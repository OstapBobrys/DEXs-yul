object "UniswapV2Exchange" {
    code {
        codecopy(
            callvalue(), // 0x00
            dataoffset("runtime"),
            datasize("runtime")
        )

        setimmutable(
            callvalue(),
            "owner", // name
            caller() // msg.sender
        )

        return(callvalue(), datasize("runtime"))
    }
    object "runtime" {
        code {
            switch selector()
            case 0xdf791e50 /* swap(address,address,uint256) */ {
                let ptr := mload(0x40)
                let pair := calldataload(4)
                let tokenToBuy := calldataload(36)
                let amountOut := calldataload(68)

                // token0()
                mstore(ptr, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
                if iszero(staticcall(gas(), pair, ptr, 0x04, 0, 0)) {
                    mstore(0, 0x0200000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0x100, 0, returndatasize())

                // token1()
                mstore(ptr, 0xd21220a700000000000000000000000000000000000000000000000000000000)
                if iszero(staticcall(gas(), pair, ptr, 0x04, 0, 0)) {
                    mstore(0, 0x0300000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0x120, 0, returndatasize())

                switch eq(mload(0x100), tokenToBuy)
                case 0 {
                    mstore(0x140, mload(0x100))
                }
                case 1 {
                    mstore(0x140, mload(0x120))
                }

                // getReserves()
                mstore(ptr, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
                if iszero(staticcall(gas(), pair, ptr, 0x04, 0, 0)) {
                    mstore(0, 0x0400000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0x200, 0, returndatasize())

                // calculate amountIn
                let numerator := mul(mload(0x200), amountOut)
                numerator := mul(numerator, 1000)

                let denominator := sub(mload(0x220), amountOut)
                denominator := mul(denominator, 997)

                let amountIn := add(div(numerator, denominator), 1)

                // transfer()
                mstore(ptr, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x4), pair)
                mstore(add(ptr, 0x24), amountIn)
                if iszero(call(gas(), mload(0x140), 0, ptr, 0x44, 0, 0)) {
                    mstore(0, 0x0500000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }

                // swap()
                mstore(ptr, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
                switch eq(mload(0x100), tokenToBuy)
                case 0 {
                    mstore(add(ptr, 0x4), 0)
                    mstore(add(ptr, 0x24), amountOut)
                }
                case 1 {
                    mstore(add(ptr, 0x4), amountOut)
                    mstore(add(ptr, 0x24), 0)
                }
                mstore(add(ptr, 0x44), caller())
                mstore(add(ptr, 0x64), "")
                if iszero(call(gas(), pair, 0, ptr, 0x84, 0, 0)) {
                    mstore(0, 0x0600000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
            }
            case 0x49df728c /* withdrawTokens(address) */ {
                onlyOwner()

                let ptr := mload(0x40)

                // balanceOf()
                mstore(ptr, 0x70a0823100000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x4), address())
                if iszero(staticcall(gas(), calldataload(4), ptr, 0x24, 0, 0)) {
                    mstore(0, 0x0700000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0x80, 0, returndatasize())

                // transfer()
                mstore(ptr, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x4), caller())
                mstore(add(ptr, 0x24), mload(0x80))
                if iszero(call(gas(), calldataload(4), 0, ptr, 0x44, 0, 0)) {
                    mstore(0, 0x0500000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
            }
            default {
                mstore(0, 0x5200000000000000000000000000000000000000000000000000000000000000)
                revert(0, 0x1)
            }

            /* OWNABLE */
            function onlyOwner() {
                if iszero(eq(loadimmutable("owner"), caller())) {
                    mstore(0, 0x0100000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
            }

            /* HELPERS */
            function selector() -> s {
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }
        }
    }
}
