

local Sun = {img = love.graphics.newImage("assests/sun.png")}
Sun.__index = Sun

Sun.width = Sun.img:getWidth()
Sun.height = Sun.img:getHeight()

local ActiveSuns = {}


function Sun.new(x,y, world)
    
    local instance = setmetatable({}, Sun)
    instance.x = x 
    instance.y = y 
    instance.r = 0
    instance.scaleX = 1
    

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    table.insert(ActiveSuns, instance)
end

function Sun.removeAll()
    for i,v in ipairs(ActiveSuns) do
        v.physics.body:destroy()
    end

    ActiveSuns = {}
end

function Sun:update(dt)
    self:synchPhysics()
end

function Sun:synchPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function Sun:draw()
    love.graphics.draw(Sun.img, self.x, self.y, self.r, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Sun.updateAll(dt)
    for i,instance in ipairs(ActiveSuns) do
        instance:update(dt)
    end
end

function Sun.drawAll()
    for i,instance in ipairs(ActiveSuns) do
        instance:draw()
    end
end

Sun.ActiveSuns = ActiveSuns

return Sun