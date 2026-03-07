local Save = require "normalpicross.utils.save"

local controls = {}

controls.keys = { 'primary', 'secondary', 'menu', 'up', 'down', 'left', 'right' }

local config = Save:new("controls.lua", {
    primary = {
        { key = 'space' },
        { key = 'return' },
        { scancode = 'e' },
        { scancode = 'z' },
    },
    secondary = {
        { key = 'backspace' },
        { key = 'lshift' },
        { key = 'rshift' },
        { scancode = 'q' },
        { scancode = 'x' },
    },
    menu = {
        { key = 'escape' },
        { scancode = 'c' },
    },
    up = {
        { key = 'up' },
        { scancode = 'w' },
    },
    down = {
        { key = 'down' },
        { scancode = 's' },
    },
    left = {
        { key = 'left' },
        { scancode = 'a' },
    },
    right = {
        { key = 'right' },
        { scancode = 'd' },
    },
})
function config:check()
    for k, v in pairs(self.default) do
        if not self.data[k] then
            self.data[k] = v
        end
    end
    for k in pairs(self.data) do
        if not self.default[k] then
            self.data[k] = nil
        end
    end
    return true
end

-- load the config from disk
config:load()
config:save()
local function reload()
    for _, k in ipairs(controls.keys) do
        local v = config.data[k]
        controls[k] = { key = {}, scancode = {} }
        for _, obj in ipairs(v) do
            local t, r = next(obj)
            ---@diagnostic disable-next-line: need-check-nil
            controls[k][t][r] = true
        end
    end
end
reload()

local function update()
    config.data = {}
    for _, k in ipairs(controls.keys) do
        config.data[k] = {}
        for t, v in pairs(controls[k]) do
            for r in pairs(v) do
                table.insert(config.data[k], { [t] = r })
            end
        end
    end
    config:save()
end

function controls.add(type, mode, value)
    controls[type][mode][value] = true
    update()
end

function controls.del(type, mode, value)
    controls[type][mode][value] = nil
    update()
end

function controls.reset()
    config.data = config.default
    config:save()
    reload()
end

function controls.is(type, key, scancode)
    return controls[type].key[key] or controls[type].scancode[scancode] or false
end

function controls.isprimary(key, scancode)
    return controls.is('primary', key, scancode)
end

function controls.issecondary(key, scancode)
    return controls.is('secondary', key, scancode)
end

function controls.ismenu(key, scancode)
    return controls.is('menu', key, scancode)
end

function controls.isup(key, scancode)
    return controls.is('up', key, scancode)
end

function controls.isdown(key, scancode)
    return controls.is('down', key, scancode)
end

function controls.isleft(key, scancode)
    return controls.is('left', key, scancode)
end

function controls.isright(key, scancode)
    return controls.is('right', key, scancode)
end

return controls
