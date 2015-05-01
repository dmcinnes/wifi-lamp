server = net.createServer(net.TCP)
server:listen(80,function(conn)
  conn:on("receive", function(conn, payload)
    print(payload)
    conn:send("HTTP/1.1 200 OK\n\n")
    if payload:find("^PUT") or payload:find("^POST") then
      local query, headers = parseHeaders(payload)
      print("Query: "..query)
      for header,value in pairs(headers) do
        print(header.."="..value)
      end
      if headers["Expect"] == "100-continue" then
        continue(conn)
      else
        ok(conn)
      end
    else
      print('data?')
      ok(conn)
    end
  end)
  conn:on("sent", function(conn)
    conn:close()
  end)
end)

function parseHeaders(payload)
  local headers = {}
  local query = false
  local header, value
  for line in payload:gmatch("([^\n\r]+)") do
    if not query then
      query = line
    else
      header = line:gsub(":.*$", "")
      value  = line:gsub("^[^:]*: ", "")
      headers[header] = value
    end
  end
  return query, headers
end

function ok(conn)
  conn:send("HTTP/1.1 200 OK\n\n")
end

function continue(conn)
  conn:send("HTTP/1.1 100 Continue\n\n")
end
