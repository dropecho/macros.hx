package dropecho.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;
using Lambda;
#end

typedef TypeMacros = dropecho.macros.TypeBuildingMacros;

class Constructor {
	macro static public function fromParams(pub:Bool = false):Array<Field> {
		var fields = Context.getBuildFields();
		var constructor = fields.find(x -> x.name == "new");

		var constructorFN = switch (constructor.kind) {
			case FieldType.FFun(fn): fn;
			default: null;
		}

		// if fn is null return or if the constructor exists, don't change it.
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

	macro static public function fromTypeDef(pub:Bool = false):Array<Field> {
		var fields = Context.getBuildFields();
		var constructor = fields.find(x -> x.name == "new");

		var buildArgs = [];
		var buildExprs = [];
		var constructorExprs = [];

		var constructorFN = switch (constructor.kind) {
			case FieldType.FFun(fn): fn;
			default: null;
		}

		var configObj = constructorFN.args[0];
		var objName = configObj.name;
		buildExprs.push(macro var $objName:Dynamic = {});

		var objFields = configObj.type.toType().sure().getFields();

		for (field in objFields.sure()) {
			var fieldType = switch (field.type) {
				case TAbstract(t, _): t.get().name.asComplexType();
				case TLazy(t): switch (t()) {
						case TAbstract(t, _): t.get().name.asComplexType();
						default: null;
					}
				default: null;
			}

			if (fieldType == null) {
				continue;
			}

			// Create field from configuration object fields.
			fields.push({
				name: field.name,
				access: [pub ? APublic : APrivate],
				pos: Context.currentPos(),
				kind: FieldType.FVar(fieldType)
			});

			// Create a function argument for the "build" function from config obj.
			// like function new({x:1, y:1}) => function build(x:Int,y:Int){...}
			buildArgs.push({
				name: field.name,
				type: fieldType,
				opt: true,
			});

			// Build assignment expressions for the built config object and the constructor.
			buildExprs.push(macro $p{[objName, field.name]} = $i{field.name});
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

	macro static public function fromFields(allOpt:Bool = false):Array<Field> {
		var fields = Context.getBuildFields();
		var constructorArgs = [];
		var assignmentExprs = [];

		// build list of args for constructor from fields.
		for (f in fields) {
			switch (f.kind) {
				case FVar(t, val):
					constructorArgs.push({
						name: f.name,
						type: t,
						opt: allOpt,
						value: !TypeMacros.isEmpty(val) ? $e{val} : null
					});

					f.kind = FieldType.FVar(t, null);
				default:
			}
		}

		if (constructorArgs.length > 0) {
			// Create new constructor.
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
}
