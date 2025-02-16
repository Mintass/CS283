#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file


@test "only spaces input is ignored" {
  run ./dsh <<EOF
       
EOF
  [ "$status" -eq 0 ]
}

@test "ls command runs without errors" {
  run ./dsh <<EOF
ls
EOF
  [ "$status" -eq 0 ]
}

@test "echo command with quoted argument" {
  run ./dsh <<EOF
echo "hello,      world"
EOF
  expected="hello,      world"
  [ "$output" = "$expected" ]
  [ "$status" -eq 0 ]
}

@test "cd with no arguments does not change directory" {
  current_dir="$(pwd)"
  run ./dsh <<EOF
cd
pwd
EOF
  [ "$output" = "$current_dir" ]
  [ "$status" -eq 0 ]
}

@test "cd with one argument changes directory" {
  mkdir -p testdir
  run ./dsh <<EOF
cd testdir
pwd
EOF
  [[ "$output" =~ testdir$ ]]
  [ "$status" -eq 0 ]
  rmdir testdir
}

@test "cd with too many arguments" {
  run ./dsh <<EOF
cd dir1 dir2
EOF
  [[ "$output" =~ "too many arguments" ]]
  [ "$status" -eq 0 ]
}

@test "non-executable command returns permission denied" {
  touch noexec
  chmod -x noexec
  run ./dsh <<EOF
./noexec
rc
EOF
  [[ "$output" =~ "Permission denied" ]]
  [[ "$output" =~ "13" ]]
  [ "$status" -eq 0 ]
  rm noexec
}

@test "non-existent command returns proper error and rc builtin shows error code" {
  run ./dsh <<EOF
nonexistent_command
rc
EOF
  [[ "$output" =~ "Command not found in PATH" ]]
  [[ "$output" =~ [0-9]+ ]]
  [ "$status" -eq 0 ]
}

@test "rc command shows correct exit code after success" {
  run ./dsh <<EOF
echo success
rc
EOF
  [[ "$output" =~ "0" ]]
  [ "$status" -eq 0 ]
}

@test "uname command returns system info" {
  run ./dsh <<EOF
uname
EOF
  [[ "$output" =~ "Linux" ]] || [[ "$output" =~ "Darwin" ]]
  [ "$status" -eq 0 ]
}