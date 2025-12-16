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

-- Configuration
local Config = {
    SilentAim = false,
    SilentFOV = 120,
    ESP = false,
    AntiAim = false,
    Resolver = false,
    TriggerBot = false,
    CamLock = false,
    CamLockSmoothness = 0.2,
    Fly = false,
    FlySpeed = 50,
    NoClip = false
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

-- Silent Aim Backend
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

local function PredictPosition(target)
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local rootPart = target.Character.HumanoidRootPart
    local velocity = rootPart.Velocity
    local ping = (2 * 1000) / 1000
    local prediction = rootPart.Position + (velocity * (ping / 1000))
    
    if Config.Resolver then
        local yaw = rootPart.CFrame:ToEulerAnglesYXZ()
        prediction = prediction + Vector3.new(math.sin(tick() * 5) * 2, 0, math.cos(tick() * 5) * 2)
    end
    
    return prediction
end

-- Silent Aim Hook
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        if Config.SilentAim then
            local target = GetClosestPlayer()
            if target then
                local predictedPos = PredictPosition(target)
                if predictedPos then
                    local cameraCFrame = Camera.CFrame
                    local newCFrame = CFrame.lookAt(cameraCFrame.Position, predictedPos)
                    Camera.CFrame = newCFrame
                    task.wait(0.1)
                    Camera.CFrame = cameraCFrame
                end
            end
        end
    end
end)

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

-- CamLock
local CamLockConnection
local CamLockTarget = nil

local function StartCamLock()
    if CamLockConnection then CamLockConnection:Disconnect() end
    
    CamLockConnection = RunService.RenderStepped:Connect(function()
        if Config.CamLock and CamLockTarget and CamLockTarget.Character and CamLockTarget.Character:FindFirstChild("Head") then
            local targetPos = CamLockTarget.Character.Head.Position
            local currentCF = Camera.CFrame
            local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, Config.CamLockSmoothness)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q and Config.CamLock then
        CamLockTarget = GetClosestPlayer()
    end
end)

-- Fly
local FlyConnection
local FlyMovement = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

local function StartFly()
    if FlyConnection then FlyConnection:Disconnect() end
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if Config.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            
            if humanoid then
                humanoid.PlatformStand = true
            end
            
            local velocity = Vector3.new(0, 0, 0)
            local speed = Config.FlySpeed
            
            if FlyMovement.W then velocity = velocity + (Camera.CFrame.LookVector * speed) end
            if FlyMovement.S then velocity = velocity - (Camera.CFrame.LookVector * speed) end
            if FlyMovement.A then velocity = velocity - (Camera.CFrame.RightVector * speed) end
            if FlyMovement.D then velocity = velocity + (Camera.CFrame.RightVector * speed) end
            if FlyMovement.Space then velocity = velocity + Vector3.new(0, speed, 0) end
            if FlyMovement.LeftShift then velocity = velocity - Vector3.new(0, speed, 0) end
            
            rootPart.Velocity = velocity
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(input)
    if FlyMovement[input.KeyCode.Name] ~= nil then
        FlyMovement[input.KeyCode.Name] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if FlyMovement[input.KeyCode.Name] ~= nil then
        FlyMovement[input.KeyCode.Name] = false
    end
end)

-- NoClip
local NoClipConnection
local function StartNoClip()
    if NoClipConnection then NoClipConnection:Disconnect() end
    
    NoClipConnection = RunService.Stepped:Connect(function()
        if Config.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- TriggerBot
local TriggerConnection
local function StartTriggerBot()
    if TriggerConnection then TriggerConnection:Disconnect() end
    
    TriggerConnection = RunService.Heartbeat:Connect(function()
        if Config.TriggerBot then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
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

-- Load Linoria Library
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Create Window
local Window = Library:CreateWindow({
    Title = 'HVH GUI | Professional Edition',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Create Tabs
local Tabs = {
    Rage = Window:AddTab('Rage'),
    Legit = Window:AddTab('Legit'),
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Settings = Window:AddTab('Settings')
}

-- Rage Tab
local RageBox = Tabs.Rage:AddLeftGroupbox('Aimbot')
RageBox:AddToggle('SilentAim', {
    Text = 'Silent Aim',
    Default = false,
    Callback = function(Value)
        Config.SilentAim = Value
    end
})

RageBox:AddSlider('SilentFOV', {
    Text = 'Silent FOV',
    Default = 120,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.SilentFOV = Value
    end
})

RageBox:AddToggle('Resolver', {
    Text = 'Resolver',
    Default = false,
    Callback = function(Value)
        Config.Resolver = Value
    end
})

local AABox = Tabs.Rage:AddRightGroupbox('Anti-Aim')
AABox:AddToggle('AntiAim', {
    Text = 'Enable Anti-Aim',
    Default = false,
    Callback = function(Value)
        Config.AntiAim = Value
        StartAntiAim()
    end
})

-- Legit Tab
local LegitBox = Tabs.Legit:AddLeftGroupbox('Legitimate Features')
LegitBox:AddToggle('TriggerBot', {
    Text = 'Trigger Bot',
    Default = false,
    Callback = function(Value)
        Config.TriggerBot = Value
        StartTriggerBot()
    end
})

LegitBox:AddToggle('CamLock', {
    Text = 'CamLock (Q to lock)',
    Default = false,
    Callback = function(Value)
        Config.CamLock = Value
        StartCamLock()
        if not Value then
            CamLockTarget = nil
        end
    end
})

LegitBox:AddSlider('CamLockSmoothness', {
    Text = 'CamLock Smoothness',
    Default = 0.2,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        Config.CamLockSmoothness = Value
    end
})

-- Visuals Tab
local ESPBox = Tabs.Visuals:AddLeftGroupbox('ESP')
ESPBox:AddToggle('ESP', {
    Text = 'Enable ESP',
    Default = false,
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

-- Movement Tab
local FlyBox = Tabs.Movement:AddLeftGroupbox('Flight')
FlyBox:AddToggle('Fly', {
    Text = 'Enable Fly',
    Default = false,
    Callback = function(Value)
        Config.Fly = Value
        StartFly()
    end
})

FlyBox:AddSlider('FlySpeed', {
    Text = 'Fly Speed',
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.FlySpeed = Value
    end
})

FlyBox:AddLabel('Controls: WASD, Space (up), Shift (down)')

local ClipBox = Tabs.Movement:AddRightGroupbox('Collision')
ClipBox:AddToggle('NoClip', {
    Text = 'No Clip',
    Default = false,
    Callback = function(Value)
        Config.NoClip = Value
        StartNoClip()
    end
})

-- Settings Tab
local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Rejoin Server', function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

MenuGroup:AddLabel('UI Toggle Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Menu Keybind',
    NoUI = false,
    Callback = function(Value)
        Library:Toggle()
    end
})

-- Theme Manager & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('HVHGui')
SaveManager:SetFolder('HVHGui/configs')

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Set default theme
ThemeManager:SetTheme('Default')

-- Auto-save
SaveManager:LoadAutoloadConfig()

-- Connections
RunService.Heartbeat:Connect(UpdateESP)

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

Library:Notify('HVH GUI Loaded', 5)