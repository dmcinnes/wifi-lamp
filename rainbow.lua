local rainbowDelay   = 50;
local rainbowOffset  = 0;
local rainbowTimeout = 0;
function rainbowCycle(delta)
  local i, j;

  rainbowTimeout = rainbowTimeout + delta
  if rainbowTimeout > rainbowDelay then
    rainbowTimeout = rainbowTimeout - rainbowDelay
    rainbowOffset = rainbowOffset + 1
    if rainbowOffset > 384 then
      rainbowOffset = 0
    end

    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel(((i * 384 / led_count) + rainbowOffset) % 384))
    end

    lpd:show() -- write all the pixels out
  end
end

function rainbow(delta)
  local i

  rainbowTimeout = rainbowTimeout + delta
  if rainbowTimeout > rainbowDelay then
    rainbowTimeout = rainbowTimeout - rainbowDelay
    rainbowOffset = rainbowOffset + 1
    if rainbowOffset > 384 then
      rainbowOffset = 0
    end
    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel( (i + rainbowOffset) % 384))
    end
    lpd:show()
  end
end

function blank(delta)
end
