local Save = {}
Save.__index = Save

function Save:new(name, default)
    return setmetatable({ name = name, default = default }, Save)
end

function Save:load()
    local info = love.filesystem.getInfo(self.name)
    if info then
        local code = love.filesystem.read(self.name)
        local chunk = loadstring(code)
        if chunk then
            self.data = chunk()
            local success = true
            if self.check then
                local ok, err = self:check()
                if not ok then
                    print("Error in data from " .. self.name, err)
                    success = false
                    self.data = self.default
                end
            end
            if success then
                print("Loaded data from " .. self.name)
            end
        else
            self.data = self.default
            print("Failed to load data from " .. self.name)
        end
    else
        self.data = self.default
        print("No data in " .. self.name)
    end
    return self.data
end

local function escape(str)
    return (str
        :gsub("\\", "\\\\")
        :gsub("\"", "\\\"")
        :gsub("\'", "\\\'")
        :gsub("\n", "\\n")
        :gsub("\t", "\\t")
        :gsub("\r", "\\r")
        :gsub("\v", "\\v")
        :gsub("\a", "\\a")
        :gsub("\b", "\\b")
    )
end

local function dump(tab, obj)
    if obj == nil then
        table.insert(tab, "nil")
    elseif obj == true then
        table.insert(tab, "true")
    elseif obj == false then
        table.insert(tab, "false")
    elseif type(obj) == "number" then
        table.insert(tab, tostring(obj))
    elseif type(obj) == "string" then
        table.insert(tab, "\"")
        table.insert(tab, escape(obj))
        table.insert(tab, "\"")
    elseif type(obj) ~= "table" then
        error("Cannot dump a " .. type(obj) .. " object")
    else
        table.insert(tab, "{ ")
        for k, v in pairs(obj) do
            table.insert(tab, "[")
            dump(tab, k)
            table.insert(tab, "] = ")
            dump(tab, v)
            table.insert(tab, ", ")
        end
        table.insert(tab, " }")
    end
end

function Save:save()
    local code = { "return " }
    dump(code, self.data)
    local data = table.concat(code)
    love.filesystem.write(self.name, data)
    print("Saved data to " .. self.name)
end

return Save
