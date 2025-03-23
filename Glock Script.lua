local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Mouse = localPlayer:GetMouse()

local triggerBotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local triggerBotRange = 15
local silentAimStrength = 100

-- 🎯 Function to get closest enemy
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

-- 🔫 Silent Aim Hook (Fixes Raycasting)
local mt = getrawmetatable(game)
if mt then
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if silentAimEnabled and method == "FindPartOnRayWithIgnoreList" then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local direction = (target.Character.Head.Position - camera.CFrame.Position).unit * silentAimStrength
                args[1] = Ray.new(camera.CFrame.Position, direction)
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- 🔥 Trigger Bot (Auto-Shoot)
local triggerBotConnection
local function toggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    print("Trigger Bot:", triggerBotEnabled)
    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local distance = (target.Character.Head.Position - camera.CFrame.Position).Magnitude
                if distance < triggerBotRange then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end)
    else
        if triggerBotConnection then
            triggerBotConnection:Disconnect()
            triggerBotConnection = nil
        end
    end
end

-- 🔵 ESP (Highlights Enemies)
local espConnections = {}
local function toggleESP()
    espEnabled = not espEnabled
    for _, connection in pairs(espConnections) do
        connection:Disconnect()
    end
    table.clear(espConnections)

    if espEnabled then
        local connection = RunService.RenderStepped:Connect(function()
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local character = player.Character
                    local highlight = character:FindFirstChild("Highlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Parent = character
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.Adornee = character
                    end
                end
            end
        end)
        table.insert(espConnections, connection)
    end
end

-- 🛠️ UI Setup
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

createButton("Toggle Silent Aim", mainFrame, function()
    silentAimEnabled = not silentAimEnabled
    print("Silent Aim:", silentAimEnabled)
end, startY)

createButton("Toggle Trigger Bot", mainFrame, toggleTriggerBot, startY + buttonSpacing)
createButton("Toggle ESP", mainFrame, toggleESP, startY + buttonSpacing * 2)
