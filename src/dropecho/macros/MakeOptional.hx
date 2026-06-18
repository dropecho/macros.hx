package dropecho.macros;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using Lambda;
#end

/**
WIP: build macro that copies the fields of another type onto the current
class as optional fields. Currently resolves the source fields but returns the
class unchanged while the field-rewriting is worked out.
**/
class OptionalType {
	/**
	Copy the fields of `from` onto the building class as optional fields.

	@param from An identifier expression naming the class to copy fields from.
	@return The build fields for the current class.
	**/
	public static macro function optional(from:Expr):Array<Field> {
		var fields = switch (from.expr) {
			case EConst(CIdent(cls)):
				switch (Context.getType(cls)) {
					case TInst(_.get() => t, _):
						t.fields;
					default:
						throw "Invalid type";
				}
			default:
				throw "Invalid argument";
		}

		// TODO: rewrite `fields` as optional and merge them onto the build fields
		// instead of returning the class unchanged.
		return Context.getBuildFields();
	}
}
