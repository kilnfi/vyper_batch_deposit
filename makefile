benchmark:
	sh script/benchmark.sh

tests :
	forge test --ffi -vvv --via-ir
	