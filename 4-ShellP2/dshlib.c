#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/wait.h>

#include "dshlib.h"

static int last_exit_code = 0;

/* ----------------- Memory management for cmd_buff_t ----------------- */
int alloc_cmd_buff(cmd_buff_t *cmd_buff) {
	cmd_buff->_cmd_buffer = malloc((SH_CMD_MAX * sizeof(char)));
	if (!cmd_buff->_cmd_buffer) {
		return ERR_MEMORY;
	}

	cmd_buff->argc = 0;
	for (int i = 0; i < CMD_ARGV_MAX; i++) {
		cmd_buff->argv[i] = NULL;
	}

	return OK;
}

int free_cmd_buff(cmd_buff_t *cmd_buff) {
	if (cmd_buff->_cmd_buffer) {
		free(cmd_buff->_cmd_buffer);
		cmd_buff->_cmd_buffer = NULL;
	}

	for (int i = 0; i < cmd_buff->argc; i++) {
		if (cmd_buff->argv[i]) {
			free(cmd_buff->argv[i]);
			cmd_buff->argv[i] = NULL;
		}
	}

	cmd_buff->argc = 0;
	return OK;
}

int clean_cmd_buff(cmd_buff_t *cmd_buff) {
	for (int i = 0; i < cmd_buff->argc; i++) {
		if (cmd_buff->argv[i]) {
			free(cmd_buff->argv[i]);
			cmd_buff->argv[i] = NULL;
		}
	}

	cmd_buff->argc = 0;
	if (cmd_buff->_cmd_buffer) {
		cmd_buff->_cmd_buffer[0] = '\0';
	}

	return OK;
}

/* ----------------- Command Line Input Parser ----------------- */
int build_cmd_buff(char *cmd_line, cmd_buff_t *cmd_buff) {
	int argc = 0;
	char token[ARG_MAX];
	int token_index = 0;
	char *p = cmd_line;
	bool in_quote = false;
	bool in_token = false;

	while (*p != '\0') {
		if (in_quote) {
			if (*p == '"') {
				in_quote = false;
				token[token_index] = '\0';
				if (token_index > 0) {
					if (argc >= CMD_ARGV_MAX - 1) {
						return ERR_CMD_ARGS_BAD;
					}

					cmd_buff->argv[argc] = strdup(token);
					argc++;
				}

				token_index = 0;
				in_token = false;
			} else {
				token[token_index++] = *p;
			}
		} else {
			if (*p == '"') {
				in_quote = true;
				in_token = true;
			} else if (isspace((unsigned char)*p)) {
				if (in_token) {
					token[token_index] = '\0';
					if (argc >= CMD_ARGV_MAX - 1) {
						return ERR_CMD_ARGS_BAD;
					}

					cmd_buff->argv[argc] = strdup(token);
					argc++;
					token_index = 0;
					in_token = false;
				}
			} else {
				in_token = true;
				token[token_index++] = *p;
			}
		}

		p++;
	}

	if (in_quote || in_token) {
		token[token_index] = '\0';
		if (argc < CMD_ARGV_MAX - 1) {
			cmd_buff->argv[argc] = strdup(token);
			argc++;
		}
	}

	cmd_buff->argv[argc] = NULL;
	cmd_buff->argc = argc;

	return OK;
}

/* ----------------- Builtin Command Processing ----------------- */
Built_In_Cmds match_command(const char *input) {
	if (strcmp(input, EXIT_CMD) == 0) {
		return BI_CMD_EXIT;
	}

	if (strcmp(input, "cd") == 0) {
		return BI_CMD_CD;
	}

	if (strcmp(input, "dragon") == 0) {
		return BI_CMD_DRAGON;
	}

	if (strcmp(input, "rc") == 0) {
		return BI_RC;
	}

	return BI_NOT_BI;
}

Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd) {
	Built_In_Cmds type = match_command(cmd->argv[0]);
	if (type == BI_CMD_EXIT) {
		exit(0);
	}

	if (type == BI_CMD_CD) {
		if (cmd->argc == 1) {
			// Do nothing
		} else if (cmd->argc == 2) {
			if (chdir(cmd->argv[1]) != 0) {
				perror("cd failed");
			}
		} else {
			fprintf(stderr, "cd: too many arguments\n");
		}

		return BI_EXECUTED;
	}

	if (type == BI_CMD_DRAGON) {
		if (cmd->argc > 1) {
			fprintf(stderr, "dragon: too many arguments\n");
		}

		print_dragon();
		return BI_EXECUTED;
	}

	return  BI_NOT_BI;
}

