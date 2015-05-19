dofile('flashmod.lc')
dofile('LLbin.lc')

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

-- flashMod('rainbow'):init(lamp)
