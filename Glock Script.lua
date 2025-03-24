-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Glock.lol"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Ensure the GUI is visible across all executors
if not screenGui.Parent then
    warn("Unable to attach GUI to PlayerGui. Please check executor permissions.")
    return
end

-- Frame for the GUI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 400)  -- Size of the GUI frame
frame.Position = UDim2.new(0.5, -200, 0.5, -200)  -- Centered
frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)  -- Dark red color for visibility
frame.BackgroundTransparency = 0  -- No transparency
frame.BorderSizePixel = 0  -- No border
frame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Glock.lol"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.TextStrokeTransparency = 0.8
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = frame

-- Buttons for toggling features
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
local triggerBotButton = createButton("Trigger Bot", 0.4)
local espButton = createButton("ESP", 0.6)
local speedHackButton = createButton("Speed Hack", 0.8)

-- Slider for smoothness control (customizable)
local smoothnessSliderLabel = Instance.new("TextLabel")
smoothnessSliderLabel.Text = "Camera Lock Smoothness"
smoothnessSliderLabel.Size = UDim2.new(1, 0, 0, 40)
smoothnessSliderLabel.Position = UDim2.new(0, 0, 1, 0)
smoothnessSliderLabel.BackgroundTransparency = 1
smoothnessSliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothnessSliderLabel.TextSize = 18
smoothnessSliderLabel.TextStrokeTransparency = 0.8
smoothnessSliderLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
smoothnessSliderLabel.TextXAlignment = Enum.TextXAlignment.Center
smoothnessSliderLabel.Parent = frame

local smoothnessSlider = Instance.new("TextBox")
smoothnessSlider.Text = "0.1"  -- Default smoothness value
smoothnessSlider.Size = UDim2.new(0, 200, 0, 40)
smoothnessSlider.Position = UDim2.new(0.5, -100, 1.1, 0)
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
smoothnessSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothnessSlider.TextSize = 18
smoothnessSlider.TextAlign = Enum.TextXAlignment.Center
smoothnessSlider.Parent = frame

-- Smoothness variable
local smoothnessValue = 0.1  -- Default smoothness value

smoothnessSlider.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = tonumber(smoothnessSlider.Text)
        if input and input >= 0 and input <= 1 then
            smoothnessValue = input
        else
            smoothnessSlider.Text = tostring(smoothnessValue)  -- Reset to last valid value
        end
    end
end)

-- Smooth Drag Function for GUI
local dragging, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        update(input)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Features Logic
local camera = game.Workspace.CurrentCamera
local triggerBot = false
local lockCamera = false
local speedHackEnabled = false
local espEnabled = false

-- Camera Lock (Track Head with Smoothness)
local function toggleCameraLock()
    lockCamera = not lockCamera

    if lockCamera then
        print("Camera Lock Enabled")
        local renderSteppedConnection
        renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if not lockCamera then
                renderSteppedConnection:Disconnect()
                return
            end

            local closestPlayer = nil
            local closestDistance = math.huge

            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local distance = (camera.CFrame.Position - player.Character.Head.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player.Character.Head
                    end
                end
            end

            -- Smoothly move camera to the target player's head
            if closestPlayer then
                -- Calculate the target CFrame
                local targetCFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Position)

                -- Smoothly interpolate between current camera CFrame and target
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothnessValue)  -- Use smoothnessValue from slider
            end
        end)
    else
        print("Camera Lock Disabled")
    end
end

-- Trigger Bot
local function toggleTriggerBot()
    triggerBot = not triggerBot
    if triggerBot then
        print("Trigger Bot Enabled")
        -- Add trigger bot logic here (check for enemies in the crosshair and auto-shoot)
        -- For now, this is just a placeholder. You need to implement auto-shoot logic.
    else
        print("Trigger Bot Disabled")
    end
end

triggerBotButton.MouseButton1Click:Connect(toggleTriggerBot)

-- ESP (as before)
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        print("ESP Enabled")
        -- Create ESP for every player
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Adornee = player.Character.HumanoidRootPart
                billboardGui.Parent = player.Character.HumanoidRootPart
                billboardGui.Size = UDim2.new(0, 100, 0, 50)
                billboardGui.StudsOffset = Vector3.new(0, 3, 0)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = player.Name
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextStrokeTransparency = 0.8
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.TextSize = 16
                nameLabel.Parent = billboardGui
            end
        end
    else
        print("ESP Disabled")
        -- Remove ESP
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local billboardGui = player.Character.HumanoidRootPart:FindFirstChildOfClass("BillboardGui")
                if billboardGui then
                    billboardGui:Destroy()
                end
            end
        end
    end
end

espButton.MouseButton1Click:Connect(toggleESP)

-- Speed Hack
local function toggleSpeedHack()
    speedHackEnabled = not speedHackEnabled
    if speedHackEnabled then
        print("Speed Hack Enabled")
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100  -- Set to a high value for faster movement
    else
        print("Speed Hack Disabled")
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16  -- Reset to normal walk speed
    end
end

speedHackButton.MouseButton1Click:Connect(toggleSpeedHack)

-- Toggle the camera lock button functionality
cameraLockButton.MouseButton1Click:Connect(toggleCameraLock)

-- Ensure speed hack resets on respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if not speedHackEnabled then
        character.Humanoid.WalkSpeed = 16
    end
end)
