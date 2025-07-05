// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { FakeUSDC } from "./FUSDC.sol";
import { FakeWETH } from "./FWETH.sol";
import { Test } from "forge-std/Test.sol";

// Test for FakeUSDC and FakeWETH contracts
contract FakeTokensTest is Test {
    FakeUSDC fusdc;
    FakeWETH fweth;
    
    address recipient = address(0x123);
    address owner = address(0x456);
    address user1 = address(0x789);
    address user2 = address(0xabc);
    
    function setUp() public {
        fusdc = new FakeUSDC(recipient, owner);
        fweth = new FakeWETH(recipient, owner);
    }
    
    // Test FUSDC deployment and initial state
    function test_FUSDCDeployment() public view {
        require(fusdc.totalSupply() == 10000000 * 10 ** fusdc.decimals(), "Initial supply should be 10M");
        require(fusdc.balanceOf(recipient) == 10000000 * 10 ** fusdc.decimals(), "Recipient should have initial supply");
        require(fusdc.owner() == owner, "Owner should be set correctly");
        require(keccak256(abi.encodePacked(fusdc.name())) == keccak256(abi.encodePacked("FakeUSDC")), "Name should be FakeUSDC");
        require(keccak256(abi.encodePacked(fusdc.symbol())) == keccak256(abi.encodePacked("FUSDC")), "Symbol should be FUSDC");
    }
    
    // Test FWETH deployment and initial state
    function test_FWETHDeployment() public view {
        require(fweth.totalSupply() == 10000000 * 10 ** fweth.decimals(), "Initial supply should be 10M");
        require(fweth.balanceOf(recipient) == 10000000 * 10 ** fweth.decimals(), "Recipient should have initial supply");
        require(fweth.owner() == owner, "Owner should be set correctly");
        require(keccak256(abi.encodePacked(fweth.name())) == keccak256(abi.encodePacked("FakeWETH")), "Name should be FakeWETH");
        require(keccak256(abi.encodePacked(fweth.symbol())) == keccak256(abi.encodePacked("FWETH")), "Symbol should be FWETH");
    }
    
    // Test FUSDC minting
    function test_FUSDCMinting() public {
        uint256 initialSupply = fusdc.totalSupply();
        uint256 initialBalance = fusdc.balanceOf(user1);
        
        vm.prank(user1);
        fusdc.mint();
        
        require(fusdc.balanceOf(user1) == initialBalance + 1000000 * 10 ** fusdc.decimals(), "User should receive 1M tokens");
        require(fusdc.totalSupply() == initialSupply + 1000000 * 10 ** fusdc.decimals(), "Total supply should increase");
    }
    
    // Test FWETH minting
    function test_FWETHMinting() public {
        uint256 initialSupply = fweth.totalSupply();
        uint256 initialBalance = fweth.balanceOf(user1);
        
        vm.prank(user1);
        fweth.mint();
        
        require(fweth.balanceOf(user1) == initialBalance + 1000000 * 10 ** fweth.decimals(), "User should receive 1M tokens");
        require(fweth.totalSupply() == initialSupply + 1000000 * 10 ** fweth.decimals(), "Total supply should increase");
    }
    
    // Test FUSDC transfers
    function test_FUSDCTransfer() public {
        vm.prank(user1);
        fusdc.mint();
        
        uint256 transferAmount = 500000 * 10 ** fusdc.decimals();
        uint256 user1InitialBalance = fusdc.balanceOf(user1);
        uint256 user2InitialBalance = fusdc.balanceOf(user2);
        
        vm.prank(user1);
        fusdc.transfer(user2, transferAmount);
        
        require(fusdc.balanceOf(user1) == user1InitialBalance - transferAmount, "Sender balance should decrease");
        require(fusdc.balanceOf(user2) == user2InitialBalance + transferAmount, "Receiver balance should increase");
    }
    
    // Test FWETH transfers
    function test_FWETHTransfer() public {
        vm.prank(user1);
        fweth.mint();
        
        uint256 transferAmount = 500000 * 10 ** fweth.decimals();
        uint256 user1InitialBalance = fweth.balanceOf(user1);
        uint256 user2InitialBalance = fweth.balanceOf(user2);
        
        vm.prank(user1);
        fweth.transfer(user2, transferAmount);
        
        require(fweth.balanceOf(user1) == user1InitialBalance - transferAmount, "Sender balance should decrease");
        require(fweth.balanceOf(user2) == user2InitialBalance + transferAmount, "Receiver balance should increase");
    }
    
    // Test transfer with insufficient balance
    function test_TransferInsufficientBalance() public {
        uint256 transferAmount = 1000000 * 10 ** fusdc.decimals();
        
        vm.expectRevert();
        vm.prank(user1);
        fusdc.transfer(user2, transferAmount);
    }
    
    // Fuzz test for minting multiple times
    function testFuzz_MultipleMints(uint8 mintCount) public {
        vm.assume(mintCount > 0 && mintCount <= 10); // Limit to prevent gas issues
        
        uint256 initialSupply = fusdc.totalSupply();
        
        for (uint8 i = 0; i < mintCount; i++) {
            vm.prank(user1);
            fusdc.mint();
        }
        
        uint256 expectedIncrease = uint256(mintCount) * 1000000 * 10 ** fusdc.decimals();
        require(fusdc.totalSupply() == initialSupply + expectedIncrease, "Total supply should increase by expected amount");
        require(fusdc.balanceOf(user1) == expectedIncrease, "User balance should equal minted amount");
    }
}