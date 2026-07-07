local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path


local UEHelpers = require("UEHelpers")
local H = require("Shared.Helpers")
H.Init("IncidentalStealer :")

local LastPatchTime = 0
local COOLDOWN = 5000 -- 5 seconds in milliseconds
local function PatchAvailTags()
    local CurrentTime = os.clock() * 1000
    if (CurrentTime - LastPatchTime) < COOLDOWN then
        H.LogDebug("Patch skipped: Cooldown active.")
        return
    end
    LastPatchTime = CurrentTime
    ---@type ADatabaseDefineStatic | UObject
    local DB = FindFirstOf("DatabaseDefineStatic")
    if not DB or not DB.m_SkillAvailID or not DB.m_SkillAvailID.m_DataList then
        H.LogError("Mod Error: Could not locate DataList.")
        return
    end
    H.LogDebug("Found DataList.")
    ExecuteWithDelay(500, function()
        local DBname = DB:GetFullName()
        if not DBname then
            H.LogError("Mod Error: Could not get full name of DatabaseDefineStatic.")
            return
        end
        H.LogDebug(DBname)
        H.LogDebug("Starting to patch AvailTag for ID 75162...")
        local TargetID = 75162
        local NewTags = { 1, 2, 3, 4, 5, 15, 0 }
        local DataList = DB.m_SkillAvailID.m_DataList

        DataList:ForEach(function(Index, Elem)
            local Entry = Elem:get()
            if Entry.m_id == TargetID then
                H.LogDebug("Found ID " .. TargetID .. " at index " .. Index)
                H.PrettyPrintTArray(Entry.m_AvailTag, "AvailTagBefore")
                Entry.m_AvailTag = NewTags
                Elem:set(Entry)
                H.PrettyPrintTArray(Entry.m_AvailTag, "AvailTagAfter")
                H.LogDebug("Successfully replaced AvailTag for ID " .. TargetID)
            end
        end)
    end)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    ExecuteWithDelay(1500, PatchAvailTags)
end)
