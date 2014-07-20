PouchFrenzy = PouchFrenzy or {}
--------------------------------------
-- Pouch Frenzy
-- v1.0
-- By Michael Lewandowski
-- Mode 0 = make many pouches
-- Mode 1 = make one pouch
-- Amount of reagents to move per each pouch
-- Don't touch anything below this line
-------------------------------------
-- Reagent Table
PouchFrenzy.Options = {
	amountToMove = 50,
	reagentTable = {
			["BM"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3963,["ID"] = 0},
			["BP"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3962,["ID"] = 0},
			["GR"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3972,["ID"] = 0},
			["GI"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3973,["ID"] = 0},
			["MR"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3974,["ID"] = 0},
			["NS"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3976,["ID"] = 0},
			["SS"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3981,["ID"] = 0},
			["SA"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3980,["ID"] = 0}
	},

	-- Pouch Information
	sourcePouch = 0,
	destPouch = 0,
	amountPouch = 0,
	cancel = false,
	maxAmount = 0,
	pouchIDs = {}
}
-- 
-------------------------------------
-- Scan all items and count regs/pouches
PouchFrenzy.getAllItems = function(bagID)
	-- Get all items in bag
	local items = World().InContainer(bagID).Items
	local validate = true
	
	-- Filter items
	for k,item in pairs(items) do
		for key, value in pairs(PouchFrenzy.Options.reagentTable) do 
		
			-- If its not a pouch for containers (many reagent filling) then add following items into reagent table
			if(item.Type == value.TYPE) then  
				value.ID = item.ID
				local itemName = item.Active.Name()
				
				--Make sure to get the name so that it can calculate the amount properly.
				while validate == true do
					if (value.NAME ~= "" and value.NAME ~= nil) then
						value.NAME = itemName
						validate = false
					else
						value.NAME = item.Active.Name()
					end
				end
				
				value.AMOUNT = string.match(item.Name, "%d+")
				validate = true
			end
			

			
		end
		-- Check if the container has pouches
		if(item.Type == 3702 and PouchFrenzy.Options.destPouch ~= 0) then
			table.insert(PouchFrenzy.Options.pouchIDs,item.ID)
		end
	end
	
end
-- 
-------------------------------------
-- Put reagents into bags
PouchFrenzy.makePouch = function()
	local num = 1
	
	if (#PouchFrenzy.Options.pouchIDs == 0) then
		table.insert(PouchFrenzy.Options.pouchIDs,PouchFrenzy.Options.destPouch)
	end

	-- If the user has too many pouches for the max amount, cut them off.
	if(#PouchFrenzy.Options.pouchIDs > PouchFrenzy.Options.maxAmount) then
		local amountToPop = #PouchFrenzy.Options.pouchIDs - PouchFrenzy.Options.maxAmount
		for i = 1,amountToPop,1 do 
			table.remove(PouchFrenzy.Options.pouchIDs)
		end
	end
	
	for k, v in pairs(PouchFrenzy.Options.pouchIDs) do 
		for key, value in pairs(PouchFrenzy.Options.reagentTable) do
			UO.Drag(tonumber(value.ID),tonumber(PouchFrenzy.Options.amountToMove))
			UO.DropC(tonumber(v))
			wait(gpad(600))
		end
		PouchFrenzy.getAllItems(PouchFrenzy.Options.sourcePouch)
		UO.SysMessage("Pouch number: ".. num .. " complete.")
		num = num + 1
	end
		
	UO.SysMessage("All pouches complete.")
end
-- 
-------------------------------------
-- Check if its a pouch
PouchFrenzy.checkContainer = function(container)
	local targetType = World().WithID(container).Items[1].Type

	if(targetType ~= 3701 and targetType ~= 3702) then
		PouchFrenzy.Options.cancel = true
		UO.SysMessage("That's not a pouch or a backpack.")
	end
end
-- 
-------------------------------------
-- Put reagents into bags
PouchFrenzy.showAmount = function()
	local regMntTab = {}
	print("Reagents in source pouch")
	for key, value in pairs(PouchFrenzy.Options.reagentTable) do 
		table.insert(regMntTab, value.AMOUNT)
		print(value.NAME)
	end
	
	PouchFrenzy.Options.maxAmount = math.floor(math.min(unpack(regMntTab))/tonumber(PouchFrenzy.Options.amountToMove))
	
	UO.SysMessage("With ".. PouchFrenzy.Options.amountToMove .." reagents per bag you can make a total of " .. PouchFrenzy.Options.maxAmount .." bags.")
	
	if(PouchFrenzy.Options.maxAmount == 0) then
		UO.SysMessage("Not enough reagents.")
		PouchFrenzy.Options.cancel = true
	end
	
end
-- 
-------------------------------------
-- Main start of script
PouchFrenzy.Run = function()
	while(PouchFrenzy.Options.cancel == false) do
	
		-- Select reagent pouch
		UO.SysMessage("Select the reagent source pouch.")
		
		-- Check if cancelled select
		PouchFrenzy.Options.sourcePouch = UOExt.Managers.ItemManager.GetTargetID()
		PouchFrenzy.checkContainer(PouchFrenzy.Options.sourcePouch)
		if(PouchFrenzy.Options.cancel == true) then
			break
		end
		
		-- Get array of items from source
		UO.SysMessage("Creating array of reagents.")
		PouchFrenzy.getAllItems(PouchFrenzy.Options.sourcePouch)

		-- Print current amount and how many bags it can make
		PouchFrenzy.showAmount()
		
		-- Check if cancelled due to lack of reagents
		if(PouchFrenzy.Options.cancel == true) then
			break
		end
		
		-- Select dest pouch
		UO.SysMessage("Select the destination pouch.")
		PouchFrenzy.Options.destPouch = UOExt.Managers.ItemManager.GetTargetID()
		PouchFrenzy.checkContainer(PouchFrenzy.Options.destPouch)
		if(PouchFrenzy.Options.cancel == true) then
			break
		end
		
		-- Set the destPouch var
		PouchFrenzy.getAllItems(PouchFrenzy.Options.destPouch)
		
		-- Make the pouches
		UO.SysMessage("Making pouches...")
		PouchFrenzy.makePouch()
		
		break
	end

	PouchFrenzy.Options.cancel = false
end