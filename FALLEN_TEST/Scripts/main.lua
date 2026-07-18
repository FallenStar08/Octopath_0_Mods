local UEHelpers = require("UEHelpers")
local config = require("config")

local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("FALLEN TEST :")


---@type AQPBattleManager | UObject?
local battle_manager = nil


---Gets the battle manager instance
---@return AQPBattleManager | UObject?
local get_battle_manager = function()
    local found = FindFirstOf("QPBattleManager")
    if found and found:IsValid() then
        return found
    end
    return nil
end


NotifyOnNewObject("/Script/Kingship.BattleActionID", function(obj)
    print("New BattleActionID object created: " .. tostring(obj))
end)

NotifyOnNewObject("/Script/Kingship.BattleActionIDBase", function(obj)
    print("New BattleActionIDBase object created: " .. tostring(obj))
end)


NotifyOnNewObject("/Script/Kingship.BattlePlaybacksBase", function(obj)
    print("New BattlePlaybacksBase object created: " .. tostring(obj))
end)
