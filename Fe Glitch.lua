local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local GlitchEvent = Instance.new("RemoteEvent")
GlitchEvent.Name = "GlitchEvent"
GlitchEvent.Parent = ReplicatedStorage

local GlitchFolder = Instance.new("Folder")
GlitchFolder.Name = "GlitchEffects"
GlitchFolder.Parent = workspace

local pureColors = {
    Color3.new(0,0,0), Color3.new(1,0,0), Color3.new(0,1,0),
    Color3.new(0,0,1), Color3.new(1,1,1), Color3.new(1,1,0),
    Color3.new(0,1,1), Color3.new(1,0,1),
}

local playerParts = {}
local playerDead = {}

local function isR15(char) return char:FindFirstChild("UpperTorso") end
local function clearParts(player)
    if playerParts[player] then
        for _, p in ipairs(playerParts[player]) do if p then p:Destroy() end end
        playerParts[player] = nil
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        playerDead[p] = false
        local h = c:WaitForChild("Humanoid")
        h.Died:Connect(function() playerDead[p] = true clearParts(p) end)
    end)
end)

Players.PlayerRemoving:Connect(function(p) clearParts(p) playerDead[p] = nil end)

GlitchEvent.OnServerEvent:Connect(function(player, pos, mobile)
    if not mobile or playerDead[player] then return end
    local c = player.Character
    if not c or not isR15(c) then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChild("Humanoid")
    if not hrp or not h or h.Health <= 0 then return end
    if (hrp.Position - pos).Magnitude > 10 then return end
    
    clearParts(player)
    local parts = {}
    for i = 1, math.random(3,6) do
        local p = Instance.new("Part")
        p.Size = Vector3.new(math.random(1,3), math.random(1,3), math.random(1,3))
        p.CFrame = hrp.CFrame * CFrame.new(math.random(-4,4), math.random(-4,4), math.random(-4,4))
        p.Anchored, p.Material, p.Color = true, Enum.Material.Neon, pureColors[math.random(1,#pureColors)]
        p.Transparency, p.CanCollide, p.CastShadow = 0.1, false, false
        p.Parent = GlitchFolder
        local l = Instance.new("PointLight", p)
        l.Color, l.Brightness, l.Range = p.Color, 3, 10
        table.insert(parts, p)
        Debris:AddItem(p, 0.5)
    end
    playerParts[player] = parts
end)
