// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OrderBookDex {
    struct Order {
        uint256 orderId;
        uint256 amountOffered;
        uint256 amountRequested;
        address recipeint;
        address creator;
        address tokenOffered;
        address tokenRequested;
        bool isFilled;
        bool isActive;
    }

    mapping(address => mapping(uint256 => Order)) orders;
    mapping(address => uint256) public orderCount;

    // ========== ERRORS ==========
    error OrderBookDEX__AmountMustBeGreaterThanZero();
    error OrderBookDEX__OrderNotActive();
    error OrderBookDEX__AddressZeroNotAllowed(address sender);
    error OrderBookDEX__OrderFilled();
    error OrderBookDEX__OnlyCreatorAllowed(address creator);
    error OrderBookDEX__CannotBeSameToken();

    // ========== EVENTS ==========
    event OrderCreated(
        uint256 indexed orderId,
        address indexed tokenOffered,
        address indexed tokenRequested,
        uint256 amountOffered,
        uint256 amountRequested,
        address recipient
    );
    event OrderFulfilled(uint256 indexed orderId, address indexed buyer);

    // ========== PRIVATEFUNCTIONS ==========
    function _checkAddressZero(address _address) private pure {
        if (_address == address(0))
            revert OrderBookDEX__AddressZeroNotAllowed(_address);
    }

    // CREATE ORDER
    function createOrder(
        address _to,
        address _tokenOffered,
        address _tokenRequested,
        uint256 _amountOffered,
        uint256 _amountRequested
    ) external returns (uint256 orderId) {
        _checkAddressZero(_to);
        if (_amountOffered == 0)
            revert OrderBookDEX__AmountMustBeGreaterThanZero();
        if (_amountRequested == 0)
            revert OrderBookDEX__AmountMustBeGreaterThanZero();
        if (_tokenOffered == _tokenRequested)
            revert OrderBookDEX__CannotBeSameToken();

        IERC20(_tokenOffered).transferFrom(
            msg.sender,
            address(this),
            _amountOffered
        );

        orderId = orderCount[_tokenOffered] + 1;
        Order memory newOrder = Order({
            orderId: orderId,
            creator: msg.sender,
            tokenOffered: _tokenOffered,
            amountOffered: _amountOffered,
            tokenRequested: _tokenRequested,
            amountRequested: _amountRequested,
            recipeint: _to,
            isFilled: false,
            isActive: true
        });

        orderCount[_tokenOffered] = orderId;
        orders[_tokenOffered][orderId] = newOrder;

        emit OrderCreated(
            orderId,
            _tokenOffered,
            _tokenRequested,
            _amountOffered,
            _amountRequested,
            _to
        );
    }

    // FULFILL ORDER
    function fillOrder(uint256 _orderId, address _offeredToken) external {
        Order storage order = orders[_offeredToken][_orderId];

        if (order.isFilled) revert OrderBookDEX__OrderFilled();
        if (!order.isActive) revert OrderBookDEX__OrderNotActive();

        IERC20(order.tokenRequested).transferFrom(
            msg.sender,
            order.recipeint,
            order.amountRequested
        );

        IERC20(order.tokenOffered).transfer(msg.sender, order.amountOffered);

        order.isActive = false;
        order.isFilled = true;

        emit OrderFulfilled(_orderId, msg.sender);
    }

    // CANCEL ORDER
    function cancelOrder(uint256 _orderId, address _offeredToken) external {
        Order storage order = orders[_offeredToken][_orderId];

        if (order.isFilled) revert OrderBookDEX__OrderFilled();
        if (!order.isActive) revert OrderBookDEX__OrderNotActive();
        if (msg.sender != order.creator)
            revert OrderBookDEX__OnlyCreatorAllowed(order.creator);

        IERC20(order.tokenOffered).transfer(order.creator, order.amountOffered);

        order.isActive = false;
    }

    // GETTERS
    function getOrder(
        uint256 _orderId,
        address _offeredToken
    ) external view returns (Order memory) {
        return orders[_offeredToken][_orderId];
    }

    function getOrderCount(
        address _offeredToken
    ) external view returns (uint256) {
        return orderCount[_offeredToken];
    }
}
