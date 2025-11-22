local Cow = require("cow.init")

-- получаем имя файла из аргументов командной строки
local filename = arg[1]

if not filename then
    print("Usage: lua cow/main.lua <file.cow>")
    os.exit(1)
end

-- открываем файл
local file = io.open(filename, "r")
if not file then
    print("Error: Could not open file " .. filename)
    os.exit(1)
end

-- читаем весь код
local code = file:read("*a")
file:close()

-- запускаем
local interpreter = Cow.new()
interpreter:run(code)
print()