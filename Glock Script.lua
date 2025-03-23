local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()

local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local camLockSmoothness = 5
local triggerBotRange = 10
local silentAimStrength = 5

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Parent = localPlayer:WaitForChild("PlayerGui")

the main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.ClipsDescendants = true
mainFrame.Parent = glockGui

-- UI Layout Fix
local layout = Instance.new("UIListLayout")
layout.Parent = mainFrame
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 20) -- Increase padding to avoid overlapping

-- Function to create sliders
local function createSlider(parent, label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = parent
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 150, 0, 50)
    sliderLabel.Position = UDim2.new(0, 10, 0, 0)
    sliderLabel.Text = label .. ": " .. tostring(default)
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Parent = frame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0, 120, 0, 10)
    sliderBar.Position = UDim2.new(0, 160, 0, 20)
    sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
    sliderBar.Parent = frame
    
    local dragBar = Instance.new("TextButton")
    dragBar.Size = UDim2.new(0, 10, 0, 20)
    dragBar.Position = UDim2.new(0, (default - min) / (max - min) * 120, 0, -5)
    dragBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dragBar.Parent = sliderBar
    
    dragBar.MouseButton1Down:Connect(function()
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local posX = math.clamp(mouseX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
            local value = math.floor(min + ((posX / sliderBar.AbsoluteSize.X) * (max - min)))
            dragBar.Position = UDim2.new(0, posX - 5, 0, -5)
            sliderLabel.Text = label .. ": " .. tostring(value)
            callback(value)
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
            end
        end)
    end)
end

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

local function updateSilentAim()
    if silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), silentAimStrength / 20)
        end
    end
end

local function updateCamLock()
    if camLockEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), camLockSmoothness / 10)
        end
    end
end

local function updateTriggerBot()
    if triggerBotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if (localPlayer.Character.Head.Position - target.Character.Head.Position).Magnitude <= triggerBotRange then
                mouse1click()
            end
        end
    end
end

RunService.RenderStepped:Connect(updateSilentAim)
RunService.RenderStepped:Connect(updateCamLock)
RunService.RenderStepped:Connect(updateTriggerBot)

-- Create UI Elements
createSlider(mainFrame, "Silent Aim Strength", 1, 20, silentAimStrength, function(value) silentAimStrength = value end)
createSlider(mainFrame, "Cam Lock Speed", 1, 10, camLockSmoothness, function(value) camLockSmoothness = value end)
createSlider(mainFrame, "Trigger Bot Range", 5, 50, triggerBotRange, function(value) triggerBotRange = value end)
