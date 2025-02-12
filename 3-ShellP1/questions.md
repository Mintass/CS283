1. In this assignment I suggested you use `fgets()` to get user input in the main while loop. Why is `fgets()` a good choice for this application?

    > **Answer**: `fgets()` is well-suited for this application because it reads an entire line from the input—including spaces—up to a specified limit. This behavior is important for a shell since commands are entered line-by-line. It also safely handles buffer boundaries by requiring a maximum size, reducing the risk of buffer overflows. Additionally, `fgets()` gracan cefully handles end-of-file (EOF) conditions well, which is useful when running automated tests or in headless environments.

2. You needed to use `malloc()` to allocte memory for `cmd_buff` in `dsh_cli.c`. Can you explain why you needed to do that, instead of allocating a fixed-size array?

    > **Answer**: It provides flexibility, the size of the buffer can be adjusted based on user input or configuration without being constrained by fixed compile-time limits. It avoids potential stack overflow issues, especially when the required buffer size is large. It enables the program to manage memory more efficiently.


3. In `dshlib.c`, the function `build_cmd_list()` must trim leading and trailing spaces from each command before storing it. Why is this necessary? If we didn't trim spaces, what kind of issues might arise when executing commands in our shell?

    > **Answer**: Because user input often contains extra whitespace that is not part of the intended command or its arguments. If these spaces aren't removed, the command name might include unwanted spaces, causing mismatches when trying to execute the intended binary. for example, " ls" might not be found even though "ls" exists. Extra spaces in the arguments can lead to incorrect parsing or unexpected behavior when commands are executed. Overall, the shell might misinterpret the user's intentions, leading to errors or failed command executions.

4. For this question you need to do some research on STDIN, STDOUT, and STDERR in Linux. We've learned this week that shells are "robust brokers of input and output". Google _"linux shell stdin stdout stderr explained"_ to get started.

- One topic you should have found information on is "redirection". Please provide at least 3 redirection examples that we should implement in our custom shell, and explain what challenges we might have implementing them.

    > **Answer**:
    > 1. `>`: `ls > output` The shell must open/create the file for writing, duplicate the STDOUT file descriptor to the file descriptor of the file, and ensure that error conditions like permission issues are properly handled.
    > 2. `<`: `sort < input` The shell needs to open the specified file for reading and redirect STDIN to read from that file. It must handle cases where the file does not exist or is inaccessible.
    > 3. `>>`: `echo "Hello" >> log` Similar to output redirection, but the shell must open the file in append mode instead of truncating it. Handling file locking and ensuring that multiple writes do not corrupt the file is also a concern.

- You should have also learned about "pipes". Redirection and piping both involve controlling input and output in the shell, but they serve different purposes. Explain the key differences between redirection and piping.

    > **Answer**: Redirection changes the source or destination of a single command’s standard streams (STDIN, STDOUT, or STDERR) to or from a file, redirecting output to a file saves the result rather than displaying it. Piping connects the STDOUT of one command directly to the STDIN of another command, allowing the output of one command to be processed immediately by the next. This is useful for chaining commands together.

- STDERR is often used for error messages, while STDOUT is for regular output. Why is it important to keep these separate in a shell?

    > **Answer**: It allows users and programs to distinguish between normal output and error messages. Scripts and command-line tools can redirect or process errors independently of the standard output. Mixing them can lead to confusion in the output, making debugging and logging more difficult. For instance, a user might want to capture only error messages to a log file while displaying regular output on the console.

- How should our custom shell handle errors from commands that fail? Consider cases where a command outputs both STDOUT and STDERR. Should we provide a way to merge them, and if so, how?

    > **Answer**:  The shell need to capture and display the exit status of a command so that users are aware of failures. When we are debugging, merging them may be helpful. We can provide syntax like `2>&1` that merges STDERR into STDOUT. This means that both outputs are sent to the same destination, making it easier to trace the flow of execution and error messages.