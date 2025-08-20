--[[ WARNING: Use at your own risk! ]]--

local HITBOX_SIZE = Vector3.new(10, 10, 10)
local TRANSPARENCY = 0.5 -- semi-transparent for 3D boxes
local NOTIFICATIONS = false

local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

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

notify("Script", "Loading 3D Box ESP...", 3)

-- Table to keep track of 3D ESP boxes
local espBoxes = {}

-- Create a 3D box around a model's HumanoidRootPart
local function create3DBox(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Create a transparent part to act as a 3D box
    local box = Instance.new("Part")
    box.Name = "ESP_Box"
    box.Anchored = true
    box.CanCollide = false
    box.Transparency = TRANSPARENCY
    box.Size = HITBOX_SIZE
    box.Material = Enum.Material.Neon
    box.Color = Color3.fromRGB(255, 0, 0)
    box.CFrame = root.CFrame
    box.Parent = workspace

    espBoxes[model] = box

    -- Update box position every frame
    spawn(function()
        while box and box.Parent and model and model.Parent do
            if root and root.Parent then
                box.CFrame = root.CFrame
            else
                break
            end
            task.wait()
        end
        if box then
            box:Destroy()
            espBoxes[model] = nil
        end
    end)
end

-- Remove box when model is removed
local function remove3DBox(model)
    local box = espBoxes[model]
    if box then
        box:Destroy()
        espBoxes[model] = nil
    end
end

-- Initial setup: add boxes for existing enemies
for _, model in ipairs(workspace:GetDescendants()) do
    if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
        create3DBox(model)
    end
end

-- Listen for new enemies spawning
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(1)
    if descendant:IsA("Model") and descendant.Name == "soldier_model" and not descendant:FindFirstChild("friendly_marker") then
        create3DBox(descendant)
        notify("Warning", "New enemy spawned!", 3)
    end
end)

-- Clean up when enemy models are removed
workspace.DescendantRemoving:Connect(function(descendant)
    if espBoxes[descendant] then
        remove3DBox(descendant)
    end
end)

notify("Script", "3D Box ESP Loaded!", 3)


