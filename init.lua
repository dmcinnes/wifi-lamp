dofile('flashmod.lc')

server = flashMod('server')
server:init()
tcp = net.createServer(net.TCP)
tcp:listen(80, function(conn)
  conn:on('receive', function(conn, payload)
    server:receiver(conn, payload)
  end)
end)

dofile('commands.lc')

LPD8806 = dofile('LPD8806.lc')
lamp = flashMod('lamp')
lamp:init(server, LPD8806)

-- clear up some space
LPD8806.new         = nil
LPD8806.setup       = nil
LPD8806.resetCursor = nil

flashMod('rainbow'):init(lamp)

runner = lamp.run
tmr.alarm(0, 50, 1, function()
  runner(lamp)
end)
