-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Glock.lol"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Parent = frame

-- Smooth Drag Function
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

-- Camera Lock Function
local camera = game.Workspace.CurrentCamera
local lockCamera = false

local function toggleCameraLock()
    lockCamera = not lockCamera
    if lockCamera then
        camera.CameraType = Enum.CameraType.Scriptable
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- Trigger Bot Function
local triggerBot = false
local function toggleTriggerBot()
    triggerBot = not triggerBot
end

local function onUpdate()
    if triggerBot then
        local target = nil
        local closestDistance = math.huge
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Team ~= game.Players.LocalPlayer.Team then
                local distance = (camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    target = player.Character.HumanoidRootPart
                end
            end
        end
        if target then
            -- Logic to shoot at the target
            -- This is where you'd implement the actual trigger bot mechanics (aiming and shooting)
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(onUpdate)

-- FOV Circle Function
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, 200, 0, 200)
fovCircle.Position = UDim2.new(0.5, -100, 0.5, -100)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fovCircle.BackgroundTransparency = 0.5
fovCircle.BorderSizePixel = 0
fovCircle.Parent = screenGui

-- GUI Buttons for toggling features
local cameraLockButton = Instance.new("TextButton")
cameraLockButton.Text = "Toggle Camera Lock"
cameraLockButton.Size = UDim2.new(1, 0, 0, 40)
cameraLockButton.Position = UDim2.new(0, 0, 0.5, 50)
cameraLockButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
cameraLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
cameraLockButton.Parent = frame

cameraLockButton.MouseButton1Click:Connect(toggleCameraLock)

local triggerBotButton = Instance.new("TextButton")
triggerBotButton.Text = "Toggle Trigger Bot"
triggerBotButton.Size = UDim2.new(1, 0, 0, 40)
triggerBotButton.Position = UDim2.new(0, 0, 0.5, 0)
triggerBotButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
triggerBotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerBotButton.Parent = frame

triggerBotButton.MouseButton1Click:Connect(toggleTriggerBot)
