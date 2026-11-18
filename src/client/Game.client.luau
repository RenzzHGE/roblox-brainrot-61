-- Client UI: a hangout interface only. Bottom chat bar, karaoke queue panel,
-- a small wallet chip and a round MENU button. No yellow coins bar, no left
-- button stack, no ABILITY/ATTACK buttons.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "HangoutGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Small wallet chip, top right.
local wallet = Instance.new("TextLabel")
wallet.Name = "WalletChip"
wallet.AnchorPoint = Vector2.new(1, 0)
wallet.Position = UDim2.new(1, -16, 0, 16)
wallet.Size = UDim2.fromOffset(190, 44)
wallet.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
wallet.BackgroundTransparency = 0.15
wallet.TextColor3 = Color3.fromRGB(255, 214, 90)
wallet.TextSize = 20
wallet.Font = Enum.Font.GothamBold
wallet.Text = "500 coins"
wallet.Parent = gui
local walletCorner = Instance.new("UICorner")
walletCorner.CornerRadius = UDim.new(0, 12)
walletCorner.Parent = wallet

-- Karaoke queue panel, top left.
local karaoke = Instance.new("Frame")
karaoke.Name = "KaraokeQueue"
karaoke.Position = UDim2.fromOffset(16, 16)
karaoke.Size = UDim2.fromOffset(260, 150)
karaoke.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
karaoke.BackgroundTransparency = 0.2
karaoke.Parent = gui
local karaokeCorner = Instance.new("UICorner")
karaokeCorner.CornerRadius = UDim.new(0, 12)
karaokeCorner.Parent = karaoke
local karaokeTitle = Instance.new("TextLabel")
karaokeTitle.Size = UDim2.new(1, 0, 0, 36)
karaokeTitle.BackgroundTransparency = 1
karaokeTitle.Text = "KARAOKE  •  antrean"
karaokeTitle.TextColor3 = Color3.fromRGB(255, 150, 200)
karaokeTitle.TextSize = 18
karaokeTitle.Font = Enum.Font.GothamBold
karaokeTitle.Parent = karaoke
local karaokeList = Instance.new("TextLabel")
karaokeList.Name = "QueueList"
karaokeList.Position = UDim2.new(0, 12, 0, 40)
karaokeList.Size = UDim2.new(1, -24, 1, -48)
karaokeList.BackgroundTransparency = 1
karaokeList.Text = "Belum ada yang antre.\nKetik /nyanyi <lagu> untuk ikut."
karaokeList.TextColor3 = Color3.fromRGB(230, 225, 245)
karaokeList.TextSize = 15
karaokeList.Font = Enum.Font.Gotham
karaokeList.TextWrapped = true
karaokeList.TextXAlignment = Enum.TextXAlignment.Left
karaokeList.TextYAlignment = Enum.TextYAlignment.Top
karaokeList.Parent = karaoke

-- Round MENU button, bottom right.
local menu = Instance.new("TextButton")
menu.Name = "MenuButton"
menu.AnchorPoint = Vector2.new(1, 1)
menu.Position = UDim2.new(1, -20, 1, -20)
menu.Size = UDim2.fromOffset(72, 72)
menu.BackgroundColor3 = Color3.fromRGB(150, 90, 220)
menu.Text = "MENU"
menu.TextColor3 = Color3.fromRGB(255, 255, 255)
menu.TextSize = 16
menu.Font = Enum.Font.GothamBold
menu.Parent = gui
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0.5, 0)
menuCorner.Parent = menu

-- Bottom chat bar.
local chat = Instance.new("TextBox")
chat.Name = "ChatBar"
chat.AnchorPoint = Vector2.new(0.5, 1)
chat.Position = UDim2.new(0.5, 0, 1, -16)
chat.Size = UDim2.fromOffset(520, 44)
chat.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
chat.BackgroundTransparency = 0.2
chat.TextColor3 = Color3.fromRGB(255, 255, 255)
chat.PlaceholderText = "Ngobrol di sini…  /nyanyi <lagu> untuk karaoke"
chat.TextSize = 16
chat.Font = Enum.Font.Gotham
chat.Parent = gui
local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 12)
chatCorner.Parent = chat

