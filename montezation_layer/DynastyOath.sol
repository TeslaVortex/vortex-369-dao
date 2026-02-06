// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DynastyOath - Eternal Soul Bound Token
 * @dev Soul Bound Token (SBT) contract for eternal manifestation records
 *
 * ∞ En Eeke Mai Ea ∞ - Argead Kingdom Manifested
 * 66 Code Supreme - Eternal Flame Burns
 *
 * Features:
 * - Soul Bound Tokens (non-transferable)
 * - Eternal manifestation record storage
 * - Dynasty vessel binding
 * - Collective manifestation logging
 * - Immutable on-chain records
 */

contract DynastyOath {
    // ========================================
    // STATE VARIABLES
    // ========================================

    string public constant name = "DynastyOath";
    string public constant symbol = "DYNASTY";
    string public constant kingdom = "Argead Dynasty Manifested";

    // Eternal flame constants
    uint256 public constant ETERNAL_FLAME = 66;
    uint256 public constant KINGDOM_CODE = 369;
    uint256 public constant SUPREME_RESONANCE = 999;

    // Soul bound token storage
    mapping(address => SoulRecord) public soulRecords;
    mapping(uint256 => ManifestationRecord) public manifestationRecords;

    // Dynasty vessel registry
    mapping(address => DynastyVessel) public dynastyVessels;

    // Eternal counters
    uint256 public totalSoulsBound;
    uint256 public totalManifestations;
    uint256 public collectiveAmplification;

    // ========================================
    // DATA STRUCTURES
    // ========================================

    struct SoulRecord {
        address soulAddress;
        uint256 bindingTimestamp;
        uint256 manifestationCount;
        uint256 collectivePower;
        string ensDomain;
        string quantumSignature;
        bool isBound;
        bool eternalFlame;
    }

    struct ManifestationRecord {
        uint256 id;
        address soulAddress;
        string manifestationType;
        uint256 probabilityShift;
        uint256 warpStrength;
        uint256 validationScore;
        string validationSeal;
        uint256 timestamp;
        bytes32 quantumHash;
    }

    struct DynastyVessel {
        address vesselAddress;
        string vesselName;
        string ensDomain;
        uint256 bloodlinePurity;
        uint256 connectionStrength;
        uint256 vesselPower;
        bool isActive;
        uint256 lastSync;
    }

    // ========================================
    // EVENTS
    // ========================================

    event SoulBound(
        address indexed soulAddress,
        string ensDomain,
        uint256 bindingTimestamp,
        string quantumSignature
    );

    event ManifestationRecorded(
        uint256 indexed manifestationId,
        address indexed soulAddress,
        string manifestationType,
        uint256 probabilityShift,
        uint256 warpStrength,
        string validationSeal
    );

    event DynastyVesselRegistered(
        address indexed vesselAddress,
        string vesselName,
        string ensDomain,
        uint256 bloodlinePurity
    );

    event CollectiveAmplification(
        uint256 indexed manifestationId,
        uint256 amplificationFactor,
        uint256 vesselCount,
        uint256 collectivePower
    );

    // ========================================
    // MODIFIERS
    // ========================================

    modifier onlySoulOwner(address soulAddress) {
        require(
            msg.sender == soulAddress || soulRecords[soulAddress].isBound,
            "DynastyOath: Only soul owner can perform this action"
        );
        _;
    }

    modifier validManifestation(string memory manifestationType) {
        require(
            bytes(manifestationType).length > 0,
            "DynastyOath: Invalid manifestation type"
        );
        _;
    }

    // ========================================
    // EXTERNAL FUNCTIONS
    // ========================================

    /**
     * @dev Bind a soul to eternal manifestation records
     * @param ensDomain ENS domain for the soul
     * @param quantumSignature Quantum signature verification
     */
    function bindSoul(
        string memory ensDomain,
        string memory quantumSignature
    ) external {
        require(!soulRecords[msg.sender].isBound, "DynastyOath: Soul already bound");
        require(bytes(ensDomain).length > 0, "DynastyOath: Invalid ENS domain");

        SoulRecord memory newSoul = SoulRecord({
            soulAddress: msg.sender,
            bindingTimestamp: block.timestamp,
            manifestationCount: 0,
            collectivePower: 0,
            ensDomain: ensDomain,
            quantumSignature: quantumSignature,
            isBound: true,
            eternalFlame: true
        });

        soulRecords[msg.sender] = newSoul;
        totalSoulsBound++;

        emit SoulBound(msg.sender, ensDomain, block.timestamp, quantumSignature);
    }

    /**
     * @dev Record eternal manifestation
     * @param manifestationType Type of manifestation
     * @param probabilityShift Probability shift achieved
     * @param warpStrength Reality warp strength
     * @param validationScore Validation score
     * @param validationSeal Validation seal
     */
    function recordManifestation(
        string memory manifestationType,
        uint256 probabilityShift,
        uint256 warpStrength,
        uint256 validationScore,
        string memory validationSeal
    ) external validManifestation(manifestationType) {
        require(soulRecords[msg.sender].isBound, "DynastyOath: Soul not bound");

        totalManifestations++;
        uint256 manifestationId = totalManifestations;

        // Generate quantum hash
        bytes32 quantumHash = keccak256(
            abi.encodePacked(
                msg.sender,
                manifestationType,
                probabilityShift,
                warpStrength,
                block.timestamp,
                KINGDOM_CODE
            )
        );

        ManifestationRecord memory record = ManifestationRecord({
            id: manifestationId,
            soulAddress: msg.sender,
            manifestationType: manifestationType,
            probabilityShift: probabilityShift,
            warpStrength: warpStrength,
            validationScore: validationScore,
            validationSeal: validationSeal,
            timestamp: block.timestamp,
            quantumHash: quantumHash
        });

        manifestationRecords[manifestationId] = record;

        // Update soul record
        soulRecords[msg.sender].manifestationCount++;
        soulRecords[msg.sender].collectivePower += validationScore;

        emit ManifestationRecorded(
            manifestationId,
            msg.sender,
            manifestationType,
            probabilityShift,
            warpStrength,
            validationSeal
        );
    }

    /**
     * @dev Register dynasty vessel
     * @param vesselName Name of the dynasty vessel
     * @param ensDomain ENS domain for the vessel
     * @param bloodlinePurity Bloodline purity score (0-1000)
     */
    function registerDynastyVessel(
        string memory vesselName,
        string memory ensDomain,
        uint256 bloodlinePurity
    ) external {
        require(bloodlinePurity <= 1000, "DynastyOath: Invalid bloodline purity");

        DynastyVessel memory vessel = DynastyVessel({
            vesselAddress: msg.sender,
            vesselName: vesselName,
            ensDomain: ensDomain,
            bloodlinePurity: bloodlinePurity,
            connectionStrength: 900 + (bloodlinePurity / 10), // Base 90% + purity bonus
            vesselPower: bloodlinePurity * ETERNAL_FLAME,
            isActive: true,
            lastSync: block.timestamp
        });

        dynastyVessels[msg.sender] = vessel;

        emit DynastyVesselRegistered(msg.sender, vesselName, ensDomain, bloodlinePurity);
    }

    /**
     * @dev Record collective manifestation with dynasty amplification
     * @param vesselAddresses Array of dynasty vessel addresses
     * @param manifestationType Type of collective manifestation
     * @param baseProbabilityShift Base probability shift
     * @param baseWarpStrength Base warp strength
     */
    function recordCollectiveManifestation(
        address[] memory vesselAddresses,
        string memory manifestationType,
        uint256 baseProbabilityShift,
        uint256 baseWarpStrength
    ) external validManifestation(manifestationType) {
        require(soulRecords[msg.sender].isBound, "DynastyOath: Soul not bound");
        require(vesselAddresses.length > 0, "DynastyOath: No vessels provided");

        // Calculate collective amplification
        uint256 amplificationFactor = 100; // Base 1.0
        uint256 validVessels = 0;

        for (uint256 i = 0; i < vesselAddresses.length; i++) {
            DynastyVessel memory vessel = dynastyVessels[vesselAddresses[i]];
            if (vessel.isActive && vessel.bloodlinePurity > 0) {
                amplificationFactor += vessel.bloodlinePurity / 10;
                validVessels++;
            }
        }

        require(validVessels > 0, "DynastyOath: No valid dynasty vessels");

        // Apply amplification
        uint256 amplifiedProbabilityShift = (baseProbabilityShift * amplificationFactor) / 100;
        uint256 amplifiedWarpStrength = (baseWarpStrength * amplificationFactor) / 100;

        // Record manifestation
        recordManifestation(
            string(abi.encodePacked("COLLECTIVE_", manifestationType)),
            amplifiedProbabilityShift,
            amplifiedWarpStrength,
            900 + (amplificationFactor / 10), // High validation score
            "COLLECTIVE_DYNASTY_SEAL_VERIFIED"
        );

        // Update collective amplification counter
        collectiveAmplification += amplificationFactor;

        emit CollectiveAmplification(
            totalManifestations,
            amplificationFactor,
            validVessels,
            collectiveAmplification
        );
    }

    /**
     * @dev Sync dynasty vessel (update connection strength)
     */
    function syncDynastyVessel() external {
        DynastyVessel storage vessel = dynastyVessels[msg.sender];
        require(vessel.isActive, "DynastyOath: Vessel not registered");

        // Strengthen connection through sync
        uint256 strengthBoost = 50; // 5% boost per sync
        vessel.connectionStrength = vessel.connectionStrength + strengthBoost > 1000 ?
                                   1000 : vessel.connectionStrength + strengthBoost;
        vessel.lastSync = block.timestamp;
    }

    // ========================================
    // VIEW FUNCTIONS
    // ========================================

    /**
     * @dev Get soul record details
     * @param soulAddress Address of the soul
     */
    function getSoulRecord(address soulAddress)
        external
        view
        returns (
            address soulAddr,
            uint256 bindingTimestamp,
            uint256 manifestationCount,
            uint256 collectivePower,
            string memory ensDomain,
            string memory quantumSignature,
            bool isBound,
            bool eternalFlame
        )
    {
        SoulRecord memory soul = soulRecords[soulAddress];
        return (
            soul.soulAddress,
            soul.bindingTimestamp,
            soul.manifestationCount,
            soul.collectivePower,
            soul.ensDomain,
            soul.quantumSignature,
            soul.isBound,
            soul.eternalFlame
        );
    }

    /**
     * @dev Get manifestation record details
     * @param manifestationId ID of the manifestation
     */
    function getManifestationRecord(uint256 manifestationId)
        external
        view
        returns (
            uint256 id,
            address soulAddress,
            string memory manifestationType,
            uint256 probabilityShift,
            uint256 warpStrength,
            uint256 validationScore,
            string memory validationSeal,
            uint256 timestamp,
            bytes32 quantumHash
        )
    {
        ManifestationRecord memory record = manifestationRecords[manifestationId];
        return (
            record.id,
            record.soulAddress,
            record.manifestationType,
            record.probabilityShift,
            record.warpStrength,
            record.validationScore,
            record.validationSeal,
            record.timestamp,
            record.quantumHash
        );
    }

    /**
     * @dev Get dynasty vessel details
     * @param vesselAddress Address of the vessel
     */
    function getDynastyVessel(address vesselAddress)
        external
        view
        returns (
            address vesselAddr,
            string memory vesselName,
            string memory ensDomain,
            uint256 bloodlinePurity,
            uint256 connectionStrength,
            uint256 vesselPower,
            bool isActive,
            uint256 lastSync
        )
    {
        DynastyVessel memory vessel = dynastyVessels[vesselAddress];
        return (
            vessel.vesselAddress,
            vessel.vesselName,
            vessel.ensDomain,
            vessel.bloodlinePurity,
            vessel.connectionStrength,
            vessel.vesselPower,
            vessel.isActive,
            vessel.lastSync
        );
    }

    /**
     * @dev Get kingdom statistics
     */
    function getKingdomStats()
        external
        view
        returns (
            uint256 soulsBound,
            uint256 totalManifestations_,
            uint256 collectiveAmplification_,
            uint256 eternalFlame,
            uint256 kingdomCode,
            string memory kingdomName
        )
    {
        return (
            totalSoulsBound,
            totalManifestations,
            collectiveAmplification,
            ETERNAL_FLAME,
            KINGDOM_CODE,
            kingdom
        );
    }

    /**
     * @dev Verify quantum signature
     * @param soulAddress Address of the soul
     * @param signature Signature to verify
     */
    function verifyQuantumSignature(address soulAddress, string memory signature)
        external
        view
        returns (bool)
    {
        SoulRecord memory soul = soulRecords[soulAddress];
        return soul.isBound &&
               keccak256(abi.encodePacked(soul.quantumSignature)) ==
               keccak256(abi.encodePacked(signature));
    }

    // ========================================
    // INTERNAL FUNCTIONS
    // ========================================

    /**
     * @dev Generate quantum hash for manifestation
     */
    function _generateQuantumHash(
        address soulAddress,
        string memory manifestationType,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            soulAddress,
            manifestationType,
            timestamp,
            KINGDOM_CODE,
            ETERNAL_FLAME
        ));
    }
}
