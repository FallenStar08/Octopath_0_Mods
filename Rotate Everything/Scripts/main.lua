local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("Rotate Everything :")

local function patch()
    OH.Patch("m_VillageBuildingData.m_DataList")
        :All()
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            entry.m_RotationType = 2
        end)
    OH.Patch("m_VillageTownLevel.m_DataList")
        :All()
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            entry.m_PlacedLimitNum     = 9999
            entry.m_BuildingMaxPC      = 9999
            entry.m_BuildingMaxWINGDK  = 9999
            entry.m_BuildingMaxXSX     = 9999
            entry.m_BuildingMaxSwitch  = 9999
            entry.m_BuildingMaxSwitch2 = 9999
            entry.m_BuildingMaxPS4     = 9999
            entry.m_BuildingMaxPS5     = 9999
        end)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
