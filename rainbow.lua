local rainbow = {MOD_NAME = 'rainbow'}

function rainbow:init(lamp)
  self.rainbowDelay   = 50
  self.rainbowOffset  = 0
  self.rainbowTimeout = 0
  self.wheel          = lamp.wheel
  -- lamp:glamp('rainbow', self)
  -- lamp:glamp('rainbow_cycle', self)
end

function rainbow:rainbow_cycle(lpd, delta)
  local rainbowDelay   = self.rainbowDelay
  local rainbowOffset  = self.rainbowOffset
  local rainbowTimeout = self.rainbowTimeout
  local wheel          = self.wheel
  local led_count      = lpd.led_count

  self.rainbowTimeout = rainbowTimeout + delta
  if rainbowTimeout > rainbowDelay then
    self.rainbowTimeout = rainbowTimeout - rainbowDelay
    self.rainbowOffset = rainbowOffset + 1
    if rainbowOffset > 384 then
      self.rainbowOffset = 0
    end

    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel(((i * 384 / led_count) + rainbowOffset) % 384))
    end

    lpd:show() -- write all the pixels out
  end
end

function rainbow:rainbow(lpd, delta)
  local rainbowDelay   = self.rainbowDelay
  local rainbowOffset  = self.rainbowOffset
  local rainbowTimeout = self.rainbowTimeout
  local wheel          = self.wheel
  local led_count      = lpd.led_count

  self.rainbowTimeout = rainbowTimeout + delta
  if rainbowTimeout > rainbowDelay then
    self.rainbowTimeout = rainbowTimeout - rainbowDelay
    self.rainbowOffset = rainbowOffset + 1
    if rainbowOffset > 384 then
      self.rainbowOffset = 0
    end
    for i=0, led_count-1 do
      lpd:setPixelColor(i, wheel( (i + rainbowOffset) % 384))
    end
    lpd:show()
  end
end

flashMod(rainbow)
