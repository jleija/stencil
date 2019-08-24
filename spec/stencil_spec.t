describe("stencil with quotes", function()
    local aux = { }
    local m = require("match")
    local N = m.namespace()
    local K = N.keys
    local V = N.vars

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
    it("assembles a quote", function()
        local expr = {
            op = "mul",
            a = {
                    op = "sum",
                    a = 1,
                    b = 2
                },
            b = 5
        }
        local stencil = require("stencil")()

        stencil.rule{
            { op = "mul", K.a, K.b },
            function(v) return `[stencil.apply(v.a)] * [stencil.apply(v.b)] end
        }
        stencil.rule{
            { op = "sum", K.a, K.b },
            function(v) return `[stencil.apply(v.a)] + [stencil.apply(v.b)] end
        }
        stencil.rule{
            m.is_number,
            function(_, x) return x end
        }
        stencil.rule{
            { target = "function", K.expr },
            function(v)
                return terra()
                    return [ stencil.apply(v.expr) ]
                end
            end
        }

        local terra_fn = stencil.apply{target="function", expr = expr}

        assert.is.equal(15, terra_fn())
    end)

--    pending("can generate code for a csv query", function()
        -- TODO: move this test to protocolq 
--        local data_spec = {
--            schema = {
--                fields = {
--                    { name = "id", type = "string" },
--                    { name = "quantity", type = "uint16" }
--                }
--            },
--            query = {
--                select = {
--                    { field = "id" },
--                    { field = "quantity" }
--                }
--            },
--            source = {
--                file = "id-qty.csv"
--            }
--        }
--        local stencil = require("quote_stencil")()
--        local doc = data_spec
--        local reference_query_quote = quote end
--        assert.is.same(reference, stencil.apply(doc))
--    end)
end)
