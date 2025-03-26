local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

-- Create a Screen GUI for cheats
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

-- Create a Frame for the cheat buttons (Synapse X-like)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.7, 0)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)  -- Dark background
frame.BackgroundTransparency = 0.8
frame.BorderSizePixel = 0
frame.RoundedCornerRadius = UDim.new(0, 10)  -- Rounded corners
frame.Parent = screenGui

-- Title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = "Synapse X Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextStrokeTransparency = 0.8
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = frame

-- Draggable UI setup
local dragging = false
local dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragInput = input
        mousePos = Vector2.new(input.Position.X, input.Position.Y)
        framePos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X - mousePos.X, input.Position.Y - mousePos.Y)
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Function to create buttons in the cheat menu
local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.05, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Darker button
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = frame

    -- Hover effect for the button
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  -- Lighter on hover
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Back to dark on leave
    end)

    button.MouseButton1Click:Connect(callback)
    return button
end

-------------------------------
-- Aim Cheats Section
-------------------------------

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

createButton("Toggle Aim Lock", UDim2.new(0.1, 0, 0.15, 0), function()
    aimLockEnabled = not aimLockEnabled
end)

-------------------------------
-- Aim Assist Section
-------------------------------

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

createButton("Toggle Aim Assist", UDim2.new(0.1, 0, 0.2, 0), function()
    aimAssistEnabled = not aimAssistEnabled
end)

-------------------------------
-- Trigger Bot Section
-------------------------------

local triggerBotEnabled = false

local function triggerBot()
    if triggerBotEnabled then
        local target = mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
            -- Simulate mouse click using VirtualUser
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end
end

createButton("Toggle Trigger Bot", UDim2.new(0.1, 0, 0.25, 0), function()
    triggerBotEnabled = not triggerBotEnabled
end)

-------------------------------
-- ESP Cheats Section
-------------------------------

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

createButton("Toggle ESP", UDim2.new(0.1, 0, 0.3, 0), toggleESP)

-------------------------------
-- Health ESP Section
-------------------------------

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

createButton("Toggle Health ESP", UDim2.new(0.1, 0, 0.35, 0), toggleHealthESP)

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
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true

                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 0.2, 0)
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextSize = 14
                label.BackgroundTransparency = 1
                label.TextStrokeTransparency = 0.8
                label.Text = ""

                -- Update distance in real-time
                distanceESPConnections[otherPlayer] = otherPlayer.Character.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                    local distance = (otherPlayer.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude
                    label.Text = string.format("Distance: %.2f", distance)
                end)
            end
        end
    end
    distanceESPEnabled = not distanceESPEnabled
end

createButton("Toggle Distance ESP", UDim2.new(0.1, 0, 0.4, 0), toggleDistanceESP)

-------------------------------
-- Main Loop
-------------------------------

local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    aimLock()
    aimAssist()
    triggerBot()
end)
