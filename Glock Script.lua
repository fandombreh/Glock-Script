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

-- // UI Buttons
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

-- // Toggles
local espEnabled = false
local aimbotEnabled = false
local cameraLockEnabled = false
local fovCircleEnabled = false

createButton("Toggle ESP", 10, function()
    espEnabled = not espEnabled
end)

createButton("Toggle Aimbot", 50, function()
    aimbotEnabled = not aimbotEnabled
end)

createButton("Toggle Camera Lock", 90, function()
    cameraLockEnabled = not cameraLockEnabled
end)

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
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            highlight.Enabled = true
        else
            highlight.Enabled = false
        end
    end

    RunService.RenderStepped:Connect(update)
    
    player.CharacterRemoving:Connect(function()
        highlight:Destroy()
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

-- // Aimbot (Smooth & More Accurate)
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
            local currentCFrame = Camera.CFrame.Position
            local smoothness = 0.1  -- Controls how smooth the aim is (Lower is slower)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentCFrame, targetPos), smoothness)
        end
    end
end)

-- // Camera Lock
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

-- // FOV Circle (Fixed)
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = 100
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.NumSides = 50
fovCircle.Filled = false
fovCircle.Transparency = 0.5
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if fovCircleEnabled then
        fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)
