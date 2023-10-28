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
                let pair := calldataload(4)
                let tokenToBuy := calldataload(36)
                let amountOut := calldataload(68)

                // token0()
                mstore(0x40, 0x0dfe1681)
                if iszero(staticcall(gas(), pair, 0x5c, 0x04, 0, 0)) {
                    mstore(0, 0x0200000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0x80, 0, returndatasize())

                // token1()
                mstore(0x40, 0xd21220a7)
                if iszero(staticcall(gas(), pair, 0x5c, 0x04, 0, 0)) {
                    mstore(0, 0x0300000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0xa0, 0, returndatasize())

                switch eq(mload(0x80), tokenToBuy)
                case 0 {
                    mstore(0xc0, mload(0x80))
                }
                case 1 {
                    mstore(0xc0, mload(0xa0))
                }

                // getReserves()
                mstore(0x40, 0x0902f1ac)
                if iszero(staticcall(gas(), pair, 0x5c, 0x04, 0, 0)) {
                    mstore(0, 0x0400000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0xe0, 0, returndatasize())

                // calculate amountIn
                let numerator := mul(mload(0xe0), amountOut)
                numerator := mul(numerator, 1000)

                let denominator := sub(mload(0x100), amountOut)
                denominator := mul(denominator, 997)

                let amountIn := add(div(numerator, denominator), 1)

                // transfer()
                mstore(0x40, 0xa9059cbb)
                mstore(0x60, pair)
                mstore(0x80, amountIn)
                if iszero(call(gas(), mload(0xc0), 0, 0x5c, 0x44, 0, 0)) {
                    mstore(0, 0x0500000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }

                // swap()
                mstore(0x40, 0x022c0d9f)
                switch eq(mload(0x80), tokenToBuy)
                case 0 {
                    mstore(0x60, 0)
                    mstore(0x80, amountOut)
                }
                case 1 {
                    mstore(0x60, amountOut)
                    mstore(0x80, 0)
                }
                mstore(0xa0, caller())
                mstore(0xc0, "")
                if iszero(call(gas(), pair, 0, 0x5c, 0x84, 0, 0)) {
                    mstore(0, 0x0600000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
            }
            case 0x49df728c /* withdrawTokens(address) */ {
                onlyOwner()

                // balanceOf()
                mstore(0x40, 0x70a08231)
                mstore(0x60, address())
                if iszero(staticcall(gas(), calldataload(4), 0x5c, 0x24, 0, 0)) {
                    mstore(0, 0x0700000000000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x1)
                }
                returndatacopy(0x80, 0, returndatasize())

                // transfer()
                mstore(0x40, 0xa9059cbb)
                mstore(0x60, caller())
                mstore(0x80, mload(0x80))
                if iszero(call(gas(), calldataload(4), 0, 0x5c, 0x44, 0, 0)) {
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
