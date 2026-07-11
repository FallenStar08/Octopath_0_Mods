local LogLevel = {
    DEBUG = 3,
    INFO = 2,
    ERROR = 1,
    NONE = 0
}


local CONFIG = {
    LogLevel = LogLevel.DEBUG,
    GlobalBoost = {
        BoostNormals = false,
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
            m_PetExp = 1.0,
            m_JP = 1.0,
        },
        BoostBosses = true,
        UseBossSpecificBoost = true,
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
            m_PetExp = 1.0,
            m_JP = 1.0,
        }
    }

}

return CONFIG
