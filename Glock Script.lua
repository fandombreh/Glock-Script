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

-- // UI Sliders
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

-- // Toggle Buttons (For ESP, Aimbot, Camera Lock, FOV Circle)
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 280, 0, 30)
espToggle.Position = UDim2.new(0, 10, 0, 60)
espToggle.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
espToggle.Text = "Toggle ESP"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.Parent = MainFrame

local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Size = UDim2.new(0, 280, 0, 30)
aimbotToggle.Position = UDim2.new(0, 10, 0, 100)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
aimbotToggle.Text = "Toggle Aimbot"
aimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotToggle.Parent = MainFrame

local cameraLockToggle = Instance.new("TextButton")
cameraLockToggle.Size = UDim2.new(0, 280, 0, 30)
cameraLockToggle.Position = UDim2.new(0, 10, 0, 140)
cameraLockToggle.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
cameraLockToggle.Text = "Toggle Camera Lock"
cameraLockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
cameraLockToggle.Parent = MainFrame

local fovCircleToggle = Instance.new("TextButton")
fovCircleToggle.Size = UDim2.new(0, 280, 0, 30)
fovCircleToggle.Position = UDim2.new(0, 10, 0, 180)
fovCircleToggle.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
fovCircleToggle.Text = "Toggle FOV Circle"
fovCircleToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
fovCircleToggle.Parent = MainFrame

-- // Initialize Toggles State
local espEnabled = false
local aimbotEnabled = false
local cameraLockEnabled = false
local fovCircleEnabled = false

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    print("ESP Enabled: ", espEnabled)
end)

aimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    print("Aimbot Enabled: ", aimbotEnabled)
end)

cameraLockToggle.MouseButton1Click:Connect(function()
    cameraLockEnabled = not cameraLockEnabled
    print("Camera Lock Enabled: ", cameraLockEnabled)
end)

fovCircleToggle.MouseButton1Click:Connect(function()
    fovCircleEnabled = not fovCircleEnabled
    print("FOV Circle Enabled: ", fovCircleEnabled)
end)

-- // Sliders for Aimbot Smoothness, Camera Lock Smoothness, and FOV Radius
createSlider("Aimbot Smoothness", 250, 1, 10, 5, function(value)
    aimbotSmoothness = value
end)
createSlider("Camera Lock Smoothness", 300, 1, 10, 5, function(value)
    cameraLockSmoothness = value
end)
createSlider("FOV Radius", 350, 50, 200, 100, function(value)
    fovRadius = value
end)

-- // ESP Function
local function createESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5

    local function update()
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            highlight.Enabled = true
        else
            highlight.Enabled = false
        end
    end

    RunService.RenderStepped:Connect(update)
    
    player.CharacterRemoving:Connect(function()
        highlight:Destroy()
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

-- // Aimbot (Cursor Tracking & Smoothness)
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if onScreen and distance < shortestDistance then
                closestTarget = player
                shortestDistance = distance
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local targetScreenPos, onScreen = Camera:WorldToScreenPoint(targetPos)

            if onScreen then
                local cursorPos = UserInputService:GetMouseLocation()
                local smoothness = aimbotSmoothness / 10
                local targetDirection = (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - cursorPos).unit
                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.LookVector + targetDirection)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
            end
        end
    end
end)
