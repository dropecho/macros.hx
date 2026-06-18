package dropecho.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using Lambda;

/**
Shared compile-time helpers used by the other build macros to inspect
expressions and create fields/constructor bodies.
**/
class TypeBuildingMacros {
	/**
	Check whether an expression is null or empty. If the expression is a block
	(e.g. a function body), it is empty when it contains no sub-expressions.

	@param expr The expression to check.
	@return Whether the expression is null or an empty block.
	**/
	public static function isEmpty(expr:Expr) {
		if (expr == null) {
			return true;
		}
		return switch (expr.expr) {
			case ExprDef.EBlock(exprs): exprs.length == 0;
			default: false;
		}
	}

	/**
	Check whether an expression is a constant expression.

	@param expr The expression to check.
	@return Whether the expression is a non-empty constant.
	**/
	public static function isConstant(expr:Expr) {
		if (isEmpty(expr)) {
			return false;
		}

		return switch (expr.expr) {
			case ExprDef.EConst(c): true;
			default: false;
		}
	}

	/**
	Create a class field from a constructor argument, carrying over any
	matching `@param` documentation and the argument's default value.

	@param arg The constructor argument to build a field from.
	@param pos The position to assign to the generated field.
	@param doc The owning constructor's doc comment, scanned for `@param` text.
	@param pub Whether the created field should be public.
	@return The generated field.
	**/
	public static function createFieldFromArg(arg, pos, doc, pub:Bool = false) {
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

	/**
	Generate a block that assigns each local variable in scope to the matching
	field on `this`, optionally prefixed with custom expressions. Used as the
	generated body for constructors built by the other macros.

	@param custom Optional expressions to prepend to the generated block.
	@return A block expression assigning locals to their matching fields.
	**/
	public static macro function initLocals(custom:Array<Expr> = null):Expr {
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
		// Generates a block expression from the given expression array.
		return macro $b{exprs};
	}
}
