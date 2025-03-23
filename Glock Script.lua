local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isFocused = true -- Assume focused initially

-- Track focus state
UserInputService.WindowFocused:Connect(function()
    isFocused = true
end)

UserInputService.WindowFocusReleased:Connect(function()
    isFocused = false
end)

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock"
glockGui.Parent = player:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = glockGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 50)
tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabFrame.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Create Tabs
local function createTab(name, position, targetTab)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 100, 0, 50)
    tab.Position = UDim2.new(0, position * 100, 0, 0)
    tab.Text = name
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 16
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tab.Parent = tabFrame

    tab.MouseButton1Click:Connect(function()
        for _, frame in pairs(contentFrame:GetChildren()) do
            frame.Visible = false
        end
        targetTab.Visible = true
    end)
end

-- Create Slider
local function createSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 350, 0, 50)
    sliderFrame.Parent = parent
    sliderFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.BackgroundTransparency = 1
    label.Parent = sliderFrame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 350, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.Text = ""
    slider.Parent = sliderFrame

    local moving = false

    local function updateSlider(input)
        if not moving then return end
        local mousePos = input.Position.X
        local sliderPos = slider.AbsolutePosition.X
        local percent = math.clamp((mousePos - sliderPos) / slider.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percent)
        label.Text = text .. ": " .. value
        callback(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            moving = true
            updateSlider(input)
        end
    end)

    local inputChangedConn
    inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if moving and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            moving = false
        end
    end)
end

-- Creating Tabs
local silentAimTab = Instance.new("Frame")
silentAimTab.Name = "SilentAimTab"
silentAimTab.Size = UDim2.new(1, 0, 1, -50)
silentAimTab.BackgroundTransparency = 1
silentAimTab.Parent = contentFrame
silentAimTab.Visible = false

local camLockTab = silentAimTab:Clone()
camLockTab.Name = "CamLockTab"
camLockTab.Parent = contentFrame
camLockTab.Visible = false

local triggerBotTab = silentAimTab:Clone()
triggerBotTab.Name = "TriggerBotTab"
triggerBotTab.Parent = contentFrame
triggerBotTab.Visible = false

createTab("Silent Aim", 0, silentAimTab)
createTab("Cam Lock", 1, camLockTab)
createTab("Trigger Bot", 2, triggerBotTab)

-- Sliders
createSlider(silentAimTab, "Smoothness", 1, 10, 5, function(value) end)
createSlider(camLockTab, "Smoothness", 1, 10, 5, function(value) end)
createSlider(triggerBotTab, "Trigger Range", 1, 50, 10, function(value) end)
createSlider(camLockTab, "Lock Range", 1, 50, 10, function(value) end)

silentAimTab.Visible = true -- Default active tab

