-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame for the GUI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
frame.BackgroundTransparency = 0.85
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Glock.lol"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.TextStrokeTransparency = 0.8
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.TextAlign = Enum.TextXAlignment.Center
titleLabel.Parent = frame

-- Buttons for toggling features
local cameraLockButton = Instance.new("TextButton")
cameraLockButton.Text = "Camera Lock"
cameraLockButton.Size = UDim2.new(1, 0, 0, 40)
cameraLockButton.Position = UDim2.new(0, 0, 0.2, 0)
cameraLockButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
cameraLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
cameraLockButton.TextSize = 18
cameraLockButton.BorderSizePixel = 0
cameraLockButton.Parent = frame

local triggerBotButton = Instance.new("TextButton")
triggerBotButton.Text = "Trigger Bot"
triggerBotButton.Size = UDim2.new(1, 0, 0, 40)
triggerBotButton.Position = UDim2.new(0, 0, 0.4, 0)
triggerBotButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
triggerBotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerBotButton.TextSize = 18
triggerBotButton.BorderSizePixel = 0
triggerBotButton.Parent = frame

local espButton = Instance.new("TextButton")
espButton.Text = "ESP"
espButton.Size = UDim2.new(1, 0, 0, 40)
espButton.Position = UDim2.new(0, 0, 0.6, 0)
espButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextSize = 18
espButton.BorderSizePixel = 0
espButton.Parent = frame

local speedHackButton = Instance.new("TextButton")
speedHackButton.Text = "Speed Hack"
speedHackButton.Size = UDim2.new(1, 0, 0, 40)
speedHackButton.Position = UDim2.new(0, 0, 0.8, 0)
speedHackButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
speedHackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedHackButton.TextSize = 18
speedHackButton.BorderSizePixel = 0
speedHackButton.Parent = frame

-- Smooth Drag Function for GUI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if dragging == false then
                return
            end
            update(input)
        end)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Features
local camera = game.Workspace.CurrentCamera
local lockCamera = false
local triggerBot = false
local speedHackEnabled = false
local espEnabled = false

-- Camera Lock
local function toggleCameraLock()
    lockCamera = not lockCamera
    if lockCamera then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = camera.CFrame
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end

cameraLockButton.MouseButton1Click:Connect(toggleCameraLock)

-- Trigger Bot
local function toggleTriggerBot()
    triggerBot = not triggerBot
end

triggerBotButton.MouseButton1Click:Connect(toggleTriggerBot)

-- Speed Hack
local function toggleSpeedHack()
    speedHackEnabled = not speedHackEnabled
    if speedHackEnabled then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

speedHackButton.MouseButton1Click:Connect(toggleSpeedHack)

-- ESP (Enemy Wallhack)
local function toggleESP()
    espEnabled = not espEnabled
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player ~= game.Players.LocalPlayer then
            if espEnabled then
                local box = Instance.new("BillboardGui")
                box.Parent = player.Character
                box.Size = UDim2.new(0, 100, 0, 50)
                box.StudsOffset = Vector3.new(0, 3, 0)
                box.AlwaysOnTop = true

                local label = Instance.new("TextLabel")
                label.Text = player.Name
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.TextSize = 18
                label.TextAlign = Enum.TextXAlignment.Center
                label.Parent = box
            else
                if player.Character:FindFirstChild("BillboardGui") then
                    player.Character.BillboardGui:Destroy()
                end
            end
        end
    end
end

espButton.MouseButton1Click:Connect(toggleESP)

-- Trigger Bot Logic (Aimbot + Auto-Shoot)
local function onUpdate()
    if triggerBot then
        local closestPlayer = nil
        local closestDistance = math.huge

        -- Find the closest enemy player
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player ~= game.Players.LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player.Character.HumanoidRootPart
                end
            end
        end

        -- Aim and shoot at closest player
        if closestPlayer then
            -- Aim at closest player (add your shooting mechanism here)
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Position)
            -- Implement auto-shoot logic here
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(onUpdate)
