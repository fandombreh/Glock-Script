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

-- Silent Aim Function (Fixed)
local function silentAim()
    if silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPosition = target.Character.Head.Position
            local direction = (headPosition - camera.CFrame.Position).unit
            -- Adjusting the aim direction using CFrame
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction * 10)
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
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    -- Drawing ESP box
                    local espBox = Instance.new("Frame")
                    espBox.Size = UDim2.new(0, 100, 0, 100)
                    espBox.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y - 50)
                    espBox.BorderSizePixel = 2
                    espBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
                    espBox.BackgroundTransparency = 1
                    espBox.Parent = glockGui
                    table.insert(espConnections, espBox)
                end
            end
        end
    else
        -- Clear all ESP boxes when disabled
        for _, espBox in pairs(espConnections) do
            espBox:Destroy()
        end
        espConnections = {}
    end
end

RunService.RenderStepped:Connect(function()
    silentAim() -- Keeps silent aiming active
    updateESP() -- Updates ESP

    if lockAimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPosition), aimbotSmoothness)
        end
    end
end)

-- FOV Circle Functionality
local fovCircle = Instance.new("CircleHandleAdornment")
fovCircle.Radius = silentAimFOV
fovCircle.Color3 = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.5
fovCircle.Adornee = camera

-- Create UI
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

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 30)
closeButton.Position = UDim2.new(1, -60, 0, 10)
closeButton.Text = "X"
closeButton.Parent = mainFrame
closeButton.MouseButton1Click:Connect(function()
    glockGui:Destroy()
end)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 50, 0, 30)
minimizeButton.Position = UDim2.new(1, -120, 0, 10)
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame
minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Toggle Checkbox
local function createToggleButton(parent, text, settingName, position)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 180, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, position)
    toggleButton.Text = text .. ": " .. tostring(_G[settingName])
    toggleButton.Parent = parent
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    toggleButton.MouseButton1Click:Connect(function()
        _G[settingName] = not _G[settingName]
        toggleButton.Text = text .. ": " .. tostring(_G[settingName])
        saveSettings()
    end)
end

-- Create Toggle Buttons
createToggleButton(mainFrame, "TriggerBot", "triggerBotEnabled", 60)
createToggleButton(mainFrame, "Aimbot", "lockAimbotEnabled", 100)
createToggleButton(mainFrame, "Silent Aim", "silentAimEnabled", 140)
createToggleButton(mainFrame, "ESP", "espEnabled", 180)
createToggleButton(mainFrame, "FOV Circle", "fovCircleEnabled", 220)

-- Create Sliders for Smoothness
local function createSlider(parent, text, settingName, position)
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0, 180, 0, 40)
    slider.Position = UDim2.new(0, 10, 0, position)
    slider.Text = text .. ": " .. tostring(_G[settingName])
    slider.Parent = parent
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    slider.FocusLost:Connect(function()
        local newValue = tonumber(slider.Text:match("%d+%.?%d*"))
        if newValue then
            if settingName == "aimbotSmoothness" then
                aimbotSmoothness = newValue
            elseif settingName == "triggerBotSmoothness" then
                triggerBotSmoothness = newValue
            end
            slider.Text = text .. ": " .. tostring(newValue)
            saveSettings()
        end
    end)
end

-- Add Sliders for Smoothness
createSlider(mainFrame, "Aimbot Smoothness", "aimbotSmoothness", 260)
createSlider(mainFrame, "TriggerBot Smoothness", "triggerBotSmoothness", 300)

-- Parent FOV Circle to glockGui after creation
fovCircle.Parent = glockGui

