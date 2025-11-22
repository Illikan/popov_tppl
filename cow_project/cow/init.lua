local Cow = {}
Cow.__index = Cow

function Cow.new()
    local self = setmetatable({}, Cow)
    self.memory = {} 
    self.ptr = 1     
    self.reg = nil   
    self.output = {} 
    self.input_buffer = {} 
    return self
end

function Cow:get_val()
    return self.memory[self.ptr] or 0
end

function Cow:set_val(val)
    self.memory[self.ptr] = val
end

function Cow:parse(code)
    local instructions = {}
    local mapping = {
        ["MoO"] = 0, ["MOo"] = 1, ["moO"] = 2, ["mOo"] = 3,
        ["moo"] = 4, ["MOO"] = 5, ["OOM"] = 6, ["oom"] = 7,
        ["mOO"] = 8, ["Moo"] = 9, ["OOO"] = 10, ["MMM"] = 11
    }
    
    for word in code:gmatch("%a%a%a") do
        if mapping[word] then
            table.insert(instructions, mapping[word])
        end
    end
    return instructions
end

function Cow:run(code, inputs)
    self.input_buffer = inputs or {}
    self.output = {}
    local ops = self:parse(code)
    local pc = 1 
    
    -- Расчет прыжков
    local jumps = {}
    local stack = {}
    for i, op in ipairs(ops) do
        if op == 5 then -- MOO (Начало цикла)
            table.insert(stack, i)
        elseif op == 4 then -- moo (Конец цикла)
            local start = table.remove(stack)
            if start then
                jumps[start] = i -- MOO знает где его moo
                jumps[i] = start -- moo знает где его MOO
            else
                error("Ошибка: встречен moo без MOO")
            end
        end
    end
    if #stack > 0 then
        error("Ошибка: есть MOO без закрывающего moo")
    end

    local function execute_step(op_code)
        if op_code == 0 then -- MoO: +1
            self:set_val(self:get_val() + 1)
        
        elseif op_code == 1 then -- MOo: -1
            self:set_val(self:get_val() - 1)
        
        elseif op_code == 2 then -- moO: ptr++
            self.ptr = self.ptr + 1
        
        elseif op_code == 3 then -- mOo: ptr--
            if self.ptr > 1 then self.ptr = self.ptr - 1 end
        
        elseif op_code == 4 then -- moo: конец цикла
            if jumps[pc] then 
                -- Возвращаем PC на позицию MOO - 1, чтобы цикл инкремента переместил нас ровно на MOO
                return jumps[pc] - 1 
            end
        
        elseif op_code == 5 then -- MOO: начало цикла
            if self:get_val() == 0 then
                if jumps[pc] then 
                    return jumps[pc] -- Прыгаем на moo. Цикл инкремента переместит нас за moo.
                end
            end
        
        elseif op_code == 6 then -- OOM: вывод числа
            local val = self:get_val()
            local str_val = tostring(val)
            table.insert(self.output, str_val)
            io.write(str_val)
        
        elseif op_code == 7 then -- oom: ввод числа
            local val
            if #self.input_buffer > 0 then
                val = table.remove(self.input_buffer, 1)
            else
                val = io.read("*n")
            end
            if val then self:set_val(val) end
        
        elseif op_code == 9 then -- Moo: сhar инпут/аутпут
            if self:get_val() == 0 then
                -- ввод символа
                local val
                if #self.input_buffer > 0 then
                    val = table.remove(self.input_buffer, 1)
                else
                   local char = io.read(1)
                   val = char and string.byte(char) or 0
                end
                self:set_val(val)
            else
                -- вывод символа
                local val = self:get_val()
                local char = string.char(val % 256)
                table.insert(self.output, char)
                io.write(char)
            end
        
        elseif op_code == 10 then -- OOO: обнулить
            self:set_val(0)
        
        elseif op_code == 11 then -- MMM: регистр
            if self.reg == nil then
                self.reg = self:get_val()
            else
                self:set_val(self.reg)
                self.reg = nil
            end
        end
        return nil -- Если не было прыжка
    end

    while pc <= #ops do
        local op = ops[pc]
        local next_pc = nil

        if op == 8 then -- mOO: выполнить
             local target_op = self:get_val()
             -- третью нельзя
             if target_op == 3 then
                 error("Ошибка: mOO попыталась выполнить код 3 (бесконечный цикл)")
             end
             -- при неправильном коде вылетаем
             if target_op < 0 or target_op > 11 then
                 return table.concat(self.output) -- Завершаем программу
             end
             
             -- Защита от рекурсии
             if target_op == 8 then
                 error("Ошибка: mOO вызывает сама себя")
             end

             execute_step(target_op)
        else
             next_pc = execute_step(op)
        end
        
        if next_pc then
            pc = next_pc
        end
        pc = pc + 1
    end
    
    return table.concat(self.output)
end

return Cow