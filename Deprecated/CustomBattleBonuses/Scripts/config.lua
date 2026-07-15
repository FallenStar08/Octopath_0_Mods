local LogLevel = {
    DEBUG = 3,
    INFO = 2,
    ERROR = 1,
    NONE = 0
}


local CONFIG = {
    LogLevel = LogLevel.INFO,
    --Bonuses for battle conditions, values are additive multipliers to the base (1.0) reward (0.25 = 1.25 total bonus = 25% bonus)
    --These default values provide a 25% bonus for each condition
    --Defaults are like 10% I think
    battleBonuses = {
        ["NoDamage"] = 0.25,
        ["OverKill"] = 0.25,
        ["Break"] = 0.25,
        ["1TurnKill"] = 0.25,
    }

}

return CONFIG
