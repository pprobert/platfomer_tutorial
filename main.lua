love.graphics.setDefaultFilter("nearest", "nearest")

local Player = require("player")
local Coin = require("coin")
local GUI = require("gui")
local Spike = require("spikes")
local Stone = require("stone")
local Camera = require("camera")
local Enemy = require("enemy")
local Map = require("map")
local Sound = require("sound")

function love.load()
    Enemy.loadAssests()
    Map:load()
    background = love.graphics.newImage("assests/background.png")
    GUI:load()
    Player:load()
    Sound:init("jump", "sfx/Jump_2.wav", "static")
    Sound:init("coin", "sfx/Collectible_1.wav", "static")
    Sound:init("hit", "sfx/Hit_4.wav", "static")
    Sound:init("death", "sfx/Loose_1.wav", "static")
    Sound:init("run", "sfx/Grass_FS_1.wav", "static")
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
    Map:update(dt)
    Sound:update()
end

function love.draw()
    love.graphics.draw(background)
    Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
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
    Enemy.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

