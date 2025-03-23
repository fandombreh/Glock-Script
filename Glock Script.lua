local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local triggerBotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local triggerBotRange = 15
local silentAimStrength = 100

-- 🎯 Get Closest Player Function
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (UserInputService:GetMouseLocation() - Vector2.new(headPos.X, headPos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- 🔫 Silent Aim (Fixed Raycasting)
local function silentAim(rayOrigin, rayDirection)
    if silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            return target.Character.Head.Position
        end
    end
    return nil
end

-- 🔥 Trigger Bot (Auto-Shoot)
local triggerBotConnection
local function toggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    triggerBotButton.Text = "Trigger Bot: " .. (triggerBotEnabled and "ON" or "OFF")
    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local distance = (target.Character.Head.Position - camera.CFrame.Position).Magnitude
                if distance < triggerBotRange then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, Enum.UserInputType.MouseButton1, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, Enum.UserInputType.MouseButton1, false, game, 0)
                end
            end
        end)
    else
        if triggerBotConnection then
            triggerBotConnection:Disconnect()
            triggerBotConnection = nil
        end
    end
end

-- 🔵 ESP (Fix Cleanup)
local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    if not espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        return
    end

    RunService.RenderStepped:Connect(function()
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local character = player.Character
                if not character:FindFirstChild("Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Adornee = character
                end
            end
        end
    end)
end

-- 🛠️ UI Setup
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

silentAimButton = createButton("Silent Aim: OFF", mainFrame, function()
    silentAimEnabled = not silentAimEnabled
    silentAimButton.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
end, startY)

triggerBotButton = createButton("Trigger Bot: OFF", mainFrame, toggleTriggerBot, startY + buttonSpacing)
espButton = createButton("ESP: OFF", mainFrame, toggleESP, startY + buttonSpacing * 2)
