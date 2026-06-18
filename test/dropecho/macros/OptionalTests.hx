package dropecho.macros;

import utest.Assert;

class Point {
	var x:Int;
	var y:Int;

	public function new() {}
}

@:build(dropecho.macros.MakeOptional.OptionalType.optional(Point))
class Foo {
	public var z:Int = 99;

	public function new() {}
}

class OptionalTests extends utest.Test {
	public function test_keeps_own_fields() {
		var f = new Foo();
		Assert.equals(99, f.z);
	}

	public function test_copies_source_fields_as_optional() {
		var f = new Foo();
		// x and y are copied from Point as Null<Int>; unset, so null.
		Assert.isNull(f.x);
		Assert.isNull(f.y);
	}

	public function test_copied_fields_accept_values() {
		var f = new Foo();
		f.x = 1;
		f.y = 2;
		Assert.equals(1, f.x);
		Assert.equals(2, f.y);
	}
}
