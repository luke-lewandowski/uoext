dofile(".\\FluentUO\\FluentUO.lua")
dofile(".\\Managers\\LimitedStack.lua")

Skinner = Skinner or {}

Skinner.Options = {
    ["hideContainer"] = 1075309910,

    ["knifeType"] = 3922,
    ["scissorsType"] = 3999,
    ["distance"] = 2
} 

Skinner.FindKnife = function()
    local knifes = Backpack().WithType(Skinner.Options.knifeType).Items

    if(#knifes > 0) then
        return knifes[1]
    end
      
    return {}
end

Skinner.FindScissors = function()
    local scissors = Backpack().WithType(Skinner.Options.scissorsType).Items

    if(#scissors > 0) then
        return scissors[1]
    end
      
    return {}
end

Skinner.FindCorpses = function()
    local corpses = Ground().WithType(8198).InRange(Skinner.Options.distance).Items
      
    if(#corpses > 0) then
        return corpses
    end
      
    return {}
end

Skinner.GetHides = function (containerID)
    local hidesType = 4217
    local hides = World().WithType(4217).InContainer(containerID).Items
      
    if(#hides > 0) then
        return hides
    end
      
    return {}                 
end

Skinner.CutCorps = function (corpsID, knifeItem)
      
    if(knifeItem ~= nil and corpsID ~= nil) then
        -- Cutting corps to get hides
        UO.LTargetID = corpsID
        knifeItem.Use()
        FluentUO.Action.WaitForAction(false)
        UO.Macro(22, 0) -- Last target
    end
end

Skinner.CutHides = function(containerID, scissorsItem)
      
    print("Cutting hides...")
      
    if(containerID ~= nil and scissorsItem ~= nill) then
        local hidesBackpack = Skinner.GetHides(containerID)
          
        print("Looking for hides to cut..." .. #hidesBackpack)
         
        for khides,hides in pairs(hidesBackpack) do
            print("Cutting hides " .. hides.Name)
            UO.LTargetID = hides.ID
            scissorsItem.Use()
            FluentUO.Action.WaitForAction(false)
            UO.Macro(22, 0) -- Last target
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

Skinner.cutHistory = SimpleStack:Create(10)

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
         
            --DebugProperty(corps)
			
			
				Skinner.CutCorps(corps.ID, knife)
				Skinner.cutHistory:push(corps.ID)
			
         
            
         
            local hidesWorld = Skinner.GetHides(corps.ID)
         
            print("Looking for hides. Found " .. #hidesWorld)
         
            for khides,hides in pairs(hidesWorld) do
                print("Dragging " .. hides.Name)
                hides.Drag()
                wait(1000)
                UO.DropC(Skinner.Options.hideContainer)
            end
            else
                print("Body already skinned. Skipping")
            end
        end
    end
end