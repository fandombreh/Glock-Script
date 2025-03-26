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

local espEnabled, aimbotEnabled, cameraLockEnabled, fovCircleEnabled = false, false, false, false

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

-- // Smoothness Sliders
local aimbotSmoothness, cameraLockSmoothness, fovRadius = 5, 5, 100

local function createSlider(text, position, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 280, 0, 40)
    sliderFrame.Position = UDim2.new(0, 10, 0, position)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.Parent = MainFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Text = text .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Parent = sliderFrame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 260, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    slider.Text = ""
    slider.Parent = sliderFrame

    local function updateValue(input)
        local relativePosition = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
        local value = math.clamp(math.floor(relativePosition * (max - min) + min), min, max)
        sliderLabel.Text = text .. ": " .. value
        callback(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateValue(input)
            local moveConnection
            local releaseConnection
            moveConnection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input)
                end
            end)
            releaseConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConnection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
end

createSlider("Aimbot Smoothness", 250, 1, 10, 5, function(value)
    aimbotSmoothness = value
end)

createSlider("Camera Lock Smoothness", 300, 1, 10, 5, function(value)
    cameraLockSmoothness = value
end)

createSlider("FOV Radius", 350, 50, 200, 100, function(value)
    fovRadius = value
end)

-- // Aimbot Functionality (Tracking with Cursor)
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
                local cursorPos = UserInputService:GetMouseLocation()
                local direction = (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - cursorPos).Unit
                local smoothFactor = aimbotSmoothness / 10
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothFactor)
            end
        end
    end
end)

-- // Camera Lock Functionality (Tracks Target without Camera Move)
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), cameraLockSmoothness / 10)
        end
    end
end)

-- // FOV Circle Setup (Around the Cursor)
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius)
fovCircle.Position = UDim2.new(0, 0, 0, 0)  -- Default to top left, will update below
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 0.5

-- Make the frame a circle
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)  -- This makes it a circle
corner.Parent = fovCircle

fovCircle.Visible = false
fovCircle.Parent = ScreenGui

-- Update the position of the FOV circle to follow the cursor
RunService.RenderStepped:Connect(function()
    if fovCircleEnabled then
        local cursorPos = UserInputService:GetMouseLocation()
        fovCircle.Position = UDim2.new(0, cursorPos.X - fovRadius / 2, 0, cursorPos.Y - fovRadius / 2)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)
