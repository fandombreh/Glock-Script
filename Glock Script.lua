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
    if target and target.Character then
        local aimPos = getAimPosition(target)
        if aimPos then
            -- Predict position if prediction is enabled
            if predictionEnabled then
                aimPos = predictPosition(target)
            end

            local smoothFactor = blatantMode and 1 or aimbotSmoothness / 10
            local direction = (aimPos - Camera.CFrame.Position).unit
            Camera.CFrame = Camera.CFrame:Lerp(Camera.CFrame * CFrame.new(direction * smoothFactor), 0.2)
        end
    end
end

-- UI Setup
local function setupUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Glock - made by snoopy"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame (Black Background, Sleek look)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 69, 240)
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
    Title.BackgroundColor3 = Color3.fromRGB(98, 12, 219)
    Title.Text = "Glock - made by snoopy"
    Title.TextColor3 = Color3.fromRGB(21, 211, 197)
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

    -- Prediction Mode Toggle Button
    local predictionModeButton = createToggleButton("Toggle Prediction: Off", 460, function()
        predictionEnabled = not predictionEnabled
        if predictionEnabled then
            predictionModeButton.Text = "Toggle Prediction: On"
        else
            predictionModeButton.Text = "Toggle Prediction: Off"
        end
    end)

    -- Blatant Mode Toggle Button
    local blatantModeButton = createToggleButton("Toggle Blatant Mode: Non-Blatant", 510, function()
        blatantMode = not blatantMode
        if blatantMode then
            blatantModeButton.Text = "Toggle Blatant Mode: Blatant"
        else
            blatantModeButton.Text = "Toggle Blatant Mode: Non-Blatant"
        end
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

-- Main Loop to check ESP, Aimbot, and Camera Lock
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if aimbotEnabled then
        local closestTarget = getClosestTarget()
        if closestTarget then
            aimAtTarget(closestTarget)
        end
    end
end)

-- Setup UI
setupUI()
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
    if target and target.Character then
        local aimPos = getAimPosition(target)
        if aimPos then
            -- Predict position if prediction is enabled
            if predictionEnabled then
                aimPos = predictPosition(target)
            end

            local smoothFactor = blatantMode and 1 or aimbotSmoothness / 10
            local direction = (aimPos - Camera.CFrame.Position).unit
            Camera.CFrame = Camera.CFrame:Lerp(Camera.CFrame * CFrame.new(direction * smoothFactor), 0.2)
        end
    end
end

-- UI Setup
local function setupUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Glock - made by snoopy"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame (Black Background, Sleek look)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 69, 240)
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
    Title.BackgroundColor3 = Color3.fromRGB(98, 12, 219)
    Title.Text = "Glock - made by snoopy"
    Title.TextColor3 = Color3.fromRGB(21, 211, 197)
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

    -- Prediction Mode Toggle Button
    local predictionModeButton = createToggleButton("Toggle Prediction: Off", 460, function()
        predictionEnabled = not predictionEnabled
        if predictionEnabled then
            predictionModeButton.Text = "Toggle Prediction: On"
        else
            predictionModeButton.Text = "Toggle Prediction: Off"
        end
    end)

    -- Blatant Mode Toggle Button
    local blatantModeButton = createToggleButton("Toggle Blatant Mode: Non-Blatant", 510, function()
        blatantMode = not blatantMode
        if blatantMode then
            blatantModeButton.Text = "Toggle Blatant Mode: Blatant"
        else
            blatantModeButton.Text = "Toggle Blatant Mode: Non-Blatant"
        end
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

-- Main Loop to check ESP, Aimbot, and Camera Lock
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if aimbotEnabled then
        local closestTarget = getClosestTarget()
        if closestTarget then
            aimAtTarget(closestTarget)
        end
    end
end)

-- Setup UI
setupUI()
