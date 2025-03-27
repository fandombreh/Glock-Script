local glock = {}
glock.name = "Glock - Made by Snoopy"

-- Services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local guiService = game:GetService("StarterGui")
local player = players.LocalPlayer

-- Settings
local fov = 100
local aimLockEnabled = true
local triggerbotEnabled = true
local espEnabled = true
local colors = {Color3.fromRGB(128, 0, 128), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(173, 216, 230)} -- Purple, Green, Blue, Light Blue
local currentColor = 1
local colorChangeInterval = 0.5 -- seconds between color changes
local nextColorChange = tick()

-- Create the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleAimbotBtn = Instance.new("TextButton")
toggleAimbotBtn.Size = UDim2.new(0, 200, 0, 50)
toggleAimbotBtn.Position = UDim2.new(0, 50, 0, 50)
toggleAimbotBtn.Text = "Toggle Aimbot Lock"
toggleAimbotBtn.Parent = screenGui

local toggleTriggerbotBtn = Instance.new("TextButton")
toggleTriggerbotBtn.Size = UDim2.new(0, 200, 0, 50)
toggleTriggerbotBtn.Position = UDim2.new(0, 50, 0, 110)
toggleTriggerbotBtn.Text = "Toggle Triggerbot"
toggleTriggerbotBtn.Parent = screenGui

local toggleESPBtn = Instance.new("TextButton")
toggleESPBtn.Size = UDim2.new(0, 200, 0, 50)
toggleESPBtn.Position = UDim2.new(0, 50, 0, 170)
toggleESPBtn.Text = "Toggle ESP"
toggleESPBtn.Parent = screenGui

local toggleFOVBtn = Instance.new("TextButton")
toggleFOVBtn.Size = UDim2.new(0, 200, 0, 50)
toggleFOVBtn.Position = UDim2.new(0, 50, 0, 230)
toggleFOVBtn.Text = "Toggle FOV Circle"
toggleFOVBtn.Parent = screenGui

-- ESP Functionality
function glock:drawESP(target)
    if not target then return end
    local espBox = Drawing.new("Text")
    espBox.Text = target.Name
    espBox.Size = 18
    espBox.Center = true
    espBox.Color = colors[currentColor]
    espBox.Position = Vector2.new(target.Character.Head.Position.X, target.Character.Head.Position.Y)
    espBox.Visible = true
    return espBox
end

-- Aimbot Lock Functionality
function glock:aimAt(target)
    if not target then return end
    local camera = workspace.CurrentCamera
    local targetPosition = target.Character.Head.Position
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
end

-- Triggerbot Functionality
function glock:triggerbot(target)
    if triggerbotEnabled and target then
        local mouse = players.LocalPlayer:GetMouse()
        if mouse.Target == target.Character.Head then
            mouse1click()
        end
    end
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fov
fovCircle.Color = colors[currentColor]
fovCircle.Filled = false
fovCircle.Thickness = 2
fovCircle.Transparency = 1
fovCircle.Visible = true

-- Update FOV Circle Position
function glock:updateFOV()
    local mouse = players.LocalPlayer:GetMouse()
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
end

-- Handle button clicks
toggleAimbotBtn.MouseButton1Click:Connect(function()
    aimLockEnabled = not aimLockEnabled
    toggleAimbotBtn.Text = aimLockEnabled and "Disable Aimbot Lock" or "Enable Aimbot Lock"
end)

toggleTriggerbotBtn.MouseButton1Click:Connect(function()
    triggerbotEnabled = not triggerbotEnabled
    toggleTriggerbotBtn.Text = triggerbotEnabled and "Disable Triggerbot" or "Enable Triggerbot"
end)

toggleESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleESPBtn.Text = espEnabled and "Disable ESP" or "Enable ESP"
end)

toggleFOVBtn.MouseButton1Click:Connect(function()
    fovCircle.Visible = not fovCircle.Visible
    toggleFOVBtn.Text = fovCircle.Visible and "Hide FOV Circle" or "Show FOV Circle"
end)

-- Main Loop
runService.RenderStepped:Connect(function()
    local localPlayer = players.LocalPlayer
    local mouse = localPlayer:GetMouse()
    local target

    -- ESP and Aimbot
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local distance = (localPlayer.Character.Head.Position - player.Character.Head.Position).Magnitude
            if distance < fov then
                target = player
                if aimLockEnabled then
                    glock:aimAt(target)
                end
                if espEnabled then
                    glock:drawESP(target)
                end
            end
        end
    end

    -- Triggerbot
    if target then
        glock:triggerbot(target)
    end

    -- Update FOV Circle
    glock:updateFOV()

    -- Handle color cycling
    if tick() >= nextColorChange then
        currentColor = currentColor % #colors + 1
        fovCircle.Color = colors[currentColor]
        nextColorChange = tick() + colorChangeInterval
    end
end)

return glock
