package dropecho.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using Lambda;

class TypeBuildingMacros {
	static public function isEmpty(expr:Expr) {
		if (expr == null) {
			return true;
		}
		return switch (expr.expr) {
			case ExprDef.EBlock(exprs): exprs.length == 0;
			default: false;
		}
	}

	static public function isConstant(expr:Expr) {
		if (isEmpty(expr)) {
			return false;
		}

		return switch (expr.expr) {
			case ExprDef.EConst(c): true;
			default: false;
		}

		return false;
	}

	static public function createFieldFromArg(arg, pos, doc, pub:Bool = false) {
		var docRegex = new EReg('\\*\\s@param\\s${arg.name}\\s-?\\s?(.*)', "i");
		var val = arg.value != null ? ExprTools.getValue(arg.value) : null;

		var d = '';
		if (doc != null && docRegex.match(doc)) {
			d = docRegex.matched(1) + "\nDefault: " + val;
		}

		return {
			name: arg.name,
			doc: d,
			meta: [],
			access: [pub ? APublic : APrivate],
			kind: FVar(arg.type),
			pos: pos
		};
	}

	macro static public function initLocals(custom:Array<Expr> = null):Expr {
		// Grab the variables accessible in the context the macro was called.
		var locals = Context.getLocalVars();
		var fields = Context.getLocalClass().get().fields.get();

		var exprs:Array<Expr> = custom != null ? custom : [];
		for (local in locals.keys()) {
			if (fields.exists((field) -> field.name == local)) {
				// $i generates an "identifier" from the given string.
				exprs.push(macro this.$local = $i{local});
			} else {
				throw new Error(Context.getLocalClass() + " has no field " + local, Context.currentPos());
			}
		}
		// Generates a block expression from the given expression array
		return macro $b{exprs};
	}
}
