dofile(".\\skinner.lua")
dofile(".\\Managers\\SkinningManager.lua")

while true do
    UOExt.Managers.SkinningManager.Run()
    wait(5000)
end