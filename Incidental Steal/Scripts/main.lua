local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("IncidentalStealer :")


RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    OH.Patch("m_SkillAvailID.m_DataList")
        :Where("m_id", 75162)
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            entry.m_AvailTag = { 1, 2, 3, 4, 5, 15, 0 }
        end)
end)
