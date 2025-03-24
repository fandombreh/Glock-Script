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
            local direction = (headPosition - camera.CFrame.Position).unit
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        end
    end
end
RunService.RenderStepped:Connect(silentAim)

-- Toggle Aimbot
local function lockAimbot()
    lockAimbotEnabled = not lockAimbotEnabled
    saveSettings()
end

RunService.RenderStepped:Connect(function()
    if lockAimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), aimbotSmoothness)
        end
    end
end)

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false -- Prevents UI from disappearing after respawn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true
mainFrame.Draggable = true

local function createSlider(parent, text, settingVar, position)
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0, 180, 0, 40)
    slider.Position = UDim2.new(0, 10, 0, position)
    slider.Text = text .. ": " .. tostring(_G[settingVar] or 0) -- Added fallback
    slider.Parent = parent
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)

    slider.FocusLost:Connect(function()
        local newValue = tonumber(slider.Text:match("%d+%.?%d*"))
        if newValue then
            if settingVar == "aimbotSmoothness" then
                aimbotSmoothness = newValue
            elseif settingVar == "triggerBotSmoothness" then
                triggerBotSmoothness = newValue
            end
            slider.Text = text .. ": " .. tostring(newValue)
            saveSettings()
        end
    end)
end

createSlider(mainFrame, "Aimbot Smoothness", "aimbotSmoothness", 100)
createSlider(mainFrame, "TriggerBot Smoothness", "triggerBotSmoothness", 150)

print("GUI Loaded Successfully!")
