server:cmd('restart', function ()
  tmr.alarm(0, 100, 0, function ()
    node.restart()
  end)
end)

server:cmd('telnet', function ()
  tmr.alarm(0, 100, 0, function ()
    -- need to close web server for this
    tcp:close()
    require 'telnet'
  end)
end)
