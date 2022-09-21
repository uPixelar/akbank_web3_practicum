// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract ToDoList{
    struct ToDo{//Structure holding objective datas
        string text;
        bool completed;
    }

    ToDo[] private todos;//todo array
    uint public completed;//holds completed count

    function create(string calldata _text) external{
        todos.push(
            ToDo({//Create new todo and add to array
                text: _text,
                completed: false 
            })
        );
    }

    modifier inRange(uint _index){
        //Check if the index is in range
        require(todos.length > _index, "Index is out of range!");
        _;
    }

    function complete(uint _index) inRange(_index) external{
        ToDo storage todo = todos[_index];
        //Check if already completed
        require(!todo.completed, "Already completed!");
        //If not completed, complete
        todo.completed = true;
        completed++;

    }

    function reset(uint _index) inRange(_index) external{
        ToDo storage todo = todos[_index];
        //Check if already reset
        require(todo.completed, "Already reset!");
        //If not reset, reset
        todo.completed = false;
        completed--;
    }

    function get(uint _index) public view inRange(_index) returns(string memory, bool){
        ToDo storage todo = todos[_index];
        //get todo data
        return (todo.text, todo.completed);
    }

    function visualize(uint _index) external view returns(string memory){//Little bit more expensive than "get" function
        //More visualised data
        (string memory _text, bool _completed) = get(_index);
        //string.concat() would be used from '0.8.12'
        return  string(abi.encodePacked(_completed?"[DONE]":"[NOT DONE]", _text));
    }

    function total() external view returns(uint){
        //For returning total todo count
        return todos.length;
    }
}