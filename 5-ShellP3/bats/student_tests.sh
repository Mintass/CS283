#!/usr/bin/env bats

# File: student_tests.sh
#
# Create your unit tests suit in this file

setup() {
  mkdir -p $HOME/tmp
}

teardown() {
  rm -f $HOME/tmp/re_in.txt $HOME/tmp/re_in2.txt $HOME/tmp/re_out.txt $HOME/tmp/another.txt $HOME/tmp/notwritable.txt $HOME/tmp/pipe_in.txt $HOME/tmp/pipe_out.txt
}

# Command Parsing Test
@test "empty input" {
    run "./dsh" <<EOF
     
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="warning:nocommandsprovideddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "command too lohg" {
    long_cmd=$(printf 'a%.0s' {1..360})
    run "./dsh" <<EOF
$long_cmd
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="error:maximumbuffersizeforuserinputis320dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "exe too long" {
    long_exe=$(printf 'a%.0s' {1..70})
    run "./dsh" <<EOF
$long_exe
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="error:commandnametoolongerrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "arg too long" {
    long_arg=$(printf 'a%.0s' {1..300})
    run "./dsh" <<EOF
echo $long_arg
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="error:argumenttoolongerrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

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
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="error:pipinglimitedto8commandsdsh3>dsh3>cmdloopreturned0"

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
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="helloworlddsh3>dsh3>cmdloopreturned0"

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
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="hello>worlddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "cd with too many arguments" {
    run "./dsh" <<EOF
cd a b
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="cd:toomanyargumentsdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Redirection Test
@test "input redirection normal" {
    echo "Hello World" > $HOME/tmp/re_in.txt

    run "./dsh" <<EOF
cat < $HOME/tmp/re_in.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="HelloWorlddsh3>dsh3>cmdloopreturned0"

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
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="redirect:missinginputfileforredirectionerrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "multiple input redirection" {
    echo "Content1" > $HOME/tmp/re_in.txt
    echo "Content2" > $HOME/tmp/re_in2.txt

    run "./dsh" <<EOF
cat < $HOME/tmp/re_in.txt < $HOME/tmp/re_in2.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="redirect:multipleinputredirectionoperatorserrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "output redirection overwrite" {
    rm -f $HOME/tmp/re_out.txt

    run "./dsh" <<EOF
echo "HelloOverwrite" > $HOME/tmp/re_out.txt
cat < $HOME/tmp/re_out.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="HelloOverwritedsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "output redirection append" {
    rm -f $HOME/tmp/re_out.txt

    run "./dsh" <<EOF
echo "Line1" > $HOME/tmp/re_out.txt
echo "Line2" >> $HOME/tmp/re_out.txt
cat < $HOME/tmp/re_out.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="Line1Line2dsh3>dsh3>dsh3>dsh3>cmdloopreturned0"

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
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="redirect:missingoutputfileforredirection'>'errorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

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
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="redirect:missingoutputfileforredirection'>>'errorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "multiple output redirection" {
    run "./dsh" <<EOF
echo "Hello" > $HOME/tmp/re_out.txt > $HOME/tmp/another.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="redirect:multipleoutputredirectionoperatorserrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "nonexistent input file" {
    rm -f $HOME/tmp/nonexistent.txt

    run "./dsh" <<EOF
cat < $HOME/tmp/nonexistent.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="openinputfile:Nosuchfileordirectorydsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "output file not writable" {
    echo "ExistingContent" > $HOME/tmp/notwritable.txt
    chmod 444 $HOME/tmp/notwritable.txt

    run "./dsh" <<EOF
echo "Test" > $HOME/tmp/notwritable.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="openoutputfile:Permissiondenieddsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "redirection without commands" {
    run "./dsh" <<EOF
< re_input.txt | pwd | > re_output.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="warning:nocommandsprovideddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# pipe test
@test "single command execution" {
    run "./dsh" <<EOF
echo "HelloSingle"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="HelloSingledsh3>dsh3>cmdloopreturned0"
    
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "two command pipeline" {
    run "./dsh" <<EOF
echo "hello.c world" | grep ".c"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="hello.cworlddsh3>dsh3>cmdloopreturned0"
    
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "three command pipeline" {
    run "./dsh" <<EOF
printf "3\n2\n1\n" | cat | sort
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="123dsh3>dsh3>cmdloopreturned0"
    
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "pipeline with Mixed redirection" {
    echo -e "bar\nfoo\nbazfoo\nabc" > ~/tmp/pipe_in.txt

    run "./dsh" <<EOF
cat < ~/tmp/pipe_in.txt | grep foo | sort > ~/tmp/pipe_out.txt
EOF

    file_content=$(cat ~/tmp/pipe_out.txt | tr -d '[:space:]')
    expected_file_content="bazfoofoo"
    echo "Captured file content:"
    echo "Content: $file_content"
    [ "$file_content" = "$expected_file_content" ]

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>dsh3>cmdloopreturned0"
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "pipeline with CMD_MAX commands" {
    run "./dsh" <<EOF
echo 1 | cat | cat | cat | cat | cat | cat | cat
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="1dsh3>dsh3>cmdloopreturned0"
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "pipeline with command parsing error" {
    run "./dsh" <<EOF
echo hello | cat <
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="redirect:missinginputfileforredirectionerrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"
    
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "empty command segment" {
    run "./dsh" <<EOF
ls | | grep foo
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="warning:nocommandsprovideddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "intermediate command redirection" {
    echo "dummy" > ~/tmp/pipe_in.txt

    run "./dsh" <<EOF
echo hello | grep foo < ~/tmp/pipe_in.txt | sort
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="error:redirectionnotallowedinintermediatecommandserrorparsingcommandlinedsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "partial command failure" {
    run "./dsh" <<EOF
nonexistent_command | cat
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="execvp:Nosuchfileordirectorydsh3>dsh3>dsh3>cmdloopreturned0"
    
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

@test "mixed builtin and external commands in pipeline" {
    run "./dsh" <<EOF
echo hello | cd /tmp
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="execvp:Nosuchfileordirectorydsh3>dsh3>dsh3>cmdloopreturned0"
    
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}
