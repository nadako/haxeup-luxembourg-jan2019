import haxe.Constraints.Function;

extern class EventEmitter {
	function new();
	function on(eventName:String, listener:Function):Void;
}
