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
end)
