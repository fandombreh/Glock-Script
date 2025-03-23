local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local mouse = player:GetMouse()

-- Create the main ScreenGui
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock"
glockGui.Parent = player:WaitForChild("PlayerGui")
glockGui.ResetOnSpawn = false

-- Main Frame (Clean, centered)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = glockGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

-- Function to create toggles and mode selectors
local function createToggleAndMode(name, yPos)
    local enabled = false
    local mode = "Legit"
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 20)
    label.Position = UDim2.new(0.5, -100, 1, yPos)
    label.BackgroundTransparency = 1
    label.Text = name .. ": OFF"
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = mainFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 30)
    button.Position = UDim2.new(0.5, -90, 1, yPos + 30)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = "Toggle " .. name
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.Parent = mainFrame
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        label.Text = name .. ": " .. (enabled and "ON" or "OFF")
    end)
    
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(0, 200, 0, 20)
    modeLabel.Position = UDim2.new(0.5, -100, 1, yPos + 70)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Text = "Mode: Legit"
    modeLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.TextSize = 16
    modeLabel.Parent = mainFrame
    
    local modeButton = Instance.new("TextButton")
    modeButton.Size = UDim2.new(0, 180, 0, 30)
    modeButton.Position = UDim2.new(0.5, -90, 1, yPos + 100)
    modeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    modeButton.Text = "Switch Mode"
    modeButton.Font = Enum.Font.Gotham
    modeButton.TextSize = 16
    modeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    modeButton.Parent = mainFrame
    
    modeButton.MouseButton1Click:Connect(function()
        mode = (mode == "Legit" and "Blatant" or "Legit")
        modeLabel.Text = "Mode: " .. mode
    end)
    
    return {enabled = function() return enabled end, mode = function() return mode end}
end

local silentAim = createToggleAndMode("Silent Aim", -220)
local triggerBot = createToggleAndMode("Trigger Bot", -120)
local cameraLock = createToggleAndMode("Camera Lock", -20)
local aimbot = createToggleAndMode("Aimbot", 80)

-- Functionality for Silent Aim, Trigger Bot, Camera Lock, and Aimbot
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(targetPos.X, targetPos.Y)).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = v
            end
        end
    end
    return closestPlayer
end

game:GetService("RunService").RenderStepped:Connect(function()
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = camera:WorldToViewportPoint(target.Character.Head.Position)
        
        if silentAim.enabled() then
            local factor = silentAim.mode() == "Legit" and 0.5 or 1
            mousemoverel((headPos.X - mouse.X) * factor, (headPos.Y - mouse.Y) * factor)
        end
        
        if aimbot.enabled() then
            local factor = aimbot.mode() == "Legit" and 0.5 or 1
            mousemoverel((headPos.X - mouse.X) * factor, (headPos.Y - mouse.Y) * factor)
        end
    end
end)
