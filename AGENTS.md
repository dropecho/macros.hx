# AGENTS.md — dropecho.macros

Single source of truth for all AI agents working on this project.

## Agent Instructions

- **Always use the `haxe` skill** when reading or writing any `.hx` or `.hxml` file.
- **Always use the Haxe LSP** (`LSP` tool) for navigating code — go-to-definition, find references, hover types — before grepping or reading files manually.
- **Never co-author or co-sign commits.** Do not add `Co-Authored-By` trailers, `Signed-off-by` lines, or any other attribution/sign-off trailers to commit messages.
- **Never add section/region divider comments** (e.g. `// ── Foo ──`, `// --- Foo ---`, `#region`). Organize code with ordering and doc comments instead.

---

## Project Overview

**dropecho.macros** (`haxelib: dropecho.macros`, npm: `@dropecho/macros`) is a small
library of compile-time build macros for Haxe — helpers that generate constructors and
fields onto a class at build time. Because everything runs at compile time, the library
ships no runtime code of its own.

- **Version:** 0.0.1
- **License:** MIT
- **Targets:** any Haxe target (the generated code is plain Haxe; the test suite runs on JS/Node)
- **Test runner:** `dropecho.testing` (auto-discovery) over `utest`
- **Source root:** `src/`  · **Tests root:** `test/`
- **Releases:** automated via `semantic-release` (+ `semantic-release-haxelib`)
- **Dependency:** `tink_macro` (used for AST helpers in the build macros)

---

## Source Modules

| Module | Path | Description |
|---|---|---|
| `Constructor` | `src/dropecho/macros/Constructor.hx` | `@:build` macros that generate constructors/fields: `fromArgs` (fill an empty constructor's body + fields from its args), `fromFields` (build a constructor from the class's variable fields), `fromTypeDef` (build a class + static `build` from a single config-object argument) |
| `TypeBuildingMacros` | `src/dropecho/macros/TypeBuildingMacros.hx` | Shared compile-time helpers: `isEmpty`, `isConstant`, `createFieldFromArg`, and the `initLocals` macro used as the generated constructor body |
| `MakeOptional` | `src/dropecho/macros/MakeOptional.hx` | **WIP.** `OptionalType.optional` — intended to copy another type's fields onto the building class as optional fields; currently returns the class unchanged while the rewrite is worked out |

All `Constructor`/`MakeOptional` functions are `macro` functions, so the classes compile
to nothing on a runtime target — only the code they *generate* runs. Macro-only imports
are guarded with `#if macro`; the class declarations stay unguarded so generated code can
still resolve them (e.g. `TypeBuildingMacros.initLocals()`).

---

## Directory Layout

```
src/dropecho/macros/         # library source (all compile-time)
  Constructor.hx             # constructor/field build macros
  TypeBuildingMacros.hx      # shared compile-time helpers + initLocals
  MakeOptional.hx            # WIP optional-fields build macro
test/                        # utest cases, auto-discovered by filename (*Tests.hx)
  dropecho/macros/
    ConstructorTests.hx      # build-macro example classes + assertions
    OptionalTests.hx
.dropecho.testing.json       # test-runner config (root_package, hxml)
artifacts/                   # compiled test output
```

There is no hand-written test main/suite: `dropecho.testing` generates the entry point
and registers every `*Tests.hx` class on the classpath (note the plural — `Test.hx`
files are **not** discovered).

---

## Build & Test

Prefer `npm` scripts over invoking Haxe tools directly.

```bash
# Run tests (builds the JS target and runs it on Node, via the runner)
npm test             # → haxelib run dropecho.testing
```

- `test.hxml` lists libs/targets only — **no `-main`**. The `dropecho.testing` runner
  injects `--main dropecho.testing.AutoTest`, then runs each target it finds in the hxml
  (`-js artifacts/js_test.cjs` on Node).
- The runner auto-detects the test lib: `utest` is selected because `buddy` is **not** on
  the classpath. Do not re-add `buddy` to `test.hxml` or detection flips back to it.
- Type-check a source change quickly with `haxe test.hxml --no-output` before running.

---

## Key Conventions

- Tests are `utest` cases: each class is named `*Tests.hx`, `extends utest.Test`, with
  `test_`-prefixed methods and `utest.Assert`.
- Build-macro behavior is tested by declaring example classes with `@:build(...)` in the
  test file, constructing them, and asserting on the generated fields/constructor.
- Macro-only imports/usings are wrapped in `#if macro`; macro classes themselves are not,
  so generated code can resolve them on the runtime target.
- No coverage/instrument: a compile-time-only library has no runtime code to instrument,
  so the `instrument` block is omitted from `.dropecho.testing.json`.

---

## Status / WIP

This repo is mid-feature on the `optional_type_builder` branch:

- `MakeOptional.OptionalType.optional` is unfinished (resolves the source type's fields but
  returns the class unchanged). See its `TODO`.
- `Constructor.fromFields` does not yet restore a field's default value when the matching
  constructor arg is omitted (the disabled `value:` line). See the `TODO` in
  `ConstructorTests.hx` for the scenarios to re-enable once the macros stabilise.
