// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Whitelist {

    event Authorized(address indexed _address);

    mapping(address => bool) public whitelist;

    modifier check() {
        require(whitelist[msg.sender] == true, "Unauthorized");
        _;
    }

    function authorize(address _address) public check {
        whitelist[_address] = true;
        emit Authorized(_address);
    } 
}