local popupmenu = require "normalpicross.scene.popupmenu"
local controls = require "normalpicross.utils.controls"
local Button = require "normalpicross.ui.button"

local controlsmenu = popupmenu:new()
controlsmenu.name = 'controlsmenu'

function controlsmenu:init()
    popupmenu.init(self)

    self:_reload()
end

function controlsmenu:_reload()
    self.selected = nil
    self.selected2 = 0
    self.keys = {}
    for i, t in ipairs(controls.keys) do
        self.keys[i] = {
            type = t,
            btnname = Button:new {
                text = t:sub(1, 1):upper() .. t:sub(2),
                halign = 'center',
                valign = 'center',
                textcolor = { 1, 1, 1 },
            },
            keys = {},
        }
        for k, l in pairs(controls[t]) do
            for m in pairs(l) do
                table.insert(self.keys[i].keys, {
                    kind = k,
                    value = m,
                    btn = Button:new {
                        text = k == 'scancode'
                            and love.keyboard.getKeyFromScancode(m)
                            or m,
                        halign = 'center',
                        valign = 'center',
                        textcolor = { 1, 1, 1 },
                    }
                })
            end
        end
    end

    self.btnreset = Button:new {
        halign = 'center', valign = 'center',
        text = 'Reset to defaults',
        textcolor = { 1, 1, 1 }
    }

    self.deleting = nil

    self.key = nil
    self.creating = nil
    self.btnkey = Button:new {
        halign = 'center', valign = 'center',
        text = '',
        textcolor = { 1, 1, 1 },
    }

    self.okcancel = nil
    self.btnok = Button:new {
        halign = 'center', valign = 'center',
        text = 'OK',
        textcolor = { 1, 1, 1 }
    }
    self.btncancel = Button:new {
        halign = 'center', valign = 'center',
        text = 'Cancel',
        textcolor = { 1, 1, 1 }
    }
end

