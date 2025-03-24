local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local SETTINGS_FILE = "GlockSettings.json"

local triggerBotEnabled = false
local lockAimbotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local fovCircleEnabled = false
local triggerBotRange = 15
local aimbotSmoothness = 0.2
local triggerBotSmoothness = 0.2
local silentAimFOV = 130
local espConnections = {}
local triggerBotConnection

-- Save Settings
local function saveSettings()
    local settings = {
        triggerBotEnabled = triggerBotEnabled,
        lockAimbotEnabled = lockAimbotEnabled,
        silentAimEnabled = silentAimEnabled,
        espEnabled = espEnabled,
        fovCircleEnabled = fovCircleEnabled,
        aimbotSmoothness = aimbotSmoothness,
        triggerBotSmoothness = triggerBotSmoothness
    }
    writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
end

-- Load Settings
local function loadSettings()
    if isfile(SETTINGS_FILE) then
        local settings = HttpService:JSONDecode(readfile(SETTINGS_FILE))
        triggerBotEnabled = settings.triggerBotEnabled
        lockAimbotEnabled = settings.lockAimbotEnabled
        silentAimEnabled = settings.silentAimEnabled
        espEnabled = settings.espEnabled
        fovCircleEnabled = settings.fovCircleEnabled
        aimbotSmoothness = settings.aimbotSmoothness
        triggerBotSmoothness = settings.triggerBotSmoothness
    end
end

loadSettings()

-- Get Closest Player within FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = silentAimFOV
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

-- Silent Aim Function
local function silentAim()
    if silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPosition = target.Character.Head.Position
            camera.CFrame = CFrame.new(camera.CFrame.Position, headPosition)
        end
    end
end

-- Toggle Silent Aim
local function toggleSilentAim()
    silentAimEnabled = not silentAimEnabled
    silentAimButton.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
    saveSettings()
end

-- Toggle Aimbot
local function lockAimbot()
    lockAimbotEnabled = not lockAimbotEnabled
    lockAimbotButton.Text = "Lock Aimbot: " .. (lockAimbotEnabled and "ON" or "OFF")
    saveSettings()
    RunService.RenderStepped:Connect(function()
        if lockAimbotEnabled then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPosition = target.Character.Head.Position
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), aimbotSmoothness)
            end
        end
    end)
end

-- Toggle ESP
local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    saveSettings()
end

-- Toggle FOV Circle
local function toggleFOVCircle()
    fovCircleEnabled = not fovCircleEnabled
    fovButton.Text = "FOV Circle: " .. (fovCircleEnabled and "ON" or "OFF")
    saveSettings()
end

-- Toggle Trigger Bot
local function toggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    triggerBotButton.Text = "Trigger Bot: " .. (triggerBotEnabled and "ON" or "OFF")
    saveSettings()
end

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 400)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
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

silentAimButton = createButton("Silent Aim: OFF", mainFrame, toggleSilentAim, startY)
lockAimbotButton = createButton("Lock Aimbot: OFF", mainFrame, lockAimbot, startY + buttonSpacing)
triggerBotButton = createButton("Trigger Bot: OFF", mainFrame, toggleTriggerBot, startY + buttonSpacing * 2)
espButton = createButton("ESP: OFF", mainFrame, toggleESP, startY + buttonSpacing * 3)
fovButton = createButton("FOV Circle: OFF", mainFrame, toggleFOVCircle, startY + buttonSpacing * 4)
