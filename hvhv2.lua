local Lunar = require(2488333606) -- Lunar's module ID

local Config = {  
    SilentAim = false,  
    SilentFOV = 120,  
    ESP = false,  
    AntiAim = false,  
    Resolver = false,  
    Rage = false,  
    Legit = false,  
    TriggerBot = false,  
    Camlock = false,  
    CamlockSmoothness = 5,  
    Fly = false,  
    Noclip = false,  
    GUIKeybind = "F12" -- Default Keybind  
}

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local TweenService = game:GetService("TweenService")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local Workspace = game:GetService("Workspace")  
local LocalPlayer = Players.LocalPlayer  
local Camera = Workspace.CurrentCamera

-- Anti-Detection (Basic)  
local mt = getrawmetatable(game)  
local oldnamecall = mt.__namecall  
setreadonly(mt, false)  
mt.__namecall = newcclosure(function(self, ...)  
    local args = {...}  
    local method = getnamecallmethod()  
    if method == "FireServer" and tostring(self) == "MainEvent" then  
        if args[1] == "Cheese" or args[1] == "Block" then  
            return end  
    end  
    return oldnamecall(self, ...)  
end)  
setreadonly(mt, true)

-- UI Window Creation with Lunar Framework  
local Window = Lunar:CreateWindow({  
    Title = "HVH - Advanced",  
    Width = 600,  
    Height = 400,  
    Transparency = 0.8,  
    GradientColors = {Color3.fromRGB(30, 30, 30), Color3.fromRGB(60, 60, 60)},  
})

-- Rage Tab  
local RageTab = Window:CreateTab("Rage", Color3.fromRGB(60, 0, 0))  
RageTab:CreateToggle({ Name = "Silent Aim", CurrentValue = Config.SilentAim, Flag = "SilentAim", Callback = function(Value) Config.SilentAim = Value end })  
RageTab:CreateSlider({ Name = "Silent FOV", Range = {0, 500}, Increment = 5, CurrentValue = Config.SilentFOV, Flag = "SilentFOV", Callback = function(Value) Config.SilentFOV = Value end })  
RageTab:CreateToggle({ Name = "Anti Aim", CurrentValue = Config.AntiAim, Flag = "AntiAim", Callback = function(Value) Config.AntiAim = Value StartAntiAim() end })  
RageTab:CreateToggle({ Name = "Resolver", CurrentValue = Config.Resolver, Flag = "Resolver", Callback = function(Value) Config.Resolver = Value end })  
RageTab:CreateButton({Name = "Unload All", Callback = function()  
	for _, player in pairs(Players:GetPlayers()) do  
		if ESPObjects[player] then  
			ESPObjects[player][1]:Destroy()  
			ESPObjects[player] = nil  
		end  
	end  
end})

-- Legit Tab  
local LegitTab = Window:CreateTab("Legit", Color3.fromRGB(0, 60, 0))  
LegitTab:CreateToggle({ Name = "Trigger Bot", CurrentValue = Config.TriggerBot, Flag = "TriggerBot", Callback = function(Value) Config.TriggerBot = Value StartTriggerBot() end })

-- Visuals Tab  
local VisualsTab = Window:CreateTab("Visuals", Color3.fromRGB(0, 0, 60))  
VisualsTab:CreateToggle({ Name = "ESP", CurrentValue = Config.ESP, Flag = "ESP", Callback = function(Value) Config.ESP = Value  
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
end })

-- Movement Tab  
local MovementTab = Window:CreateTab("Movement", Color3.fromRGB(60, 60, 0))  
MovementTab:CreateToggle({ Name = "Camlock", CurrentValue = Config.Camlock, Flag = "Camlock", Callback = function(Value) Config.Camlock = Value end })  
MovementTab:CreateSlider({ Name = "Camlock Smoothness", Range = {1, 10}, Increment = 1, CurrentValue = Config.CamlockSmoothness, Flag = "CamlockSmoothness", Callback = function(Value) Config.CamlockSmoothness = Value end })  
MovementTab:CreateToggle({ Name = "Fly", CurrentValue = Config.Fly, Flag = "Fly", Callback = function(Value) Config.Fly = Value StartFly() end })  
MovementTab:CreateToggle({ Name = "Noclip", CurrentValue = Config.Noclip, Flag = "Noclip", Callback = function(Value) Config.Noclip = Value StartNoclip() end })

