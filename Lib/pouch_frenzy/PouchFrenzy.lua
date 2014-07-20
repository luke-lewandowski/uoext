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
	pouchIDs = {}
}
-- 
-------------------------------------
-- Scan all items and count regs/pouches
PouchFrenzy.getAllItems = function(bagID,isDest)
	local itemCount = 0
	local scanIt = UO.ScanItems(false) 
	local allItems = false

	while itemCount ~= scanIt do
	 local ID,Type,Kind,ContID,X,Y,Stack,Rep,Col = UO.GetItem(itemCount) 
	 
	   -- Make sure the items are in source pouch
	   if(ContID == bagID) then
			for key, value in pairs(PouchFrenzy.Options.reagentTable) do 
				if(Type == value.TYPE and isDest == false) then
				    local name, info = UO.Property(ID)  
					value.ID = ID
					value.NAME = name
					value.AMOUNT = string.match(name, "%d+")
				end
			end
			
			if(Type == 3702 and isDest == true) then
				table.insert(PouchFrenzy.Options.pouchIDs,ID)
			end
	   
	   end
	   itemCount = itemCount + 1
	end
    
end
-- 
-------------------------------------
-- Wait timer for cursor selecting
PouchFrenzy.waitForCurs = function(timeToWait)
	timeCounter = 0
	while(UO.TargCurs == true) do
		wait(100)
		timeCounter = timeCounter + 100
		if(timeCounter == timeToWait) then
			UO.SysMessage("You failed to select anything.")
			UO.SysMessage("Select the pouch again, you have 6 seconds.")
			UO.TargCurs = true
			PouchFrenzy.waitForCurs(timeToWait)
		end
	end
end
-- 
-------------------------------------
-- Wait timer for bag opening
PouchFrenzy.waitForPouch = function(timeToWait)
	timeCounter = 0
	while(UO.ContID ~= UO.LObjectID) do 
		wait(100)
		timeCounter = timeCounter + 100
		if(timeCounter == timeToWait) then
			UO.SysMessage("Could not open pouch.")
			UO.SysMessage("Restart and make sure pouch is reachable.")
			UO.TargCurs = true
			PouchFrenzy.waitForPouch(timeToWait)
		end

	end
end
-- 
-------------------------------------
-- Put reagents into bags
PouchFrenzy.makePouch = function(many)
	if(many == true) then
		local num = 1
		for k, v in pairs(PouchFrenzy.Options.pouchIDs) do 
			for key, value in pairs(PouchFrenzy.Options.reagentTable) do 
				UO.Drag(value.ID, PouchFrenzy.Options.amountToMove)
				UO.DropC(v,50,50)
				wait(1000)
			end
			PouchFrenzy.getAllItems(PouchFrenzy.Options.sourcePouch, false)
			UO.SysMessage("Pouch number: ".. num .. " complete.")
			num = num + 1
		end
	else		
		for key, value in pairs(PouchFrenzy.Options.reagentTable) do 
			UO.Drag(value.ID, PouchFrenzy.Options.amountToMove)
			UO.DropC(PouchFrenzy.Options.destPouch,50,50)
			wait(1000)
		end
	end
	UO.SysMessage("All pouches complete.")
end
-- 
-------------------------------------
-- Put reagents into bags
PouchFrenzy.showAmount = function()
	local regMntTab = {}
	print("Reagents in source pouch")
	for key, value in pairs(PouchFrenzy.Options.reagentTable) do 
		print(value.NAME)
		table.insert(regMntTab, value.AMOUNT)
	end
	UO.SysMessage("With ".. PouchFrenzy.Options.amountToMove .." reagents per bag you can make a total of " .. math.floor(math.min(unpack(regMntTab))/PouchFrenzy.Options.amountToMove) .." bags.")
	
end
-- 
-------------------------------------
-- Main start of script
PouchFrenzy.Run = function(mode)
	if(mode == 0) then
		-- Select reagent pouch
		UO.SysMessage("Select the reagent source pouch, you have 6 seconds.")
		UO.TargCurs = true
		PouchFrenzy.waitForCurs(6000)

		-- Set the pouch as last Object
		UO.LObjectID = UO.LTargetID
		PouchFrenzy.Options.sourcePouch = UO.LTargetID

		-- Open it
		UO.Macro(17,0)

		-- Check it it actually opens otherwise time out after 6 seconds.
		PouchFrenzy.waitForPouch(6000)

		-- Get array of items from source
		UO.SysMessage("Creating array of regs.")
		PouchFrenzy.getAllItems(PouchFrenzy.Options.sourcePouch, false)
		
		-- Print current amount and how many bags it can make
		PouchFrenzy.showAmount()
		
		-- Select dest pouch
		UO.SysMessage("Select the destination pouch, you have 6 seconds.")
		UO.TargCurs = true
		PouchFrenzy.waitForCurs(6000)

		-- Set the destPouch var
		PouchFrenzy.Options.destPouch = UO.LTargetID
		PouchFrenzy.getAllItems(PouchFrenzy.Options.destPouch, true)
		-- Make the pouches
		
		UO.SysMessage("Making pouches.")
		PouchFrenzy.makePouch(true)

	else
		-- Select reagent pouch
		UO.SysMessage("Select the reagent source pouch, you have 6 seconds.")
		UO.TargCurs = true
		PouchFrenzy.waitForCurs(6000)

		-- Set the pouch as last Object
		UO.LObjectID = UO.LTargetID
		PouchFrenzy.Options.sourcePouch = UO.LTargetID

		-- Open it
		UO.Macro(17,0)

		-- Check it it actually opens otherwise time out after 6 seconds.
		PouchFrenzy.waitForPouch(6000)

		-- Get array of items from source
		UO.SysMessage("Creating array of regs.")
		PouchFrenzy.getAllItems(PouchFrenzy.Options.sourcePouch, false)
		PouchFrenzy.showAmount()
		-- Select dest pouch
		UO.SysMessage("Select the destination pouch, you have 6 seconds.")
		UO.TargCurs = true
		PouchFrenzy.waitForCurs(6000)

		-- Set the destPouch var
		PouchFrenzy.Options.destPouch = UO.LTargetID

		-- Make the pouches
		PouchFrenzy.makePouch(false)

	end

end