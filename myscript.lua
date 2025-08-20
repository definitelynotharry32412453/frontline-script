--[[ WARNING: Use at your own risk! ]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local BOX_SIZE = Vector3.new(3, 5, 3)  -- smaller box, adjust as needed
local BOX_COLOR = Color3.fromRGB(255, 0, 0)
local BOX_TRANSPARENCY = 0.6  -- more transparent

local espBoxes = {}

local function create3DBox(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Create BoxHandleAdornment
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Adornee = root
    box.AlwaysOnTop = true -- renders on top, so visible through walls
    box.ZIndex = 10
    box.Size = BOX_SIZE
    box.Color3 = BOX_COLOR
    box.Transparency = BOX_TRANSPARENCY
    box.Visible = true
    box.Parent = root

    espBoxes[model] = box
end

local function remove3DBox(model)
    local box = espBoxes[model]
    if box then
        box:Destroy()
        espBoxes[model] = nil
    end
end

-- Add boxes for current enemies
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        create3DBox(model)
    end
end

-- Listen for new enemies spawning
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        create3DBox(descendant)
    end
end)

-- Remove box when enemy despawns
workspace.DescendantRemoving:Connect(function(descendant)
    if espBoxes[descendant] then
        remove3DBox(descendant)
    end
end)
