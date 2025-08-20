--[[ WARNING: Use at your own risk! ]]--

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local workspace = game:GetService("Workspace")

-- Notify script loaded
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ESP Script",
        Text = "Player-style ESP loaded successfully!",
        Duration = 5
    })
end)

-- Configuration
local BOX_COLOR = Color3.fromRGB(255, 0, 0)
local BOX_TRANSPARENCY = 0.6
local PARTS_TO_ESP = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}

-- Table to track ESP adornments per part
local espAdornments = {}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

local function createOutline(part)
    if not part or not part:IsA("BasePart") then return end

    -- Don't create multiple adornments on same part
    if espAdornments[part] then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_PartOutline"
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1) -- slightly bigger for outline effect
    box.Transparency = BOX_TRANSPARENCY
    box.Color3 = BOX_COLOR
    box.Visible = true
    box.Parent = part

    espAdornments[part] = box
end

local function removeOutlinesFromModel(model)
    for part, box in pairs(espAdornments) do
        if part and part:IsDescendantOf(model) then
            box:Destroy()
            espAdornments[part] = nil
        end
    end
end

local function setupModelESP(model)
    for _, partName in ipairs(PARTS_TO_ESP) do
        local part = model:FindFirstChild(partName)
        if part then
            createOutline(part)
        end
    end
end

-- Add ESP to existing enemies
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        setupModelESP(model)
    end
end

-- Listen for new enemy spawns
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        setupModelESP(descendant)
        notify("ESP", "New enemy detected and ESP applied!", 4)
    end
end)

-- Remove ESP when enemy despawns
workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" then
        removeOutlinesFromModel(descendant)
    end
end)

