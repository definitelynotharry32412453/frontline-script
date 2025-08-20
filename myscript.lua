--[[ WARNING: Use at your own risk! ]]--

-- Configuration
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local TRANSPARENCY = 1
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

-- GUI Setup
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ScriptControlGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = " Script Controls "
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.BorderSizePixel = 0

-- Unified button creation
local function createButton(text, yPos, onClick)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Toggle Hitboxes
local hitboxBtn = createButton("Hitboxes: ON", 40, function()
    hitboxesEnabled = not hitboxesEnabled
    hitboxBtn.Text = hitboxesEnabled and "Hitboxes: ON" or "Hitboxes: OFF"
    notify("Toggle", "Hitboxes " .. (hitboxesEnabled and "enabled" or "disabled"), 3)
end)

-- Toggle Notifications
local notifBtn = createButton("Notifications: OFF", 80, function()
    notifications = not notifications
    notifBtn.Text = notifications and "Notifications: ON" or "Notifications: OFF"
    notify("Toggle", "Notifications " .. (notifications and "enabled" or "disabled"), 3)
end)

-- Toggle ESP
local espBtn = createButton("ESP: ON", 120, function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"

    if espEnabled then
        esp.enemy = true
        esp:Toggle(true)
        notify("Toggle", "ESP enabled", 3)
    else
        esp.enemy = false
        esp:Toggle(false)
        notify("Toggle", "ESP disabled", 3)
    end
end)

-- Final Load Notification
local loadTime = os.clock()
notify("Loaded", string.format("Loaded in %.2f seconds", loadTime), 5)

