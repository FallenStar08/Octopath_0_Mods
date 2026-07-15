local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
local config = require("config")
H.Init("Custom Difficulty :")


local OriginalStatsCache = {}

local CatsIDs = {
    432,
    433,
    434,
    55531,
    55532,
    55533,
    55534,
    55535,
    55536,
    55538
}

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
    --Module difficulty (stats)
    if config.STATS_BOOST_ENABLED then
        H.LogDebug("Patching enemy stats")
        OH.Patch("m_EnemyID.m_DataList")
            :All()
            :Execute(function(entry)
                local id = entry.m_id

                if not OriginalStatsCache[id] then
                    OriginalStatsCache[id] = {}
                    local modifiers = config.GlobalStatsBoost.Normal
                    for field, _ in pairs(modifiers) do
                        if entry[field] ~= nil then
                            OriginalStatsCache[id][field] = entry[field]
                        end
                    end
                end

                local isBoss = entry.m_IsBoss
                if (isBoss and not config.GlobalStatsBoost.BoostBosses) or
                    (not isBoss and not config.GlobalStatsBoost.BoostNormals) then
                    return
                end

                local modifiers = (isBoss and config.GlobalStatsBoost.UseBossSpecificBoost and config.GlobalStatsBoost.Boss)
                    or config.GlobalStatsBoost.Normal

                for field, multiplier in pairs(modifiers) do
                    if OriginalStatsCache[id][field] ~= nil then
                        entry[field] = math.floor(OriginalStatsCache[id][field] * multiplier)
                    end
                end

                entry.m_HpUI = true
            end)
    end

    --Module Cats
    if config.CATS_DONT_FLEE_ENABLED then
        H.LogDebug("Patching rare enemy skills")
        OH.Patch("m_TacticalSkillList.m_DataList")
            :Where("m_id", CatsIDs)
            :Cooldown(5000)
            :Delay(2000)
            :Execute(function(entry)
                if entry.m_UseSkills and type(entry.m_UseSkills.ForEach) == "function" then
                    entry.m_UseSkills:ForEach(function(index, elem)
                        if elem:get() == 4 then
                            elem:set(0)
                        end
                    end)
                end
            end)
    end

    --Module Battle Bonuses
    if config.CUSTOM_BATTLE_BONUSES_ENABLED then
        H.LogDebug("Patching battle bonuses")
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
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
