-- Advanced ESP, Cam Lock, and Triggerbot Script for Da Hood with UI

-- Get services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- UI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ESP, Cam Lock, and Triggerbot Toggle Buttons
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 150, 0, 50)
espButton.Position = UDim2.new(0, 10, 0, 10)
espButton.Text = "Toggle ESP"
espButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Parent = ScreenGui

local camLockButton = Instance.new("TextButton")
camLockButton.Size = UDim2.new(0, 150, 0, 50)
camLockButton.Position = UDim2.new(0, 10, 0, 70)
camLockButton.Text = "Toggle Cam Lock"
camLockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
camLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
camLockButton.Parent = ScreenGui

local triggerbotButton = Instance.new("TextButton")
triggerbotButton.Size = UDim2.new(0, 150, 0, 50)
triggerbotButton.Position = UDim2.new(0, 10, 0, 130)
triggerbotButton.Text = "Toggle Triggerbot"
triggerbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
triggerbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerbotButton.Parent = ScreenGui

-- Settings for ESP, Cam Lock, and Triggerbot
local ESPEnabled = false
local CamLockEnabled = false
local TriggerbotEnabled = false
local TriggerbotFOV = 50  -- Field of view for triggerbot activation
local Smoothness = 0.1 -- Smoothness factor for Cam Lock

-- Toggle ESP
espButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        espButton.Text = "ESP: ON"
    else
        espButton.Text = "ESP: OFF"
    end
end)

-- Toggle Cam Lock
camLockButton.MouseButton1Click:Connect(function()
    CamLockEnabled = not CamLockEnabled
    if CamLockEnabled then
        camLockButton.Text = "Cam Lock: ON"
    else
        camLockButton.Text = "Cam Lock: OFF"
    end
end)

-- Toggle Triggerbot
triggerbotButton.MouseButton1Click:Connect(function()
    TriggerbotEnabled = not TriggerbotEnabled
    if TriggerbotEnabled then
        triggerbotButton.Text = "Triggerbot: ON"
    else
        triggerbotButton.Text = "Triggerbot: OFF"
    end
end)

-- ESP part
local function createESP(target)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 50)
    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red Box for ESP
    box.BorderSizePixel = 0
    box.ZIndex = 10
    box.Parent = game:GetService("CoreGui")
    
    local function updateESP()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                box.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 25)
                box.Visible = true
            else
                box.Visible = false
            end
        end
    end

    -- Update ESP every frame
    RunService.RenderStepped:Connect(updateESP)
end

-- Cam Lock function
local function camLock(target)
    local cameraPos = Camera.CFrame.Position
    local targetPos = target.Character.HumanoidRootPart.Position
    local direction = (targetPos - cameraPos).unit
    local lookAtCFrame = CFrame.lookAt(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAtCFrame, Smoothness)
end

-- Triggerbot function
local function triggerbot()
    if TriggerbotEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)).Magnitude
                if onScreen and distance <= TriggerbotFOV then
                    -- Triggerbot logic here: Auto-shoot when target is in crosshair
                    game:GetService("ReplicatedStorage").RemoteEvent:FireServer("Shoot")
                end
            end
        end
    end
end

-- Update ESP, Cam Lock, and Triggerbot every frame
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                createESP(player)
            end
        end
    end

    if CamLockEnabled then
        local target = getClosestTarget()  -- Function to get the closest target
        if target then
            camLock(target)
        end
    end

    triggerbot()
end)

-- Helper function to get the closest target (for Cam Lock)
function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end
