// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IB20} from "src/interfaces/IB20.sol";
import {IB20Asset} from "src/interfaces/IB20Asset.sol";

import {B20AssetTest} from "test/lib/B20AssetTest.sol";

/// @title Differential check-order tests for `updateExtraMetadata`.
///
/// @notice **Canonical order (Solidity reference):**
///         1. ROLE (`onlyRole(OPERATOR_ROLE)` modifier) → `AccessControlUnauthorizedAccount`
///         2. INVALID-IDENTIFIER-TYPE (`bytes(identifierType).length == 0`) → `InvalidIdentifierType`
///
///         C(2, 2) = 1 pair.
contract B20AssetUpdateExtraMetadataRevertOrderTest is B20AssetTest {
    /// @notice ROLE beats INVALID-IDENTIFIER-TYPE.
    /// @dev Caller lacks OPERATOR_ROLE AND the identifierType is empty.
    ///      Role modifier fires before the body's empty-type check.
    function test_updateExtraMetadata_revertOrder_role_beats_invalidIdentifierType(
        address caller,
        string calldata value
    ) public {
        _assumeValidCaller(caller);
        vm.assume(caller != admin);
        vm.assume(caller != operator);
        bytes32 role = security().OPERATOR_ROLE();

        vm.prank(caller);
        vm.expectRevert(abi.encodeWithSelector(IB20.AccessControlUnauthorizedAccount.selector, caller, role));
        security().updateExtraMetadata("", value); // empty type triggers InvalidIdentifierType
    }
}
