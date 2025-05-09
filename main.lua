love.graphics.setDefaultFilter("nearest", "nearest")
local STI = require("sti")
local Player = require("player")
local Coin = require("coin")
local GUI = require("gui")
local Spike = require("spikes")
local Stone = require("stone")
local Camera = require("camera")
local Enemy = require("enemy")

function love.load()
    Map = STI("map/firstMap.lua", {"box2d"})
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    Map.layers.solid.visible = false
    Map.layers.entities.visible = false
    MapWidth = Map.layers.ground.width * 16
    background = love.graphics.newImage("assests/background.png")
    GUI:load()
    Enemy.loadAssests()
    Player:load()
    spawnEntities()
end

function love.update(dt)
    World:update(dt)
    Player:update(dt)
    Coin.updateAll(dt)
    Spike.updateAll(dt)
    Stone.updateAll(dt)
    Enemy.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, 0)
    
end

function love.draw()
    love.graphics.draw(background)
    Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
    Camera:apply()
    Player:draw()
    Coin.drawAll()
    Spike.drawAll()
    Stone.drawAll()
    Enemy.drawAll()
    Camera:clear()
    GUI:draw()
end

function love.keypressed(key)
    Player:jump(key)
end

function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if Spike.beginContact(a, b, collision) then return end
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function spawnEntities()
    for i,v in ipairs(Map.layers.entities.objects) do
        if v.type ==  "spikes" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "stone" then
            Stone.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin.new(v.x, v.y)
        elseif v.type == "enemy" then
            Enemy.new(v.x + v.width / 2, v.y + v.height / 2)
        end
    end
end