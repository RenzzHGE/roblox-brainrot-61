-- GameSystems: coins, buying brainrots, fusion, the GOD TUNG boss and the
-- karaoke queue. All state lives on the server; the client only shows it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeData = require(ReplicatedStorage.Shared.ThemeData)

local GameSystems = {}

local coins = {}
local owned = {}
local bossHealth = ThemeData.BossHealth
local karaokeQueue = {}

local coinsEvent = Instance.new("RemoteEvent")
coinsEvent.Name = "CoinsEvent"
coinsEvent.Parent = ReplicatedStorage

local buyEvent = Instance.new("RemoteEvent")
buyEvent.Name = "BuyEvent"
buyEvent.Parent = ReplicatedStorage

local karaokeEvent = Instance.new("RemoteEvent")
karaokeEvent.Name = "KaraokeEvent"
karaokeEvent.Parent = ReplicatedStorage

local bossEvent = Instance.new("RemoteEvent")
bossEvent.Name = "BossEvent"
bossEvent.Parent = ReplicatedStorage

local function incomePerSecond(player)
	local total = 0
	for _, entry in ipairs(owned[player] or {}) do
		local brainrot = ThemeData.getBrainrot(entry.index)
		local mutation = ThemeData.Mutations[entry.mutation or 1]
		total += brainrot.income * mutation.mult
	end
	return total
end

local function priceOf(index)
	local brainrot = ThemeData.getBrainrot(index)
	local rarity = ThemeData.getRarity(brainrot.rarity)
	return math.floor(brainrot.income * 12 * rarity.mult)
end

function GameSystems.start()
	Players.PlayerAdded:Connect(function(player)
		coins[player] = 500
		owned[player] = {}
		coinsEvent:FireClient(player, coins[player], 0)
	end)
	Players.PlayerRemoving:Connect(function(player)
		coins[player] = nil
		owned[player] = nil
	end)

	-- Coins tick once a second from everything the player owns.
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local gain = incomePerSecond(player)
				coins[player] = (coins[player] or 0) + gain
				coinsEvent:FireClient(player, coins[player], gain)
			end
		end
	end)

	-- Buy a brainrot from a stall (index 1..30).
	buyEvent.OnServerEvent:Connect(function(player, index)
		if typeof(index) ~= "number" then
			return
		end
		index = math.floor(index)
		if index < 1 or index > #ThemeData.Brainrots then
			return
		end
		local price = priceOf(index)
		if (coins[player] or 0) < price then
			buyEvent:FireClient(player, false, index, coins[player] or 0)
			return
		end
		coins[player] -= price
		table.insert(owned[player], { index = index, mutation = 1 })
		buyEvent:FireClient(player, true, index, coins[player])
	end)

	-- Fuse three of the same brainrot into one mutated copy.
	local fuseEvent = Instance.new("RemoteEvent")
	fuseEvent.Name = "FuseEvent"
	fuseEvent.Parent = ReplicatedStorage
	fuseEvent.OnServerEvent:Connect(function(player, index)
		local list = owned[player] or {}
		local found = {}
		for i, entry in ipairs(list) do
			if entry.index == index and entry.mutation == 1 and #found < 3 then
				table.insert(found, i)
			end
		end
		if #found < 3 then
			fuseEvent:FireClient(player, false, index)
			return
		end
		for i = #found, 1, -1 do
			table.remove(list, found[i])
		end
		table.insert(list, { index = index, mutation = 2 })
		fuseEvent:FireClient(player, true, index)
	end)

	-- The boss: every hit deals 25 damage; at zero it drops a GOD brainrot.
	bossEvent.OnServerEvent:Connect(function(player)
		if bossHealth <= 0 then
			return
		end
		bossHealth -= 25
		if bossHealth <= 0 then
			bossHealth = 0
			table.insert(owned[player], { index = 26, mutation = 1 })
			task.delay(30, function()
				bossHealth = ThemeData.BossHealth
			end)
		end
		bossEvent:FireAllClients(bossHealth, ThemeData.BossHealth)
	end)

	-- Karaoke queue: join with a song name, the front of the queue sings.
	karaokeEvent.OnServerEvent:Connect(function(player, song)
		if typeof(song) ~= "string" or #song == 0 or #song > 60 then
			return
		end
		for _, entry in ipairs(karaokeQueue) do
			if entry.player == player then
				return
			end
		end
		table.insert(karaokeQueue, { player = player, song = song })
		karaokeEvent:FireAllClients(karaokeQueue)
	end)
end

return GameSystems
