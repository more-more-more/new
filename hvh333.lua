--[[
 * FLEXMUSIX HVH Suite
 * Custom-built precision tool
 * Version 2.0
]]--

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- Notification System
local function Notify(msg, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "FLEXMUSIX",
        Text = msg,
        Duration = duration or 3
    })
end

-- Anti-Detection & Bypass
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args, method = {...}, getnamecallmethod()
        if method == "FireServer" and tostring(self) == "MainEvent" then
            if args[1] == "Cheese" or args[1] == "Block" or args[1] == "UpdateMousePos" then return end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- Enhanced Config System
local C = {
    Silent = {
        Enabled=false,FOV=150,ShowFOV=true,FOVColor=Color3.fromRGB(138,43,226),
        Thickness=2.5,Transparency=0.5,Part="Head",Prediction=0.133,
        WallCheck=false,TeamCheck=true,AutoShoot=false,HitChance=100,
        Key="None",KeyMode="Toggle"
    },
    Cam = {
        Enabled=false,Key="Q",KeyMode="Toggle",Smoothness=0.15,
        Prediction=0.142,Part="HumanoidRootPart",Shake=true,ShakeAmount=2.5,
        TeamCheck=true,FirstPerson=false,ThirdPerson=true,Spectate=false
    },
    ESP = {
        Enabled=false,Names=true,NameColor=Color3.fromRGB(255,255,255),
        Distance=true,DistColor=Color3.fromRGB(100,200,255),Health=true,
        HealthBar=true,Boxes=true,BoxColor=Color3.fromRGB(138,43,226),
        BoxFilled=false,BoxFillColor=Color3.fromRGB(138,43,226),BoxFillTrans=0.3,
        Tracers=true,TracerColor=Color3.fromRGB(138,43,226),TracerFrom="Bottom",
        MaxDistance=3000,TeamCheck=true,ShowTeam=false,Chams=false,
        Skeleton=false,SkeletonColor=Color3.fromRGB(255,255,255),
        ViewAngle=false,LookLine=false,Weapon=true,
        Key="None",KeyMode="Toggle"
    },
    AntiAim = {
        Enabled=false,Type="Custom",Speed=20,CustomX=0,CustomY=0,CustomZ=0,
        VelocitySpoof=true,VelAmount=25,CFrameDesync=true,
        NetworkDesync=true,PredictionBreaker=false,
        Key="None",KeyMode="Toggle"
    },
    Resolver = {
        Enabled=false,Method="Advanced",UndergroundResolver=true,
        AirResolver=true,PredictMovement=true
    },
    Movement = {
        Flight={Enabled=false,Speed=80,Key="X",KeyMode="Hold"},
        NoClip={Enabled=false,Key="C",KeyMode="Toggle"},
        Speed={Enabled=false,Value=35,Key="V",KeyMode="Toggle"},
        InfiniteJump={Enabled=false,Key="None",KeyMode="Hold"},
        BunnyHop={Enabled=false,Key="None",KeyMode="Toggle"},
        CFrameWalk={Enabled=false,Speed=2,Key="None",KeyMode="Hold"},
        AutoSprint=true
    },
    Spinbot = {
        Enabled=false,Speed=35,Degrees=360,RandomSpin=false,
        Key="B",KeyMode="Toggle"
    },
    Target = {
        Enabled=false,ShowTarget=true,Notifications=true,
        TargetStrafe=false,StrafeSpeed=5,StrafeDistance=10,
        AutoPrediction=true,Key="T",KeyMode="Toggle"
    },
    Gun = {
        NoRecoil=false,NoSpread=false,InfiniteAmmo=false,
        RapidFire=false,RapidSpeed=0.02,AutoReload=false,
        InstantHit=false,Key="None",KeyMode="Toggle"
    },
    World = {
        Ambient=false,AmbientColor=Color3.fromRGB(138,43,226),
        Brightness=1,FogEnd=100000,RemoveFog=false,
        ForceTime=false,TimeValue=14,FullBright=false,
        Key="None",KeyMode="Toggle"
    },
    Misc = {
        WalkSpeed=16,JumpPower=50,Gravity=196.2,
        FOVChanger=false,FOVValue=90,AutoLowGFX=false,
        FPSBoost=false,ChatSpam=false,SpamDelay=3,
        FakeFlag=false,FlagText="FLEXMUSIX",
        AntiAfk=true,AntiVoid=false
    },
    UI = {
        Keybind="RightShift",RainbowMode=false,
        PrimaryColor=Color3.fromRGB(138,43,226),
        SecondaryColor=Color3.fromRGB(75,0,130)
    }
}

-- Keybind States
local KeyStates = {}

-- FOV Circle (Enhanced)
local FOV = Drawing.new("Circle")
FOV.Thickness = 2.5
FOV.NumSides = 64
FOV.Radius = 150
FOV.Color = Color3.fromRGB(138,43,226)
FOV.Visible = false
FOV.Filled = false
FOV.Transparency = 0.5

-- Target Indicator
local TargetIndicator = Drawing.new("Text")
TargetIndicator.Center = true
TargetIndicator.Outline = true
TargetIndicator.Font = 3
TargetIndicator.Size = 18
TargetIndicator.Color = Color3.fromRGB(138,43,226)
TargetIndicator.Visible = false

-- ESP System (Enhanced)
local ESPCache = {}

