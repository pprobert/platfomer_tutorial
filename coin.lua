

local Coin = {img = love.graphics.newImage("assests/coin.png")}
Coin.__index = Coin

Coin.width = Coin.img:getWidth()
Coin.height = Coin.img:getHeight()


local ActiveCoins = {}
local Player = require("player")
local Sound = require("sound")

function Coin.new(x, y, world)
    local instance = setmetatable({}, Coin)
    instance.x = x
    instance.y = y

    instance.scaleX = 1
    instance.randomTimeOffset = math.random(0, 100)
    instance.toBeRemoved = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveCoins, instance)
end

function Coin:remove()
    Player:incrementCoins()
    self.physics.body:destroy()
    for i, instance in ipairs(ActiveCoins) do
        if instance == self then
            table.remove(ActiveCoins, i)
            break
        end
    end
    Sound:play("coin", "sfx")
end

function Coin.removeAll()
    for i,v in ipairs(ActiveCoins) do
        v.physics.body:destroy()
    end

    ActiveCoins = {}
end

function Coin:update(dt)
    self:spin(dt)
    self:checkRemove()
end

function Coin:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Coin:spin(dt)
    self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function Coin:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Coin.updateAll(dt)
    for i,instance in ipairs(ActiveCoins) do
        instance:update(dt)
    end
end

function Coin.drawAll()
    for i,instance in ipairs(ActiveCoins) do
        instance:draw()
    end
end

function Coin.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveCoins) do 
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.toBeRemoved = true
                return true
            end
        end
    end
end

return Coin