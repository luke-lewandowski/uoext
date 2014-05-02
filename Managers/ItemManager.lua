dofile(".\\..\\Lib\\FluentUO\\FluentUO.lua")

-- Namespaces
UOExt = UOExt or {}
UOExt.Managers = UOExt.Managers or {}
UOExt.Managers.ItemManager = UOExt.Managers.ItemManager or {}

UOExt.Managers.ItemManager.GetItemFromBackpack = function(itemType)
    local item = Backpack().WithType(itemType).Items

    if(#item > 0) then
        return item[1]
    end
      
    return {}
end

UOExt.Managers.ItemManager.GetCorpsesWithinRange = function(range)
  local corpses = Ground().WithType(8198).InRange(range).Items
      
  if(#corpses > 0) then
    return corpses
  end
      
  return {}
end

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

UOExt.Managers.ItemManager.MoveItemToContainer = function(item, containerID)
  if(item ~= nil and containerID ~= nil) then
    item.Drag()
    wait(600)
    UO.DropC(containerID)
    return true
  end
  
  return false
end