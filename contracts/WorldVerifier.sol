// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ByteHasher } from './helpers/ByteHasher.sol';
import { IWorldID } from './interfaces/IWorldID.sol';

/// @title This contract verifies the proof of World ID and execute certain business logic
/// @dev This contract is based on https://github.com/worldcoin/world-id-onchain-template
contract WorldVerifier {
	using ByteHasher for bytes;

    /// @notice Thrown when attempting to reuse a nullifier
	error InvalidNullifier();

    /// @dev The contract of worldId
    IWorldID internal immutable worldId;

    /// @dev The contract's external nullifier hash
	uint256 internal immutable externalNullifier;

    /// @dev The World ID group ID (always 1)
	uint256 internal constant groupId = 1;

    /// @dev Whether a nullifier hash has been used already. Used to guarantee an action is only performed once by a single person
	mapping(uint256 => bool) internal nullifierHashes;

    /// @dev Mapping of nullifier hashes and an address own by this person
    mapping(uint256 => address) internal hashToAddressMap;

    constructor(IWorldID _worldId, string memory _appId, string memory _actionId) {
        worldId = _worldId;
		externalNullifier = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _actionId).hashToField();
    }

    /// @param signal An arbitrary input from the user, usually the user's wallet address (check README for further details)
	/// @param root The root of the Merkle tree (returned by the JS widget).
	/// @param nullifierHash The nullifier hash for this proof, preventing double signaling (returned by the JS widget).
	/// @param proof The zero-knowledge proof that demonstrates the claimer is registered with World ID (returned by the JS widget).
	/// @dev Feel free to rename this method however you want! We've used `claim`, `verify` or `execute` in the past.
    function verifyEndExecute(
        address signal,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // First, we make sure this person hasn't done this before
		if (nullifierHashes[nullifierHash]) revert InvalidNullifier();

        // We now verify the provided proof is valid and the user is verified by World ID
		worldId.verifyProof(
			root,
			groupId,
			abi.encodePacked(signal).hashToField(),
			nullifierHash,
			externalNullifier,
			proof
		);

        // We now record the user has done this, so they can't do it again (proof of uniqueness)
        nullifierHashes[nullifierHash] = true;

        // Execute the business logic here
		hashToAddressMap[nullifierHash] = msg.sender;
    }
}