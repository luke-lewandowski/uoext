--- Core methods that have no particular connection
-- @module UOExt.Core

UOExt = UOExt or {}
UOExt.Core = UOExt.Core or {}

--- This methods makes sure that value is 0 if nil.
-- @param val number value to be checked and casted
-- @return number or 0 if value wasn't castable to a number.
UOExt.Core.ConvertToInt = function(val)
    return tonumber(val) or 0
end

--- Blocks execution until cursor turns into target
-- It times out after 10 seconds and returns false
-- @return true if target cursor is showing or false if timed out without target cursor.
UOExt.Core.WaitForTarget = function()
	local timeout = 10000 -- 10 seconds

	for i=1,(timeout / 600) do
		if(UO.TargCurs) then return true end
		wait(600)
	end

	return false
end

--- Load file at specific location
-- @param filename path to a file to read.
-- @return content of file or nil.
UOExt.Core.LoadFile = function(filename)
	local fileOpen = openfile(filename, "r+")

	if(fileOpen ~= nil)then
		local content = fileOpen:read("*a")
		fileOpen:close()
		return content
	else
		return nil
	end
end

--- Save file at specific location with specified content
-- @param filename path to file to save
-- @return content or nil if unable to save
UOExt.Core.SaveFile = function(filename, content)
	local fileOpen = openfile(filename, "w+")

	if(fileOpen ~= nil)then
		local content = fileOpen:write(content)
		fileOpen:close()
		return content
	else
		return nil
	end
end


-- ############################################
-- Utilities for tables
-- ############################################

--- Utilities for tables
UOExt.TableUtils = UOExt.TableUtils or {}

--- Get keys for a specific array/table
-- @param array to get keys off
-- @return an array of keys of given table.
UOExt.TableUtils.GetKeys = function(array)
	local temp = {}
	for k,v in pairs(array) do
		table.insert(temp, k)
	end

	return temp
end

--- Gets values of specific array
-- @param array to get values off
-- @return an array of values
UOExt.TableUtils.GetValues = function(array)
	local temp = {}
	for k,v in pairs(array) do
		table.insert(temp, v)
	end

	return temp
end

--- Combine key with value with a delimeter and return as table
-- @param array table to combine
-- @param delimeter character to use as a delimeter
-- @return an array of combines key with value
UOExt.TableUtils.CombineKeyWithValue = function(array, delimeter)
	local temp = {}
	for k,v in pairs(array) do
		table.insert(temp, (k..delimeter..v))
	end

	return temp
end

--- Checks if following key exists in an array
-- @deprecated
-- @param array to be checked
-- @param key to be searched for
-- @return true if found, false otherwise
UOExt.TableUtils.KeyExists = function(array, key)
	for k,v in pairs(array) do
		if(tostring(key) == tostring(k)) then
			return true
		end
	end

	return false
end