-- Misc Tab  
local MiscTab = Window:CreateTab("Misc", Color3.fromRGB(0, 60, 60))  
MiscTab:CreateKeybind({Name = "GUI Keybind", CurrentValue = Config.GUIKeybind, Flag = "GUIKeybind", Callback = function(Value) Config.GUIKeybind = Value end})

-- ESP Backend (Same as before)  
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
            objects[3].BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)  
        else  
            objects[1]:Destroy()  
            ESPObjects[player] = nil  
        end  
    end  
end

-- Silent Aim Backend (Advanced Prediction + Resolver) - (Similar to before)  
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
    if Config.Resolver then -- Basic resolver (detects common anti-aim patterns)  
        local yaw = rootPart.CFrame:ToEulerAnglesYXZ()  
        prediction = prediction + Vector3.new(math.sin(tick() * 5) * 2, 0, math.cos(tick() * 5) * 2)  
    end  
    PredictionCache[target] = prediction  
    return prediction  
end

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
                    task.wait(0.01) --Small Delay so it doesn't freak out.  
                    Camera.CFrame = cameraCFrame  
                end  
            end  
        end  
    end  
end)

-- Anti-Aim Backend - (Similar to before)  
local AntiAimConnection  
local function StartAntiAim()  
    if AntiAimConnection then  
        AntiAimConnection:Disconnect()  
    end  
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

-- TriggerBot  (Da Hood specific) - (Similar to before)  
local TriggerConnection  
local function StartTriggerBot()  
    if TriggerConnection then  
        TriggerConnection:Disconnect()  
    end  
    TriggerConnection = RunService.Heartbeat:Connect(function()  
        if Config.TriggerBot then  
            local target = GetClosestPlayer()  
            if target and target.Character and target.Character:FindFirstChild("Head") then -- Fire weapon remote (Da Hood specific)  
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

-- Camlock  
local CamlockOriginalCFrame = Camera.CFrame  
local function StartCamlock()  
    if Config.Camlock then  
       RunService.Heartbeat:Connect(function()  
            Camera.CFrame = CamlockOriginalCFrame  
        end) --Simple camlock, just reset CFrame.  
    end  
end

--Fly  
local oldConstraints = {}  
local function StartFly()  
    if Config.Fly then  
        local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")  
		humanoid.UseJumpPower = true  
        oldConstraints = {}  
        for i, constraint in pairs(LocalPlayer.Character:GetChildren()) do  
          if constraint:IsA("BasePart") then  
            oldConstraints[constraint] = constraint.Anchored  
            constraint.Anchored = false  
          end  
        end  
          
        UserInputService.InputBegan:Connect(function(input, gameProcessed)  
            if not gameProcessed then  
                if input.KeyCode == Enum.KeyCode.Space then  
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)  
                end  
            end  
        end)  
    else  
    	local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")  
		humanoid.UseJumpPower = false  
        for constraint, anchored in pairs(oldConstraints) do  
            constraint.Anchored = anchored  
        end  
    end  
end

--Noclip  
local function StartNoclip()  
    if Config.Noclip then  
      for i, child in pairs(Workspace:GetChildren()) do  
        if child:IsA("BasePart") and child ~= LocalPlayer.Character then  
            child.CanCollide = false  
        end  
      end  
    else  
      for i, child in pairs(Workspace:GetChildren()) do  
        if child:IsA("BasePart") and child ~= LocalPlayer.Character then  
            child.CanCollide = true  
        end  
      end  
    end  
end

-- GUI Keybind  
UserInputService.InputBegan:Connect(function(input, gameProcessed)  
    if not gameProcessed and input.KeyCode == Enum.KeyCode[Config.GUIKeybind] then  
        Window:Toggle()  
    end  
end)

-- Connections and Initial Setup  
RunService.Heartbeat:Connect(UpdateESP) -- Update ESP every frame  
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

-- Initialize config Values  
Config.SilentAim = RageTab:GetToggleValue("SilentAim")  
Config.SilentFOV = RageTab:GetSliderValue("Silent FOV")  
Config.AntiAim = RageTab:GetToggleValue("Anti Aim")  
Config.Resolver = RageTab:GetToggleValue("Resolver")  
Config.TriggerBot = LegitTab:GetToggleValue("Trigger Bot")  
Config.Camlock = MovementTab:GetToggleValue("Camlock")  
Config.CamlockSmoothness = MovementTab:GetSliderValue("Camlock Smoothness")  
Config.Fly = MovementTab:GetToggleValue("Fly")  
Config.Noclip = MovementTab:GetToggleValue("Noclip")

print("HVH - Advanced Loaded")