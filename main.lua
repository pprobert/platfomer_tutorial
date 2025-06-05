
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
local Sun = require("sun")


local shader_code = [[
#define NUM_LIGHTS 32
struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};

extern Light lights[NUM_LIGHTS];
extern int num_lights;
extern vec2 screen;

const float constant = 1.0;
const float linear = 0.02;
const float quadratic = 0.005;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {
    vec4 pixel = Texel(image, uvs);

    vec2 norm_screen = screen_coords / screen;
    vec3 ambient = vec3(0.1, 0.1, 0.1); // light gray ambient base
    vec3 diffuse = ambient;

    for (int i = 0; i < num_lights; i++){
        Light light = lights[i];
        vec2 norm_pos = light.position / screen;

        float distance = length(norm_pos - norm_screen) * light.power;
        float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));

        diffuse += light.diffuse * attenuation;
    }

    diffuse = clamp(diffuse, 0.0, 1.0);

    return pixel * vec4(diffuse, 1.0);
}
]]

local shader = nil
local image = nil

local world = love.physics.newWorld(0, 500, true)

function love.load()
    canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    shader = love.graphics.newShader(shader_code)
    Enemy.loadAssests()
    Player:load(world)
    Map:load(world)
    Camera:setMapWidth(Map.mapWidth or 2000)
    Camera:setPosition(Player.x, Player.y)
    background = love.graphics.newImage("assests/background.png")
    image = background
    GUI:load()
    Sound:init("jump", "sfx/Jump_2.wav", "static")
    Sound:init("coin", "sfx/Collectible_1.wav", "static")
    Sound:init("hit", "sfx/Hit_4.wav", "static")
    Sound:init("death", "sfx/Loose_1.wav", "static")
    Sound:init("run", "sfx/Grass_FS_1.wav", "static")
    Sound:init("enemy_walk", "sfx/Grass_FS_3.wav", "static")
    Sound:init("enemy_run", "sfx/Grass_FS_5.wav", "static")
end

function love.update(dt)
    Map.world:update(dt)
    Player:update(dt)
    Coin.updateAll(dt)
    Spike.updateAll(dt)
    Stone.updateAll(dt)
    Enemy.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, 0)
    Map:update(dt)
    Sun.updateAll(dt)
    Sound:update()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.draw(background, -Camera.x * 0.5, 0)
    Camera:apply()
    Map.level:draw(0, 0, Camera.scale, Camera.scale) 
    Player:draw()
    Coin.drawAll()
    Spike.drawAll()
    Stone.drawAll()
    Enemy.drawAll()
    Sun.drawAll()
    Camera:clear()
    love.graphics.setCanvas()

    shader:send("screen", {
        love.graphics.getWidth(), love.graphics.getHeight()
    })

    local max_lights = 32
    local lights = {}

    -- Add player light first
    table.insert(lights, {
        position = {Camera:worldToScreen(Player.x, Player.y)},
        diffuse = {1.0, 1.0, 1.0},
        power = 48
    })

    -- Add enemy lights
    for i, enemy in ipairs(Enemy.ActiveEnemies) do
        if #lights >= max_lights then break end
        local ex, ey = Camera:worldToScreen(enemy.x, enemy.y)
        table.insert(lights, {
            position = {ex, ey},
            diffuse = {1.0, 0.5, 0.5}, -- example reddish light
            power = 48
        })
    end

    for i, sun in ipairs(Sun.ActiveSuns) do
        if #lights >= max_lights then break end
        local sx, sy = Camera:worldToScreen(sun.x, sun.y)
        table.insert(lights, {
            position = {sx, sy},
            diffuse = {4.0, 3.6, 2.4}, -- 
            power = 512
        })
    end

    -- Send number of lights to shader
    shader:send("num_lights", #lights)

    -- Send each light's data to the shader uniforms
    for i, light in ipairs(lights) do
        shader:send("lights["..(i-1).."].position", light.position)
        shader:send("lights["..(i-1).."].diffuse", light.diffuse)
        shader:send("lights["..(i-1).."].power", light.power)
    end

    love.graphics.setShader(shader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

    GUI:draw()
end


function love.resize(w, h)
    canvas = love.graphics.newCanvas(w, h)
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

