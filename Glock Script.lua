-- GUI Setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")

-- Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- GUI Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 400)
frame.Position = UDim2.new(0.5, -200, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Dragging functionality
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Create button function
local function createButton(text, positionY, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, positionY, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = frame
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Camera Lock
local lockCameraEnabled = false
createButton("Camera Lock", 0.2, function()
    lockCameraEnabled = not lockCameraEnabled
    if lockCameraEnabled then
        RunService.RenderStepped:Connect(function()
            if not lockCameraEnabled then return end
            local closest, distance = nil, math.huge
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local mag = (Camera.CFrame.Position - player.Character.Head.Position).Magnitude
                    if mag < distance then
                        distance = mag
                        closest = player.Character.Head
                    end
                end
            end
            if closest then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 0.1)
            end
        end)
    end
end)

-- Silent Aim
local silentAimEnabled = false
createButton("Silent Aim", 0.4, function()
    silentAimEnabled = not silentAimEnabled
end)

-- ESP
local espEnabled = false
createButton("ESP", 0.6, function()
    espEnabled = not espEnabled
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local esp = root:FindFirstChildOfClass("BillboardGui")
            if espEnabled and not esp then
                local gui = Instance.new("BillboardGui", root)
                gui.Adornee = root
                gui.Size = UDim2.new(0, 100, 0, 50)
                gui.StudsOffset = Vector3.new(0, 3, 0)
                local label = Instance.new("TextLabel", gui)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Text = player.Name
            elseif not espEnabled and esp then
                esp:Destroy()
            end
        end
    end
end)

-- Speed Hack
local speedHackEnabled = false
createButton("Speed Hack", 0.8, function()
    speedHackEnabled = not speedHackEnabled
    if Humanoid then
        Humanoid.WalkSpeed = speedHackEnabled and 100 or 16
    end
end)
