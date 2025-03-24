-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Ensure the GUI is visible across all executors
if not screenGui.Parent then
    warn("Unable to attach GUI to PlayerGui. Please check executor permissions.")
    return
end

-- Frame for the GUI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 400)  -- Size of the GUI frame
frame.Position = UDim2.new(0.5, -200, 0.5, -200)  -- Centered
frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)  -- Dark red color for visibility
frame.BackgroundTransparency = 0  -- No transparency
frame.BorderSizePixel = 0  -- No border
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
titleLabel.TextXAlignment = Enum.TextXAlignment.Center -- Fixed property name
titleLabel.Parent = frame

-- Buttons for toggling features
local function createButton(text, positionY)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, positionY, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = frame
    return button
end

local cameraLockButton = createButton("Camera Lock", 0.2)
local triggerBotButton = createButton("Trigger Bot", 0.4)
local espButton = createButton("ESP", 0.6)
local speedHackButton = createButton("Speed Hack", 0.8)

-- Smooth Drag Function for GUI
local dragging, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        update(input)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Features Logic
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

-- ESP
local function toggleESP()
    espEnabled = not espEnabled
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player ~= game.Players.LocalPlayer then
            local billboard = player.Character:FindFirstChild("BillboardGui")
            if espEnabled and not billboard then
                local box = Instance.new("BillboardGui", player.Character)
                box.Size = UDim2.new(0, 100, 0, 50)
                box.StudsOffset = Vector3.new(0, 3, 0)
                box.AlwaysOnTop = true

                local label = Instance.new("TextLabel", box)
                label.Text = player.Name
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.TextSize = 18
                label.TextXAlignment = Enum.TextXAlignment.Center
            elseif not espEnabled and billboard then
                billboard:Destroy()
            end
        end
    end
end

espButton.MouseButton1Click:Connect(toggleESP)

-- Trigger Bot Logic
local function onUpdate()
    if triggerBot then
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player ~= game.Players.LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player.Character.HumanoidRootPart
                end
            end
        end

        if closestPlayer then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Position)
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(onUpdate)
