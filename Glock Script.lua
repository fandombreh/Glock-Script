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
local blatantMode = false  -- Default to non-blatant mode
local aimbotSmoothness, cameraLockSmoothness, fovRadius = 5, 5, 100
local keybinds = {aimbot = Enum.KeyCode.E, esp = Enum.KeyCode.R}  -- Hotkeys for toggling

-- Helper function to calculate screen distance
local function getScreenDistance(worldPos)
    local screenPoint = Camera:WorldToScreenPoint(worldPos)
    return (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
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

        local defaultDistance = getScreenDistance(defaultPart.Position)
        local bestPart = defaultPart
        local bestDistance = defaultDistance

        -- Check other candidate parts (head, left leg, right leg)
        local candidates = {}
        if head then
            candidates["Head"] = head
        end
        local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
        if leftLeg then
            candidates["LeftLeg"] = leftLeg
        end
        local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")
        if rightLeg then
            candidates["RightLeg"] = rightLeg
        end

        -- Only change if a candidate is at least 20% closer than the default torso
        for name, part in pairs(candidates) do
            local dist = getScreenDistance(part.Position)
            if dist < bestDistance * 0.8 then
                bestDistance = dist
                bestPart = part
            end
        end

        return bestPart.Position
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

-- UI Setup (Sleek Black Matcha External Style)
local function setupUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Glock - made by snoopy"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame (Black Background, Sleek look)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(16, 63, 216)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = MainFrame
    MainFrame.Parent = ScreenGui

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(18, 84, 192)
    Title.Text = "Glock - made by snoopy"
    Title.TextColor3 = Color3.fromRGB(23, 49, 182)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextStrokeTransparency = 0.8
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = MainFrame

    -- Function to Create Toggle Buttons
    local function createToggleButton(text, position, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 350, 0, 40)
        button.Position = UDim2.new(0, 25, 0, position)
        button.BackgroundColor3 = Color3.fromRGB(182, 35, 35)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(49, 9, 172)
        button.Font = Enum.Font.Gotham
        button.TextSize = 18
        button.TextStrokeTransparency = 0.8
        button.TextXAlignment = Enum.TextXAlignment.Center
        button.Parent = MainFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.05, 0)
        corner.Parent = button
        button.MouseButton1Click:Connect(callback)
        return button
    end

    -- Function to Create Sliders
    local function createSlider(text, position, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(0, 350, 0, 40)
        sliderFrame.Position = UDim2.new(0, 25, 0, position)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.05, 0)
        corner.Parent = sliderFrame
        sliderFrame.Parent = MainFrame

        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(1, 0, 0, 20)
        sliderLabel.Text = text .. ": " .. default
        sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextSize = 18
        sliderLabel.TextStrokeTransparency = 0.8
        sliderLabel.Parent = sliderFrame

        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(0, 300, 0, 20)
        slider.Position = UDim2.new(0, 25, 0, 20)
        slider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        slider.Text = ""
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.05, 0)
        corner.Parent = slider
        slider.Parent = sliderFrame

        local function updateValue(input)
            local relativePosition = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            local value = math.clamp(math.floor(relativePosition * (max - min) + min), min, max)
            sliderLabel.Text = text .. ": " .. value
            callback(value)
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateValue(input)
                local moveConnection
                local releaseConnection
                moveConnection = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateValue(input)
                    end
                end)
                releaseConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        moveConnection:Disconnect()
                        releaseConnection:Disconnect()
                    end
                end)
            end
        end)
    end

    -- Create Toggle Buttons
    createToggleButton("Toggle ESP", 60, function() espEnabled = not espEnabled end)
    createToggleButton("Toggle Aimbot", 110, function() aimbotEnabled = not aimbotEnabled end)
    createToggleButton("Toggle Camera Lock", 160, function() cameraLockEnabled = not cameraLockEnabled end)
    createToggleButton("Toggle FOV Circle", 210, function() fovCircleEnabled = not fovCircleEnabled end)

    -- Blatant Mode Toggle Button
    local blatantModeButton = createToggleButton("Toggle Blatant Mode: Non-Blatant", 460, function()
        blatantMode = not blatantMode
        if blatantMode then
            blatantModeButton.Text = "Toggle Blatant Mode: Blatant"
        else
            blatantModeButton.Text = "Toggle Blatant Mode: Non-Blatant"
        end
    end)

    -- Create Smoothness and FOV Sliders
    createSlider("Aimbot Smoothness", 260, 1, 10, 5, function(value)
        aimbotSmoothness = value
    end)
    createSlider("Camera Lock Smoothness", 310, 1, 10, 5, function(value)
        cameraLockSmoothness = value
    end)
    createSlider("FOV Radius", 360, 50, 200, 100, function(value)
        fovRadius = value
    end)

    -- FOV Circle Setup (Around the Cursor)
    local fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, fovRadius, 0, fovRadius)
    fovCircle.Position = UDim2.new(0, 0, 0, 0)
    fovCircle.BackgroundColor3 = Color3.fromRGB(181, 25, 189)
    fovCircle.BackgroundTransparency = 0.5
    fovCircle.Visible = false

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = fovCircle

    fovCircle.Parent = ScreenGui

    -- Update FOV Circle Position and Visibility
    RunService.RenderStepped:Connect(function()
        if fovCircleEnabled then
            fovCircle.Visible = true
            fovCircle.Position = UDim2.new(0, Mouse.X - fovCircle.Size.X.Offset / 2, 0, Mouse.Y - fovCircle.Size.Y.Offset / 2)
        else
            fovCircle.Visible = false
        end
    end)
end

-- Aimbot: Aim at the target using the chosen body part
local function aimAtTarget(target)
    if target and target.Character then
        local aimPos = getAimPosition(target)
        if aimPos then
            local smoothFactor = blatantMode and 1 or aimbotSmoothness / 10
            local newAim = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), smoothFactor)
            Camera.CFrame = newAim
        end
    end
end

-- Camera Lock: Adjust camera to track the target using the chosen body part
local function lockCameraToTarget(target)
    if target and target.Character then
        local aimPos = getAimPosition(target)
        if aimPos then
            local smoothFactor = blatantMode and 1 or cameraLockSmoothness / 10
            local newCFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), smoothFactor)
            Camera.CFrame = newCFrame
        end
    end
end

-- Keybinds for toggling features
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == keybinds.aimbot then
        aimbotEnabled = not aimbotEnabled
    elseif input.KeyCode == keybinds.esp then
        espEnabled = not espEnabled
    end
end)

-- Main Loop: Update ESP, Aimbot, and Camera Lock
RunService.RenderStepped:Connect(function()
    -- ESP Management
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[player] then
                    local espBox = Instance.new("BoxHandleAdornment")
                    espBox.Adornee = player.Character.HumanoidRootPart
                    espBox.AlwaysOnTop = true
                    espBox.Size = Vector3.new(4, 6, 0)
                    espBox.ZIndex = 10
                    espBox.Color3 = Color3.fromRGB(255, 0, 0)
                    espBox.Transparency = 0.3
                    espBox.Parent = player.Character
                    espBoxes[player] = espBox
                end
            end
        end
    else
        for _, esp in pairs(espBoxes) do
            if esp then
                esp:Destroy()
            end
        end
        espBoxes = {}
    end

    -- Aimbot Logic
    if aimbotEnabled then
        local target = getClosestTarget()
        if target then
            aimAtTarget(target)
        end
    end

    -- Camera Lock Logic
    if cameraLockEnabled then
        local target = getClosestTarget()
        if target then
            lockCameraToTarget(target)
        end
    end
end)

-- Initialize the UI
setupUI()
