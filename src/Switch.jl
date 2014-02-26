

module Switch

export @switch

macro switch(value, body)
    cases = {}
    bodies = {}

    endlabel = gensym("switchend")

    for arg in body.args
        if isa(arg, Expr) && arg.head == :macrocall && arg.args[1] == symbol("@case")
            push!(cases, arg.args[2])
            push!(bodies, {})
        elseif !isempty(bodies)
            if isa(arg, Expr) && arg.head == :break
                push!(bodies[end], Expr(:symbolicgoto, endlabel))
            else
                push!(bodies[end], esc(arg))
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

