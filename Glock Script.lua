local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

-- Create a Screen GUI for cheats
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

-- Create a Frame for the cheat buttons (Synapse X-like)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.7, 0)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)  -- Dark background
frame.BackgroundTransparency = 0.8
frame.BorderSizePixel = 0
frame.RoundedCornerRadius = UDim.new(0, 10)  -- Rounded corners
frame.Parent = screenGui

-- Title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = "Synapse X Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextStrokeTransparency = 0.8
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = frame

-------------------------------
-- Aim Cheats Section
-------------------------------

local aimLockEnabled = false
local aimAssistEnabled = false
local triggerBotEnabled = false

-- Aimbot that tracks with the cursor
local function aimbot()
    if aimLockEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end

        if closestPlayer and closestPlayer.Character then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            local cursorPosition = Vector3.new(mouse.Hit.X, targetPosition.Y, mouse.Hit.Z) -- Align cursor with Y position of target

            -- Rotate the character's upper torso to aim at the cursor
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.RootPart then
                humanoid.RootPart.CFrame = CFrame.new(humanoid.RootPart.Position, cursorPosition)
            end
        end
    end
end

-- Camera lock that tracks the camera
local function cameraLock()
    if aimLockEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end

        if closestPlayer and closestPlayer.Character then
            -- Camera follows the closest player
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
        end
    end
end

-- Button to toggle Aim Lock
local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.05, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Darker button
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = frame

    -- Hover effect for the button
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  -- Lighter on hover
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Back to dark on leave
    end)

    button.MouseButton1Click:Connect(callback)
    return button
end

createButton("Toggle Aim Lock", UDim2.new(0.1, 0, 0.15, 0), function()
    aimLockEnabled = not aimLockEnabled
end)

createButton("Toggle Camera Lock", UDim2.new(0.1, 0, 0.2, 0), function()
    aimLockEnabled = not aimLockEnabled
end)

-------------------------------
-- Main Loop
-------------------------------

local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    aimbot()    -- Update aimbot
    cameraLock() -- Update camera lock
end)
