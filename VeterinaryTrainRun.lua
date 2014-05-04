--[[
;----------------------------------
; Script Name: VeterinaryTrainRun.lua
; Author: Luke Lewandowski
; Version: 1.0
; Client Tested with: 7.0.34.22
; EUO version tested with: OpenEUO
; Shard OSI / FS: FS
; Purpose: 
; - Causes two animals to fight each other
; - It uses veterinary to heal them
;---------------------------------- ]]

dofile(".\\Utils\\Core.lua")
dofile(".\\Lib\\FluentUO\\FluentUO.lua")
dofile(".\\Lib\\GetHitBarLife\\GetHitBarLife.lua")
dofile(".\\Structs\\LimitedStack.lua")
dofile(".\\Managers\\ItemManager.lua")
dofile(".\\Managers\\SkinningManager.lua")

--[[
	- Find two animals
	- Cause a fight (provo or tamed animals) (TODO)
	- Check health and if below threshold start healing
	- Repeat
    - Once above 70 it uses magery to poison both animals.
	
	TODO: Shift some of this methods and logic out to the animal manager.


]]

VetTrainer = VetTrainer or {}

VetTrainer.Options = {
	-- Percentage of health before bandages kick in
	["healthThreshold"] = 50, 

	-- Attempt to stop fight when out of bandages
	["stopFightWhenBandagesRunOut"] = true,

    ["usePoison"] = true
}

local ShowMessage = function(message, objectID)
	if(objectID == nil)then
		objectID = UO.CharID
	end
	UO.ExMsg(objectID, message)
	print(objectID .. ":" .. message)
end

local PoisonTarget = function(targetID)
    local temp = UO.LTargetID
    UO.LTargetID = targetID
    UO.Macro(15, 19) -- Poison
    UOExt.Core.WaitForTarget()
    UO.Macro(22, 0) -- Last target
    UO.LTargetID = temp
end

local PosionIfNotPoisoned = function(targetID)

    if(targetID ~= nil) then
        print(targetID)
        UO.StatBar(targetID)
        
        local health, col = GetHitBarLife(targetID)
        col = col or "unknown"
        
        print(health .. " " .. col)
        
        if(col ~= "green")then
            PoisonTarget(targetID)
               
            -- Resets war/peace
            UO.Macro(6, 0) -- war/peace
            wait(600)
            UO.Macro(6, 0)
        end
    end

end

ShowMessage("Target your first animal")
local animal1 = UOExt.Managers.ItemManager.GetTargetID()

ShowMessage("Target your second animal")
local animal2 = UOExt.Managers.ItemManager.GetTargetID()

if(animal1 ~= nil and animal2 ~= nil) then
   UO.StatBar(animal1)
   UO.StatBar(animal2)
   
    local animal1Item = {["ID"] = animal1}
    local animal2Item = {["ID"] = animal2}
   
    while true do
        local bandages = UOExt.Managers.ItemManager.GetItemFromContainer(3617, UO.BackpackID)
        local nightshades = UOExt.Managers.ItemManager.GetItemFromContainer(3976, UO.BackpackID)
        local isHealingRequired = false

        -- If you run out of regents or bandages
        -- Run away and scream "all stay"
        if(bandages == nil or (VetTrainer.Options.usePosion and nightshades == nil)) then
            UO.Macro(1,0, "all stay")
            UO.Move(UO.CharPosX - 10, UO.CharPosY - 10)
            print("Stopping script at:")
            print(gettime())
            break
        end
         
        local ahp1, acol1 = GetHitBarLife(animal1)
        local ahp2, acol2 = GetHitBarLife(animal2)
         
        if(animal1 == animal2)then
         	-- Both animals are the same!
            print("only one animal found!" .. ahp1)
         	if(ahp1 < VetTrainer.Options.healthThreshold) then
         	  ShowMessage("using bandages on animal", animal1Item.ID)
              UOExt.Managers.ItemManager.UseItemOnItem(bandages, animal1Item)
         	  isHealingRequired = true
            end
        else
            -- Two different animals 
            -- Pick the one with less health
         	local health = UOExt.Core.ConvertToInt(0)
         	local animalToHeal = {["ID"] = 0}

            print("animal1: " .. ahp1) -- hitbar must be open!
            print("animal2: " .. ahp2) -- hitbar must be open!
         
         	if(ahp1 > ahp2) then
         		health = UOExt.Core.ConvertToInt(ahp2)
         		animalToHeal.ID = animal2Item.ID
         	else
     			health = UOExt.Core.ConvertToInt(ahp1)
         		animalToHeal.ID = animal1Item.ID
         	end

	        if(health <= VetTrainer.Options.healthThreshold) then
	            ShowMessage("using bandages on animal", animalToHeal.ID)
	            UOExt.Managers.ItemManager.UseItemOnItem(bandages, animalToHeal)
	        	isHealingRequired = true
	        end
     	end

        local norm, real = UO.GetSkill("Vete")
        if(norm > 700 and VetTrainer.Options.usePoison) then
            -- Change threshold to be 90 -- since we gotta cure
            VetTrainer.Options.healthThreshold = 90

            if(ahp1 > 95)then
                print("Using poisoning" .. animal1)
                PosionIfNotPoisoned(animal1)
            end
            if(ahp2 > 95)then
                print("Using poisoning" .. animal2)
                PosionIfNotPoisoned(animal2)
            end
        end
        
     	-- Change how often script runs dependable on whats currently done
        if(isHealingRequired)then 
        	print("Waiting longer - using bandages")
        	wait(6000)
        else
        	print("Quick check...")
    		wait(1000)
    	end
   end
end