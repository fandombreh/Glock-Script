local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()

local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local aimbotEnabled = false
local autoLockEnabled = true -- Auto-lock on being shot
local camLockSmoothness = 5
local triggerBotRange = 10
local silentAimStrength = 5
local aimbotSmoothness = 7

local currentTarget = nil
local gunEquipped = false

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Parent = game.CoreGui

-- Main Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 250)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Function to find the closest enemy
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

-- Check if the player has a gun equipped
local function checkGunEquipped()
    if localPlayer.Character then
        local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            gunEquipped = true
        else
            gunEquipped = false
        end
    end
end

-- Cam Lock System (Only when holding a gun)
local function updateCamLock()
    if camLockEnabled and gunEquipped then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), camLockSmoothness / 10)
        end
    end
end

-- Silent Aim System (Only when holding a gun)
local function updateSilentAim()
    if silentAimEnabled and gunEquipped then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), silentAimStrength / 20)
        end
    end
end

-- Trigger Bot System (Only when holding a gun)
local function updateTriggerBot()
    if triggerBotEnabled and gunEquipped then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if (localPlayer.Character.Head.Position - target.Character.Head.Position).Magnitude <= triggerBotRange then
                mouse1click()
            end
        end
    end
end

-- Aimbot System (Locks onto enemies when holding right-click and holding a gun)
local function updateAimbot()
    if aimbotEnabled and gunEquipped and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), aimbotSmoothness / 10)
        end
    end
end

-- Auto Lock System (Locks onto the player that shot you)
local function autoLock(target)
    if autoLockEnabled and gunEquipped then
        currentTarget = target
        camLockEnabled = true
    end
end

-- Detect when a player is hit
local function detectHit()
    localPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    autoLock(player)
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(updateSilentAim)
RunService.RenderStepped:Connect(updateCamLock)
RunService.RenderStepped:Connect(updateTriggerBot)
RunService.RenderStepped:Connect(updateAimbot)

-- Constantly check if a gun is equipped
RunService.RenderStepped:Connect(checkGunEquipped)

-- Detect hits
detectHit()

-- Function to create toggle buttons
local function createToggleButton(name, toggleVar, yOffset)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 25, 0, yOffset) -- Properly spaced
    button.Text = name .. " [OFF]"
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = mainFrame

    button.MouseButton1Click:Connect(function()
        if toggleVar == "camLock" then
            camLockEnabled = not camLockEnabled
            button.Text = "Cam Lock [" .. (camLockEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "silentAim" then
            silentAimEnabled = not silentAimEnabled
            button.Text = "Silent Aim [" .. (silentAimEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "triggerBot" then
            triggerBotEnabled = not triggerBotEnabled
            button.Text = "Trigger Bot [" .. (triggerBotEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "aimbot" then
            aimbotEnabled = not aimbotEnabled
            button.Text = "Aimbot [" .. (aimbotEnabled and "ON" or "OFF") .. "]"
        elseif toggleVar == "autoLock" then
            autoLockEnabled = not autoLockEnabled
            button.Text = "Auto Lock [" .. (autoLockEnabled and "ON" or "OFF") .. "]"
        end
    end)
end

-- Create buttons
createToggleButton("Cam Lock", "camLock", 10)
createToggleButton("Silent Aim", "silentAim", 60)
createToggleButton("Trigger Bot", "triggerBot", 110)
createToggleButton("Aimbot", "aimbot", 160)
createToggleButton("Auto Lock", "autoLock", 210)