function CreateESP(player)
    if player == LP or ESPCache[player] then return end
    
    local success = pcall(function()
        ESPCache[player] = {
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            Health = Drawing.new("Text"),
            Weapon = Drawing.new("Text"),
            Box = Drawing.new("Square"),
            BoxFill = Drawing.new("Square"),
            HealthBarBG = Drawing.new("Square"),
            HealthBar = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            ViewLine = Drawing.new("Line")
        }
        
        local esp = ESPCache[player]
        
        -- Text setup
        for _, obj in pairs({esp.Name, esp.Distance, esp.Health, esp.Weapon}) do
            obj.Center = true
            obj.Outline = true
            obj.Font = 2
            obj.Visible = false
        end
        
        -- Box setup
        esp.Box.Thickness = 2
        esp.Box.Filled = false
        esp.Box.Visible = false
        
        esp.BoxFill.Filled = true
        esp.BoxFill.Visible = false
        
        -- Health bar setup
        esp.HealthBarBG.Filled = true
        esp.HealthBarBG.Visible = false
        esp.HealthBar.Filled = true
        esp.HealthBar.Visible = false
        
        -- Lines setup
        esp.Tracer.Thickness = 1.5
        esp.Tracer.Visible = false
        esp.ViewLine.Thickness = 1.5
        esp.ViewLine.Visible = false
    end)
    
    if not success then
        ESPCache[player] = nil
    end
end

function UpdateESP()
    for player, esp in pairs(ESPCache) do
        if not esp or not esp.Name then
            ESPCache[player] = nil
            continue
        end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
            pcall(function()
                for _, obj in pairs(esp) do
                    obj.Visible = false
                end
            end)
            continue
        end
        
        local char = player.Character
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        local head = char:FindFirstChild("Head")
        
        local pos, onScreen = Cam:WorldToViewportPoint(hrp.Position)
        local distance = (hrp.Position - Cam.CFrame.Position).Magnitude
        
        if not C.ESP.Enabled or not onScreen or distance > C.ESP.MaxDistance or (C.ESP.TeamCheck and player.Team == LP.Team) then
            pcall(function()
                for _, obj in pairs(esp) do
                    obj.Visible = false
                end
            end)
            continue
        end
        
        pcall(function()
            -- Name
            if C.ESP.Names then
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(pos.X, pos.Y - 40)
                esp.Name.Color = C.ESP.NameColor
                esp.Name.Size = 14
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            -- Distance
            if C.ESP.Distance then
                esp.Distance.Text = math.floor(distance) .. "m"
                esp.Distance.Position = Vector2.new(pos.X, pos.Y + 30)
                esp.Distance.Color = C.ESP.DistColor
                esp.Distance.Size = 13
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
            
            -- Weapon
            if C.ESP.Weapon then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    esp.Weapon.Text = tool.Name
                    esp.Weapon.Position = Vector2.new(pos.X, pos.Y + 45)
                    esp.Weapon.Color = Color3.fromRGB(255, 200, 0)
                    esp.Weapon.Size = 12
                    esp.Weapon.Visible = true
                else
                    esp.Weapon.Visible = false
                end
            else
                esp.Weapon.Visible = false
            end
            
            -- Box
            if C.ESP.Boxes and head then
                local headPos = Cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.5
                
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                esp.Box.Color = C.ESP.BoxColor
                esp.Box.Visible = true
                
                if C.ESP.BoxFilled then
                    esp.BoxFill.Size = Vector2.new(width, height)
                    esp.BoxFill.Position = Vector2.new(pos.X - width/2, headPos.Y)
                    esp.BoxFill.Color = C.ESP.BoxFillColor
                    esp.BoxFill.Transparency = C.ESP.BoxFillTrans
                    esp.BoxFill.Visible = true
                else
                    esp.BoxFill.Visible = false
                end
                
                -- Health Bar
                if C.ESP.HealthBar then
                    local healthPct = hum.Health / hum.MaxHealth
                    esp.HealthBarBG.Size = Vector2.new(3, height)
                    esp.HealthBarBG.Position = Vector2.new(pos.X - width/2 - 6, headPos.Y)
                    esp.HealthBarBG.Color = Color3.new(0, 0, 0)
                    esp.HealthBarBG.Visible = true
                    
                    esp.HealthBar.Size = Vector2.new(3, height * healthPct)
                    esp.HealthBar.Position = Vector2.new(pos.X - width/2 - 6, headPos.Y + (height * (1 - healthPct)))
                    esp.HealthBar.Color = Color3.new(1 - healthPct, healthPct, 0)
                    esp.HealthBar.Visible = true
                else
                    esp.HealthBarBG.Visible = false
                    esp.HealthBar.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.BoxFill.Visible = false
                esp.HealthBarBG.Visible = false
                esp.HealthBar.Visible = false
            end
            
            -- Tracer
            if C.ESP.Tracers then
                local origin = C.ESP.TracerFrom == "Bottom" and 
                    Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y) or 
                    Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                esp.Tracer.From = origin
                esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                esp.Tracer.Color = C.ESP.TracerColor
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
        end)
    end
end

-- Target System (Enhanced)
local CurrentTarget = nil

function GetClosestPlayer()
    local closest, minDist = nil, math.huge
    local mousePos = UIS:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild(C.Silent.Part) then
            if C.Silent.TeamCheck and player.Team == LP.Team then continue end
            
            local part = player.Character[C.Silent.Part]
            local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < C.Silent.FOV and dist < minDist then
                    if C.Silent.WallCheck then
                        local ray = Ray.new(Cam.CFrame.Position, (part.Position - Cam.CFrame.Position).Unit * 500)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character})
                        if hit and hit:IsDescendantOf(player.Character) then
                            closest, minDist = player, dist
                        end
                    else
                        closest, minDist = player, dist
                    end
                end
            end
        end
    end
    
    return closest
end

