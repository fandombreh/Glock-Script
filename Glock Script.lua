-- // Glock - made by Snoopy //

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SETTINGS_FILE = "GlockSettings.json"

local settings = {
    silentAimEnabled = false,
    lockAimbotEnabled = false,
    espEnabled = false,
    fovCircleEnabled = false,
    aimbotSmoothness = 0.2,
    silentAimFOV = 130
}

-- Save & Load Settings
local function saveSettings()
    writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
end

local function loadSettings()
    if isfile(SETTINGS_FILE) then
        local savedData = HttpService:JSONDecode(readfile(SETTINGS_FILE))
        for k, v in pairs(savedData) do
            settings[k] = v
        end
    end
end

loadSettings()

-- Get Closest Player in FOV
local function getClosestPlayer()
    local closestPlayer, shortestDistance = nil, settings.silentAimFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (UserInputService:GetMouseLocation() - Vector2.new(headPos.X, headPos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer, shortestDistance = player, distance
                end
            end
        end
    end
    return closestPlayer
end

-- Silent Aim Fix (Raycast Targeting)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if settings.silentAimEnabled and tostring(self) == "HitPart" and getnamecallmethod() == "FireServer" then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local args = {...}
            args[1] = target.Character.Head.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by Snoopy"
glockGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active, mainFrame.Draggable = true, true

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size, minimizeButton.Position = UDim2.new(0, 50, 0, 30), UDim2.new(1, -60, 0, 10)
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame
minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local showGuiButton = Instance.new("TextButton")
showGuiButton.Size, showGuiButton.Position = UDim2.new(0, 100, 0, 40), UDim2.new(0, 10, 0, 10)
showGuiButton.Text = "Show GUI"
showGuiButton.Parent = glockGui
showGuiButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
end)

local function createToggleButton(parent, text, settingKey, position)
    local button = Instance.new("TextButton")
    button.Size, button.Position = UDim2.new(0, 180, 0, 40), UDim2.new(0, 10, 0, position)
    button.Text = text .. ": OFF"
    button.Parent, button.BackgroundColor3, button.TextColor3 = parent, Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)
    button.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        button.Text = text .. ": " .. (settings[settingKey] and "ON" or "OFF")
        saveSettings()
    end)
end

createToggleButton(mainFrame, "Silent Aim", "silentAimEnabled", 50)
createToggleButton(mainFrame, "Lock Aimbot", "lockAimbotEnabled", 100)
createToggleButton(mainFrame, "ESP", "espEnabled", 150)
createToggleButton(mainFrame, "FOV Circle", "fovCircleEnabled", 200)

local function createSlider(parent, text, settingName, position)
    local slider = Instance.new("TextBox")
    slider.Size, slider.Position = UDim2.new(0, 180, 0, 40), UDim2.new(0, 10, 0, position)
    slider.Text = text .. ": " .. tostring(settings[settingName])
    slider.Parent, slider.BackgroundColor3, slider.TextColor3 = parent, Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)
    slider.FocusLost:Connect(function()
        local newValue = tonumber(slider.Text:match("%d+%.?%d*"))
        if newValue then
            settings[settingName] = newValue
            slider.Text = text .. ": " .. tostring(newValue)
            saveSettings()
        end
    end)
end

createSlider(mainFrame, "Aimbot Smoothness", "aimbotSmoothness", 250)
createSlider(mainFrame, "Silent Aim FOV", "silentAimFOV", 300)
