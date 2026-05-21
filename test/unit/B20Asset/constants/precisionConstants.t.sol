// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {B20AssetTest} from "test/lib/B20AssetTest.sol";

contract B20AssetPrecisionConstantsTest is B20AssetTest {
    /// @notice Verifies WAD_PRECISION equals 1e18
    /// @dev DeFi convention check: `toShares` and `sharesOf` divide by this after multiplying
    ///      by the stored ratio; any drift silently rescales every holder's share count.
    function test_wadPrecision_success_equalsOneWad() public view {
        assertEq(security().WAD_PRECISION(), 1e18, "WAD_PRECISION must equal 1e18");
    }
}
