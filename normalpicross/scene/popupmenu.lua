local scenemanager = require "normalpicross.scenemanager"
local controls = require "normalpicross.utils.controls"

local popupmenu = scenemanager.Scene:new()
popupmenu.name = 'popupmenu'

function popupmenu:init()
    self.parent = nil
end

function popupmenu:enter(prev, action)
    love.keyboard.setKeyRepeat(false)

    if action == 'push' then
        self.parent = prev
    end
end

function popupmenu:draw()
    self.parent:draw()
    love.graphics.origin()
    self:drawmenu()
end

function popupmenu:drawmenu()
    -- doesnt do anything but can be overridden
end

function popupmenu:keypressed(key, scancode)
    if controls.ismenu(key, scancode) then
        scenemanager.pop()
    end
end

return popupmenu
