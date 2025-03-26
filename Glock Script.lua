-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI Setup (Synapse X Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Glock - made by snoopy"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- // Toggle Buttons (For ESP, Aimbot, Camera Lock, FOV Circle)
local function createToggleButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 280, 0, 30)
    button.Position = UDim2.new(0, 10, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

-- // Sliders for Smoothness and Prediction
local function createSlider(label, position, minVal, maxVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, position)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = MainFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, 200, 0, 4)
    slider.Position = UDim2.new(0, 10, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    slider.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 1, 0)
    knob.Position = UDim2.new(0, 0, 0, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = slider

    local value = minVal
    local dragging = false

    local function updateSliderPosition(input)
        local mousePos = input.Position.X - frame.AbsolutePosition.X
        local newPos = math.clamp(mousePos, 0, 200)
        knob.Position = UDim2.new(0, newPos, 0, 0)
        value = minVal + (maxVal - minVal) * (newPos / 200)
        callback(value)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSliderPosition(input)
        end
    end)

    return frame
end

local espEnabled, aimbotEnabled, cameraLockEnabled, fovCircleEnabled = false, false, false, false
local aimbotSmoothness = 0.1
local cameraLockSmoothness = 0.1
local aimbotPrediction = 0
local cameraLockPrediction = 0

createToggleButton("Toggle ESP", 60, function()
    espEnabled = not espEnabled
    print("ESP Enabled:", espEnabled)
end)

createToggleButton("Toggle Aimbot", 100, function()
    aimbotEnabled = not aimbotEnabled
    print("Aimbot Enabled:", aimbotEnabled)
end)

createToggleButton("Toggle Camera Lock", 140, function()
    cameraLockEnabled = not cameraLockEnabled
    print("Camera Lock Enabled:", cameraLockEnabled)
end)

createToggleButton("Toggle FOV Circle", 180, function()
    fovCircleEnabled = not fovCircleEnabled
    print("FOV Circle Enabled:", fovCircleEnabled)
end)

-- // Add Smoothness and Prediction Sliders
createSlider("Aimbot Smoothness", 220, 0, 1, function(value)
    aimbotSmoothness = value
    print("Aimbot Smoothness:", aimbotSmoothness)
end)

createSlider("Camera Lock Smoothness", 260, 0, 1, function(value)
    cameraLockSmoothness = value
    print("Camera Lock Smoothness:", cameraLockSmoothness)
end)

createSlider("Aimbot Prediction", 300, 0, 1, function(value)
    aimbotPrediction = value
    print("Aimbot Prediction:", aimbotPrediction)
end)

createSlider("Camera Lock Prediction", 340, 0, 1, function(value)
    cameraLockPrediction = value
    print("Camera Lock Prediction:", cameraLockPrediction)
end)

-- // Aimbot Functionality (Tracks with Cursor)
local function getClosestTarget()
    local closest, shortestDistance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if onScreen and distance < shortestDistance then
                closest, shortestDistance = player, distance
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local targetScreenPos, onScreen = Camera:WorldToScreenPoint(targetPos)

            if onScreen then
                -- Get the mouse cursor position
                local cursorPos = UserInputService:GetMouseLocation()

                -- Prediction (adjusting for velocity)
                local predictedPos = targetPos + (target.Character.HumanoidRootPart.AssemblyLinearVelocity * aimbotPrediction)

                -- Calculate direction to the target
                local direction = (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - cursorPos).Unit

                -- Adjust the camera's CFrame to move the camera smoothly towards the target (this is still camera-based but for aimbot effect)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predictedPos), aimbotSmoothness)
            end
        end
    end
end)

-- // Camera Lock Functionality (Tracks with Camera)
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position

            -- Prediction for Camera Lock
            local predictedPos = targetPos + (target.Character.HumanoidRootPart.AssemblyLinearVelocity * cameraLockPrediction)

            -- The camera's CFrame will always face the predicted target
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
        end
    end
end)

-- // FOV Circle Setup
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, 200, 0, 200)
fovCircle.Position = UDim2.new(0.5, -100, 0.5, -100)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 0.5
fovCircle.Visible = false
fovCircle.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = fovCircleEnabled
end)
