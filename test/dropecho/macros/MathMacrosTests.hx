package dropecho.macros;

import utest.Assert;
import dropecho.macros.MathMacros;

class MathMacrosTests extends utest.Test {
	public function test_pow_2() {
		Assert.equals(Math.pow(2, 2), MathMacros.pow(2, 2));
	}

	public function test_pow_3() {
		Assert.equals(Math.pow(2, 3), MathMacros.pow(2, 3));
	}

	public function test_pow_12() {
		Assert.equals(Math.pow(2, 12), MathMacros.pow(2, 12));
	}

	public function test_pow_with_var() {
		var t = 2;
		Assert.equals(Math.pow(t, 2), MathMacros.pow(t, 2));
	}

	public function test_pow_compound_arg_evaluated_once() {
		// `1 - t` is bound once; the unrolled product must still equal Math.pow.
		var t = 0.25;
		Assert.floatEquals(Math.pow(1 - t, 4), MathMacros.pow(1 - t, 4));
	}
	// Non-integer exponents are intentionally unsupported by the unrolling macro.
}
