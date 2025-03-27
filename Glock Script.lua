-- Initialize GUI
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui")
gui.Name = "Glock - made by snoopy"
gui.Parent = player:WaitForChild("PlayerGui")

-- Colors
local colors = {"Teal", "Purple", "Blue"}
local currentColor = 1

-- Create the UI frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)  -- Increased size for all elements
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
frame.Parent = gui

-- Create the Title label
local title = Instance.new("TextLabel")
title.Text = "Glock - made by snoopy"
title.Size = UDim2.new(1, 0, 0, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.TextSize = 24
title.Parent = frame

-- Create the Smoothness Slider
local smoothnessSlider = Instance.new("TextBox")
smoothnessSlider.Text = "Smoothness"
smoothnessSlider.Size = UDim2.new(0.8, 0, 0, 30)
smoothnessSlider.Position = UDim2.new(0.1, 0, 0.2, 0)
smoothnessSlider.BackgroundTransparency = 0.7
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
smoothnessSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
smoothnessSlider.TextSize = 20
smoothnessSlider.Parent = frame

-- Create Buttons for Features
local aimbotButton = Instance.new("TextButton")
aimbotButton.Text = "Toggle Aimbot / Camera Lock"
aimbotButton.Size = UDim2.new(0.8, 0, 0, 30)
aimbotButton.Position = UDim2.new(0.1, 0, 0.3, 0)
aimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
aimbotButton.TextSize = 18
aimbotButton.Parent = frame

local silentAimButton = Instance.new("TextButton")
silentAimButton.Text = "Toggle Silent Aim"
silentAimButton.Size = UDim2.new(0.8, 0, 0, 30)
silentAimButton.Position = UDim2.new(0.1, 0, 0.4, 0)
silentAimButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
silentAimButton.TextColor3 = Color3.fromRGB(0, 0, 0)
silentAimButton.TextSize = 18
silentAimButton.Parent = frame

local espButton = Instance.new("TextButton")
espButton.Text = "Toggle ESP"
espButton.Size = UDim2.new(0.8, 0, 0, 30)
espButton.Position = UDim2.new(0.1, 0, 0.5, 0)
espButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextColor3 = Color3.fromRGB(0, 0, 0)
espButton.TextSize = 18
espButton.Parent = frame

local fovCircleButton = Instance.new("TextButton")
fovCircleButton.Text = "Toggle FOV Circle"
fovCircleButton.Size = UDim2.new(0.8, 0, 0, 30)
fovCircleButton.Position = UDim2.new(0.1, 0, 0.6, 0)
fovCircleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
fovCircleButton.TextSize = 18
fovCircleButton.Parent = frame

-- Function to make the UI draggable
local dragging = false
local dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Button Functions
local aimbotEnabled = false
local cameraLock = false
local silentAim = false
local fovRadius = 50
local smoothness = 0.2

-- Toggle Aimbot / Camera Lock
aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    cameraLock = not cameraLock
    print("Aimbot/Camera Lock: " .. (aimbotEnabled and "Enabled" or "Disabled"))
end)

-- Toggle Silent Aim
silentAimButton.MouseButton1Click:Connect(function()
    silentAim = not silentAim
    print("Silent Aim: " .. (silentAim and "Enabled" or "Disabled"))
end)

-- Toggle ESP
espButton.MouseButton1Click:Connect(function()
    -- Implement your ESP logic here
    print("ESP toggled")
end)

-- Toggle FOV Circle
fovCircleButton.MouseButton1Click:Connect(function()
    -- Implement your FOV circle logic here
    print("FOV Circle toggled")
end)

-- Smoothness Slider Update
smoothnessSlider.FocusLost:Connect(function()
    smoothness = tonumber(smoothnessSlider.Text) or smoothness
    print("Smoothness set to: " .. smoothness)
end)

-- Aimbot, Camera Lock, Silent Aim Logic (simplified)
local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (target.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestEnemy = target
            end
        end
    end
    return closestEnemy
end

local function aimbot()
    if aimbotEnabled then
        local enemy = getClosestEnemy()
        if enemy then
            local targetPosition = enemy.Character.HumanoidRootPart.Position
            -- Aim at the target (using Tweening for smooth movement)
            local camera = game.Workspace.CurrentCamera
            local targetCFrame = CFrame.new(targetPosition)
            game:GetService("TweenService"):Create(camera, TweenInfo.new(smoothness), {CFrame = targetCFrame}):Play()
        end
    end
end

local function cameraLockFunction()
    if cameraLock then
        local enemy = getClosestEnemy()
        if enemy then
            local targetPosition = enemy.Character.HumanoidRootPart.Position
            -- Lock the camera on the target (using Tweening for smooth movement)
            local camera = game.Workspace.CurrentCamera
            local targetCFrame = CFrame.new(targetPosition)
            game:GetService("TweenService"):Create(camera, TweenInfo.new(smoothness), {CFrame = targetCFrame}):Play()
        end
    end
end

local function silentAimFunction()
    if silentAim then
        local enemy = getClosestEnemy()
        if enemy then
            -- Calculate angle and fire the weapon (you need to implement firing logic for your specific game)
            print("Silent Aim activated towards: " .. enemy.Name)
        end
    end
end

-- Run the functions
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        aimbot()
    end
    if cameraLock then
        cameraLockFunction()
    end
    if silentAim then
        silentAimFunction()
    end
end)
