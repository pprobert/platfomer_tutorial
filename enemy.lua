

local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")



local ActiveEnemys = {}


function Enemy.new(x,y)
    local instance = setmetatable({}, Enemy)
    instance.x = x 
    instance.y = y 
    instance.r = 0
    instance.scaleX = 1
    
    instance.state = "walk"

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.run = {total = 4, current = 1, img = Enemy.runAnim}
    instance.animation.walk = {total = 4, current = 1, img = Enemy.walkAnim}
    instance.animation.draw = instance.animation.walk.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setMass(25)
    table.insert(ActiveEnemys, instance)
end

function Enemy.loadAssests()
    Enemy.runAnim = {}
    for i = 1,4 do
        Enemy.runAnim[i] = love.graphics.newImage("assests/enemy/run/"..i..".png")
    end
    Enemy.walkAnim = {}
    for i = 1,4 do
        Enemy.walkAnim[i] = love.graphics.newImage("assests/enemy/walk/"..i..".png")
    end

    Enemy.width = Enemy.runAnim[1]:getWidth()
    Enemy.height = Enemy.runAnim[1]:getHeight()
end

function Enemy:update(dt)
    self:synchPhysics()
    self:updateAnimation(dt)
end

function Enemy:synchPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function Enemy:updateAnimation(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Enemy:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end


function Enemy:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Enemy.updateAll(dt)
    for i,instance in ipairs(ActiveEnemys) do
        instance:update(dt)
    end
end

function Enemy.drawAll()
    for i,instance in ipairs(ActiveEnemys) do
        instance:draw()
    end
end

return Enemy