function PredictPosition(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local hrp = target.Character.HumanoidRootPart
    local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
    local predictedPos = hrp.Position + (velocity * C.Silent.Prediction)
    
    -- Advanced Resolver
    if C.Resolver.Enabled then
        if C.Resolver.Method == "Advanced" then
            local t = tick()
            predictedPos = predictedPos + Vector3.new(
                math.sin(t * 8) * 2.8,
                math.cos(t * 6) * 1.5,
                math.cos(t * 8) * 2.8
            )
        elseif C.Resolver.Method == "Delta" then
            local t = tick()
            predictedPos = predictedPos + Vector3.new(
                math.sin(t * 12) * 3.5,
                0,
                math.cos(t * 12) * 3.5
            )
        end
    end
    
    return predictedPos
end

-- Silent Aim (Enhanced)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Silent Aim
    if input.UserInputType == Enum.UserInputType.MouseButton1 and C.Silent.Enabled then
        if math.random(1, 100) <= C.Silent.HitChance then
            local target = GetClosestPlayer()
            if target then
                CurrentTarget = target
                local predictedPos = PredictPosition(target)
                if predictedPos then
                    local originalCF = Cam.CFrame
                    Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, predictedPos)
                    task.wait(0.025)
                    Cam.CFrame = originalCF
                end
            end
        end
    end
end)

-- CamLock System (Enhanced)
local CamLockTarget = nil
local CamLockActive = false

function HandleCamLock()
    if C.Cam.KeyMode == "Toggle" then
        CamLockActive = not CamLockActive
        if CamLockActive then
            CamLockTarget = GetClosestPlayer()
            if CamLockTarget then
                Notify("Locked onto " .. CamLockTarget.Name, 2)
            end
        else
            Notify("CamLock disabled", 2)
            CamLockTarget = nil
        end
    else
        CamLockActive = true
        CamLockTarget = GetClosestPlayer()
    end
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[C.Cam.Key] and C.Cam.Enabled then
        HandleCamLock()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[C.Cam.Key] and C.Cam.Enabled and C.Cam.KeyMode == "Hold" then
        CamLockActive = false
        CamLockTarget = nil
    end
end)

RS.RenderStepped:Connect(function()
    if C.Cam.Enabled and CamLockActive and CamLockTarget and 
       CamLockTarget.Character and CamLockTarget.Character:FindFirstChild(C.Cam.Part) then
        
        local part = CamLockTarget.Character[C.Cam.Part]
        local velocity = part.AssemblyLinearVelocity or part.Velocity
        local predictedPos = part.Position + (velocity * C.Cam.Prediction)
        
        if C.Cam.Shake then
            predictedPos = predictedPos + Vector3.new(
                math.random(-C.Cam.ShakeAmount, C.Cam.ShakeAmount) / 10,
                math.random(-C.Cam.ShakeAmount, C.Cam.ShakeAmount) / 10,
                0
            )
        end
        
        Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, predictedPos), C.Cam.Smoothness)
    end
end)

-- Anti-Aim System (Enhanced)
local AAActive = false

RS.Heartbeat:Connect(function()
    if C.AntiAim.Enabled and AAActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        
        if C.AntiAim.Type == "Spin" then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(C.AntiAim.Speed), 0)
        elseif C.AntiAim.Type == "Jitter" then
            local jitter = (tick() % 0.3 < 0.15) and 90 or -90
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(jitter), 0)
        elseif C.AntiAim.Type == "Random" then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        elseif C.AntiAim.Type == "Custom" then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(
                math.rad(C.AntiAim.CustomX),
                math.rad(C.AntiAim.CustomY),
                math.rad(C.AntiAim.CustomZ)
            )
        end
        
        if C.AntiAim.VelocitySpoof then
            local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
            hrp.Velocity = Vector3.new(
                math.sin(tick() * 10) * C.AntiAim.VelAmount,
                vel.Y,
                math.cos(tick() * 10) * C.AntiAim.VelAmount
            )
        end
    end
end)

-- Movement System (Enhanced)
local FlightBV, FlightBG

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local hum = LP.Character:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    -- Flight
    if C.Movement.Flight.Enabled and KeyStates[C.Movement.Flight.Key] then
        if not FlightBV then
            FlightBV = Instance.new("BodyVelocity", hrp)
            FlightBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            FlightBG = Instance.new("BodyGyro", hrp)
            FlightBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        end
        
        local velocity = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + Cam.CFrame.LookVector * C.Movement.Flight.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - Cam.CFrame.LookVector * C.Movement.Flight.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - Cam.CFrame.RightVector * C.Movement.Flight.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + Cam.CFrame.RightVector * C.Movement.Flight.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, C.Movement.Flight.Speed, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then velocity = velocity - Vector3.new(0, C.Movement.Flight.Speed, 0) end
        
        FlightBV.Velocity = velocity
        FlightBG.CFrame = Cam.CFrame
    else
        if FlightBV then FlightBV:Destroy() FlightBV = nil end
        if FlightBG then FlightBG:Destroy() FlightBG = nil end
    end
    
    -- NoClip
    if C.Movement.NoClip.Enabled and KeyStates[C.Movement.NoClip.Key] then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Speed
    if C.Movement.Speed.Enabled and KeyStates[C.Movement.Speed.Key] then
        hum.WalkSpeed = C.Movement.Speed.Value
    else
        hum.WalkSpeed = C.Misc.WalkSpeed
    end
    
    -- Infinite Jump
    if C.Movement.InfiniteJump.Enabled and KeyStates[C.Movement.InfiniteJump.Key] then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- Bunny Hop
    if C.Movement.BunnyHop.Enabled and KeyStates[C.Movement.BunnyHop.Key] then
        if UIS:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- Auto Sprint
    if C.Movement.AutoSprint then
        hum.WalkSpeed = C.Misc.WalkSpeed
    end
    
    -- Jump Power
    hum.JumpPower = C.Misc.JumpPower
end)

-- Spinbot System
local SpinbotActive = false

