-- main.lua
package.cpath = package.cpath .. ";.\\?.dll;.\\?\\core.dll"

local Client = require("src.client")
local Parser = require("src.parser")

-- Настройки серверов
local S1_HOST, S1_PORT, S1_SIZE = "95.163.237.76", 5123, 15
local S2_HOST, S2_PORT, S2_SIZE = "95.163.237.76", 5124, 21

local client1 = Client.new(S1_HOST, S1_PORT, S1_SIZE)
local client2 = Client.new(S2_HOST, S2_PORT, S2_SIZE)

local file = io.open("data_log.txt", "a+")
if not file then error("Cannot open file") end

print("Starting data collection. Press Ctrl+C to stop.")

-- Бесконечный цикл
while true do
    -- Обработка клиента 1
    local raw1 = client1:process()
    if raw1 then
        local data, err = Parser.parse_type1(raw1)
        if data then
            local line = string.format("[%s] %s | Temp: %s | Press: %d\n", 
                data.type, data.timestamp, data.temp, data.pressure)
            file:write(line)
            file:flush() -- Принудительная запись на диск
            print(line:sub(1, -2))
        elseif err then
            print("Error S1: " .. err)
        end
    end

    -- Обработка клиента 2
    local raw2 = client2:process()
    if raw2 then
        local data, err = Parser.parse_type2(raw2)
        if data then
            local line = string.format("[%s] %s | X: %d | Y: %d | Z: %d\n", 
                data.type, data.timestamp, data.x, data.y, data.z)
            file:write(line)
            file:flush()
            print(line:sub(1, -2))
        elseif err then
            print("Error S2: " .. err)
        end
    end
    
    -- Небольшая пауза, чтобы не грузить проц на 100%
    local socket = require("socket")
    socket.sleep(0.001)
end