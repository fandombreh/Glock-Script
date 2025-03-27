-- Glock - Made by Snoopy
-- Features: Aimbot Lock, Triggerbot, FOV Circle, ESP, Color Cycling

local glock = {}
glock.name = "Glock - Made by Snoopy"

-- Services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")

-- Settings
local fov = 100
local aimLockEnabled = true
local triggerbotEnabled = true
local espEnabled = true
local colors = {Color3.fromRGB(128, 0, 128), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(173, 216, 230)} -- Purple, Green, Blue, Light Blue
local currentColor = 1
local colorChangeInterval = 0.5 -- seconds between color changes
local nextColorChange = tick()

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
