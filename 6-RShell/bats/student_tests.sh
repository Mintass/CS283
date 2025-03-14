#!/usr/bin/env bats

@test "Local Mode: Basic Command" {
    run "./dsh" <<EOF
ls -la
exit
EOF

    echo "Captured stdout:"
    echo "$output"
    echo "Exit Status: $status"
    
    [[ "$output" == *"local mode"* ]]
    [[ "$output" == *"dshlib.c"* ]]
    [[ "$output" == *"rshlib.h"* ]]
    
    [ "$status" -eq 0 ]
}

@test "Local Mode: Pipe Command" {
    run "./dsh" <<EOF
ls | grep .c
exit
EOF

    echo "Captured stdout:"
    echo "$output"
    echo "Exit Status: $status"
    
    [[ "$output" == *"local mode"* ]]
    [[ "$output" == *"dshlib.c"* ]]
    [[ "$output" == *"dsh_cli.c"* ]]
    
    [ "$status" -eq 0 ]
}

@test "Local Mode: Built-in Command (cd)" {
    run "./dsh" <<EOF
cd ..
pwd
exit
EOF

    echo "Captured stdout:"
    echo "$output"
    echo "Exit Status: $status"
    
    [[ "$output" == *"local mode"* ]]
    [[ "$output" != *"$(basename $(pwd))"* ]]
    
    [ "$status" -eq 0 ]
}

@test "Single-Threaded Server: Start and Stop" {
    ./dsh -s -p 5678 &
    server_pid=$!
    
    sleep 1
    
    run "./dsh" -c -p 5678 <<EOF
stop-server
EOF

    wait $server_pid
    server_status=$?
    
    echo "Server exit status: $server_status"
    echo "Client output:"
    echo "$output"
    echo "Client exit status: $status"
    
    [ "$server_status" -eq 0 ]
    [ "$status" -eq 0 ]
    [[ "$output" == *"stop"* ]]
}

@test "Single-Threaded Server: Basic Command" {
    ./dsh -s -p 5679 &
    server_pid=$!
    
    sleep 1
    
    run "./dsh" -c -p 5679 <<EOF
ls -la
exit
EOF

    ./dsh -c -p 5679 <<EOF
stop-server
EOF
    
    wait $server_pid
    
    echo "Client output:"
    echo "$output"
    echo "Client exit status: $status"
    
    [[ "$output" == *"dshlib.c"* ]]
    [[ "$output" == *"rshlib.h"* ]]
    
    [ "$status" -eq 0 ]
}

@test "Multi-Threaded Server: Start and Stop" {
    ./dsh -s -x -p 5680 &
    server_pid=$!
    
    sleep 1
    
    run "./dsh" -c -p 5680 <<EOF
stop-server
EOF

    wait $server_pid
    server_status=$?
    
    echo "Server exit status: $server_status"
    echo "Client output:"
    echo "$output"
    echo "Client exit status: $status"
    
    [ "$server_status" -eq 0 ]
    [ "$status" -eq 0 ]
    [[ "$output" == *"stop"* ]]
}

@test "Multi-Threaded Server: Concurrent Clients" {
    ./dsh -s -x -p 5681 &
    server_pid=$!
    
    sleep 1
    
    temp_dir=$(mktemp -d)
    client1_output="$temp_dir/client1.out"
    client2_output="$temp_dir/client2.out"
    
    (echo "echo client1_test" | ./dsh -c -p 5681 > "$client1_output" 2>&1) &
    client1_pid=$!
    
    (echo "echo client2_test" | ./dsh -c -p 5681 > "$client2_output" 2>&1) &
    client2_pid=$!
    
    wait $client1_pid
    wait $client2_pid
    
    ./dsh -c -p 5681 <<EOF
stop-server
EOF

    wait $server_pid
    server_status=$?
    
    client1_content=$(cat "$client1_output")
    client2_content=$(cat "$client2_output")
    
    echo "Server exit status: $server_status"
    echo "Client 1 output: $client1_content"
    echo "Client 2 output: $client2_content"
    
    rm -r "$temp_dir"
    
    [[ "$client1_content" == *"client1_test"* ]]
    [[ "$client2_content" == *"client2_test"* ]]
    
    [ "$server_status" -eq 0 ]
}

@test "Multi-Threaded Server: Many Concurrent Clients" {
    ./dsh -s -x -p 5682 &
    server_pid=$!
    
    sleep 1
    
    temp_dir=$(mktemp -d)
    num_clients=5
    client_pids=()
    
    for i in $(seq 1 $num_clients); do
        output_file="$temp_dir/client$i.out"
        (echo "echo client${i}_test" | ./dsh -c -p 5682 > "$output_file" 2>&1) &
        client_pids+=($!)
    done
    
    for pid in "${client_pids[@]}"; do
        wait $pid
    done
    
    ./dsh -c -p 5682 <<EOF
stop-server
EOF

    wait $server_pid
    server_status=$?
    
    success=true
    for i in $(seq 1 $num_clients); do
        output_file="$temp_dir/client$i.out"
        content=$(cat "$output_file")
        echo "Client $i output: $content"
        if [[ "$content" != *"client${i}_test"* ]]; then
            success=false
            echo "Client $i failed!"
        fi
    done
    
    rm -r "$temp_dir"
    
    [ "$success" = true ]
    
    [ "$server_status" -eq 0 ]
}

@test "Multi-Threaded Server: Complex Commands" {
    ./dsh -s -x -p 5683 &
    server_pid=$!
    
    sleep 1
    
    run "./dsh" -c -p 5683 <<EOF
ps aux | grep dsh | wc -l
exit
EOF

    ./dsh -c -p 5683 <<EOF
stop-server
EOF
    
    wait $server_pid
    
    echo "Client output:"
    echo "$output"
    echo "Client exit status: $status"
    
    [[ "$output" =~ [0-9]+ ]]
    
    [ "$status" -eq 0 ]
}