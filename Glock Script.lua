-- // Glock - made by Snoopy //

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // SETTINGS //
local settings = {
    triggerBotEnabled = false,
    lockAimbotEnabled = false,
    silentAimEnabled = false,
    espEnabled = false,
    fovCircleEnabled = false,
    aimbotSmoothness = 0.2,
    triggerBotSmoothness = 0.2,
    silentAimFOV = 130
}

-- // GUI SETUP //
local GlockGUI = Instance.new("ScreenGui")
GlockGUI.Name = "Glock - made by Snoopy"
GlockGUI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Parent = GlockGUI
MainFrame.Active = true
MainFrame.Draggable = true

-- Function to Create Toggle Buttons
local function createToggleButton(parent, text, settingName, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.Text = text .. ": " .. (settings[settingName] and "ON" or "OFF")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    button.MouseButton1Click:Connect(function()
        settings[settingName] = not settings[settingName]
        button.Text = text .. ": " .. (settings[settingName] and "ON" or "OFF")
    end)
end

createToggleButton(MainFrame, "Aimbot", "lockAimbotEnabled", 50)
createToggleButton(MainFrame, "Silent Aim", "silentAimEnabled", 100)
createToggleButton(MainFrame, "Trigger Bot", "triggerBotEnabled", 150)
createToggleButton(MainFrame, "ESP", "espEnabled", 200)
createToggleButton(MainFrame, "FOV Circle", "fovCircleEnabled", 250)

-- Function to Get Closest Player in FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = settings.silentAimFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (UserInputService:GetMouseLocation() - Vector2.new(headPos.X, headPos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- AIMBOT (Camera Lock)
RunService.RenderStepped:Connect(function()
    if settings.lockAimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPosition = target.Character.Head.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPosition), settings.aimbotSmoothness)
        end
    end
end)

-- SILENT AIM (Bullet Redirection)
RunService.RenderStepped:Connect(function()
    if settings.silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local direction = (headPos - Camera.CFrame.Position).unit
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
        end
    end
end)

-- TRIGGER BOT (Auto-Fire)
RunService.RenderStepped:Connect(function()
    if settings.triggerBotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local ray = Ray.new(Camera.CFrame.Position, (headPos - Camera.CFrame.Position).unit * 100)
            local hit, _ = workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and hit:IsDescendantOf(target.Character) then
                mouse1click()
            end
        end
    end
end)

print("✅ Glock GUI Loaded! Made by Snoopy")

