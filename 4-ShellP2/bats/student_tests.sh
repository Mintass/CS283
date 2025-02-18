#!/usr/bin/env bats
#
# Student Test Suite for dsh Assignment: Custom Shell Part 2 - Fork/Exec
#
# This file contains additional tests (edge cases and extra credit tests)
# to supplement the assignment_tests.sh.
#
# The tests cover:
#   - cd with non-existent directory
#   - cd into directory with no permission
#   - cd with too many arguments
#   - Extra Credit: Nonexistent command error and "rc" built-in command
#   - Extra Credit: Successful external command returns rc 0
#   - Handling of an empty input line
#   - A command with leading and trailing spaces
#   - Collapsing of multiple spaces between arguments (outside quoted strings)
#   - A combination of built-in and external commands
################################################################################

@test "cd with non-existent directory" {
    # This test verifies that if a non-existent directory is provided,
    # an appropriate error message is printed and the working directory remains unchanged.
    current=$(pwd)

    cd /tmp

    run "${current}/dsh" <<EOF
cd /nonexistent_directory
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="cdfailed:Nosuchfileordirectory/tmpdsh2>dsh2>dsh2>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]
}

@test "cd into directory with no permission" {
    # This test creates a temporary directory with a subdirectory that has no permissions.
    # Attempting to cd into this directory should result in an error message.
    cd /tmp
    mkdir -p no_perm_dir
    chmod 000 no_perm_dir

    run "./dsh" <<EOF
cd no_perm_dir
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="cdfailed:Permissiondenied/tmpdsh2>dsh2>dsh2>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]
}

@test "cd with too many arguments" {
    # This test verifies that providing too many arguments to cd results in an error message.
    
    cd /tmp

    run "./dsh" <<EOF
cd dir1 dir2
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="cd:toomanyargumentsdsh2>dsh2>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Extra Credit: Nonexistent command error and rc built-in" {
    run "./dsh" <<EOF
not_exists
rc
exit
EOF

    # Remove all whitespace (spaces, tabs, newlines) for easier matching.
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # - The "not_exists" command should trigger an error message: "Command not found in PATH"
    # - The "rc" built-in should print the error code from the last command (assumed to be "2")
    # - With 3 commands, dsh prints 4 prompts ("dsh2>") and then "cmd loop returned 0"
    #
    # Therefore, the expected output (with whitespace removed) is:
    # "CommandnotfoundinPATH2dsh2>dsh2>dsh2>dsh2>cmdloopreturned0"
    expected_output="CommandnotfoundinPATH2dsh2>dsh2>dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Stripped Output: ${stripped_output}"
    echo "Expected Output: ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Extra Credit: Successful external command and rc returns 0" {
    run "./dsh" <<EOF
echo hello
rc
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # - "echo hello" should output "hello"
    # - "rc" should then output "0" because echo executed successfully
    # - With 3 commands, expect 4 prompts ("dsh2>") plus final "cmd loop returned 0"
    #
    # Expected (whitespace removed):
    # "hellodsh2>dsh2>0dsh2>dsh2>cmdloopreturned0"
    expected_output="hellodsh2>dsh2>0dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Stripped Output: ${stripped_output}"
    echo "Expected Output: ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Empty input line is handled gracefully" {
    run "./dsh" <<EOF
       
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # If an empty line is entered, the shell should ignore it.
    # Therefore, only the prompt for the "exit" command and the final message are expected.
    #
    # For a single (ignored) command plus exit, assume one prompt ("dsh2>") then "cmd loop returned 0":
    expected_output="dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Stripped Output: ${stripped_output}"
    echo "Expected Output: ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Command with leading and trailing spaces" {
    run "./dsh" <<EOF
   echo spaced   
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # The input line has extra spaces at the beginning and end.
    # After trimming, "echo spaced" should output "spaced".
    # For one command, expect 2 prompts ("dsh2>") plus the final "cmd loop returned 0".
    #
    # Expected (whitespace removed):
    # "spaceddsh2>dsh2>dsh2>cmdloopreturned0"
    expected_output="spaceddsh2>dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Stripped Output: ${stripped_output}"
    echo "Expected Output: ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Multiple spaces between arguments collapse to single space in output" {
    run "./dsh" <<EOF
echo a    b   c
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # The command "echo a    b   c" should collapse duplicate spaces between arguments.
    # Thus, the output from echo should be "a b c" (when printed normally).
    # When all whitespace is removed, "a b c" becomes "abc".
    # For one command, expect 2 prompts plus the final message.
    #
    # Expected (whitespace removed):
    # "abcdsh2>dsh2>cmdloopreturned0"
    expected_output="abcdsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Stripped Output: ${stripped_output}"
    echo "Expected Output: ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Combination of built-in and external commands" {
    # This test mixes the cd built-in with external commands.
    current=$(pwd)
    cd /tmp
    mkdir -p dsh-combo-test

    run "${current}/dsh" <<EOF
cd dsh-combo-test
echo combo test
pwd
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # - "cd dsh-combo-test" changes the directory; no output is produced.
    # - "echo combo test" should output "combo test" (when spaces are normalized, becomes "combotest" after whitespace removal)
    # - "pwd" should output "/tmp/dsh-combo-test"
    # With 3 commands, expect 4 prompts ("dsh2>") plus final "cmd loop returned 0".
    #
    # Expected (whitespace removed):
    # "/tmp/dsh-combo-testdsh2>dsh2>combotestdsh2>dsh2>cmdloopreturned0"
    expected_output="/tmp/dsh-combo-testdsh2>dsh2>combotestdsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Stripped Output: ${stripped_output}"
    echo "Expected Output: ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}
