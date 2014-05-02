dofile(".\\Lib\\FluentUO\\FluentUO.lua")
dofile(".\\Structs\\LimitedStack.lua")
dofile(".\\Managers\\ItemManager.lua")

Skinner = Skinner or {}

Skinner.Options = {
    ["hideContainer"] = 1075309910,

    ["knifeType"] = 3922,
    ["scissorsType"] = 3999,
    ["distance"] = 2
}

Skinner.FindKnife = function()
    return UOExt.Managers.ItemManager.GetItemFromBackpack(Skinner.Options.knifeType)
end

Skinner.FindScissors = function()
    return UOExt.Managers.ItemManager.GetItemFromBackpack(Skinner.Options.scissorsType)
end

Skinner.FindCorpses = function()
    return UOExt.Managers.ItemManager.GetCorpsesWithinRange(Skinner.Options.distance)
end

Skinner.GetHides = function (containerID)
    local hidesType = 4217
    local hides = UOExt.Managers.ItemManager.GetItemsFromContainer(hidesType, containerID)
    
    if(#hides > 0) then
        return hides
    end

    return {}                 
end

Skinner.CutCorps = function (corpsID, knifeItem)
      
    if(knifeItem ~= nil and corpsID ~= nil) then
        local corps = World().WithID(corpsID).Items[1]
        UOExt.Managers.ItemManager.UseItemOnItem(knifeItem, corps)
    end
end

Skinner.CutHides = function(containerID, scissorsItem)

    print("Cutting hides...")
      
    if(containerID ~= nil and scissorsItem ~= nill) then
        local hidesBackpack = Skinner.GetHides(containerID)
          
        print("Looking for hides to cut..." .. #hidesBackpack)
         
        for khides,hides in pairs(hidesBackpack) do
            print("Cutting hides " .. hides.Name)
            UOExt.Managers.ItemManager.UseItemOnItem(scissorsItem, hides)
            end 
    else
        print("Unable to find container or scissors for cutting hides")
    end
      
end

DebugProperty = function(prop)
    for k,v in pairs(prop) do
        if(k ~= nil and v ~= nil) then
            print("Key: " .. k .. " Value: " .. tostring(v))
        end
    end
end

Skinner.cutHistory = UOExt.Structs.LimitedStack:Create(10)

Skinner.Run = function()

    local knife = Skinner.FindKnife()
    local corpses = Skinner.FindCorpses()
    local scissors = Skinner.FindScissors()


    print("Found following cutting item: " .. knife.Name)
    print("Found scissors: " .. scissors.Name)
    print("Found skinning corpses " .. #corpses)

    Skinner.CutHides(Skinner.Options.hideContainer, scissors)

    if(#corpses > 0 and knife ~= nil) then
        for kcorps,corps in pairs(corpses) do if(Skinner.cutHistory:valueExists(corps.ID) ~= true) then
            
            -- Open corps
            corps.Use()
			
			Skinner.CutCorps(corps.ID, knife)
			Skinner.cutHistory:push(corps.ID)

            -- Wait for corps to open
            wait(1000)

            local hidesWorld = Skinner.GetHides(corps.ID)
         
            print("Looking for hides. Found " .. #hidesWorld)
         
            for khides,hides in pairs(hidesWorld) do
                print("Moving " .. hides.Name)
                UOExt.Managers.ItemManager.MoveItemToContainer(hides, Skinner.Options.hideContainer)
            end
            else
                print("Body already skinned. Skipping")
            end
        end
    end
end