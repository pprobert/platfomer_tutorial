local Map = {}
local STI = require("sti")
local Coin = require("coin")
local Spike = require("spikes")
local Stone = require("stone")
local Enemy = require("enemy")
local Player = require("player")
local Sun = require("sun")

local TILE_SIZE = 16

function Map:load(world)
    self.currentLevel = 1
    self.world = world or love.physics.newWorld(0, 2000)
    self.world:setCallbacks(beginContact, endContact)
    self:init()
end

function Map:init()
    self.level = STI("map/" .. self.currentLevel .. ".lua", { "box2d" })
    self.level:box2d_init(self.world)

    -- Defensive checks
    assert(self.level.layers.solid, "Missing 'solid' layer in map.")
    assert(self.level.layers.ground, "Missing 'ground' layer in map.")
    assert(self.level.layers.entities, "Missing 'entities' layer in map.")

    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entitiesLayer = self.level.layers.entities

    self.solidLayer.visible = false
    self.entitiesLayer.visible = false

    self.mapWidth = self.groundLayer.width * TILE_SIZE

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
    Sun.removeAll()
end

function Map:update()
    if Player.x > self.mapWidth - TILE_SIZE then
        self:next()
    end
end

function Map:spawnEntities()
    local world = self.world
    for _, v in ipairs(self.entitiesLayer.objects) do
        local cx, cy = v.x + v.width / 2, v.y + v.height / 2
        if v.type == "spikes" then
            Spike.new(cx, cy, self.world)
        elseif v.type == "stone" then
            Stone.new(v.x + v.width / 2, v.y + v.height / 2, self.world)
        elseif v.type == "coin" then
            Coin.new(v.x, v.y, self.world)
        elseif v.type == "enemy" then
            Enemy.new(v.x + v.width / 2, v.y + v.height / 2, self.world)
        elseif v.type == "sun" then
            Sun.new(cx, cy, self.world)
        end
    end
end

return Map
