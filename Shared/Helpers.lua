local Helpers = {

}
local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
local LOG_PREFIX = nil
local logPath = sd .. "log.txt"
local IsLogInitialized = false
local CONFIG = require("config")

---Log a message
---@param message string
function Helpers.Log(message)
    if CONFIG.LogLevel >= 2 and message then
        print((LOG_PREFIX and LOG_PREFIX .. " " or "") ..
            message .. "\n")
    end
end

---Log a warning message if the log level is set to 1 or higher
---@param message string
function Helpers.LogWarning(message)
    if CONFIG.LogLevel >= 1 and message then
        print((LOG_PREFIX and LOG_PREFIX .. " " or "") ..
            message .. "\n")
    end
end

---Log an error message if the log level is set to 1 or higher
---@param message string
function Helpers.LogError(message)
    if CONFIG.LogLevel >= 1 and message then
        print((LOG_PREFIX and LOG_PREFIX .. " " or "") ..
            message .. "\n")
    end
end

---Log a debug message if the log level is set to 3 or higher
---@param message string
function Helpers.LogDebug(message)
    if CONFIG.LogLevel >= 3 and message then
        print((LOG_PREFIX and LOG_PREFIX .. " " or "") ..
            message .. "\n")
    end
end

---Log a message to a file
---@param message string
function Helpers.LogToFile(message)
    local mode = "a"
    if not IsLogInitialized then
        mode = "w"
        IsLogInitialized = true
    end

    local file = io.open(logPath, mode)
    if file then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        file:write(string.format("[%s] %s\n", timestamp, message))
        file:close()
    end

    Helpers.Log(message)
end

---Retries a function until it succeeds or the max retries are reached
---@param func fun(): boolean # The function to call; return true when the retry should stop
---@param interval integer # Time in ms between attempts
---@param maxRetries integer # How many times to try before giving up
function Helpers.RetryFunction(func, interval, maxRetries)
    local attempts = 0
    local function attempt()
        attempts = attempts + 1
        local success, result = pcall(func)
        if success and result == true then
            return
        end
        if attempts < maxRetries then
            ExecuteWithDelay(interval, attempt)
        else
            Helpers.LogWarning(string.format("Retry limit reached (%d attempts).", attempts))
        end
    end

    attempt()
end

local CooldownTracker = {}

--- Executes a function only if the cooldown for the given ID has expired
--- @param id string: Unique name for this cooldown
--- @param cooldown number: Time in milliseconds
--- @param func function: The logic to execute
function Helpers.ExecuteWithCooldown(id, cooldown, func)
    local CurrentTime = os.clock() * 1000
    local LastTime = CooldownTracker[id] or 0

    if (CurrentTime - LastTime) < cooldown then
        Helpers.LogDebug("Execution skipped for '" .. id .. "': Cooldown active.")
        return
    end

    CooldownTracker[id] = CurrentTime
    func()
end

function Helpers.Init(log_prefix)
    LOG_PREFIX = log_prefix
    Helpers.Log("Mod Initialized")
end

--- Pretty print a TArray for debugging purposes
--- @param TArrayObj table The TArray to print
--- @param Name string Optional name for the array
function Helpers.PrettyPrintTArray(TArrayObj, Name)
    if CONFIG.LogLevel < 3 then
        return
    end
    local ArrayName = Name or "TArray"
    local Count = TArrayObj:GetArrayNum()

    print(string.format("\n=== Pretty Printing %s | Size: %d ===", ArrayName, Count))

    if Count == 0 then
        print("  [ Empty ]")
    else
        TArrayObj:ForEach(function(Index, Elem)
            local Value = Elem:get()
            -- Format with alignment for better readability
            print(string.format("  [%3d] -> %s", Index, tostring(Value)))
        end)
    end

    print(string.format("=== End of %s ===\n", ArrayName))
end

return Helpers