RS.RenderStepped:Connect(function()
    if C.Spinbot.Enabled and SpinbotActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local rotation = C.Spinbot.RandomSpin and math.random(1, C.Spinbot.Speed) or C.Spinbot.Speed
        LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * 
            CFrame.Angles(0, math.rad(rotation), 0)
    end
end)

-- FOV & Target Indicator Update
RS.RenderStepped:Connect(function()
    -- FOV Circle
    FOV.Visible = C.Silent.ShowFOV and C.Silent.Enabled
    FOV.Radius = C.Silent.FOV
    FOV.Color = C.UI.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or C.Silent.FOVColor
    FOV.Transparency = C.Silent.Transparency
    FOV.Thickness = C.Silent.Thickness
    FOV.Position = UIS:GetMouseLocation()
    
    -- Target Indicator
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local pos = Cam:WorldToViewportPoint(CurrentTarget.Character.HumanoidRootPart.Position)
        TargetIndicator.Text = "⦿ " .. CurrentTarget.Name .. " ⦿"
        TargetIndicator.Position = Vector2.new(pos.X, pos.Y - 50)
        TargetIndicator.Visible = C.Target.ShowTarget
        TargetIndicator.Color = C.UI.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or C.UI.PrimaryColor
    else
        TargetIndicator.Visible = false
    end
end)

-- ESP Update Loop
RS.RenderStepped:Connect(UpdateESP)

-- Player Setup
task.wait(1)
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then CreateESP(player) end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        CreateESP(player)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        CreateESP(player)
    end)
end)

-- UI Library
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Win = Lib:CreateWindow({
    Title = "FLEXMUSIX | Premium HVH Suite",
    Center = true,
    AutoShow = true,
    TabPadding = 10,
    MenuFadeTime = 0.3
})

local Tabs = {
    Combat = Win:AddTab("⚔️ Combat"),
    Visuals = Win:AddTab("👁️ Visuals"),
    Movement = Win:AddTab("🏃 Movement"),
    AntiAim = Win:AddTab("🛡️ Anti-Aim"),
    World = Win:AddTab("🌍 World"),
    Misc = Win:AddTab("⚙️ Misc"),
    Settings = Win:AddTab("🎨 Settings")
}

