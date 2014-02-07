

module Switch

export @switch

macro switch(value, body)
    cases = {}
    bodies = {}

    for arg in body.args
        if isa(arg, Expr) && arg.head == :macrocall && arg.args[1] == symbol("@case")
            push!(cases, arg.args[2])
            push!(bodies, {})
        elseif !isempty(bodies)
            push!(bodies[end], arg)
        end
    end

    labels = [gensym("switchlabel") for _ in 1:length(cases)]

    dispatch = {}
    for (case, label) in zip(cases, labels)
        ex = quote
            if __switch_value == $(case)
                @goto $(label)
            end
        end
        push!(dispatch, ex)
    end

    labeledbody = {}
    for (body, label) in zip(bodies, labels)
        push!(labeledbody, :(@label $(label)))
        push!(labeledbody, body...)
    end

    quote
        while true
            local switch_value = $(value)
            $(dispatch...)
            $(labeledbody...)
            break
        end
    end
end

end

