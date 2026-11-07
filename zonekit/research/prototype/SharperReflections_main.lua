-- SharperReflections: Lumen reflection settings that Ultra+ has no menu entry for.
-- Applied a few seconds after every load, after Ultra+ has applied its own settings.
local CVARS = {
    -- reflections show the real shapes of objects near the reflecting surface
    {'r.Lumen.Reflections.TraceMeshSDFs', '1'},
    {'r.Lumen.TraceMeshSDFs.TraceDistance', '180'},
    -- sharper colours of the things seen in reflections
    {'r.Lumen.Reflections.SurfaceCacheFeedback', '1'},
}
local DELAY_MS = 10000

local UEHelpers = require('UEHelpers')

local function log(msg)
    print('[SharperReflections] ' .. msg .. '\n')
end

local function apply()
    local ok, err = pcall(function()
        local ksl = UEHelpers.GetKismetSystemLibrary()
        local engine = FindFirstOf('Engine')
        if not ksl or not ksl:IsValid() or not engine or not engine:IsValid() then
            log('engine not ready, skipped')
            return
        end
        for _, c in ipairs(CVARS) do
            ksl:ExecuteConsoleCommand(engine, c[1] .. ' ' .. c[2], nil)
        end
        log('applied ' .. #CVARS .. ' settings')
    end)
    if not ok then log('error: ' .. tostring(err)) end
end

RegisterHook('/Script/Engine.PlayerController:ClientRestart', function()
    ExecuteWithDelay(DELAY_MS, function()
        ExecuteInGameThread(apply)
    end)
end)

log('loaded')
