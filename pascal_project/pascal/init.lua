-- pascal/init.lua
local Pascal = {}
Pascal.__index = Pascal

-- Типы токенов
local TokenType = {
    INTEGER = "INTEGER",
    PLUS = "PLUS", MINUS = "MINUS", MUL = "MUL", DIV = "DIV",
    LPAREN = "LPAREN", RPAREN = "RPAREN",
    BEGIN = "BEGIN", END = "END",
    ID = "ID", ASSIGN = "ASSIGN",
    SEMI = "SEMI", DOT = "DOT",
    EOF = "EOF"
}

function Pascal.new()
    local self = setmetatable({}, Pascal)
    self.text = ""
    self.pos = 1
    self.current_token = nil
    self.variables = {} 
    return self
end


function Pascal:error(msg)
    error("Pascal Error: " .. msg)
end

function Pascal:get_next_token()
    local text = self.text
    

    while self.pos <= #text and text:sub(self.pos, self.pos):match("%s") do
        self.pos = self.pos + 1
    end

    if self.pos > #text then
        return { type = TokenType.EOF, value = nil }
    end

    local char = text:sub(self.pos, self.pos)

    if char:match("%d") then
        local num_str = text:match("^%d+", self.pos)
        self.pos = self.pos + #num_str
        return { type = TokenType.INTEGER, value = tonumber(num_str) }
    end

    if char:match("[%a_]") then
        local word = text:match("^[%a_][%w_]*", self.pos)
        self.pos = self.pos + #word
        local upper_word = word:upper()
        if upper_word == "BEGIN" then return { type = TokenType.BEGIN, value = "BEGIN" }
        elseif upper_word == "END" then return { type = TokenType.END, value = "END" }
        elseif upper_word == "DIV" then return { type = TokenType.DIV, value = "/" } 
        else return { type = TokenType.ID, value = word }
        end
    end

    if char == ":" and text:sub(self.pos+1, self.pos+1) == "=" then
        self.pos = self.pos + 2
        return { type = TokenType.ASSIGN, value = ":=" }
    end

    self.pos = self.pos + 1
    if char == "+" then return { type = TokenType.PLUS, value = "+" }
    elseif char == "-" then return { type = TokenType.MINUS, value = "-" }
    elseif char == "*" then return { type = TokenType.MUL, value = "*" }
    elseif char == "/" then return { type = TokenType.DIV, value = "/" }
    elseif char == "(" then return { type = TokenType.LPAREN, value = "(" }
    elseif char == ")" then return { type = TokenType.RPAREN, value = ")" }
    elseif char == ";" then return { type = TokenType.SEMI, value = ";" }
    elseif char == "." then return { type = TokenType.DOT, value = "." }
    end

    self:error("Unexpected character: " .. char)
end

function Pascal:eat(token_type)
    if self.current_token.type == token_type then
        self.current_token = self:get_next_token()
    else
        self:error("Expected " .. token_type .. ", got " .. self.current_token.type)
    end
end

function Pascal:factor()
    local token = self.current_token
    
    if token.type == TokenType.PLUS then
        self:eat(TokenType.PLUS)
        return self:factor()
    elseif token.type == TokenType.MINUS then
        self:eat(TokenType.MINUS)
        return -self:factor()
    elseif token.type == TokenType.INTEGER then
        self:eat(TokenType.INTEGER)
        return token.value
    elseif token.type == TokenType.LPAREN then
        self:eat(TokenType.LPAREN)
        local result = self:expr()
        self:eat(TokenType.RPAREN)
        return result
    elseif token.type == TokenType.ID then
        return self:variable()
    else
        self:error("Unexpected token in factor: " .. token.type)
    end
end

function Pascal:term()
    local result = self:factor()

    while self.current_token.type == TokenType.MUL or self.current_token.type == TokenType.DIV do
        local token = self.current_token
        if token.type == TokenType.MUL then
            self:eat(TokenType.MUL)
            result = result * self:factor()
        elseif token.type == TokenType.DIV then
            self:eat(TokenType.DIV)
            result = result / self:factor()
        end
    end
    return result
end

function Pascal:expr()
    local result = self:term()

    while self.current_token.type == TokenType.PLUS or self.current_token.type == TokenType.MINUS do
        local token = self.current_token
        if token.type == TokenType.PLUS then
            self:eat(TokenType.PLUS)
            result = result + self:term()
        elseif token.type == TokenType.MINUS then
            self:eat(TokenType.MINUS)
            result = result - self:term()
        end
    end
    return result
end

function Pascal:variable()
    local var_name = self.current_token.value
    self:eat(TokenType.ID)
    local val = self.variables[var_name]
    if val == nil then
        self:error("Variable not found: " .. var_name)
    end
    return val
end

function Pascal:assignment()
    local var_name = self.current_token.value
    self:eat(TokenType.ID)
    self:eat(TokenType.ASSIGN)
    local result = self:expr()
    self.variables[var_name] = result
end

function Pascal:statement()
    local token = self.current_token
    if token.type == TokenType.BEGIN then
        self:compound_statement()
    elseif token.type == TokenType.ID then
        self:assignment()
    else

    end
end

function Pascal:statement_list()
    self:statement()
    while self.current_token.type == TokenType.SEMI do
        self:eat(TokenType.SEMI)
        self:statement()
    end
end

function Pascal:compound_statement()
    self:eat(TokenType.BEGIN)
    self:statement_list()
    self:eat(TokenType.END)
end

function Pascal:program()
    self:compound_statement()
    self:eat(TokenType.DOT)
end

function Pascal:run(code)
    self.text = code
    self.pos = 1
    self.variables = {}
    self.current_token = self:get_next_token()
    
    self:program()
    
    return self.variables
end

return Pascal