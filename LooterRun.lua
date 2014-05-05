--[[
;----------------------------------
; Script Name: LooterRun.lua
; Author: Luke Lewandowski
; Version: 1.0.1
; Client Tested with: 7.0.34.22
; EUO version tested with: OpenEUO
; Shard OSI / FS: FS
; Purpose: 
; - Find and loots any nearby corpses for 
; items specified in "lootItems" below. 
; - Corpes belonging to you will be fully loted.
; - Skinning can be enabled by changing "useSkinning" to true
; 	- It requires Scissors and dagger in your backpack.
;----------------------------------]]

dofile(".\\Utils\\Core.lua")
dofile(".\\Lib\\FluentUO\\FluentUO.lua")
dofile(".\\Structs\\LimitedStack.lua")
dofile(".\\Managers\\ItemManager.lua")
dofile(".\\Managers\\SkinningManager.lua")

Looter = Looter or {}

-- Amount of bodies to rememebr
Looter.History = UOExt.Structs.LimitedStack:Create(20)

Looter.Options = {
	-- Items to loot
	-- Note: If its detected that corps belongs to you 
	-- then it will loot all items
	["lootItems"] = {
		3821, -- Gold

		-- Rocks
		3859, -- Ruby
		3877, -- Amber
		3862, -- Amethyst
		3861 -- Citrine
		},

	-- Container of where to place all the loot
    ["containerID"] = UO.BackpackID,

    -- Distance from your character to seek corpses
    ["distance"] = 2,

    -- Use skinning looter for corpses around
    ["useSkinning"] = true
}

-- #### Nothing past this line needs changing #### --

-- Main method that needs to be run in order to 
-- 1. Find corpses around you
-- 2. Loot & skin them (if selected)
Looter.Run = function()
	local corpses = UOExt.Managers.ItemManager.GetCorpsesWithinRange(Looter.Options.distance)

	if(#corpses > 0) then
        for kcorps,corps in pairs(corpses) do 
            if(Looter.History:valueExists(corps.ID) ~= true) then
            	-- Open corps
                corps.Use()

            	if(Looter.Options.useSkinning)then
            		print("Running skinner")
            		UOExt.Managers.SkinningManager.CutAndLoot(corps)
            	end

            	local items = {}

            	if(string.find(corps.Name, UO.CharName))then
            		-- Its your own body! Loot all
            		items = World().InContainer(corps.ID).Items
            	else
            		-- Any other body. Use selected types.
        			items = World().WithType(Looter.Options.lootItems).InContainer(corps.ID).Items
            	end

        		print("Found items to loot: " .. #items)

        		if(#items > 0)then
    				for kitem,item in pairs(items) do
			            print("Moving " .. item.Name)
			            UOExt.Managers.ItemManager.MoveItemToContainer(item, Looter.Options.containerID)
			        end
        		end

        		Looter.History:push(corps.ID)
            end
        end
    end
end

while true do
	print("LooterRun running.")
    Looter.Run()
    wait(2000)
end