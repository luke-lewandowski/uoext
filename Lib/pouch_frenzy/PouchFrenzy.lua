--------------------------------------
-- Pouch Frenzy
-- v1.0
-- By Michael Lewandowski
-- Mode 0 = make many pouches
-- Mode 1 = make one pouch
-- Amount of reagents to move per each pouch
	mode = 0
	amountToMove = 50
-- Don't touch anything below this line
-------------------------------------
-- Reagent Table
reagentTable = {
		["BM"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3963,["ID"] = 0},
		["BP"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3962,["ID"] = 0},
		["GR"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3972,["ID"] = 0},
		["GI"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3973,["ID"] = 0},
		["MR"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3974,["ID"] = 0},
		["NS"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3976,["ID"] = 0},
		["SS"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3981,["ID"] = 0},
		["SA"] = {["NAME"] = "",["AMOUNT"] = 0,["TYPE"] = 3980,["ID"] = 0}
}

-- Pouch Information
sourcePouch = 0 
destPouch = 0
amountPouch = 0
pouchType = 3702
pouchIDs = {}
-- 
-------------------------------------
-- Scan all items and count regs/pouches
function getAllItems(bagID,isDest)
	local itemCount = 0
	local scanIt = UO.ScanItems(false) 
	local allItems = false

	while itemCount ~= scanIt do
	 local ID,Type,Kind,ContID,X,Y,Stack,Rep,Col = UO.GetItem(itemCount) 
	 
	   -- Make sure the items are in source pouch
	   if(ContID == bagID) then
			for key, value in pairs(reagentTable) do 
				if(Type == value.TYPE and isDest == false) then
				        local name, info = UO.Property(ID)  
					value.ID = ID
					value.NAME = name
					value.AMOUNT = string.match(name, "%d+")
				end
			end
			
			if(Type == 3702 and isDest == true) then
				table.insert(pouchIDs,ID)
				print(ID)
			end
	   
	   end
	   itemCount = itemCount + 1
	end
    
end
-- 
-------------------------------------
-- Wait timer for cursor selecting
function waitForCurs(timeToWait)
	timeCounter = 0
	while(UO.TargCurs == true) do
		wait(100)
		timeCounter = timeCounter + 100
		if(timeCounter == timeToWait) then
			UO.SysMessage("You failed to select anything.")
			UO.SysMessage("Select the pouch again, you have 6 seconds.")
			UO.TargCurs = true
			waitForCurs(timeToWait)
		end
	end
end
-- 
-------------------------------------
-- Wait timer for bag opening
function waitForPouch(timeToWait)
	timeCounter = 0
	while(UO.ContID ~= UO.LObjectID) do 
		wait(100)
		timeCounter = timeCounter + 100
		if(timeCounter == timeToWait) then
			UO.SysMessage("Could not open pouch.")
			UO.SysMessage("Restart and make sure pouch is reachable.")
			stop()
		end

	end
end
-- 
-------------------------------------
-- Put reagents into bags
function makePouch(many)
	if(many == true) then
		local num = 1
		for k, v in pairs(pouchIDs) do 
			for key, value in pairs(reagentTable) do 
				UO.Drag(value.ID, amountToMove)
				UO.DropC(v,50,50)
				wait(1000)
			end
			getAllItems(sourcePouch, false)
			UO.SysMessage("Pouch number: ".. num .. " complete.")
			num = num + 1
		end
	else		
		for key, value in pairs(reagentTable) do 
			UO.Drag(value.ID, amountToMove)
			UO.DropC(destPouch,50,50)
			wait(1000)
		end
	end
	UO.SysMessage("All pouches complete.")
end
-- 
-------------------------------------
-- Put reagents into bags
function showAmount()
	local regMntTab = {}
	print("Reagents in source pouch")
	for key, value in pairs(reagentTable) do 
		print(value.NAME)
		table.insert(regMntTab, value.AMOUNT)
	end
	UO.SysMessage("With ".. amountToMove .." reagents per bag you can make a total of " .. math.floor(math.min(unpack(regMntTab))/amountToMove) .." bags.")
	
end
-- 
-------------------------------------
-- Main start of script
while true do 
	if(mode == 0) then
		-- Select reagent pouch
		UO.SysMessage("Select the reagent source pouch, you have 6 seconds.")
		UO.TargCurs = true
		waitForCurs(6000)

		-- Set the pouch as last Object
		UO.LObjectID = UO.LTargetID
		sourcePouch = UO.LTargetID

		-- Open it
		UO.Macro(17,0)

		-- Check it it actually opens otherwise time out after 6 seconds.
		waitForPouch(6000)

		-- Get array of items from source
		UO.SysMessage("Creating array of regs.")
		getAllItems(sourcePouch, false)
		
		-- Print current amount and how many bags it can make
		showAmount()
		
		-- Select dest pouch
		UO.SysMessage("Select the destination pouch, you have 6 seconds.")
		UO.TargCurs = true
		waitForCurs(6000)

		-- Set the destPouch var
		destPouch = UO.LTargetID
		getAllItems(destPouch, true)
		-- Make the pouches
		
		UO.SysMessage("Making pouches.")
		makePouch(true)

	else
		-- Select reagent pouch
		UO.SysMessage("Select the reagent source pouch, you have 6 seconds.")
		UO.TargCurs = true
		waitForCurs(6000)

		-- Set the pouch as last Object
		UO.LObjectID = UO.LTargetID
		sourcePouch = UO.LTargetID

		-- Open it
		UO.Macro(17,0)

		-- Check it it actually opens otherwise time out after 6 seconds.
		waitForPouch(6000)

		-- Get array of items from source
		UO.SysMessage("Creating array of regs.")
		getAllItems(sourcePouch, false)
		showAmount()
		-- Select dest pouch
		UO.SysMessage("Select the destination pouch, you have 6 seconds.")
		UO.TargCurs = true
		waitForCurs(6000)

		-- Set the destPouch var
		destPouch = UO.LTargetID

		-- Make the pouches
		makePouch(false)

	end
	stop()
end