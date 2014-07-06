dofile("..\\Lib\\kalinex_journal\\journal.lua")
UOExt = UOExt or {}
UOExt.Server = UOExt.Server or {}

UOExt.Server.GetPing = function()
	-- Get average ping
	local journal = journal:new()
	UO.Msg(' '..string.char(13))
	UO.Msg("-ping"..string.char(13))
	getPingIndex = journal:wait(10000,"Min")
	if(getPingIndex ~= nil) then
		text = journal:last()
		ping = string.match(string.match(text,"Avg: %d+"),"%d+")
		return ping
	end
end

UOExt.Server.GetPingAdjustedDelay = function(ping,delay)
	local factor = (ping / 2) / 1000
	return ((factor + 1) * delay)
end