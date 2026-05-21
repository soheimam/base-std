// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {B20AssetTest} from "test/lib/B20AssetTest.sol";

contract B20AssetPolicyTypeConstantsTest is B20AssetTest {
    /// @notice Verifies REDEEM_SENDER_POLICY equals keccak256("REDEEM_SENDER_POLICY")
    /// @dev Wire-format invariant: identifies the policy slot the redeem path consults
    ///      against msg.sender; a value drift would silently misroute the policy lookup.
    function test_redeemSenderPolicy_success_matchesKeccak() public view {
        assertEq(
            security().REDEEM_SENDER_POLICY(),
            keccak256("REDEEM_SENDER_POLICY"),
            "REDEEM_SENDER_POLICY must equal keccak256(\"REDEEM_SENDER_POLICY\")"
        );
        assertEq(
            security().REDEEM_SENDER_POLICY(),
            REDEEM_SENDER_POLICY,
            "compile-time copy in B20AssetTest must match the contract value"
        );
    }
}
