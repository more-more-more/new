local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Anti-Detection (unchanged)  
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

-- Config (Oxygen handles saving.  Initial default values)  
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
HBSize = 2,  
Camlock = false,  
CamlockSmoothness = 5,  
Fly = false,  
Noclip = false,  
ToggleKey = 49 -- Example: Number '1' key  
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

-- Camlock  
local camlockEnabled = false  
local camlockSmoothness = Config.CamlockSmoothness

local function Camlock()  
if camlockEnabled then  
Camera.CameraType = Enum.CameraType.Scriptable  
local character = LocalPlayer.Character  
if character and character:FindFirstChild("HumanoidRootPart") then  
local headCFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)  
Camera.CFrame = headCFrame  
-- Add smoothness here.  Lerp the Camera.CFrame towards headCFrame over time.  
-- Example: Camera.CFrame = Camera.CFrame:Lerp(headCFrame, camlockSmoothness)  
end  
else  
Camera.CameraType = Enum.CameraType.Custom  
end  
end

-- Fly  
local flyEnabled = false

local function Fly()  
if flyEnabled then  
LocalPlayer.Character.Humanoid.WalkSpeed = 50  
LocalPlayer.Character.Humanoid.JumpPower = 100  
UserInputService.SetEnumParameter("Enum.KeyCode.Space", "Jump", false)  
LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)  
else  
LocalPlayer.Character.Humanoid.WalkSpeed = 16  
LocalPlayer.Character.Humanoid.JumpPower = 50  
UserInputService.SetEnumParameter("Enum.KeyCode.Space", "Jump", true)  
end  
end

-- Noclip (Placeholder - Needs collision bypass implementation)  
local noclipEnabled = false

local function Noclip()  
if noclipEnabled then  
--Implement collision bypass here  
print("Noclip enabled (collision bypass not implemented)")  
else  
--Implement normal collision here  
print("Noclip disabled")  
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

-- Hook UserInputService for Silent Aim  
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
task.wait(0.1) --Adjust Timing  
Camera.CFrame = cameraCFrame --Restore original camera  
end  
end  
end  
end  
end)

-- TriggerBot Backend (Placeholder - Needs more robust implementation)  
local function StartTriggerBot()  
if Config.TriggerBot then  
--Implement triggerbot logic here  
print ("Trigger Bot activated")  
end  
end

-- Toggle GUI Keybind  
UserInputService.InputBegan:Connect(function(input, gameProcessed)  
if input.KeyCode == Config.ToggleKey and not gameProcessed then  
--Toggle camlock, fly and noclip  
camlockEnabled = not camlockEnabled  
flyEnabled = not flyEnabled  
noclipEnabled = not noclipEnabled

Camlock()  
Fly()  
Noclip()  
end  
end)

-- Connections and Startup  
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