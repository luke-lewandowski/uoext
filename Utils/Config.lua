dofile(".\\Core.lua")
dofile("..\\Lib\\json4lua\\json4lua.lua")

UOExt = UOExt or {}
UOExt.Config = UOExt.Config or {}

UOExt.Config.GetConfig = function(filename)
	if(filename ~= nil)then
		local content = UOExt.Core.LoadFile(filename)
		if(content ~= nil and string.len(content) > 0) then
			return json.decode(content)
		else
			return nil
		end
	else
		return nil
	end
end

UOExt.Config.SaveConfig = function(filename, config)
	if(filename ~= nil and config ~= nil)then
		local content = UOExt.Core.SaveFile(filename, json.encode(config))
		return config
	else
		return nil
	end
end