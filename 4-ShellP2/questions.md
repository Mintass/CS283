1. Can you think of why we use `fork/execvp` instead of just calling `execvp` directly? What value do you think the `fork` provides?

    > **Answer**:  We use the `fork/execvp` combination because `execvp` by itself replaces the current process image with a new one. If we called `execvp` directly in our shell process, the shell itself would be replaced by the external command, and we would lose control over the shell. Using `fork` creates a child process in which we call `execvp`. This way, the child process executes the external command while the our shell continues running and can wait for the child to finish.

2. What happens if the fork() system call fails? How does your implementation handle this scenario?

    > **Answer**:  If `fork()` fails, it returns -1, which indicates that the system was unable to create a new process. In my implementation, I check for this condition immediately after calling `fork()`. If it fails, I use `perror("fork failed")` to print an error message and return the error code `ERR_EXEC_CMD`, thereby preventing further execution of the command.

3. How does execvp() find the command to execute? What system environment variable plays a role in this process?

    > **Answer**: `execvp()` searches for the command in the directories specified by the `PATH` environment variable, which is a colon-separated list of directories. If the command name provided does not contain a `/`, `execvp()` iterates through these directories in order and attempts to locate an executable file matching the command name.

4. What is the purpose of calling wait() in the parent process after forking? What would happen if we didn’t call it?

    > **Answer**: The `wait()` call in the parent process causes it to block until the child process terminates. It allows the parent to retrieve the child’s exit status using macros like `WEXITSTATUS`, which can be used for error handling or reporting. What's more, if we didn’t call `wait()`, the parent process might continue running without cleaning up the terminated child, leading to zombie processes that waste system resources.

5. In the referenced demo code we used WEXITSTATUS(). What information does this provide, and why is it important?

    > **Answer**: The `WEXITSTATUS(status)` macro extracts the exit code or return value of a child process from the status value returned by `wait()`. This exit code indicates whether the child process executed successfully or encountered an error. The macro is important because it allows the shell to make decisions based on whether the executed command succeeded, failed, or encountered a specific error.

6. Describe how your implementation of build_cmd_buff() handles quoted arguments. Why is this necessary?

    > **Answer**: In my `build_cmd_buff()` implementation, when the parser encounters a `"`', it sets a flag (`in_quote = true`) indicating that it is inside a quoted section. In this mode, all characters—including spaces—are added to the current token until another double-quote is encountered, signaling the end of the quoted argument. This handling is necessary because arguments that contain spaces should be treated as a single argument rather than split into multiple tokens. This preserves the intended grouping of words within quotes.

7. What changes did you make to your parsing logic compared to the previous assignment? Were there any unexpected challenges in refactoring your old code?

    > **Answer**: In this assignment, we refactored our parsing logic to use a single cmd_buff_t structure instead of a command list, which simplifies the handling of one command line at a time. One unexpected challenge was ensuring that edge cases—such as unmatched quotes or commands with excessive spacing—were handled gracefully without causing buffer overruns or incorrect tokenization. This required careful attention to state transitions in the parser and additional boundary checks.

8. For this quesiton, you need to do some research on Linux signals. You can use [this google search](https://www.google.com/search?q=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&oq=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBBzc2MGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8) to get started.

- What is the purpose of signals in a Linux system, and how do they differ from other forms of interprocess communication (IPC)?

    > **Answer**: Signals in Linux are used to notify a process that a specific event has occurred. They are asynchronous and can interrupt a process's normal flow to handle events such as hardware exceptions, software conditions, or user actions (e.g., pressing Ctrl+C). Unlike other IPC mechanisms (such as pipes or message queues) that transfer data between processes, signals are simple notifications without data payloads. They provide a way to control process behavior (e.g., termination, suspension, or triggering a custom handler) and are primarily used for event-driven communication.

- Find and describe three commonly used signals (e.g., SIGKILL, SIGTERM, SIGINT). What are their typical use cases?

    > **Answer**:  
    > - SIGKILL (signal 9):
    > This signal forces a process to terminate immediately. It cannot be caught, blocked, or ignored. It is used as a last resort when a process refuses to terminate gracefully.
    > - SIGTERM (signal 15):
    > This is the default termination signal used by commands like `kill`. It requests a process to terminate gracefully, allowing it to perform cleanup operations before exiting. Processes can catch and handle `SIGTERM` to, for example, save state or release resources.
    > - SIGINT (signal 2):
    > Typically generated by pressing Ctrl+C in the terminal, `SIGINT` interrupts a process. It is intended to allow users to abort a running process. Processes can catch `SIGINT` to perform cleanup or ignore it if appropriate.

- What happens when a process receives SIGSTOP? Can it be caught or ignored like SIGINT? Why or why not?

    > **Answer**: When a process receives `SIGSTOP`, it is immediately suspended (paused) by the operating system. Unlike `SIGINT`, `SIGSTOP` cannot be caught, blocked, or ignored. This is by design because `SIGSTOP` is meant to unconditionally pause a process, allowing system administrators or debuggers to halt a process's execution for inspection or management. The inability to catch or ignore `SIGSTOP` ensures that a process cannot prevent itself from being stopped.