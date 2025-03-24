local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Mouse = localPlayer:GetMouse()

local SETTINGS_FILE = "GlockSettings.json"

-- Default Settings
local settings = {
    triggerBotEnabled = false,
    lockAimbotEnabled = false,
    silentAimEnabled = false,
    espEnabled = false,
    fovCircleEnabled = false,
    aimbotSmoothness = 0.2,
    triggerBotSmoothness = 0.2,
    silentAimFOV = 130
}

-- Load Settings
if isfile(SETTINGS_FILE) then
    local savedSettings = HttpService:JSONDecode(readfile(SETTINGS_FILE))
    for key, value in pairs(savedSettings) do
        settings[key] = value
    end
end

-- Save Settings
local function saveSettings()
    writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
end

-- Get Closest Player within FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = settings.silentAimFOV
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

-- Aimbot Function (Smooth Lock)
RunService.RenderStepped:Connect(function()
    if settings.lockAimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), settings.aimbotSmoothness)
        end
    end
end)

-- Silent Aim (Auto-Aim without Locking Camera)
RunService.RenderStepped:Connect(function()
    if settings.silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local direction = (headPos - camera.CFrame.Position).unit
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        end
    end
end)

-- Trigger Bot (Auto-Shoot when Crosshair is on Enemy)
RunService.RenderStepped:Connect(function()
    if settings.triggerBotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local ray = Ray.new(camera.CFrame.Position, (headPos - camera.CFrame.Position).unit * settings.triggerBotSmoothness)
            local hit, _ = workspace:FindPartOnRay(ray, localPlayer.Character)
            if hit and hit:IsDescendantOf(target.Character) then
                mouse1click()
            end
        end
    end
end)

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Function to create toggle buttons
local function createToggleButton(parent, text, settingName, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.Text = text .. ": " .. (settings[settingName] and "ON" or "OFF")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    button.MouseButton1Click:Connect(function()
        settings[settingName] = not settings[settingName]
        button.Text = text .. ": " .. (settings[settingName] and "ON" or "OFF")
        saveSettings()
    end)
end

createToggleButton(mainFrame, "Aimbot", "lockAimbotEnabled", 50)
createToggleButton(mainFrame, "Silent Aim", "silentAimEnabled", 100)
createToggleButton(mainFrame, "Trigger Bot", "triggerBotEnabled", 150)
createToggleButton(mainFrame, "ESP", "espEnabled", 200)
createToggleButton(mainFrame, "FOV Circle", "fovCircleEnabled", 250)

-- Function to create sliders
local function createSlider(parent, text, settingName, position)
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0, 180, 0, 40)
    slider.Position = UDim2.new(0, 10, 0, position)
    slider.Text = text .. ": " .. tostring(settings[settingName])
    slider.Parent = parent
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    slider.FocusLost:Connect(function()
        local newValue = tonumber(slider.Text:match("%d+%.?%d*"))
        if newValue then
            settings[settingName] = newValue
            slider.Text = text .. ": " .. tostring(newValue)
            saveSettings()
        end
    end)
end

createSlider(mainFrame, "Aimbot Smoothness", "aimbotSmoothness", 300)
createSlider(mainFrame, "TriggerBot Smoothness", "triggerBotSmoothness", 350)
createSlider(mainFrame, "Silent Aim FOV", "silentAimFOV", 400)

print("✅ Glock GUI Loaded! Made by Snoopy")

