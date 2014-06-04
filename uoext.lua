--- UOEXT Dispatcher file - it combines all libraries together
-- @module UOExt

-- Core & Utilities
dofile(".\\Utils\\Core.lua")
dofile(".\\Utils\\Config.lua")

-- External libraries
dofile(".\\Lib\\FluentUO\\FluentUO.lua")
dofile(".\\Lib\\GetHitBarLife\\GetHitBarLife.lua")
dofile(".\\Lib\\json4lua\\json4lua.lua")
dofile(".\\Lib\\kalocr\\kalocr.lua")
dofile(".\\Lib\\kalinex_journal\\journal.lua")

-- Structures
dofile(".\\Structs\\LimitedStack.lua")

-- Managers and helpers
dofile(".\\Managers\\ItemManager.lua")
dofile(".\\Managers\\SkinningManager.lua")