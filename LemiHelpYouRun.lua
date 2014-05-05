dofile(".\\Utils\\Core.lua")
dofile(".\\Utils\\Config.lua")
dofile(".\\Lib\\FluentUO\\FluentUO.lua")
dofile(".\\Lib\\GetHitBarLife\\GetHitBarLife.lua")
dofile(".\\Lib\\json4lua\\json4lua.lua")
dofile(".\\Structs\\LimitedStack.lua")
dofile(".\\Managers\\ItemManager.lua")
dofile(".\\Managers\\SkinningManager.lua")

LHYMain = LHYMain or {}

-- Basic settings for this applications
LHYMain.Settings = {
	-- Each character will create its own config
	["configFile"] = getbasedir() .. "\\Configs\\config_" .. string.gsub(UO.CharName, " ", "_") .. ".json",
	["timeInterval"] = 1000
}

-- JSon config file should mimic following structure
local configStructure = {
	["charName"] = UO.CharName,
	["shardName"] = UO.Shard,
	["vetThreshold"] = 80
}

function LHYMain:Create()
	local f = {
		["IsRunning"] = false
	}

	local _firstColumn = 5
	local _secondColumn = 150
	local _rowGap = 10

	local ems = {}

	local p_loadConfiguration = function()
		local settings = UOExt.Config.GetConfig(LHYMain.Settings.configFile)

		if(settings == nil) then
			UOExt.Config.SaveConfig(LHYMain.Settings.configFile, configStructure)
			return configStructure
		else
			return settings
		end
	end

	local p_saveConfiguration = function()
		UOExt.Config.SaveConfig(LHYMain.Settings.configFile, f.Config)

		ems.TMsg = Obj.Create("TMessageBox")
		ems.TMsg.Button = 0
		ems.TMsg.Title = "Settings"
		ems.TMsg.Show("Settings saved successfully!")
	end

	local p_showMessage = function(message)
		ems.Messages.Lines.Add(tostring(message))
	end

	local p_createVeterinaryElements = function()

		ems.TVetGroupBox = f:addControl(Obj.Create("TGroupBox"), _firstColumn, _rowGap * 1)
		ems.TVetGroupBox.Caption = "Veterinary"

		ems.TVetThresholdLabel = f:addControl(Obj.Create("TLabel"), _firstColumn, _rowGap * 1, ems.TVetGroupBox)
		ems.TVetThresholdLabel.Caption = "Health threshold: "

		ems.TVetThresholdEdit = f:addControl(Obj.Create("TEdit"), _secondColumn, _rowGap * 1, ems.TVetGroupBox)
		ems.TVetThresholdEdit.OnChange = function(sender)
			f.Config.vetThreshold = tonumber(sender.Text) or 80 -- default
		end
		ems.TVetThresholdEdit.Text = tostring(f.Config.vetThreshold) 

	end

	p_createSaveButton = function()
		ems.TSaveButton = f:addControl(Obj.Create("TButton"), _firstColumn, _rowGap * 3)
		ems.TSaveButton.Caption = "Save config"
		ems.TSaveButton.OnClick = function(sender)
			p_saveConfiguration()
		end
	end

	p_createRunButton = function()
		ems.TRunButton = f:addControl(Obj.Create("TButton"), _secondColumn, _rowGap * 3)
		ems.TRunButton.Caption = "Run"
		ems.TRunButton.OnClick = function(sender)
			f.IsRunning = not f.IsRunning
			if(f.IsRunning) then
				sender.Caption = "Running"
			else
				sender.Caption = "Run"
			end
			ems.Timer.Enabled = f.IsRunning
		end
	end

	function f:Run()
		f.Config = p_loadConfiguration()

		ems.Main = Obj.Create("TForm")
		ems.Main.Caption = "UO:LemiHelpYou"
		ems.Main.OnClose = function(sender)
			Obj.Exit()
		end

		ems.Timer = Obj.Create("TTimer")
		ems.Timer.Enabled = f.IsRunning
		ems.Timer.Interval = LHYMain.Settings.timeInterval
		ems.Timer.OnTimer = function(sender)
			p_showMessage("ping poing")
		end

		ems.Messages = f:addControl(Obj.Create("TMemo"), 200, 10)

		p_createVeterinaryElements()
		p_createSaveButton()
		p_createRunButton()

		ems.Main.Show()

		Obj.Loop()
		f:freeSpace()
	end

	function f:addControl(control, left, top, parent)
		control.Top = top
		control.Left = left

		if(parent == nil) then parent = ems.Main end
		control.Parent = parent

		return control
	end

	function f:freeSpace()
		for i,v in pairs(ems) do
			Obj.Free(v)
		end
	end

	f:Run()

	return f
end

local form = LHYMain:Create()