--[[
little pomodoro timer script to go off on a configurable interval
based on https://gist.github.com/1bardesign/fac82485d67b8d97f6a38a68f685b5be#file-main-lua-L31
]]
require 'love'

local intervals = {
{"work", 25},
{"rest", 5},
}

local t = 0
local i = 0

local limit = 0
local label = ""

love.graphics.setFont(love.graphics.newFont(32))
local nosoundImg = love.graphics.newImage('nosound.png')
local sound = true

-- generate beep audio
local rate = 44100
local duration = 1.0
local freq_a = 440
local freq_b = 440 * 2
local samples = rate * duration
local beep: love.audio.Source -- = love.sound.newSoundData(samples, rate, 16, 1 )
local selectedBorder = false

local function genBeep(): love.sound.SoundData
    local beepData = love.sound.newSoundData(samples, rate, 16, 1 )
    for i = 1, samples do
        local lt = i / rate
        local note = ((1 - (i / samples)) * 2)
        local note_vol = note % 1
        local freq = note < 1 and freq_a or freq_b
        local a = math.sin(lt * freq * math.pi * 2)
        local b = (a * a) * 2 - 1
        local v = a * b * note_vol
        beepData:setSample(i - 1, 1, v)
    end
    return beepData
end

beep = love.audio.newSource(genBeep())

--function love.update(dt)
love.update = function(dt: number)
    t = t - dt
    if t <= 0 then
        --beep
        beep:seek(0)
        if sound then
            beep:play()
        end
        --next interval
        i = i + 1
        if i > #intervals then
            i = 1
        end
        local cfg = intervals[i]
        label = cfg[1]
        limit = cfg[2] * 60
        t = limit
    end
    local mx, my = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    --print(mx, my, )
    if mx > 0 and my > 0 and mx < w and my < h then
        selectedBorder = true
    else
        selectedBorder = false
    end
end

local mode = "grey"

function love.draw()
    --love.graphics.setColor(0.5, 0.5, 0.5, 1.0)
    if label == "work" then
        love.graphics.setColor(1.0, 0.0, 0., 1.)
    elseif label == "rest" then
        love.graphics.setColor(0., 1., 0., 1.)
    end
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth() * t / limit, love.graphics.getHeight())

    print("selectedBorder", selectedBorder )
    --love.graphics.setColor(.0, .0, .0, 1.0)
    --love.graphics.rectangle("line", 0, 0, love.graphics.getWidth() * t / limit, love.graphics.getHeight())

    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    print('label', label)
    love.graphics.printf( label, 0, 10, love.graphics.getWidth(), "center")

    if not sound then
        love.graphics.draw(nosoundImg as love.graphics.Drawable, 0, 0)
    end
end

function love.keypressed(k: love.keyboard.KeyConstant)
--love.keypressed = function(k: string)
    if k == "n" or k == "space" then
        --skip to next
        t = 0
    end
    if k == "r" then
        mode = "red"
    elseif k == "g" then
        mode = "gray"
    end
    if k == "escape" then
        love.event.quit()
    end
    if k == 's' then
        sound = not sound
    end
    if love.keyboard.isDown("lctrl") then
        if k == "q" then
            love.event.quit()
        elseif k == "r" then
            love.event.quit("restart")
        end
    end
end

function love.mousemoved(_: number, _: number, dx: number, dy: number)
    print("m", dx, dy)
end
