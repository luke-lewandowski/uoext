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