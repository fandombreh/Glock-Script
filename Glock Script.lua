-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame for the GUI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 400)
frame.Position = UDim2.new(0.5, -200, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Make GUI Draggable
local UIS = game:GetService("UserInputService")
local dragging, dragInput, startPos, dragStart

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Button Creator
local function createButton(text, positionY)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, positionY, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = frame
    return button
end

local cameraLockButton = createButton("Camera Lock", 0.2)
local silentAimButton = createButton("Silent Aim", 0.4)
local espButton = createButton("ESP", 0.6)
local speedHackButton = createButton("Speed Hack", 0.8)

-- Camera Lock
local camera = game.Workspace.CurrentCamera
local lockCameraEnabled = false

cameraLockButton.MouseButton1Click:Connect(function()
    lockCameraEnabled = not lockCameraEnabled
    if lockCameraEnabled then
        print("Camera Lock Enabled")
        game:GetService("RunService").RenderStepped:Connect(function()
            if not lockCameraEnabled then return end
            local closestPlayer, closestDistance = nil, math.huge
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local distance = (camera.CFrame.Position - player.Character.Head.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player.Character.Head
                    end
                end
            end
            if closestPlayer then
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closestPlayer.Position), 0.1)
            end
        end)
    else
        print("Camera Lock Disabled")
    end
end)

-- Silent Aim (Fixes Locking Issue)
local silentAimEnabled = false
silentAimButton.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    print("Silent Aim " .. (silentAimEnabled and "Enabled" or "Disabled"))
end)

-- Speed Hack Fix
local speedHackEnabled = false
speedHackButton.MouseButton1Click:Connect(function()
    speedHackEnabled = not speedHackEnabled
    local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedHackEnabled and 100 or 16
        print("Speed Hack " .. (speedHackEnabled and "Enabled" or "Disabled"))
    end
end)

-- ESP (No Changes Needed)
local espEnabled = false
espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    print("ESP " .. (espEnabled and "Enabled" or "Disabled"))
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local existingESP = rootPart:FindFirstChildOfClass("BillboardGui")
            if espEnabled and not existingESP then
                local billboardGui = Instance.new("BillboardGui", rootPart)
                billboardGui.Adornee = rootPart
                billboardGui.Size = UDim2.new(0, 100, 0, 50)
                billboardGui.StudsOffset = Vector3.new(0, 3, 0)
                local nameLabel = Instance.new("TextLabel", billboardGui)
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.Text = player.Name
            elseif not espEnabled and existingESP then
                existingESP:Destroy()
            end
        end
    end
end)
