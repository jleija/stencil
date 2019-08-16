local liluat = require("liluat")
local m = require("match")

local function build_template(template_text)
	return liluat.compile(template_text)
end

local function render(template, vars)
	return liluat.render(template, vars)
end


local function new_stencil(aux, aliases)
    aux = aux or {}
    aliases = aliases or {}
    aliases.aux = aliases.aux or "aux"
    aliases.V = aliases.V or "V"
    aliases.apply_stencil = aliases.apply_stencil or "apply_stencil"

    local rules = {}

    local apply

	local function template_env(element, captures, aux)
        local env
        if type(element) == "table" then
            assert(not element[aliases.aux], "Key '" .. aliases.aux 
                    .. "' clashes with alias given to auxiliary functions \"namespace\". Use aliases in constructor to override given names.")
            assert(not element[aliases.V], "Key '" .. aliases.V 
                    .. "' clashes with alias given to pattern-captured variables. Use aliases in constructor to override given names.")
            assert(not element[aliases.apply_stencil], "Key '" .. aliases.apply_stencil
                    .. "' clashes with alias used for recursive stencil calls. Use aliases in constructor to override given names.")
            env = element
        else
            env = {}
        end
--        env.self = element   -- TODO: FIXME: liluat stack-overflows with this
        env[aliases.aux] = aux
        env[aliases.V] = captures
        env[aliases.apply_stencil] = apply
        return env
	end

    local function normalize_rule(r)
		local template_text = r[2]
        assert(type(template_text) == "string")
		local template = build_template(template_text)

        return { r[1], template, where = r.where, name = r.name }
    end

    local function rule(r)
        local normal_rule = normalize_rule(r)
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
