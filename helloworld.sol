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
