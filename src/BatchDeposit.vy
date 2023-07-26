# @version ^0.3.6

# ██╗  ██╗██╗██╗     ███╗   ██╗
# ██║ ██╔╝██║██║     ████╗  ██║
# █████╔╝ ██║██║     ██╔██╗ ██║
# ██╔═██╗ ██║██║     ██║╚██╗██║
# ██║  ██╗██║███████╗██║ ╚████║
# ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═══╝

MAX_LEN: constant(uint256) = 800 # lower is more gas efficient, but less flexible
PUBLIC_KEY_LEN: constant(uint256) = 48
WITHDRAWAL_CRED_LEN: constant(uint256) = 32
SIGNATURE_LEN: constant(uint256) = 96

depositAddress: immutable(address)

@external
def __init__(depositAdd: address):
    depositAddress = depositAdd

@payable
@external
def batchDeposit(publicKeys: Bytes[MAX_LEN*PUBLIC_KEY_LEN],
                withdrawalCreds: Bytes[MAX_LEN*WITHDRAWAL_CRED_LEN],
                signatures: Bytes[MAX_LEN*SIGNATURE_LEN],
                dataRoots: DynArray[bytes32, MAX_LEN]) :
    # Check for malformed input, could be removed to save gas
    assert len(publicKeys) % PUBLIC_KEY_LEN == 0
    assert len(withdrawalCreds) % WITHDRAWAL_CRED_LEN == 0
    assert len(signatures) % SIGNATURE_LEN == 0
    l : uint256 = len(dataRoots)
    assert l == len(publicKeys) / PUBLIC_KEY_LEN
    assert l == len(withdrawalCreds) / WITHDRAWAL_CRED_LEN
    assert l == len(signatures) / SIGNATURE_LEN
    pk : uint256 = 0
    wc : uint256 = 0
    sig : uint256 = 0
    for dataRoot in dataRoots:
        raw_call(
        depositAddress,
        _abi_encode(slice(publicKeys, pk, PUBLIC_KEY_LEN),
                    slice(withdrawalCreds, wc, WITHDRAWAL_CRED_LEN),
                    slice(signatures, sig, SIGNATURE_LEN),
                    dataRoot,
                    method_id=method_id("deposit(bytes,bytes,bytes,bytes32)")),
        value= as_wei_value(32, "ether"),
        revert_on_failure=True)
        pk += PUBLIC_KEY_LEN
        wc += WITHDRAWAL_CRED_LEN
        sig += SIGNATURE_LEN
