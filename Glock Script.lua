local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()

local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local aimbotEnabled = false
local camLockSmoothness = 5
local triggerBotRange = 10
local silentAimStrength = 5
local aimbotSmoothness = 7

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Parent = game.CoreGui

-- Main Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
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

-- Function to find the closest enemy
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

-- Cam Lock System
local function updateCamLock()
    if camLockEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), camLockSmoothness / 10)
        end
    end
end

-- Silent Aim System
local function updateSilentAim()
    if silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), silentAimStrength / 20)
        end
    end
end

-- Trigger Bot System
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

-- Aimbot System (Locks onto enemies when holding right-click)
local function updateAimbot()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), aimbotSmoothness / 10)
        end
    end
end

RunService.RenderStepped:Connect(updateSilentAim)
RunService.RenderStepped:Connect(updateCamLock)
RunService.RenderStepped:Connect(updateTriggerBot)
RunService.RenderStepped:Connect(updateAimbot)

-- Function to create toggle buttons
local function createToggleButton(text, parent, toggleVar)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Text = text .. " [OFF]"
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        if toggleVar == "camLock" then
            camLockEnabled = not camLockEnabled
            button.Text = "Cam Lock [" .. (camLockEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "silentAim" then
            silentAimEnabled = not silentAimEnabled
            button.Text = "Silent Aim [" .. (silentAimEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "triggerBot" then
            triggerBotEnabled = not triggerBotEnabled
            button.Text = "Trigger Bot [" .. (triggerBotEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "aimbot" then
            aimbotEnabled = not aimbotEnabled
            button.Text = "Aimbot [" .. (aimbotEnabled and "ON" or "OFF") .. "]"
        end
    end)
end

-- Create buttons
createToggleButton("Cam Lock", mainFrame, "camLock")
createToggleButton("Silent Aim", mainFrame, "silentAim")
createToggleButton("Trigger Bot", mainFrame, "triggerBot")
createToggleButton("Aimbot", mainFrame, "aimbot")
