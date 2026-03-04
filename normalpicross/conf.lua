function love.conf(t)
    t.identity = "normalpicross"
    t.version = "11.5"
    t.window.title = "Normal Picross"

    t.console = false
    t.accelerometerjoystick = false
    t.externalstorage = false
    t.gammacorrect = true
    t.audio.mic = false
    
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.video = false
end