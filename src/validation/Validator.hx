#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;
#end

class Validator {
	public static macro function validate(data:Expr, type:Expr):Expr {
		function getValidationExpr(valueExpr:Expr, type:Type):Expr {
			type = type.follow(); // don't care about typedefs for the sake of simplicity

			switch type.toString() {
				case "String":
					return macro if (!Std.is($valueExpr, String)) throw "not a string";

				case "Int":
					return macro if (!Std.is($valueExpr, Int)) throw "not an int";

				case _:
					switch type {
						case TAnonymous(_.get() => anon):
							var checks = [];
							checks.push(macro if (!Reflect.isObject(obj)) throw "not an object");
							for (field in anon.fields) {
								var fieldName = field.name;
								var checkExpr = getValidationExpr(macro obj.$fieldName, field.type);
								var hasFieldExpr = macro Reflect.hasField(obj, $v{fieldName});
								if (field.meta.has(":optional")) {
									checkExpr = macro if ($hasFieldExpr) $checkExpr;
								} else {
									checks.push(macro if (!$hasFieldExpr) throw $v{"object doesnt have field " + fieldName});
								}
								checks.push(checkExpr);
							}
							return macro {
								var obj:Dynamic<Dynamic> = $valueExpr;
								$b{checks};
							}

						case TInst(_.toString() => "Array", [elemType]):
							var elemCheck = getValidationExpr(macro elem, elemType);
							return macro {
								var arr:Array<Dynamic> = $valueExpr;
								if (!Std.is(arr, Array)) throw "not an array";
								for (elem in arr) {
									$elemCheck;
								}
							}

						case TAbstract(_.get() => ab, params):
							// first - validate using the real underlying type
							// second - if there's a "validate" function - also call it
							var realType = ab.type.applyTypeParameters(ab.params, params);
							var validateMethod = ab.impl.get().findField("validate", true);
							if (validateMethod != null) {
								var realTypeCheck = getValidationExpr(macro value, realType);
								var typePathExpr = macro $p{ab.module.split(".").concat([ab.name])};
								return macro {
									var value:Dynamic = $valueExpr;
									$realTypeCheck;
									@:privateAccess $typePathExpr.validate(value);
								}
							} else {
								return getValidationExpr(valueExpr, realType);
							}

						case _:
							return macro {}; // empty block, or we can emit a warning or error here
					}
			}
		}

		var type = Context.getType(type.toString());
		var ct = type.toComplexType();
		return macro {
			var value:Dynamic = $data;
			${getValidationExpr(macro value, type)};
			(value : $ct);
		}
	}
}
