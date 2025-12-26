local socket = require("socket")
local Client = {}
Client.__index = Client

function Client.new(host, port, packet_size)
    local self = setmetatable({}, Client)
    self.host = host
    self.port = port
    self.packet_size = packet_size
    self.sock = nil
    self.state = "DISCONNECTED" 
    self.buffer = ""
    self.name = (port == 5123) and "S1" or "S2" -- Имя для логов
    return self
end

function Client:log(msg)
    print(string.format("[%s] %s", self.name, msg))
end

function Client:connect()
    self.sock = socket.tcp()
    self.sock:settimeout(0) -- Неблокирующий режим
    self.sock:connect(self.host, self.port)
    self.state = "CONNECTING"
    self.buffer = ""
    self:log("Connecting...")
end

function Client:process()
    if self.state == "DISCONNECTED" then
        self:connect()
        return nil
    end

    -- Чтение данных из сокета
    local chunk, err, partial = self.sock:receive(8192)
    
    if err == "closed" then
        self:log("Connection closed by server.")
        self.state = "DISCONNECTED"
        return nil
    end

    -- Накапливаем буфер
    if chunk then self.buffer = self.buffer .. chunk end
    if partial then self.buffer = self.buffer .. partial end

    if self.state == "CONNECTING" then
        -- Проверяем, удалось ли подключиться
        local _, write_err = socket.select(nil, {self.sock}, 0)
        if write_err and #write_err > 0 then
            self:log("Connected! Sending Auth...")
            self.sock:send("isu_pt")
            self.state = "WAIT_GRANTED"
        end

    elseif self.state == "WAIT_GRANTED" then
        -- Ждем granted
        if #self.buffer > 0 then
            -- Ищем granted
            local s, e = string.find(self.buffer, "granted")
            
            if s then
                self:log("Auth success! Sending GET...")
                -- Удаляем всё
                self.buffer = "" 
                
                self.sock:send("get")
                self.state = "STREAMING"
            else
                -- Если пришло не granted покажем это
                if #self.buffer > 10 then
                     self:log("Unknown handshake: " .. self.buffer)
                     self.buffer = "" -- Сброс, пробуем снова
                     self.sock:send("isu_pt")
                end
            end
        end

    elseif self.state == "STREAMING" then
        -- Режем буфер на пакеты
        if #self.buffer >= self.packet_size then
            local packet = string.sub(self.buffer, 1, self.packet_size)
            self.buffer = string.sub(self.buffer, self.packet_size + 1)
        
            -- Запрашиваем следующий пакет только когда получили текущий
            self.sock:send("get")
            
            return packet
        end
    end
    
    return nil
end

return Client