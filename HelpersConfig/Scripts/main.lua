local UEHelpers = require("UEHelpers")
local config = require("config")

local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("Helpers Config :")



local VILLAGE_BONUS_TYPE_SUPPORTER_ENTRY_COUNT = {
    74357, -- church bonus + 2 uses
    75131  -- church bonus + 4 uses
}

local function patch()
    OH.Patch("m_SkillAvailID.m_DataList")
        :Where("m_id", VILLAGE_BONUS_TYPE_SUPPORTER_ENTRY_COUNT)
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            if entry.m_Values and type(entry.m_Values.ForEach) == "function" then
                entry.m_Values:ForEach(function(index, elem)
                    local value = elem:get()
                    if value ~= 0 then
                        elem:set(value * config.MaxHelpersAmountMulti)
                    end
                end)
            end
        end)
end




RegisterKeyBind(Key.F5, patch)


RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)
