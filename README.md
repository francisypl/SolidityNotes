`notes from blockgeeks`

# Data Types
- contract
- signed integers: int x; int256 y = 16;
- unsigned integers: uint x; uint256 y = 187; uint constant Z = 521;
- booleans: bool x; bool y = true; bool constant y = false;
- type ambiguoius: var x;
- ether public key address: address public user; (public creates an accessor method)
- byte x; // 2 bytes by default
- bytes16 y;
- bytes32 z; use to store strings can also use: string lang = 'Solidity'; // its ok to use if used locally, not if interfacing w/ other contracts
arrays: bytes32[] arr1; // dynamically sized, bytes32[3] fixedArr;

# Struct & Enum & Mapping:
## Mapping:
``` solidity
mapping(address => uint256) public balances; // mapping address to a wallet token balances
function queryBalance(address _address) constant returns (uint256 balance) {
	return balances[_address];
}
```
## Struct:
``` solidity
contract Struct {
	struct testStruct {
		uint value1;
		uint value2;
	}

	testStruct newStruct;

	function Struct() {
		newStruct.value1 = 100;
		newStruct.value2 = 200;
	}

	function balance() returns (uint) {
		return newStruct.value1;
	}
}
```

## Enum
- User defined types
- Ideal if you are modeling a finite state machine
``` solidity
contract shoppingContract {
	
	enum CheckoutState {cartEmpty, itemsInCart, payForCart, checkout};
	CheckoutState public currentState;

	bytes32[] cart;
	
	// modifiers modify the body of a function
	modifier onlyState(CheckoutState expectedState) {
		// _; is replaced by by the body of the function
		if (expectedState == currentState) {_;} else {throw;} 
	}

	function addToCart(bytes32 _item) returns (bool) {
		cart.push(_items);
		return true;
	}

	function checkout(bytes32[] _cart) onlyState(CheckoutState.itemsInCart) returns (bool) {
		// business logic
	}

}
```

# Control Strucutures
- if...else if...else
- while
- do...while
- for([init vals]; [condition]; [final expression]) ...

# Global Variables and Functions
## Message
- message, transaction and block variables
- msg.sender: address of the sender
- msg.value(uint): value in ether sent in the msg in uint
``` solidity
contract CrowdFund {

	mapping (address => uint256) funders;
	address[] funderAddresses;

	// Important to provide the payable keyword, otherwise the function will
	// automatically reject all Ether sent to it.
	function contribute() payable {
		if (funders[msg.sender] == 0) funderAddresses.push(msg.sender);
		funders[msg.sender] += msg.value;
	}

}
```
- msg.data(bytes)
- msg.gas(uint)
- msg.sig(bytes4) - first four bytes of the call data which is the signiture
## Block
- block.number(uint)
- block.difficulty(uint)
- block.blockhash(uint blockNumber), can only access the previous 256 blocks of the blockchain
- block.gaslimit(uint)
- block.coinbase(address) - returns the address of the miner that mined the current block
- block.timestamp(uint) - current block's timestamp since epoch
## Transaction
- tx.gasprice(uint) - price of gas paid by the sender
- tx.origin(address) - address data of the sender of the tx, stores the full call chain
fns
## Functions
- assert(bool condition) returns (uint), if a condition is false, it will throw and drain the gas
- addmod(uint x, uint y, unit z) returns (uint), (x + y) % z
- mulmod(uint x, uint y, unit z) returns (uint), (x * y) % z
- keccak256() returns (bytes32), hash the provided parameter using ethereum's hasing function
- sha256() returns (bytes32), takes any number of parameters and concats thems
- ripemd160() returns (bytes32)
- revert(), abort execute and rever any state changes
## Address
- \<address\>.balance (uint256), returns the balance of an address in wei
- \<address\>.send(uint256 amount), returns (bool), sends amount of wei to the address, if tx fails returns false
- \<address\>.transfer(uint amount), same as send but if tx fails, it throws instead of returning false
``` solidity
contract TestContract {

	function testFunction(uint _withdrawalAmt, address _withdrawlalAddr) {
		if (_withdrawalAddr.balance >= _withdrawalAmt) {
			// contract types are automatically converted to address types, this is the contract
			// and it can use address methods
			_withdrawalAddr.send(this.balance)
		}
		else {
			throw;
		}
	}

}
```
### Contract:
- this: refers to the current instance of the smart contract
- selfdestruct: a means of disabling a smart contract, takes on arg: an addr, disables function in smart contract, and send remaining ether in the contract to the param addr
- now: alias to block.timestamp
``` solidity
contract mortal {

	address public owner;

	function mortal() {
		owner = msg.sender;
	}

	function kill() {
		selfdestruct(owner);
	}

}
```

# Scope and Variables
- follows js scoping rules
``` solidity
function() {
	if (true) {
		int x = 1;
	}
	int x = 3;
}
// This would throw an error
```
- convention to use _ for function parameters
``` solidity
// specific name to the return value
function add(utin num1, uint num2) returns (uint sum) {
	sum = num1 + num2
}
```
- can return multiple values
``` solidity
function something() returns (uint, uint) {
	return (1, 2);
}
```
or 
``` solidity
function something() returns (uint sum1, uint sum2) {
	sum1 = 1 + 1;
	sum2 = sum1 + 2;
}
```

