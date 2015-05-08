local server = {MOD_NAME = 'server'}

function server:init()
  self.commands = {}
end

function server:parseHeaders(payload)
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

function server:response(conn, code)
  print(code)
  conn:send("HTTP/1.1 "..code.."\r\n")
end

function server:ok(conn)
  self:response(conn, '200 OK')
end

function server:close(conn)
  conn:on("sent", function(conn)
    conn:close()
  end)
end

function server:cmd(name, func)
  self.commands[name] = func
end

function server:receiver(conn, payload)
  local query, path, headers, total, expect

  if payload:match("^PUT") or payload:match("^POST") then
    query, path, headers = self:parseHeaders(payload)
    self.filename = path:gsub('^/', '')
    print("Request: "..query)

    expect = headers["Expect"]
    if expect and expect:match("^100") then
      total = tonumber(headers["Content-Length"])
      file.open(self.filename, 'w')
      self:response(conn, '100 Continue')
    else
      -- it's POST
      if self.commands[self.filename] then
        success, message = pcall(self.commands[self.filename])
        if success then
          self:ok(conn)
        else
          self:response(conn, '500 Server Error')
          conn:send(message..'\r\n')
        end
      else
        self:response(conn, '404 Not Found')
      end
      self:close(conn)
    end
  else
    file.write(payload)
    total = total - payload:len()
    if total <= 0 then
      file.flush()
      file.close()
      -- clear out some memory
      payload = nil
      collectgarbage()
      success, message = pcall(node.compile, self.filename)
      if success then
        self:response(conn, '201 Created')
        -- remove the souce file to save room
        file.remove(self.filename)
      else
        self:response(conn, '422 Unprocessable Entity')
        conn:send('\r\nCompile Failed: '..message..'\r\n')
      end
      self:close(conn)
    end
  end
end

flashMod(server)
