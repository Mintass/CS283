#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

@test "Empty input produces no output" {
  run ./dsh <<EOF

EOF
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "Input with only spaces is ignored" {
  run ./dsh <<EOF
       
EOF
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "Change directory - with one argument" {
  current=$(pwd)
  cd /tmp
  mkdir -p dsh-test

  run "${current}/dsh" <<EOF
cd dsh-test
pwd
EOF

  stripped_output=$(echo "$output" | tr -d '[:space:]')
  expected_output="/tmp/dsh-testdsh2>dsh2>dsh2>cmdloopreturned0"
  echo "Captured stdout:" 
  echo "Output: $output"
  echo "Exit Status: $status"
  echo "${stripped_output} -> ${expected_output}"
  [ "$stripped_output" = "$expected_output" ]
  [ "$status" -eq 0 ]
}

@test "Change directory - no arguments (directory remains unchanged)" {
  current=$(pwd)
  cd /tmp
  mkdir -p dsh-test

  run "${current}/dsh" <<EOF
cd
pwd
EOF

  stripped_output=$(echo "$output" | tr -d '[:space:]')
  expected_output="/tmpdsh2>dsh2>dsh2>cmdloopreturned0"
  echo "Captured stdout:" 
  echo "Output: $output"
  echo "Exit Status: $status"
  echo "${stripped_output} -> ${expected_output}"
  [ "$stripped_output" = "$expected_output" ]
  [ "$status" -eq 0 ]
}

@test "Change directory - too many arguments produces error" {
  run ./dsh <<EOF
cd dir1 dir2
EOF

  [[ "$output" =~ "too many arguments" ]]
  [ "$status" -eq 0 ]
}

@test "rc command after a successful external command returns 0" {
  run ./dsh <<EOF
echo success
rc
EOF
  [[ "$output" =~ "0" ]]
  [ "$status" -eq 0 ]
}

@test "rc command after a failing external command returns error code" {
  run ./dsh <<EOF
nonexistent_command
rc
EOF
  [[ "$output" =~ "Command not found in PATH" ]]
  [[ "$output" =~ [0-9]+ ]]
  [ "$status" -eq 0 ]
}

@test "Non-executable file produces permission denied error" {
  run bash -c "touch noexec && chmod -x noexec && ./dsh <<EOF
./noexec
rc
EOF
rm noexec"
  [[ "$output" =~ "Permission denied" ]]
  [[ "$output" =~ [0-9]+ ]]
  [ "$status" -eq 0 ]
}

@test "which command returns system path" {
  run ./dsh <<EOF
which which
EOF

  stripped_output=$(echo "$output" | tr -d '[:space:]')
  expected_output="/usr/bin/whichdsh2>dsh2>cmdloopreturned0"
  echo "Captured stdout:" 
  echo "Output: $output"
  echo "Exit Status: $status"
  echo "${stripped_output} -> ${expected_output}"
  [ "$stripped_output" = "$expected_output" ]
}

@test "Handles quoted spaces correctly" {
  run ./dsh <<EOF
echo " hello     world     "
EOF

  stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
  expected_output=" hello     world     dsh2> dsh2>cmdloopreturned0"
  echo "Captured stdout:" 
  echo "Output: $output"
  echo "Exit Status: $status"
  echo "${stripped_output} -> ${expected_output}"
  [ "$stripped_output" = "$expected_output" ]
}
