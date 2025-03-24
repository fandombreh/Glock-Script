-- Load Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Table
local GlockGUI = {
    SilentAim = false,
    ESP = false,
    Speedhack = false,
    Lock = false,
    Target = nil
}

-- Function to find closest player
local function getClosestPlayer()
    local closest, distance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if magnitude < distance then
                    closest, distance = player, magnitude
                end
            end
        end
    end
    return closest
end

-- Silent Aim Function
RunService.RenderStepped:Connect(function()
    if GlockGUI.SilentAim and GlockGUI.Target then
        local head = GlockGUI.Target.Character and GlockGUI.Target.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)

-- ESP Function
RunService.RenderStepped:Connect(function()
    if GlockGUI.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local billboard = head:FindFirstChild("ESP")
                if not billboard then
                    billboard = Instance.new("BillboardGui", head)
                    billboard.Name = "ESP"
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.AlwaysOnTop = true
                    
                    local text = Instance.new("TextLabel", billboard)
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = player.Name
                    text.TextColor3 = Color3.fromRGB(255, 0, 0)
                    text.TextStrokeTransparency = 0.5
                end
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("ESP")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end
end)

-- Speedhack Function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift then
        if GlockGUI.Speedhack then
            LocalPlayer.Character.Humanoid.WalkSpeed = 50
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Lock Function
RunService.RenderStepped:Connect(function()
    if GlockGUI.Lock then
        GlockGUI.Target = getClosestPlayer()
    else
        GlockGUI.Target = nil
    end
end)

-- GUI Implementation (Basic Toggle System)
local function toggleFeature(feature)
    GlockGUI[feature] = not GlockGUI[feature]
    print(feature .. " toggled: " .. tostring(GlockGUI[feature]))
end

-- Example Keybinds (Change these as needed)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then toggleFeature("SilentAim") end
    if input.KeyCode == Enum.KeyCode.F2 then toggleFeature("ESP") end
    if input.KeyCode == Enum.KeyCode.F3 then toggleFeature("Speedhack") end
    if input.KeyCode == Enum.KeyCode.F4 then toggleFeature("Lock") end
end)

-- Full GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local Tabs = {
    "Silent Aim", "ESP", "Speedhack", "Lock"
}

local TabButtons = {}
local TabFrames = {}

for i, tabName in ipairs(Tabs) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0, (i - 1) * 100, 0, 0)
    button.Text = tabName
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = MainFrame
    TabButtons[tabName] = button
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, -30)
    frame.Position = UDim2.new(0, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Visible = (i == 1) -- Show first tab by default
    frame.Parent = MainFrame
    TabFrames[tabName] = frame
end

local function switchTab(tabName)
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == tabName)
    end
end

for tabName, button in pairs(TabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- Feature Buttons inside Tabs
local featureButtons = {
    {"Toggle Silent Aim", "SilentAim", "Silent Aim"},
    {"Toggle ESP", "ESP", "ESP"},
    {"Toggle Speedhack", "Speedhack", "Speedhack"},
    {"Toggle Lock", "Lock", "Lock"}
}

for _, info in ipairs(featureButtons) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0.5, -100, 0.5, -25)
    button.Text = info[1]
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = TabFrames[info[3]]
    button.MouseButton1Click:Connect(function()
        toggleFeature(info[2])
    end)
end
