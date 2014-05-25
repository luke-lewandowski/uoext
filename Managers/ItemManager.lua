--- Item Manager - contains all methods to do with managing items.
-- @module UOExt.Managers.ItemManager

dofile(".\\..\\Lib\\FluentUO\\FluentUO.lua")

-- Namespaces
UOExt = UOExt or {}
UOExt.Managers = UOExt.Managers or {}
UOExt.Managers.ItemManager = UOExt.Managers.ItemManager or {}

--- GetItemFromBackpack
-- This method gets a single item from current's character backpack.
-- @param itemType The item type
-- @return first item or empty object
UOExt.Managers.ItemManager.GetItemFromBackpack = function(itemType)
    local item = Backpack().WithType(itemType).Items

    if(#item > 0) then
        return item[1]
    end
      
    return {}
end

--- GetItemFromContainer
-- This method gets a single item from specified container ID
-- @param itemType The item type
-- @param containerID ID of the container of where to look for item
UOExt.Managers.ItemManager.GetItemFromContainer = function(itemType, containerID)
    local items = UOExt.Managers.ItemManager.GetItemsFromContainer(itemType, containerID)

    if(#items> 0) then
        return items[1]
    end
      
    return {}
end

--- GetItemsFromContainer
-- This method returns an array of items by type from specific container ID
-- @param itemType The item type
-- @param containerID ID of the container of where to look for item
-- @return returns an array of items or empty object
UOExt.Managers.ItemManager.GetItemsFromContainer = function(itemType, containerID)
    local items = World().WithType(itemType).InContainer(containerID).Items

    if(#items > 0) then
        return items
    end
      
    return {}
end

--- GetCorposesWithinRange
-- This method returns an array of all corpses around the character within specific range
-- @param range Number of tiles from character to scan
-- @return a list of corpses (containers) around character or empty object
UOExt.Managers.ItemManager.GetCorpsesWithinRange = function(range)
  local corpses = Ground().WithType(8198).InRange(range).Items
      
  if(#corpses > 0) then
    return corpses
  end
      
  return {}
end

--- UseItemOnItem
-- Use specific item on item. 
-- @param useItem Item from fluentUO to use
-- @param onItem Item from fluentUO to use on
UOExt.Managers.ItemManager.UseItemOnItem = function(useItem, onItem)
  if(useItem ~= nil and onItem ~= nil) then
    local tempID = UO.LTargetID
    UO.LTargetID = onItem.ID
    useItem.Use()
    FluentUO.Action.WaitForAction(false)
    UO.Macro(22, 0) -- Last target
    UO.LTargetID = tempID
  end
end

--- MoveItemToContainer
-- This method moves specific item to a container
-- @param item Item from fluentUO to move
-- @param containerID ID number of a container to move item to
-- @return true if move has succedded, false otherwise
UOExt.Managers.ItemManager.MoveItemToContainer = function(item, containerID)
  if(item ~= nil and containerID ~= nil) then
    item.Drag()
    wait(600)
    UO.DropC(containerID)
    return true
  end
  
  return false
end

--- GetTargetID
-- Use this method to capture a target ID from user
-- It will turn cursor for targeting cursor and returns target ID
-- @return targetID
UOExt.Managers.ItemManager.GetTargetID = function()
  local current = UO.LTargetID
  UO.LTargetID = 0

  while (UO.LTargetID == 0) do
    UO.TargCurs = true
    wait(2000)
  end

  local newTarget = UO.LTargetID
  UO.LTargetID = current
  
  return newTarget
end