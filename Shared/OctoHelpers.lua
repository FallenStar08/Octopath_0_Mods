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
    H.LogDebug("[OctoHelpers.Patch] Creating patch task for path: " .. tostring(path))
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
        H.LogDebug("[PatchTask.All] Enabling list mode for path: " .. tostring(self.path))
        self._isList = true
        return self
    end

    ---@param self PatchTask
    ---@param field string
    ---@param value any
    function task:Where(field, value)
        H.LogDebug("[PatchTask.Where] Setting filter for path: " ..
            tostring(self.path) .. ", field: " .. tostring(field) .. ", value: " .. tostring(value))
        self._matchField = field
        self._matchValue = value
        return self
    end

    ---@param self PatchTask
    ---@param ms number
    function task:Cooldown(ms)
        H.LogDebug("[PatchTask.Cooldown] Adding cooldown modifier for path: " ..
            tostring(self.path) .. ", ms: " .. tostring(ms))
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
        H.LogDebug("[PatchTask.Delay] Scheduling delayed execution for path: " ..
            tostring(self.path) .. ", delay ms: " .. tostring(ms))
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
        if not DB then
            H.LogError("[PatchTask._runActualPatch] DatabaseDefineStatic not found. Aborting path: " ..
                tostring(self.path))
            return
        end

        local current = DB
        for part in string.gmatch(self.path, "([^.]+)") do current = current[part] end

        local pendingUpdates = {}
        local scannedCount = 0
        local matchedCount = 0
        local updatedCount = 0

        H.LogDebug("[PatchTask._runActualPatch] Beginning iteration for path: " .. tostring(self.path) ..
            ". Is list: " ..
            tostring(self._isList) .. (self._matchField and (", match field: " .. tostring(self._matchField) ..
                ", match value: " .. tostring(self._matchValue)) or ""))

        current:ForEach(function(Index, Elem)
            scannedCount = scannedCount + 1

            local Entry = Elem:get()
            if self._isList or (self._matchField and Entry[self._matchField] == self._matchValue) then
                matchedCount = matchedCount + 1
                callback(Entry)
                table.insert(pendingUpdates, { elem = Elem, entry = Entry })
            end
        end)

        H.LogDebug("[PatchTask._runActualPatch] Iteration complete. Scanned: " ..
            tostring(scannedCount) ..
            ", matched: " .. tostring(matchedCount) .. ", pending updates: " .. tostring(#pendingUpdates))

        for i, update in ipairs(pendingUpdates) do
            update.elem:set(update.entry)
            updatedCount = updatedCount + 1
        end

        H.LogDebug("[PatchTask._runActualPatch] Patch complete for path: " .. tostring(self.path) ..
            ", updated: " .. tostring(updatedCount) .. " entries.")
    end

    return task
end

return octoHelpers
