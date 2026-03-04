local scenemanager = require "normalpicross.scenemanager"

function love.load()
    scenemanager.declare(require "normalpicross.scene.demo")
    scenemanager.push('demo')
end

for _, method in ipairs(scenemanager.methods) do
    love[method] = function(...)
        local scene = scenemanager.current()
        return scene[method](scene, ...)
    end
end
