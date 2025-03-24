local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 400)
frame.Position = UDim2.new(0.5, -200, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
frame.Parent = screenGui

local function createButton(text, positionY)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, positionY, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Parent = frame
    return button
end

local cameraLockButton = createButton("Camera Lock", 0.2)
local silentAimButton = createButton("Silent Aim", 0.4)
local espButton = createButton("ESP", 0.6)
local speedHackButton = createButton("Speed Hack", 0.8)

-- Feature Toggles
local lockCameraEnabled = false
local silentAimEnabled = false
local speedHackEnabled = false
local espEnabled = false

-- 📌 **Camera Lock (Smooth Aim Assist)**
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("Head") then
            local distance = (player.Character.Head.Position - target.Character.Head.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = target.Character.Head
            end
        end
    end
    
    return closestPlayer
end

local function toggleCameraLock()
    lockCameraEnabled = not lockCameraEnabled
    if lockCameraEnabled then
        print("🔒 Camera Lock Enabled")
        game:GetService("RunService").RenderStepped:Connect(function()
            if not lockCameraEnabled then return end
            
            local target = getClosestEnemy()
            if target then
                local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.2) -- Smooth locking
            end
        end)
    else
        print("🚫 Camera Lock Disabled")
    end
end
cameraLockButton.MouseButton1Click:Connect(toggleCameraLock)

-- 📌 **Silent Aim (Hits enemies without perfect aim)**
local function toggleSilentAim()
    silentAimEnabled = not silentAimEnabled
    print(silentAimEnabled and "🎯 Silent Aim Enabled" or "🚫 Silent Aim Disabled")
end

local function onBulletFired()
    if not silentAimEnabled then return end

    local closestEnemy = getClosestEnemy()
    if closestEnemy then
        local args = {
            [1] = closestEnemy.Position,
            [2] = closestEnemy
        }
        game:GetService("ReplicatedStorage").ShootEvent:FireServer(unpack(args)) -- Simulate hitting target
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
        onBulletFired()
    end
end)

silentAimButton.MouseButton1Click:Connect(toggleSilentAim)

-- 📌 **ESP (Shows enemy positions)**
local function toggleESP()
    espEnabled = not espEnabled
    print(espEnabled and "👀 ESP Enabled" or "🚫 ESP Disabled")
    
    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Adornee = target.Character.HumanoidRootPart
                billboardGui.Size = UDim2.new(0, 100, 0, 50)
                billboardGui.StudsOffset = Vector3.new(0, 3, 0)
                billboardGui.Parent = target.Character.HumanoidRootPart

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = target.Name
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextSize = 16
                nameLabel.Parent = billboardGui
            else
                if target.Character:FindFirstChild("HumanoidRootPart") then
                    local billboardGui = target.Character.HumanoidRootPart:FindFirstChildOfClass("BillboardGui")
                    if billboardGui then billboardGui:Destroy() end
                end
            end
        end
    end
end
espButton.MouseButton1Click:Connect(toggleESP)

-- 📌 **Speed Hack (Fast movement)**
local function toggleSpeedHack()
    speedHackEnabled = not speedHackEnabled
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = speedHackEnabled and 50 or 16
        print(speedHackEnabled and "⚡ Speed Hack Enabled" or "🚶 Speed Hack Disabled")
    end
end
speedHackButton.MouseButton1Click:Connect(toggleSpeedHack)

