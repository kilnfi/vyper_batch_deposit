#!/bin/bash

# Set FORK_URL environment variable before running this script.

# Run the sequence of commands:
# 1. Start Anvil server
# 2. Wait for Anvil server to start
# 3. Run forge benchmark script
# 4. Echo results
# 5. End Anvil server
run_benchmark() {
    # Run anvil
    anvil -m 'test test test test test test test test test test test junk' --balance 100000 --fork-url ${FORK_URL} --fork-block-number 17712841 > anvil.log 2>&1 &
    ANVIL_PID=$!

    # Wait for anvil to start
    echo "Waiting for Anvil server to start"
    while ! nc -z localhost 8545; do 
        sleep 1
        echo -n .
    done
    echo

    # Run benchmark
    forge script Benchmark --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --skip-simulation --slow --ffi
    
    printf "Last block-number: "
    cast block-number --rpc-url http://localhost:8545   

    # Echo results 
    echo ""
    echo "Benchmark results:"
    echo "=================="
    echo ""

    printf "Vyper bigBatchDeposit 126 validators => "
    cast bl 17712844 --field gasUsed --rpc-url http://localhost:8545  
    
    printf "Vyper bigBatchDeposit 3 validators => "
    cast bl 17712845 --field gasUsed --rpc-url http://localhost:8545  
    
    printf "Vyper batchDeposit 3 validators => "
    cast bl 17712846 --field gasUsed --rpc-url http://localhost:8545  
    

    # End benchmark
    if [ "${PRINT_LOGS}" = "true" ]; then
        echo "Anvil output:"
        cat anvil.log
    fi
    echo "Shutting down Anvil server..."
    kill $ANVIL_PID
    rm -f anvil.log
}

run_benchmark