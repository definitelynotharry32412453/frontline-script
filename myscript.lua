--// Configurable Settings
local HITBOX_SIZE       = Vector3.new(10, 10, 10)
local TRANSPARENCY      = 1
local HITBOX_RADIUS     = 5
local ENABLE_NOTIFICATIONS = false
local ENEMY_NAME        = "soldier_model"
local FRIENDLY_TAG      = "friendly_marker"

local startTime = os.clock()

--// Safe Notification
local function notify(title, message, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 5
        })
    end)
end

notify("Script", "Loading...", 5)

--// Load ESP Library
local success, esp = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/andrewc0de/Roblox/main/Dependencies/ESP.lua"))()
end)

if not success or not esp then
    notify("Error", "Failed to load ESP library.", 5)
    return
end

--// ESP Configuration
esp:Toggle(true)
esp.Boxes   = true
esp.Names   = false
esp.Tracers = false
esp.Players = false

--// Add Listener for Enemy Models
esp:AddObjectListener(workspace, {
    Name        = ENEMY_NAME,
    Type        = "Model",
    Color       = Color3.fromRGB(255, 0, 4),
    PrimaryPart = function(model)
        local root
        repeat
            root = model:FindFirstChild("HumanoidRootPart")
            task.wait()
        until root
        return root
    end,
    Validator   = function(model)
        task.wait(1)
        return not model:FindFirstChild(FRIENDLY_TAG)
    end,
    CustomName  = "?",
    IsEnabled   = "enemy"
})
esp.enemy = true

--// Hitbox Application Logic
local function applyHitbox(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position

    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and (part.Position - pos).Magnitude <= HITBOX_RADIUS then
            part.Transparency = TRANSPARENCY
            part.Size         = HITBOX_SIZE
        end
    end
end

--// Apply Hitboxes to Existing Enemies
task.wait(1)
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == ENEMY_NAME and not model:FindFirstChild(FRIENDLY_TAG) then
        applyHitbox(model)
    end
end

--// Handle Newly Spawned Enemies
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(1)
    if descendant:IsA("Model") and descendant.Name == ENEMY_NAME and not descendant:FindFirstChild(FRIENDLY_TAG) then
        applyHitbox(descendant)
        if ENABLE_NOTIFICATIONS then
            notify("Script", "[Warning] New Enemy Spawned! Hitbox Applied.", 3)
        end
    end
end)

--// Final Notification with Load Time
local elapsed = os.clock() - startTime
local rating = (elapsed < 3) and "fast" or (elapsed < 5) and "acceptable" or "slow"
notify("Script", string.format("Loaded in %.2f seconds — %s.", elapsed, rating), 5)

