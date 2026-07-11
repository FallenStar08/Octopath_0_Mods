local UEHelpers = require("UEHelpers")


local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("IncidentalStealer :")

local AVAIL_TYPE = {
    NONE = 0,
    ATTACK = 1,
    ATTACK_ALL_TARGET = 2,
    ATTACK_SINGLE_TARGET = 3,
    ATTACK_MULTIPLE = 4,
    ATTACK_SINGLE = 5,
    HEAL = 6,
    STEAL = 7,
    MAGIC = 8,
    ITEM = 9,
    MAGICSTONE = 10,
    BUFF = 11,
    DEBUFF = 12,
    MAGIC_ALL_TARGET = 13,
    MAGIC_SINGLE_TARGET = 14,
    ATTACK_NORMAL = 15,
    WEAPON = 16,
    COMMAND = 17,
    SONG_DANCE = 18,
    MAGIC_SKILL = 19,
    HP_REGENERATE = 20,
    BUFF_DEBUFF = 21,
    DANCER_SKILL = 22,
    CONDUCTOR_SKILL = 23,
    HP_HEAL = 24,
    MAGIC_HEAL = 25,
    ATTACK_TARGET_EXTENSION_TARGET = 26,
    NOT_MAGIC_TARGET_SINGLE_TARGET = 27,
    ITEM_HEAL = 28,
    NOT_ATTACK = 29,
    EVENT_REVIVE = 30,
    CAN_NOT_PARRY = 31,
    ESKILL_AVAIL_MAX = 32,
}

local newTags = {
    AVAIL_TYPE.ATTACK,
    AVAIL_TYPE.BUFF_DEBUFF,
    AVAIL_TYPE.HEAL,
    AVAIL_TYPE.ATTACK_NORMAL,
    AVAIL_TYPE.ITEM,
    AVAIL_TYPE.NOT_ATTACK,
    AVAIL_TYPE.STEAL,
}

local incidentals = {
    75160, -- incidental heal
    75162, --incidental steal
    75158, --incidental attack
    75156, --incidental analysis
}

local function patch()
    OH.Patch("m_SkillAvailID.m_DataList")
        :Where("m_id", incidentals)
        :Cooldown(5000)
        :Delay(2000)
        :Execute(function(entry)
            entry.m_AvailTag = newTags
        end)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", patch)

RegisterKeyBind(Key.F5, patch)
