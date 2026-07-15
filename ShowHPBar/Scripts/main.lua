local UEHelpers = require("UEHelpers")
local config = require("config")

local sd = debug.getinfo(1, 'S').source:sub(2):match("^(.*[\\/])") or ""
--Add the current mod directory and the 'Shared' subfolder to the search path
package.path = sd .. "/?.lua;" .. sd .. "/Shared/?.lua;" .. package.path

local H = require("Shared.Helpers")
local OH = require("Shared.OctoHelpers")
H.Init("HP BAR :")

---Big thanks to VeganPrimate
---@param widget any
local function ForceVisibilityDelayed(widget)
    ExecuteWithDelay(666, function()
        if widget and widget:IsValid() then
            if widget.m_DebugHPBarRoot and widget.m_DebugHPBarRoot:IsValid() then
                widget.m_DebugHPBarRoot:SetVisibility(3)
                widget.m_DebugHPBarRoot:SetRenderOpacity(1.0)
            end
            if widget.HPBar and widget.HPBar:IsValid() then
                widget.HPBar:SetVisibility(3)
                widget.HPBar:SetRenderOpacity(1.0)
            end
        end
    end)
end



---Gets the battle manager instance
---@return AQPBattleManager | UObject?
local get_battle_manager = function()
    local found = FindFirstOf("QPBattleManager")
    if found and found:IsValid() then
        return found
    end
    return nil
end


---@type AQPBattleManager | UObject?
local battle_manager = nil


local original_name_cache = {}
local last_hp_values = {}

---Updates the health display for all enemies by appending its current and max HP to its name in the status UI.
local function update_health_display()
    if not battle_manager or not battle_manager:IsValid() then return end

    local enemies = battle_manager.m_BattleEnemies
    if not enemies or not enemies:IsValid() then return end

    enemies:ForEach(function(index, enemy)
        local enemy_ptr = enemy:get()
        if not enemy_ptr or not enemy_ptr:IsValid() then return end

        local success, err = pcall(function()
            local hp = enemy_ptr:GetHP()
            local max_hp = enemy_ptr:GetMaxHP()
            local addr = enemy_ptr:GetAddress()

            local status = enemy_ptr.m_BattleStatusUI
            if status and status:IsValid() and status.m_Name then
                if not original_name_cache[addr] then
                    local name_text = status.m_Name.Text
                    original_name_cache[addr] = name_text and name_text:ToString() or "Enemy"
                end

                local clean_name = original_name_cache[addr]
                local new_string = string.format("%s\n(%d/%d)", clean_name, hp, max_hp)

                status.m_Name.Text = FText(new_string)

                if status.m_Name.refreshUI then
                    status.m_Name:refreshUI()
                end
            end
        end)

        if not success then
            H.LogDebug("Skipped update: " .. tostring(err))
        end
    end)
end


local is_loop_running = false

---Monitors the health of all enemies in the battle and updates the health display when changes are detected.
local function start_loop()
    is_loop_running = true

    LoopAsync(200, function()
        if not battle_manager or not battle_manager:IsValid() then
            H.LogDebug("Battle manager is no longer valid. Stopping the loop.")
            is_loop_running = false
            return true
        end

        local enemies = battle_manager.m_BattleEnemies
        if not enemies or not enemies:IsValid() or #enemies == 0 then
            H.LogDebug("Combat ended or no enemies found. Stopping the loop.")
            last_hp_values = {}
            original_name_cache = {}

            is_loop_running = false
            return true
        end

        enemies:ForEach(function(index, enemy)
            local enemy_ptr = enemy:get()
            if enemy_ptr and enemy_ptr:IsValid() then
                local current_hp = enemy_ptr:GetHP()
                local address = tostring(enemy_ptr:GetAddress())

                if last_hp_values[address] ~= current_hp then
                    last_hp_values[address] = current_hp
                    update_health_display()
                end
            end
        end)
        return false
    end)
end

NotifyOnNewObject("/Game/UI/Battle/BP/CharacterStatus/BattleEnemyStatus.BattleEnemyStatus_C", function(new_widget)
    if config.SHOW_HP_BAR then
        H.LogDebug("New enemy status widget detected, applying fix...")
        ForceVisibilityDelayed(new_widget)
    end
    if config.SHOW_HP_NUMBERS then
        battle_manager = get_battle_manager()
        ExecuteWithDelay(666, update_health_display)
        ExecuteWithDelay(666, function()
            if not is_loop_running then
                start_loop()
            end
        end)
    end
end)
