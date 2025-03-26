-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI Setup (Synapse X Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
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

-- // Toggle Buttons (For ESP, Aimbot, Camera Lock, FOV Circle)
local function createToggleButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 280, 0, 30)
    button.Position = UDim2.new(0, 10, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

local espEnabled, aimbotEnabled, cameraLockEnabled, fovCircleEnabled = false, false, false, false

createToggleButton("Toggle ESP", 60, function()
    espEnabled = not espEnabled
    print("ESP Enabled:", espEnabled)
end)

createToggleButton("Toggle Aimbot", 100, function()
    aimbotEnabled = not aimbotEnabled
    print("Aimbot Enabled:", aimbotEnabled)
end)

createToggleButton("Toggle Camera Lock", 140, function()
    cameraLockEnabled = not cameraLockEnabled
    print("Camera Lock Enabled:", cameraLockEnabled)
end)

createToggleButton("Toggle FOV Circle", 180, function()
    fovCircleEnabled = not fovCircleEnabled
    print("FOV Circle Enabled:", fovCircleEnabled)
end)

-- // Aimbot Functionality (Tracking with Cursor)
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
                -- Get mouse position
                local cursorPos = UserInputService:GetMouseLocation()

                -- Calculate direction to the cursor
                local direction = (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - cursorPos).Unit

                -- Lerp between the current camera position and the target position
                local targetCFrame = Camera.CFrame * CFrame.new(direction.X, direction.Y, 0) -- Move towards the cursor

                -- Apply the aim smoothness
                local smoothFactor = 0.1  -- Adjust smoothness factor as needed
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothFactor)
            end
        end
    end
end)

-- // Camera Lock Functionality
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 0.1)
        end
    end
end)

-- // FOV Circle Setup
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, 200, 0, 200)
fovCircle.Position = UDim2.new(0.5, -100, 0.5, -100)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 0.5
fovCircle.Visible = false
fovCircle.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = fovCircleEnabled
end)
