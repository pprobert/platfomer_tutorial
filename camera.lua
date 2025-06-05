

local Camera = {
    x = 0,
    y = 0, 
    scale = 2,
    mapWidth = 0
}

function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end

function Camera:setMapWidth(width)
    self.mapWidth = width
end

function Camera:setPosition(x, y)
    self.x = x - love.graphics.getWidth() / 2 / self.scale
    self.y = y 

    local RS = self.x + love.graphics.getWidth() / 2 / self.scale

    if self.x < 0 then
        self.x = 0
    elseif self.mapWidth and RS > self.mapWidth then
        self.x = self.mapWidth - love.graphics.getWidth() / 2 / self.scale
    end
end

function Camera:worldToScreen(wx, wy)
    local sx = (wx - self.x) * self.scale
    local sy = (wy - self.y) * self.scale
    return sx, sy
end

return Camera