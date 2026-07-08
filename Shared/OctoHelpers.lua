local H = require("Shared.Helpers")

local octoHelpers = {}
local CooldownTracker = {}


---@class PatchTask
---@field path string
---@field modifiers function[]
---@field _callback function|nil
---@field _matchField string|nil
---@field _matchValue any|nil
---@field _isList boolean
---@field _scheduledDelay number|nil
---@field All fun(self: PatchTask): PatchTask
---@field Where fun(self: PatchTask, field: string, value: any): PatchTask
---@field Cooldown fun(self: PatchTask, ms: number): PatchTask
---@field Delay fun(self: PatchTask, ms: number): PatchTask
---@field Execute fun(self: PatchTask, callback: function)
---@field _runActualPatch fun(self: PatchTask, callback: function)


---Patch factory function to create a new PatchTask for modifying database entries.
---@param path any
---@return PatchTask
function octoHelpers.Patch(path)
    local task = {
        path = path,
        modifiers = {},
        _callback = nil,
        _matchField = nil,
        _matchValue = nil,
        _isList = false,
        _scheduledDelay = nil
    }

    ---@param self PatchTask
    function task:All()
        self._isList = true
        return self
    end

    ---@param self PatchTask
    ---@param field string
    ---@param value any
    function task:Where(field, value)
        self._matchField = field
        self._matchValue = value
        return self
    end

    ---@param self PatchTask
    ---@param ms number
    function task:Cooldown(ms)
        table.insert(self.modifiers, function()
            local id = self.path .. tostring(self._matchValue or "all")
            local current = os.clock() * 1000
            local last = CooldownTracker[id] or 0
            if (current - last) < ms then return false end
            CooldownTracker[id] = current
            return true
        end)
        return self
    end

    ---@param self PatchTask
    ---@param ms number
    function task:Delay(ms)
        self._scheduledDelay = ms
        return self
    end

    ---@param self PatchTask
    ---@param callback function
    function task:Execute(callback)
        for _, mod in ipairs(self.modifiers) do
            if not mod() then return end
        end

        if self._scheduledDelay then
            ExecuteWithDelay(self._scheduledDelay, function()
                self:_runActualPatch(callback)
            end)
        else
            self:_runActualPatch(callback)
        end
    end

    function task:_runActualPatch(callback)
        local DB = FindFirstOf("DatabaseDefineStatic")
        local current = DB
        H.LogDebug("Found DatabaseDefineStatic: " .. (DB and DB:GetFullName() or "nil"))
        H.LogDebug("Patching database path: " ..
            self.path ..
            (self._isList and " (all entries)" or (" where " .. self._matchField .. " = " .. tostring(self._matchValue))))

        for part in string.gmatch(self.path, "([^.]+)") do current = current[part] end

        current:ForEach(function(Index, Elem)
            local Entry = Elem:get()
            if self._isList or Entry[self._matchField] == self._matchValue then
                callback(Entry)
                Elem:set(Entry)
                H.LogDebug("Patched entry at index " .. Index .. " with ID " .. tostring(Entry[self._matchField]))
            end
        end)
    end

    return task
end

return octoHelpers
