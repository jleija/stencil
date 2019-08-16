local liluat = require("liluat")
local m = require("match")

local function build_template(template_text)
	return liluat.compile(template_text)
end

local function render(template, vars)
	return liluat.render(template, vars)
end


local function new_stencil(aux)
    aux = aux or {}
    local rules = {}

    local apply

	local function template_env(element, captures, aux)
        assert(not element.aux, "aux will be used to supporting functions")
        assert(not element.V, "V will be used for pattern-captured variables")
        assert(not element.apply_stencil, "apply_stencil will be used for recursive stencil calls")
        element.aux = aux
        element.V = captures
        element.apply_stencil = apply
        return element
	end

    local function normalize_rule(r)
		local template_text = r[2]
        assert(type(template_text) == "string")
		local template = build_template(template_text)

        return { r[1], template, where = r.where, name = r.name }
    end

    local function rule(r)
        local normal_rule = normalize_rule(r)
        assert(normal_rule, "Could not build rule " .. #rules + 1)
        table.insert(rules, normal_rule)
        return normal_rule
    end

    function apply(element)
        for _, rule in ipairs(rules) do
            local pattern = rule[1]
            local matched, captures = m.match_root(pattern, element)
            if matched and (not rule.where or rule.where(captures, matched)) then
                local vars = template_env(element, captures, aux)
                local template = rule[2]
                local text = render(template, vars)
                return text
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
