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

-- Find nearest player to crosshair
local function getNearestPlayer()
    local closest, minDist = nil, math.huge
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < minDist and dist < 200 then
                    closest, minDist = player, dist
                end
            end
        end
    end
    return closest
end

-- Cam Lock Function
RunService.RenderStepped:Connect(function()
    if camLockEnabled and targetPlayer and targetPlayer.Character then
        local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, hrp.Position), camLockSmoothness / 100)
        end
    end
end)

-- Trigger Bot Function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and triggerBotEnabled then
        local target = getNearestPlayer()
        if target and (target.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude < triggerBotRange then
            task.wait(0.1)
            mouse1click()
        end
    end
end)

-- Toggle Cam Lock
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E then
        camLockEnabled = not camLockEnabled
        targetPlayer = getNearestPlayer()
    end
end)

-- Toggle Trigger Bot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        triggerBotEnabled = not triggerBotEnabled
    end
end)

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

silentAimTab.Visible = true -- Default active tab
