local LPD8806 = require('LPD8806')

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

function clear()
  for i=0, led_count-1 do
    lpd:setPixelColor(i, 0, 0, 0)
  end
  lpd:show()
end

function glamp(name)
  Server.cmd(name, function()
    clear()
    currentFunc = _G[name]
  end)
end

function blank(delta)
end

require 'rainbow'
-- require 'bubble'


glamp('blank')
glamp('rainbow')
glamp('rainbow_cycle')
glamp('bubble')

currentFunc = rainbow_cycle

local lastTime = tmr.now()
local currentTime, success, message
tmr.alarm(0, 50, 1, function()
  currentTime = tmr.now()
  currentFunc(currentTime - lastTime)
  lastTime = currentTime
end)
