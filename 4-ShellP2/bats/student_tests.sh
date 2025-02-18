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
    current=$(pwd)

    cd /tmp
    mkdir -p no_perm_dir
    chmod 000 no_perm_dir

    run "${current}/dsh" <<EOF
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
    current=$(pwd)

    cd /tmp

    run "${current}/dsh" <<EOF
cd dir1 dir2
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="cd:toomanyarguments/tmpdsh2>dsh2>dsh2>cmdloopreturned0"

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
    current=$(pwd)

    run "${current}/dsh" <<EOF
not_exists
rc
EOF

    # Remove all whitespace (spaces, tabs, newlines) for easier matching.
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="CommandnotfoundinPATH2dsh2>dsh2>dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Extra Credit: Successful external command and rc returns 0" {
    current=$(pwd)

    run "${current}/dsh" <<EOF
echo hello
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="hello0dsh2>dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Empty input line is handled gracefully" {
    current=$(pwd)

    run "${current}/dsh" <<EOF
       
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Command with leading and trailing spaces" {
    current=$(pwd)

    run "${current}/dsh" <<EOF
   echo spaced   
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="spaceddsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "Multiple spaces between arguments collapse to single space in output" {
    current=$(pwd)
    
    run "${current}/dsh" <<EOF
echo a    b   c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="abcdsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

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
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}
