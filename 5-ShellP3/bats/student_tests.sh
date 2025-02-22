#!/usr/bin/env bats

# File: student_tests.sh
#
# Create your unit tests suit in this file

setup() {
  mkdir -p ~/tmp
}

teardown() {
  rm -f ~/tmp/in.txt ~/tmp/in2.txt ~/tmp/out.txt ~/tmp/another.txt ~/tmp/notwritable.txt
}

# Command Parsing Test
@test "empty input" {
    run "./dsh" <<EOF
     
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>warning:nocommandsprovideddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "too long command" {
    long_command=$(printf 'a%.0s' {1..70})
    run "./dsh" <<EOF
$long_command
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>Errorparsingcommandlinedsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "max commands limit" {
    
    run "./dsh" <<EOF
echo 1 | echo 2 | echo 3 | echo 4 | echo 5 | echo 6 | echo 7 | echo 8 | echo 9
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>error:pipinglimitedto8commandsdsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "quote handling: parameters with spaces" {
    run "./dsh" <<EOF
echo "hello world"
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>helloworlddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "quote handling: redirection symbols inside quotes" {
    run "./dsh" <<EOF
echo "hello > world"
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>hello>worlddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Redirection Test
@test "input redirection normal" {
    echo "Hello World" > ~/tmp/in.txt

    run "./dsh" <<EOF
cat < ~/tmp/in.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>HelloWorlddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "missing input filename" {
    run "./dsh" <<EOF
cat <
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>Error:missinginputfileforredirection'<'dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "multiple input redirection" {
    echo "Content1" > ~/tmp/in.txt
    echo "Content2" > ~/tmp/in2.txt

    run "./dsh" <<EOF
cat < ~/tmp/in.txt < ~/tmp/in2.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>Error:multipleinputredirectionoperatorsdsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "output redirection overwrite" {
    rm -f ~/tmp/out.txt

    run "./dsh" <<EOF
echo "HelloOverwrite" > ~/tmp/out.txt
cat < ~/tmp/out.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>dsh3>HelloOverwritedsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "output redirection append" {
    rm -f ~/tmp/out.txt

    run "./dsh" <<EOF
echo "Line1" > ~/tmp/out.txt
echo "Line2" >> ~/tmp/out.txt
cat < ~/tmp/out.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>dsh3>dsh3>Line1Line2dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "missing output filename overwrite" {
    run "./dsh" <<EOF
echo "Hello" >
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>Error:missingoutputfileforredirection'>'dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "missing output filename append" {
    run "./dsh" <<EOF
echo "Hello" >>
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>Error:missingoutputfileforredirection'>>'dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "multiple output redirection" {
    run "./dsh" <<EOF
echo "Hello" > ~/tmp/out.txt > ~/tmp/another.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>Error:multipleoutputredirectionoperatorsdsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "nonexistent input file" {
    rm -f ~/tmp/nonexistent.txt

    run "./dsh" <<EOF
cat < ~/tmp/nonexistent.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>openinput_file:Nosuchfileordirectorydsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "output file not writable" {
    echo "ExistingContent" > ~/tmp/notwritable.txt
    chmod 444 ~/tmp/notwritable.txt

    run "./dsh" <<EOF
echo "Test" > ~/tmp/notwritable.txt
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>openoutput_file:Permissiondenieddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}