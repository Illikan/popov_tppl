-- spec/client_spec.lua
-- 1. Настраиваем пути к DLL (обязательно первая строка)
package.cpath = package.cpath .. ";.\\?.dll;.\\?\\core.dll"

local Client = require("src.client")
local socket = require("socket")

describe("Client State Machine", function()
    local mock_sock
    local client

    before_each(function()
        -- Создаем мок-сокет
        mock_sock = {
            connect = function() return 1 end,
            settimeout = function() end,
            send = function() return 1 end,
            receive = function() return nil, "timeout" end,
            close = function() end
        }

        -- Подменяем глобальный socket.tcp
        socket._original_tcp = socket.tcp
        socket.tcp = function() return mock_sock end
        socket.select = function() return nil, {mock_sock} end

        client = Client.new("host", 1234, 10)
    end)

    after_each(function()
        if socket._original_tcp then
            socket.tcp = socket._original_tcp
        end
    end)

    it("должен подключаться", function()
        client:process() 
        assert.are.equal("CONNECTING", client.state)
    end)

    it("должен отправлять авторизацию", function()
        client.state = "CONNECTING"
        client.sock = mock_sock -- мокаем сокет
        
        local sent_data
        mock_sock.send = function(self, data) sent_data = data end
        
        client:process()
        
        assert.are.equal("isu_pt", sent_data)
        assert.are.equal("WAIT_GRANTED", client.state)
    end)

    it("должен обрабатывать 'granted'", function()
        client.state = "WAIT_GRANTED"
        client.sock = mock_sock -- Мокаем сокет
        
        mock_sock.receive = function() return "granted" end
        local sent_data
        mock_sock.send = function(self, data) sent_data = data end

        client:process() -- Читает
        client:process() -- Обрабатывает
        
        assert.are.equal("get", sent_data)
        assert.are.equal("STREAMING", client.state)
    end)
    
    it("должен игнорировать мусор при рукопожатии", function()
        client.state = "WAIT_GRANTED"
        client.sock = mock_sock -- Мокаем сокет
        
        client.buffer = "some_garbage_string_very_long"
        
        local sent_data
        mock_sock.send = function(self, data) sent_data = data end
        
        client:process()
        
        assert.are.equal("isu_pt", sent_data)
        assert.are.equal("", client.buffer)
    end)

    it("должен нарезать пакеты", function()
        client.state = "STREAMING"
        client.sock = mock_sock -- Мокаем сокет
        
        client.buffer = string.rep("A", 10) .. string.rep("B", 5)
        
        local packet = client:process()
        
        assert.are.equal(string.rep("A", 10), packet)
        assert.are.equal(string.rep("B", 5), client.buffer)
    end)

    it("должен обрабатывать разрыв соединения", function()
        client.state = "STREAMING"
        client.sock = mock_sock -- Мокаем сокет
        
        mock_sock.receive = function() return nil, "closed" end
        
        client:process()
        
        assert.are.equal("DISCONNECTED", client.state)
    end)
end)