-- Combat Tab
do
    local SilentBox = Tabs.Combat:AddLeftGroupbox("Silent Aim")
    
    SilentBox:AddToggle("SilentAim", {Text = "Enable Silent Aim", Default = false})
        :AddKeyPicker("SilentAimKey", {Default = "None", SyncToggleState = false, Mode = "Toggle", Text = "Silent Aim"})
        :OnChanged(function() end)
    
    Toggles.SilentAim:OnChanged(function(value)
        C.Silent.Enabled = value
        if value then Notify("Silent Aim Enabled", 2) end
    end)
    
    Options.SilentAimKey:OnChanged(function(value)
        C.Silent.Key = value.Name
        C.Silent.KeyMode = value.Mode
    end)
    
    SilentBox:AddSlider("SilentFOV", {Text = "FOV Size", Default = 150, Min = 50, Max = 500, Rounding = 0})
        :OnChanged(function(value) C.Silent.FOV = value end)
    
    SilentBox:AddToggle("ShowFOV", {Text = "Show FOV Circle", Default = true})
        :OnChanged(function(value) C.Silent.ShowFOV = value end)
    
    SilentBox:AddLabel("FOV Color"):AddColorPicker("FOVColor", {Default = Color3.fromRGB(138,43,226)})
        :OnChanged(function(value) C.Silent.FO
            SilentBox:AddSlider("SilentPred", {Text = "Prediction", Default = 0.133, Min = 0.1, Max = 0.2, Rounding = 3})
    :OnChanged(function(value) C.Silent.Prediction = value end)

SilentBox:AddSlider("HitChance", {Text = "Hit Chance %", Default = 100, Min = 1, Max = 100, Rounding = 0})
    :OnChanged(function(value) C.Silent.HitChance = value end)

SilentBox:AddDropdown("SilentPart", {Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, Default = 1, Multi = false, Text = "Hitbox"})
    :OnChanged(function(value) C.Silent.Part = value end)

SilentBox:AddToggle("WallCheck", {Text = "Visibility Check", Default = false})
    :OnChanged(function(value) C.Silent.WallCheck = value end)

SilentBox:AddToggle("TeamCheck1", {Text = "Ignore Team", Default = true})
    :OnChanged(function(value) C.Silent.TeamCheck = value end)

local CamBox = Tabs.Combat:AddRightGroupbox("Camera Lock")

CamBox:AddToggle("CamLock", {Text = "Enable CamLock", Default = false})
    :AddKeyPicker("CamLockKey", {Default = "Q", SyncToggleState = false, Mode = "Toggle", Text = "CamLock"})
    :OnChanged(function() end)

Toggles.CamLock:OnChanged(function(value)
    C.Cam.Enabled = value
    if value then Notify("CamLock Ready", 2) end
end)

Options.CamLockKey:OnChanged(function(value)
    C.Cam.Key = value.Name
    C.Cam.KeyMode = value.Mode
end)

CamBox:AddSlider("CamSmooth", {Text = "Smoothness", Default = 0.15, Min = 0.05, Max = 1, Rounding = 2})
    :OnChanged(function(value) C.Cam.Smoothness = value end)

CamBox:AddSlider("CamPred", {Text = "Prediction", Default = 0.142, Min = 0.1, Max = 0.2, Rounding = 3})
    :OnChanged(function(value) C.Cam.Prediction = value end)

CamBox:AddDropdown("CamPart", {Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, Default = 3, Multi = false, Text = "Target Part"})
    :OnChanged(function(value) C.Cam.Part = value end)

CamBox:AddToggle("CamShake", {Text = "Camera Shake", Default = true})
    :OnChanged(function(value) C.Cam.Shake = value end)

CamBox:AddSlider("ShakeAmt", {Text = "Shake Amount", Default = 2.5, Min = 1, Max = 10, Rounding = 1})
    :OnChanged(function(value) C.Cam.ShakeAmount = value end)

CamBox:AddToggle("TeamCheck2", {Text = "Ignore Team", Default = true})
    :OnChanged(function(value) C.Cam.TeamCheck = value end)

local ResolverBox = Tabs.Combat:AddLeftGroupbox("Resolver")

ResolverBox:AddToggle("Resolver", {Text = "Enable Resolver", Default = false})
    :OnChanged(function(value) C.Resolver.Enabled = value end)

ResolverBox:AddDropdown("ResolverType", {Values = {"Basic", "Advanced", "Delta"}, Default = 2, Multi = false, Text = "Method"})
    :OnChanged(function(value) C.Resolver.Method = value end)

ResolverBox:AddToggle("AirResolver", {Text = "Air Resolver", Default = true})
    :OnChanged(function(value) C.Resolver.AirResolver = value end)

local TargetBox = Tabs.Combat:AddRightGroupbox("Target System")

TargetBox:AddToggle("ShowTarget", {Text = "Show Target Indicator", Default = true})
    :OnChanged(function(value) C.Target.ShowTarget = value end)

TargetBox:AddToggle("TargetNotif", {Text = "Target Notifications", Default = true})
    :OnChanged(function(value) C.Target.Notifications = value end)

TargetBox:AddToggle("AutoPred", {Text = "Auto Prediction", Default = true})
    :OnChanged(function(value) C.Target.AutoPrediction = value end)
end
-- Visuals Tab
do
local ESPBox = Tabs.Visuals:AddLeftGroupbox("ESP")
ESPBox:AddToggle("ESP", {Text = "Enable ESP", Default = false})
    :AddKeyPicker("ESPKey", {Default = "None", SyncToggleState = false, Mode = "Toggle", Text = "ESP"})
    :OnChanged(function() end)

Toggles.ESP:OnChanged(function(value)
    C.ESP.Enabled = value
    if value then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then CreateESP(player) end
        end
    end
end)

Options.ESPKey:OnChanged(function(value)
    C.ESP.Key = value.Name
    C.ESP.KeyMode = value.Mode
end)

ESPBox:AddToggle("ESPNames", {Text = "Show Names", Default = true})
    :OnChanged(function(value) C.ESP.Names = value end)

ESPBox:AddLabel("Name Color"):AddColorPicker("NameColor", {Default = Color3.new(1,1,1)})
    :OnChanged(function(value) C.ESP.NameColor = value end)

ESPBox:AddToggle("ESPDist", {Text = "Show Distance", Default = true})
    :OnChanged(function(value) C.ESP.Distance = value end)

ESPBox:AddLabel("Distance Color"):AddColorPicker("DistColor", {Default = Color3.fromRGB(100,200,255)})
    :OnChanged(function(value) C.ESP.DistColor = value end)

ESPBox:AddToggle("ESPWeapon", {Text = "Show Weapon", Default = true})
    :OnChanged(function(value) C.ESP.Weapon = value end)

ESPBox:AddSlider("ESPMaxDist", {Text = "Max Distance", Default = 3000, Min = 500, Max = 5000, Rounding = 0})
    :OnChanged(function(value) C.ESP.MaxDistance = value end)

ESPBox:AddToggle("TeamCheck3", {Text = "Ignore Team", Default = true})
    :OnChanged(function(value) C.ESP.TeamCheck = value end)

local ESPBox2 = Tabs.Visuals:AddRightGroupbox("ESP Features")

ESPBox2:AddToggle("Boxes", {Text = "Boxes", Default = true})
    :OnChanged(function(value) C.ESP.Boxes = value end)

ESPBox2:AddLabel("Box Color"):AddColorPicker("BoxColor", {Default = Color3.fromRGB(138,43,226)})
    :OnChanged(function(value) C.ESP.BoxColor = value end)

ESPBox2:AddToggle("BoxFill", {Text = "Filled Boxes", Default = false})
    :OnChanged(function(value) C.ESP.BoxFilled = value end)

ESPBox2:AddLabel("Fill Color"):AddColorPicker("BoxFillColor", {Default = Color3.fromRGB(138,43,226)})
    :OnChanged(function(value) C.ESP.BoxFillColor = value end)

ESPBox2:AddSlider("FillTrans", {Text = "Fill Transparency", Default = 0.3, Min = 0, Max = 1, Rounding = 2})
    :OnChanged(function(value) C.ESP.BoxFillTrans = value end)

ESPBox2:AddToggle("HealthBar", {Text = "Health Bars", Default = true})
    :OnChanged(function(value) C.ESP.HealthBar = value end)

ESPBox2:AddToggle("Tracers", {Text = "Tracers", Default = true})
    :OnChanged(function(value) C.ESP.Tracers = value end)

ESPBox2:AddLabel("Tracer Color"):AddColorPicker("TracerColor", {Default = Color3.fromRGB(138,43,226)})
    :OnChanged(function(value) C.ESP.TracerColor = value end)

ESPBox2:AddDropdown("TracerOrigin", {Values = {"Bottom", "Middle"}, Default = 1, Multi = false, Text = "Tracer Origin"})
    :OnChanged(function(value) C.ESP.TracerFrom = value end)

local ChamsBox = Tabs.Visuals:AddLeftGroupbox("Advanced Visuals")

ChamsBox:AddToggle("Chams", {Text = "Chams (Highlight)", Default = false})
    :OnChanged(function(value) C.ESP.Chams = value end)

ChamsBox:AddToggle("Skeleton", {Text = "Skeleton ESP", Default = false})
    :OnChanged(function(value) C.ESP.Skeleton = value end)

ChamsBox:AddLabel("Skeleton Color"):AddColorPicker("SkeletonColor", {Default = Color3.new(1,1,1)})
    :OnChanged(function(value) C.ESP.SkeletonColor = value end)
end
-- Movement Tab
do
local FlightBox = Tabs.Movement:AddLeftGroupbox("Flight")
FlightBox:AddToggle("Flight", {Text = "Enable Flight", Default = false})
    :AddKeyPicker("FlightKey", {Default = "X", SyncToggleState = false, Mode = "Hold", Text = "Flight"})
    :OnChanged(function() end)

Toggles.Flight:OnChanged(function(value) C.Movement.Flight.Enabled = value end)

Options.FlightKey:OnChanged(function(value)
    C.Movement.Flight.Key = value.Name
    C.Movement.Flight.KeyMode = value.Mode
    KeyStates[value.Name] = false
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode.Name == C.Movement.Flight.Key then
        if C.Movement.Flight.KeyMode == "Hold" then
            KeyStates[C.Movement.Flight.Key] = true
        else
            KeyStates[C.Movement.Flight.Key] = not KeyStates[C.Movement.Flight.Key]
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode.Name == C.Movement.Flight.Key and C.Movement.Flight.KeyMode == "Hold" then
        KeyStates[C.Movement.Flight.Key] = false
    end
end)

FlightBox:AddSlider("FlightSpeed", {Text = "Flight Speed", Default = 80, Min = 20, Max = 200, Rounding = 0})
    :OnChanged(function(value) C.Movement.Flight.Speed = value end)

FlightBox:AddLabel("Controls: WASD, Space, Shift")

local SpeedBox = Tabs.Movement:AddRightGroupbox("Speed")

SpeedBox:AddToggle("Speed", {Text = "Enable Speed", Default = false})
    :AddKeyPicker("SpeedKey", {Default = "V", SyncToggleState = false, Mode = "Toggle", Text = "Speed"})
    :OnChanged(function() end)

Toggles.Speed:OnChanged(function(value) C.Movement.Speed.Enabled = value end)

Options.SpeedKey:OnChanged(function(value)
    C.Movement.Speed.Key = value.Name
    C.Movement.Speed.KeyMode = value.Mode
    KeyStates[value.Name] = false
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode.Name == C.Movement.Speed.Key then
        if C.Movement.Speed.KeyMode == "Hold" then
            KeyStates[C.Movement.Speed.Key] = true
        else
            KeyStates[C.Movement.Speed.Key] = not KeyStates[C.Movement.Speed.Key]
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode.Name == C.Movement.Speed.Key and C.Movement.Speed.KeyMode == "Hold" then
        KeyStates[C.Movement.Speed.Key] = false
    end
end)

SpeedBox:AddSlider("SpeedValue", {Text = "Speed Amount", Default = 35, Min = 16, Max = 150, Rounding = 0})
    :OnChanged(function(value) C.Movement.Speed.Value = value end)

local NoClipBox = Tabs.Movement:AddLeftGroupbox("NoClip")

NoClipBox:AddToggle("NoClip", {Text = "Enable NoClip", Default = false})
    :AddKeyPicker("NoClipKey", {Default = "C", SyncToggleState = false, Mode = "Toggle", Text = "NoClip"})
    :OnChanged(function() end)

Toggles.NoClip:OnChanged(function(value) C.Movement.NoClip.Enabled = value end)

Options.NoClipKey:OnChanged(function(value)
    C.Movement.NoClip.Key = value.Name
    C.Movement.NoClip.KeyMode = value.Mode
    KeyStates[value.Name] = false
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode.Name == C.Movement.NoClip.Key then
        if C.Movement.NoClip.KeyMode == "Hold" then
            KeyStates[C.Movement.NoClip.Key] = true
        else
            KeyStates[C.Movement.NoClip.Key] = not KeyStates[C.Movement.NoClip.Key]
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode.Name == C.Movement.NoClip.Key and C.Movement.NoClip.KeyMode == "Hold" then
        KeyStates[C.Movement.NoClip.Key] = false
    end
end)

local JumpBox = Tabs.Movement:AddRightGroupbox("Jump Modifications")

JumpBox:AddToggle("InfJump", {Text = "Infinite Jump", Default = false})
    :AddKeyPicker("InfJumpKey", {Default = "None", SyncToggleState = false, Mode = "Hold", Text = "Infinite Jump"})
    :OnChanged(function() end)

Toggles.InfJump:OnChanged(function(value) C.Movement.InfiniteJump.Enabled = value end)

Options.InfJumpKey:OnChanged(function(value)
    C.Movement.InfiniteJump.Key = value.Name
    C.Movement.InfiniteJump.KeyMode = value.Mode
    KeyStates[value.Name] = false
end)

JumpBox:AddToggle("BHop", {Text = "Bunny Hop", Default = false})
    :AddKeyPicker("BHopKey", {Default = "None", SyncToggleState = false, Mode = "Toggle", Text = "Bunny Hop"})
    :OnChanged(function() end)

Toggles.BHop:OnChanged(function(value) C.Movement.BunnyHop.Enabled = value end)

Options.BHopKey:OnChanged(function(value)
    C.Movement.BunnyHop.Key = value.Name
    C.Movement.BunnyHop.KeyMode = value.Mode
    KeyStates[value.Name] = false
end)

local MiscMoveBox = Tabs.Movement:AddLeftGroupbox("Misc Movement")

MiscMoveBox:AddToggle("AutoSprint", {Text = "Auto Sprint", Default = true})
    :OnChanged(function(value) C.Movement.AutoSprint = value end)
end
-- Anti-Aim Tab
do
local AABox = Tabs.AntiAim:AddLeftGroupbox("Anti-Aim")
AABox:AddToggle("AntiAim", {Text = "Enable Anti-Aim", Default = false})
    :AddKeyPicker("AAKey", {Default = "None", SyncToggleState = false, Mode = "Toggle", Text = "Anti-Aim"})
    :OnChanged(function() end)

Toggles.AntiAim:OnChanged(function(value)
    C.AntiAim.Enabled = value
    AAActive = value
end)

Options.AAKey:OnChanged(function(value)
    C.AntiAim.Key = value.Name
    C.AntiAim.KeyMode = value.Mode
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode.Name == C.AntiAim.Key and C.AntiAim.Enabled then
        if C.AntiAim.KeyMode == "Hold" then
            AAActive = true
        else
            AAActive = not AAActive
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode.Name == C.AntiAim.Key and C.AntiAim.KeyMode == "Hold" then
        AAActive = false
    end
end)

AABox:AddDropdown("AAType", {Values = {"Spin", "Jitter", "Random", "Custom"}, Default = 4, Multi = false, Text = "Type"})
    :OnChanged(function(value) C.AntiAim.Type = value end)

AABox:AddSlider("AASpeed", {Text = "Speed", Default = 20, Min = 1, Max = 100, Rounding = 0})
    :OnChanged(function(value) C.AntiAim.Speed = value end)

AABox:AddLabel("Custom Angles (for Custom type)")

AABox:AddSlider("CustomX", {Text = "Pitch (X)", Default = 0, Min = -180, Max = 180, Rounding = 0})
    :OnChanged(function(value) C.AntiAim.CustomX = value end)

AABox:AddSlider("CustomY", {Text = "Yaw (Y)", Default = 0, Min = -180, Max = 180, Rounding = 0})
    :OnChanged(function(value) C.AntiAim.CustomY = value end)

AABox:AddSlider("CustomZ", {Text = "Roll (Z)", Default = 0, Min = -180, Max = 180, Rounding = 0})
    :OnChanged(function(value) C.AntiAim.CustomZ = value end)

AABox:AddToggle("VelSpoof", {Text = "Velocity Spoof", Default = true})
    :OnChanged(function(value) C.AntiAim.VelocitySpoof = value end)

AABox:AddSlider("VelAmount", {Text = "Velocity Amount", Default = 25, Min = 5, Max = 100, Rounding = 0})
    :OnChanged(function(value) C.AntiAim.VelAmount = value end)

local SpinbotBox = Tabs.AntiAim:AddRightGroupbox("Spinbot")

SpinbotBox:AddToggle("Spinbot", {Text = "Enable Spinbot", Default = false})
    :AddKeyPicker("SpinbotKey", {Default = "B", SyncToggleState = false, Mode = "Toggle", Text = "Spinbot"})
    :OnChanged(function() end)

Toggles.Spinbot:OnChanged(function(value)
    C.Spinbot.Enabled = value
    SpinbotActive = value
end)

Options.SpinbotKey:OnChanged(function(value)
    C.Spinbot.Key = value.Name
    C.Spinbot.KeyMode = value.Mode
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode.Name == C.Spinbot.Key and C.Spinbot.Enabled then
        if C.Spinbot.KeyMode == "Hold" then
            SpinbotActive = true
        else
            SpinbotActive = not SpinbotActive
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode.Name == C.Spinbot.Key and C.Spinbot.KeyMode == "Hold" then
        SpinbotActive = false
    end
end)

SpinbotBox:AddSlider("SpinSpeed", {Text = "Spin Speed", Default = 35, Min = 1, Max = 100, Rounding = 0})
    :OnChanged(function(value) C.Spinbot.Speed = value end)

SpinbotBox:AddToggle("RandomSpin", {Text = "Random Spin", Default = false})
    :OnChanged(function(value) C.Spinbot.RandomSpin = value end)
end
-- World Tab
do
local AmbientBox = Tabs.World:AddLeftGroupbox("Lighting")
AmbientBox:AddToggle("FullBright", {Text = "Full Bright", Default = false})
    :OnChanged(function(value)
        C.World.FullBright = value
        if value then
            game:GetService("Lighting").Brightness = 3
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").GlobalShadows = true
        end
    end)

AmbientBox:AddToggle("Ambient", {Text = "Custom Ambient", Default = false})
    :OnChanged(function(value) C.World.Ambient = value end)

AmbientBox:AddLabel("Ambient Color"):AddColorPicker("AmbientColor", {Default = Color3.fromRGB(138,43,226)})
    :OnChanged(function(value)
        C.World.AmbientColor = value
        if C.World.Ambient then
            game:GetService("Lighting").Ambient = value
        end
    end)

AmbientBox:AddSlider("Brightness", {Text = "Brightness", Default = 1, Min = 0, Max = 5, Rounding = 1})
    :OnChanged(function(value)
        C.World.Brightness = value
        game:GetService("Lighting").Brightness = value
    end)

local FogBox = Tabs.World:AddRightGroupbox("Fog & Sky")

FogBox:AddToggle("RemoveFog", {Text = "Remove Fog", Default = false})
    :OnChanged(function(value)
        C.World.RemoveFog = value
        game:GetService("Lighting").FogEnd = value and 100000 or 1000
    end)

FogBox:AddToggle("ForceTime", {Text = "Force Time of Day", Default = false})
    :OnChanged(function(value) C.World.ForceTime = value end)

FogBox:AddSlider("TimeValue", {Text = "Time", Default = 14, Min = 0, Max = 24, Rounding = 0})
    :OnChanged(function(value)
        C.World.TimeValue = value
        if C.World.ForceTime then
            game:GetService("Lighting").ClockTime = value
        end
    end)

RS.Heartbeat:Connect(function()
    if C.World.ForceTime then
        game:GetService("Lighting").ClockTime = C.World.TimeValue
    end
    if C.World.Ambient then
        game:GetService("Lighting").Ambient = C.World.AmbientColor
    end
end)
end
-- Misc Tab
do
local CharBox = Tabs.Misc:AddLeftGroupbox("Character")
CharBox:AddSlider("WalkSpeed", {Text = "Walk Speed", Default = 16, Min = 16, Max = 150, Rounding = 0})
    :OnChanged(function(value) C.Misc.WalkSpeed = value end)

CharBox:AddSlider("JumpPower", {Text = "Jump Power", Default = 50, Min = 50, Max = 300, Rounding = 0})
    :OnChanged(function(value) C.Misc.JumpPower = value end)

CharBox:AddSlider("Gravity", {Text = "Gravity", Default = 196.2, Min = 0, Max = 500, Rounding = 1})
    :OnChanged(function(value)
        C.Misc.Gravity = value
        workspace.Gravity = value
    end)

local FOVBox = Tabs.Misc:AddRightGroupbox("Camera")

FOVBox:AddToggle("FOVChanger", {Text = "FOV Changer", Default = false})
    :OnChanged(function(value) C.Misc.FOVChanger = value end)

FOVBox:AddSlider("FOVValue", {Text = "FOV", Default = 90, Min = 70, Max = 120, Rounding = 0})
    :OnChanged(function(value)
        C.Misc.FOVValue = value
        if C.Misc.FOVChanger then
            Cam.FieldOfView = value
        end
    end)

RS.RenderStepped:Connect(function()
    if C.Misc.FOVChanger then
        Cam.FieldOfView = C.Misc.FOVValue
    end
end)

local UtilBox = Tabs.Misc:AddLeftGroupbox("Utilities")

UtilBox:AddToggle("AntiAFK", {Text = "Anti-AFK", Default = true})
    :OnChanged(function(value) C.Misc.AntiAfk = value end)

if C.Misc.AntiAfk then
    local VirtualUser = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if C.Misc.AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

UtilBox:AddToggle("FPSBoost", {Text = "FPS Boost", Default = false})
    :OnChanged(function(value)
        C.Misc.FPSBoost = value
        if value then
            local decals = {"Decal", "Texture"}
            local parts = workspace:GetDescendants()
            for _, part in pairs(parts) do
                if table.find(decals, part.ClassName) then
                    part.Transparency = 1
                end
            end
        end
    end)

local ServerBox = Tabs.Misc:AddRightGroupbox("Server")

ServerBox:AddButton({Text = "Rejoin Server", Func = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end})

ServerBox:AddButton({Text = "Server Hop", Func = function()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
    
    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end
    
    local Server, Next
    repeat
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor
    until Server
    
    TPS:TeleportToPlaceInstance(_place, Server.id, LP)
end})

ServerBox:AddButton({Text = "Copy Job ID", Func = function()
    setclipboard(game.JobId)
    Notify("Job ID copied to clipboard!", 2)
end})
end
-- Settings Tab
do
local UIBox = Tabs.Settings:AddLeftGroupbox("UI Settings")
UIBox:AddToggle("RainbowMode", {Text = "Rainbow Mode", Default = false})
    :OnChanged(function(value) C.UI.RainbowMode = value end)

UIBox:AddLabel("Primary Color"):AddColorPicker("PrimaryColor", {Default = Color3.fromRGB(138,43,226)})
    :OnChanged(function(value) C.UI.PrimaryColor = value end)

UIBox:AddLabel("Secondary Color"):AddColorPicker("SecondaryColor", {Default = Color3.fromRGB(75,0,130)})
    :OnChanged(function(value) C.UI.SecondaryColor = value end)

UIBox:AddDivider()

UIBox:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {Default = "RightShift", NoUI = true, Text = "Menu Keybind"})

