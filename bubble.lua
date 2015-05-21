local bubble = {MOD_NAME = 'bubble'}

function bubble:init(lamp)
  lamp.bubbleCount    = 5
  lamp.bubbleUpdateOn = {0, 0, 0, 0, 0}
  lamp.bubbleTimers   = {0, 0, 0, 0, 0}
  lamp.bubbleLeds     = {0, 0, 0, 0, 0}
  lamp:glamp('bubble')
end

flashMod(bubble)

local lamp = {MOD_NAME = 'lamp'}

function lamp:bubble(delta)
  local show = false
  local led
  local bubbleCount    = self.bubbleCount
  local bubbleUpdateOn = self.bubbleUpdateOn
  local bubbleTimers   = self.bubbleTimers
  local bubbleLeds     = self.bubbleLeds
  local lpd            = self.lpd
  local led_count      = lpd.led_count

  for i = 1, bubbleCount do
    if bubbleUpdateOn[i] == 0 then
      bubbleUpdateOn[i] = math.random(30, 150)
    end

    bubbleTimers[i] = bubbleTimers[i] + delta

    if bubbleTimers[i] > bubbleUpdateOn[i] then
      bubbleTimers[i] = bubbleTimers[i] - bubbleUpdateOn[i]
      led = bubbleLeds[i]
      if led > 0 then
        lpd:setPixelColor(led - 1, 0, 0, 0)
      end
      if led < led_count then
        lpd:setPixelColor(led, 0, 0, 20)
        bubbleLeds[i] = led + 1
      else
        -- reset
        bubbleLeds[i]     = 0
        bubbleUpdateOn[i] = 0
        bubbleTimers[i]   = 0
      end
      show = true
    end
  end
  if show then
    lpd:show()
  end
end

flashMod(lamp)
