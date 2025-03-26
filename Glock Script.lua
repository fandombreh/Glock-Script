-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- UI Setup (Informant.wtf Lib Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Title.Text = "Glock - made by snoopy"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextStrokeTransparency = 0.8
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

-- Function to Create Buttons
local function createToggleButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 350, 0, 40)
    button.Position = UDim2.new(0, 25, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 18
    button.TextStrokeTransparency = 0.8
    button.TextXAlignment = Enum.TextXAlignment.Center
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Function to Create Sliders
local function createSlider(text, position, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 350, 0, 40)
    sliderFrame.Position = UDim2.new(0, 25, 0, position)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderFrame.Parent = MainFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Text = text .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 18
    sliderLabel.TextStrokeTransparency = 0.8
    sliderLabel.Parent = sliderFrame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 300, 0, 20)
    slider.Position = UDim2.new(0, 25, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
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

-- Create the Toggle Buttons
local espEnabled, aimbotEnabled, cameraLockEnabled, fovCircleEnabled = false, false, false, false
local blatantMode = false  -- Default to non-blatant mode

createToggleButton("Toggle ESP", 60, function() espEnabled = not espEnabled end)
createToggleButton("Toggle Aimbot", 110, function() aimbotEnabled = not aimbotEnabled end)
createToggleButton("Toggle Camera Lock", 160, function() cameraLockEnabled = not cameraLockEnabled end)
createToggleButton("Toggle FOV Circle", 210, function() fovCircleEnabled = not fovCircleEnabled end)
createToggleButton("Toggle Blatant Mode", 460, function() blatantMode = not blatantMode end)

-- Create the Smoothness Sliders
local aimbotSmoothness, cameraLockSmoothness, fovRadius = 5, 5, 100
createSlider("Aimbot Smoothness", 260, 1, 10, 5, function(value) aimbotSmoothness = value end)
createSlider("Camera Lock Smoothness", 310, 1, 10, 5, function(value) cameraLockSmoothness = value end)
createSlider("FOV Radius", 360, 50, 200, 100, function(value) fovRadius = value end)

-- Aimbot Functionality (Tracking with Cursor)
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

                local smoothFactor
                if blatantMode then
                    smoothFactor = 1  -- Snap to target quickly in blatant mode
                else
                    smoothFactor = aimbotSmoothness / 10  -- Smooth aimbot in non-blatant mode
                end
                
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothFactor)
            end
        end
    end
end)

-- Camera Lock Functionality (Tracks Target without Camera Move)
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position

            local smoothFactor
            if blatantMode then
                smoothFactor = 1  -- Instant camera lock in blatant mode
            else
                smoothFactor = cameraLockSmoothness / 10  -- Smooth camera lock in non-blatant mode
            end

            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothFactor)
        end
    end
end)

-- ESP Functionality (Shows Boxes around Players)
local function createESPBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local box = Instance.new("BillboardGui")
    box.Size = UDim2.new(0, 100, 0, 100)
    box.StudsOffset = Vector3.new(0, 2, 0)
    box.Adornee = player.Character.HumanoidRootPart
    box.AlwaysOnTop = true
    box.Parent = player.Character

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = box
end

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPBox(player)
            end
        end
    end
end)

-- FOV Circle Setup (Around the Cursor)
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius)
fovCircle.Position = UDim2.new(0, 0, 0, 0)  -- Default to top left, will update below
fovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
fovCircle.BackgroundTransparency = 0.5
fovCircle.Visible = false

-- Make the frame a circle
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)  -- This makes it a circle
corner.Parent = fovCircle

fovCircle.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    if fovCircleEnabled then
        local cursorPos = UserInputService:GetMouseLocation()
        fovCircle.Position = UDim2.new(0, cursorPos.X - fovRadius / 2, 0, cursorPos.Y - fovRadius / 2)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)
