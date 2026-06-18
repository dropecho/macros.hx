# dropecho.macros

A small Haxe library of compile-time build macros that generate constructors and fields
onto a class at build time. Everything runs at compile time, so the library ships no
runtime code of its own — only the code it generates.

## Install

```bash
haxelib install dropecho.macros
```

## Usage

Attach a macro to a class with `@:build`.

### `Constructor.fromFields`

Generate a constructor from the class's variable fields. Each field becomes a constructor
argument that is assigned to `this`.

```haxe
@:build(dropecho.macros.Constructor.fromFields(true))
class Point {
	public var x:Int;
	public var y:Int;
}

new Point(1, 2); // x = 1, y = 2
```

### `Constructor.fromArgs`

Fill in an empty constructor's body and create matching fields from its arguments.

```haxe
@:build(dropecho.macros.Constructor.fromArgs(true))
class Point {
	public function new(x:Int, y:Int);
}
```

### `Constructor.fromTypeDef`

Build a class (and a static `build` function) from a single configuration-object argument.
The config's fields are copied onto the class and assigned in the constructor.

```haxe
class Config {
	public var x:Int;
	public var y:Int;
}

@:build(dropecho.macros.Constructor.fromTypeDef(true))
class Point {
	public function new(config:Config);
}
```

The boolean argument on each macro controls whether the generated fields are public.

## Development

```bash
npm test   # run the utest suite (via dropecho.testing)
```

Tests are auto-discovered: any `test/**/*Tests.hx` class extending `utest.Test` is picked
up by `dropecho.testing` — there is no hand-written test main.

## Status

`MakeOptional` and the default-value handling in `Constructor.fromFields` are works in
progress. See **AGENTS.md** for details.

## License

MIT
