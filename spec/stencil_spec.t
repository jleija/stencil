local mm = require'mm'
local m = require("match")

describe("stencil", function()
    before_each(function()
        stencil = require("stencil")()
    end)

    it("how to compare quotes", function()  -- {{{
        local x = quote print("hello") end
        local y = quote print("hello") end
        x.tree.offset = nil
        y.tree.offset = nil
        x.tree.statements[1].offset = nil
        y.tree.statements[1].offset = nil
        x.tree.statements[1].linenumber = nil
        y.tree.statements[1].linenumber = nil
        x.tree.statements[1].value.offset = nil
        y.tree.statements[1].value.offset = nil
        x.tree.statements[1].value.linenumber = nil
        y.tree.statements[1].value.linenumber = nil
        x.tree.statements[1].arguments[1].offset = nil
        y.tree.statements[1].arguments[1].offset = nil
        x.tree.statements[1].arguments[1].linenumber = nil
        y.tree.statements[1].arguments[1].linenumber = nil
        assert.is.same( x.tree.statements[1], y.tree.statements[1])
    end)    -- }}}
    it("copies input element with empty template", function()
        local templates = {}
        local apply_stencil = stencil.make(templates)
        local doc = { a = 1, b = 2}
        assert.is.same(doc, apply_stencil(doc))
    end)
    it("applies match and returns a simple substitution", function()
        local N = m.namespace()
        local K = N.keys
        local V = N.vars
        local templates = {
            {
                name = "test",
                { { K.a }, V.a }
            }
        }
        stencil.make(templates)
        local doc = { a = 1, b = 2}
        assert.is.equal(1, stencil.apply(doc))
    end)
    it("applies stencil recursively", function()
        local N = m.namespace()
        local K = N.keys
        local V = N.vars

        local templates = {
            {
                name = "top",
                { { K.a, K.b }, function(capture) 
                                    return { C = stencil.apply(capture.b) } 
                                end }
            },
            {
                name = "mid",
                { { K.c }, function(capture)
                                return { es = stencil.apply(capture.c) } 
                           end }
            },
            {
                name = "bottom",
                { 1, "uno" },
                { 2, "dos" },
                { 3, "tres"}
            }
        }
        apply_stencil = stencil.make(templates)
        local doc = { a = 1, b = { c = 3 } }
        assert.is.same({ C = { es = "tres" } }, apply_stencil(doc))
    end)
    it("applies stencil recursively via var transforms", function()
        local N = m.namespace()
        local K = N.keys
        local V = N.vars
        local T = N.transforms

        local templates = {
            {
                name = "top",
                { { K.a, K.b }, { C = T.b(stencil.apply) } }
            },
            {
                name = "mid",
                { { K.c }, { es = T.c(stencil.apply) } }
            },
            {
                name = "bottom",
                { 1, "uno" },
                { 2, "dos" },
                { 3, "tres"}
            }
        }
        stencil.make(templates)
        local doc = { a = 1, b = { c = 3 } }
        assert.is.same({ C = { es = "tres" } }, stencil.apply(doc))
    end)
    it("fails when trying to apply stencil without having call make with templates", function()
        assert.is.error(function() stencil.apply({}) end, 
            "Stencil application without templates. Invoke make_stencil with templates before making this call")
    end)
    it("fails when trying to make stencil twice", function()
        stencil.make({})
        assert.is.error(function() stencil.make({}) end, "Shouldn't invoke stencil.make() twice on the same instance")
    end)
end)
