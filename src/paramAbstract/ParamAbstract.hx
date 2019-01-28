abstract EventName<T>(String) {
	public inline function new(name) this = name;
}

@:jsRequire("events")
extern class EventEmitter {
	function new();
	function on<T>(eventName:EventName<T>, listener:T):Void;
}

class ParamAbstract {
	static inline var MyEvent = new EventName<(Int,String)->Void>("myEvent");

	static function main() {
		var ee = new EventEmitter();

		ee.on(MyEvent, function(a, b) {
			trace(a, b);
		});
	}
}
