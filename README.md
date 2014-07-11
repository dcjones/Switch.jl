
# Switch.jl

[![Build Status](https://api.travis-ci.org/dcjones/Switch.jl.svg?branch=master)](https://travis-ci.org/dcjones/Switch.jl) [![Coverage Status](https://img.shields.io/coveralls/dcjones/Switch.jl.svg)](https://coveralls.io/r/dcjones/Switch.jl?branch=master)


This package defines a C-style switch statement for Julia.

The basic definition uses `@switch`, `@case`, `@default`, and `break`.

```julia

using Switch

function f(x)
    @switch x begin
        @case 1
            print("one")
            break

        @case 2
            println("two")
            break

        @case 3
            println("three")
            break

        @default
            println("Can't count that high.")
    end
end

f(2) # → two
f(10) # → Can't count that high.
```

Without the `break` statements, case blocks fall through to the next block.

```julia

using Switch

function f(x)
    @switch x begin
        @case 1
            print("one")

        @case 2
            println("two")

        @case 3
            println("three")

        @default
            println("Can't count that high.")
    end
end

f(2) # → two, three, Can't count that high.
f(10) # → Can't count that high.
```



