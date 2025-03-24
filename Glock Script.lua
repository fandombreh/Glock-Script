-- Setup GUI for Cheats
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

-- Create a Screen GUI for cheats
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "CheatMenu"

-- Create a Frame for the cheat buttons
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0.3, 0, 0.7, 0)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.Visible = true

-- Sample Button Template
local function createButton(name, position, callback)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.8, 0, 0.05, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.MouseButton1Click:Connect(callback)
    return button
end

-------------------------------
-- Aim Cheats Section
-------------------------------

-- Aim Lock: Locks onto the nearest player
local aimLockEnabled = false

local function aimLock()
    if aimLockEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end

        if closestPlayer and closestPlayer.Character then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
        end
    end
end

createButton("Toggle Aim Lock", UDim2.new(0.1, 0, 0.05, 0), function()
    aimLockEnabled = not aimLockEnabled
end)

-- Aim Assist: Gradually moves aim towards nearest player
local aimAssistEnabled = false

local function aimAssist()
    if aimAssistEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end

        if closestPlayer and closestPlayer.Character then
            local aimPosition = closestPlayer.Character.HumanoidRootPart.Position
            local newCFrame = CFrame.new(camera.CFrame.Position, aimPosition)
            camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.1) -- Lerp for smooth aim assist
        end
    end
end

createButton("Toggle Aim Assist", UDim2.new(0.1, 0, 0.1, 0), function()
    aimAssistEnabled = not aimAssistEnabled
end)

-- Trigger Bot: Automatically shoots when aiming at an enemy
local triggerBotEnabled = false

local function triggerBot()
    if triggerBotEnabled then
        local target = mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent:FindFirstChild("Humanoid").Health > 0 then
            -- Simulate mouse click
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end
end

createButton("Toggle Trigger Bot", UDim2.new(0.1, 0, 0.15, 0), function()
    triggerBotEnabled = not triggerBotEnabled
end)

-------------------------------
-- ESP Cheats Section
-------------------------------
-- ESP: Show player outlines
local espEnabled = false

local function toggleESP()
    if espEnabled then
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = otherPlayer.Character:FindFirstChild("Highlight")
                if highlight then
                    highlight:Destroy()  -- Disable ESP
                end
            end
        end
    else
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight", otherPlayer.Character)
                highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Red outline
                highlight.OutlineTransparency = 0.5
            end
        end
    end
    espEnabled = not espEnabled
end

createButton("Toggle ESP", UDim2.new(0.1, 0, 0.2, 0), toggleESP)

-- ESP: Show health bars
local healthESPEnabled = false

local function toggleHealthESP()
    if healthESPEnabled then
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local billboard = otherPlayer.Character:FindFirstChild("HealthBillboard")
                if billboard then
                    billboard:Destroy()  -- Disable Health ESP
                end
            end
        end
    else
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local billboard = Instance.new("BillboardGui", otherPlayer.Character.HumanoidRootPart)
                billboard.Name = "HealthBillboard"
                billboard.Size = UDim2.new(4, 0, 1, 0)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true

                local bar = Instance.new("Frame", billboard)
                bar.Size = UDim2.new(1, 0, 0.2, 0)
                bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

                -- Update health in real-time
                otherPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    local healthPercent = otherPlayer.Character.Humanoid.Health / otherPlayer.Character.Humanoid.MaxHealth
                    bar.Size = UDim2.new(healthPercent, 0, 0.2, 0)
                    bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                end)
            end
        end
    end
    healthESPEnabled = not healthESPEnabled
end

createButton("Toggle Health ESP", UDim2.new(0.1, 0, 0.25, 0), toggleHealthESP)

-- ESP: Distance ESP
local distanceESPEnabled = false

local function toggleDistanceESP()
    if distanceESPEnabled then
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local billboard = otherPlayer.Character:FindFirstChild("DistanceBillboard")
                if billboard then
                    billboard:Destroy()  -- Disable Distance ESP
                end
            end
        end
    else
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local billboard = Instance.new("BillboardGui", otherPlayer.Character.HumanoidRootPart)
                billboard.Name = "DistanceBillboard"
                billboard.Size = UDim2.new(4, 0, 1, 0)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true

                local textLabel = Instance.new("TextLabel", billboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "Distance: 0"

                -- Update distance in real-time
                game:GetService("RunService").Stepped:Connect(function()
                    local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    textLabel.Text = "Distance: " .. math.floor(distance)
                end)
            end
        end
    end
    distanceESPEnabled = not distanceESPEnabled
end

createButton("Toggle Distance ESP", UDim2.new(0.1, 0, 0.3, 0), toggleDistanceESP)

-------------------------------
-- Movement Cheats Section
-------------------------------

-- Speed Boost: Increase player walk speed
local speedBoostEnabled = false

local function toggleSpeedBoost()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        if speedBoostEnabled then
            humanoid.WalkSpeed = 16  -- Default speed
        else
            humanoid.WalkSpeed = 50  -- Boosted speed
        end
        speedBoostEnabled = not speedBoostEnabled
    end
end

createButton("Toggle Speed Boost", UDim2.new(0.1, 0, 0.35, 0), toggleSpeedBoost)

-- Teleport to mouse click
local teleportEnabled = false

local function toggleTeleport()
    if teleportEnabled then
        mouse.Button1Down:Connect(function()
            if mouse.Target then
                player.Character:MoveTo(mouse.Hit.p)
            end
        end)
    end
    teleportEnabled = not teleportEnabled
end

createButton("Toggle Teleport", UDim2.new(0.1, 0, 0.4, 0), toggleTeleport)

-------------------------------
-- Utility Cheats Section
-------------------------------

-- God Mode: Infinite health
local godModeEnabled = false

local function toggleGodMode()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if godModeEnabled then
            player.Character.Humanoid.MaxHealth = 100
            player.Character.Humanoid.Health = 100
        else
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
        end
        godModeEnabled = not godModeEnabled
    end
end

createButton("Toggle God Mode", UDim2.new(0.1, 0, 0.45, 0), toggleGodMode)

-- Infinite Stamina: No stamina drain
local staminaEnabled = false

local function toggleInfiniteStamina()
    -- Assume a Stamina property exists in the game
    if player.Character and player.Character:FindFirstChild("Stamina") then
        if staminaEnabled then
            player.Character.Stamina.Value = 100  -- Default stamina
        else
            player.Character.Stamina.Value = math.huge
        end
        staminaEnabled = not staminaEnabled
    end
end

createButton("Toggle Infinite Stamina", UDim2.new(0.1, 0, 0.5, 0), toggleInfiniteStamina)

-------------------------------
-- Additional Placeholder Features
-------------------------------

for i = 1, 5 do
    createButton("Feature " .. tostring(i + 15), UDim2.new(0.1, 0, 0.5 + (i * 0.05), 0), function()
        print("Feature " .. tostring(i + 15) .. " activated!")
    end)
end
