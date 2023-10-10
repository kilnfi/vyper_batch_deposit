```
 _    _                           ______                  _        _____                         _      
| |  | |                         (____  \       _        | |      (____ \                       (_)_    
| |  | |   _ ____   ____  ____    ____)  ) ____| |_  ____| | _     _   \ \ ____ ____   ___   ___ _| |_  
 \ \/ / | | |  _ \ / _  )/ ___)  |  __  ( / _  |  _)/ ___) || \   | |   | / _  )  _ \ / _ \ /___) |  _) 
  \  /| |_| | | | ( (/ /| |      | |__)  | ( | | |_( (___| | | |  | |__/ ( (/ /| | | | |_| |___ | | |__ 
   \/  \__  | ||_/ \____)_|      |______/ \_||_|\___)____)_| |_|  |_____/ \____) ||_/ \___/(___/|_|\___)
      (____/|_|                                                                |_|                      
```

**Optimized Batch Deposit contract using Vyper**

## Requirements

The following will need to be installed in order to use this project. Please follow the links and instructions.

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
-   [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (92f8951 2022-08-06T00:09:32.96582Z)`
    -   To get the latest of each, just run `foundryup`
-   [Vyper Compiler](https://docs.vyperlang.org/en/stable/installing-vyper.html)
    -    You'll know you've done it right if you can run `vyper --version` and get an output like: `0.3.9+commit.66b9670`

## Getting Started

```sh
forge build
forge test
```

## Deploying

Use the script corresponding to the network you want to deploy to. For example, to deploy to Goerli:

```sh
forge script script/Deploy.goerli.s.sol --ffi --rpc-url <RPC> --broadcast --private-key <PRIVATE_KEY>
```

## Deployed Contracts

### Mainnet

`0x043a4073d9e8b509E5e7D1F928b4062895B802B0`

### Goerli

`0xDB325757C99b18a591592414Cd4e3E3681856F48`

### Holesky

Coming soon

## Development

This project uses [Foundry](https://getfoundry.sh). See the [book](https://book.getfoundry.sh/getting-started/installation.html) for instructions on how to install and use Foundry.
