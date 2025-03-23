local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Create GUI
local glock = Instance.new("ScreenGui", player.PlayerGui)
local mainFrame = Instance.new("Frame", glock)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local tabs = Instance.new("Frame", mainFrame)
tabs.Size = UDim2.new(1, 0, 0, 30)
tabs.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local cameraLockTab = Instance.new("TextButton", tabs)
cameraLockTab.Size = UDim2.new(0.5, 0, 1, 0)
cameraLockTab.Text = "Camera Lock"

local triggerbotTab = Instance.new("TextButton", tabs)
triggerbotTab.Size = UDim2.new(0.5, 0, 1, 0)
triggerbotTab.Position = UDim2.new(0.5, 0, 0, 0)
triggerbotTab.Text = "Triggerbot"

local lockOnTarget = nil
local cameraLock = false
local triggerbotEnabled = false
local smoothSpeed = 0.2

-- Function to find the closest enemy player
local function findClosestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge
    
    for _, enemy in pairs(game.Players:GetPlayers()) do
        if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - enemy.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestEnemy = enemy
                closestDistance = distance
            end
        end
    end
    
    return closestEnemy
end

-- Function to track the enemy
local function trackEnemy(enemy)
    if enemy then
        local enemyPosition = enemy.Character.HumanoidRootPart.Position
        local cameraPosition = camera.CFrame.Position
        local lookAt = CFrame.new(cameraPosition, enemyPosition)
        camera.CFrame = camera.CFrame:Lerp(lookAt, smoothSpeed)
    end
end

-- Camera Lock Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if cameraLock then
        if not lockOnTarget or not lockOnTarget.Character then
            lockOnTarget = findClosestEnemy()
        end
        if lockOnTarget and lockOnTarget.Character then
            trackEnemy(lockOnTarget)
        end
    end
end)

-- Triggerbot Logic
local function triggerbot()
    if triggerbotEnabled then
        local target = findClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            if mouse.Target and mouse.Target:IsDescendantOf(target.Character) then
                mouse1click()
            end
        end
    end
end
game:GetService("RunService").RenderStepped:Connect(triggerbot)

-- Camera Lock Button
cameraLockTab.MouseButton1Click:Connect(function()
    cameraLock = not cameraLock
    cameraLockTab.Text = cameraLock and "Camera Lock: ON" or "Camera Lock: OFF"
end)

-- Triggerbot Button
triggerbotTab.MouseButton1Click:Connect(function()
    triggerbotEnabled = not triggerbotEnabled
    triggerbotTab.Text = triggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
end)
