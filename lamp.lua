LPD8806 = require('LPD8806')

led_count = 16
lpd = LPD8806.new(led_count, 3, 4)
lpd:show()

-- Input a value 0 to 384 to get an rgb color value.
function wheel(wheelPos)
  local r, g, b
  local switch = wheelPos / 128
  if switch == 0 then
    r = 127 - wheelPos % 128 -- Red down
    g = wheelPos % 128       -- Green up
    b = 0                    -- blue off
  elseif switch == 1 then
    g = 127 - wheelPos % 128 -- green down
    b = wheelPos % 128       -- blue up
    r = 0                    -- red off
  else
    b = 127 - wheelPos % 128 -- blue down
    r = wheelPos % 128       -- red up
    g = 0                    -- green off
  end
  return r, g, b
end

local rainbowDelay   = 50;
local rainbowOffset  = 0;
local rainbowTimeout = 0;
function rainbowCycle(delta)
  local i, j, r, g, b;

  rainbowTimeout = rainbowTimeout + delta
  if (rainbowTimeout > rainbowDelay) then
    rainbowTimeout = rainbowTimeout - rainbowDelay
    rainbowOffset = rainbowOffset + 1
    if (rainbowOffset > 384) then
      rainbowOffset = 0
    end

    for i=0, led_count-1 do
      r, g, b = wheel( ((i * 384 / led_count) + rainbowOffset) % 384)
      lpd:setPixelColor(i, r, g, b)
    end

    lpd:show() -- write all the pixels out
  end
end

local currentFunc = rainbowCycle
local lastTime    = tmr.now()
local currentTime
tmr.alarm(0, 50, 1, function()
  currentTime = tmr.now()
  currentFunc(currentTime - lastTime)
  lastTime = currentTime
end)
