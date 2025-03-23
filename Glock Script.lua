local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()

local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local fovCircleEnabled = true
local camLockSmoothness = 5
local triggerBotRange = 10
local silentAimStrength = 5
local fovSize = 100

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game.CoreGui

-- Main Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true

-- Dragging System
local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Radius = fovSize
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Visible = fovCircleEnabled

RunService.RenderStepped:Connect(function()
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Visible = fovCircleEnabled
end)

-- Function to get the closest player within FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = fovSize
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

-- Toggleable Features
local function createButton(text, parent, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 150, 0, 40)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
end

createButton("Toggle Cam Lock", mainFrame, function()
    camLockEnabled = not camLockEnabled
    print("Cam Lock:", camLockEnabled)
end)

createButton("Toggle Silent Aim", mainFrame, function()
    silentAimEnabled = not silentAimEnabled
    print("Silent Aim:", silentAimEnabled)
end)

createButton("Toggle Trigger Bot", mainFrame, function()
    triggerBotEnabled = not triggerBotEnabled
    print("Trigger Bot:", triggerBotEnabled)
end)

createButton("Toggle ESP", mainFrame, function()
    espEnabled = not espEnabled
    print("ESP:", espEnabled)
end)

createButton("Toggle FOV Circle", mainFrame, function()
    fovCircleEnabled = not fovCircleEnabled
    fovCircle.Visible = fovCircleEnabled
    print("FOV Circle:", fovCircleEnabled)
end)
