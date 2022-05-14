// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpidermanDAOToken is ERC20("Spiderman DAO", "SpiderDAO"),Ownable {
    /**
     * Network: Mumbai Testnet
     * Aggregator: MATIC / USD
     * Address: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
     */
    AggregatorV3Interface internal priceFeed =
        AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);

    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // return price / 100000000; // 1
        // return price / 1000000; // 137 , go for this one
        return price / 1000000;
    }

    // Get the price of MATIC in USD

    // uint256 public EXCHANGE_RATE = uint256(getLatestPrice());
    uint256 public EXCHANGE_RATE = uint(getLatestPrice());
    uint256 public deployedTime = block.timestamp;

    // Function: Buy $SpiderDAO (mint) token in exchange for $MATIC
    function buy(uint256 _amount) public payable {
        // require(_amount >= 1, "Matic should be equal or greater than 1");
        require(msg.value >= _amount, "SEND SUFFICIENT MATIC");
        // Step 1: Retrieve the amount of $matic deposited
        uint256 MaticAmount = msg.value;
        // Step 2: Calculate the amount of $SpiderDAO token to mint
        // spiderDAOAmount = 10 * 1.3706 (current price of matic)
        uint256 SpiderDAOamount = MaticAmount * EXCHANGE_RATE;

        // Step 3: Mint $SpiderDAO to the caller address
        address sender = msg.sender;
        _mint(sender, SpiderDAOamount);
    }

    // function 2: Redeem $SpiderDAO (burn) and get $MATIC back
    function redeem(uint256 _SpiderDAOToRedeem) public {
        // step 1: Check that the user has enough $SpiderDAO balance
        require(block.timestamp < (deployedTime + 10 days), "REFUND_GUARANTEE_EXPIRED");
        require(balanceOf(msg.sender) >= _SpiderDAOToRedeem,"INSUFFICIENT BALANCE");

        // step 2: Calculate the amount of $MATIC to get back from burning $SpiderDAO
        // MaticAmount = 10 / 1.3706 (current price of matic)
        uint256 MaticAmount = _SpiderDAOToRedeem / EXCHANGE_RATE;

        require(address(this).balance >= MaticAmount, "NOT ENOUGH MATIC");

        // step 3: Burn the $SpiderDAO token
        _burn(msg.sender, _SpiderDAOToRedeem);

        // step 4: Transfer $MATIC to the user
        payable(msg.sender).transfer(MaticAmount);
    }
    
    function getMaticBalance() public view returns(uint256){
        return address(this).balance;
    }

    function withdraw() external onlyOwner  {
        require(block.timestamp > (deployedTime + 10 days), "REFUND_GUARANTEE_RUNNING");
          uint256 amount = address(this).balance;
          (bool sent, ) =  owner().call{value: amount}("");
          require(sent, "Failed to send Ether");
    }
}
