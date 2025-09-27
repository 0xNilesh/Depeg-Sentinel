// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPyth} from "@pythnetwork/IPyth.sol";
import {PythStructs} from "@pythnetwork/PythStructs.sol";

/// @notice PythOracleAdapter: Adapter for reading Pyth price and confidence for two tokens.
/// Normalizes values and provides helpers for confRatio.
contract PythOracleAdapter {
    IPyth public immutable pyth;

    uint256 public maxStaleness = 60; // Seconds; configurable

    constructor(address _pyth) {
        pyth = IPyth(_pyth);
    }

    /// @notice Get price, confidence, and publish time for a specified price feed
    /// @param priceFeedId The Pyth price feed ID (either priceFeedId0 or priceFeedId1)
    function getPriceWithConfidence(bytes32 priceFeedId)
        external
        view
        returns (int64 price, uint64 conf, uint256 publishTime)
    {
        PythStructs.Price memory pythPrice = pyth.getPriceUnsafe(priceFeedId);
        // require(block.timestamp - pythPrice.publishTime <= maxStaleness, "PythOracleAdapter: stale price");
        return (pythPrice.price, pythPrice.conf, pythPrice.publishTime);
    }

    /// @notice Compute confRatio in basis points (conf / |price| * 10000)
    function computeConfRatioBps(int64 price, uint64 conf) external pure returns (uint256) {
        if (price == 0) return 0;
        uint256 absPrice = price > 0 ? uint256(uint64(price)) : uint256(uint64(-price));
        return (uint256(conf) * 10000) / absPrice;
    }

    /// @notice Set max staleness (governance)
    function setMaxStaleness(uint256 _maxStaleness) external {
        maxStaleness = _maxStaleness;
    }
}
