local Parser = require("src.parser")

describe("Parser Logic", function()

    it("должен проверять правильную checksum", function()
        -- "AB" (65+66=131). 131 % 256 = 131.
        local data = "AB" .. string.char(131)
        assert.is_true(Parser.validate_checksum(data, "TEST"))
    end)

    it("должен проверять неправильную checksum", function()
        local data = "AB" .. string.char(0) -- Неверная сумма
        -- validate_checksum возвращает false
        assert.is_false(Parser.validate_checksum(data, "TEST"))
    end)

    it("должен парсить правильный Type 1", function()
        -- Time: 0 -> 1970-01-01 00:00:00 (с учетом часового пояса будет +часы)
        -- Temp: 25.5
        -- Press: 100
        local body = string.pack(">i8fi2", 0, 25.5, 100)
        
        -- Считаем сумму
        local sum = 0
        for i=1, #body do sum = sum + string.byte(body, i) end
        local packet = body .. string.char(sum % 256)

        local res, err = Parser.parse_type1(packet)
        
        assert.is_nil(err)
        assert.are.equal("25.50", res.temp)
        assert.are.equal(100, res.pressure)
        -- Проверка на наличие даты (формат)
        assert.is_not_nil(res.timestamp:match("%d%d%d%d%-%d%d%-%d%d"))
    end)

    it("должен возвращать ошибку Type 1: неверная длина", function()
        local res, err = Parser.parse_type1("short")
        assert.is_nil(res)
        assert.are.equal("Invalid length", err)
    end)
    
    it("должен возвращать ошибку Type 1: косячная чексумма", function()
        -- 14 нулей (сумма 0), а 15-й байт делаем 1.
        -- 0 != 1, теперь это точно ошибка.
        local packet = string.rep("\0", 14) .. "\1" 
        
        local res, err = Parser.parse_type1(packet)
        assert.is_nil(res)
        assert.are.equal("Checksum error", err)
    end)

    it("должен парсить правильный Type 2", function()
        -- >i8, >i4, >i4, >i4
        local body = string.pack(">i8i4i4i4", 0, 10, 20, 30)
        local sum = 0
        for i=1, #body do sum = sum + string.byte(body, i) end
        local packet = body .. string.char(sum % 256)

        local res, err = Parser.parse_type2(packet)
        assert.is_nil(err)
        assert.are.equal(10, res.x)
    end)

    it("должен возвращать ошибку Type 2: неверная длина", function()
        local res, err = Parser.parse_type2("short")
        assert.are.equal("Invalid length", err)
    end)
    
    it("должен обрабатывать INVALID_DATE", function()
       -- Передаем огромное число
       local date_str = Parser.format_time(99999999999999999)
       assert.are.equal("INVALID_DATE", date_str)
    end)
end)