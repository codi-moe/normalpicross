local scenemanager = require "normalpicross.scenemanager"

function love.load()
    scenemanager.declare(require "normalpicross.scene.demo")
    scenemanager.declare(require "normalpicross.scene.picross")
    scenemanager.declare(require "normalpicross.scene.pausemenu")
    scenemanager.declare(require "normalpicross.scene.controlsmenu")
    scenemanager.push('demo')
end

love.update = function(deltatime)
    local scene = scenemanager.current()
    scene:update(deltatime)
end

local function measuretext(text, x, y, halign, valign)
    halign = halign or 'left'
    valign = valign or 'top'

    local font = love.graphics.getFont()
    local width = font:getWidth(text)
    local height = font:getHeight(text)

    if halign == 'right' then
        x = x - width
    elseif halign == 'center' then
        x = x - width / 2
    end
    if valign == 'bottom' then
        y = y - height
    elseif valign == 'center' then
        y = y - height / 2
    end

    return x, y, width, height
end

local function debugtext(text, y)
    ---@diagnostic disable-next-line: redefined-local
    local x, y, w, h = measuretext(text, love.graphics.getWidth(), y, 'right')
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x, y)
    return y + h
end

local function debuglines(lines)
    local y = 0
    for _, line in ipairs(lines) do
        y = debugtext(tostring(line), y)
    end
end

love.draw = function()
    local scene = scenemanager.current()
    scene:draw()

    love.graphics.origin()
    debuglines {
        love.timer.getFPS(),
        scenemanager.current().name,
    }
end

for _, method in ipairs(scenemanager.loveevents) do
    love[method] = function(...)
        local scene = scenemanager.current()
        return scene[method](scene, ...)
    end
end
