

local Spike = {img = love.graphics.newImage("assests/spikes.png")}
Spike.__index = Spike

Spike.width = Spike.img:getWidth()
Spike.height = Spike.img:getHeight()

local ActiveSpikes = {}
local Player = require("player")

function Spike.new(x,y, world)
    local instance = setmetatable({}, Spike)
    instance.x = x 
    instance.y = y 
    
    instance.scaleX = 1

    instance.damage = 1

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(Spike.width, Spike.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveSpikes, instance)
end

function Spike.removeAll()
    for i,v in ipairs(ActiveSpikes) do
        v.physics.body:destroy()
    end

    ActiveSpikes = {}
end

function Spike:update(dt)
    self.x, self.y = self.physics.body:getPosition()
end

function Spike:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Spike.updateAll(dt)
    for i,instance in ipairs(ActiveSpikes) do
        instance:update(dt)
    end
end

function Spike.drawAll()
    for i,instance in ipairs(ActiveSpikes) do
        instance:draw()
    end
end

function Spike.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveSpikes) do 
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
                return true
            end
        end
    end
end

return Spike