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
;----------------------------------]]

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

print("Target your first animal")
local animal1 = UOExt.Managers.ItemManager.GetTargetID()

print("Targe your second animal")
local animal2 = UOExt.Managers.ItemManager.GetTargetID()

if(animal1 ~= nil and animal2 ~= nil) then
   UO.StatBar(animal1)
   UO.StatBar(animal2)
   
   local animal1Item = {["ID"] = animal1}
   local animal2Item = {["ID"] = animal2}
   
   while true do
         local bandages = UOExt.Managers.ItemManager.GetItemFromContainer(3617, UO.BackpackID)
         
         if(bandages == nil) then
              UO.Macro(1,0, "all follow me")
         end
         
         local ahp1 = GetHitBarLife(animal1)
         local ahp2 = GetHitBarLife(animal2)
         print("animal1: " .. ahp1) -- hitbar must be open!
         print("animal2: " .. ahp2) -- hitbar must be open!
         
         if(ahp1 < 50) then
              print("using bandages on animal1")
              UOExt.Managers.ItemManager.UseItemOnItem(bandages, animal1Item)
         end
         
         if(ahp2 < 50) then
              print("using bandages on animal1")
              UOExt.Managers.ItemManager.UseItemOnItem(bandages, animal2Item)
         end
         
         wait(6000)
   end
end