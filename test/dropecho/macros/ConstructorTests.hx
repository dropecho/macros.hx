package dropecho.macros;

import haxe.rtti.Rtti;
import buddy.BuddySuite;

using buddy.Should;

@:build(dropecho.macros.Constructor.fromParams())
@:rtti
class FromParamsPrivateExample {
	public function new(test:Int = 1, bar:Int = 2);
}

@:build(dropecho.macros.Constructor.fromParams(true))
@:rtti
class FromParamsPublicExample {
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

class ConstructorTests extends BuddySuite {
	public function new() {
		describe('when building from params', {
			it('should make the fields private when true not passed', {
				var typeInfo = Rtti.getRtti(FromParamsPrivateExample);
				typeInfo.fields[0].isPublic.should.be(false);
			});

			it('should set the private fields to the default value', {
				var built = new FromParamsPrivateExample();
				Reflect.field(built, "test").should.be(1);
			});

			it('should make the fields public when true is passed', {
				var typeInfo = Rtti.getRtti(FromParamsPublicExample);
				typeInfo.fields[0].isPublic.should.be(true);
			});

			it('should set the fields to the default value', {
				var built = new FromParamsPublicExample();
				built.test.should.be(1);
			});
		});

		//     describe('when building from fields', {
		//       it('should set add a constructor with the fields as params', {
		//         var built = new FromFieldsExample(1, 2);
		//         built.bar.should.be(2);
		//         built.test.should.be(1);
		//       });
		//
		//       it('should set the fields to default when not passed.', {
		//         var built = new FromFieldsExample();
		//         built.bar.should.be(1);
		//         built.test.should.be(1);
		//       });
		//     });

		describe('when building from typedef / config obj', {
			describe('when building from class', {
				it('should add the fields from the object', {
					var built = new FromClassExample(new FromFieldsExample());
					built.test.should.be(1);
				});

				it('should allow object to be optional in constructor', {
					var built = new FromClassExample();
					built.test.should.be(1);
				});

				it('should add a build function that has the type broken out', {
					var built = FromClassExample.build(1, null);
					built.test.should.be(1);
				});

				it('should add a build function that has the type broken out with optional args', {
					var built = FromClassExample.build();
					built.test.should.be(1);
				});
			});
			describe('when building from typedef object', {
				it('should add the fields from the typedef', {
					var built = new FromTypeDefExample({test: 1, bar: 1});
					built.test.should.be(1);
				});
			});
			describe('when building from typedef class like', {
				it('should add the fields from the typedef', {
					var built = new FromTypeDefExample2({test: 1, bar: 1});
					built.test.should.be(1);
				});
			});
		});
	}
}
