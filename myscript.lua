--[[ WARNING: Use at your own risk! ]]--

-- Configuration
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local TRANSPARENCY = 1
local notifications = false
local hitboxesEnabled = true
local espEnabled = true
local aimbotEnabled = true  -- Enabled by default

-- Notification helper
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
        })
    end)
end

notify("Script", "Loading...", 5)

-- Load ESP library
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

-- Listener config for enemy models
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

-- Applies hitboxes around model
local function applyHitbox(model)
    if not hitboxesEnabled then return end
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

-- Initial hitboxes for existing enemies
task.wait(1)
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        applyHitbox(model)
    end
end

-- Handle new enemy spawns
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(1)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        applyHitbox(descendant)
        if notifications then
            notify("Warning", "New enemy spawned!", 3)
        end
    end
end)

-- Aimbot Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local circleRadius = 150

-- Find closest enemy HumanoidRootPart within circle radius from mouse
local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDist = circleRadius
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist <= shortestDist then
                        shortestDist = dist
                        closestEnemy = rootPart
                    end
                end
            end
        end
    end
    return closestEnemy
end

-- Smooth aiming toward target
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local targetRoot = getClosestEnemy()
        if targetRoot then
            local camPos = camera.CFrame.Position
            local targetPos = targetRoot.Position
            local direction = (targetPos - camPos).Unit
            local newCFrame = CFrame.new(camPos, camPos + direction)
            camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.3)
        end
    end
end)

notify("Loaded", "Aimbot enabled and running.", 5)


