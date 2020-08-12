/*
   _____            _   _            _            _____ 
  / ____|          | | (_)          | |     /\   |_   _|
 | (___   ___ _ __ | |_ _ _ __   ___| |    /  \    | |  
  \___ \ / _ \ '_ \| __| | '_ \ / _ \ |   / /\ \   | |  
  ____) |  __/ | | | |_| | | | |  __/ |_ / ____ \ _| |_ 
 |_____/ \___|_| |_|\__|_|_| |_|\___|_(_)_/    \_\_____|
                                                        
*/                                                      

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Sentinel {

    using SafeMath for uint256;

    struct Task {
        uint256 taskID;
        uint256 currentRound;
        uint256 totalRounds;
        uint256 cost;
        string[] modelHashes;
    }
    
    address public owner;
    address public coordinatorAddress = 0xBeb71662FF9c08aFeF3866f85A6591D4aeBE6e4E;

    uint256 nextTaskID = 1;
    mapping (uint256 => Task) public SentinelTasks;
    mapping (address => uint256[]) public UserTaskIDs;
    mapping (address => string[]) public UserFiles;

    event newTaskCreated(uint256 indexed taskID, address indexed _user, string _modelHash, uint256 _amt, uint256 _time);
    event modelUpdated(uint256 indexed taskID, string _modelHash, uint256 _time);
    event fileAdded(address indexed _user, string _fileHash, uint256 _time);

    modifier onlyOwner () {
      require(msg.sender == owner);
      _;
    }
    modifier onlyCoordinator () {
      require(msg.sender == coordinatorAddress);
      _;
    }
    
     constructor(address _coordinatorAddress) {
        owner = msg.sender;
        coordinatorAddress = _coordinatorAddress;
    }
    
    function updateCoordinator(address _coordinatorAddress) 
        public onlyOwner
    {
        coordinatorAddress = _coordinatorAddress;
    }

    function createTask(string memory _modelHash, uint256 _rounds) 
        public payable 
    {
        require(_rounds < 10, "Number of Rounds should be less than 10");
        uint256 taskCost = msg.value;

        Task memory newTask;
        newTask = Task({
            taskID: nextTaskID,
            currentRound: 1,
            totalRounds: _rounds,
            cost: taskCost,
            modelHashes: new string[](_rounds)
        });
        newTask.modelHashes[0] = _modelHash;
        SentinelTasks[nextTaskID] = newTask;
        UserTaskIDs[msg.sender].push(nextTaskID);
        emit newTaskCreated(nextTaskID, msg.sender, _modelHash, taskCost, block.timestamp);

        nextTaskID = nextTaskID.add(1);
    }

    function updateModelForTask(uint256 _taskID,  string memory _modelHash, address payable computer) 
        public onlyCoordinator
    {
        require(_taskID <= nextTaskID, "Invalid Task ID");
        uint256 newRound = SentinelTasks[_taskID].currentRound.add(1);
        require(newRound <= SentinelTasks[_taskID].totalRounds, "All Rounds Completed");
        

        SentinelTasks[_taskID].currentRound = newRound;
        SentinelTasks[_taskID].modelHashes[newRound.sub(1)] = _modelHash;
        computer.transfer(SentinelTasks[_taskID].cost.div(SentinelTasks[_taskID].totalRounds));
        emit modelUpdated(_taskID, _modelHash, block.timestamp);

    }

    function getTaskHashes(uint256 _taskID) public view returns (string[] memory) {
        return (SentinelTasks[_taskID].modelHashes);
    }

    function getTaskCount() public view returns (uint256) {
        return nextTaskID.sub(1);
    }
    function getTasksOfUser() public view returns (uint256[] memory) {
        return UserTaskIDs[msg.sender];
    }

    function storeFile(string memory _fileHash) public {
        UserFiles[msg.sender].push(_fileHash);
        emit fileAdded(msg.sender, _fileHash, block.timestamp);
    }

    function getFiles() public view returns (string[] memory){
        return UserFiles[msg.sender];
    }

}
