local Stone = {}
Stone.__index = Stone

Stone.img = love.graphics.newImage("assests/stone.png")
Stone.width = Stone.img:getWidth()
Stone.height = Stone.img:getHeight()

local ActiveStones = {}
Stone.ActiveStones = ActiveStones

function Stone.new(x, y, world)
    local instance = setmetatable({}, Stone)

    instance.x = x
    instance.y = y
    instance.scaleX = 1

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, x, y, "static")
    instance.physics.shape = love.physics.newRectangleShape(Stone.width, Stone.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    table.insert(ActiveStones, instance)
    return instance
end

function Stone.removeAll()
    for i, v in ipairs(ActiveStones) do
        v.physics.body:destroy()
    end
    ActiveStones = {}
    Stone.ActiveStones = ActiveStones -- Keep external reference updated
end

function Stone:update(dt)
    self:synchPhysics()
end

function Stone:synchPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function Stone:draw()
    love.graphics.draw(Stone.img, self.x, self.y, self.r, self.scaleX, 1, Stone.width / 2, Stone.height / 2)
end

function Stone.updateAll(dt)
    for i, instance in ipairs(ActiveStones) do
        instance:update(dt)
    end
end

function Stone.drawAll()
    for i, instance in ipairs(ActiveStones) do
        instance:draw()
    end
end

return Stone