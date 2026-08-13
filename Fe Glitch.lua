-- FE Glitch Effect — FULLY OPAQUE, everyone sees it  
local Player = game:Players.LocalPlayer  
local pureColors = {  
Color3.new(0,0,0), Color3.new(1,0,0), Color3.new(0,1,0),  
Color3.new(0,0,1), Color3.new(1,1,1), Color3.new(1,1,0),  
Color3.new(0,1,1), Color3.new(1,0,1),  
}

local running = false

local function createGlitchPart(hrp)  
local part = Instance.new("Part")  
part.Size = Vector3.new(math.random(1,3), math.random(1,3), math.random(1,3))  
part.Anchored = false  
part.Material = Enum.Material.Neon  
part.BrickColor = BrickColor.new(pureColors[math.random(1, #pureColors)])  
part.Transparency = 0 -- FULLY OPAQUE  
part.CanCollide = false  
part.CanQuery = false  
part.CanTouch = false  
part.CastShadow = false

part.Parent = hrp.Parent

local weld = Instance.new("Weld")  
weld.Part0 = hrp  
weld.Part1 = part  
weld.C0 = CFrame.new(math.random(-4,4), math.random(-4,4), math.random(-4,4))  
weld.Parent = part

game:GetService("Debris"):AddItem(part, 0.5)  
end

local function createGlitchSprite(hrp)  
local char = hrp.Parent  
local billboard = Instance.new("BillboardGui")  
billboard.Name = "GlitchEffect"  
billboard.Size = UDim2.new(0, math.random(20,60), 0, math.random(20,60))  
billboard.StudsOffset = Vector3.new(math.random(-4,4), math.random(-4,4), math.random(-4,4))  
billboard.AlwaysOnTop = false  
billboard.Enabled = true  
billboard.ClipsDescendants = false  
billboard.Parent = char

local image = Instance.new("ImageLabel")  
image.Size = UDim2.new(1,0,1,0)  
image.BackgroundColor3 = pureColors[math.random(1, #pureColors)]  
image.BackgroundTransparency = 0 -- FULLY OPAQUE  
image.BorderSizePixel = 0  
image.Parent = billboard

game:GetService("Debris"):AddItem(billboard, 0.4)  
end

local function stopGlitch()  
running = false  
local char = Player.Character  
if char then  
for _, v in ipairs(char:GetChildren()) do  
if v:IsA("BasePart") and v.Material == Enum.Material.Neon then  
v:Destroy()  
end  
end  
for _, v in ipairs(char:GetChildren()) do  
if v:IsA("BillboardGui") and v.Name == "GlitchEffect" then  
v:Destroy()  
end  
end  
end  
end

local function startGlitch()  
if running then return end  
running = true

task.spawn(function()  
while running do  
local char = Player.Character  
local hrp = char and char:FindFirstChild("HumanoidRootPart")  
if hrp then  
for i = 1, math.random(2,4) do  
createGlitchPart(hrp)  
end  
for i = 1, math.random(2,3) do  
createGlitchSprite(hrp)  
end  
end  
task.wait(0.25)  
end  
end)  
end

Player.CharacterAdded:Connect(function(newChar)  
stopGlitch()  
newChar:WaitForChild("HumanoidRootPart")  
startGlitch()  
end)

if Player.Character then  
startGlitch()  
end  
