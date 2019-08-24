local m = require("match")

local function new_stencil()
    local rules = {}

    local function rule(r)
        table.insert(rules, r)
        return r
    end

    local function apply(element)
        for _, rule in ipairs(rules) do
            local pattern = rule[1]
            local matched, captures = m.match_root(pattern, element)
            if matched and (not rule.where or rule.where(captures, matched)) then
                return rule[2](captures, element)
            end
        end
        return element
    end

    return {
        rule = rule,
        apply = apply
    }
end

return new_stencil
