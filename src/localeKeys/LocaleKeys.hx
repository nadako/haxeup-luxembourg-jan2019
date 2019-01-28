abstract LocaleKey(String) {
	public inline function new(key) this = key;
	public inline function asString() return this;
}

class Messages {
	public static inline var hello = new LocaleKey("hello");
}

class LocaleKeys {
	static function translate(key:LocaleKey):String {
		return key.asString().toUpperCase();
	}

	static function display(text:String) {
		trace(text);
	}

	static function main() {
		var translatedMessage = translate(Messages.hello);
		display(translatedMessage);
		
		// translate(translatedMessage);
		// display(Messages.hello);
	}
}
