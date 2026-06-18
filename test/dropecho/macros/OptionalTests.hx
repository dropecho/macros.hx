package dropecho.macros;

import utest.Assert;

class Point {
	var x:Int;
	var y:Int;

	public function new() {}
}

@:build(dropecho.macros.MakeOptional.OptionalType.optional(Point))
class Foo {
	var z:Int;

	public function new() {}
}

class OptionalTests extends utest.Test {
	public function test_does_not_remove_fields() {
		var baz = new Point();
		var bar = new Foo();
		Assert.notNull(baz);
		Assert.notNull(bar);
	}

	// TODO: assert that fields copied from the source type are made optional
	// once MakeOptional.OptionalType.optional rewrites the build fields.
}
