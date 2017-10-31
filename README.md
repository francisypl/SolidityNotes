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

# Deploying
## opcodes
This is what the EVM is interested in. What solc code is compiled down to.
## byecode
One to one mapping of opcodes. Also provided to the EVM.
## interface
ABI. Users and other contracts can interact with this.

# Contract on testRPC
``` 
> acct1
'0x92e0972ea47756a6a4287cda03f2224696483c6b'
> var source = `contract helloWorld {
...
...         string public message;
...
...         function helloWorld() {
...                 message = 'hello world';
...         }
...
...         // constant indicates it doesnt change any state
...         function sayHi() constant returns (string) {
...                 return message;
...         }
...
... }`
undefined
> var compiled = solc.compile(source)
undefined
> compiled
{ contracts:
   { ':helloWorld':
      { assembly: [Object],
        bytecode: '6060604052341561000f57600080fd5b6040805190810160405280600b81526020017f68656c6c6f20776f726c640000000000000000000000000000000000000000008152506000908051906020019061005a929190610060565b50610105565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100a157805160ff19168380011785556100cf565b828001600101855582156100cf579182015b828111156100ce5782518255916020019190600101906100b3565b5b5090506100dc91906100e0565b5090565b61010291905b808211156100fe5760008160009055506001016100e6565b5090565b90565b6102f3806101146000396000f30060606040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680630c49c36c14610051578063e21f37ce146100df575b600080fd5b341561005c57600080fd5b61006461016d565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100a4578082015181840152602081019050610089565b50505050905090810190601f1680156100d15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34156100ea57600080fd5b6100f2610215565b6040518080602001828103825283818151815260200191508051906020019080838360005b83811015610132578082015181840152602081019050610117565b50505050905090810190601f16801561015f5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101756102b3565b60008054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561020b5780601f106101e05761010080835404028352916020019161020b565b820191906000526020600020905b8154815290600101906020018083116101ee57829003601f168201915b5050505050905090565b60008054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102ab5780601f10610280576101008083540402835291602001916102ab565b820191906000526020600020905b81548152906001019060200180831161028e57829003601f168201915b505050505081565b6020604051908101604052806000815250905600a165627a7a723058209826efa13ad92a56d6fd81f6105c7cba835c60598ae8ddc4afdfd440f80a0c990029',
        functionHashes: [Object],
        gasEstimates: [Object],
        interface: '[{"constant":true,"inputs":[],"name":"sayHi","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"message","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]',
        metadata: '{"compiler":{"version":"0.4.18+commit.9cf6e910"},"language":"Solidity","output":{"abi":[{"constant":true,"inputs":[],"name":"sayHi","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"message","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"}],"devdoc":{"methods":{}},"userdoc":{"methods":{}}},"settings":{"compilationTarget":{"":"helloWorld"},"libraries":{},"optimizer":{"enabled":false,"runs":200},"remappings":[]},"sources":{"":{"keccak256":"0x1d4ee88697cfb6758d45d6808f2634e7ed063aa45f5b6ab8da52f0118b50bbab","urls":["bzzr://032dda897bfa76bdc35662c84ef4d67526abf6430cf4760901486ce6e6a1b12d"]}},"version":1}',
        opcodes: 'PUSH1 0x60 PUSH1 0x40 MSTORE CALLVALUE ISZERO PUSH2 0xF JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH1 0x40 DUP1 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0xB DUP2 MSTORE PUSH1 0x20 ADD PUSH32 0x68656C6C6F20776F726C64000000000000000000000000000000000000000000 DUP2 MSTORE POP PUSH1 0x0 SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0x5A SWAP3 SWAP2 SWAP1 PUSH2 0x60 JUMP JUMPDEST POP PUSH2 0x105 JUMP JUMPDEST DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 PUSH1 0x1F ADD PUSH1 0x20 SWAP1 DIV DUP2 ADD SWAP3 DUP3 PUSH1 0x1F LT PUSH2 0xA1 JUMPI DUP1 MLOAD PUSH1 0xFF NOT AND DUP4 DUP1 ADD OR DUP6 SSTORE PUSH2 0xCF JUMP JUMPDEST DUP3 DUP1 ADD PUSH1 0x1 ADD DUP6 SSTORE DUP3 ISZERO PUSH2 0xCF JUMPI SWAP2 DUP3 ADD JUMPDEST DUP3 DUP2 GT ISZERO PUSH2 0xCE JUMPI DUP3 MLOAD DUP3 SSTORE SWAP2 PUSH1 0x20 ADD SWAP2 SWAP1 PUSH1 0x1 ADD SWAP1 PUSH2 0xB3 JUMP JUMPDEST JUMPDEST POP SWAP1 POP PUSH2 0xDC SWAP2 SWAP1 PUSH2 0xE0 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST PUSH2 0x102 SWAP2 SWAP1 JUMPDEST DUP1 DUP3 GT ISZERO PUSH2 0xFE JUMPI PUSH1 0x0 DUP2 PUSH1 0x0 SWAP1 SSTORE POP PUSH1 0x1 ADD PUSH2 0xE6 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST SWAP1 JUMP JUMPDEST PUSH2 0x2F3 DUP1 PUSH2 0x114 PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN STOP PUSH1 0x60 PUSH1 0x40 MSTORE PUSH1 0x4 CALLDATASIZE LT PUSH2 0x4C JUMPI PUSH1 0x0 CALLDATALOAD PUSH29 0x100000000000000000000000000000000000000000000000000000000 SWAP1 DIV PUSH4 0xFFFFFFFF AND DUP1 PUSH4 0xC49C36C EQ PUSH2 0x51 JUMPI DUP1 PUSH4 0xE21F37CE EQ PUSH2 0xDF JUMPI JUMPDEST PUSH1 0x0 DUP1 REVERT JUMPDEST CALLVALUE ISZERO PUSH2 0x5C JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0x64 PUSH2 0x16D JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP1 PUSH1 0x20 ADD DUP3 DUP2 SUB DUP3 MSTORE DUP4 DUP2 DUP2 MLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP4 DUP4 PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0xA4 JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0x89 JUMP JUMPDEST POP POP POP POP SWAP1 POP SWAP1 DUP2 ADD SWAP1 PUSH1 0x1F AND DUP1 ISZERO PUSH2 0xD1 JUMPI DUP1 DUP3 SUB DUP1 MLOAD PUSH1 0x1 DUP4 PUSH1 0x20 SUB PUSH2 0x100 EXP SUB NOT AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP JUMPDEST POP SWAP3 POP POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST CALLVALUE ISZERO PUSH2 0xEA JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST PUSH2 0xF2 PUSH2 0x215 JUMP JUMPDEST PUSH1 0x40 MLOAD DUP1 DUP1 PUSH1 0x20 ADD DUP3 DUP2 SUB DUP3 MSTORE DUP4 DUP2 DUP2 MLOAD DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP4 DUP4 PUSH1 0x0 JUMPDEST DUP4 DUP2 LT ISZERO PUSH2 0x132 JUMPI DUP1 DUP3 ADD MLOAD DUP2 DUP5 ADD MSTORE PUSH1 0x20 DUP2 ADD SWAP1 POP PUSH2 0x117 JUMP JUMPDEST POP POP POP POP SWAP1 POP SWAP1 DUP2 ADD SWAP1 PUSH1 0x1F AND DUP1 ISZERO PUSH2 0x15F JUMPI DUP1 DUP3 SUB DUP1 MLOAD PUSH1 0x1 DUP4 PUSH1 0x20 SUB PUSH2 0x100 EXP SUB NOT AND DUP2 MSTORE PUSH1 0x20 ADD SWAP2 POP JUMPDEST POP SWAP3 POP POP POP PUSH1 0x40 MLOAD DUP1 SWAP2 SUB SWAP1 RETURN JUMPDEST PUSH2 0x175 PUSH2 0x2B3 JUMP JUMPDEST PUSH1 0x0 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x20B JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x1E0 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x20B JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x1EE JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP SWAP1 POP SWAP1 JUMP JUMPDEST PUSH1 0x0 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV DUP1 ISZERO PUSH2 0x2AB JUMPI DUP1 PUSH1 0x1F LT PUSH2 0x280 JUMPI PUSH2 0x100 DUP1 DUP4 SLOAD DIV MUL DUP4 MSTORE SWAP2 PUSH1 0x20 ADD SWAP2 PUSH2 0x2AB JUMP JUMPDEST DUP3 ADD SWAP2 SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 JUMPDEST DUP2 SLOAD DUP2 MSTORE SWAP1 PUSH1 0x1 ADD SWAP1 PUSH1 0x20 ADD DUP1 DUP4 GT PUSH2 0x28E JUMPI DUP3 SWAP1 SUB PUSH1 0x1F AND DUP3 ADD SWAP2 JUMPDEST POP POP POP POP POP DUP2 JUMP JUMPDEST PUSH1 0x20 PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 PUSH1 0x0 DUP2 MSTORE POP SWAP1 JUMP STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 SWAP9 0x26 0xef LOG1 GASPRICE 0xd9 0x2a JUMP 0xd6 REVERT DUP2 0xf6 LT 0x5c PUSH29 0xBA835C60598AE8DDC4AFDFD440F80A0C99002900000000000000000000 ',
        runtimeBytecode: '60606040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680630c49c36c14610051578063e21f37ce146100df575b600080fd5b341561005c57600080fd5b61006461016d565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100a4578082015181840152602081019050610089565b50505050905090810190601f1680156100d15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34156100ea57600080fd5b6100f2610215565b6040518080602001828103825283818151815260200191508051906020019080838360005b83811015610132578082015181840152602081019050610117565b50505050905090810190601f16801561015f5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101756102b3565b60008054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561020b5780601f106101e05761010080835404028352916020019161020b565b820191906000526020600020905b8154815290600101906020018083116101ee57829003601f168201915b5050505050905090565b60008054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102ab5780601f10610280576101008083540402835291602001916102ab565b820191906000526020600020905b81548152906001019060200180831161028e57829003601f168201915b505050505081565b6020604051908101604052806000815250905600a165627a7a723058209826efa13ad92a56d6fd81f6105c7cba835c60598ae8ddc4afdfd440f80a0c990029',
        srcmap: '0:293:0:-;;;63:74;;;;;;;;103:23;;;;;;;;;;;;;;;;;;:7;:23;;;;;;;;;;;;:::i;:::-;;0:293;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::i;:::-;;;:::o;:::-;;;;;;;;;;;;;;;;;;;;;;;;;;;:::o;:::-;;;;;;;',
        srcmapRuntime: '0:293:0:-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;204:86;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;23:1:-1;8:100;33:3;30:1;27:2;8:100;;;99:1;94:3;90;84:5;80:1;75:3;71;64:6;52:2;49:1;45:3;40:15;;8:100;;;12:14;3:109;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;31:21:0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;23:1:-1;8:100;33:3;30:1;27:2;8:100;;;99:1;94:3;90;84:5;80:1;75:3;71;64:6;52:2;49:1;45:3;40:15;;8:100;;;12:14;3:109;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;204:86:0;239:6;;:::i;:::-;272:7;265:14;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;204:86;:::o;31:21::-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::o;0:293::-;;;;;;;;;;;;;;;:::o' } },
  errors:
   [ ':5:9: Warning: No visibility specified. Defaulting to "public".\n        function helloWorld() {\n        ^\nSpanning multiple lines.\n',
     ':10:9: Warning: No visibility specified. Defaulting to "public".\n        function sayHi() constant returns (string) {\n        ^\nSpanning multiple lines.\n',
     ':1:1: Warning: Source file does not specify required compiler version!Consider adding "pragma solidity ^0.4.18\ncontract helloWorld {\n^\nSpanning multiple lines.\n' ],
  sourceList: [ '' ],
  sources: { '': { AST: [Object] } } }
> var data = compiled.contracts[':helloWorld'].bytecode
undefined
> var abi = JSON.parse(compiled.contracts[':helloWorld'].interface)
> var helloWorldContract = web3.eth.contract(abi)
> var deployed = helloWorldContract.new({
... from: acct1,
... data: data,
... gas: 4700000,
... gasPrice: 1,
... },
... (error, contract) => { } )
undefined
> deployed.sayHi()
'hello world'
> deployed.message()
'hello world'
>
```
## Contract
``` solidity
contract helloWorld {

        string public message;

        function helloWorld() {
                message = 'hello world';
        }

        // constant indicates it doesnt change any state
        function sayHi() constant returns (string) {
                return message;
        }

}
```


