local UEHelpers = require("UEHelpers")
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary

local ksl = GetKismetSystemLibrary()
local engine = FindFirstOf("Engine")



--- @param cmd string
function ExecCmd(cmd)
    if not ksl:IsValid() then return end

    ExecuteInGameThread(function()
        ksl:ExecuteConsoleCommand(engine, cmd, nil)
    end)
end

function ApplyMaxFPS()
    ExecCmd("t.MaxFPS 144")
end

NotifyOnNewObject("/Script/Engine.Level", function()
    ApplyMaxFPS()
end)
