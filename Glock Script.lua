Untitled artifact

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Create a Screen GUI for cheats
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")
screenGui.ResetOnSpawn = false

-- Create a Frame for the cheat buttons
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.7, 0)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Draggable UI setup
local function makeDraggable(dragArea)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        dragArea.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = dragArea.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeDraggable(frame)

-- Function to create buttons in the cheat menu
local function createButton(name, yPosition, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.05, 0)
    button.Position = UDim2.new(0.1, 0, yPosition, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = frame

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)

    button.MouseButton1Click:Connect(callback)
    return button
end

-- Cheat states
local cheats = {
    aimLock = false,
    aimAssist = false,
    triggerBot = false,
    esp = false,
    healthESP = false,
    distanceESP = false
}

-- Find closest player
local function findClosestPlayer()
    if not player.Character then return nil end
    
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

    return closestPlayer
end

-- Aim Lock
local function aimLock()
    if not cheats.aimLock then return end
    
    local closestPlayer = findClosestPlayer()
    if closestPlayer and closestPlayer.Character then
        camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
    end
end

-- Aim Assist
local function aimAssist()
    if not cheats.aimAssist then return end
    
    local closestPlayer = findClosestPlayer()
    if closestPlayer and closestPlayer.Character then
        local aimPosition = closestPlayer.Character.HumanoidRootPart.Position
        local newCFrame = CFrame.new(camera.CFrame.Position, aimPosition)
        camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.1)
    end
end

-- Trigger Bot
local function triggerBot()
    if not cheats.triggerBot then return end
    
    local target = mouse.Target
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
        game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end

-- ESP Toggle
local function toggleESP()
    cheats.esp = not cheats.esp
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local existingHighlight = otherPlayer.Character:FindFirstChild("Highlight")
            
            if cheats.esp then
                if not existingHighlight then
                    local highlight = Instance.new("Highlight", otherPlayer.Character)
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineTransparency = 0.5
                end
            elseif existingHighlight then
                existingHighlight:Destroy()
            end
        end
    end
end

-- Health ESP Toggle
local function toggleHealthESP()
    cheats.healthESP = not cheats.healthESP
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer.Character:FindFirstChild("Humanoid") then
            local existingBillboard = otherPlayer.Character:FindFirstChild("HealthBillboard")
            
            if cheats.healthESP then
                if not existingBillboard then
                    local billboard = Instance.new("BillboardGui", otherPlayer.Character.HumanoidRootPart)
                    billboard.Name = "HealthBillboard"
                    billboard.Size = UDim2.new(4, 0, 1, 0)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true

                    local bar = Instance.new("Frame", billboard)
                    bar.Name = "HealthBar"
                    bar.Size = UDim2.new(1, 0, 0.2, 0)
                    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

                    otherPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        local healthPercent = otherPlayer.Character.Humanoid.Health / otherPlayer.Character.Humanoid.MaxHealth
                        bar.Size = UDim2.new(healthPercent, 0, 0.2, 0)
                        bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    end)
                end
            elseif existingBillboard then
                existingBillboard:Destroy()
            end
        end
    end
end

-- Distance ESP Toggle
local function toggleDistanceESP()
    cheats.distanceESP = not cheats.distanceESP
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local existingBillboard = otherPlayer.Character:FindFirstChild("DistanceBillboard")
            
            if cheats.distanceESP then
                if not existingBillboard then
                    local billboard = Instance.new("BillboardGui", otherPlayer.Character.HumanoidRootPart)
                    billboard.Name = "DistanceBillboard"
                    billboard.Size = UDim2.new(4, 0, 1, 0)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true

                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1, 0, 0.2, 0)
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextSize = 14
                    label.BackgroundTransparency = 1
                    label.TextStrokeTransparency = 0.8
                    
                    spawn(function()
                        while cheats.distanceESP and otherPlayer.Character do
                            local distance = (otherPlayer.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude
                            label.Text = string.format("Distance: %.2f", distance)
                            wait(0.1)
                        end
                    end)
                end
            elseif existingBillboard then
                existingBillboard:Destroy()
            end
        end
    end
end

-- Create Buttons
createButton("Aim Lock", 0.15, function()
    cheats.aimLock = not cheats.aimLock
end)

createButton("Aim Assist", 0.22, function()
    cheats.aimAssist = not cheats.aimAssist
end)

createButton("Trigger Bot", 0.29, function()
    cheats.triggerBot = not cheats.triggerBot
end)

createButton("ESP", 0.36, toggleESP)

createButton("Health ESP", 0.43, toggleHealthESP)

createButton("Distance ESP", 0.50, toggleDistanceESP)

-- Main Loop
local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    aimLock()
    aimAssist()
    triggerBot()
end)
