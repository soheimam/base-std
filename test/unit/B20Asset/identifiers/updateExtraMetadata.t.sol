// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {B20AssetTest} from "test/lib/B20AssetTest.sol";

import {IB20} from "src/interfaces/IB20.sol";
import {IB20Asset} from "src/interfaces/IB20Asset.sol";

contract B20AssetUpdateExtraMetadataTest is B20AssetTest {
    /// @notice Verifies updateExtraMetadata reverts when caller lacks OPERATOR_ROLE
    /// @dev Access control: gated on OPERATOR_ROLE. Checks
    ///      AccessControlUnauthorizedAccount with the operator role in the revert.
    function test_updateExtraMetadata_revert_unauthorized(address caller, string calldata value) public {
        _assumeValidCaller(caller);
        vm.assume(caller != admin);
        vm.assume(caller != operator);

        vm.prank(caller);
        vm.expectRevert(
            abi.encodeWithSelector(IB20.AccessControlUnauthorizedAccount.selector, caller, OPERATOR_ROLE)
        );
        security().updateExtraMetadata(IDENTIFIER_CUSIP, value);
    }

    /// @notice Verifies updateExtraMetadata reverts when identifierType is empty
    /// @dev Per IB20Asset: the category name is always required; pass empty `value` to
    ///      remove an entry instead. Checks the InvalidIdentifierType selector.
    function test_updateExtraMetadata_revert_emptyIdentifierType(string calldata value) public {
        _grantOperator();
        vm.prank(operator);
        vm.expectRevert(IB20Asset.InvalidIdentifierType.selector);
        security().updateExtraMetadata("", value);
    }

    /// @notice Verifies updateExtraMetadata writes the value through the getter
    /// @dev Round-trip on a fresh identifier; the getter must return the written value.
    function test_updateExtraMetadata_success_writesValue(string calldata value) public {
        vm.assume(bytes(value).length > 0);
        _grantOperator();
        vm.prank(operator);
        security().updateExtraMetadata(IDENTIFIER_CUSIP, value);
        assertEq(security().securityIdentifier(IDENTIFIER_CUSIP), value, "getter must reflect the write");
    }

    /// @notice Verifies an empty value removes the entry (subsequent read returns empty string)
    /// @dev The "remove" path is explicitly part of the API: empty `value` removes the entry.
    function test_updateExtraMetadata_success_emptyValueRemoves(string calldata value) public {
        vm.assume(bytes(value).length > 0);
        _grantOperator();
        vm.prank(operator);
        security().updateExtraMetadata(IDENTIFIER_CUSIP, value);
        assertEq(security().securityIdentifier(IDENTIFIER_CUSIP), value, "test setup: identifier must be set");

        vm.prank(operator);
        security().updateExtraMetadata(IDENTIFIER_CUSIP, "");
        assertEq(security().securityIdentifier(IDENTIFIER_CUSIP), "", "empty value must remove the entry");
    }

    /// @notice Verifies a subsequent write overwrites the previous value
    /// @dev Mutability: the latest write wins; prior value is fully discarded.
    function test_updateExtraMetadata_success_overwrites(string calldata first, string calldata second) public {
        vm.assume(bytes(first).length > 0);
        vm.assume(bytes(second).length > 0);
        vm.assume(keccak256(bytes(first)) != keccak256(bytes(second)));

        _grantOperator();
        vm.prank(operator);
        security().updateExtraMetadata(IDENTIFIER_CUSIP, first);
        vm.prank(operator);
        security().updateExtraMetadata(IDENTIFIER_CUSIP, second);
        assertEq(security().securityIdentifier(IDENTIFIER_CUSIP), second, "overwrite must replace prior value");
    }

    /// @notice Verifies updateExtraMetadata emits ExtraMetadataUpdated(identifierType, value)
    /// @dev Event integrity for the rotation; subscribers depend on this event for off-chain
    ///      identifier-state replication.
    function test_updateExtraMetadata_success_emitsEvent(string calldata value) public {
        vm.assume(bytes(value).length > 0);
        _grantOperator();
        vm.expectEmit(false, false, false, true, address(token));
        emit IB20Asset.ExtraMetadataUpdated(IDENTIFIER_CUSIP, value);
        vm.prank(operator);
        security().updateExtraMetadata(IDENTIFIER_CUSIP, value);
    }
}
