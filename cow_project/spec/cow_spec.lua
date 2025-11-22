local Cow = require("cow.init")

describe("Интерпретатор COW", function()
    
    it("должен увеличивать значение (MoO)", function()
        local cow = Cow.new()
        cow:run("MoO MoO") 
        assert.are.equal(2, cow:get_val())
    end)

    it("должен выполнять циклы (MOO = старт, moo = конец)", function()
        local cow = Cow.new()
        -- ставим 3.
        -- MOO (начало)
        -- MOo (-1)
        -- moo (конец -> назад)
        local code = "MoO MoO MoO MOO MOo moo"
        cow:run(code)
        assert.are.equal(0, cow:get_val())
    end)

    it("должен пропускать цикл, если сразу 0", function()
        local cow = Cow.new()
        -- 0 изначально. 
        -- MOO -> видит 0 -> прыгает за moo.
        -- внутри цикла увеличение, если цикл выполнится, будет 1.
        local code = "MOO MoO moo"
        cow:run(code)
        assert.are.equal(0, cow:get_val())
    end)

    it("OOM должен выводить число ", function()
        local cow = Cow.new()
        -- 65. OOM должен вывести "65", а не "A".
        local code = ""
        for i=1,65 do code = code.."MoO " end
        code = code .. "OOM"
        
        local result = cow:run(code)
        assert.are.equal("65", result)
    end)

    it("Moo должен выводить символ, если не 0", function()
        local cow = Cow.new()
        -- 65 (A). Moo должен вывести A а не 65.
        local code = ""
        for i=1,65 do code = code.."MoO " end
        code = code .. "Moo"
        
        local result = cow:run(code)
        assert.are.equal("A", result)
    end)
    
    it("mOO должно падать при коде 3", function()
        local cow = Cow.new()
        cow:set_val(3) 
        -- пытаемся выполнить код 3 через mOO
        -- а нельзя
        assert.has_error(function() cow:run("mOO") end)
    end)

    it("mOO должно завершать программу при невалидном коде", function()
        local cow = Cow.new()
        cow:set_val(99) -- несуществующая команда
        -- должно просто выйти без ошибки
        local res = cow:run("mOO")
        assert.are.equal("", res) 
    end)

    it("oom должен читать число (буфер)", function()
        local cow = Cow.new()
        cow:run("oom", {123})
        assert.are.equal(123, cow:get_val())
    end)
    
    it("oom должен читать число (io.read)", function()
        local cow = Cow.new()
        local old = io.read
        io.read = function() return 555 end
        cow:run("oom")
        io.read = old
        assert.are.equal(555, cow:get_val())
    end)

    it("Moo должен читать символ (io.read) если 0", function()
        local cow = Cow.new()
        local old = io.read
        io.read = function() return "Z" end
        cow:run("Moo") -- При 0 читает char
        io.read = old
        assert.are.equal(90, cow:get_val())
    end)
    
    it("MMM работает с регистром", function()
        local cow = Cow.new()
        cow:run("MoO MMM OOO MMM") -- 1 -> Reg -> 0 -> 1
        assert.are.equal(1, cow:get_val())
    end)

    it("mOo (назад) и moO (вперед)", function()
        local cow = Cow.new()
        cow:run("moO MoO mOo") -- Вперед, +1, Назад
        assert.are.equal(0, cow:get_val()) -- Мы вернулись в 1 (где 0)
        assert.are.equal(1, cow.ptr)
    end)
    it("должен выдавать ошибку при незакрытом цикле (MOO без moo)", function()
        local cow = Cow.new()
        -- Открываем цикл, но не закрываем его
        assert.has_error(function() 
            cow:run("MOO") 
        end)
    end)
end)