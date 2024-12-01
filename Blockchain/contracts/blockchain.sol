// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Blockchain {
    struct Block {
        uint256 blockNumber;
        string previousHash;
        uint256 timestamp;
        string caseID;
        string description;
        string hash; // Added hash field to store the block's hash
    }

    Block[] public chain; // Array to store the blockchain

    enum Role { NONE, BLOCK_CREATOR } // Define roles
    mapping(address => Role) public roles; // Mapping to store roles of each address

    event BlockAdded(uint256 blockNumber, string caseID, string hash);
    event RoleAssigned(address indexed account, Role role);

    modifier onlyAuthorized() {
        require(roles[msg.sender] == Role.BLOCK_CREATOR, "Not authorized to add blocks");
        _;
    }

    constructor(string memory description) {
        // Assign the contract deployer the BLOCK_CREATOR role
        roles[msg.sender] = Role.BLOCK_CREATOR;

        // Initialize the blockchain with the genesis block
        string memory genesisHash = _calculateHash(
            0,
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            block.timestamp,
            "GENESIS",
            description
        );

        chain.push(
            Block({
                blockNumber: 0,
                previousHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
                timestamp: block.timestamp,
                caseID: "GENESIS",
                description: description,
                hash: genesisHash
            })
        );

        emit BlockAdded(0, "GENESIS", genesisHash);
    }

    function addBlock(
        string memory previousHash,
        uint256 timestamp,
        string memory caseID,
        string memory description
    ) public onlyAuthorized {
        uint256 blockNumber = chain.length;

        // Validate the previous hash
        require(
            keccak256(abi.encodePacked(chain[blockNumber - 1].hash)) ==
                keccak256(abi.encodePacked(previousHash)),
            "Invalid previous hash"
        );

        // Calculate the hash for the new block
        string memory newHash = _calculateHash(
            blockNumber,
            previousHash,
            timestamp,
            caseID,
            description
        );

        chain.push(
            Block({
                blockNumber: blockNumber,
                previousHash: previousHash,
                timestamp: timestamp, // Use provided timestamp
                caseID: caseID,
                description: description,
                hash: newHash
            })
        );

        emit BlockAdded(blockNumber, caseID, newHash);
    }

    function getBlock(uint256 index) public view returns (Block memory) {
        require(index < chain.length, "Block index out of range");
        return chain[index];
    }

    function getChainLength() public view returns (uint256) {
        return chain.length;
    }

    function addRole(address account, Role role) public {
        require(msg.sender == address(this) || roles[msg.sender] == Role.BLOCK_CREATOR, "Only contract can add roles");
        roles[account] = role;
        emit RoleAssigned(account, role);
    }

    function _calculateHash(
        uint256 blockNumber,
        string memory previousHash,
        uint256 timestamp,
        string memory caseID,
        string memory description
    ) internal pure returns (string memory) {
        return
            _toHexString(
                keccak256(
                    abi.encodePacked(
                        blockNumber,
                        previousHash,
                        timestamp,
                        caseID,
                        description
                    )
                )
            );
    }

    function _toHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint8(data[i] >> 4)];
            str[1 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}
