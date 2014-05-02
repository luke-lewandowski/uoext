dofile(".\\skinner.lua")

Skinner.Options = {
    ["hideContainer"] = 1075309910,

    ["knifeType"] = 3922,
    ["scissorsType"] = 3999,
    ["distance"] = 2
}

while true do
    Skinner.Run()
    wait(5000)
end