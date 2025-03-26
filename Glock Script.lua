-- Existing UI Setup and UI Elements (as in your code)
-- Note that this is the same as your existing setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (Draggable Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Title.Text = "Glock - made by snoopy"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextStrokeTransparency = 0.8
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

-- // Create Toggle Buttons for ESP, Aimbot, Camera Lock, FOV Circle
local espEnabled, aimbotEnabled, cameraLockEnabled, fovCircleEnabled = false, false, false, false

createToggleButton("Toggle ESP", 60, function()
    espEnabled = not espEnabled
    print("ESP Enabled:", espEnabled)
end)

createToggleButton("Toggle Aimbot", 110, function()
    aimbotEnabled = not aimbotEnabled
    print("Aimbot Enabled:", aimbotEnabled)
end)

createToggleButton("Toggle Camera Lock", 160, function()
    cameraLockEnabled = not cameraLockEnabled
    print("Camera Lock Enabled:", cameraLockEnabled)
end)

createToggleButton("Toggle FOV Circle", 210, function()
    fovCircleEnabled = not fovCircleEnabled
    print("FOV Circle Enabled:", fovCircleEnabled)
end)

-- Smoothness Sliders for Aimbot, Camera Lock, and FOV
createSlider("Aimbot Smoothness", 260, 1, 10, 5, function(value)
    aimbotSmoothness = value
end)

createSlider("Camera Lock Smoothness", 310, 1, 10, 5, function(value)
    cameraLockSmoothness = value
end)

createSlider("FOV Radius", 360, 50, 200, 100, function(value)
    fovRadius = value
end)

-- Aimbot Functionality
local function getClosestTarget()
    local closest, shortestDistance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if onScreen and distance < shortestDistance then
                closest, shortestDistance = player, distance
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local targetScreenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            if onScreen then
                local cursorPos = UserInputService:GetMouseLocation()
                local direction = (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - cursorPos).Unit
                local smoothFactor = aimbotSmoothness / 10
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothFactor)
            end
        end
    end
end)

-- Camera Lock Functionality
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), cameraLockSmoothness / 10)
        end
    end
end)

-- ESP Functionality
local function createESPBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local box = Instance.new("BillboardGui")
    box.Size = UDim2.new(0, 100, 0, 100)
    box.StudsOffset = Vector3.new(0, 2, 0)
    box.Adornee = player.Character.HumanoidRootPart
    box.AlwaysOnTop = true
    box.Parent = player.Character

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = box
end

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPBox(player)
            end
        end
    end
end)

-- FOV Circle Functionality
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius)
fovCircle.Position = UDim2.new(0, 0, 0, 0)  
fovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
fovCircle.BackgroundTransparency = 0.5
fovCircle.Visible = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)  
corner.Parent = fovCircle

fovCircle.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    if fovCircleEnabled then
        local cursorPos = UserInputService:GetMouseLocation()
        fovCircle.Position = UDim2.new(0, cursorPos.X - fovRadius / 2, 0, cursorPos.Y - fovRadius / 2)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)
