-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera

-- UI Elements (Add this in Roblox Studio)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Glock - made by snoopy"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = ScreenGui

-- Toggle Buttons (For simplicity, you can add more buttons)
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 180, 0, 30)
espToggle.Position = UDim2.new(0, 10, 0, 10)
espToggle.Text = "Toggle ESP"
espToggle.Parent = MainFrame

local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Size = UDim2.new(0, 180, 0, 30)
aimbotToggle.Position = UDim2.new(0, 10, 0, 50)
aimbotToggle.Text = "Toggle Aimbot"
aimbotToggle.Parent = MainFrame

local cameraLockToggle = Instance.new("TextButton")
cameraLockToggle.Size = UDim2.new(0, 180, 0, 30)
cameraLockToggle.Position = UDim2.new(0, 10, 0, 90)
cameraLockToggle.Text = "Toggle Camera Lock"
cameraLockToggle.Parent = MainFrame

local fovCircleToggle = Instance.new("TextButton")
fovCircleToggle.Size = UDim2.new(0, 180, 0, 30)
fovCircleToggle.Position = UDim2.new(0, 10, 0, 130)
fovCircleToggle.Text = "Toggle FOV Circle"
fovCircleToggle.Parent = MainFrame

-- ESP (Simple Implementation)
local espEnabled = false

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
end)

local function drawESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local part = player.Character.HumanoidRootPart
            local screenPosition = Camera:WorldToScreenPoint(part.Position)

            if espEnabled then
                local espBox = Instance.new("Frame")
                espBox.Size = UDim2.new(0, 5, 0, 5)
                espBox.Position = UDim2.new(0, screenPosition.X - 2.5, 0, screenPosition.Y - 2.5)
                espBox.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                espBox.Parent = ScreenGui
                game:GetService("Debris"):AddItem(espBox, 1)
            end
        end
    end
end

RunService.RenderStepped:Connect(drawESP)

-- Aimbot
local aimbotEnabled = false

aimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
end)

local function aimbotFunction()
    if aimbotEnabled then
        local closestTarget = nil
        local shortestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = player.Character.HumanoidRootPart.Position
                local screenPosition = Camera:WorldToScreenPoint(targetPosition)
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    closestTarget = player
                    shortestDistance = distance
                end
            end
        end

        if closestTarget then
            local targetPosition = closestTarget.Character.HumanoidRootPart.Position
            local mouseDirection = (targetPosition - Camera.CFrame.Position).Unit
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + mouseDirection)
        end
    end
end

RunService.RenderStepped:Connect(aimbotFunction)

-- Camera Lock
local cameraLockEnabled = false

cameraLockToggle.MouseButton1Click:Connect(function()
    cameraLockEnabled = not cameraLockEnabled
end)

local function lockCamera()
    if cameraLockEnabled then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.LookVector)
    end
end

RunService.RenderStepped:Connect(lockCamera)

-- FOV Circle
local fovCircleEnabled = false

fovCircleToggle.MouseButton1Click:Connect(function()
    fovCircleEnabled = not fovCircleEnabled
end)

local fovCircle

local function drawFOVCircle()
    if fovCircleEnabled then
        if not fovCircle then
            fovCircle = Instance.new("Frame")
            fovCircle.Size = UDim2.new(0, 100, 0, 100)
            fovCircle.Position = UDim2.new(0.5, -50, 0.5, -50)
            fovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            fovCircle.BackgroundTransparency = 0.5
            fovCircle.BorderSizePixel = 0
            fovCircle.Parent = ScreenGui
        end
    else
        if fovCircle then
            fovCircle:Destroy()
        end
    end
end

RunService.RenderStepped:Connect(drawFOVCircle)

    triggerBot()
end)
