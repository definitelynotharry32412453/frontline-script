--// Configuration
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local TRANSPARENCY = 1
local ENABLE_NOTIFICATIONS = false
local HITBOX_RADIUS = 5
local ENEMY_NAME = "soldier_model"
local FRIENDLY_TAG = "friendly_marker"
local START_TIME = os.clock()

--// Safe Notification Function
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

notify("Script", "Loading script...")

--// Load ESP Library
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/andrewc0de/Roblox/main/Dependencies/ESP.lua"))()
if not esp then
    notify("Script", "Failed to load ESP library.", 5)
    return
end

--// Configure ESP
esp:Toggle(true)
esp.Boxes = true
esp.Names = false
esp.Tracers = false
esp.Players = false

--// Add ESP Listener for Enemies
esp:AddObjectListener(workspace, {
    Name = ENEMY_NAME,
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
        return not obj:FindFirstChild(FRIENDLY_TAG)
    end,
    CustomName = "?",
    IsEnabled = "enemy"
})
esp.enemy = true

--// Apply Hitbox Function
local function applyHitboxes(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position

    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and (part.Position - pos).Magnitude <= HITBOX_RADIUS then
            part.Transparency = TRANSPARENCY
            part.Size = HITBOX_SIZE
        end
    end
end

--// Initial Hitbox Application
task.wait(1)
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v.Name == ENEMY_NAME and not v:FindFirstChild(FRIENDLY_TAG) then
        applyHitboxes(v)
    end
end

--// On Enemy Spawn
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(1)
    if descendant:IsA("Model") and descendant.Name == ENEMY_NAME and not descendant:FindFirstChild(FRIENDLY_TAG) then
        applyHitboxes(descendant)
        if ENABLE_NOTIFICATIONS then
            notify("Script", "[Warning] New Enemy Spawned! Hitboxes applied.", 3)
        end
    end
end)

--// Final Load Notification
local loadTime = os.clock() - START_TIME
local rating = (loadTime < 3) and "fast" or (loadTime < 5) and "acceptable" or "slow"

notify("Script", string.format("Script loaded in %.2f seconds (%s)", loadTime, rating))

