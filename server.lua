local S = {}
local Server = S

function S.parseHeaders(payload)
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

function S.response(conn, code)
  print(code)
  conn:send("HTTP/1.1 "..code.."\r\n")
end

function S.ok(conn)
  S.response(conn, '200 OK')
end

function S.close(conn)
  conn:on("sent", function(conn)
    conn:close()
  end)
end

S.server = net.createServer(net.TCP)
S.server:listen(80, function(conn)
  local query, path, headers, total, filename, expect

  conn:on("receive", function(conn, payload)
    if payload:match("^PUT") or payload:match("^POST") then
      query, path, headers = S.parseHeaders(payload)
      print("Request: "..query)

      expect = headers["Expect"]
      if expect and expect:match("^100") then
        total = tonumber(headers["Content-Length"])
        filename = path:gsub('^/', '')
        file.open(filename, 'w')
        S.response(conn, '100 Continue')
      else
        ok(conn)
        S.close(conn)
      end
    else
      file.write(payload)
      total = total - payload:len()
      if total <= 0 then
        file.close()
        payload = nil -- clear out some memory
        success, message = pcall(node.compile, filename)
        if success then
          S.response(conn, '201 Created')
        else
          S.response(conn, '422 Unprocessable Entity')
          conn:send('\r\nCompile Failed: '..message..'\r\n')
        end
        S.close(conn)
      end
    end
  end)
end)

return Server
