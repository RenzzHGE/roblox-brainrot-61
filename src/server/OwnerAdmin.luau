-- OwnerAdmin: owner-only chat commands for RenzzHGE. No PackageLink, no
-- external loader; the owner name is checked against the game's owner.

local Players = game:GetService("Players")

local OwnerAdmin = {}
local OWNER_NAME = "RenzzHGE"

local function isOwner(player)
	return player.Name == OWNER_NAME
end

function OwnerAdmin.start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			if not isOwner(player) then
				return
			end
			local args = string.split(message, " ")
			local cmd = args[1] or ""
			if cmd == ":coins" then
				local amount = tonumber(args[2]) or 1000
				local coinsEvent = game:GetService("ReplicatedStorage"):FindFirstChild("CoinsEvent")
				if coinsEvent then
					coinsEvent:FireClient(player, amount, 0)
				end
			elseif cmd == ":give" then
				local index = tonumber(args[2]) or 1
				local buyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("BuyEvent")
				if buyEvent then
					buyEvent:FireClient(player, true, index, 0)
				end
			elseif cmd == ":boss" then
				local bossEvent = game:GetService("ReplicatedStorage"):FindFirstChild("BossEvent")
				if bossEvent then
					bossEvent:FireAllClients(0, 5000)
				end
			elseif cmd == ":time" then
				local hour = tonumber(args[2]) or 17.6
				game:GetService("Lighting").ClockTime = hour
			end
		end)
	end)
end

return OwnerAdmin
