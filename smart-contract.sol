// SPDX-License-Identifier: Unlicense

pragma solidity >=0.6.0 <=0.8.0;

contract EUGBSChain {

    // Declare Variables

    uint256 public orgIDs;
    uint256 public greenBondsSupply;
    address public owner;

    mapping (address => uint256) public greenBondsBalance;

    mapping (address => mapping(address => uint256)) public greenBondsTransfers;

    // Declare Structures

    struct organization {
        uint256 orgUniqueID;
        address orgAddress;
        string orgName;
        bool status;
    }

    organization[] public organizationRecords;

    struct trackOfTransactions {
        address orgSender;
        address orgReceipient;
        uint256 greenBondsTransfer;
    }

    trackOfTransactions[] public trackOfTransactionsRecords;

    // Constructor

    constructor(string memory _orgName, uint256 _greenBondsSupply) public {
        orgIDs=1000;
        owner = msg.sender;
        greenBondsSupply = _greenBondsSupply;
        organization memory newOrganization = organization(orgIDs, msg.sender, _orgName, true);
        organizationRecords.push(newOrganization);
        greenBondsBalance[msg.sender] = greenBondsSupply;
        orgIDs = orgIDs + 1;
    }

    // Register an Organization

    function registerOrganization(address _orgAddress, string memory _orgName, bool _status) public {
        require(msg.sender==owner);
        organization memory newOrganization = organization(orgIDs, _orgAddress, _orgName, _status);
        organizationRecords.push(newOrganization);
        orgIDs = orgIDs + 1;
    }

    // Transfer GreenBonds

    function _transfer(address _from, address _to, uint _value) internal {
        // Check if the organization is allowed to transfer
        uint256 temp;
        for (uint256 i=0; i<=organizationRecords.length-1; i++) {
            if (_from == (organizationRecords[i].orgAddress)) {
            temp = i;
            }
        }
        require (organizationRecords[temp].status ==true);
        // Check if the organization has enough Bonds to transfer
        require(greenBondsBalance[_from] >= _value);
        // Check for overflows
        require(greenBondsBalance[_to] + _value > greenBondsBalance[_to]);
        // Subtract from the sending organization
        greenBondsBalance[_from] -= _value;
        // Add the amount to the recipient organization
        greenBondsBalance[_to] += _value;
        trackOfTransactions memory newTransfer = trackOfTransactions(_from, _to, _value);
        trackOfTransactionsRecords.push(newTransfer);
        greenBondsTransfers[_from][_to] += _value;
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    // Mint new bonds

    function mintBonds(uint256 _newBonds) public {
        require(msg.sender == owner);
        greenBondsBalance[msg.sender] += _newBonds;
    }

    // Retrieve Organization's Data based on Organization's Name

    function retrieveOrganizationBasedOnName(string memory _name) public view returns (uint256, address, string memory, bool ) {
        uint256 temp;
        for (uint256 i=0; i<=organizationRecords.length-1; i++) {
            if ((keccak256(abi.encodePacked(_name))) == (keccak256(abi.encodePacked(organizationRecords[i].orgName)))) {
            temp = i;
            }
        }
        return (organizationRecords[temp].orgUniqueID, organizationRecords[temp].orgAddress, organizationRecords[temp].orgName, organizationRecords[temp].status);
    }

    // Retrieve Organization's Data based on Organization's Address

    function retrieveOrganizationBasedOnAddress(address _orgAddress) public view returns (uint256, address, string memory, bool ) {
        uint256 temp;
        for (uint256 i=0; i<=organizationRecords.length-1; i++) {
            if (_orgAddress == organizationRecords[i].orgAddress) {
            temp = i;
            }
        }
        return (organizationRecords[temp].orgUniqueID, organizationRecords[temp].orgAddress, organizationRecords[temp].orgName, organizationRecords[temp].status);
    }

}
