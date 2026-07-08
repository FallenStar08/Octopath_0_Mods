local UEHelpers = require("UEHelpers")
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary

local ksl = GetKismetSystemLibrary()
local engine = FindFirstOf("Engine")



--- @param cmd string
function ExecCmd(cmd)
    ---@diagnostic disable-next-line: undefined-field
    if not ksl:IsValid() then return end

    ExecuteInGameThread(function()
        ---@diagnostic disable-next-line: undefined-field
        ksl:ExecuteConsoleCommand(engine, cmd, nil)
    end)
end

function ApplyMaxFPS()
    ExecCmd("t.MaxFPS 144")
end

NotifyOnNewObject("/Script/Engine.Level", function()
    ApplyMaxFPS()
end)
