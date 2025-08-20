--[[ WARNING: Use at your own risk! ]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Configuration
local AIM_RADIUS = 150 -- pixels radius around mouse to detect enemy
local AUTO_SHOOT = true -- auto left click when target found

-- Find closest enemy HumanoidRootPart within AIM_RADIUS pixels of mouse
local function getClosestEnemy()
    local closestTarget = nil
    local shortestDistance = AIM_RADIUS

    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "soldier_model" and not model:FindFirstChild("friendly_marker") then
            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestTarget = root
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Main loop
RunService.RenderStepped:Connect(function()
    local target = getClosestEnemy()
    if target then
        local camPos = camera.CFrame.Position
        local direction = (target.Position - camPos).Unit
        camera.CFrame = CFrame.new(camPos, camPos + direction)

        if AUTO_SHOOT then
            -- Simulate left mouse click (requires exploit support)
            if mouse1press then
                mouse1press()
                wait(0.05)
                mouse1release()
            end
        end
    end
end)



