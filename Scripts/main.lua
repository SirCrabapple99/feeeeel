-- feeeeel by SirCrabapple99
-- https://github.com/SirCrabapple99/feeeeel

local UEHelpers = require("UEHelpers")

-- vibration function to call
local function Vibrate(vibType, intensity, duration)
    ExecuteInGameThread(function()
        -- get player controller
        local okPC, PC = pcall(UEHelpers.GetPlayerController)
        if not okPC or not PC or not PC:IsValid() then
            print("[Feeeeel] [vib] no PC\n")
            return
        end
        -- start vibtration
        local ok, err = pcall(function()
            -- idk what vibtype is but I'm pretty sure it should always be set to 2
            PC:StartVibration(vibType, intensity, duration)
        end)
        if not ok then
            print("[Feeeeel] [vib] call failed: " .. tostring(err) .. "\n")
        end
    end)
end

-- list of camerashake classes
local classes = {
    -- Example Class = { Intensity Multiplier, Duration }

    -- player taking damage
    -- CameraShakeBIMBO2_C = {0.5, 0.1},

    -- player dealing damage
    --[[ CamerashakeInenso_C = {0.35, 0.1},
    CamerashakeInenso1_C = {0.35, 0.1},
    CamerashakeHitPRO_C = {0.25, 0.12}, ]]--

    -- footsteps of large creatures
    CameraShakeBIMBO_C = {0.6, 0.30},
}

-- log each camera shake
NotifyOnNewObject("/Script/Engine.CameraShakeBase", function(obj)
    if not obj or not obj:IsValid() then
        return
    end

    local className = obj:GetClass():GetFName():ToString()
    local entry = classes[className]
    if not entry then
        return
    end

    local baseIntensity, duration = entry[1], entry[2]
    local scale = tonumber(tostring(obj.ShakeScale)) or 1.0
    local intensity = math.min(baseIntensity * scale, 1.0)

    print(string.format("[Feeeeel] className: %s intensity: %.3f duration: %.3f\n", className, intensity, duration))

    Vibrate(2, intensity, duration)
end)

