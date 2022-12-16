package dropecho.macros;

import haxe.rtti.Rtti;
import massive.munit.Assert;

@:build(dropecho.macros.Constructor.fromParams())
@:rtti
class BuiltPriv {
	public function new(test:Int = 1, bar:Int = 2);
}

@:build(dropecho.macros.Constructor.fromParams(true))
class BuiltPub {
	public function new(test:Int = 1, bar:Int = 2);
}

@:build(dropecho.macros.Constructor.fromFields())
class FromFieldsPrivateExample {
	var test:Int = 1;
	var bar:Int = 2;
}

@:struct
@:build(dropecho.macros.Constructor.fromFields(true))
class ConfigExample {
	public var test:Int = 1;
	public var bar:Int = 1;
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
	public function new(banana:ConfigExample);
}

@:build(dropecho.macros.Constructor.fromTypeDef(true))
class FromTypeDefExample {
	public function new(foo:ConfigDef);
}

@:build(dropecho.macros.Constructor.fromTypeDef(true))
class FromTypeDefExample2 {
	public function new(naz:ConfigDef2);
}

class ConstructorTest {
	@Test
	public function should_build_private_fields_from_contructor_param() {
		var built = new BuiltPub();
		var typeInfo = Rtti.getRtti(BuiltPriv);
		Assert.isTrue(typeInfo.fields[0].isPublic == false);
		Assert.areEqual(1, Reflect.field(built, "test"));
	}

	@Test
	public function should_build_public_fields_from_contructor_param() {
		var built = new BuiltPub();

		Assert.areEqual(1, built.test);
	}

	@Test
	public function should_build_constructor_from_fields_private_fields() {
		//     var built = new FromFieldsPrivateExample();
		//     var typeInfo = Rtti.getRtti(BuiltPriv);
		//     Assert.isTrue(typeInfo.fields[0].isPublic == false);
		//     Assert.areEqual(1, Reflect.field(built, "test"));
	}

	@Test
	public function should_build_constructor_from_config_class() {
		//     var built = new FromClassExample(new ConfigExample());
		//     Assert.areEqual(1, built.test);
	}

	@Test
	public function should_build_constructor_from_config_object() {
		var built = new FromTypeDefExample({test: 1, bar: 1});
		Assert.areEqual(1, built.test);
	}

	@Test
	public function should_build_constructor_from_config_object_2() {
		var built = new FromTypeDefExample2({test: 1, bar: 2});
		Assert.areEqual(1, built.test);
	}

	@Test
	public function should_build_from_config_object_build_static() {
		var built = FromTypeDefExample2.build(2, 1);
		Assert.areEqual(1, built.test);
	}
}
