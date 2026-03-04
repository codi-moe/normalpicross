-- module
local scenemanager = {}

-- all defined scenes
-- @type Record<string, Class<Scene>>
scenemanager.scenes = {}

-- current scene stack
-- @type Scene[]
scenemanager.scenestack = {}

-- declare a scene class
-- @type (Class<Scene>) -> void
function scenemanager.declare(class)
    scenemanager.scenes[class.name] = class
end

-- push a scene to the stack
-- @type (string, ...T[]) -> Scene
function scenemanager.push(kind, ...)
    local class = scenemanager.scenes[kind]
    local scene = scenemanager.scenes[kind]:new(...)
    table.insert(scenemanager.scenestack, scene)
    return scene
end

-- pop the topmost scene from the stack and return it
-- @type () -> Scene
function scenemanager.pop()
    local scene = scenemanager.scenestack[#scenemanager.scenestack]
    scenemanager.scenestack[#scenemanager.scenestack] = nil
    if #scenemanager.scenestack == 0 then
        error "No scenes left in stack after pop!"
    end
    return scene
end

-- get the current topmost scene
-- @type () -> Scene
function scenemanager.current()
    return scenemanager.scenestack[#scenemanager.scenestack]
end

-- Scene class
scenemanager.Scene = {}
scenemanager.Scene.__index = scenemanager.Scene

function scenemanager.Scene:new(...)
    local item = setmetatable({}, {__index = self})
    item:init(...)
    return item
end

-- @type (self, ...) -> void
scenemanager.Scene.init = function() end

scenemanager.methods = {
    -- lifecycle methods
    'update', -- (self, deltatime: number) -> void
    'draw', -- (self) -> void

    -- events
    'mousepressed', -- (self, x: number, y: number, button: number, touch:boolean) -> void
}
for _, fn in ipairs(scenemanager.methods) do
    scenemanager.Scene[fn] = function() end
end

return scenemanager