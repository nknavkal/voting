pragma solidity ^0.4.15;

contract Patient {

  address public owner;

  struct AccessData {
    address requester;
    uint timestamp;
  }

  struct UpdateData {
    address updater;
    uint timestamp;
    string jsonHash;
    string ipfs2Hash;
  }

  struct User {
    /*string transformed; // hash that allows to store and retrieve data*/
    AccessData[] dataAccesses;
    UpdateData[] dataUpdates;
    uint numberOfUpdates;
    uint numberOfAccesses;
  }

  mapping (string => address) private indexToAddr; // index fingerprint to user
  mapping (address => string) private patientToFunc;
  mapping (address => User) public users;

  event patientCreated();
  event dataUpdated(address patient);
  event dataAccessed(address requester, address patient);
  event contractInitialized();

  modifier ownlerOnly() {
    require(msg.sender == owner);
    _;
  }

//constructor
  function Patient() public {
    owner = msg.sender; // patient owner of the contract ?
    contractInitialized();
  }

  function userExists(string indexPrint) constant public returns (bool) {
    if (indexToAddr[indexPrint] == address(0)) return false;
    else return true;
  }

  function createPatient(address _addr, string _indexFingerprint, string _func) public {
    indexToAddr[_indexFingerprint] = _addr;
    patientToFunc[_addr] = _func;
    users[_addr].numberOfUpdates = 0;
    users[_addr].numberOfAccesses = 0;
    patientCreated();
  }

  function accessData(address _requester, string _indexFingerprint) constant public returns (string) {
    uint time = now;
    address patientAddr = indexToAddr[_indexFingerprint];
    users[patientAddr].dataAccesses[users[patientAddr].numberOfAccesses + 1] = AccessData({
      requester: _requester,
      timestamp: time
      });
    dataAccessed(_requester, patientAddr);
    string storage func = patientToFunc[patientAddr];
    return func;
  }

  function updateData(address _patientAdrr, string _ipfshashHash, string _jsonHash) ownlerOnly() public {
    uint time = now;
    users[_patientAdrr].dataUpdates[users[_patientAdrr].numberOfUpdates + 1] = UpdateData({
      updater: _patientAdrr,
      timestamp: time,
      jsonHash: _jsonHash,
      ipfs2Hash: _ipfshashHash});
    dataUpdated(_patientAdrr);
  }
}
