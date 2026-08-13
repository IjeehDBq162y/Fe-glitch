====================================================================
  GLITCH EFFECT SYSTEM â€” FE-COMPLIANT | SERVER-AUTHORITATIVE
====================================================================
  How to install:
  1. Create a Script in ServerScriptService â†’ paste SERVER code
  2. Create a LocalScript in StarterPlayerScripts â†’ paste CLIENT code
====================================================================


========================================
  PART 1 â€” SERVER (ServerScriptService)
========================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Safety check: this MUST run on the server
if RunService:IsClient() then
	warn("[GlitchSystem] Server script ran on client â€” destroying.")
	script:Destroy()
	return
end

-- Create the remote that clients will fire
local GlitchEvent = Instance.new("RemoteEvent")
GlitchEvent.Name = "GlitchEffectRemote"
GlitchEvent.Parent = ReplicatedStorage

-- Folder to hold visual parts (cleaned automatically)
local GlitchFolder = Instance.new("Folder")
GlitchFolder.Name = "GlitchEffects"
GlitchFolder.Parent = workspace

-- Color palette for the glitch parts
local GLITCH_COLORS = {
	Color3.new(0, 0, 0),
	Color3.new(1, 0, 0),
	Color3.new(0, 1, 0),
	Color3.new(0, 0, 1),
	Color3.new(1, 1, 1),
	Color3.new(1, 1, 0),
	Color3.new(0, 1, 1),
	Color3.new(1, 0, 1),
}

-- Track active parts per player so they can be cleaned up
local activeEffects = {}
local isDead = {}

-- Helpers
local function isR15(character)
	return character:FindFirstChild("UpperTorso") ~= nil
end

local function clearPlayerEffects(player)
	local parts = activeEffects[player]
	if parts then
		for _, part in ipairs(parts) do
			if part and part.Parent then
				part:Destroy()
			end
		end
		activeEffects[player] = nil
	end
end

-- Character tracking
local function setupCharacter(player, character)
	isDead[player] = false

	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		isDead[player] = true
		clearPlayerEffects(player)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)

	-- If character already exists (e.g. respawn mid-game)
	if player.Character then
		setupCharacter(player, player.Character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	clearPlayerEffects(player)
	isDead[player] = nil
end)

-- The core: server receives request, validates, spawns effects
GlitchEvent.OnServerEvent:Connect(function(player, originPosition)
	-- === VALIDATION LAYER ===

	-- 1. Must provide a position
	if not originPosition then return end

	-- 2. Player must not be dead
	if isDead[player] then return end

	-- 3. Character must exist and be R15
	local character = player.Character
	if not character or not isR15(character) then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoidRootPart or not humanoid then return end
	if humanoid.Health <= 0 then return end

	-- 4. Distance check â€” client position must be near the character
	--    Prevents teleport-abuse / wall-glitch exploitation
	if (humanoidRootPart.Position - originPosition).Magnitude > 15 then
		warn(string.format("[GlitchSystem] %s rejected â€” position mismatch", player.Name))
		return
	end

	-- 5. Rate-limit: minimum 1 second between triggers per player
	if activeEffects[player] and #activeEffects[player] > 0 then
		return  -- Already has active glitch parts
	end

	-- === EFFECT GENERATION ===
	clearPlayerEffects(player)

	local parts = {}
	local partCount = math.random(3, 6)

	for i = 1, partCount do
		local part = Instance.new("Part")
		part.Size = Vector3.new(
			math.random(1, 3),
			math.random(1, 3),
			math.random(1, 3)
		)
		part.CFrame = humanoidRootPart.CFrame * CFrame.new(
			math.random(-5, 5),
			math.random(-4, 4),
			math.random(-5, 5)
		)
		part.Anchored = true
		part.Material = Enum.Material.Neon
		part.Color = GLITCH_COLORS[math.random(1, #GLITCH_COLORS)]
		part.Transparency = 0.1
		part.CanCollide = false
		part.CastShadow = false
		part.Parent = GlitchFolder

		-- PointLight for the neon glow
		local light = Instance.new("PointLight")
		light.Color = part.Color
		light.Brightness = 3
		light.Range = 10
		light.Parent = part

		table.insert(parts, part)

		-- Auto-cleanup after 0.6 seconds
		Debris:AddItem(part, 0.6)
	end

	activeEffects[player] = parts

	-- Clean up the reference after the parts are gone
	task.delay(0.7, function()
		activeEffects[player] = nil
	end)
end)

print("[GlitchSystem] Server loaded â€” ready for glitch effects.")


========================================
  PART 2 â€” CLIENT (StarterPlayerScripts)
========================================
--[[
	Place this LocalScript in:
		StarterPlayer > StarterPlayerScripts

	Press the G key to trigger the glitch effect on your character.
	All players in the server will see it.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Safety: must run on client
if not RunService:IsClient() then
	script:Destroy()
	return
end

local player = Players.LocalPlayer
local glitchEvent = ReplicatedStorage:WaitForChild("GlitchEffectRemote")

-- Cooldown so we don't spam the server
local cooldown = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- Ignore if user is typing in chat or a UI textbox
	if gameProcessed then return end

	-- Trigger on the G key
	if input.KeyCode == Enum.KeyCode.G then
		if cooldown then return end
		cooldown = true

		-- Fire the remote with the character's current position
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				glitchEvent:FireServer(hrp.Position)
			end
		end

		-- 1-second cooldown
		task.delay(1, function()
			cooldown = false
		end)
	end
end)

print("[GlitchSystem] Client loaded â€” press G to glitch.")
