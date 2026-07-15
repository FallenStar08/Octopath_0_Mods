local LogLevel = {
    DEBUG = 3,
    INFO = 2,
    ERROR = 1,
    NONE = 0
}

local CONFIG = {

    --Main toggles for each module
    CATS_DONT_FLEE_ENABLED = true,        --Toggle to remove the ability for Cait (& octodudes) to flee
    STATS_BOOST_ENABLED = true,           --Toggle to enable the global stats boost for enemies, this will apply the multipliers defined in GlobalStatsBoost to all enemies in the game
    CUSTOM_BATTLE_BONUSES_ENABLED = true, --Toggle to enable custom battle bonuses


    --Bonuses for battle conditions, values are additive multipliers to the base (1.0) reward (0.25 = 1.25 total bonus = 25% bonus)
    battleBonuses = {
        ["NoDamage"] = 0.25,
        ["OverKill"] = 0.25,
        ["Break"] = 0.25,
        ["1TurnKill"] = 0.25,
    },


    --Stats boost values for enemies, these are multipliers to the base stats (1.0 = no change, 1.25 = 25% increase, 0.75 = 25% decrease)
    GlobalStatsBoost = {
        BoostNormals = true, -- wether to apply the boost to normal enemies
        Normal = {
            m_MaxHP = 1.25,
            m_MaxSP = 1.25,
            m_DefP = 1.20,
            m_AtkP = 1.20,
            m_AtkM = 1.20,
            m_DefM = 1.20,
            m_Agi = 1.10,
            m_Crt = 1.20,
            m_CrtDef = 1.00,
            m_Hit = 1.00,
            m_Avd = 1.00,
            m_DamageRate = 1.00,
            m_Exp = 1.0,
            m_Money = 1.0,
            m_JP = 1.0,
        },
        BoostBosses = true,          -- wether to apply the boost to bosses
        UseBossSpecificBoost = true, --If false then bosses will use the same boost as normal enemies
        Boss = {
            m_MaxHP = 1.20,
            m_MaxSP = 1.00,
            m_DefP = 1.00,
            m_AtkP = 1.10,
            m_AtkM = 1.10,
            m_DefM = 1.00,
            m_Agi = 1.00,
            m_Crt = 1.05,
            m_CrtDef = 1.00,
            m_Hit = 1.00,
            m_Avd = 1.00,
            m_DamageRate = 1.00,
            m_Exp = 1.0,
            m_Money = 1.0,
            m_JP = 1.0,
        }
    },
    LogLevel = LogLevel.INFO, --Dont touch UwU
}

return CONFIG
