--[[ WARNING: Use at your own risk! ]]--

local size = Vector3.new(10, 10, 10)
local trans = 1
local notifications = false
local hitboxesEnabled = true
local espEnabled = true

local start = os.clock()

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
esp:Toggle(true)
esp.Boxes = true
esp.Names = false
esp.Tracers = false
esp.Players = false

-- ESP object listener
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

-- Apply hitboxes
local function applyHitbox(model)
    if not hitboxesEnabled then return end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position
    for _, bp in pairs(workspace:GetChildren()) do
        if bp:IsA("BasePart") then
            local dist = (bp.Position - pos).Magnitude
            if dist <= 5 then
                bp.Transparency = trans
                bp.Size = size
            end
        end
    end
end

-- Initial hitbox application
task.wait(1)
for _, model in pairs(workspace:GetDescendants()) do
    if model.Name == "soldier_model" and model:IsA("Model") and not model:FindFirstChild("friendly_marker") then
        applyHitbox(model)
    end
end

-- Detect new enemies
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
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "HitboxScriptGUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 230, 0, 180)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Text = "Hitbox Script Controller"
titleLabel.BorderSizePixel = 0

-- Hitbox Toggle Button
local hitboxToggle = Instance.new("TextButton", mainFrame)
hitboxToggle.Size = UDim2.new(0.8, 0, 0, 35)
hitboxToggle.Position = UDim2.new(0.1, 0, 0, 40)
hitboxToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
hitboxToggle.TextColor3 = Color3.new(1, 1, 1)
hitboxToggle.Font = Enum.Font.SourceSans
hitboxToggle.TextSize = 16
hitboxToggle.Text = "Hitboxes: ON"

hitboxToggle.MouseButton1Click:Connect(function()
    hitboxesEnabled = not hitboxesEnabled
    hitboxToggle.Text = hitboxesEnabled and "Hitboxes: ON" or "Hitboxes: OFF"

    if not hitboxesEnabled then
        for _, bp in pairs(workspace:GetChildren()) do
            if bp:IsA("BasePart") and bp.Transparency == trans and bp.Size == size then
                bp.Transparency = 0
                bp.Size = Vector3.new(1, 1, 1)
            end
        end
    else
        for _, model in pairs(workspace:GetDescendants()) do
            if model.Name == "soldier_model" and model:IsA("Model") and not model:FindFirstChild("friendly_marker") then
                applyHitbox(model)
            end
        end
    end
end)

-- Notifications Toggle
local notifToggle = Instance.new("TextButton", mainFrame)
notifToggle.Size = UDim2.new(0.8, 0, 0, 35)
notifToggle.Position = UDim2.new(0.1, 0, 0, 80)
notifToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
notifToggle.TextColor3 = Color3.new(1, 1, 1)
notifToggle.Font = Enum.Font.SourceSans
notifToggle.TextSize = 16
notifToggle.Text = "Notifications: OFF"

notifToggle.MouseButton1Click:Connect(function()
    notifications = not notifications
    notifToggle.Text = notifications and "Notifications: ON" or "Notifications: OFF"
end)

-- ESP Toggle
local espToggle = Instance.new("TextButton", mainFrame)
espToggle.Size = UDim2.new(0.8, 0, 0, 35)
espToggle.Position = UDim2.new(0.1, 0, 0, 120)
espToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Font = Enum.Font.SourceSans
espToggle.TextSize = 16
espToggle.Text = "ESP: ON"

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    esp:Toggle(espEnabled)
    espToggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
end)

-- Final load message
local finish = os.clock()
local elapsed = finish - start
local rating = (elapsed < 3) and "fast" or (elapsed < 5) and "acceptable" or "slow"
notify("Script", string.format("Loaded in %.2f seconds (%s)", elapsed, rating), 5)
