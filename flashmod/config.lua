local config = {}

config.MOD_NAME = "config"

function config.ListAP(t)
	local res = ""
	if t then
		for k,v in pairs(t) do
			res = res .. '"' .. k .. '"' .. ",\n"
		end
		if file.open("aplist.txt","w+") then
			file.write(res..'null')
			file.close()
			print("accesspoint list : " .. res .. " has ben written to aplist.txt file")
		end
	end
end

function config.GetAPList()
	local list = ""
	if file.open("aplist.txt","r") then
		list = file.read()
		file.close()
	end
	return list
end

return flashMod(config)