flash = {MOD_NAME = "flash"}

function flash.LLbin(fname)
	file.open(fname,'w+')
	uart.on("data", "\r", function(data)
		local a, x, byte = {}
		if string.find(data,'EOF') then
			uart.on("data","\r",nil,1)
			file.flush()
			file.close() 
		else
			for x in string.gmatch(data, "[^%s]+") do
				table.insert(a,x)
			end
			if a[3] then
				local addr = a[1]
				local dat = a[2]
				local csum = 0
				for byte in dat:gmatch'%x%x' do
					x = tonumber(byte,16)
					csum = csum + x
				end
				if tonumber(a[3]) == csum then
					uart.write(0,'>')
				else
					uart.write(0,'!')
					print(a[3]..' '..csum)
				end
				local sdat = ''
				for byte in dat:gmatch'%x%x' do
					sdat = sdat..string.char(tonumber(byte,16))
				end
				file.seek("set",addr)
				file.write(sdat)
			end
		end
	end , 0)
end

flashMod(flash)
flash = nil
collectgarbage()

function LLbin(fname) loadfile("flash_LLbin.lc")(fname) end