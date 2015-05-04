LPD8806 = require('LPD8806')

led_count = 16
lpd = LPD8806.new(led_count, 3, 4)
lpd:show()

-- Input a value 0 to 384 to get an rgb color value.
function wheel(wheelPos)
  local r, g, b
  local switch = WheelPos / 128
  if switch == 0 then
    r = 127 - WheelPos % 128 -- Red down
    g = WheelPos % 128       -- Green up
    b = 0                    -- blue off
  elseif switch == 1 then
    g = 127 - WheelPos % 128 -- green down
    b = WheelPos % 128       -- blue up
    r = 0                    -- red off
  else
    b = 127 - WheelPos % 128 -- blue down
    r = WheelPos % 128       -- red up
    g = 0                    -- green off
  end
  return r, g, b
end

local rainbowDelay   = 50;
local rainbowOffset  = 0;
local rainbowTimeout = 0;
function rainbowCycle(delta)
  local i, j;

  rainbowTimeout = rainbowTimeout + delta
  if (rainbowTimeout > rainbowDelay) then
    rainbowTimeout = rainbowTimeout - rainbowDelay
    rainbowOffset = rainbowOffset + 1
    if (rainbowOffset > 384) then
      rainbowOffset = 0
    end

    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel( ((i * 384 / led_count) + rainbowOffset) % 384) )
    end

    lpd:show() -- write all the pixels out
  end
end

local currentFunc = rainbowCycle
local currentTime, lastTime = tmr.now()
tmr.alarm(0, 50, 1, function()
  currentTime = tmr.now()
  if currentFunc then
    pcall(currentFunc, lastTime - currentTime)
  end
  lastTime = currentTime
end)
