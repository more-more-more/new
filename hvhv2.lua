local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local DataStoreService = game:GetService("DataStoreService")  
local LocalPlayer = Players.LocalPlayer

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
GUIKeybind = "ins"  
}

local DataStore = DataStoreService:GetDataStore("HVHConfig")

-- Load Configuration  
local function LoadConfig()  
local success, errorMessage = pcall(function()  
local data = DataStore:GetAsync(LocalPlayer.UserId)  
if data then  
for k, v in pairs(data) do  
Config[k] = v  
end  
end)  
if not success then  
warn("Error loading config:", errorMessage)  
end  
end

-- Save Configuration  
local function SaveConfig()  
local success, errorMessage = pcall(function()  
DataStore:SetAsync(LocalPlayer.UserId, Config)  
end)  
if not success then  
warn("Error saving config:", errorMessage)  
end  
end

-- Anti-Detection (Basic)  
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

-- Create GUI  
local ScreenGui = Instance.new("ScreenGui")  
ScreenGui.Name = "HVHGui"  
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")  
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")  
MainFrame.Name = "MainFrame"  
MainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)  
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)  
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)  
MainFrame.BorderSizePixel = 0

local TabBar = Instance.new("Frame")  
TabBar.Name = "TabBar"  
TabBar.Size = UDim2.new(1, 0, 0.1, 0)  
TabBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)  
TabBar.Parent = MainFrame

local RageButton = Instance.new("TextButton")  
RageButton.Name = "RageButton"  
RageButton.Size = UDim2.new(0.25, 0, 1, 0)  
RageButton.Position = UDim2.new(0, 0, 0, 0)  
RageButton.BackgroundColor3 = Color3.new(0.3, 0, 0)  
RageButton.Text = "Rage"  
RageButton.TextColor3 = Color3.new(1, 1, 1)  
RageButton.Parent = TabBar

local LegitButton = Instance.new("TextButton")  
LegitButton.Name = "LegitButton"  
LegitButton.Size = UDim2.new(0.25, 0, 1, 0)  
LegitButton.Position = UDim2.new(0.25, 0, 0, 0)  
LegitButton.BackgroundColor3 = Color3.new(0, 0.3, 0)  
LegitButton.Text = "Legit"  
LegitButton.TextColor3 = Color3.new(1, 1, 1)  
LegitButton.Parent = TabBar

--Rage Tab Content  
local RageTab = Instance.new("Frame")  
RageTab.Name = "RageTab"  
RageTab.Size = UDim2.new(1,0,0.9,0)  
RageTab.Position = UDim2.new(0,0,0.1,0)  
RageTab.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)  
RageTab.Visible = false  
RageTab.Parent = MainFrame

local SilentAimToggle = Instance.new("TextButton")  
SilentAimToggle.Name = "SilentAimToggle"  
SilentAimToggle.Size = UDim2.new(1,0,0.1,0)  
SilentAimToggle.Position = UDim2.new(0,0,0,0)  
SilentAimToggle.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)  
SilentAimToggle.Text = "Silent Aim: " .. tostring(Config.SilentAim)  
SilentAimToggle.TextColor3 = Color3.new(1, 1, 1)  
SilentAimToggle.Parent = RageTab

SilentAimToggle.MouseButton1Click:Connect(function()  
Config.SilentAim = not Config.SilentAim  
SilentAimToggle.Text = "Silent Aim: " .. tostring(Config.SilentAim)  
SaveConfig()  
end)

-- Simple ESP Toggle  
local ESPToggle = Instance.new("TextButton")  
ESPToggle.Name = "ESPToggle"  
ESPToggle.Size = UDim2.new(1,0,0.1,0)  
ESPToggle.Position = UDim2.new(0,0,0.1,0)  
ESPToggle.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)  
ESPToggle.Text = "ESP: " .. tostring(Config.ESP)  
ESPToggle.TextColor3 = Color3.new(1, 1, 1)  
ESPToggle.Parent = RageTab

ESPToggle.MouseButton1Click:Connect(function()  
Config.ESP = not Config.ESP  
ESPToggle.Text = "ESP: " .. tostring(Config.ESP)  
SaveConfig()  
end)

-- ... (Add more toggles and sliders here - omitted for brevity.  The pattern is the same as the above.) ...

--Tab Switching  
RageButton.MouseButton1Click:Connect(function()  
RageTab.Visible = true  
end)

-- GUI Keybind Activation  
UserInputService.InputBegan:Connect(function(input, gameProcessed)  
if not gameProcessed and input.KeyCode == Enum.KeyCode[Config.GUIKeybind] then  
ScreenGui.Enabled = not ScreenGui.Enabled  
end  
end)

--ESP Backend (Same as before)  
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
ESPObjects[player] = { Billboard, NameLabel, HealthBar, HealthBarBG }  
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

-- Load config at startup  
LoadConfig()

-- Connections and Initial Setup  
RunService.Heartbeat:Connect(UpdateESP)	-- Update ESP every frame  
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

print("Mother Trucker")  