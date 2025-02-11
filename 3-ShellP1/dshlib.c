#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "dshlib.h"

static char *trim_whitespace(char *str) {
    while (isspace((unsigned)*str)) {
        str++;
    }

    if (*str == '\0') {
        return str;
    }

    char *end = str + strlen(str) - 1;
    while (end > str && isspace((unsigned)*end)) {
        *end = '\0';
        end--;
    }
    
    return str;
}

/*
 *  build_cmd_list
 *    cmd_line:     the command line from the user
 *    clist *:      pointer to clist structure to be populated
 *
 *  This function builds the command_list_t structure passed by the caller
 *  It does this by first splitting the cmd_line into commands by spltting
 *  the string based on any pipe characters '|'.  It then traverses each
 *  command.  For each command (a substring of cmd_line), it then parses
 *  that command by taking the first token as the executable name, and
 *  then the remaining tokens as the arguments.
 *
 *  NOTE your implementation should be able to handle properly removing
 *  leading and trailing spaces!
 *
 *  errors returned:
 *
 *    OK:                      No Error
 *    ERR_TOO_MANY_COMMANDS:   There is a limit of CMD_MAX (see dshlib.h)
 *                             commands.
 *    ERR_CMD_OR_ARGS_TOO_BIG: One of the commands provided by the user
 *                             was larger than allowed, either the
 *                             executable name, or the arg string.
 *
 *  Standard Library Functions You Might Want To Consider Using
 *      memset(), strcmp(), strcpy(), strtok(), strlen(), strchr()
 */
int build_cmd_list(char *cmd_line, command_list_t *clist)
{
    char *trimmed_line = trim_whitespace(cmd_line);
    if (strlen(trimmed_line) == 0) {
        return WARN_NO_CMDS;
    }
    
    int cmdCount = 0;
    char *token = strtok(cmd_line, PIPE_STRING);
    while (token != NULL) {
        char *cmd_token = trim_whitespace(token);
        if (strlen(cmd_token) > 0) {
            if (cmdCount >= CMD_MAX) {
                return ERR_TOO_MANY_COMMANDS;
            }
            
            char *inner = strtok(cmd_token, " ");
            if (inner == NULL) {
                token = strtok(NULL, PIPE_STRING);
                continue;
            }
            
            if (strlen(inner) >= EXE_MAX) {
                return ERR_CMD_OR_ARGS_TOO_BIG;
            }

            strcpy(clist->commands[cmdCount].exe, inner);
            clist->commands[cmdCount].args[0] = '\0';

            inner = strtok(NULL, " ");
            while (inner != NULL) {
                if (strlen(clist->commands[cmdCount].args) > 0) {
                    if (strlen(clist->commands[cmdCount].args) + 1 + strlen(inner) >= ARG_MAX) {
                        return ERR_CMD_OR_ARGS_TOO_BIG;
                    }

                    strcat(clist->commands[cmdCount].args, " ");
                } else {
                    if (strlen(inner) >= ARG_MAX)
                    {
                        return ERR_CMD_OR_ARGS_TOO_BIG;
                    }                   
                }

                if (strlen(clist->commands[cmdCount].args) + strlen(inner) >= ARG_MAX) {
                    return ERR_CMD_OR_ARGS_TOO_BIG;
                }

                strcat(clist->commands[cmdCount].args, inner);
                inner = strtok(NULL, " ");
            }
            
            cmdCount++;
        }
        
        token = strtok(NULL, PIPE_STRING);
    }

    clist->num = cmdCount;
    if (cmdCount == 0) {
        return WARN_NO_CMDS;
    }
    
    return OK;
}