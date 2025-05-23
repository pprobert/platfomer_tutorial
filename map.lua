local Map = {}
local STI = require("sti")
local Coin = require("coin")
local Spike = require("spikes")
local Stone = require("stone")
local Enemy = require("enemy")
local Player = require("player")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)
   
    self:init()
end

function Map:init()
    self.level = STI("map/"..self.currentLevel..".lua", {"box2d"})
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entitiesLayer = self.level.layers.entities
    self.solidLayer.visible = false
    self.entitiesLayer.visible = false
    MapWidth = self.groundLayer.width * 16

    self:spawnEntities()
end

function Map:next()
    self:clean()
    self.currentLevel = self.currentLevel + 1
    self:init()
    Player:resetPosition()
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    Coin.removeAll()
    Enemy.removeAll()
    Spike.removeAll()
    Stone.removeAll()
end

function Map:update()
    if Player.x > MapWidth - 16 then
        self:next()
    end
end

function Map:spawnEntities()
    for i,v in ipairs(self.entitiesLayer.objects) do
        if v.type ==  "spikes" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2, World)
        elseif v.type == "stone" then
            Stone.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin.new(v.x, v.y)
        elseif v.type == "enemy" then
            Enemy.new(v.x + v.width / 2, v.y + v.height / 2, World)
        end
    end
end

return Map