local localPlayer = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
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
    if writefile then
        pcall(function()
            writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
        end)
    else
        warn("Writefile function is not available.")
    end
end

-- Load Settings
local function loadSettings()
    if isfile and isfile(SETTINGS_FILE) then
        local success, settings = pcall(function()
            return HttpService:JSONDecode(readfile(SETTINGS_FILE))
        end)
        if success then
            triggerBotEnabled = settings.triggerBotEnabled
            lockAimbotEnabled = settings.lockAimbotEnabled
            silentAimEnabled = settings.silentAimEnabled
            espEnabled = settings.espEnabled
            fovCircleEnabled = settings.fovCircleEnabled
            aimbotSmoothness = settings.aimbotSmoothness
            triggerBotSmoothness = settings.triggerBotSmoothness
        else
            warn("Failed to decode settings, using default values.")
        end
    else
        warn("Settings file not found, using default settings.")
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
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end

RunService.RenderStepped:Connect(function()
    silentAim()

    if lockAimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), aimbotSmoothness)
        end
    end
end)

-- ESP Functionality
local function updateESP()
    for _, espBox in pairs(espConnections) do
        espBox:Destroy()
    end
    espConnections = {}

    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local espBox = Instance.new("Frame")
                    espBox.Size = UDim2.new(0, 50, 0, 50)
                    espBox.Position = UDim2.new(0, headPos.X - 25, 0, headPos.Y - 25)
                    espBox.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    espBox.BackgroundTransparency = 0.5
                    espBox.BorderSizePixel = 0
                    if localPlayer:FindFirstChild("PlayerGui") then
                        espBox.Parent = localPlayer.PlayerGui
                    else
                        warn("PlayerGui is not available.")
                    end
                    table.insert(espConnections, espBox)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)
