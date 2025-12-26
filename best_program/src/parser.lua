local Parser = {}

function Parser.validate_checksum(data, packet_name)
    if #data < 1 then return false end
    
    local content = data:sub(1, #data - 1)
    local received_sum = string.unpack("I1", data:sub(#data))
    
    local calculated_sum = 0
    for i = 1, #content do
        calculated_sum = calculated_sum + string.byte(content, i)
    end
    calculated_sum = calculated_sum % 256
    
    if calculated_sum ~= received_sum then
        -- Выводим байты только если ошибка
        local hex = ""
        for i=1, #data do hex = hex .. string.format("%02X ", string.byte(data, i)) end
        print(string.format("DEBUG %s: Checksum Fail! Calc=%d, Recv=%d | Bytes: %s", packet_name, calculated_sum, received_sum, hex))
        return false
    end
    
    return true
end

function Parser.format_time(micro_ts)
    local seconds = math.floor(micro_ts / 1000000)
    -- Защита от сбоев даты
    if seconds < 0 or seconds > 32503680000 then -- до 3000 года
        return "INVALID_DATE"
    end
    return os.date("%Y-%m-%d %H:%M:%S", seconds)
end

function Parser.parse_type1(data)
    if #data ~= 15 then return nil, "Invalid length" end
    
    local valid = Parser.validate_checksum(data, "S1")
    
    if not valid then return nil, "Checksum error" end
    
    local ts, temp, press = string.unpack(">i8fi2", data)
    
    return {
        type = "SERVER_1",
        timestamp = Parser.format_time(ts),
        temp = string.format("%.2f", temp),
        pressure = press,
        valid = valid
    }
end

function Parser.parse_type2(data)
    if #data ~= 21 then return nil, "Invalid length" end
    
    local valid = Parser.validate_checksum(data, "S2")
    
    if not valid then return nil, "Checksum error" end
    
    local ts, x, y, z = string.unpack(">i8i4i4i4", data)
    
    return {
        type = "SERVER_2",
        timestamp = Parser.format_time(ts),
        x = x,
        y = y,
        z = z,
        valid = valid
    }
end

return Parser