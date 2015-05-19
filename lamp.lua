local lamp = {MOD_NAME = 'lamp'}

function lamp:init(server, LPD8806)
  self.server = server

  self.led_count = 16
  self.lpd = LPD8806.new(self.led_count, 3, 4)
  self.lpd:show()

  self:glamp('blank')
  self.currentFunc = self.blank

  self.lastTime    = tmr.now()
  self.currentTime = nil

  -- pre-load wheel
  self.wheel = self.wheel
end

-- Input a value 0 to 384 to get an rgb color value.
function lamp:wheel(wheelPos)
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

function lamp:clear(lpd)
  local lpd = self.lpd
  for i=0, lpd.led_count-1 do
    lpd:setPixelColor(i, 0, 0, 0)
  end
  lpd:show()
end

function lamp:blank(delta)
end

function lamp:glamp(name)
  local lamp = self
  self.server:cmd(name, function ()
    lamp:clear()
    lamp.currentFunc = nil
    collectgarbage()
    lamp.currentFunc = lamp[name]
  end)
end

function lamp:run()
  self.currentTime = tmr.now()
  self.currentFunc(self, self.currentTime - self.lastTime)
  self.lastTime = self.currentTime
end

-- function lamp:run()
--   tmr.alarm(0, 50, 1, function()
--     currentTime = tmr.now()
--     currentFunc(currentTime - lastTime)
--     lastTime = currentTime
--   end)
-- end

flashMod(lamp)
