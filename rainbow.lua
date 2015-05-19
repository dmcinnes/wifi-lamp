local rainbow = {MOD_NAME = 'rainbow'}

function rainbow:init(lamp)
  lamp.rainbowDelay   = 50
  lamp.rainbowOffset  = 0
  lamp.rainbowTimeout = 0
  lamp:glamp('rainbow')
  lamp:glamp('rainbow_cycle')
end

flashMod(rainbow)

local lamp = {MOD_NAME = 'lamp'}

function lamp:rainbow_cycle(delta)
  local rainbowDelay   = self.rainbowDelay
  local rainbowOffset  = self.rainbowOffset
  local rainbowTimeout = self.rainbowTimeout
  local wheel          = self.wheel
  local lpd            = self.lpd
  local led_count      = lpd.led_count

  rainbowTimeout = rainbowTimeout + delta
  if rainbowTimeout > rainbowDelay then
    rainbowTimeout = rainbowTimeout - rainbowDelay
    rainbowOffset = rainbowOffset + 1
    if rainbowOffset > 384 then
      rainbowOffset = 0
    end

    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel(self, ((i * 384 / led_count) + rainbowOffset) % 384))
    end
    self.rainbowTimeout = rainbowTimeout
    self.rainbowOffset  = rainbowOffset
    lpd:show() -- write all the pixels out
  end
end

function lamp:rainbow(delta)
  local rainbowDelay   = self.rainbowDelay
  local rainbowOffset  = self.rainbowOffset
  local rainbowTimeout = self.rainbowTimeout
  local wheel          = self.wheel
  local lpd            = self.lpd
  local led_count      = lpd.led_count

  rainbowTimeout = rainbowTimeout + delta
  if rainbowTimeout > rainbowDelay then
    rainbowTimeout = rainbowTimeout - rainbowDelay
    rainbowOffset = rainbowOffset + 1
    if rainbowOffset > 384 then
      rainbowOffset = 0
    end
    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel(self, (i + rainbowOffset) % 384))
    end
    self.rainbowTimeout = rainbowTimeout
    self.rainbowOffset  = rainbowOffset
    lpd:show()
  end
end

flashMod(lamp)
