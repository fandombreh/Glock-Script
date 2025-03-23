-- Glock Script for Da Hood with a Clean GUI
-- Updated with improvements for clarity and functionality

local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Create the main ScreenGui
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock"
glockGui.Parent = player:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false

-- Main Frame (Clean, centered)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = glockGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 40)
tabBar.Position = UDim2.new(0, 10, 0, 10)
tabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 8)
tabBarCorner.Parent = tabBar

-- Function to create tab buttons
local function createTabButton(parent, text, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, -5, 1, 0)
    button.Position = position
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 18
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Parent = parent

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    return button
end

local cameraLockTab = createTabButton(tabBar, "Camera Lock", UDim2.new(0, 0, 0, 0))
local triggerbotTab = createTabButton(tabBar, "Triggerbot", UDim2.new(0.5, 5, 0, 0))

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentFrameCorner = Instance.new("UICorner")
contentFrameCorner.CornerRadius = UDim.new(0, 8)
contentFrameCorner.Parent = contentFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, -10)
statusLabel.Position = UDim2.new(0, 5, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.TextWrapped = true
statusLabel.Text = "Welcome to Glock Script"
statusLabel.Parent = contentFrame

local smoothnessBox = Instance.new("TextBox")
smoothnessBox.Size = UDim2.new(0, 180, 0, 30)
smoothnessBox.Position = UDim2.new(0.5, -90, 1, -40)
smoothnessBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
smoothnessBox.BorderSizePixel = 0
smoothnessBox.Text = "Smoothness (0-1)"
smoothnessBox.Font = Enum.Font.Gotham
smoothnessBox.TextSize = 16
smoothnessBox.TextColor3 = Color3.fromRGB(230, 230, 230)
smoothnessBox.Parent = mainFrame

local smoothnessBoxCorner = Instance.new("UICorner")
smoothnessBoxCorner.CornerRadius = UDim.new(0, 6)
smoothnessBoxCorner.Parent = smoothnessBox

-- Default states
local cameraLockEnabled = false
local triggerbotEnabled = false
local smoothSpeed = 0.2

-- Helper function: Reset placeholder
local function resetPlaceholder()
    smoothnessBox.Text = "Smoothness (0-1)"
end

smoothnessBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = tonumber(smoothnessBox.Text)
        if input and input >= 0 and input <= 1 then
            smoothSpeed = input
            statusLabel.Text = "Smoothness set to " .. smoothSpeed
        else
            smoothnessBox.Text = "Invalid"
            resetPlaceholder()
        end
    end
end)

-- Optimized Camera Lock and Triggerbot toggles
cameraLockTab.MouseButton1Click:Connect(function()
    cameraLockEnabled = not cameraLockEnabled
    statusLabel.Text = cameraLockEnabled and "Camera Lock: ON" or "Camera Lock: OFF"
    cameraLockTab.BackgroundColor3 = cameraLockEnabled and Color3.fromRGB(90, 90, 90) or Color3.fromRGB(60, 60, 60)
    
    -- Example: Camera Lock Logic
    if cameraLockEnabled then
        -- Example: Lock the camera position to the player's character position
        local targetPosition = player.Character.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(targetPosition)
    end
end)

triggerbotTab.MouseButton1Click:Connect(function()
    triggerbotEnabled = not triggerbotEnabled
    statusLabel.Text = triggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
    triggerbotTab.BackgroundColor3 = triggerbotEnabled and Color3.fromRGB(90, 90, 90) or Color3.fromRGB(60, 60, 60)
    
    -- Example: Triggerbot Logic (simple version)
    if triggerbotEnabled then
        -- Placeholder for triggerbot functionality
        -- This could include raycasting or other methods to detect and automatically shoot enemies
        statusLabel.Text = statusLabel.Text .. "\nTriggerbot active!"
    end
end)

-- Additional suggestions:
-- - Test performance with multiple players
-- - Ensure the script remains compliant with platform rules
-- - Use MouseButton1Click responsibly
