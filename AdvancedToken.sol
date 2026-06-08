// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AdvancedToken is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ReentrancyGuard
{
    bytes32 public constant MINTER_ROLE =
        keccak256("MINTER_ROLE");

    bytes32 public constant PAUSER_ROLE =
        keccak256("PAUSER_ROLE");

    uint8 private immutable _tokenDecimals;
    uint256 private immutable _cap;

    bool public feeEnabled;

    uint256 public feePercent; // basis points

    address public feeCollector;

    mapping(address => bool) public isExcludedFromFee;

    event FeeEnabled(bool enabled);

    event FeePercentUpdated(
        uint256 oldFee,
        uint256 newFee
    );

    event FeeCollectorUpdated(
        address indexed collector
    );

    event ExcludedFromFee(
        address indexed account,
        bool excluded
    );

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 cap_,
        address admin_
    ) ERC20(name_, symbol_) {
        require(
            admin_ != address(0),
            "Invalid admin"
        );

        _tokenDecimals = decimals_;
        _cap = cap_;

        _grantRole(
            DEFAULT_ADMIN_ROLE,
            admin_
        );

        _grantRole(
            MINTER_ROLE,
            admin_
        );

        _grantRole(
            PAUSER_ROLE,
            admin_
        );

        feeCollector = admin_;
        feePercent = 100;

        isExcludedFromFee[admin_] = true;
    }

    function decimals()
        public
        view
        override
        returns (uint8)
    {
        return _tokenDecimals;
    }

    function cap()
        external
        view
        returns (uint256)
    {
        return _cap;
    }

    function mint(
        address to,
        uint256 amount
    )
        external
        onlyRole(MINTER_ROLE)
        nonReentrant
    {
        require(
            totalSupply() + amount <= _cap,
            "Cap exceeded"
        );

        _mint(to, amount);
    }

    function pause()
        external
        onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause()
        external
        onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    function setFeeEnabled(bool enabled)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        feeEnabled = enabled;

        emit FeeEnabled(enabled);
    }

    function setFeePercent(
        uint256 percent
    )
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            percent <= 1000,
            "Max 10%"
        );

        emit FeePercentUpdated(
            feePercent,
            percent
        );

        feePercent = percent;
    }

    function setFeeCollector(
        address collector
    )
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            collector != address(0),
            "Invalid collector"
        );

        feeCollector = collector;

        emit FeeCollectorUpdated(
            collector
        );
    }

    function excludeFromFee(
        address account,
        bool excluded
    )
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        isExcludedFromFee[
            account
        ] = excluded;

        emit ExcludedFromFee(
            account,
            excluded
        );
    }

    function _update(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(
            ERC20,
            ERC20Pausable
        )
    {
        if (
            feeEnabled &&
            from != address(0) &&
            to != address(0) &&
            !isExcludedFromFee[from] &&
            !isExcludedFromFee[to]
        ) {
            uint256 fee =
                (amount *
                    feePercent) /
                10000;

            uint256 sendAmount =
                amount - fee;

            if (fee > 0) {
                super._update(
                    from,
                    feeCollector,
                    fee
                );
            }

            super._update(
                from,
                to,
                sendAmount
            );
        } else {
            super._update(
                from,
                to,
                amount
            );
        }
    }
}