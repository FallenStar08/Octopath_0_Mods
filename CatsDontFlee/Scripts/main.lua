local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("CatsDontFlee :")



local IdsToPatch = {
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

local function patch()
    OH.Patch("m_TacticalSkillList.m_DataList")
        :Where("m_id", IdsToPatch)
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


RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
