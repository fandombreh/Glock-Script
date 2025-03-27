-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Global Variables
local espBoxes = {}
local espEnabled, aimbotEnabled, cameraLockEnabled, fovCircleEnabled = false, false, false, false
local predictionEnabled = false
local blatantMode = false  -- Non-blatant mode by default
local aimbotSmoothness, cameraLockSmoothness, fovRadius = 5, 5, 100
local keybinds = {aimbot = Enum.KeyCode.E, esp = Enum.KeyCode.R}  -- Hotkeys for toggling

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "Glock - made by snoopy"

local mainFrame = Instance.new("Frame")
mainFrame.Parent = ScreenGui
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Glock - Aimbot"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.BackgroundTransparency = 1
title.TextAlign = Enum.TextXAlignment.Center

local toggleAimbotButton = Instance.new("TextButton")
toggleAimbotButton.Parent = mainFrame
toggleAimbotButton.Size = UDim2.new(1, 0, 0, 50)
toggleAimbotButton.Position = UDim2.new(0, 0, 0, 40)
toggleAimbotButton.Text = "Aimbot: OFF"
toggleAimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleAimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleAimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleAimbotButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

local toggleESPButton = Instance.new("TextButton")
toggleESPButton.Parent = mainFrame
toggleESPButton.Size = UDim2.new(1, 0, 0, 50)
toggleESPButton.Position = UDim2.new(0, 0, 0, 90)
toggleESPButton.Text = "ESP: OFF"
toggleESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleESPButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

local toggleCameraLockButton = Instance.new("TextButton")
toggleCameraLockButton.Parent = mainFrame
toggleCameraLockButton.Size = UDim2.new(1, 0, 0, 50)
toggleCameraLockButton.Position = UDim2.new(0, 0, 0, 140)
toggleCameraLockButton.Text = "Camera Lock: OFF"
toggleCameraLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleCameraLockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleCameraLockButton.MouseButton1Click:Connect(function()
    cameraLockEnabled = not cameraLockEnabled
    toggleCameraLockButton.Text = "Camera Lock: " .. (cameraLockEnabled and "ON" or "OFF")
end)

local toggleFovCircleButton = Instance.new("TextButton")
toggleFovCircleButton.Parent = mainFrame
toggleFovCircleButton.Size = UDim2.new(1, 0, 0, 50)
toggleFovCircleButton.Position = UDim2.new(0, 0, 0, 190)
toggleFovCircleButton.Text = "FOV Circle: OFF"
toggleFovCircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleFovCircleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFovCircleButton.MouseButton1Click:Connect(function()
    fovCircleEnabled = not fovCircleEnabled
    toggleFovCircleButton.Text = "FOV Circle: " .. (fovCircleEnabled and "ON" or "OFF")
end)

-- Helper function to calculate screen distance
local function getScreenDistance(worldPos)
    local screenPoint = Camera:WorldToScreenPoint(worldPos)
    return (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
end

-- Helper function to calculate the predicted position
local function predictPosition(target)
    local character = target.Character
    if not character then return nil end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    -- Get the target's current velocity
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end

    local velocity = humanoid.RootPart.Velocity
    local speed = velocity.Magnitude
    if speed == 0 then return rootPart.Position end

    -- Estimate time to target (for simplicity, using a constant bullet speed)
    local bulletSpeed = 150  -- Customize based on your game's mechanics
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    local timeToTarget = distance / bulletSpeed

    -- Predict where the target will be based on velocity
    local predictedPosition = rootPart.Position + velocity * timeToTarget
    return predictedPosition
end

-- Determine which part to aim at based on mode and position
local function getAimPosition(target)
    if not (target and target.Character) then
        return nil
    end

    local character = target.Character
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

    if blatantMode then
        if head then
            return head.Position
        elseif torso then
            return torso.Position
        end
    else
        -- Non-blatant mode: default is torso
        local defaultPart = torso or head
        if not defaultPart then return nil end

        return defaultPart.Position
    end

    return nil
end

-- Finds the closest target based on the default part for detection in each mode.
local function getClosestTarget()
    local closest, shortestDistance = nil, fovRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = nil
            if blatantMode then
                part = player.Character:FindFirstChild("Head")
            else
                part = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
            end
            if part then
                local screenPoint = Camera:WorldToScreenPoint(part.Position)
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                if distance < shortestDistance then
                    closest = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

-- Aimbot: Aim at the target using the chosen body part
local function aimAtTarget(target)
    if not target then return end
    local aimPos = getAimPosition(target)
    if not aimPos then return end

    local direction = (aimPos - Camera.CFrame.Position).unit
    local newCFrame = Camera.CFrame + direction * 0.1
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, aimbotSmoothness / 100)
end

-- Camera Lock: Keep the camera locked on the target
local function lockCameraOnTarget(target)
    if not target then return end
    local aimPos = getAimPosition(target)
    if not aimPos then return end

    local direction = (aimPos - Camera.CFrame.Position).unit
    local newCFrame = Camera.CFrame + direction * 0.1
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, cameraLockSmoothness / 100)
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target then
            aimAtTarget(target)
        end
    end

    if cameraLockEnabled then
        local target = getClosestTarget()
        if target then
            lockCameraOnTarget(target)
        end
    end
end)
