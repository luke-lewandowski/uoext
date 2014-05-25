--- Configuration module
-- @module UOExt.Config

dofile(".\\Core.lua")
dofile("..\\Lib\\json4lua\\json4lua.lua")

UOExt = UOExt or {}
UOExt.Config = UOExt.Config or {}

--- Gets configuration from specified file location
-- @param filename path to a file (json)
-- @return config array thats been deserialized from json file.
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

--- Saves configuration object to a specific filename
-- @param filename full path to where json file needs to be saved.
-- @param config object that needs to be serializable.
-- @return config if completed successfully or nil
UOExt.Config.SaveConfig = function(filename, config)
	if(filename ~= nil and config ~= nil)then
		local content = UOExt.Core.SaveFile(filename, json.encode(config))
		return config
	else
		return nil
	end
end