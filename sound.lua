
local Sound = {active = {}, source = {}}

function Sound:init(id, source, soundType)
    assert(self.source[id] == nil, "Sound with that ID already exists")

    if type(source) == "table" then
        self.source[id] = {}
        for i = 1, #source do
            self.source[id][i] = love.audio.newSource(source[i], soundType)
        end
    else
       self.source[id] = love.audio.newSource(source, soundType)
    end
    
end

function Sound:clean(id)
    self.source[id] = nil
end

function Sound:play(id, channel, volume, pitch, loop)
    local source
    if type(Sound.source[id]) == "table" then
        source = Sound.source[id][math.random(1, #Sound.source[id])]
    else
        source = Sound.source[id]
    end

    local channel = channel or "default"
    local clone = source:clone()
    clone:setVolume(volume or 1)
    clone:setPitch(pitch or 1)
    clone:setLooping(loop or false)
    clone:play()

    if Sound.active[channel] == nil then
        Sound.active[channel] = {}
    end

    table.insert(Sound.active[channel], clone)

    return clone
end

function Sound:setVolume(channel, volume)  
    assert(Sound.active[channel] ~= nil, "Channel doesn't exist")
    for k, sound in pairs(Sound.active[channel]) do
        sound:setVolume(volume)
    end
end

function Sound:setPitch(channel, pitch)  
    assert(Sound.active[channel] ~= nil, "Channel doesn't exist")
    for k, sound in pairs(Sound.active[channel]) do
        sound:setPitch(pitch)
    end
end

function Sound:isPlaying(name, category)
    local snd = self[category][name] or self.sfx[name]
    return snd and snd:isPlaying()
end

function Sound:stop(channel)
    assert(Sound.active[channel] ~= nil, "Channel doesn't exist")
    for k, sound in pairs(Sound.active[channel]) do
        sound:stop()
    end
end

function Sound:update()
    for k,channel in pairs(Sound.active) do 
        if channel[1] ~= nil and not channel[1]:isPlaying() then
            table.remove(channel, 1)
        end
    end
end

function Sound:setLooping(loop)
    for _, snd in pairs(self.sfx) do
        snd:setLooping(loop)
    end
end

return Sound