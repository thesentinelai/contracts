pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract Sentinel {
    
    struct Task {
        uint taskID;
        uint currentRound;
        uint totalRounds;
        uint cost;
        string[] modelHashes;
    }
    
    uint activeTaskID = 1;
    mapping (uint => Task) public SentinelTasks;
    mapping (address => uint[]) public UserTaskIDs;
    
    event newTaskCreated(uint indexed taskID, address indexed _user, uint _amt, uint _time);
    event modelUpdated(uint indexed taskID, string _modelHash, uint _time);
    
    function createTask(string memory _modelHash, uint _rounds) public {
        require(_rounds < 10, "Number of Rounds should be less than 10");
        uint taskCost = 0;

        Task memory newTask;
        newTask = Task({
            taskID: activeTaskID,
            currentRound: 1,
            totalRounds: _rounds,
            cost: taskCost,
            modelHashes: new string[](_rounds)
        });
        newTask.modelHashes[0] = _modelHash;
        SentinelTasks[activeTaskID] = newTask;
        UserTaskIDs[msg.sender].push(activeTaskID);
        emit newTaskCreated(activeTaskID, msg.sender, taskCost, now);
        
        activeTaskID+=1;
    }
    
    function updateModelForTask(uint _taskID,  string memory _modelHash) public returns (uint) {
        
        uint newRound = SentinelTasks[_taskID].currentRound+1;
        require(newRound <= SentinelTasks[_taskID].totalRounds, "All Rounds Completed");
        
        SentinelTasks[_taskID].currentRound = newRound;
        SentinelTasks[_taskID].modelHashes[newRound] = _modelHash;
        emit modelUpdated(_taskID, _modelHash, now);
        return newRound;
    }
    
    function getTaskHashes(uint _taskID) public view returns (string[] memory) {
        return (SentinelTasks[_taskID].modelHashes);
    }
    
    function getTaskCount() public view returns (uint) {
        return activeTaskID-1;
    }
    function getTasksOfUser() public view returns (uint[]) {
        return UserTaskIDs[msg.sender];
    }
    
}