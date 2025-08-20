--[[ WARNING: Use at your own risk! ]]--

local size = Vector3.new(10, 10, 10)
local trans = 1
local notifications = false
local hitboxesEnabled = true
local espEnabled = true

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

notify("Script", "Loading script...", 5)

-- Load ESP library
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/andrewc0de/Roblox/main/Dependencies/ESP.lua"))()
esp.Boxes = true
esp.Names = false
esp.Tracers = false
esp.Players = false

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

local function applyHitbox(model)
    if not hitboxesEnabled then return end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position
    for _, bp in pairs(workspace:GetChildren()) do
        if bp:IsA("BasePart") and (bp.Position - pos).Magnitude <= 5 then
            bp.Transparency = trans
            bp.Size = size
        end
    end
end

task.wait(1)
for _, model in pairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        applyHitbox(model)
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    task.wait(1)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        applyHitbox(descendant)
        if notifications then
            notify("Script", "[Warning] New Enemy Spawned!", 3)
        end
    end
end)

-- GUI Setup
local player = game:GetService("Players").LocalPlayer
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
screenGui.Name = "ScriptControlGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Text = "Script Controls"

local function createButton(text, yPos, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local hitboxBtn = createButton("Hitboxes: ON", 40, function()
    hitboxesEnabled = not hitboxesEnabled
    hitboxBtn.Text = hitboxesEnabled and "Hitboxes: ON" or "Hitboxes: OFF"
end)

local notifBtn = createButton("Notifications: OFF", 80, function()
    notifications = not notifications
    notifBtn.Text = notifications and "Notifications: ON" or "Notifications: OFF"
end)

local espBtn = createButton("ESP: ON", 120, function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"

    if espEnabled then
        esp.enemy = true
        esp:Toggle(true)
        -- Reapply for current models
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
                esp:AddObjectListener(workspace, {
                    Name = "soldier_model", Type = "Model", Color = Color3.fromRGB(255, 0, 4),
                    PrimaryPart = function(obj)
                        local root
                        repeat root = obj:FindFirstChild("HumanoidRootPart"); task.wait() until root
                        return root
                    end,
                    Validator = function(obj) task.wait(1); return not obj:FindFirstChild("friendly_marker") end,
                    CustomName = "?", IsEnabled = "enemy"
                })
                esp.enemy = true
                esp:Toggle(true)
            end
        end
    else
        esp.enemy = false
        esp:Toggle(false)
        -- Remove visuals for all enemies
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == "soldier_model" then
                pcall(function()
                    esp:Remove(model)
                end)
            end
        end
    end
end)

local loadTime = os.clock()
notify("Script", string.format("Loaded in %.2f seconds", loadTime), 5)

