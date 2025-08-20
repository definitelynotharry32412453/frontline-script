--[[ WARNING: Use at your own risk! ]]--

-- CONFIGURATION
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local TRANSPARENCY = 1
local NOTIFICATIONS = false

local AIM_FOV = 100 -- pixels radius for aimbot target lock
local AIM_SMOOTHNESS = 0.15 -- how fast the camera moves to target (0.1-0.3 good)

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- NOTIFY HELPER
local function notify(title, text, duration)
    if NOTIFICATIONS then
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 5,
            })
        end)
    end
end

notify("Script", "Loading script...", 3)

-- LOAD ESP LIBRARY
local espLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/andrewc0de/Roblox/main/Dependencies/ESP.lua"))()
if not espLib then
    notify("Error", "Failed to load ESP library.", 5)
    return
end

local esp = espLib
esp.Boxes = true
esp.Names = false
esp.Tracers = false
esp.Players = false

-- Add enemy listener to ESP for "soldier_model" (enemy)
esp:AddObjectListener(workspace, {
    Name = "soldier_model",
    Type = "Model",
    Color = Color3.fromRGB(255, 0, 4),
    PrimaryPart = function(obj)
        local root
        repeat
            root = obj:FindFirstChild("HumanoidRootPart")
            task.wait()
        until root
        return root
    end,
    Validator = function(obj)
        task.wait(1)
        return not obj:FindFirstChild("friendly_marker")
    end,
    CustomName = "?",
    IsEnabled = "enemy"
})

esp.enemy = true
esp:Toggle(true)

-- APPLY HITBOXES TO ENEMIES
local function applyHitbox(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and (part.Position - pos).Magnitude <= 5 then
            part.Transparency = TRANSPARENCY
            part.Size = HITBOX_SIZE
        end
    end
end

-- Initial hitboxes on existing enemies
task.wait(1)
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        applyHitbox(model)
    end
end

-- Apply hitbox when new enemy spawns
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(1)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        applyHitbox(descendant)
        notify("Warning", "New enemy spawned!", 3)
    end
end)

-- AIMBOT FUNCTIONS

local Mouse = LocalPlayer:GetMouse()

local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = AIM_FOV

    for _, model in pairs(workspace:GetChildren()) do
        if model.Name == "soldier_model" and model:FindFirstChild("HumanoidRootPart") and not model:FindFirstChild("friendly_marker") then
            local hrp = model.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (targetPos - mousePos).Magnitude

                if dist < shortestDistance then
                    shortestDistance = dist
                    closestTarget = hrp
                end
            end
        end
    end

    return closestTarget
end

local function aimAt(target)
    if not target then return end
    local camCFrame = Camera.CFrame
    local direction = (target.Position - camCFrame.Position).Unit
    local targetCFrame = CFrame.new(camCFrame.Position, camCFrame.Position + direction)
    Camera.CFrame = camCFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)
end

-- AIMBOT LOOP
RunService.RenderStepped:Connect(function()
    local target = getClosestTarget()
    if target then
        aimAt(target)

        -- Simulate left mouse click (works with most injectors)
        mouse1press()
        task.wait(0.01)
        mouse1release()
    end
end)

notify("Script", "Loaded!", 3)


