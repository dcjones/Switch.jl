#!/usr/bin/env julia

module TestSwitch

using FactCheck
using Switch

# basic switch constructs
function switch_with_fallthrough(x::Int)
    xs = Int[]
    @switch x begin
        @case 1
            push!(xs, 1)

        @case 2
            push!(xs, 2)

        @case 3
            push!(xs, 3)

        @default
            push!(xs, 4)
    end
    return xs
end


# fallthrough with weird default case placement
function switch_with_leading_default(x::Int)
    xs = Int[]
    @switch x begin
        @default
            push!(xs, 4)

        @case 1
            push!(xs, 1)

        @case 2
            push!(xs, 2)

        @case 3
            push!(xs, 3)
    end
    return xs
end


# switching with expressions
function switch_with_expressions(x::Int)
    xs = Int[]
    @switch x + 1 begin
        @case 1 + 1
            push!(xs, 1)

        @case 2 + 1
            push!(xs, 2)

        @case 3 + 1
            push!(xs, 3)

        @default
            push!(xs, 4)
    end
    return xs
end

# switching with breaks
function switch_with_break(x::Int)
    xs = Int[]
    @switch x begin
        @case 1
            push!(xs, 1)
            break

        @case 2
            push!(xs, 2)
            break

        @case 3
            push!(xs, 3)
            break

        @default
            push!(xs, 4)
    end
    return xs
end

facts("switching") do
    @fact switch_with_fallthrough(1) => Int[1, 2, 3, 4]
    @fact switch_with_fallthrough(3) => Int[3, 4]
    @fact switch_with_fallthrough(100) => Int[4]

    @fact switch_with_leading_default(1) => Int[1, 2, 3]
    @fact switch_with_leading_default(3) => Int[3]
    @fact switch_with_leading_default(100) => Int[4, 1, 2, 3]

    @fact switch_with_expressions(1) => Int[1, 2, 3, 4]
    @fact switch_with_expressions(3) => Int[3, 4]
    @fact switch_with_expressions(100) => Int[4]

    @fact switch_with_break(1) => Int[1]
    @fact switch_with_break(3) => Int[3]
    @fact switch_with_break(100) => Int[4]
end

exitstatus()

end

