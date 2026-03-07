local Button = {}
Button.__index = Button

function Button:new(options)
    return setmetatable({
        x = options.x or 0,
        y = options.y or 0,
        w = options.w or 0,
        h = options.h or 0,
        text = options.text,
        halign = options.halign or 'left',
        valign = options.valign or 'top',
        color = options.color,
        textcolor = options.textcolor,
    }, Button)
end

function Button:ishovered(x, y)
    return x >= self.x and x <= self.x + self.w
        and y >= self.y and y <= self.y + self.h
end

function Button:draw()
    if self.color then
        love.graphics.setColor(self.color)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end

    local font = love.graphics.getFont()

    local width = font:getWidth(self.text)
    local height = font:getHeight(self.text)

    local x = self.x
    local y = self.y

    if self.halign == 'right' then
        x = self.x + self.w - width
    elseif self.halign == 'center' then
        x = self.x + self.w / 2 - width / 2
    end

    if self.valign == 'bottom' then
        y = self.y + self.h - height
    elseif self.valign == 'center' then
        y = self.y + self.h / 2 - height / 2
    end

    if self.textcolor then
        love.graphics.setColor(self.textcolor)
    end
    love.graphics.print(self.text, x, y)
end

return Button
