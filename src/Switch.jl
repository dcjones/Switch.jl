

module Switch

export @switch

macro switch(value, body)
    cases = {}
    bodies = {}

    endlabel = gensym("switchend")

    hasdefault = false
    next_is_default = false
    default_block = {}

    for arg in body.args
        if isa(arg, Expr) && arg.head == :macrocall && arg.args[1] == symbol("@case")
            push!(cases, arg.args[2])
            push!(bodies, {})
            next_is_default = false
        elseif isa(arg, Expr) && arg.head == :macrocall && arg.args[1] == symbol("@default")
            if hasdefault
                error("Multiple default cases in switch statement.")
            end
            hasdefault = true
            next_is_default = true
        elseif !isempty(bodies)
            if isa(arg, Expr) && arg.head == :break
                body = Expr(:symbolicgoto, endlabel)
            else
                body = esc(arg)
            end

            if next_is_default
                push!(default_block, body)
            else
                push!(bodies[end], body)
            end
        end
    end

    labels = [gensym("switchlabel") for _ in 1:length(cases)]

    dispatch = {}
    for (case, label) in zip(cases, labels)
        ex = quote
            if switch_value == $(case)
                $(Expr(:symbolicgoto, label))
            end
        end
        push!(dispatch, ex)
    end

    if hasdefault
        append!(dispatch, default_block)
    end

    labeledbody = {}
    for (body, label) in zip(bodies, labels)
        push!(labeledbody, Expr(:symboliclabel, label))
        push!(labeledbody, body...)
    end

    quote
        begin
            local switch_value = $(esc(value))
            $(dispatch...)
            $(Expr(:symbolicgoto, endlabel))
            $(labeledbody...)
            $(Expr(:symboliclabel, endlabel))
        end
    end
end

end

