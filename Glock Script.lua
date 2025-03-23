local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()
local ESPEnabled, FOVCircleEnabled, camLockEnabled, triggerBotEnabled, silentAimEnabled = false, false, false, false, false
local camLockSmoothness, triggerBotRange, silentAimStrength, FOVRadius = 5, 10, 5, 150

-- GUI Setup
glockGui = Instance.new("ScreenGui")
glockGui.Parent = game.CoreGui
glockGui.Name = "Glock - made by snoopy"

-- Main UI Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true

-- Dragging Functionality
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Function to Check If Player Has a Gun
local function hasGun()
    local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
    return tool and tool:FindFirstChild("Handle")
end

-- Function to Find Closest Player Within FOV
local function getClosestPlayer()
    local closest, shortestDist = nil, math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local dist = (mousePos - Vector2.new(headPos.X, headPos.Y)).Magnitude
            if onScreen and dist < shortestDist and dist <= FOVRadius then
                closest, shortestDist = player, dist
            end
        end
    end
    return closest
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible, fovCircle.Radius = false, FOVRadius
fovCircle.Color, fovCircle.Thickness = Color3.fromRGB(255, 255, 0), 1
RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    fovCircle.Visible = FOVCircleEnabled
end)

-- ESP Function
local function createESP(player)
    local box = Drawing.new("Square")
    box.Color, box.Thickness, box.Filled = Color3.fromRGB(255, 0, 0), 1, false
    RunService.RenderStepped:Connect(function()
        if ESPEnabled and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                box.Position = Vector2.new(headPos.X - 25, headPos.Y - 25)
                box.Size, box.Visible = Vector2.new(50, 50), true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= localPlayer then createESP(player) end
end
game.Players.PlayerAdded:Connect(createESP)

-- Aim & Lock Functions
local function updateCamLock()
    if camLockEnabled and hasGun() then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), camLockSmoothness / 10)
        end
    end
end

local function updateSilentAim()
    if silentAimEnabled and hasGun() then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character.Head.Position), silentAimStrength / 20)
        end
    end
end

local function updateTriggerBot()
    if triggerBotEnabled and hasGun() then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if (localPlayer.Character.Head.Position - target.Character.Head.Position).Magnitude <= triggerBotRange then
                mouse1click()
            end
        end
    end
end

RunService.RenderStepped:Connect(updateSilentAim)
RunService.RenderStepped:Connect(updateCamLock)
RunService.RenderStepped:Connect(updateTriggerBot)

-- UI Buttons
table.insert({"Cam Lock", "Silent Aim", "Trigger Bot", "ESP", "FOV Circle"}, function(name)
    local button = Instance.new("TextButton")
    button.Size, button.Text, button.Parent = UDim2.new(0, 150, 0, 40), "Toggle "..name, mainFrame
    button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)
    button.MouseButton1Click:Connect(function()
        if name == "Cam Lock" then camLockEnabled = not camLockEnabled
        elseif name == "Silent Aim" then silentAimEnabled = not silentAimEnabled
        elseif name == "Trigger Bot" then triggerBotEnabled = not triggerBotEnabled
        elseif name == "ESP" then ESPEnabled = not ESPEnabled
        elseif name == "FOV Circle" then FOVCircleEnabled = not FOVCircleEnabled
        end
    end)
end)
