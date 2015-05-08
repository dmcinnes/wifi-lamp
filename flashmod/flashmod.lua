flash = {MOD_NAME = "flash"}

function flash.flashMod(tbl)
	if type(tbl) == "string" then tbl = {MOD_NAME=tbl} end 
	for k,v in pairs(tbl) do
		if type(v) == "function" then
			file.open(string.format("%s_%s.lc", tbl.MOD_NAME, k), "w+")
			file.write(string.dump(v))
			file.close()
			tbl[k] = nil
		end
	end
	return setmetatable(tbl, {
		__index = function(t, k)
			return assert(loadfile(string.format("%s_%s.lc",t.MOD_NAME,k)))
		end
	})
end

flash.flashMod(flash)
flash = nil
module = nil
package = nil
newproxy = nil
require = nil
collectgarbage()

function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
