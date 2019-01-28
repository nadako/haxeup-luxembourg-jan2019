import Validator.validate;

typedef Customer = {
	var name:String;
	var ?age:Int;
	var cart:Array<ProductId>;
}

abstract ProductId(Int) from Int {}

class Validation {
	static function main() {
		var rawData = haxe.Json.parse('{
			"name": "John",
			"age": 25,
			"cart": [1,2]
		}');

		var customer = validate(rawData, Customer);
		trace(customer.name);
	}
}
