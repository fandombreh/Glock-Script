local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isFocused = true
local camLockEnabled = false
local triggerBotEnabled = false
local targetPlayer = nil
local camLockSmoothness = 5
local triggerBotRange = 10

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
glockGui.Parent = localPlayer:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
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

-- Creating Tabs
local function createTabContent(tab, name)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 24
    label.Parent = tab
end

local silentAimTab = Instance.new("Frame")
silentAimTab.Name = "SilentAimTab"
silentAimTab.Size = UDim2.new(1, 0, 1, -50)
silentAimTab.BackgroundTransparency = 1
silentAimTab.Parent = contentFrame
silentAimTab.Visible = false
createTabContent(silentAimTab, "Silent Aim Settings")

local camLockTab = silentAimTab:Clone()
camLockTab.Name = "CamLockTab"
camLockTab.Parent = contentFrame
camLockTab.Visible = false
createTabContent(camLockTab, "Cam Lock Settings")

local triggerBotTab = silentAimTab:Clone()
triggerBotTab.Name = "TriggerBotTab"
triggerBotTab.Parent = contentFrame
triggerBotTab.Visible = false
createTabContent(triggerBotTab, "Trigger Bot Settings")

createTab("Silent Aim", 0, silentAimTab)
createTab("Cam Lock", 1, camLockTab)
createTab("Trigger Bot", 2, triggerBotTab)

silentAimTab.Visible = true -- Default active tab
