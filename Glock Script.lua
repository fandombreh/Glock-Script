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
local camLockSmoothness = 0.2  -- Lower value = smoother tracking
local triggerBotRange = 10
local fovSize = 100

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true
mainFrame.Draggable = true

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

-- Function to get closest player
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

-- UI Button Creator
local function createButton(text, parent, callback, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

local buttonSpacing = 45
local startY = 10

-- Cam Lock Toggle (Uses Smooth Camera Adjustment)
local camLockConnection
createButton("Toggle Cam Lock", mainFrame, function()
    camLockEnabled = not camLockEnabled
    print("Cam Lock:", camLockEnabled)

    if camLockEnabled then
        camLockConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                local newCFrame = CFrame.new(camera.CFrame.Position, headPos)

                camera.CFrame = camera.CFrame:Lerp(newCFrame, camLockSmoothness)
            end
        end)
    else
        if camLockConnection then
            camLockConnection:Disconnect()
            camLockConnection = nil
        end
    end
end, startY)

-- Silent Aim Toggle
createButton("Toggle Silent Aim", mainFrame, function()
    silentAimEnabled = not silentAimEnabled
    print("Silent Aim:", silentAimEnabled)
end, startY + buttonSpacing)

-- Trigger Bot Toggle
local triggerBotConnection
createButton("Toggle Trigger Bot", mainFrame, function()
    triggerBotEnabled = not triggerBotEnabled
    print("Trigger Bot:", triggerBotEnabled)

    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local distance = (target.Character.Head.Position - camera.CFrame.Position).Magnitude
                if distance < triggerBotRange then
                    mouse1click()
                end
            end
        end)
    else
        if triggerBotConnection then
            triggerBotConnection:Disconnect()
            triggerBotConnection = nil
        end
    end
end, startY + buttonSpacing * 2)

-- ESP Toggle
createButton("Toggle ESP", mainFrame, function()
    espEnabled = not espEnabled
    print("ESP:", espEnabled)
end, startY + buttonSpacing * 3)

-- FOV Circle Toggle
createButton("Toggle FOV Circle", mainFrame, function()
    fovCircleEnabled = not fovCircleEnabled
    fovCircle.Visible = fovCircleEnabled
    print("FOV Circle:", fovCircleEnabled)
end, startY + buttonSpacing * 4)
