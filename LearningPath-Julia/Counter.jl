module Counter
export count_heads

    function count_heads(n)
        c::Int = 0
        for i = 1:n
            c += rand(Bool)
        end
        return c
    end

end