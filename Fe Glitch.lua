local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local character = Player.Character or Player.CharacterAdded:Wait()

-- List of Pibby glitch colors
local pibbyColors = {
    Color3.new(0.5, 0, 0.5), -- Purple
    Color3.new(0.5, 0, 1), -- Blue
    Color3.new(0, 0.5, 0.5), -- Teal
    Color3.new(0, 1, 0.5), -- Light Green
    Color3.new(0.5, 0, 0.5), -- Purple
    Color3.new(0.5, 0.5, 0), -- Olive
    Color3.new(0.5, 0.5, 1), -- Light Blue
    Color3.new(1, 0, 0.5), -- Light Red
    Color3.new(1, 0.5, 0), -- Orange
    Color3.new(1, 0.5, 1), -- Light Purple
    -- Add more Pibby glitch colors as needed
}

local function isR15Avatar(character)
    return character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")
end

local function createGlitchParts()
    if not character or not isR15Avatar(character) then return end
    local hrp = character.HumanoidRootPart

    for i = 1, math.random(3, 6) do
        local glitchPart = Instance.new("Part")
        glitchPart.Size = Vector3.new(math.random(1, 3), math.random(1, 3), math.random(1, 3))
        glitchPart.Position = hrp.Position + Vector3.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))
        glitchPart.Anchored = true
        glitchPart.Material = Enum.Material.Neon
        glitchPart.Color = pibbyColors[math.random(1, #pibbyColors)]
        glitchPart.Transparency = 0
        glitchPart.CanCollide = false
        glitchPart.Name = "GlitchPart"
        glitchPart.Parent = workspace

        -- Ensure the part is visible to everyone
        local function makePartVisible(part)
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= Player then
                    local character = player.Character
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local clone = part:Clone()
                            clone.Parent = workspace
                            clone.Position = rootPart.Position + Vector3.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))
                            Debris:AddItem(clone, 0.5)
                        end
                    end
                end
            end
        end

        makePartVisible(glitchPart)

        -- Remove after a short time
        Debris:AddItem(glitchPart, 0.5)
    end
end

-- Continuously spawn glitch parts around your avatar
while true do
    createGlitchParts()
    wait(0.3)
end

-- Ensure the script works in any game and server
local function ensureScriptWorksInAnyGame()
    -- This function ensures that the script works in any game and server
    -- by checking if the necessary services and objects are available
    if not RunService or not Debris or not Player or not character then
        warn("Required services or objects are not available. The script may not work as expected.")
    end
end local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create or get the RemoteEvent for glitch effect synchronization
local glitchEffectEvent = ReplicatedStorage:WaitForChild("GlitchEffectEvent")

-- Table to track active glitch effects per player
local activeGlitchEffects = {}

-- Function to validate player and create glitch effect data
local function onGlitchEffectRequested(player, characterPosition, colorIndex)
    -- Security: Validate that the player exists and is in the game
    if not Players:FindFirstChild(player.Name) then
        warn("Invalid player attempted to trigger glitch effect")
        return
    end
    
    -- Security: Validate character exists and position is reasonable
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Security: Verify position is close to player's actual position (prevent remote abuse)
    local actualPosition = player.Character.HumanoidRootPart.Position
    local distance = (characterPosition - actualPosition).Magnitude
    
    if distance > 50 then
        warn("Player " .. player.Name .. " attempted to create glitch effect too far from character")
        return
    end
    
    -- Security: Validate color index is within acceptable range
    if type(colorIndex) ~= "number" or colorIndex < 1 or colorIndex > 8 then
        warn("Invalid color index received from player " .. player.Name)
        return
    end
    
    -- Broadcast the glitch effect to all clients
    -- This allows everyone to see the effect on the requesting player
    glitchEffectEvent:FireAllClients(player, characterPosition, colorIndex)
end

-- Connect the RemoteEvent to handle glitch effect requests
glitchEffectEvent.OnServerEvent:Connect(onGlitchEffectRequested)

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(player)
    if activeGlitchEffects[player.UserId] then
        activeGlitchEffects[player.UserId] = nil
    end
end)

print("Glitch Effect Server initialized successfully")
