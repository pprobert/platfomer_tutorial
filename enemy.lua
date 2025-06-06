

local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")

local Sound = require("sound")

local ActiveEnemies = {}


function Enemy.new(x,y, world)
    local instance = setmetatable({}, Enemy)
    instance.x = x 
    instance.y = y 
    instance.offsetY = 8
    instance.r = 0
    
    instance.speed = 100
    instance.speedMod = 1
    instance.xVel = instance.speed

    instance.rageCounter = 0 
    instance.rageTrigger = 3

    instance.damage = 1

    instance.width = Enemy.width
    instance.height = Enemy.height

    instance.state = "walk"

    instance.isMovingSoundPlaying = false
    instance.soundChannel = "enemy" .. tostring(#ActiveEnemies + 1) -- unique per enemy


    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.run = {total = 4, current = 1, img = Enemy.runAnim}
    instance.animation.walk = {total = 4, current = 1, img = Enemy.walkAnim}
    instance.animation.draw = instance.animation.walk.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
    instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setMass(25)
    table.insert(ActiveEnemies, instance)
end

function Enemy.loadAssests()
    Enemy.runAnim = {}
    for i = 1,4 do
        Enemy.runAnim[i] = love.graphics.newImage("assests/enemy/run/run"..i..".png")
    end
    Enemy.walkAnim = {}
    for i = 1,4 do
        Enemy.walkAnim[i] = love.graphics.newImage("assests/enemy/walk/walk"..i..".png")
    end

    Enemy.width = Enemy.runAnim[1]:getWidth()
    Enemy.height = Enemy.runAnim[1]:getHeight()

end

function Enemy:update(dt)
    self:synchPhysics()
    self:updateAnimation(dt)

    local soundID = (self.state == "run") and "enemy_run" or "enemy_walk"
    local isMoving = math.abs(self.xVel) > 0

    if isMoving then
        if not self.isMovingSoundPlaying then
            Sound:play(soundID, self.soundChannel, 0.4, 1, true) -- volume=0.4, loop=true
            self.isMovingSoundPlaying = true
        end
    else
        if self.isMovingSoundPlaying then
            Sound:stop(self.soundChannel)
            self.isMovingSoundPlaying = false
        end
    end
end


function Enemy:incrementRage()
    self.rageCounter = self.rageCounter + 1
    if self.rageCounter > self.rageTrigger then
        self.state = "run"
        self.speedMod = 3
        self.rageCounter = 0
    else
        self.state = "walk"
        self.speedMod = 1
    end
end

function Enemy:synchPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel * self.speedMod, 100)

end

function Enemy:flipDirection()
    self.xVel = - self.xVel
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

function Enemy.removeAll()
    for i, v in ipairs(ActiveEnemies) do
        Sound:stop(v.soundChannel)
        v.physics.body:destroy()
    end
    ActiveEnemies = {}
end

function Enemy:draw()
    local scaleX = 1
    if self.xVel < 0 then
        scaleX = -1
    end
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function Enemy.updateAll(dt)
    for i,instance in ipairs(ActiveEnemies) do
        instance:update(dt)
    end
end

function Enemy.drawAll()
    for i,instance in ipairs(ActiveEnemies) do
        instance:draw()
    end
end

function Enemy.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveEnemies) do 
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
            end
            instance:incrementRage()
            instance:flipDirection()
        end
    end
end

Enemy.ActiveEnemies = ActiveEnemies

return Enemy
