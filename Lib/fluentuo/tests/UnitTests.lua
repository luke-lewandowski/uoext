dofile('luaunit.lua')
dofile('lemock.lua')
require "lfs"

for object in lfs.dir(".") do
	if string.find(tostring(object):lower(),"^test\..+\.lua") ~= nil then
		dofile(object)
	end
end

LuaUnit:run()
