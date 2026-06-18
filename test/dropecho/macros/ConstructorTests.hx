package dropecho.macros;

import utest.Assert;

@:nativeGen
@:build(dropecho.macros.Constructor.fromFields(true))
class FromFieldsExample {
	public var test:Int = 1;
	public var bar:Map<String, String> = new Map<String, String>();
}

typedef ConfigDef = {
	test:Int,
	bar:Int
}

typedef ConfigDef2 = {
	var test:Int;
	var bar:Int;
}

@:build(dropecho.macros.Constructor.fromTypeDef(true))
class FromClassExample {
	public function new(banana:FromFieldsExample);
}

@:build(dropecho.macros.Constructor.fromTypeDef(true))
class FromTypeDefExample {
	public function new(foo:ConfigDef);
}

@:build(dropecho.macros.Constructor.fromTypeDef(true))
class FromTypeDefExample2 {
	public function new(naz:ConfigDef2);
}

class ConstructorTests extends utest.Test {
	public function test_build_from_class_copies_fields() {
		var built = new FromClassExample(new FromFieldsExample(5));
		Assert.equals(5, built.test);
	}

	// TODO: re-enable as the macros stabilise (was covered by the buddy suite):
	//  - fromFields: restore field defaults when an arg is omitted (the disabled
	//    `value:` line in Constructor.fromFields), so `new FromFieldsExample().test == 1`.
	//  - fromTypeDef from class: config object optional in constructor; generated
	//    `build` breaks the type out into individual (optional) args.
	//  - fromTypeDef from typedef object and typedef class-like: fields copied from
	//    the typedef.
}
