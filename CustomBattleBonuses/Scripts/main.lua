local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
local config = require("config")
H.Init("Custom Battle Bonuses :")

local battleBonusesIDs = {
    91183,
    91182,
    91180,
    91181,
}

local battleBonuses = {
    ["NoDamage"] = 91183,
    ["OverKill"] = 91182,
    ["Break"] = 91180,
    ["1TurnKill"] = 91181,
}

local function patch()
    OH.Patch("m_BattleResultBonus.m_DataList")
        :Where("m_TextID", battleBonusesIDs)
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            if entry.m_TextID then
                local bbt = entry.m_TextID
                for bonusName, bonusID in pairs(battleBonuses) do
                    if bbt == bonusID then
                        local newValue = config.battleBonuses[bonusName]
                        if newValue then
                            entry.m_AddRatio = newValue
                        end
                    end
                end
            end
        end)
end


RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
