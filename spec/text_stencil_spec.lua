describe("text_stencil", function()
    local function double(x) return x * 2 end
    local aux = {   -- auxiliary/helper functions
        double = double
    }
    local m = require("match")
    local N = m.namespace()
    local K = N.keys

    it("copies input element when no template is matched", function()
        local stencil = require("text_stencil")()
        local doc = { a = 1 }
        assert.is.equal(doc, stencil.apply(doc))
    end)
    it("errors out with an invalid template", function()
        local stencil = require("text_stencil")()
        stencil.rule{
           { a = m.value }, "A:{{{}}}"
        }
        local doc = { a = 1 }
        assert.is.error(function() stencil.apply(doc) end)
    end)
    pending("applies simple template with non-table matched element and access self", function()
        -- TODO: submit a fix to liluat or use another template engine
        local stencil = require("text_stencil")(aux)
        stencil.rule{
           5, "x:{{= self }}"
        }
        local doc = 5
        assert.is.equal("x:5", stencil.apply(doc))
    end)
    it("applies simple template with non-table matched element and use auxiliary functions", function()
        local stencil = require("text_stencil")(aux)
        stencil.rule{
           5, "x:{{= aux.double(2) }}"
        }
        local doc = 5
        assert.is.equal("x:4", stencil.apply(doc))
    end)
    it("applies simple template with matched element", function()
        local stencil = require("text_stencil")()
        stencil.rule{
           { a = m.value }, "A:{{= a }}"
        }
        local doc = { a = 1 }
        assert.is.equal("A:1", stencil.apply(doc))
    end)
    it("applies simple template with bound match variable", function()
        local stencil = require("text_stencil")()
        stencil.rule{
           { K.a }, "A:{{= V.a }}"
        }
        local doc = { a = 1 }
        assert.is.equal("A:1", stencil.apply(doc))
    end)
    it("can call auxiliary functions from the template", function()
        local stencil = require("text_stencil")(aux)
        stencil.rule{
           { K.a }, "A:{{= aux.double(V.a) }}"
        }
        local doc = { a = 1 }
        assert.is.equal("A:2", stencil.apply(doc))
    end)
    it("can apply stencil recursively", function()
        local stencil = require("text_stencil")(aux)
        stencil.rule{
           { K.a }, "A:{{= aux.double(V.a) }}"
        }
        stencil.rule{
           { K.b }, "B:[{{= apply_stencil(V.b) }}]"
        }
        local doc = { b = { a = 1 } }
        assert.is.equal("B:[A:2]", stencil.apply(doc))
    end)
    it("supports customization of context/environment to avoid name clashes", function()
        local aliases = {
            aux = "utils",
            V = "captures",
            apply_stencil = "apply_templates"
        }
        local stencil = require("text_stencil")(aux, aliases)
        stencil.rule{
           { K.a }, "A:{{= utils.double(captures.a) }}"
        }
        stencil.rule{
           { K.b }, "B:[{{= apply_templates(captures.b) }}]"
        }
        local doc = { b = { a = 1 } }
        assert.is.equal("B:[A:2]", stencil.apply(doc))
    end)
    it("errors out when an element key clashes with one of the internal values", function()
        local stencil = require("text_stencil")()
        stencil.rule{
           { aux = m.value }, "A:{{= a }}"
        }
        local doc = { aux = 1 }
        assert.is.error(function() stencil.apply(doc) end, 
            [[Key 'aux' clashes with alias given to auxiliary functions "namespace". Use aliases in constructor to override given names.]])
    end)
end)
