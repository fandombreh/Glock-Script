-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI Setup (Synapse X Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Glock - made by snoopy"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- // UI Buttons
local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 280, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

-- // Toggles
local espEnabled = false
local aimbotEnabled = false
local cameraLockEnabled = false
local fovCircleEnabled = false

createButton("Toggle ESP", 40, function()
    espEnabled = not espEnabled
end)

createButton("Toggle Aimbot", 90, function()
    aimbotEnabled = not aimbotEnabled
end)

createButton("Toggle Camera Lock", 140, function()
    cameraLockEnabled = not cameraLockEnabled
end)

createButton("Toggle FOV Circle", 190, function()
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

-- // Aimbot (Smooth & Accurate)
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
            local smoothness = 0.2
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothness)
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
