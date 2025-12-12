local Pascal = require("pascal.init")

describe("Pascal Interpreter", function()

    it("должен обрабатывать пустую программу", function()
        local parser = Pascal.new()
        local code = [[
            BEGIN
            END.
        ]]
        local vars = parser:run(code)
        assert.is_nil(next(vars)) 
    end)

    it("должен вычислять сложные выражения", function()
        local parser = Pascal.new()
        local code = [[
            BEGIN
                x:= 2 + 3 * (2 + 3);
                y:= 2 / 2 - 2 + 3 * ((1 + 1) + (1 + 1));
            END.
        ]]
        -- x := 2 + 3 * 5 = 17
        -- y := 1 - 2 + 3 * (2 + 2) = -1 + 3 * 4 = -1 + 12 = 11
        local vars = parser:run(code)
        
        assert.are.equal(17, vars["x"])
        assert.are.equal(11, vars["y"])
    end)

    it("должен поддерживать вложенные блоки", function()
        local parser = Pascal.new()
        local code = [[
            BEGIN
                y := 2;
                BEGIN
                    a := 3;
                    a := a;
                    b := 10 + a + 10 * y / 4;
                    c := a - b
                END;
                x := 11;
            END.
        ]]
        -- y = 2
        -- a = 3
        -- b = 10 + 3 + 10 * 2 / 4 = 13 + 20/4 = 13 + 5 = 18
        -- c = 3 - 18 = -15
        -- x = 11
        
        local vars = parser:run(code)
        
        assert.are.equal(2, vars["y"])
        assert.are.equal(3, vars["a"])
        assert.are.equal(18, vars["b"])
        assert.are.equal(-15, vars["c"])
        assert.are.equal(11, vars["x"])
    end)
    
    it("должен игнорировать лишние пробелы и переносы", function()
         local parser = Pascal.new()
         local code = "BEGIN x   := 100; y:=200 END."
         local vars = parser:run(code)
         assert.are.equal(100, vars["x"])
         assert.are.equal(200, vars["y"])
    end)
    
    it("должен работать с унарными операторами", function()
        local parser = Pascal.new()
        local code = "BEGIN x := -5; y := +3; z := x + y END." -- -5 + 3 = -2
        local vars = parser:run(code)
        assert.are.equal(-5, vars["x"])
        assert.are.equal(3, vars["y"])
        assert.are.equal(-2, vars["z"])
    end)

    it("должен падать с ошибкой при использовании неопределенной переменной", function()
        local parser = Pascal.new()
        local code = "BEGIN x := y + 1 END."
        assert.has_error(function() 
            parser:run(code) 
        end, "Pascal Error: Variable not found: y")
    end)

    it("должен падать при наличии запрещенных символов", function()
        local parser = Pascal.new()
        local code = "BEGIN x := 5 $ 5 END."
        assert.has_error(function() 
            parser:run(code) 
        end, "Pascal Error: Unexpected character: $")
    end)

    it("должен падать при синтаксической ошибке (ожидался другой токен)", function()
        local parser = Pascal.new()
        local code = "BEGIN x := 5 ) END."
        assert.has_error(function() 
            parser:run(code) 
        end)
    end)

    it("должен падать, если выражение начинается некорректно (factor error)", function()
        local parser = Pascal.new()
        local code = "BEGIN x := * 5 END."
        assert.has_error(function() 
            parser:run(code) 
        end, "Pascal Error: Unexpected token in factor: MUL")
    end)
end)