- payable keyword - need this to recieve ether


# Import, Inheritance and modifiers
## Import
- import './contract'; - imports an contract from the same directory
- import * as testSymbol from './contract';
- import { func1, func2 } from './contract';
- import { func1 as sendTo, func2 as balance } from './contract';
## Inheritance
- uses the is keyword to inherit, allows multiple inheritance
- derived contracts can all private functions and variables
- function collision will take the most closest definition of the function
``` solidity
contract MortalModule {

	address public owner;

	function MortalModule() {
		owner = msg.sender;
	}


	function disable() {
		if (msg.sender != owner) {
			throw;
		}
		else {
			selfdestruct(owner);
		}
	}
}

contract TestContract is MortalModule {

}
```
``` solidity

contract SetOwnerModule {
	
	address public owner;

	function owned() {
		owner = msg.sender;
	}

}

contract MortalModule is SetOwnerModule {
	
	function kill() {
		if (msg.sender == owner) {
			suicide(owner);
		}
		else {
			throw;
		}
	}

}

contract SendTo {
	
	address recipient;

	function SendTo(address _sendAddr) {
		recipient = _sendAddr;
	}

	function sendEther() {
		recipient.send(this.balance);
	}

}

// SendTo(0x123) calls the SendTo constructor
contract TestContract is MortalModule, SendTo(0x123) {
	// ...
}
```

# Events
- provides evm logging facilities, used to fire js callbacks in frontend apps
- events are inheritable
- events are stored in a transaction log - special data structure in the blockchain. Logs are associated with the addr of the contract
- import note: log and event data are not accessible in the contract, can only be use by outside entities
``` solidity
event MintCoinsLog(address _to, uint _amount, uint _newSupply);

function min(uint _amount) returns (bool) {
	if (msg.sender != owner) throw;
	totalSupply += _amount;
	balances[owner] += _amount;
	MintCoinsLog(owner, _amount, totalSupply);
	return true;
}
```
```
event TransferCoinsLog(address indexed _from, address indexed _to, uint _amount);
```
- indexed: up to three params can used the indexed attribute
- cause the args as log topics, then its possible to search for specific values of indexed arguments from the UI
- non-indexed arguments will be stored in the data section in the log

- Use of events is to: allow UI to listen to return values from smart contracts
```js
// Looks in the log for transfer between addr1 and addr2
var addr1 = 0x0123;
var addr2 = 0x0456;

Coin.TransferCoinsLog({ _from: addr1, _to: addr2 });
```

# Compiled Contracts
opcodes: what the evm is interested in, what the solidity code is compiled down to
bytecode: one to one mapping of opcodes
interface: publicly exposed methods other contracts can interact with

# Sending Transactions using JS web3
```
> web3.eth.accounts
[ '0x5a1f3a7812e1720b28d0d66af789eea16c3aca8c',
  '0xd98964a517a5370d7ca629ba87aa4fa79099e39b',
  '0x474ef4635af0a69aefad3f084b0e9c705436eb00',
  '0x095e68dc54c4d3f82fcc3ca8f57c285020263f56',
  '0x9b6f59af6d886117bcaf2713617e7c6ed1fe492b',
  '0x02adf9256f2ce0e97cdcd470695c5b40fdac9aea',
  '0xcae5683ae553987f84470cd569882dc5f1d27ee5',
  '0x32b659b62d4b450f3c6f15f3f40123456625ea27',
  '0xd909840f7b2c5ff977eeb5b51ed2586906057cc0',
  '0x80e4916e52f5076dec934892bcb077cfc99ae473' ]
> var acct1 = web3.eth.accounts[0]
undefined
> acct1
'0x5a1f3a7812e1720b28d0d66af789eea16c3aca8c'
> var acct2 = web3.eth.accounts[1]
undefined
> acct2
'0xd98964a517a5370d7ca629ba87aa4fa79099e39b'
> web3.eth.getBalance(acct1)
{ [String: '100000000000000000000'] s: 1, e: 20, c: [ 1000000 ] }
> web3.fromWei(web3.eth.getBalance(acct1))
{ [String: '100'] s: 1, e: 2, c: [ 100 ] }
> web3.fromWei(web3.eth.getBalance(acct1), 'ether')
{ [String: '100'] s: 1, e: 2, c: [ 100 ] }
> web3.fromWei(web3.eth.getBalance(acct1), 'ether').toNumber()
100
> web3.fromWei(web3.eth.getBalance(acct2), 'ether').toNumber()
100
> web3.eth.sendTransaction({from: acct1, to: acct2, value: web3.toWei(1, 'ether')})
'0x332ab3a85bb7a5a8e8d042eb60949f93e6ae07281e91522cfbfef3e7954fe677'
> web3.fromWei(web3.eth.getBalance(acct1), 'ether').toNumber()
98.99999999999999
> web3.fromWei(web3.eth.getBalance(acct2), 'ether').toNumber()
101
```


