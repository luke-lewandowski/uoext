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
	- Cause a fight (provo or tamed animals)
	- Check health and if below threshold start healing
	- Repeat
	
	TODO: Shift some of this methods and logic out to the animal manager.


]]

VetTrainer = VetTrainer or {}

VetTrainer.Options = {
	-- Percentage of health before bandages kick in
	["healthThreshold"] = 50, 

	-- Attempt to stop fight when out of bandages
	["stopFightWhenBandagesRunOut"] = true
}

local ShowMessage = function(message, objectID)
	if(objectID == nil)then
		objectID = UO.CharID
	end
	UO.ExMsg(objectID, message)
	print(objectID .. ":" .. message)
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
        local isHealingRequired = false

        if(bandages == nil) then
            UO.Macro(1,0, "all follow me")
        end
         
        local ahp1 = UOExt.Core.ConvertToInt(GetHitBarLife(animal1))
        local ahp2 = UOExt.Core.ConvertToInt(GetHitBarLife(animal2))
         
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