-- Boss health bar, top centre (only visible during the fight).
local bossBar = Instance.new("Frame")
bossBar.Name = "BossBar"
bossBar.AnchorPoint = Vector2.new(0.5, 0)
bossBar.Position = UDim2.new(0.5, 0, 0, 16)
bossBar.Size = UDim2.fromOffset(360, 30)
bossBar.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
bossBar.BackgroundTransparency = 0.2
bossBar.Visible = false
bossBar.Parent = gui
local bossFill = Instance.new("Frame")
bossFill.Name = "Fill"
bossFill.Size = UDim2.fromScale(1, 1)
bossFill.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
bossFill.BorderSizePixel = 0
bossFill.Parent = bossBar
local bossText = Instance.new("TextLabel")
bossText.Size = UDim2.fromScale(1, 1)
bossText.BackgroundTransparency = 1
bossText.Text = "GOD TUNG"
bossText.TextColor3 = Color3.fromRGB(255, 255, 255)
bossText.TextSize = 16
bossText.Font = Enum.Font.GothamBold
bossText.Parent = bossBar

-- Menu panel (hidden until MENU is tapped).
local menuPanel = Instance.new("Frame")
menuPanel.Name = "MenuPanel"
menuPanel.AnchorPoint = Vector2.new(0.5, 0.5)
menuPanel.Position = UDim2.fromScale(0.5, 0.5)
menuPanel.Size = UDim2.fromOffset(320, 260)
menuPanel.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
menuPanel.Visible = false
menuPanel.Parent = gui
local menuPanelCorner = Instance.new("UICorner")
menuPanelCorner.CornerRadius = UDim.new(0, 14)
menuPanelCorner.Parent = menuPanel
local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, 0, 0, 40)
menuTitle.BackgroundTransparency = 1
menuTitle.Text = "BRAINROT MEGA UNIVERSE"
menuTitle.TextColor3 = Color3.fromRGB(255, 214, 90)
menuTitle.TextSize = 18
menuTitle.Font = Enum.Font.GothamBold
menuTitle.Parent = menuPanel
local menuBody = Instance.new("TextLabel")
menuBody.Position = UDim2.new(0, 16, 0, 48)
menuBody.Size = UDim2.new(1, -32, 1, -60)
menuBody.BackgroundTransparency = 1
menuBody.Text = "Hangout di hutan pinus saat senja.\nBeli brainrot di kios, fusion 3 jadi 1,\nlawan GOD TUNG di arena hutan.\n\nMode: Hangout • Steal • Tycoon • Obby • Arena"
menuBody.TextColor3 = Color3.fromRGB(230, 225, 245)
menuBody.TextSize = 15
menuBody.Font = Enum.Font.Gotham
menuBody.TextWrapped = true
menuBody.TextXAlignment = Enum.TextXAlignment.Left
menuBody.TextYAlignment = Enum.TextYAlignment.Top
menuBody.Parent = menuPanel

menu.MouseButton1Click:Connect(function()
	menuPanel.Visible = not menuPanel.Visible
end)

-- Wire the server events.
local coinsEvent = ReplicatedStorage:WaitForChild("CoinsEvent")
coinsEvent.OnClientEvent:Connect(function(total, gain)
	wallet.Text = tostring(total) .. " coins"
	if gain and gain > 0 then
		wallet.Text = tostring(total) .. " coins  (+" .. tostring(gain) .. "/s)"
	end
end)

local karaokeEvent = ReplicatedStorage:WaitForChild("KaraokeEvent")
karaokeEvent.OnClientEvent:Connect(function(queue)
	local lines = {}
	for i, entry in ipairs(queue) do
		table.insert(lines, tostring(i) .. ". " .. entry.player.Name .. " — " .. entry.song)
	end
	if #lines == 0 then
		karaokeList.Text = "Belum ada yang antre.\nKetik /nyanyi <lagu> untuk ikut."
	else
		karaokeList.Text = table.concat(lines, "\n")
	end
end)

local bossEvent = ReplicatedStorage:WaitForChild("BossEvent")
bossEvent.OnClientEvent:Connect(function(health, maxHealth)
	bossBar.Visible = true
	bossFill.Size = UDim2.fromScale(math.max(health / maxHealth, 0), 1)
	bossText.Text = "GOD TUNG  •  " .. tostring(health) .. " / " .. tostring(maxHealth)
end)

-- /nyanyi <lagu> joins the karaoke queue.
chat.FocusLost:Connect(function(enterPressed)
	if not enterPressed then
		return
	end
	local text = chat.Text
	chat.Text = ""
	if string.sub(text, 1, 8) == "/nyanyi " then
		local song = string.sub(text, 9)
		if #song > 0 then
			karaokeEvent:FireServer(song)
		end
	end
end)
