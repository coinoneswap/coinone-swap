/**
 *Submitted for verification at BscScan.com on 2021-04-23
*/

import './interfaces/ICoinoneFactory.sol';
import './CoinonePair.sol';

pragma solidity =0.5.16;


contract CoinoneFactory is ICoinoneFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(CoinonePair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    uint count = 0;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }


    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Coinone: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Coinone: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Coinone: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(CoinonePair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ICoinonePair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        count = count + 1;
        emit PairCreated(token0, token1, pair, count);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Coinone: FORBIDDEN'); 
        require(_feeTo != address(0), "_feeTo is zero address!");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Coinone: FORBIDDEN');
        require(_feeToSetter != address(0), "_feeToSetter is zero address!");
        feeToSetter = _feeToSetter;
    }
}
