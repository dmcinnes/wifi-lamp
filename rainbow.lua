local lamp = {MOD_NAME = 'lamp'}

function lamp:rainbow_init()
  self.rainbowDelay   = 50;
  self.rainbowOffset  = 0;
  self.rainbowTimeout = 0;
end

function lamp:rainbow_cycle(lpd, delta)
  local rainbowDelay   = self.rainbowDelay;
  local rainbowOffset  = self.rainbowOffset;
  local rainbowTimeout = self.rainbowTimeout;
  local led_count      = lpd.led_count;

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

function lamp:rainbow(lpd, delta)
  local rainbowDelay   = self.rainbowDelay;
  local rainbowOffset  = self.rainbowOffset;
  local rainbowTimeout = self.rainbowTimeout;

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

flashMod(lamp)
