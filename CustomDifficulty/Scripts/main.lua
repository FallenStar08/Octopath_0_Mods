local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
local config = require("config")
H.Init("CustomDifficulty :")

local function patch()
    if not config.GlobalBoost.BoostNormals and not config.GlobalBoost.BoostBosses then
        H.LogDebug("Both BoostNormals and BoostBosses are disabled. No modifications will be applied.")
        return
    end
    OH.Patch("m_EnemyID.m_DataList")
        :All()
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            entry.m_HpUI = true
            local isBoss = entry.m_IsBoss
            if config.GlobalBoost.BoostBosses == false and isBoss then
                return
            end
            if config.GlobalBoost.BoostNormals == false and not isBoss then
                return
            end
            local modifiers = (isBoss and config.GlobalBoost.UseBossSpecificBoost and config.GlobalBoost.Boss) or
                config.GlobalBoost.Normal

            for field, multiplier in pairs(modifiers) do
                if entry[field] ~= nil and type(entry[field]) == "number" then
                    entry[field] = math.floor(entry[field] * multiplier)
                end
            end
        end)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
