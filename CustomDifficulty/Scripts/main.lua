local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
local config = require("config")
H.Init("Custom Difficulty :")


local OriginalStatsCache = {}

local function patch()
    OH.Patch("m_EnemyID.m_DataList")
        :All()
        :Execute(function(entry)
            local id = entry.m_id

            if not OriginalStatsCache[id] then
                OriginalStatsCache[id] = {}
                local modifiers = config.GlobalBoost.Normal
                for field, _ in pairs(modifiers) do
                    if entry[field] ~= nil then
                        OriginalStatsCache[id][field] = entry[field]
                    end
                end
            end

            local isBoss = entry.m_IsBoss
            if (isBoss and not config.GlobalBoost.BoostBosses) or
                (not isBoss and not config.GlobalBoost.BoostNormals) then
                return
            end

            local modifiers = (isBoss and config.GlobalBoost.UseBossSpecificBoost and config.GlobalBoost.Boss)
                or config.GlobalBoost.Normal

            for field, multiplier in pairs(modifiers) do
                if OriginalStatsCache[id][field] ~= nil then
                    entry[field] = math.floor(OriginalStatsCache[id][field] * multiplier)
                end
            end

            entry.m_HpUI = true
        end)
end
RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
