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

-- create and return a scene without touching the stack
-- @type (string, ...T[]) -> Scene
function scenemanager.new(kind, ...)
    return scenemanager.scenes[kind]:new(...)
end

function getscene(kind, ...)
    if type(kind) == 'table' then
        return kind
    end
    return scenemanager.new(kind, ...)
end

-- push a scene to the stack
-- @type (string, ...T[]) -> Scene
-- @type (Scene) -> Scene
function scenemanager.push(kind, ...)
    local scene = getscene(kind, ...)
    local prev = scenemanager.scenestack[#scenemanager.scenestack]
    if prev then
        prev:exit(scene, 'push')
        scene:enter(prev, 'push')
    end
    table.insert(scenemanager.scenestack, scene)
    return scene
end

-- pop the topmost scene from the stack and return it
-- @type () -> Scene
function scenemanager.pop()
    local len = #scenemanager.scenestack
    local scene = scenemanager.scenestack[len]
    local next = scenemanager.scenestack[len - 1]
    if not next then
        error "No scenes left in stack after pop!"
    end
    scene:exit(next, 'pop')
    next:enter(scene, 'pop')
    scenemanager.scenestack[len] = nil
    return scene
end

-- swap the current scene from with another
-- @type (string, ...T[]) -> Scene
-- @type (Scene) -> Scene
function scenemanager.swap(kind, ...)
    local scene = getscene(kind, ...)
    local len = #scenemanager.scenestack
    local prev = scenemanager.scenestack[len]
    prev:exit(next, 'swap')
    scene:enter(prev, 'swap')
    scenemanager.scenestack[len] = scene
    return prev
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

local methods = {
    -- instance initializer
    'init', -- (self, ...) -> void

    -- scene switching
    'enter', -- (self, prev: Scene, action: string) -> void
    'exit', -- (self, next: Scene, action: string) -> void

    -- lifecycle methods
    'update', -- (self, deltatime: number) -> void
    'draw', -- (self) -> void
}
for _, fn in ipairs(methods) do
    scenemanager.Scene[fn] = function() end
end

scenemanager.loveevents = {
    -- events
    'mousemoved', -- (self, x: number, y: number, dx: number, dy: number, touch: boolean) -> void
    'mousepressed', -- (self, x: number, y: number, button: number, touch:boolean, presses: number) -> void
    'mousereleased', -- (self, x: number, y: number, button: number, touch:boolean, presses: number) -> void

    -- keyboard
    'keypressed', -- (self, key: string, scancode: string, repeat: boolean) -> void
    'keyreleased', -- (self, key: string, scancode: string) -> void
}
for _, fn in ipairs(scenemanager.loveevents) do
    scenemanager.Scene[fn] = function() end
end

return scenemanager