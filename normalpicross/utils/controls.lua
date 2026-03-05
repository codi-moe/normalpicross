local controls = {}

function controls.isprimary(key, scancode)
    return key == 'space' or key == 'return'
        or scancode == 'e' or scancode == 'z'
end

function controls.issecondary(key, scancode)
    return key == 'backspace' or key == 'lshift' or key == 'rshift'
        or scancode == 'q' or scancode == 'x'
end

function controls.ismenu(key, scancode)
    return key == 'escape' or scancode == 'c'
end

function controls.isup(key, scancode)
    return key == 'up' or scancode == 'w'
end

function controls.isdown(key, scancode)
    return key == 'down' or scancode == 's'
end

function controls.isleft(key, scancode)
    return key == 'left' or scancode == 'a'
end

function controls.isright(key, scancode)
    return key == 'right' or scancode == 'd'
end

return controls
