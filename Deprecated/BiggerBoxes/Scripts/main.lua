local UEHelpers = require("UEHelpers")
local config = require("config")

local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("Bigger Boxes :")



local BoxAvailsValues = {
    74373, --Small Harvest Box 10
    74374, --Medium Harvest Box 30
    74375, --Large Harvest Box 100
    74377, --Small GatherBox 10
    74379, --Medium GatherBox 30
    74381, --Large GatherBox 100
    76124, --Small GatherBox Money (25k)
    76125, --Medium GatherBox Money (60k)
    76126, --Large GatherBox Money (100k)

}

local function patch()
    OH.Patch("m_SkillAvailID.m_DataList")
        :Where("m_id", BoxAvailsValues)
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            if entry.m_Values and type(entry.m_Values.ForEach) == "function" then
                entry.m_Values:ForEach(function(index, elem)
                    local value = elem:get()
                    if value ~= 0 then
                        elem:set(value * config.StorageMulti)
                    end
                end)
            end
        end)
end


RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
