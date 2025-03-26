-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = ScreenGui

-- // Buttons
local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 30)
    button.Position = UDim2.new(0, 10, 0, position)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

local espEnabled = false
createButton("Toggle ESP", 10, function()
    espEnabled = not espEnabled
end)

local aimbotEnabled = false
createButton("Toggle Aimbot", 50, function()
    aimbotEnabled = not aimbotEnabled
end)

local cameraLockEnabled = false
createButton("Toggle Camera Lock", 90, function()
    cameraLockEnabled = not cameraLockEnabled
end)

local fovCircleEnabled = false
createButton("Toggle FOV Circle", 130, function()
    fovCircleEnabled = not fovCircleEnabled
end)

-- // ESP Function
local function createESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5

    local function update()
        highlight.Enabled = espEnabled
    end

    RunService.RenderStepped:Connect(update)
end

for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

-- // Aimbot
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude

            if onScreen and distance < shortestDistance then
                closestTarget = player
                shortestDistance = distance
            end
        end
    end

    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

-- // Camera Lock
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.LookVector)
    end
end)

-- // FOV Circle
local fovCircle

RunService.RenderStepped:Connect(function()
    if fovCircleEnabled then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Radius = 100
            fovCircle.Thickness = 2
            fovCircle.Color = Color3.fromRGB(0, 255, 0)
            fovCircle.Filled = false
            fovCircle.Transparency = 1
        end
        fovCircle.Position = UserInputService:GetMouseLocation()
        fovCircle.Visible = true
    else
        if fovCircle then
            fovCircle.Visible = false
        end
    end
end)

    triggerBot()
end)
