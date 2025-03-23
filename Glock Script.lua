local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local triggerBotEnabled = false
local lockAimbotEnabled = false
local espEnabled = false
local fovCircleEnabled = false
local triggerBotRange = 15
local aimbotStrength = 100
local espConnections = {}

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

-- 🔒 Lock Aimbot
local function lockAimbot()
    lockAimbotEnabled = not lockAimbotEnabled
    lockAimbotButton.Text = "Lock Aimbot: " .. (lockAimbotEnabled and "ON" or "OFF")
    RunService.RenderStepped:Connect(function()
        if lockAimbotEnabled then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end)
end

-- 🔵 ESP System
local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    for _, conn in ipairs(espConnections) do
        conn:Disconnect()
    end
    table.clear(espConnections)
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
    local conn = RunService.RenderStepped:Connect(function()
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
    table.insert(espConnections, conn)
end

-- 🔵 FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 2
fovCircle.Radius = 100
fovCircle.Position = UserInputService:GetMouseLocation()
local function toggleFOVCircle()
    fovCircleEnabled = not fovCircleEnabled
    fovButton.Text = "FOV Circle: " .. (fovCircleEnabled and "ON" or "OFF")
    fovCircle.Visible = fovCircleEnabled
end
RunService.RenderStepped:Connect(function()
    fovCircle.Position = UserInputService:GetMouseLocation()
end)

-- 🛠️ UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
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

lockAimbotButton = createButton("Lock Aimbot: OFF", mainFrame, lockAimbot, startY)
triggerBotButton = createButton("Trigger Bot: OFF", mainFrame, toggleTriggerBot, startY + buttonSpacing)
espButton = createButton("ESP: OFF", mainFrame, toggleESP, startY + buttonSpacing * 2)
fovButton = createButton("FOV Circle: OFF", mainFrame, toggleFOVCircle, startY + buttonSpacing * 3)
