--[[
;----------------------------------
; Script Name: SkinRun.lua
; Author: Luke Lewandowski
; Version: 1.0
; Client Tested with: 7.0.34.22
; EUO version tested with: OpenEUO
; Shard OSI / FS: FS
; Purpose: 
; - Find and loots hides from any nearby corpses.
; Note: For full featured looter, use LooterRun.lua
;----------------------------------]]

dofile(".\\skinner.lua")
dofile(".\\Managers\\SkinningManager.lua")

while true do
    UOExt.Managers.SkinningManager.Run()
    wait(5000)
end