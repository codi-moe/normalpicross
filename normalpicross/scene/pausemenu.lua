local controls = require "normalpicross.utils.controls"
local popupmenu = require "normalpicross.scene.popupmenu"
local scenemanager = require "normalpicross.scenemanager"

local pausemenu = popupmenu:new()
pausemenu.name = 'pausemenu'

function pausemenu:init(options)
    popupmenu.init(self)
    self.parent = nil
    self.exitcb = options.exit
    self.selected = nil
end

function pausemenu:drawmenu()
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(.2, 0, 0, 1)
    love.graphics.rectangle('fill', w / 4, h / 4, w / 2, h / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Game paused", w / 4, h / 4)

    if self.selected == 1 then
        love.graphics.setColor(.3, .7, .3, 1)
    else
        love.graphics.setColor(.3, .3, .3, 1)
    end
    love.graphics.rectangle('fill', w / 4 + w / 16, h / 2 + h / 16, w / 8, h / 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Resume", w / 4 + w / 16, h / 2 + h / 16)

    if self.selected == 2 then
        love.graphics.setColor(.3, .7, .3, 1)
    else
        love.graphics.setColor(.3, .3, .3, 1)
    end
    love.graphics.rectangle('fill', w / 2 + w / 16, h / 2 + h / 16, w / 8, h / 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Exit", w / 2 + w / 16, h / 2 + h / 16)
end

function pausemenu:keypressed(key, scancode)
    popupmenu.keypressed(self, key, scancode)

    if controls.isright(key, scancode) then
        self:_move(1)
    elseif controls.isleft(key, scancode) then
        self:_move(-1)
    elseif controls.isprimary(key, scancode) and self.selected then
        self:_activate(self.selected)
    end
end

function pausemenu:mousemoved(x, y)
    self.selected = self:_buttonat(x, y)
end

function pausemenu:mousepressed(x, y, button)
    if button ~= 1 then
        return
    end
    local target = self:_buttonat(x, y)
    if not target then
        return
    end
    self:_activate(target)
end

function pausemenu:_buttonat(x, y)
    local w, h = love.graphics.getDimensions()

    if y < h / 2 + h / 16 or y > h / 2 + h / 16 + h / 8 then
        return nil
    end

    if x >= w / 4 + w / 16 and x <= w / 4 + w / 16 + w / 8 then
        return 1
    end
    if x >= w / 2 + w / 16 and x <= w / 2 + w / 16 + w / 8 then
        return 2
    end

    return nil
end

function pausemenu:_move(offset)
    if not self.selected then
        self.selected = 1
        return
    end
    self.selected = self.selected + offset
    if self.selected < 1 then
        self.selected = 2
    end
    if self.selected > 2 then
        self.selected = 1
    end
end

function pausemenu:_activate(item)
    scenemanager.pop()
    if item == 1 then
        -- dont do anything extra
    elseif item == 2 then
        self.exitcb()
    end
end

return pausemenu
