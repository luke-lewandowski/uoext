dofile("..\\Lib\\FluentUO\\FluentUO.lua")
dofile("..\\Structs\\LimitedStack.lua")
dofile(".\\ItemManager.lua")

UOExt = UOExt or {}
UOExt.Managers = UOExt.Managers or {}
UOExt.Managers.SkinningManager = UOExt.Managers.SkinningManager or {}

UOExt.Managers.SkinningManager.cutHistory = UOExt.Structs.LimitedStack:Create(10)
UOExt.Managers.SkinningManager.Options = {
    ["hideContainer"] = UO.BackpackID,

    ["knifeType"] = 3922,
    ["scissorsType"] = 3999,
    ["distance"] = 2
}

UOExt.Managers.SkinningManager.FindKnife = function()
    return UOExt.Managers.ItemManager.GetItemFromBackpack(UOExt.Managers.SkinningManager.Options.knifeType)
end

UOExt.Managers.SkinningManager.FindScissors = function()
    return UOExt.Managers.ItemManager.GetItemFromBackpack(UOExt.Managers.SkinningManager.Options.scissorsType)
end

UOExt.Managers.SkinningManager.FindCorpses = function()
    return UOExt.Managers.ItemManager.GetCorpsesWithinRange(UOExt.Managers.SkinningManager.Options.distance)
end

UOExt.Managers.SkinningManager.GetHides = function (containerID)
    local hidesType = 4217
    local hides = UOExt.Managers.ItemManager.GetItemsFromContainer(hidesType, containerID)
    
    if(#hides > 0) then
        return hides
    end

    return {}                 
end

UOExt.Managers.SkinningManager.CutCorps = function (corpsID, knifeItem)
      
    if(knifeItem ~= nil and corpsID ~= nil) then
        local corps = World().WithID(corpsID).Items[1]
        UOExt.Managers.ItemManager.UseItemOnItem(knifeItem, corps)
    end
end

UOExt.Managers.SkinningManager.CutHides = function(containerID, scissorsItem)

    print("Cutting hides...")
      
    if(containerID ~= nil and scissorsItem ~= nill) then
        local hidesBackpack = UOExt.Managers.SkinningManager.GetHides(containerID)
          
        print("Looking for hides to cut..." .. #hidesBackpack)
         
        for khides,hides in pairs(hidesBackpack) do
            print("Cutting hides " .. hides.Name)
            UOExt.Managers.ItemManager.UseItemOnItem(scissorsItem, hides)
            end 
    else
        print("Unable to find container or scissors for cutting hides")
    end
      
end

UOExt.Managers.SkinningManager.CutAndLoot = function(corpsItem)
    local knife = UOExt.Managers.SkinningManager.FindKnife()
    local scissors = UOExt.Managers.SkinningManager.FindScissors()

    print("Found following cutting item: " .. knife.Name)
    print("Found scissors: " .. scissors.Name)

    if(corpsItem ~= nil and knife ~= nil) then
        -- Open corps
        corpsItem.Use()
        
        UOExt.Managers.SkinningManager.CutCorps(corpsItem.ID, knife)

        -- Wait for corps to open
        -- TODO: Replace with wait for gump
        wait(600)

        local hidesWorld = UOExt.Managers.SkinningManager.GetHides(corpsItem.ID)
     
        print("Looking for hides. Found " .. #hidesWorld)
     
        for khides,hides in pairs(hidesWorld) do
            print("Moving " .. hides.Name)
            UOExt.Managers.ItemManager.MoveItemToContainer(hides, UOExt.Managers.SkinningManager.Options.hideContainer)
        end
    end

    UOExt.Managers.SkinningManager.CutHides(UOExt.Managers.SkinningManager.Options.hideContainer, scissors)
end

UOExt.Managers.SkinningManager.Run = function()
    local corpses = UOExt.Managers.SkinningManager.FindCorpses()
    local scissors = UOExt.Managers.SkinningManager.FindScissors()

    print("Found scissors: " .. scissors.Name)
    print("Found skinning corpses " .. #corpses)

    UOExt.Managers.SkinningManager.CutHides(UOExt.Managers.SkinningManager.Options.hideContainer, scissors)

    if(#corpses > 0 and knife ~= nil) then
        for kcorps,corps in pairs(corpses) do 
            if(UOExt.Managers.SkinningManager.cutHistory:valueExists(corps.ID) ~= true) then
                UOExt.Managers.SkinningManager.CutAndLoot(corps)
                UOExt.Managers.SkinningManager.cutHistory(corps.ID)
            end
        end
    end
end