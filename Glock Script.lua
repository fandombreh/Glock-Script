local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 200, 0, 60)
espButton.Position = UDim2.new(0, 10, 0, 10)
espButton.Text = "Toggle ESP"
espButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Parent = ScreenGui

local camLockButton = Instance.new("TextButton")
camLockButton.Size = UDim2.new(0, 200, 0, 60)
camLockButton.Position = UDim2.new(0, 10, 0, 80)
camLockButton.Text = "Toggle Cam Lock"
camLockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
camLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
camLockButton.Parent = ScreenGui

local triggerbotButton = Instance.new("TextButton")
triggerbotButton.Size = UDim2.new(0, 200, 0, 60)
triggerbotButton.Position = UDim2.new(0, 10, 0, 150)
triggerbotButton.Text = "Toggle Triggerbot"
triggerbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
triggerbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerbotButton.Parent = ScreenGui

local ESPEnabled = false
local CamLockEnabled = false
local TriggerbotEnabled = false
local TriggerbotFOV = 50
local Smoothness = 0.1

espButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

camLockButton.MouseButton1Click:Connect(function()
    CamLockEnabled = not CamLockEnabled
    camLockButton.Text = CamLockEnabled and "Cam Lock: ON" or "Cam Lock: OFF"
end)

triggerbotButton.MouseButton1Click:Connect(function()
    TriggerbotEnabled = not TriggerbotEnabled
    triggerbotButton.Text = TriggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
end)

local function createESP(target)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 50)
    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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

    RunService.RenderStepped:Connect(updateESP)
end

local function camLock(target)
    local cameraPos = Camera.CFrame.Position
    local targetPos = target.Character.HumanoidRootPart.Position
    local direction = (targetPos - cameraPos).unit
    local lookAtCFrame = CFrame.lookAt(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAtCFrame, Smoothness)
end

local function triggerbot()
    if TriggerbotEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)).Magnitude
                if onScreen and distance <= TriggerbotFOV then
                    game:GetService("ReplicatedStorage").RemoteEvent:FireServer("Shoot")
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                createESP(player)
            end
        end
    end

    if CamLockEnabled then
        local target = getClosestTarget()
        if target then
            camLock(target)
        end
    end

    triggerbot()
end)

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

local dragging, dragInput, dragStart, startPos
local function onInputBegan(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        dragging = true
        dragStart = input.Position
        startPos = ScreenGui.Position
    end
end

local function onInputChanged(input)
    if dragging then
        local delta = input.Position - dragStart
        ScreenGui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

UIS.InputBegan:Connect(onInputBegan)
UIS.InputChanged:Connect(onInputChanged)
UIS.InputEnded:Connect(onInputEnded)
