local scenemanager = require "normalpicross.scenemanager"
local Picross = require "normalpicross.mechanics.picross"

local picross = scenemanager.Scene:new()
picross.name = 'picross'

function picross:init(options)
    -- board state
    self.picross = Picross:new(options)

    -- target x/y (hover / keyboard)
    self.tx, self.ty = nil, nil

    -- held button / key
    self.hstate = nil
    -- held button comparison
    self.hif = nil
    -- held button start x/y
    self.hx, self.hy = nil, nil
    -- held button direction
    self.hd = nil
end

function picross:enter()
    love.keyboard.setKeyRepeat(true)
end

-- color of the numbers
local clrnumbers = {1, 1, 1}
-- color of the lines
local clrlines = {.9, .9, .9}
-- color of an active cell
local clron = {.7, 1, .7}
-- color of an excluded cell
local clrex = {1, .7, .7}
-- color of an inactive cell
local clroff = {.1, .1, .1}
-- color of an active targetted cell
local clront = {.2, 1, .7}
-- color of an excluded targetted cell
local clrext = {1, .2, .2}
-- color of an inactive targetted cell
local clrofft = {.5, .5, .5}

function picross:draw()
    love.graphics.setColor(clroff)
    love.graphics.rectangle('fill', 100, 100, 10 * self.picross.w, 10 * self.picross.h)

    love.graphics.setColor(clrlines)
    for x=0, self.picross.w do
        love.graphics.line(100 + x * 10, 0, 100 + x * 10, 100 + self.picross.h * 10)
    end
    for y=0, self.picross.h do
        love.graphics.line(0, 100 + y * 10, 100 + self.picross.w * 10, 100 + y * 10)
    end

    for x=1, self.picross.w do
        for y=1, self.picross.h do
            local v = self.picross:get(x, y)
            if v == 'x' then
                love.graphics.setColor(clron)
                love.graphics.rectangle('fill', 90 + x * 10, 90 + y * 10, 10, 10)
            elseif v == '.' then
                love.graphics.setColor(clrex)
                love.graphics.rectangle('fill', 90 + x * 10, 90 + y * 10, 10, 10)
            end
        end
    end

    if self.tx and self.ty then
        local state = self.picross:get(self.tx, self.ty)
        if state == 'x' then
            love.graphics.setColor(clront)
        elseif state == '.' then
            love.graphics.setColor(clrext)
        else
            love.graphics.setColor(clrofft)
        end
        love.graphics.rectangle('fill', 90 + self.tx * 10, 90 + self.ty * 10, 10, 10)
    end

    love.graphics.setColor(clrnumbers)
    for x, col in ipairs(self.picross.cols) do
        for y, num in ipairs(col) do
            love.graphics.print(tostring(num), 90 + x * 10, y * 10)
        end
    end
    for y, row in ipairs(self.picross.rows) do
        for x, num in ipairs(row) do
            love.graphics.print(tostring(num), x * 10, 90 + y * 10)
        end
    end
end

function picross:_setat(x, y, state, exact)
    local current = self.picross:get(x, y)
    if not exact then
        if current == state then
            state = ' '
        elseif current == '.' and state == 'x' then
            return nil
        elseif current == 'x' and state == '.' then
            state = ' '
        end
    end
    self.picross:set(x, y, state)
    return state
end

function picross:_infield(x, y)
    if x < 100 or y < 100 then
        return false
    elseif x >= 100 + self.picross.w * 10 then
        return false
    elseif y >= 100 + self.picross.h * 10 then
        return false
    else
        return true
    end
end

function picross:_fieldcoords(x, y)
    return math.floor((x - 90) / 10), math.floor((y - 90) / 10)
end

function picross:_move(dx, dy)
    if not self.tx then
        self.tx, self.ty = 1, 1
        return
    end
    self.tx, self.ty = self.tx + dx, self.ty + dy
    if self.hstate then
        if self.tx < 1 then
            self.tx = 1
        end
        if self.tx > self.picross.w then
            self.tx = self.picross.w
        end
        if self.ty < 1 then
            self.ty = 1
        end
        if self.ty > self.picross.h then
            self.ty = self.picross.h
        end
    else
        if self.tx < 1 then
            self.tx = self.picross.w
        end
        if self.tx > self.picross.w then
            self.tx = 1
        end
        if self.ty < 1 then
            self.ty = self.picross.h
        end
        if self.ty > self.picross.h then
            self.ty = 1
        end
    end
    if self.hstate and self.hif == self.picross:get(self.tx, self.ty) then
        self:_setat(self.tx, self.ty, self.hstate, true)
    end
end

function picross:mousemoved(x, y)
    if self:_infield(x, y) then
        self.tx, self.ty = self:_fieldcoords(x, y)

        if not self.hstate then
            return
        end

        if not self.hd then
            if self.tx ~= self.hx then
                self.hd = 'x'
            elseif self.ty ~= self.hy then
                self.hd = 'y'
            end
        end
        local ax, ay = self.tx, self.ty
        if self.hd == 'x' then
            ay = self.hy
        elseif self.hd == 'y' then
            ax = self.hx
        end

        if self.hif == self.picross:get(ax, ay) then
            self:_setat(ax, ay, self.hstate, true)
        end
    else
        self.tx, self.ty = nil, nil
    end
end

function picross:mousepressed(x, y, button)
    if not self:_infield(x, y) then
        return
    end

    local cx, cy = self:_fieldcoords(x, y)

    local state = nil
    if button == 1 then
        state = 'x'
    elseif button == 2 then
        state = '.'
    else
        return
    end
    local current = self.picross:get(cx, cy)
    state = self:_setat(cx, cy, state)
    if state then
        self.hif = current
        self.hstate = state
        self.hx, self.hy = cx, cy
        self.hd = nil
    end
end

function picross:mousereleased()
    self.hstate = nil
    self.hif = nil
    self.hx, self.hy = nil
    self.hd = nil
end

function picross:keypressed(key, scancode)
    if key == 'escape' or scancode == 'c' then
        scenemanager.pop()
    elseif key == 'down' or scancode == 's' then
        self:_move(0, 1)
    elseif key == 'up' or scancode == 'w' then
        self:_move(0, -1)
    elseif key == 'left' or scancode == 'a' then
        self:_move(-1, 0)
    elseif key == 'right' or scancode == 'd' then
        self:_move(1, 0)
    elseif (key == 'space' or key == 'return' or scancode == 'e' or scancode == 'z') and self.tx then
        local current = self.picross:get(self.tx, self.ty)
        local state = self:_setat(self.tx, self.ty, 'x')
        if state then
            self.hif = current
            self.hstate = state
            self.hx, self.hy = self.tx, self.ty
            self.hd = nil
        end
    elseif (key == 'backspace' or key == 'lshift' or key == 'rshift' or scancode == 'q' or scancode == 'x') and self.tx then
        local current = self.picross:get(self.tx, self.ty)
        local state = self:_setat(self.tx, self.ty, '.')
        if state then
            self.hif = current
            self.hstate = state
            self.hx, self.hy = self.tx, self.ty
            self.hd = nil
        end
    end
end

function picross:keyreleased(key, scancode)
    if
        key == 'space' or key == 'return' or scancode == 'e' or scancode == 'z'
        or key == 'backspace' or key == 'lshift' or key == 'rshift' or scancode == 'q' or scancode == 'x'
    then
        self.hstate = nil
        self.hif = nil
        self.hx, self.hy = nil
        self.hd = nil
    end
end

return picross