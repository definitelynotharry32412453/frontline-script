--[[ WARNING: Use at your own risk! ]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local workspace = game:GetService("Workspace")

-- Notify script loaded
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ESP Script",
        Text = "3D ESP loaded successfully!",
        Duration = 5
    })
end)

-- Config
local BOX_COLOR = Color3.fromRGB(255, 0, 0)
local BOX_TRANSPARENCY = 0.6

-- Table to store esp boxes per model
local espBoxes = {}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

local function create3DBox(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- If box already exists, don't recreate
    if espBoxes[model] then return end

    -- Get model size accurately using GetBoundingBox
    local cframe, size = model:GetBoundingBox()

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Adornee = root
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = size * Vector3.new(1, 1, 1) -- keep actual model size
    box.Transparency = BOX_TRANSPARENCY
    box.Color3 = BOX_COLOR
    box.Visible = true
    box.Parent = root

    espBoxes[model] = box

    -- Notify about new enemy ESP
    notify("ESP", "New enemy detected and highlighted!", 4)
end

local function remove3DBox(model)
    local box = espBoxes[model]
    if box then
        box:Destroy()
        espBoxes[model] = nil
    end
end

-- Add boxes for existing enemies
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        create3DBox(model)
    end
end

-- Listen for new enemy spawn
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        create3DBox(descendant)
    end
end)

-- Remove boxes when enemy despawns
workspace.DescendantRemoving:Connect(function(descendant)
    if espBoxes[descendant] then
        remove3DBox(descendant)
    end
end)

