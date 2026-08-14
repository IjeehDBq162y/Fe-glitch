-- FE Glitch — Colored blocks orbiting you, no flashing lights  
-- Execute = glitch appears. Die/respawn = gone forever. Re-execute to bring back.

local Player = game.Players.LocalPlayer  
local pureColors = {  
Color3.new(0,0,0),   -- Black  
Color3.new(1,0,0),   -- Red  
Color3.new(0,1,0),   -- Green  
Color3.new(0,0,1),   -- Blue  
Color3.new(1,1,1),   -- White  
Color3.new(1,1,0),   -- Yellow  
Color3.new(0,1,1),   -- Cyan  
Color3.new(1,0,1),   -- Magenta  
}

local TAG = "OrbitGlitch"

local function killAllGlitchParts(char)  
if not char then return end  
for _, v in ipairs(char:GetChildren()) do  
pcall(function()  
if v:IsA("BasePart") and v:GetAttribute(TAG) then  
v:Destroy()  
end  
end)  
end  
end

local function startGlitch()  
local char = Player.Character  
if not char then return end  
local hrp = char:FindFirstChild("HumanoidRootPart")  
if not hrp then return end

local angle = 0  
local running = true

local hum = char:FindFirstChild("Humanoid")  
if hum then  
hum.Died:Connect(function()  
running = false  
killAllGlitchParts(char)  
end)  
end

task.spawn(function()  
while running do  
if not char.Parent then running = false break end  
for i = 1, 4 do  
local blockAngle = angle + (i * math.pi / 2)  
local radius = math.random(3,6)  
local height = math.random(-4,4)  
local x = math.sin(blockAngle) * radius  
local z = math.cos(blockAngle) * radius

local glitchPart = Instance.new("Part")  
glitchPart.Size = Vector3.new(math.random(1,3), math.random(1,3), math.random(1,3))  
glitchPart.Position = hrp.Position + Vector3.new(x, height, z)  
glitchPart.Anchored = true  
glitchPart.Material = Enum.Material.Neon  
glitchPart.BrickColor = BrickColor.new(pureColors[math.random(1, #pureColors)])  
glitchPart.Transparency = 0  
glitchPart.CanCollide = false  
glitchPart:SetAttribute(TAG, true)  
glitchPart.Parent = hrp.Parent -- FE replication = everyone sees it

game:GetService("Debris"):AddItem(glitchPart, 0.5)  
end  
angle = angle + 0.3  
task.wait(0.3)  
end  
end)  
end

-- Clean leftovers and start  
killAllGlitchParts(Player.Character)  
startGlitch()  