function controlsmenu:drawmenu()
    local w, h = love.graphics.getDimensions()
    local font = love.graphics.getFont()
    local x, y = w / 4, h / 4

    love.graphics.setColor(.2, 0, 0, 1)
    love.graphics.rectangle('fill', x, y, w / 2, h / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Controls", x, y)

    local titlewidth = 0
    for _, t in ipairs(controls.keys) do
        local title = t:sub(1, 1):upper() .. t:sub(2)
        local width = font:getWidth(title)
        if titlewidth < width then
            titlewidth = width
        end
    end

    for i, key in ipairs(self.keys) do
        local y = y + 10 + 25 * i
        key.btnname.x, key.btnname.y = x, y
        key.btnname.w, key.btnname.h = titlewidth + 10, 20
        key.btnname:draw()

        for i, obj in ipairs(key.keys) do
            local prev = i > 1
                and key.keys[i - 1].btn
                or key.btnname
            obj.btn.x, obj.btn.y = prev.x + prev.w + 5, y
            obj.btn.w, obj.btn.h = font:getWidth(obj.btn.text) + 10, prev.h
            obj.btn:draw()
        end
    end

    self.btnreset.x, self.btnreset.y = x, 3 * h / 4 - 20
    self.btnreset.w, self.btnreset.h = w / 2, 20
    self.btnreset:draw()

    if self.creating then
        local x, y = w / 3, h / 3

        love.graphics.setColor(0, 0, .2, 1)
        love.graphics.rectangle('fill', x, y, w / 3, h / 3)
        love.graphics.setColor(1, 1, 1, 1)
        local type = self.keys[self.creating].type
        local title = type:sub(1, 1):upper() .. type:sub(2)
        love.graphics.print("New key for " .. title, x, y)

        self.btnkey.x, self.btnkey.y = x, y + 20
        self.btnkey.w, self.btnkey.h = w / 3, 40
        self.btnkey:draw()

        if self.key then
            self.btnok.x, self.btnok.y = x, h / 2
            self.btnok.w, self.btnok.h = w / 6, h / 6
            self.btnok:draw()
        end

        self.btncancel.x, self.btncancel.y = w / 2, h / 2
        self.btncancel.w, self.btncancel.h = w / 6, h / 6
        self.btncancel:draw()
    end

    if self.deleting then
        local x, y = w / 3, h / 3

        love.graphics.setColor(0, 0, .2, 1)
        love.graphics.rectangle('fill', x, y, w / 3, h / 3)
        love.graphics.setColor(1, 1, 1, 1)
        local type = self.keys[self.selected].type
        local title = type:sub(1, 1):upper() .. type:sub(2)
        local key = self.keys[self.selected].keys[self.selected2].btn.text
        love.graphics.print("Deleting key " .. key .. " for " .. title, x, y)

        self.btnok.x, self.btnok.y = x, h / 2
        self.btnok.w, self.btnok.h = w / 6, h / 6
        self.btnok:draw()

        self.btncancel.x, self.btncancel.y = w / 2, h / 2
        self.btncancel.w, self.btncancel.h = w / 6, h / 6
        self.btncancel:draw()
    end
end

function controlsmenu:update()
    if self.creating then
        if self.key then
            self.btnkey.color = { .2, .2, .5 }
            self.btnkey.text = self.key
        else
            self.btnkey.color = { 0, 0, .5 }
            self.btnkey.text = '(press a key)'
        end
    end

    if self.okcancel == 1 then
        self.btnok.color = { .2, .5, .2 }
    else
        self.btnok.color = { 0, .5, 0 }
    end
    if self.okcancel == 2 then
        self.btncancel.color = { .2, .5, .2 }
    else
        self.btncancel.color = { 0, .5, 0 }
    end

    for i, key in ipairs(self.keys) do
        if self.selected == i and self.selected2 == 0 then
            key.btnname.color = { .5, .2, .2 }
        else
            key.btnname.color = { .5, 0, 0 }
        end

        for j, obj in ipairs(key.keys) do
            if self.selected == i and self.selected2 == j then
                obj.btn.color = { .3, .1, .1 }
            else
                obj.btn.color = nil
            end
        end
    end

    self.btnreset.color = self.selected == #self.keys + 1
        and { .5, .2, .2 }
        or { .5, 0, 0 }
end

function controlsmenu:_moveselected(direction)
    if not self.selected then
        self.selected = 1
        return
    end
    self.selected = self.selected + direction
    self.selected2 = 0
    if self.selected < 1 then
        self.selected = #self.keys + 1
    end
    if self.selected > #self.keys + 1 then
        self.selected = 1
    end
end

function controlsmenu:_moveselected2(direction)
    if not self.selected then
        self.selected = 1
        return
    end

    local max = self.selected == #self.keys + 1
        and 0
        or #self.keys[self.selected].keys

    self.selected2 = self.selected2 + direction
    if self.selected2 < 0 then
        self.selected2 = max
    end
    if self.selected2 > max then
        self.selected2 = 0
    end
end

function controlsmenu:_docreate()
    controls.add(self.keys[self.creating].type, 'key', self.key)
    self:_reload()
end

function controlsmenu:_dodelete()
    local key = self.keys[self.selected]
    local obj = key.keys[self.selected2]
    controls.del(key.type, obj.kind, obj.value)
    self:_reload()
end

function controlsmenu:keypressed(key, scancode)
    if self.creating then
        if not self.key then
            self.key = key
            return
        end

        if controls.isleft(key, scancode) or controls.isright(key, scancode) then
            if not self.okcancel then
                self.okcancel = 1
            elseif self.okcancel == 1 then
                self.okcancel = 2
            else
                self.okcancel = 1
            end
        elseif controls.isprimary(key, scancode) and self.okcancel then
            if self.okcancel == 1 then
                self:_docreate()
            else
                self.key = nil
                self.okcancel = nil
                self.creating = nil
            end
        end

        return
    end

    if self.deleting then
        if controls.isleft(key, scancode) or controls.isright(key, scancode) then
            if not self.okcancel then
                self.okcancel = 1
            elseif self.okcancel == 1 then
                self.okcancel = 2
            else
                self.okcancel = 1
            end
        elseif controls.isprimary(key, scancode) and self.okcancel then
            if self.okcancel == 1 then
                self:_dodelete()
            else
                self.okcancel = nil
                self.deleting = nil
            end
        end

        return
    end

    popupmenu.keypressed(self, key, scancode)
    if controls.isdown(key, scancode) then
        self:_moveselected(1)
    elseif controls.isup(key, scancode) then
        self:_moveselected(-1)
    elseif controls.isright(key, scancode) then
        self:_moveselected2(1)
    elseif controls.isleft(key, scancode) then
        self:_moveselected2(-1)
    elseif controls.isprimary(key, scancode) and self.selected then
        if self.selected == #self.keys + 1 then
            controls.reset()
            self:_reload()
            return
        end
        if self.selected2 == 0 then
            self.creating = self.selected
            self.selected = nil
            self.selected2 = 0
            self.key = nil
        else
            self.deleting = true
        end
    end
end

function controlsmenu:mousemoved(x, y)
    if self.creating then
        if self.btnok:ishovered(x, y) and self.key then
            self.okcancel = 1
        elseif self.btncancel:ishovered(x, y) then
            self.okcancel = 2
        else
            self.okcancel = nil
        end

        return
    end

    if self.deleting then
        if self.btnok:ishovered(x, y) then
            self.okcancel = 1
        elseif self.btncancel:ishovered(x, y) then
            self.okcancel = 2
        else
            self.okcancel = nil
        end

        return
    end

    if self.btnreset:ishovered(x, y) then
        self.selected = #self.keys + 1
        self.selected2 = 0
        return
    end

    for i, key in ipairs(self.keys) do
        if key.btnname:ishovered(x, y) then
            self.selected = i
            self.selected2 = 0
            return
        end

        for j, obj in ipairs(key.keys) do
            if obj.btn:ishovered(x, y) then
                self.selected = i
                self.selected2 = j
                return
            end
        end
    end

    self.selected = nil
    self.selected2 = 0
end

function controlsmenu:mousepressed(x, y, button)
    if button ~= 1 then
        return
    end

    if self.creating then
        if self.btncancel:ishovered(x, y) then
            self.key = nil
            self.creating = nil
            self.okcancel = nil
        elseif self.btnkey:ishovered(x, y) then
            self.key = nil
        elseif self.key and self.btnok:ishovered(x, y) then
            self:_docreate()
        end
        return
    end

    if self.deleting then
        if self.btncancel:ishovered(x, y) then
            self.deleting = nil
            self.okcancel = nil
        elseif self.btnok:ishovered(x, y) then
            self:_dodelete()
        end
        return
    end

    if self.btnreset:ishovered(x, y) then
        controls.reset()
        self:_reload()
        return
    end

    for i, key in ipairs(self.keys) do
        if key.btnname:ishovered(x, y) then
            self.creating = i
            self.selected = nil
            self.selected2 = 0
            return
        end

        for j, obj in ipairs(key.keys) do
            if obj.btn:ishovered(x, y) then
                self.selected = i
                self.selected2 = j
                self.deleting = true
                return
            end
        end
    end
end

return controlsmenu
