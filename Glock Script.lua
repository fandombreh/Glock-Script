local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
        triggerBotEnabled = settings.triggerBotEnabled or false
        lockAimbotEnabled = settings.lockAimbotEnabled or false
        silentAimEnabled = settings.silentAimEnabled or false
        espEnabled = settings.espEnabled or false
        fovCircleEnabled = settings.fovCircleEnabled or false
        aimbotSmoothness = settings.aimbotSmoothness or 0.2
        triggerBotSmoothness = settings.triggerBotSmoothness or 0.2
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
RunService.RenderStepped:Connect(function()
    if silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPosition = target.Character.Head.Position
            local direction = (headPosition - camera.CFrame.Position).unit
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        end
    end
end)

-- Lock Aimbot
RunService.RenderStepped:Connect(function()
    if lockAimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), aimbotSmoothness)
        end
    end
end)

-- Trigger Bot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and triggerBotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            wait(triggerBotSmoothness) -- Add slight delay for smoothness
            mouse1click() -- Fire shot
        end
    end
end)

-- ESP Function
local function updateESP()
    for _, connection in pairs(espConnections) do
        connection:Disconnect()
    end
    table.clear(espConnections)

    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Adornee = player.Character.Head
                highlight.Size = Vector3.new(3, 3, 3)
                highlight.Color3 = Color3.fromRGB(255, 0, 0)
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 5
                highlight.Parent = player.Character.Head

                local connection = player.CharacterRemoving:Connect(function()
                    highlight:Destroy()
                end)
                table.insert(espConnections, connection)
            end
        end
    end
end

updateESP()
game.Players.PlayerAdded:Connect(updateESP)
game.Players.PlayerRemoving:Connect(updateESP)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 2
fovCircle.NumSides = 30
fovCircle.Radius = silentAimFOV
fovCircle.Visible = fovCircleEnabled
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = fovCircleEnabled
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Radius = silentAimFOV
end)

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = localPlayer:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Function to Create Toggle Buttons
local function createToggleButton(parent, text, settingVar, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent

    local function updateButton()
        button.Text = text .. ": " .. (settingVar and "ON" or "OFF")
    end

    updateButton()

    button.MouseButton1Click:Connect(function()
        settingVar = not settingVar
        updateButton()
        saveSettings()
        if text == "ESP" then updateESP() end
    end)
end

-- Create Toggle Buttons
createToggleButton(mainFrame, "Trigger Bot", triggerBotEnabled, 10)
createToggleButton(mainFrame, "Lock Aimbot", lockAimbotEnabled, 60)
createToggleButton(mainFrame, "Silent Aim", silentAimEnabled, 110)
createToggleButton(mainFrame, "ESP", espEnabled, 160)
createToggleButton(mainFrame, "FOV Circle", fovCircleEnabled, 210)

-- Create Sliders
createSlider(mainFrame, "Aimbot Smoothness", aimbotSmoothness, 260)
createSlider(mainFrame, "TriggerBot Smoothness", triggerBotSmoothness, 310)

print("Glock GUI Loaded Successfully!")
