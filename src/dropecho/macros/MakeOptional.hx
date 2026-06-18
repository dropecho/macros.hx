package dropecho.macros;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using Lambda;
#end

/**
Build macro that copies the variable fields of another type onto the current
class as optional fields.
**/
class OptionalType {
	/**
	Copy the variable fields of `from` onto the building class as public,
	optional (`Null<T>`) fields. Methods on the source are ignored, and fields
	whose name already exists on the building class are left untouched.

	@param from An identifier expression naming the class to copy fields from.
	@return The build fields for the current class, plus the copied fields.
	**/
	public static macro function optional(from:Expr):Array<Field> {
		var sourceFields = switch (from.expr) {
			case EConst(CIdent(cls)):
				switch (Context.getType(cls)) {
					case TInst(_.get() => t, _):
						t.fields.get();
					default:
						Context.error("MakeOptional.optional expects a class identifier.", from.pos);
						[];
				}
			default:
				Context.error("MakeOptional.optional expects a class identifier.", from.pos);
				[];
		}

		var fields = Context.getBuildFields();
		var existing = [for (f in fields) f.name => true];

		for (sf in sourceFields) {
			// Only copy variable fields (skip methods/constructors), and never
			// clobber a field the building class already declares.
			switch (sf.kind) {
				case FVar(_, _):
					if (existing.exists(sf.name)) {
						continue;
					}
					var ct = sf.type.toComplexType();
					if (ct == null) {
						continue;
					}
					fields.push({
						name: sf.name,
						access: [APublic],
						pos: Context.currentPos(),
						kind: FVar(macro :Null<$ct>)
					});
				default:
			}
		}

		return fields;
	}
}
