-- feeeeel by SirCrabapple99
-- https://github.com/SirCrabapple99/feeeeel

local UEHelpers = require("UEHelpers")

-- default camerashake classes
local defaultClasses = {
    -- class = { intensity multiplier, duration }
    CameraShakeBIMBO_C = {0.6, 0.30}, -- footsteps of large creatures
}

-- pull config
local ok, cfg = pcall(require, "config")
if not ok or type(cfg) ~= "table" then
    print("[feeeeel] config.lua failed to load, using defaults: " .. tostring(cfg) .. "\n")
    cfg = defaultClasses
end

local classes = {}
for name, v in pairs(cfg) do
    if type(v) == "table" and type(v[1]) == "number" then
        classes[name] = { intensity = v[1], duration = tonumber(v[2]) or 0 }
    else
        print("[feeeeel] bad entry for " .. tostring(name) .. ", skipping\n")
    end
end

-- vibration function to call
local function Vibrate(vibType, intensity, duration)
    ExecuteInGameThread(function()
        -- get player controller
        local okPC, PC = pcall(UEHelpers.GetPlayerController)
        if not okPC or not PC or not PC:IsValid() then
            print("[feeeeel] [vib] no PC\n")
            return
        end
        -- start vibtration
        local ok, err = pcall(function()
            -- idk what vibtype is but I'm pretty sure it should always be set to 2
            PC:StartVibration(vibType, intensity, duration)
        end)
        if not ok then
            print("[feeeeel] [vib] call failed: " .. tostring(err) .. "\n")
        end
    end)
end

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

    print(string.format("[feeeeel] className: %s intensity: %.3f duration: %.3f\n", className, intensity, duration))

    Vibrate(2, intensity, duration)
end)

