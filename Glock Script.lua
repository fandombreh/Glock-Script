local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()

local isFocused = true
local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local camLockSmoothness = 5
local triggerBotRange = 10
local silentAimStrength = 5

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui

-- Function to create sliders
local function createSlider(parent, label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = parent

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 100, 0, 50)
    sliderLabel.Text = label .. ": " .. tostring(default)
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0, 200, 0, 10)
    sliderBar.Position = UDim2.new(0, 100, 0, 20)
    sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
    sliderBar.Parent = frame

    local sliderButton = Instance.new("Frame")
    sliderButton.Size = UDim2.new(0, 10, 0, 20)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -5, 0, 15)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Parent = sliderBar
    sliderButton.Active = true
    sliderButton.Draggable = true

    local function updateSlider(positionX)
        local newValue = math.clamp(math.floor(min + ((positionX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X) * (max - min)), min, max)
        sliderButton.Position = UDim2.new((newValue - min) / (max - min), -5, 0, 15)
        sliderLabel.Text = label .. ": " .. tostring(newValue)
        callback(newValue)
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                updateSlider(UserInputService:GetMouseLocation().X)
            end)

            UserInputService.InputEnded:Connect(function(inputEnd)
                if inputEnd.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- Find Closest Player
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Silent Aim
RunService.RenderStepped:Connect(function()
    if silentAimEnabled and isFocused then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = camera:WorldToViewportPoint(target.Character.Head.Position)
            local moveX, moveY = (headPos.X - Mouse.X) / silentAimStrength, (headPos.Y - Mouse.Y) / silentAimStrength
            
            if mousemoverel then
                mousemoverel(moveX, moveY)
            end
        end
    end
end)

-- Cam Lock
RunService.RenderStepped:Connect(function()
    if camLockEnabled and isFocused then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, headPosition), camLockSmoothness / 10)
        end
    end
end)

-- Trigger Bot
RunService.RenderStepped:Connect(function()
    if triggerBotEnabled and isFocused and localPlayer.Character and localPlayer.Character:FindFirstChild("Head") then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local distance = (localPlayer.Character.Head.Position - target.Character.Head.Position).Magnitude
            if distance <= triggerBotRange then
                if mouse1click then
                    mouse1click()
                end
            end
        end
    end
end)

-- Create UI Elements
local silentAimTab = Instance.new("Frame")
silentAimTab.Size = UDim2.new(1, 0, 1, -50)
silentAimTab.BackgroundTransparency = 1
silentAimTab.Parent = mainFrame

local function createToggle(parent, text, default, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Text = text .. ": " .. (default and "ON" or "OFF")
    button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        default = not default
        button.Text = text .. ": " .. (default and "ON" or "OFF")
        button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(default)
    end)
end

createToggle(silentAimTab, "Enable Silent Aim", false, function(value) silentAimEnabled = value end)
createSlider(silentAimTab, "Silent Aim Strength", 1, 20, silentAimStrength, function(value) silentAimStrength = value end)

createToggle(silentAimTab, "Enable Cam Lock", false, function(value) camLockEnabled = value end)
createSlider(silentAimTab, "Cam Lock Speed", 1, 10, camLockSmoothness, function(value) camLockSmoothness = value end)

createToggle(silentAimTab, "Enable Trigger Bot", false, function(value) triggerBotEnabled = value end)
createSlider(silentAimTab, "Trigger Bot Range", 5, 50, triggerBotRange, function(value) triggerBotRange = value end)
