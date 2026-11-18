-- Server bootstrap: build the world, start the systems, and make sure every
-- player gets a character (the spawn fix: CharacterAutoLoads is true in the
-- project, a static SpawnLocation sits at the top of the steps, and this
-- safety call loads the character if the engine did not already).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldBuilder = require(script.Parent.WorldBuilder)
local GameSystems = require(script.Parent.GameSystems)
local OwnerAdmin = require(script.Parent.OwnerAdmin)

WorldBuilder.build()
GameSystems.start()
OwnerAdmin.start()

local function ensureCharacter(player)
	if player.Character then
		return
	end
	local ok = pcall(function()
		player:LoadCharacter()
	end)
	if not ok then
		task.delay(1, function()
			pcall(function()
				player:LoadCharacter()
			end)
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	ensureCharacter(player)
	player.CharacterAdded:Connect(function()
		-- The static SpawnLocation is reused; never create a second one.
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	ensureCharacter(player)
end
