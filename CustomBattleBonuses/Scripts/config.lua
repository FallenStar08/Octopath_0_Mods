local LogLevel = {
    DEBUG = 3,
    INFO = 2,
    ERROR = 1,
    NONE = 0
}


local CONFIG = {
    LogLevel = LogLevel.DEBUG,
    battleBonuses = {
        ["NoDamage"] = 0.25,
        ["OverKill"] = 0.25,
        ["Break"] = 0.25,
        ["1TurnKill"] = 0.25,
    }

}

return CONFIG
