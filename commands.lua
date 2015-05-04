Server.cmd('restart', function ()
  tmr.alarm(0, 100, 0, function ()
    node.restart()
  end)
end)

Server.cmd('telnet', function ()
  tmr.alarm(0, 100, 0, function ()
    -- need to close web server for this
    Server.server:close()
    require 'telnet'
  end)
end)
