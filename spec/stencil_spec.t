local mm = require'mm'
local m = require("match")

describe("stencil", function()
    local stencil = require("stencil")

    it("how to compare quotes", function()
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
    end)
    it("copies input element with empty template", function()
        local templates = {}
        local apply_stencil = stencil(templates)
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
        local apply_stencil = stencil(templates)
        local doc = { a = 1, b = 2}
        assert.is.equal(1, apply_stencil(doc))
    end)
    it("applies stencil recursively", function()
        local N = m.namespace()
        local K = N.keys
        local V = N.vars

        local apply_stencil
        local templates = {
            {
                name = "top",
                { { K.a, K.b }, function(capture) 
                                    return { C = apply_stencil(capture.b) } 
                                end }
            },
            {
                name = "mid",
                { { K.c }, function(capture)
                                return { es = apply_stencil(capture.c) } 
                           end }
            },
            {
                name = "bottom",
                { 1, "uno" },
                { 2, "dos" },
                { 3, "tres"}
            }
        }
        apply_stencil = stencil(templates)
        local doc = { a = 1, b = { c = 3 } }
        assert.is.same({ C = { es = "tres" } }, apply_stencil(doc))
    end)
end)
