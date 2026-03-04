local scenemanager = require "normalpicross.scenemanager"

local demo = scenemanager.Scene:new()
demo.name = 'demo'

function demo:init()
    self.tick = 0
    self.deltatime = 0
    self.points = {}
end

function demo:update(deltatime)
    self.tick = self.tick + 1
    self.deltatime = deltatime
end

function demo:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Hewwo", 0, 0)
    love.graphics.print("World", 0, 10)
    love.graphics.print("Points: " .. #self.points, 0, 20)
    love.graphics.print("Ticks: " .. self.tick, 0, 30)
    love.graphics.print("DeltaTime: " .. self.deltatime, 0, 40)

    do
        local text = tostring(love.timer.getFPS())
        local width = love.graphics.getFont():getWidth(text)
        love.graphics.print(text, love.graphics.getWidth() - width, 0)
    end

    for _, point in ipairs(self.points) do
        love.graphics.setColor(point.r, point.g, point.b, 1)
        love.graphics.circle("fill", point.x, point.y, 5)
    end
end

function demo:mousepressed(x, y, button, touch)
    local r, g, b = math.random(), math.random(), math.random()
    table.insert(self.points, {x=x, y=y, r=r, g=g, b=b})
end

return demo