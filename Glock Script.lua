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
local function createToggleButton(parent, text, settingName, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent

    local function updateButton()
        button.Text = text .. ": " .. (settingName and "ON" or "OFF")
    end

    updateButton()

    button.MouseButton1Click:Connect(function()
        settingName = not settingName
        updateButton()
        saveSettings()
    end)
end

-- Function to Create Sliders
local function createSlider(parent, text, settingName, position)
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0, 180, 0, 40)
    slider.Position = UDim2.new(0, 10, 0, position)
    slider.Text = text .. ": " .. tostring(settingName)
    slider.Parent = parent
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)

    slider.FocusLost:Connect(function()
        local newValue = tonumber(slider.Text:match("%d+%.?%d*"))
        if newValue then
            settingName = newValue
            slider.Text = text .. ": " .. tostring(newValue)
            saveSettings()
        end
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

print("GUI Loaded Successfully!")
