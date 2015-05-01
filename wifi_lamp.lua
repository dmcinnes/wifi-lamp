server = net.createServer(net.TCP)
server:listen(80,function(conn)
  conn:on("receive", function(conn, payload)
    if payload:match("^PUT") or payload:match("^POST") then
      local query, headers = parseHeaders(payload)
      print("Query: "..query)
      for header,value in pairs(headers) do
        print(header.."="..value)
      end

      if headers["Expect"]:match("^100") then
        response(conn, '100 Continue')
      else
        ok(conn)
        close(conn)
      end
    else
      print(payload)
      print('data?')
      response(conn, '201 Created')
      close(conn)
    end
  end)
end)

function parseHeaders(payload)
  local headers = {}
  local query = false
  local header, value
  for line in payload:gmatch("([^\r\n]+)") do
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

function response(conn, code)
  conn:send("HTTP/1.1 "..code.."\r\n")
end

function ok(conn)
  response(conn, '200 OK')
end

function close(conn)
  conn:on("sent", function(conn)
    conn:close()
  end)
end
