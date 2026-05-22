// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {B20AssetTest} from "test/lib/B20AssetTest.sol";
import {B20Constants} from "src/lib/B20Constants.sol";

contract B20AssetRoleConstantsTest is B20AssetTest {
    /// @notice Verifies OPERATOR_ROLE equals keccak256("OPERATOR_ROLE")
    /// @dev Wire-format invariant: the Rust precompile derives the same keccak; a value
    ///      drift would silently break operator role checks across implementations.
    function test_securityOperatorRole_success_matchesKeccak() public view {
        assertEq(
            security().OPERATOR_ROLE(),
            keccak256("OPERATOR_ROLE"),
            "OPERATOR_ROLE must equal keccak256(\"OPERATOR_ROLE\")"
        );
        assertEq(
            security().OPERATOR_ROLE(),
            OPERATOR_ROLE,
            "compile-time copy in B20AssetTest must match the contract value"
        );
    }

    /// @notice Verifies BURN_FROM_ROLE equals keccak256("BURN_FROM_ROLE")
    /// @dev Same wire-format invariant for the corp-actions clawback role.
    function test_burnFromRole_success_matchesKeccak() public view {
        assertEq(
            security().BURN_FROM_ROLE(),
            keccak256("BURN_FROM_ROLE"),
            "BURN_FROM_ROLE must equal keccak256(\"BURN_FROM_ROLE\")"
        );
        assertEq(security().BURN_FROM_ROLE(), BURN_FROM_ROLE, "compile-time copy in B20AssetTest must match");
        assertEq(
            security().BURN_FROM_ROLE(),
            B20Constants.BURN_FROM_ROLE,
            "B20Constants.BURN_FROM_ROLE library source-of-truth must match"
        );
    }

    /// @notice Verifies the two variant role identifiers are distinct
    /// @dev Sanity check: a collision would let a single role grant accidentally authorize both
    ///      operator and burn-from paths.
    function test_securityRoles_success_distinct() public view {
        assertTrue(
            security().OPERATOR_ROLE() != security().BURN_FROM_ROLE(),
            "operator and burn-from role identifiers must be distinct"
        );
    }
}
