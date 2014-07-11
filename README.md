
# Switch.jl

This package defines a C-style switch statement for Julia.

The basic definition uses `@swatch`, `@case`, `@label`, and `break`.

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



