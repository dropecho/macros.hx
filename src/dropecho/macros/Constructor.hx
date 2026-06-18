package dropecho.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;
using Lambda;
#end

typedef TypeMacros = dropecho.macros.TypeBuildingMacros;

class Constructor {
	/**
	Build the body of an existing empty constructor from its arguments, and
	create matching fields on the class for each argument.

	e.g. `function new(a:Int, b:Int);` creates fields `a` and `b` on the class
	and assigns the passed values in the constructor body. If the constructor is
	missing or already has a body, the fields are returned unchanged.

	@param pub Whether the created fields should be public.
	@return The build fields, including any fields created from the arguments.
	**/
	public static macro function fromArgs(pub:Bool = false):Array<Field> {
		var fields = Context.getBuildFields();
		var constructor = fields.find(x -> x.name == "new");

		var constructorFN = switch (constructor.kind) {
			case FieldType.FFun(fn): fn;
			default: null;
		}

		// If there is no constructor, or it already has a body, leave it alone.
		// TODO: Extend it?
		if (constructorFN == null || !TypeMacros.isEmpty(constructorFN.expr)) {
			return fields;
		}

		for (arg in constructorFN.args) {
			final f = TypeMacros.createFieldFromArg(arg, Context.currentPos(), constructor.doc, pub);
			fields.push(f);
		}
		constructorFN.expr = macro dropecho.macros.TypeBuildingMacros.initLocals();
		return fields;
	}

	/**
	Auto-create a constructor from the variable fields of a class. Each field
	becomes a constructor argument that is assigned to `this` in the generated
	body; the fields lose their inline initializer.

	@param allOpt Whether every generated argument should be optional.
	@return The build fields, including the generated constructor.
	**/
	public static macro function fromFields(allOpt:Bool = false):Array<Field> {
		var fields = Context.getBuildFields();
		var constructorArgs = [];

		// Build the list of constructor args from the variable fields. A field
		// with a constant initializer keeps it as the arg's default value, so an
		// omitted arg falls back to that default; the field itself is nulled so
		// the assignment in the constructor body wins.
		for (f in fields) {
			switch (f.kind) {
				case FVar(t, val):
					constructorArgs.push({
						name: f.name,
						type: t,
						opt: allOpt,
						value: (val != null && TypeMacros.isConstant(val)) ? val : null
					});
					f.kind = FieldType.FVar(t, null);
				default:
			}
		}

		if (constructorArgs.length > 0) {
			fields.push({
				name: "new",
				access: [APublic],
				pos: Context.currentPos(),
				kind: FFun({
					args: constructorArgs,
					expr: macro dropecho.macros.TypeBuildingMacros.initLocals(),
					params: [],
					ret: null
				})
			});
		}
		return fields;
	}

	/**
	Build a class from a single configuration argument on its constructor. The
	config object's fields are copied onto the class as fields, the constructor
	body assigns them from the config, and a static `build` function is generated
	that accepts the config fields broken out as individual arguments.

	@param pub Whether the copied fields should be public.
	@return The build fields, including the generated `build` function.
	**/
	public static macro function fromTypeDef(pub:Bool = false):Array<Field> {
		var fields = Context.getBuildFields();
		var constructor = fields.find(x -> x.name == "new");

		var constructorFN = constructor == null ? null : switch (constructor.kind) {
			case FieldType.FFun(fn): fn;
			default: null;
		}

		if (constructorFN == null || constructorFN.args.length == 0) {
			Context.error("Constructor.fromTypeDef requires a constructor with a single config argument.", Context.currentPos());
			return fields;
		}

		var buildArgs = [];
		var buildExprs = [];
		var constructorExprs = [];

		var configObj = constructorFN.args[0];
		var objName = configObj.name;

		var configIsClass = false;
		var configClassName;
		var newExpr = switch (configObj.type.toType().sure()) {
			case TInst(t, params): {
					configIsClass = true;
					configClassName = t.get().name.asTypePath();
					(macro var $objName = new $configClassName());
				}
			case TType(t, params): (macro var $objName:Dynamic = {});
			default: null;
		}
		if (newExpr != null) {
			buildExprs.push(newExpr);
		}

		if (configIsClass) {
			configObj.opt = true;

			if (newExpr != null) {
				constructorExprs.push(macro $i{objName} = $i{objName} != null ? $i{objName} : new $configClassName());
			}
		}

		var objFields = configObj.type.toType().sure().getFields().sure();

		for (field in objFields) {
			// Resolve each config field's type to a ComplexType we can declare.
			// toComplex() forces lazy types and handles parameterized types
			// (e.g. Map<K, V>) correctly, unlike a hand-rolled type switch.
			var fieldType = field.type.toComplex();

			if (fieldType == null) {
				continue;
			}

			// Create a field on the class from each configuration object field.
			fields.push({
				name: field.name,
				access: [pub ? APublic : APrivate],
				pos: Context.currentPos(),
				kind: FieldType.FVar(fieldType)
			});

			// Create a `build` argument for each config field, e.g.
			// `new({x:1, y:1})` => `build(x:Int, y:Int) {...}`.
			buildArgs.push({
				name: field.name,
				type: fieldType,
				opt: configIsClass,
			});

			// Assign the built config object and the constructor body.
			if (configIsClass) {
				buildExprs.push(macro $p{[objName, field.name]} = $i{field.name} != null ? $i{field.name} : $p{[objName, field.name]});
			} else {
				buildExprs.push(macro $p{[objName, field.name]} = $i{field.name});
			}

			constructorExprs.push(macro $p{["this", field.name]} = $p{[objName, field.name]});
		}

		switch (Context.getLocalType()) {
			case TInst(_.get().name => name, _):
				var path = name.asTypePath();
				buildExprs.push(macro return new $path($i{configObj.name}));
			default:
		}

		fields.push({
			name: "build",
			access: [AStatic, APublic],
			pos: Context.currentPos(),
			kind: FFun({
				args: buildArgs,
				expr: macro $b{buildExprs},
				params: [],
				ret: null
			})
		});

		constructorFN.expr = macro $b{constructorExprs};
		return fields;
	}
}
