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
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
frame.Parent = gui

-- Create the Text Label for Title
local title = Instance.new("TextLabel")
title.Text = "Glock - made by snoopy"
title.Size = UDim2.new(1, 0, 0, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = frame

-- Create Smoothness Slider
local smoothnessSlider = Instance.new("TextBox")
smoothnessSlider.Text = "Smoothness"
smoothnessSlider.Size = UDim2.new(0.8, 0, 0, 30)
smoothnessSlider.Position = UDim2.new(0.1, 0, 0.2, 0)
smoothnessSlider.BackgroundTransparency = 0.7
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
smoothnessSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
smoothnessSlider.Parent = frame

-- Add functions to change UI color
local function changeUIColors()
    local color = Color3.fromRGB(0, 255, 255) -- Default teal color
    if colors[currentColor] == "Teal" then
        color = Color3.fromRGB(0, 255, 255)
    elseif colors[currentColor] == "Purple" then
        color = Color3.fromRGB(128, 0, 128)
    elseif colors[currentColor] == "Blue" then
        color = Color3.fromRGB(0, 0, 255)
    end
    frame.BackgroundColor3 = color
end

-- Switch colors every 3 seconds
while true do
    wait(3)
    currentColor = currentColor + 1
    if currentColor > #colors then
        currentColor = 1
    end
    changeUIColors()
end

-- Aimbot and Camera Lock Functions
local cameraLock = false
local aimbotEnabled = false
local smoothness = 0.2 -- Default smoothness for aimbot and camera lock

-- Get the closest enemy
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

-- Aimbot logic
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

-- Camera Lock logic
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

-- Silent Aim logic
local function silentAim()
    if aimbotEnabled then
        local enemy = getClosestEnemy()
        if enemy then
            -- Calculate angle and fire the weapon (you need to implement firing logic for your specific game)
            print("Silent Aim activated towards: " .. enemy.Name)
        end
    end
end

-- ESP (Extrasensory Perception) logic
local function createESP(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local espPart = Instance.new("Part")
        espPart.Size = Vector3.new(3, 5, 3)
        espPart.Position = target.Character.HumanoidRootPart.Position
        espPart.Anchored = true
        espPart.CanCollide = false
        espPart.Transparency = 0.5
        espPart.BrickColor = BrickColor.new("Bright red")
        espPart.Parent = game.Workspace
        game:GetService("Debris"):AddItem(espPart, 5) -- Clean up the ESP after 5 seconds
    end
end

local function showESP()
    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            createESP(target)
        end
    end
end

-- FOV Circle
local fovRadius = 50
local fovCircle = Instance.new("Frame")
fovCircle.Visible = false
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
fovCircle.BackgroundTransparency = 0.5
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fovCircle.Parent = gui

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end

-- Adjust FOV radius dynamically (bind this to Smoothness Slider)
smoothnessSlider.FocusLost:Connect(function()
    fovRadius = tonumber(smoothnessSlider.Text) or fovRadius
    updateFOVCircle()
end)

-- Button to toggle Aimbot and Camera Lock
local aimbotButton = Instance.new("TextButton")
aimbotButton.Text = "Toggle Aimbot / Camera Lock"
aimbotButton.Size = UDim2.new(0.8, 0, 0, 30)
aimbotButton.Position = UDim2.new(0.1, 0, 0.4, 0)
aimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
aimbotButton.Parent = frame
aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    cameraLock = not cameraLock
end)

-- Button to toggle Silent Aim
local silentAimButton = Instance.new("TextButton")
silentAimButton.Text = "Toggle Silent Aim"
silentAimButton.Size = UDim2.new(0.8, 0, 0, 30)
silentAimButton.Position = UDim2.new(0.1, 0, 0.6, 0)
silentAimButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
silentAimButton.TextColor3 = Color3.fromRGB(0, 0, 0)
silentAimButton.Parent = frame
silentAimButton.MouseButton1Click:Connect(function()
    silentAim = not silentAim
end)

-- Button to toggle ESP
local espButton = Instance.new("TextButton")
espButton.Text = "Toggle ESP"
espButton.Size = UDim2.new(0.8, 0, 0, 30)
espButton.Position = UDim2.new(0.1, 0, 0.8, 0)
espButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextColor3 = Color3.fromRGB(0, 0, 0)
espButton.Parent = frame
espButton.MouseButton1Click:Connect(function()
    showESP()
end)

-- Button to toggle FOV Circle
local fovCircleButton = Instance.new("TextButton")
fovCircleButton.Text = "Toggle FOV Circle"
fovCircleButton.Size = UDim2.new(0.8, 0, 0, 30)
fovCircleButton.Position = UDim2.new(0.1, 0, 1, 0)
fovCircleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
fovCircleButton.Parent = frame
fovCircleButton.MouseButton1Click:Connect(function()
    fovCircle.Visible = not fovCircle.Visible
end)

-- Call functions to activate features
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        aimbot()
    end
    if cameraLock then
        cameraLockFunction()
    end
    if silentAim then
        silentAim()
    end
end)
