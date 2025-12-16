--[[/**
 * @author [@more-more-more]
 * @vers [1.6]
 * @create date 2025-12-16 14:54:41
 * @desc [a simple HVH gui made by @thismorechaos]
]]--

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- Anti-Detection
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args, method = {...}, getnamecallmethod()
        if method == "FireServer" and tostring(self) == "MainEvent" then
            if args[1] == "Cheese" or args[1] == "Block" then return end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- Config System
local C = {
    Silent = {On=false,FOV=120,Show=true,Col=Color3.new(1,1,1),Thick=2,Trans=0.7,Part="Head",Pred=0.13,Wall=false,Team=true},
    ESP = {On=false,Name=true,NCol=Color3.new(1,1,1),Dist=true,DCol=Color3.new(0.5,0.5,1),HP=true,HPStyle="Bar",Box=false,BCol=Color3.new(1,0,0),Fill=false,Trace=false,TCol=Color3.new(1,1,1),TFrom="Bottom",Max=2000,Team=true},
    Cam = {On=false,Key="Q",Smooth=0.18,Pred=0.135,Part="Head",Shake=false,ShakeV=3,Team=true},
    AA = {On=false,Type="Spin",Speed=15,Vel=true,VelV=20},
    Resolve = {On=false,Type="Advanced"},
    Trigger = {On=false,Delay=0.05,Chance=100,Team=true},
    Move = {Fly=false,FSpeed=60,Clip=false,Speed=false,SVal=30,InfJ=false,BHop=false},
    Spin = {On=false,Speed=25},
    Gun = {Recoil=false,Spread=false,Ammo=false,Rapid=false,RSpeed=0.03},
    Misc = {Sprint=false,WSpeed=16,JumpP=50}
}

-- Save/Load Config
local HttpService = game:GetService("HttpService")
function SaveConfig(name)
    writefile(name..".json", HttpService:JSONEncode(C))
end
function LoadConfig(name)
    if isfile(name..".json") then
        C = HttpService:JSONDecode(readfile(name..".json"))
    end
end

-- FOV Circle
local FOV = Drawing.new("Circle")
FOV.Thickness,FOV.NumSides,FOV.Radius = 2,100,120
FOV.Color,FOV.Visible,FOV.Filled,FOV.Transparency = Color3.new(1,1,1),false,false,0.7


-- ESP
local ESPCache = {}
function MakeESP(p)
    if p==LP or ESPCache[p] then return end
    
    -- Protect Drawing creation with pcall
    local success, err = pcall(function()
        ESPCache[p] = {
            N=Drawing.new("Text"),
            D=Drawing.new("Text"),
            B=Drawing.new("Square"),
            T=Drawing.new("Line"),
            HBG=Drawing.new("Square"),
            HB=Drawing.new("Square")
        }
        
        for _,v in pairs(ESPCache[p]) do
            if v.Center then 
                v.Center=true
                v.Outline=true
                v.Font=2 
            end
            if v.Thickness then 
                v.Thickness=v==ESPCache[p].B and 2 or 1.5 
            end
            if v.Filled and v~=ESPCache[p].B then 
                v.Filled=true 
            end
        end
    end)
    
    if not success then
        warn("Failed to create ESP for "..p.Name..": "..tostring(err))
        ESPCache[p] = nil
    end
end

function UpdESP()
    for p,e in pairs(ESPCache) do
        -- Check if ESP objects exist
        if not e or not e.N then 
            ESPCache[p] = nil
            continue 
        end
        
        if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                for _,v in pairs(e) do v.Visible=false end
            end)
            continue
        end
        
        local ch,hr,hu=p.Character,p.Character.HumanoidRootPart,p.Character.Humanoid
        local pos,on=Cam:WorldToViewportPoint(hr.Position)
        local dist=(hr.Position-Cam.CFrame.Position).Magnitude
        
        if not C.ESP.On or not on or dist>C.ESP.Max or (C.ESP.Team and p.Team==LP.Team) then
            pcall(function()
                for _,v in pairs(e) do v.Visible=false end
            end)
            continue
        end
        
        pcall(function()
            if C.ESP.Name then 
                e.N.Text=p.Name
                e.N.Position=Vector2.new(pos.X,pos.Y-35)
                e.N.Color=C.ESP.NCol
                e.N.Size=15
                e.N.Visible=true 
            else 
                e.N.Visible=false 
            end
            
            if C.ESP.Dist then 
                e.D.Text=math.floor(dist).."m"
                e.D.Position=Vector2.new(pos.X,pos.Y+15)
                e.D.Color=C.ESP.DCol
                e.D.Size=13
                e.D.Visible=true 
            else 
                e.D.Visible=false 
            end
            
            if C.ESP.Box and ch:FindFirstChild("Head") then
                local hp,lp=Cam:WorldToViewportPoint(ch.Head.Position+Vector3.new(0,0.5,0)),Cam:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
                local h,w=math.abs(hp.Y-lp.Y),math.abs(hp.Y-lp.Y)*0.5
                e.B.Size=Vector2.new(w,h)
                e.B.Position=Vector2.new(pos.X-w/2,hp.Y)
                e.B.Color=C.ESP.BCol
                e.B.Filled=C.ESP.Fill
                e.B.Visible=true
            else 
                e.B.Visible=false 
            end
            
            if C.ESP.Trace then
                local o=C.ESP.TFrom=="Bottom" and Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y) or Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
                e.T.From=o
                e.T.To=Vector2.new(pos.X,pos.Y)
                e.T.Color=C.ESP.TCol
                e.T.Visible=true
            else 
                e.T.Visible=false 
            end
            
            if C.ESP.HP and ch:FindFirstChild("Head") then
                local hp,lp=Cam:WorldToViewportPoint(ch.Head.Position+Vector3.new(0,0.5,0)),Cam:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
                local h,w,hp_pct=math.abs(hp.Y-lp.Y),math.abs(hp.Y-lp.Y)*0.5,hu.Health/hu.MaxHealth
                e.HBG.Size=Vector2.new(3,h)
                e.HBG.Position=Vector2.new(pos.X-w/2-6,hp.Y)
                e.HBG.Color=Color3.new(0,0,0)
                e.HBG.Visible=true
                e.HB.Size=Vector2.new(3,h*hp_pct)
                e.HB.Position=Vector2.new(pos.X-w/2-6,hp.Y+(h*(1-hp_pct)))
                e.HB.Color=Color3.new(1-hp_pct,hp_pct,0)
                e.HB.Visible=true
            else 
                e.HBG.Visible=false
                e.HB.Visible=false 
            end
        end)
    end
end

-- Target System
function GetTarget()
    local t,md=nil,math.huge
    local mp=UIS:GetMouseLocation()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild(C.Silent.Part) then
            if C.Silent.Team and p.Team==LP.Team then continue end
            local pt,ps=p.Character[C.Silent.Part],Cam:WorldToViewportPoint(p.Character[C.Silent.Part].Position)
            if ps then
                local d=(Vector2.new(ps.X,ps.Y)-mp).Magnitude
                if d<C.Silent.FOV and d<md then
                    if C.Silent.Wall then
                        local r=Ray.new(Cam.CFrame.Position,(pt.Position-Cam.CFrame.Position).Unit*500)
                        local h=workspace:FindPartOnRayWithIgnoreList(r,{LP.Character})
                        if h and h:IsDescendantOf(p.Character) then t,md=p,d end
                    else t,md=p,d end
                end
            end
        end
    end
    return t
end

function Predict(t)
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local h=t.Character.HumanoidRootPart
    local p=h.Position+(h.Velocity*C.Silent.Pred)
    if C.Resolve.On and C.Resolve.Type=="Advanced" then
        p=p+Vector3.new(math.sin(tick()*8)*2.5,0,math.cos(tick()*8)*2.5)
    end
    return p
end

-- Silent Aim
UIS.InputBegan:Connect(function(i,g)
    if g or i.UserInputType~=Enum.UserInputType.MouseButton1 or not C.Silent.On then return end
    local t=GetTarget()
    if t then
        local p=Predict(t)
        if p then
            local o=Cam.CFrame
            Cam.CFrame=CFrame.lookAt(Cam.CFrame.Position,p)
            task.wait(0.03)
            Cam.CFrame=o
        end
    end
end)

-- CamLock
local CamTgt=nil
UIS.InputBegan:Connect(function(i)
    if i.KeyCode==Enum.KeyCode[C.Cam.Key] and C.Cam.On then
        CamTgt=CamTgt and nil or GetTarget()
    end
end)

RS.RenderStepped:Connect(function()
    if C.Cam.On and CamTgt and CamTgt.Character and CamTgt.Character:FindFirstChild(C.Cam.Part) then
        local pt=CamTgt.Character[C.Cam.Part]
        local p=pt.Position+(pt.Velocity*C.Cam.Pred)
        if C.Cam.Shake then p=p+Vector3.new(math.random(-C.Cam.ShakeV,C.Cam.ShakeV)/10,math.random(-C.Cam.ShakeV,C.Cam.ShakeV)/10,0) end
        Cam.CFrame=Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position,p),C.Cam.Smooth)
    end
end)

-- Anti-Aim
RS.Heartbeat:Connect(function()
    if C.AA.On and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local h=LP.Character.HumanoidRootPart
        if C.AA.Type=="Spin" then h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(C.AA.Speed),0)
        elseif C.AA.Type=="Jitter" then h.CFrame=h.CFrame*CFrame.Angles(0,math.rad((tick()%0.3<0.15) and 90 or -90),0)
        elseif C.AA.Type=="Random" then h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(math.random(-180,180)),0) end
        if C.AA.Vel then h.Velocity=Vector3.new(math.sin(tick()*10)*C.AA.VelV,h.Velocity.Y,math.cos(tick()*10)*C.AA.VelV) end
    end
end)

-- Movement
local flyBV,flyBG
RS.Heartbeat:Connect(function()
    local ch=LP.Character
    if not ch then return end
    local hr,hu=ch:FindFirstChild("HumanoidRootPart"),ch:FindFirstChild("Humanoid")
    if not hr or not hu then return end
    
    if C.Move.Fly then
        if not flyBV then
            flyBV=Instance.new("BodyVelocity",hr)
            flyBV.MaxForce=Vector3.new(9e9,9e9,9e9)
            flyBG=Instance.new("BodyGyro",hr)
            flyBG.MaxTorque=Vector3.new(9e9,9e9,9e9)
        end
        local v=Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+Cam.CFrame.LookVector*C.Move.FSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-Cam.CFrame.LookVector*C.Move.FSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-Cam.CFrame.RightVector*C.Move.FSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+Cam.CFrame.RightVector*C.Move.FSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then v=v+Vector3.new(0,C.Move.FSpeed,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v=v-Vector3.new(0,C.Move.FSpeed,0) end
        flyBV.Velocity,flyBG.CFrame=v,Cam.CFrame
    else
        if flyBV then flyBV:Destroy() flyBV=nil end
        if flyBG then flyBG:Destroy() flyBG=nil end
    end
    
    if C.Move.Clip then for _,v in pairs(ch:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end
    hu.WalkSpeed=C.Move.Speed and C.Move.SVal or C.Misc.WSpeed
    if C.Move.InfJ and UIS:IsKeyDown(Enum.KeyCode.Space) then hu:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Spinbot
RS.RenderStepped:Connect(function()
    if C.Spin.On and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame=LP.Character.HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(C.Spin.Speed),0)
    end
end)

-- FOV Update
RS.RenderStepped:Connect(function()
    FOV.Visible,FOV.Radius,FOV.Color,FOV.Transparency,FOV.Thickness=C.Silent.Show and C.Silent.On,C.Silent.FOV,C.Silent.Col,C.Silent.Trans,C.Silent.Thick
    FOV.Position=UIS:GetMouseLocation()
end)

-- ESP Update
RS.RenderStepped:Connect(UpdESP)

-- Player Setup
for _,p in pairs(Players:GetPlayers()) do
    if p.Character then MakeESP(p) end
    p.CharacterAdded:Connect(function() if C.ESP.On then MakeESP(p) end end)
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() if C.ESP.On then MakeESP(p) end end)
end)

-- UI Library
loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Lib=loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Save=loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
local Theme=loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()

local Win=Lib:CreateWindow({Title="HVH GUI | Professional",Center=true,AutoShow=true,TabPadding=8})
local Tabs={Aim=Win:AddTab("Aimbot"),Vis=Win:AddTab("Visuals"),AA=Win:AddTab("Anti-Aim"),Move=Win:AddTab("Movement"),Misc=Win:AddTab("Misc"),Cfg=Win:AddTab("Config")}

-- Aimbot Tab
local SilentBox=Tabs.Aim:AddLeftGroupbox("Silent Aim")
SilentBox:AddToggle("SilentOn",{Text="Enable Silent Aim",Default=false,Callback=function(v) C.Silent.On=v end})
SilentBox:AddSlider("SilentFOV",{Text="FOV Size",Default=120,Min=10,Max=500,Rounding=0,Callback=function(v) C.Silent.FOV=v end})
SilentBox:AddToggle("ShowFOV",{Text="Show FOV Circle",Default=true,Callback=function(v) C.Silent.Show=v end})
SilentBox:AddLabel("FOV Color"):AddColorPicker("FOVCol",{Default=Color3.new(1,1,1),Callback=function(v) C.Silent.Col=v end})
SilentBox:AddSlider("FOVTrans",{Text="FOV Transparency",Default=0.7,Min=0,Max=1,Rounding=2,Callback=function(v) C.Silent.Trans=v end})
SilentBox:AddSlider("FOVThick",{Text="FOV Thickness",Default=2,Min=1,Max=5,Rounding=0,Callback=function(v) C.Silent.Thick=v end})
SilentBox:AddDropdown("SilentPart",{Values={"Head","UpperTorso","LowerTorso","HumanoidRootPart"},Default=1,Multi=false,Text="Target Part",Callback=function(v) C.Silent.Part=v end})
SilentBox:AddSlider("SilentPred",{Text="Prediction",Default=0.13,Min=0,Max=0.5,Rounding=3,Callback=function(v) C.Silent.Pred=v end})
SilentBox:AddToggle("SilentWall",{Text="Visibility Check",Default=false,Callback=function(v) C.Silent.Wall=v end})
SilentBox:AddToggle("SilentTeam",{Text="Team Check",Default=true,Callback=function(v) C.Silent.Team=v end})

local CamBox=Tabs.Aim:AddRightGroupbox("CamLock")
CamBox:AddToggle("CamOn",{Text="Enable CamLock",Default=false,Callback=function(v) C.Cam.On=v end})
CamBox:AddLabel("Lock Key"):AddKeyPicker("CamKey",{Default="Q",SyncToggleState=false,Mode="Toggle",Text="CamLock Key",Callback=function(v) C.Cam.Key=v.Name end})
CamBox:AddSlider("CamSmooth",{Text="Smoothness",Default=0.18,Min=0.01,Max=1,Rounding=2,Callback=function(v) C.Cam.Smooth=v end})
CamBox:AddSlider("CamPred",{Text="Prediction",Default=0.135,Min=0,Max=0.5,Rounding=3,Callback=function(v) C.Cam.Pred=v end})
CamBox:AddDropdown("CamPart",{Values={"Head","UpperTorso","LowerTorso","HumanoidRootPart"},Default=1,Multi=false,Text="Target Part",Callback=function(v) C.Cam.Part=v end})
CamBox:AddToggle("CamShake",{Text="Camera Shake",Default=false,Callback=function(v) C.Cam.Shake=v end})
CamBox:AddSlider("CamShakeV",{Text="Shake Amount",Default=3,Min=1,Max=10,Rounding=0,Callback=function(v) C.Cam.ShakeV=v end})
CamBox:AddToggle("CamTeam",{Text="Team Check",Default=true,Callback=function(v) C.Cam.Team=v end})

local TrigBox=Tabs.Aim:AddLeftGroupbox("TriggerBot")
TrigBox:AddToggle("TrigOn",{Text="Enable TriggerBot",Default=false})
TrigBox:AddSlider("TrigDelay",{Text="Delay (seconds)",Default=0.05,Min=0,Max=0.5,Rounding=2})
TrigBox:AddSlider("TrigChance",{Text="Hit Chance %",Default=100,Min=1,Max=100,Rounding=0})

-- Visuals Tab
local ESPBox=Tabs.Vis:AddLeftGroupbox("ESP Settings")
ESPBox:AddToggle("ESPOn",{Text="Enable ESP",Default=false,Callback=function(v) C.ESP.On=v if v then for _,p in pairs(Players:GetPlayers()) do if p.Character then MakeESP(p) end end end end})
ESPBox:AddToggle("ESPName",{Text="Show Names",Default=true,Callback=function(v) C.ESP.Name=v end})
ESPBox:AddLabel("Name Color"):AddColorPicker("ESPNCol",{Default=Color3.new(1,1,1),Callback=function(v) C.ESP.NCol=v end})
ESPBox:AddToggle("ESPDist",{Text="Show Distance",Default=true,Callback=function(v) C.ESP.Dist=v end})
ESPBox:AddLabel("Distance Color"):AddColorPicker("ESPDCol",{Default=Color3.fromRGB(128,128,255),Callback=function(v) C.ESP.DCol=v end})
ESPBox:AddToggle("ESPHP",{Text="Health Bar",Default=true,Callback=function(v) C.ESP.HP=v end})
ESPBox:AddDropdown("ESPHPStyle",{Values={"Bar","Gradient"},Default=2,Multi=false,Text="Health Style",Callback=function(v) C.ESP.HPStyle=v end})
ESPBox:AddSlider("ESPMax",{Text="Max Distance",Default=2000,Min=100,Max=5000,Rounding=0,Callback=function(v) C.ESP.Max=v end})
ESPBox:AddToggle("ESPTeam",{Text="Team Check",Default=true,Callback=function(v) C.ESP.Team=v end})

local ESPBox2=Tabs.Vis:AddRightGroupbox("ESP Extras")
ESPBox2:AddToggle("ESPBox",{Text="Boxes",Default=false,Callback=function(v) C.ESP.Box=v end})
ESPBox2:AddLabel("Box Color"):AddColorPicker("ESPBCol",{Default=Color3.fromRGB(255,0,0),Callback=function(v) C.ESP.BCol=v end})
ESPBox2:AddToggle("ESPFill",{Text="Filled Boxes",Default=false,Callback=function(v) C.ESP.Fill=v end})
ESPBox2:AddToggle("ESPTrace",{Text="Tracers",Default=false,Callback=function(v) C.ESP.Trace=v end})
ESPBox2:AddLabel("Tracer Color"):AddColorPicker("ESPTCol",{Default=Color3.new(1,1,1),Callback=function(v) C.ESP.TCol=v end})
ESPBox2:AddDropdown("ESPTFrom",{Values={"Bottom","Middle"},Default=1,Multi=false,Text="Tracer Origin",Callback=function(v) C.ESP.TFrom=v end})

-- Anti-Aim Tab
local AABox=Tabs.AA:AddLeftGroupbox("Anti-Aim")
AABox:AddToggle("AAOn",{Text="Enable Anti-Aim",Default=false,Callback=function(v) C.AA.On=v end})
AABox:AddDropdown("AAType",{Values={"Spin","Jitter","Random"},Default=1,Multi=false,Text="AA Type",Callback=function(v) C.AA.Type=v end})
AABox:AddSlider("AASpeed",{Text="Speed",Default=15,Min=1,Max=50,Rounding=0,Callback=function(v) C.AA.Speed=v end})
AABox:AddToggle("AAVel",{Text="Velocity Spoof",Default=true,Callback=function(v) C.AA.Vel=v end})
AABox:AddSlider("AAVelV",{Text="Velocity Amount",Default=20,Min=5,Max=50,Rounding=0,Callback=function(v) C.AA.VelV=v end})

local ResolveBox=Tabs.AA:AddRightGroupbox("Resolver")
ResolveBox:AddToggle("ResolveOn",{Text="Enable Resolver",Default=false,Callback=function(v) C.Resolve.On=v end})
ResolveBox:AddDropdown("ResolveType",{Values={"Basic","Advanced","Delta"},Default=2,Multi=false,Text="Resolver Type",Callback=function(v) C.Resolve.Type=v end})

local SpinBox=Tabs.AA:AddLeftGroupbox("Spinbot")
SpinBox:AddToggle("SpinOn",{Text="Enable Spinbot",Default=false,Callback=function(v) C.Spin.On=v end})
SpinBox:AddSlider("SpinSpeed",{Text="Spin Speed",Default=25,Min=1,Max=100,Rounding=0,Callback=function(v) C.Spin.Speed=v end})

-- Movement Tab
local FlyBox=Tabs.Move:AddLeftGroupbox("Flight")
FlyBox:AddToggle("FlyOn",{Text="Enable Fly",Default=false,Callback=function(v) C.Move.Fly=v end})
FlyBox:AddSlider("FlySpeed",{Text="Fly Speed",Default=60,Min=10,Max=200,Rounding=0,Callback=function(v) C.Move.FSpeed=v end})
FlyBox:AddLabel("Controls: WASD + Space/Shift")

local MoveBox=Tabs.Move:AddRightGroupbox("Movement")
MoveBox:AddToggle("NoClip",{Text="No Clip",Default=false,Callback=function(v) C.Move.Clip=v end})
MoveBox:AddToggle("SpeedOn",{Text="Speed Hack",Default=false,Callback=function(v) C.Move.Speed=v end})
MoveBox:AddSlider("SpeedVal",{Text="Speed Value",Default=30,Min=16,Max=200,Rounding=0,Callback=function(v) C.Move.SVal=v end})
MoveBox:AddToggle("InfJump",{Text="Infinite Jump",Default=false,Callback=function(v) C.Move.InfJ=v end})
MoveBox:AddToggle("BHop",{Text="Bunny Hop",Default=false,Callback=function(v) C.Move.BHop=v end})

-- Misc Tab
local MiscBox=Tabs.Misc:AddLeftGroupbox("Character")
MiscBox:AddToggle("Sprint",{Text="Auto Sprint",Default=false,Callback=function(v) C.Misc.Sprint=v end})
MiscBox:AddSlider("WSpeed",{Text="Walk Speed",Default=16,Min=16,Max=100,Rounding=0,Callback=function(v) C.Misc.WSpeed=v end})
MiscBox:AddSlider("JumpP",{Text="Jump Power",Default=50,Min=50,Max=200,Rounding=0,Callback=function(v) C.Misc.JumpP=v end})

local UtilBox=Tabs.Misc:AddRightGroupbox("Utilities")
UtilBox:AddButton("Rejoin Server",function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
UtilBox:AddButton("Server Hop",function()
    local servers=game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _,v in pairs(servers.data) do
        if v.id~=game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,v.id,LP)
            break
        end
    end
end)

-- Config Tab
Save:SetLibrary(Lib)
Theme:SetLibrary(Lib)
Save:SetFolder("HVH_Pro")
Theme:SetFolder("HVH_Pro")
Save:BuildConfigSection(Tabs.Cfg)
Theme:ApplyToTab(Tabs.Cfg)
Lib:SetWatermarkVisibility(true)
Lib:SetWatermark("HVH GUI Pro | "..LP.Name)
Lib:Notify("HVH GUI Loaded!")

Save:LoadAutoloadConfig()