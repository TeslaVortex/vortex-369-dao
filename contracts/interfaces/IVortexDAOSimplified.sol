// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IVortexDAOSimplified - Interface for VortexDAOSimplified Contract
interface IVortexDAOSimplified {
    enum Phase {
        Silence,
        Proposal,
        Mirror,
        Vortex,
        Resolution,
        Fractal,
        Breath,
        Witness,
        Return,
        Manifestation
    }

    struct Action {
        bytes32 hash;
        Phase phase;
        uint256 resonance;
        bytes32 vectorHash;
        uint256 timestamp;
        bool executed;
        bool cancelled;
    }

    event ActionSubmitted(bytes32 indexed actionHash, uint256 resonance);
    event PhaseAdvanced(bytes32 indexed actionHash, Phase newPhase, string witness);
    event ActionExecuted(bytes32 indexed actionHash, uint256 value);
    event ActionCancelled(bytes32 indexed actionHash, Phase cancelPhase);
    event FeesDistributed(uint256 daoAmount, uint256 burnAmount);

    function submitAction(bytes32 actionHash, uint256 resonance, bytes32 vectorHash) external;
    function advancePhase(bytes32 actionHash, string calldata witness) external;
    function executeAction(bytes32 actionHash) external payable;
    function getAction(bytes32 actionHash) external view returns (
        Phase phase,
        uint256 resonance,
        bytes32 vectorHash,
        uint256 timestamp,
        bool executed,
        bool cancelled
    );
    function canManifest(bytes32 actionHash) external view returns (bool);
    function withdrawTreasury(address to, uint256 amount) external;
}
