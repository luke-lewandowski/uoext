UOExt = UOExt or {}
UOExt.Core = UOExt.Core or {}

-- This methods makes sure that value is 0 if nil.
-- TODO: This needs to be replaced with constructor
UOExt.Core.ConvertToInt = function(val)
    return tonumber(val) or 0
end

-- Blocks execution until cursor turns into target
-- It times out after 10 seconds and returns false
UOExt.Core.WaitForTarget = function()
	local timeout = 10000 -- 10 seconds

	for i=1,(timeout / 600) do
		if(UO.TargCurs) then return true end
		wait(600)
	end

	return false
end

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

UOExt.Core.ShowMessageBox = function(message, title, button)
	if(buttons == nil) then buttons = 0 end
	if(title == nil) then title = "Message" end

	form = Obj.Create("TMessageBox")
	form.Button = button
	form.Title = title
	form.Show(message)
end