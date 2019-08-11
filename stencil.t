local m = require("match")

local function new_stencil()
    local uninitialized_apply_stencil_fn = function()
        error("Stencil application without templates. Invoke make_stencil with templates before making this call")
    end

    local apply_stencil = uninitialized_apply_stencil_fn

    local function make_stencil(templates)
        -- this is not technically an error because everything gets reset
        -- safetly but it might indicate a misused of the library
        assert(apply_stencil == uninitialized_apply_stencil_fn,
                "Shouldn't invoke stencil.make() twice on the same instance")

        local templates_by_name = {}
        local templates_by_index = {}
        for i, t in ipairs(templates) do
            local match_fn
            if type(t) == "table" then
                if t[1] and t.name then         -- assume a match table
                    match_fn = m.matcher(t)
                    templates_by_name[t.name] = match_fn
                end
            end
            match_fn = match_fn or function(x) return x == t and t or nil end
            table.insert(templates_by_index, match_fn)
        end


        local current_element

        apply_stencil = function(element)
            local tmp = current_element
            current_element = element
            local res
            local t = templates_by_name[element] 

            if t then
                res = t(element)
            else
                for i, t in ipairs(templates_by_index) do
                    res = t(element)
                    if res ~= nil then break end
                end
            end

            if res == nil then
                res = element
            end

            current_element = tmp
            return res
        end

        return apply_stencil
    end

    local function apply_stencil_proxy(element)
        return apply_stencil(element)
    end

    return {
        make = make_stencil,
        apply = apply_stencil_proxy
    }
end

return new_stencil
