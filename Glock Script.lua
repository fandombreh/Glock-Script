local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game.CoreGui

-- Variables
local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local fovEnabled = false
local autoLockEnabled = true
local camLockSmoothness = 5
local triggerBotRange = 10
local silentAimStrength = 5
local fovRadius = 150
local targetPlayer = nil

-- Create GUI Elements
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Parent = glockGui

-- Draggable UI
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

-- Get Equipped Weapon
local function hasGunEquipped()
    local character = localPlayer.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                return true
            end
        end
    end
    return false
end

-- Get Closest Player
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
            if onScreen and distance < shortestDistance and distance < fovRadius then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

-- ESP Function
local function updateESP()
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Adornee = player.Character.Head
                highlight.Size = Vector3.new(3, 3, 3)
                highlight.Color3 = Color3.fromRGB(255, 0, 0)
                highlight.AlwaysOnTop = true
                highlight.Parent = player.Character
            end
        end
    end
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 0)
fovCircle.Radius = fovRadius
fovCircle.Thickness = 2
fovCircle.Visible = fovEnabled

RunService.RenderStepped:Connect(function()
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Visible = fovEnabled
end)

-- Auto-Lock on Damage
local function onDamageTaken()
    if autoLockEnabled then
        targetPlayer = getClosestPlayer()
    end
end

localPlayer.Character.Humanoid.HealthChanged:Connect(onDamageTaken)

-- Silent Aim & Cam Lock
RunService.RenderStepped:Connect(function()
    if hasGunEquipped() then
        if camLockEnabled and targetPlayer then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPlayer.Character.Head.Position), camLockSmoothness / 10)
        end
        if silentAimEnabled and targetPlayer then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPlayer.Character.Head.Position), silentAimStrength / 20)
        end
    end
end)

-- Toggle Buttons
local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 150, 0, 40)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = mainFrame
    button.MouseButton1Click:Connect(callback)
end

createButton("Toggle Cam Lock", function()
    camLockEnabled = not camLockEnabled
end)
createButton("Toggle Silent Aim", function()
    silentAimEnabled = not silentAimEnabled
end)
createButton("Toggle Trigger Bot", function()
    triggerBotEnabled = not triggerBotEnabled
end)
createButton("Toggle ESP", function()
    espEnabled = not espEnabled
    updateESP()
end)
createButton("Toggle FOV Circle", function()
    fovEnabled = not fovEnabled
    fovCircle.Visible = fovEnabled
end)

print("Glock - made by snoopy loaded!")
