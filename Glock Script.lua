-- Roblox Script for Glock GUI with Silent Aim, ESP, Speedhacks, Lock

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui

-- Tabs
local tabButtonFrame = Instance.new("Frame")
tabButtonFrame.Size = UDim2.new(0, 100, 1, 0)
tabButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabButtonFrame.BorderSizePixel = 0
tabButtonFrame.Position = UDim2.new(0, 0, 0, 0)
tabButtonFrame.Parent = mainFrame

local silentAimTab = Instance.new("TextButton")
silentAimTab.Size = UDim2.new(1, 0, 0, 40)
silentAimTab.Position = UDim2.new(0, 0, 0, 0)
silentAimTab.Text = "Silent Aim"
silentAimTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
silentAimTab.TextColor3 = Color3.fromRGB(255, 255, 255)
silentAimTab.Parent = tabButtonFrame

local espTab = Instance.new("TextButton")
espTab.Size = UDim2.new(1, 0, 0, 40)
espTab.Position = UDim2.new(0, 0, 0, 40)
espTab.Text = "ESP"
espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
espTab.Parent = tabButtonFrame

local speedhackTab = Instance.new("TextButton")
speedhackTab.Size = UDim2.new(1, 0, 0, 40)
speedhackTab.Position = UDim2.new(0, 0, 0, 80)
speedhackTab.Text = "Speedhacks"
speedhackTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedhackTab.TextColor3 = Color3.fromRGB(255, 255, 255)
speedhackTab.Parent = tabButtonFrame

local lockTab = Instance.new("TextButton")
lockTab.Size = UDim2.new(1, 0, 0, 40)
lockTab.Position = UDim2.new(0, 0, 0, 120)
lockTab.Text = "Lock"
lockTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
lockTab.TextColor3 = Color3.fromRGB(255, 255, 255)
lockTab.Parent = tabButtonFrame

-- Tab Content Frames
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0, 400, 1, 0)
contentFrame.Position = UDim2.new(0, 100, 0, 0)
contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Silent Aim Section
local silentAimFrame = Instance.new("Frame")
silentAimFrame.Size = UDim2.new(1, 0, 1, 0)
silentAimFrame.BackgroundTransparency = 1
silentAimFrame.Visible = false
silentAimFrame.Parent = contentFrame

local silentAimToggle = Instance.new("TextButton")
silentAimToggle.Size = UDim2.new(0, 200, 0, 40)
silentAimToggle.Position = UDim2.new(0, 100, 0, 20)
silentAimToggle.Text = "Enable Silent Aim"
silentAimToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
silentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
silentAimToggle.Parent = silentAimFrame

-- ESP Section
local espFrame = Instance.new("Frame")
espFrame.Size = UDim2.new(1, 0, 1, 0)
espFrame.BackgroundTransparency = 1
espFrame.Visible = false
espFrame.Parent = contentFrame

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 200, 0, 40)
espToggle.Position = UDim2.new(0, 100, 0, 20)
espToggle.Text = "Enable ESP"
espToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.Parent = espFrame

-- Speedhacks Section
local speedhackFrame = Instance.new("Frame")
speedhackFrame.Size = UDim2.new(1, 0, 1, 0)
speedhackFrame.BackgroundTransparency = 1
speedhackFrame.Visible = false
speedhackFrame.Parent = contentFrame

local speedhackToggle = Instance.new("TextButton")
speedhackToggle.Size = UDim2.new(0, 200, 0, 40)
speedhackToggle.Position = UDim2.new(0, 100, 0, 20)
speedhackToggle.Text = "Enable Speedhack"
speedhackToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedhackToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
speedhackToggle.Parent = speedhackFrame

-- Lock Section
local lockFrame = Instance.new("Frame")
lockFrame.Size = UDim2.new(1, 0, 1, 0)
lockFrame.BackgroundTransparency = 1
lockFrame.Visible = false
lockFrame.Parent = contentFrame

local lockToggle = Instance.new("TextButton")
lockToggle.Size = UDim2.new(0, 200, 0, 40)
lockToggle.Position = UDim2.new(0, 100, 0, 20)
lockToggle.Text = "Enable Lock"
lockToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
lockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
lockToggle.Parent = lockFrame

-- Toggle Functions
silentAimTab.MouseButton1Click:Connect(function()
    silentAimFrame.Visible = true
    espFrame.Visible = false
    speedhackFrame.Visible = false
    lockFrame.Visible = false
end)

espTab.MouseButton1Click:Connect(function()
    silentAimFrame.Visible = false
    espFrame.Visible = true
    speedhackFrame.Visible = false
    lockFrame.Visible = false
end)

speedhackTab.MouseButton1Click:Connect(function()
    silentAimFrame.Visible = false
    espFrame.Visible = false
    speedhackFrame.Visible = true
    lockFrame.Visible = false
end)

lockTab.MouseButton1Click:Connect(function()
    silentAimFrame.Visible = false
    espFrame.Visible = false
    speedhackFrame.Visible = false
    lockFrame.Visible = true
end)

-- Silent Aim Logic (Simple Example)
silentAimToggle.MouseButton1Click:Connect(function()
    local enableSilentAim = not silentAimToggle.Text:match("Disable")
    if enableSilentAim then
        silentAimToggle.Text = "Disable Silent Aim"
        -- Add Silent Aim Logic here (target head, top-tier accuracy)
    else
        silentAimToggle.Text = "Enable Silent Aim"
        -- Disable Silent Aim Logic
    end
end)

-- ESP Logic (simple example)
espToggle.MouseButton1Click:Connect(function()
    local enableESP = not espToggle.Text:match("Disable")
    if enableESP then
        espToggle.Text = "Disable ESP"
        -- Add ESP Logic here
    else
        espToggle.Text = "Enable ESP"
        -- Disable ESP Logic
    end
end)

-- Speedhack Logic
speedhackToggle.MouseButton1Click:Connect(function()
    local enableSpeedhack = not speedhackToggle.Text:match("Disable")
    if enableSpeedhack then
        speedhackToggle.Text = "Disable Speedhack"
        -- Add Speedhack Logic here
    else
        speedhackToggle.Text = "Enable Speedhack"
        -- Disable Speedhack Logic
    end
end)

-- Lock Logic (Aiming Lock on Enemy Head)
lockToggle.MouseButton1Click:Connect(function()
    local enableLock = not lockToggle.Text:match("Disable")
    if enableLock then
        lockToggle.Text = "Disable Lock"
        -- Implement Top-Tier Lock Logic (aim at head with high accuracy)
        Mouse.Move:Connect(function()
            -- Example of Locking to Target's Head
            local target = nil -- Find closest target
            if target then
                local headPos = target.Head.Position
                -- Aim and shoot at the head
            end
        end)
    else
        lockToggle.Text = "Enable Lock"
        -- Disable Lock Logic
    end
end)
