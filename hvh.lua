local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Anti-Detection Backend
local mt = getrawmetatable(game)
local oldnamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and tostring(self) == "MainEvent" then
        if args[1] == "Cheese" or args[1] == "Block" then
            return
        end
    end
    
    return oldnamecall(self, ...)
end)

setreadonly(mt, true)

-- HVH Variables
local Config = {
    SilentAim = false,
    SilentFOV = 120,
    ESP = false,
    AntiAim = false,
    Resolver = false,
    Rage = false,
    Legit = false,
    TriggerBot = false,
    HitboxExpand = false,
    HBSize = 2
}

-- ESP Backend
local ESPObjects = {}
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local Billboard = Instance.new("BillboardGui")
    local NameLabel = Instance.new("TextLabel")
    local HealthBar = Instance.new("Frame")
    local HealthBarBG = Instance.new("Frame")
    
    Billboard.Name = "ESP"
    Billboard.Parent = player.Character.Head
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    Billboard.Adornee = player.Character.Head
    Billboard.AlwaysOnTop = true
    
    NameLabel.Parent = Billboard
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = player.Name
    NameLabel.TextColor3 = Color3.new(1, 1, 1)
    NameLabel.TextStrokeTransparency = 0
    NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 14
    
    HealthBarBG.Parent = Billboard
    HealthBarBG.Size = UDim2.new(1, -6, 0, 4)
    HealthBarBG.Position = UDim2.new(0, 3, 0.6, 0)
    HealthBarBG.BackgroundColor3 = Color3.new(0, 0, 0)
    HealthBarBG.BorderSizePixel = 0
    
    HealthBar.Parent = HealthBarBG
    HealthBar.Size = UDim2.new(1, 0, 1, 0)
    HealthBar.BackgroundColor3 = Color3.new(0, 1, 0)
    HealthBar.BorderSizePixel = 0
    
    ESPObjects[player] = {Billboard, NameLabel, HealthBar, HealthBarBG}
end

local function UpdateESP()
    for player, objects in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            objects[3].Size = UDim2.new(healthPercent, 0, 1, 0)
            objects[3].BackgroundColor3 = Color3.fromRGB(255 * (1-healthPercent), 255 * healthPercent, 0)
        else
            objects[1]:Destroy()
            ESPObjects[player] = nil
        end
    end
end

-- Silent Aim Backend (Advanced Prediction + Resolver)
local function GetClosestPlayer()
    local closest, dist = nil, Config.SilentFOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if onScreen and distance < dist then
                closest = player
                dist = distance
            end
        end
    end
    return closest
end

local PredictionCache = {}
local function PredictPosition(target)
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local rootPart = target.Character.HumanoidRootPart
    local velocity = rootPart.Velocity
    local ping = (2 * 1000) / 1000 -- Simulated ping compensation
    
    local prediction = rootPart.Position + (velocity * (ping / 1000))
    
    if Config.Resolver then
        -- Basic resolver (detects common anti-aim patterns)
        local yaw = rootPart.CFrame:ToEulerAnglesYXZ()
        prediction = prediction + Vector3.new(math.sin(tick() * 5) * 2, 0, math.cos(tick() * 5) * 2)
    end
    
    PredictionCache[target] = prediction
    return prediction
end

-- Hook GetMouseHit for Silent Aim
local oldGetMouseHit = Camera.GetMouseHit
Camera.GetMouseHit = function(self)
    if Config.SilentAim and Players.LocalPlayer.Character then
        local target = GetClosestPlayer()
        if target then
            local predictedPos = PredictPosition(target)
            if predictedPos then
                return CFrame.new(predictedPos)
            end
        end
    end
    return oldGetMouseHit(self)
end

-- Anti-Aim Backend
local AntiAimConnection
local function StartAntiAim()
    if AntiAimConnection then AntiAimConnection:Disconnect() end
    
    AntiAimConnection = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            if Config.AntiAim then
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(math.sin(tick() * 10) * 180), 0)
                rootPart.Velocity = Vector3.new(math.sin(tick() * 7) * 16, rootPart.Velocity.Y, math.cos(tick() * 7) * 16)
            end
        end
    end)
end

-- Hitbox Expansion
local HitboxConnections = {}
local function ExpandHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local connection
                    connection = RunService.Heartbeat:Connect(function()
                        if part.Parent and Config.HitboxExpand then
                            part.Size = part.Size * Config.HBSize
                            part.Transparency = 0.7
                        else
                            connection:Disconnect()
                            HitboxConnections[player] = nil
                        end
                    end)
                    HitboxConnections[player] = connection
                end
            end
        end
    end
end

-- TriggerBot
local TriggerConnection
local function StartTriggerBot()
    if TriggerConnection then TriggerConnection:Disconnect() end
    
    TriggerConnection = RunService.Heartbeat:Connect(function()
        if Config.TriggerBot then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                -- Fire weapon remote (Da Hood specific)
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local remote = tool:FindFirstChild("Remote")
                    if remote then
                        remote:FireServer("Shoot", target.Character.Head.Position)
                    end
                end
            end
        end
    end)
end

-- GUI Creation (Rayfield Interface)
local Library = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Library:CreateWindow({
    Name = "HVH Gui Testing ENV",
    LoadingTitle = "Loading Your Stuff",
    LoadingSubtitle = "by @thismorechaos",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HVHGUITEST",
        FileName = "Config"
    }
})

local RageTab = Window:CreateTab("Rage", 4483362458)
local LegitTab = Window:CreateTab("Legit", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Rage Tab
RageTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value)
        Config.SilentAim = Value
    end
})

RageTab:CreateSlider({
    Name = "Silent FOV",
    Range = {0, 500},
    Increment = 5,
    CurrentValue = 120,
    Flag = "SilentFOV",
    Callback = function(Value)
        Config.SilentFOV = Value
    end
})

RageTab:CreateToggle({
    Name = "Anti Aim",
    CurrentValue = false,
    Flag = "AntiAim",
    Callback = function(Value)
        Config.AntiAim = Value
        StartAntiAim()
    end
})

RageTab:CreateToggle({
    Name = "Resolver",
    CurrentValue = false,
    Flag = "Resolver",
    Callback = function(Value)
        Config.Resolver = Value
    end
})

RageTab:CreateToggle({
    Name = "Hitbox Expand",
    CurrentValue = false,
    Flag = "HitboxExpand",
    Callback = function(Value)
        Config.HitboxExpand = Value
        ExpandHitboxes()
    end
})

RageTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 2,
    Flag = "HBSize",
    Callback = function(Value)
        Config.HBSize = Value
    end
})

-- Legit Tab
LegitTab:CreateToggle({
    Name = "Trigger Bot",
    CurrentValue = false,
    Flag = "TriggerBot",
    Callback = function(Value)
        Config.TriggerBot = Value
        StartTriggerBot()
    end
})

-- Visuals Tab
VisualsTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        Config.ESP = Value
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateESP(player)
                end
            end
        else
            for _, objects in pairs(ESPObjects) do
                objects[1]:Destroy()
            end
            ESPObjects = {}
        end
    end
})

-- Misc Tab
MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Connections
RunService.Heartbeat:Connect(UpdateESP)
RunService.Heartbeat:Connect(function()
    if Config.HitboxExpand then
        ExpandHitboxes()
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Config.ESP then
            CreateESP(player)
        end
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        CreateESP(player)
    end
    player.CharacterAdded:Connect(function()
        if Config.ESP then
            CreateESP(player)
        end
    end)
end

Library:Notify({
    Title = "hvh gui loaded",
    Content = "be safe with this bro",
    Duration = 5,
    Image = 4483362458
})
