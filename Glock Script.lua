local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = localPlayer:GetMouse()

local camLockEnabled = false
local triggerBotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local fovCircleEnabled = true
local triggerBotRange = 15
local silentAimStrength = 100  -- Higher value = more accurate silent aim
local fovSize = 100

-- UI Setup
local glockGui = Instance.new("ScreenGui")
glockGui.Name = "Glock - made by snoopy"
glockGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = glockGui
mainFrame.Active = true
mainFrame.Draggable = true

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Radius = fovSize
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Visible = fovCircleEnabled

RunService.RenderStepped:Connect(function()
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Visible = fovCircleEnabled
end)

-- Function to get closest player
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = fovSize
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

-- Silent Aim Function
local function silentAim()
    if not silentAimEnabled then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
    end
end

-- ESP Function
local espConnections = {}
local function toggleESP()
    if not espEnabled then
        for _, conn in pairs(espConnections) do conn:Disconnect() end
        espConnections = {}
        for _, v in pairs(game.Workspace:GetChildren()) do
            if v:IsA("Highlight") then v:Destroy() end
        end
        return
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Parent = player.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            table.insert(espConnections, player.Character.ChildRemoved:Connect(function(child)
                if child == highlight then highlight:Destroy() end
            end))
        end
    end
end

-- UI Button Creator
local function createButton(text, parent, callback, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, position)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

local buttonSpacing = 45
local startY = 10

-- Silent Aim Toggle
createButton("Toggle Silent Aim", mainFrame, function()
    silentAimEnabled = not silentAimEnabled
    print("Silent Aim:", silentAimEnabled)
end, startY)

-- Trigger Bot Toggle
local triggerBotConnection
createButton("Toggle Trigger Bot", mainFrame, function()
    triggerBotEnabled = not triggerBotEnabled
    print("Trigger Bot:", triggerBotEnabled)

    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local distance = (target.Character.Head.Position - camera.CFrame.Position).Magnitude
                if distance < triggerBotRange then
                    mouse1click()
                end
            end
        end)
    else
        if triggerBotConnection then
            triggerBotConnection:Disconnect()
            triggerBotConnection = nil
        end
    end
end, startY + buttonSpacing)

-- ESP Toggle
createButton("Toggle ESP", mainFrame, function()
    espEnabled = not espEnabled
    toggleESP()
    print("ESP:", espEnabled)
end, startY + buttonSpacing * 2)

-- FOV Circle Toggle
createButton("Toggle FOV Circle", mainFrame, function()
    fovCircleEnabled = not fovCircleEnabled
    fovCircle.Visible = fovCircleEnabled
    print("FOV Circle:", fovCircleEnabled)
end, startY + buttonSpacing * 3)

-- Hook Silent Aim into Shooting Events
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if silentAimEnabled and method == "FindPartOnRayWithIgnoreList" then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            args[1] = Ray.new(camera.CFrame.Position, (target.Character.Head.Position - camera.CFrame.Position).unit * silentAimStrength)
        end
    end
    return oldNamecall(self, unpack(args))
end)