Options.MenuKeybind:OnChanged(function(value)
    C.UI.Keybind = value.Name
end)

local InfoBox = Tabs.Settings:AddRightGroupbox("Information")

InfoBox:AddLabel("FLEXMUSIX v2.0")
InfoBox:AddLabel("Made by: You")
InfoBox:AddLabel("Build: Premium3:20 PMEdition")
InfoBox:AddDivider()
InfoBox:AddLabel("Player: " .. LP.Name)
InfoBox:AddLabel("User ID: " .. LP.UserId)
InfoBox:AddLabel("Account Age: " .. LP.AccountAge .. " days")
InfoBox:AddDivider()
InfoBox:AddLabel("Press " .. C.UI.Keybind .. " to toggle menu")
end
-- Config System
ThemeManager:SetLibrary(Lib)
SaveManager:SetLibrary(Lib)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("FLEXMUSIX")
SaveManager:SetFolder("FLEXMUSIX/Configs")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
-- Watermark
Lib:SetWatermarkVisibility(true)
Lib:SetWatermark("FLEX | " .. LP.Name .. " | " .. os.date("%H:%M:%S"))
-- Update watermark time
task.spawn(function()
while task.wait(1) do
Lib:SetWatermark("FLEX | " .. LP.Name .. " | " .. os.date("%H:%M:%S"))
end
end)
-- Load config
SaveManager:LoadAutoloadConfig()
-- Initialize notification
Notify("FLEXMUSIX loaded successfully!", 3)
print("FLEXMUSIX v2.0 - Loaded")
print("Press " .. C.UI.Keybind .. " to open menu")
print("Made with precision by FLEXMUSIX")</parameter>