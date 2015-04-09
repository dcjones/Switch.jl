

module Switch

export @switch

macro switch(value, body)
    cases = Any[]
    bodies = Any[]

    endlabel = gensym("switchend")

    hasdefault = false
    next_is_default = false
    default_label = nothing
    labels = Symbol[]

    for arg in body.args
        if isa(arg, Expr) && arg.head == :macrocall && arg.args[1] == symbol("@case")
            push!(cases, arg.args[2])
            push!(bodies, Any[])
            push!(labels, gensym("switchlabel"))
            next_is_default = false
        elseif isa(arg, Expr) && arg.head == :macrocall && arg.args[1] == symbol("@default")
            if hasdefault
                error("Multiple default cases in switch statement.")
            end
            hasdefault = true
            push!(cases, nothing)
            push!(bodies, Any[])
            default_label = gensym("switchlabel")
            push!(labels, default_label)
            next_is_default = true
        elseif !isempty(bodies)
            if isa(arg, Expr) && arg.head == :break
                body = Expr(:symbolicgoto, endlabel)
            else
                body = esc(arg)
            end
            push!(bodies[end], body)
        end
    end

    dispatch = Any[]
    for (case, label) in zip(cases, labels)
        if label == default_label
            continue
        end
        ex = quote
            if switch_value == $(case)
                $(Expr(:symbolicgoto, label))
            end
        end
        push!(dispatch, ex)
    end

    if hasdefault
        push!(dispatch, Expr(:symbolicgoto, default_label))
    end

    labeledbody = Any[]
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