/* ----------------- Extra Command Processing ----------------- */
int exec_cmd(cmd_buff_t *cmd) {
	pid_t pid = fork();
	if (pid < 0) {
		perror("fork failed");
		return ERR_EXEC_CMD;
	}

	if (pid == 0) {
		execvp(cmd->argv[0], cmd->argv);
		int err = errno;
		if (err == ENOENT) {
			fprintf(stderr, "Command not found in PATH\n");
		} else if (err == EACCES) {
			fprintf(stderr, "Permission denied\n");
		} else {
			perror("execvp failed");
		}

		exit(err);
	}

	int status;
	waitpid(pid, &status, 0);
	last_exit_code = WEXITSTATUS(status);

	return status;
}

/* ----------------- Main Loop ----------------- */
/*
 * Implement your exec_local_cmd_loop function by building a loop that prompts the 
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 * use fgets to accept user input.
 * 
 *      while(1){
 *        printf("%s", SH_PROMPT);
 *        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL){
 *           printf("\n");
 *           break;
 *        }
 *        //remove the trailing \n from cmd_buff
 *        cmd_buff[strcspn(cmd_buff,"\n")] = '\0';
 * 
 *        //IMPLEMENT THE REST OF THE REQUIREMENTS
 *      }
 * 
 *   Also, use the constants in the dshlib.h in this code.  
 *      SH_CMD_MAX              maximum buffer size for user input
 *      EXIT_CMD                constant that terminates the dsh program
 *      SH_PROMPT               the shell prompt
 *      OK                      the command was parsed properly
 *      WARN_NO_CMDS            the user command was empty
 *      ERR_TOO_MANY_COMMANDS   too many pipes used
 *      ERR_MEMORY              dynamic memory management failure
 * 
 *   errors returned
 *      OK                     No error
 *      ERR_MEMORY             Dynamic memory management failure
 *      WARN_NO_CMDS           No commands parsed
 *      ERR_TOO_MANY_COMMANDS  too many pipes used
 *   
 *   console messages
 *      CMD_WARN_NO_CMD        print on WARN_NO_CMDS
 *      CMD_ERR_PIPE_LIMIT     print on ERR_TOO_MANY_COMMANDS
 *      CMD_ERR_EXECUTE        print on execution failure of external command
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 1+)
 *      malloc(), free(), strlen(), fgets(), strcspn(), printf()
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 2+)
 *      fork(), execvp(), exit(), chdir()
 */
int exec_local_cmd_loop()
{
    cmd_buff_t cmd;
	int rc = alloc_cmd_buff(&cmd);
    if (rc != OK) {
    	fprintf(stderr, "Failed to allocate command buffer\n");
    	return rc;
    }

	char cmd_buff[SH_CMD_MAX];
    int cmdCount = 0;   // pass assignment test
    while (1) {
        if (cmdCount > 0) {     // pass assignment test
            printf("%s", SH_PROMPT);
            fflush(stdout);
        }

	    if (fgets(cmd_buff, SH_CMD_MAX, stdin) == NULL) {
		    printf("\n");
	    	break;
	    }

    	cmd_buff[strcspn(cmd_buff, "\n")] = '\0';
    	
    	clean_cmd_buff(&cmd);
	    if (strlen((cmd_buff)) == 0) {
		    continue;
	    }

    	strncpy(cmd._cmd_buffer, cmd_buff, SH_CMD_MAX);
    	rc = build_cmd_buff(cmd_buff, &cmd);
	    if (rc != OK) {
		    fprintf(stderr, "Error parsing command line\n");
	    	continue;
	    }

	    if (cmd.argc == 0) {
		    continue;
	    }

    	Built_In_Cmds builtin = match_command(cmd.argv[0]);
	    if (builtin != BI_NOT_BI) {
		    exec_built_in_cmd(&cmd);
	    } else {
		    exec_cmd(&cmd);
	    }

        commandCount++;     // pass assignment test
    }

	free_cmd_buff(&cmd);
	return OK;
}