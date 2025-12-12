local Pascal = require("pascal.init")

local filename = arg[1]
if not filename then
    print("Usage: lua pascal/main.lua <file.pas>")
    os.exit(1)
end

local file = io.open(filename, "r")
if not file then
    print("Cannot open file: " .. filename)
    os.exit(1)
end

local code = file:read("*a")
file:close()

local parser = Pascal.new()

local status, result = pcall(function() return parser:run(code) end)

if status then
    print("Execution finished. Variables:")
    for k, v in pairs(result) do
        print(k .. " = " .. v)
    end
else
    print(result)
end