local S = {}
local Server = S

S.commands = {}

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

function S.cmd(name, func)
  S.commands[name] = func
end

S.server = net.createServer(net.TCP)
S.server:listen(80, function(conn)
  local query, path, headers, total, filename, expect

  conn:on("receive", function(conn, payload)
    if payload:match("^PUT") or payload:match("^POST") then
      query, path, headers = S.parseHeaders(payload)
      filename = path:gsub('^/', '')
      print("Request: "..query)

      expect = headers["Expect"]
      if expect and expect:match("^100") then
        total = tonumber(headers["Content-Length"])
        file.open(filename, 'w')
        S.response(conn, '100 Continue')
      else
        -- it's POST
        if S.commands[filename] then
          success, message = pcall(S.commands[filename])
          if success then
            S.ok(conn)
          else
            S.response(conn, '500 Server Error')
            conn:send(message..'\r\n')
          end
        else
          S.response(conn, '404 Not Found')
        end
        S.close(conn)
      end
    else
      file.write(payload)
      total = total - payload:len()
      if total <= 0 then
        file.flush()
        file.close()
        -- clear out some memory
        payload = nil
        headers = nil
        collectgarbage()
        success, message = pcall(node.compile, filename)
        if success then
          S.response(conn, '201 Created')
          -- remove the souce file to save room
          file.remove(filename)
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
