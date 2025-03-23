local camera = game.Workspace.CurrentCamera -- Get the current camera
local player = game.Players.LocalPlayer

local frame = script.Parent.Frame -- Reference the frame
local triggerbotButton = frame.TriggerbotButton -- Button to toggle triggerbot
local cameraLockButton = frame.CameraLockButton -- Button to toggle camera lock
local smoothnessBox = frame.SmoothnessBox -- TextBox for adjusting smoothness

local lockOnEnemy = nil -- Variable to store the current locked-on enemy
local cameraLock = false -- Camera lock toggle state
local triggerbotEnabled = false -- Triggerbot toggle state
local smoothSpeed = 0.2 -- Default smoothness value

-- Function to find the closest enemy
local function findClosestEnemy()
    local closestEnemy = nil
    local closestDistance = 50 -- Range within which the camera locks onto the enemy

    for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).magnitude
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
        local enemyPosition = enemy.HumanoidRootPart.Position
        local cameraPosition = camera.CFrame.Position
        local lookAt = CFrame.new(cameraPosition, enemyPosition) -- Point the camera towards the enemy
        camera.CFrame = camera.CFrame:Lerp(lookAt, smoothSpeed) -- Smoothly interpolate the camera position
    end
end

-- Main camera lock loop
game:GetService("RunService").RenderStepped:Connect(function()
    if cameraLock then
        if not lockOnEnemy then
            lockOnEnemy = findClosestEnemy() -- Find the closest enemy to lock onto
        end

        if lockOnEnemy then
            if lockOnEnemy:FindFirstChild("HumanoidRootPart") then
                trackEnemy(lockOnEnemy)
            else
                lockOnEnemy = nil
            end
        end
    end
end)

-- Triggerbot functionality (Fires when target is in view)
local function triggerbot()
    if triggerbotEnabled then
        local target = findClosestEnemy()
        if target and (player.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).magnitude < 50 then
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:TakeDamage(10) -- Fire at the enemy, or perform desired action
            end
        end
    end
end

-- Camera Lock Button
cameraLockButton.MouseButton1Click:Connect(function()
    cameraLock = not cameraLock
    if cameraLock then
        cameraLockButton.Text = "Camera Lock: ON"
    else
        cameraLockButton.Text = "Camera Lock: OFF"
    end
end)

-- Triggerbot Button
triggerbotButton.MouseButton1Click:Connect(function()
    triggerbotEnabled = not triggerbotEnabled
    if triggerbotEnabled then
        triggerbotButton.Text = "Triggerbot: ON"
        -- Set up triggerbot loop
        game:GetService("RunService").RenderStepped:Connect(triggerbot)
    else
        triggerbotButton.Text = "Triggerbot: OFF"
    end
end)

-- Smoothness TextBox Update
smoothnessBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = tonumber(smoothnessBox.Text)
        if input and input >= 0 and input <= 1 then
            smoothSpeed = input -- Update the smoothness value
        else
            smoothnessBox.Text = "Invalid"
        end
    end
end)
