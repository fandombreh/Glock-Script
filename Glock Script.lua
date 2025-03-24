local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

-- Create a Screen GUI for cheats
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

-- Create a Frame for the cheat buttons
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.7, 0)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.Parent = screenGui

-- Function to create buttons in the cheat menu
local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.05, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = frame
    button.MouseButton1Click:Connect(callback)
    return button
end

-------------------------------
-- Aim Cheats Section
-------------------------------

-- Aim Lock: Locks onto the nearest player
local aimLockEnabled = false

local function aimLock()
    if aimLockEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
    if aimAssistEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
            camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.1) -- Smooth aim assist
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
            -- Simulate mouse click using VirtualUser
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
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer.Character:FindFirstChild("Humanoid") then
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

-------------------------------
-- Distance ESP Section
-------------------------------

local distanceESPEnabled = false
local distanceESPConnections = {}

local function toggleDistanceESP()
    if distanceESPEnabled then
        for _, conn in pairs(distanceESPConnections) do
            conn:Disconnect()
        end
        distanceESPConnections = {}

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
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true

                local textLabel = Instance.new("TextLabel", billboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextScaled = true
                textLabel.Text = "Distance"

                local conn = game:GetService("RunService").RenderStepped:Connect(function()
                    if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        textLabel.Text = string.format("Distance: %.1f", distance)
                    end
                end)
                table.insert(distanceESPConnections, conn)
            end
        end
    end
    distanceESPEnabled = not distanceESPEnabled
end

createButton("Toggle Distance ESP", UDim2.new(0.1, 0, 0.3, 0), toggleDistanceESP)

-------------------------------
-- Main Loop
-------------------------------

-- Connect functions to RenderStepped for continuous execution
local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    aimLock()
    aimAssist()
    triggerBot()
end)
