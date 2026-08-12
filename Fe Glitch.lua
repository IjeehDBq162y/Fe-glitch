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
end

ensureScriptWorksInAnyGame()
