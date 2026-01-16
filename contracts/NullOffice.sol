// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NullOffice
 * @notice The Null Office - Where 91% of protocol fees are burned
 * @dev Simple contract that receives and holds burned funds
 * 
 * Address: 0x0000000000000000000000000000000000000369
 * 
 * The Null Office is the ultimate destination for 91% of all protocol fees.
 * Funds sent here are effectively burned, creating deflationary pressure.
 * 
 * 3 · 6 · 9
 */
contract NullOffice {
    /// @notice Total ETH burned to the void
    uint256 public totalBurned;
    
    /// @notice Total number of burn events
    uint256 public burnCount;
    
    /// @notice Emitted when funds are burned
    event Burned(address indexed from, uint256 amount, uint256 totalBurned);
    
    /**
     * @notice Receive ETH and record the burn
     */
    receive() external payable {
        totalBurned += msg.value;
        burnCount++;
        
        emit Burned(msg.sender, msg.value, totalBurned);
    }
    
    /**
     * @notice Get current balance (total burned)
     */
    function balance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @notice Check if amount follows 3·6·9 pattern
     * @param amount Amount to check
     * @return True if digital root is 3, 6, or 9
     */
    function is369Pattern(uint256 amount) public pure returns (bool) {
        uint256 sum = digitalRoot(amount);
        return sum == 3 || sum == 6 || sum == 9;
    }
    
    /**
     * @notice Calculate digital root (sum of digits until single digit)
     * @param n Number to calculate digital root for
     * @return Digital root (1-9)
     */
    function digitalRoot(uint256 n) public pure returns (uint256) {
        if (n == 0) return 0;
        return n % 9 == 0 ? 9 : n % 9;
    }
}
