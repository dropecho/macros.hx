package dropecho.macros;

import utest.Assert;

@:build(dropecho.macros.Constructor.fromArgs())
class FromArgsPrivateExample {
	public function new(test:Int = 1, bar:Int = 2);
}

@:build(dropecho.macros.Constructor.fromArgs(true))
class FromArgsPublicExample {
	public function new(test:Int = 1, bar:Int = 2);
}

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
	public function test_fromArgs_makes_fields_private_by_default() {
		var built = new FromArgsPrivateExample();
		Assert.equals(1, Reflect.field(built, "test"));
		Assert.equals(2, Reflect.field(built, "bar"));
	}

	public function test_fromArgs_makes_fields_public_when_true() {
		var built = new FromArgsPublicExample();
		Assert.equals(1, built.test);
		Assert.equals(2, built.bar);
	}

	public function test_fromFields_builds_constructor_from_fields() {
		var built = new FromFieldsExample(5);
		Assert.equals(5, built.test);
	}

	public function test_fromFields_applies_field_default_when_omitted() {
		var built = new FromFieldsExample();
		Assert.equals(1, built.test);
	}

	public function test_fromTypeDef_from_class_copies_fields() {
		var built = new FromClassExample(new FromFieldsExample(5));
		Assert.equals(5, built.test);
	}

	public function test_fromTypeDef_from_class_makes_config_optional() {
		var built = new FromClassExample();
		Assert.equals(1, built.test);
	}

	public function test_fromTypeDef_build_breaks_out_args() {
		var built = FromClassExample.build(7, null);
		Assert.equals(7, built.test);
	}

	public function test_fromTypeDef_build_args_are_optional() {
		var built = FromClassExample.build();
		Assert.equals(1, built.test);
	}

	public function test_fromTypeDef_from_typedef_object() {
		var built = new FromTypeDefExample({test: 1, bar: 1});
		Assert.equals(1, built.test);
	}

	public function test_fromTypeDef_from_typedef_class_like() {
		var built = new FromTypeDefExample2({test: 1, bar: 1});
		Assert.equals(1, built.test);
	}
}
