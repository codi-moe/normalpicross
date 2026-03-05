local Picross = {}
Picross.__index = Picross

function Picross:new(options)
    if #options.cols ~= options.w then
        error "Mismatched number of cols and width"
    end
    if #options.rows ~= options.h then
        error "Mismatched number of rows and height"
    end

    local grid = {}

    return setmetatable({
        w = options.w,
        h = options.h,
        cols = options.cols,
        rows = options.rows,
        grid = grid,
    }, self)
end

function Picross:check()
    local errors = {}

    for i, col in pairs(self.cols) do

    end
    for i, row in pairs(self.rows) do

    end

    if #errors == 0 then
        return true
    else
        return nil, errors
    end
end

function Picross:get(x, y)
    return self[x .. ',' .. y] or ' '
end

function Picross:set(x, y, v)
    self[x .. ',' .. y] = v
end

return Picross
