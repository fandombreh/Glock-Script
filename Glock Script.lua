-- Glock Script for Da Hood with a Clean GUI, Smoothness, and Range Sliders

local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Create the main ScreenGui
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock"
glockGui.Parent = player:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false

-- Main Frame (Clean, centered)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 350)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = glockGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 40)
tabBar.Position = UDim2.new(0, 10, 0, 10)
tabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 8)
tabBarCorner.Parent = tabBar

-- Function to create tab buttons
local function createTabButton(parent, text, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, -5, 1, 0)
    button.Position = position
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 18
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Parent = parent

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    return button
end

local cameraLockTab = createTabButton(tabBar, "Camera Lock", UDim2.new(0, 0, 0, 0))
local triggerbotTab = createTabButton(tabBar, "Triggerbot", UDim2.new(0.5, 5, 0, 0))

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -140)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentFrameCorner = Instance.new("UICorner")
contentFrameCorner.CornerRadius = UDim.new(0, 8)
contentFrameCorner.Parent = contentFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0.5, -10)
statusLabel.Position = UDim2.new(0, 5, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.TextWrapped = true
statusLabel.Text = "Welcome to Glock Script"
statusLabel.Parent = contentFrame

-- Smoothness Slider
local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Size = UDim2.new(0, 200, 0, 20)
smoothnessLabel.Position = UDim2.new(0.5, -100, 1, -110)
smoothnessLabel.BackgroundTransparency = 1
smoothnessLabel.Text = "Smoothness: 0.2"
smoothnessLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
smoothnessLabel.Font = Enum.Font.Gotham
smoothnessLabel.TextSize = 16
smoothnessLabel.Parent = mainFrame

local smoothnessSlider = Instance.new("TextBox")
smoothnessSlider.Size = UDim2.new(0, 180, 0, 30)
smoothnessSlider.Position = UDim2.new(0.5, -90, 1, -80)
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
smoothnessSlider.BorderSizePixel = 0
smoothnessSlider.Text = "0.2"
smoothnessSlider.Font = Enum.Font.Gotham
smoothnessSlider.TextSize = 16
smoothnessSlider.TextColor3 = Color3.fromRGB(230, 230, 230)
smoothnessSlider.Parent = mainFrame

local smoothnessBoxCorner = Instance.new("UICorner")
smoothnessBoxCorner.CornerRadius = UDim.new(0, 6)
smoothnessBoxCorner.Parent = smoothnessSlider

-- Range Slider
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0, 200, 0, 20)
rangeLabel.Position = UDim2.new(0.5, -100, 1, -70)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "Range: 100"
rangeLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 16
rangeLabel.Parent = mainFrame

local rangeSlider = Instance.new("TextBox")
rangeSlider.Size = UDim2.new(0, 180, 0, 30)
rangeSlider.Position = UDim2.new(0.5, -90, 1, -40)
rangeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
rangeSlider.BorderSizePixel = 0
rangeSlider.Text = "100"
rangeSlider.Font = Enum.Font.Gotham
rangeSlider.TextSize = 16
rangeSlider.TextColor3 = Color3.fromRGB(230, 230, 230)
rangeSlider.Parent = mainFrame

local rangeBoxCorner = Instance.new("UICorner")
rangeBoxCorner.CornerRadius = UDim.new(0, 6)
rangeBoxCorner.Parent = rangeSlider

-- Default states
local smoothSpeed = 0.2
local triggerRange = 100

smoothnessSlider.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = tonumber(smoothnessSlider.Text)
        if input and input >= 0 and input <= 1 then
            smoothSpeed = input
            smoothnessLabel.Text = "Smoothness: " .. smoothSpeed
        else
            smoothnessSlider.Text = "Invalid"
            wait(1)
            smoothnessSlider.Text = "0.2"
        end
    end
end)

rangeSlider.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = tonumber(rangeSlider.Text)
        if input and input >= 10 and input <= 500 then
            triggerRange = input
            rangeLabel.Text = "Range: " .. triggerRange
        else
            rangeSlider.Text = "Invalid"
            wait(1)
            rangeSlider.Text = "100"
        end
    end
end)

cameraLockTab.MouseButton1Click:Connect(function()
    statusLabel.Text = "Camera Lock: Adjust Smoothness & Range"
end)

triggerbotTab.MouseButton1Click:Connect(function()
    statusLabel.Text = "Triggerbot: Adjust Smoothness & Range"
end)
