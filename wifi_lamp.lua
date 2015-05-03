server = net.createServer(net.TCP)
server:listen(80, function(conn)
  local total, query, path, headers, expect

  conn:on("receive", function(conn, payload)
    if payload:match("^PUT") or payload:match("^POST") then
      query, path, headers = parseHeaders(payload)
      print("Request: "..query)

      expect = headers["Expect"]
      if expect and expect:match("^100") then
        total = tonumber(headers["Content-Length"])
        file.open(path:gsub('^/', ''), 'w')
        response(conn, '100 Continue')
      else
        ok(conn)
        close(conn)
      end
    else
      file.write(payload)
      total = total - payload:len()
      if total <= 0 then
        file.close()
        response(conn, '201 Created')
        close(conn)
      end
    end
  end)
end)

function parseHeaders(payload)
  local headers = {}
  local query = false
  local path, header, value
  for line in payload:gmatch("([^\r\n]+)") do
    if not query then
      query = line
      path  = query:match("(/[^ ]*)")
    else
      header = line:gsub(":.*$", "")
      value  = line:gsub("^[^:]*: ", "")
      headers[header] = value
    end
  end
  return query, path, headers
end

function response(conn, code)
  print(code)
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