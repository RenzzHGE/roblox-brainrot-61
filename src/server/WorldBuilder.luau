-- WorldBuilder: builds the whole 3D world at runtime.
-- A dense dark-olive pine forest at sunset; NGOBROL hangout spots in its clearings.
-- The world is built in layers so the camera always sees depth: foreground pines
-- and stall corners, the market street and steps in the midground, forest and
-- sunset ridges in the background.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ThemeData = require(ReplicatedStorage.Shared.ThemeData)
local Util = require(ReplicatedStorage.Shared.Util)

local WorldBuilder = {}
local P = ThemeData.Palette

local world = Instance.new("Folder")
world.Name = "World"
world.Parent = Workspace

-- Find an embedded asset model by a keyword in its name (Rojo names .rbxm
-- instances after their file stem, so match loosely).
local function cloneAsset(keyword, parent)
	local models = ReplicatedStorage:FindFirstChild("AssetModels")
	if not models then
		return nil
	end
	local key = string.lower(keyword)
	for _, child in ipairs(models:GetChildren()) do
		if string.find(string.lower(child.Name), key, 1, true) then
			local clone = child:Clone()
			clone.Parent = parent
			return clone
		end
	end
	return nil
end

-- Place a cloned model at a position with a yaw and a uniform scale.
local function placeModel(model, position, yaw, scale)
	if not model then
		return
	end
	if scale and scale ~= 1 then
		pcall(function()
			model:ScaleTo(scale)
		end)
	end
	pcall(function()
		model:PivotTo(CFrame.new(position) * CFrame.Angles(0, yaw, 0))
	end)
end

-- A single part helper bound to the world folder.
local function part(name, className, size, cframe, color, material)
	return Util.part(name, className, size, cframe, color, material, world)
end

-- ---------------------------------------------------------------- ground ----

local function buildGround()
	-- The dirt path: a wide sandy strip running north (steps) to south (lake),
	-- built from overlapping slabs with slight height and colour variation so
	-- it reads as packed earth, not a flat coloured band.
	local rand = Util.seededRandom(101)
	for i = 0, 17 do
		local z = -28 + i * 4
		local shade = 0.92 + rand() * 0.16
		local c = Color3.new(P.Dirt.R * shade, P.Dirt.G * shade, P.Dirt.B * shade)
		part("PathSlab", "Part", Vector3.new(9, 0.4, 4.4), CFrame.new(0, 0.1, z), c, Enum.Material.Slate, world)
	end
	-- Stone edging along both sides of the path.
	for i = 0, 17 do
		local z = -28 + i * 4
		part("PathEdgeL", "Part", Vector3.new(1, 0.7, 4.2), CFrame.new(-5, 0.25, z), P.StoneDark, Enum.Material.Slate, world)
		part("PathEdgeR", "Part", Vector3.new(1, 0.7, 4.2), CFrame.new(5, 0.25, z), P.StoneDark, Enum.Material.Slate, world)
	end
	-- Scattered pebbles on the path.
	for i = 1, 40 do
		local r = rand()
		local x = -4 + r * 8
		local z = -28 + rand() * 72
		part("Pebble", "Part", Vector3.new(0.5 + rand() * 0.5, 0.25, 0.5 + rand() * 0.5), CFrame.new(x, 0.35, z), P.StoneDark, Enum.Material.Slate, world)
	end
	-- Grass tufts: small layered cones with varied greens, clustered off-path.
	local tuftColors = {
		Color3.fromRGB(86, 148, 62),
		Color3.fromRGB(102, 165, 70),
		Color3.fromRGB(70, 128, 54),
	}
	for i = 1, 120 do
		local angle = rand() * math.pi * 2
		local radius = 12 + rand() * 55
		local x = math.cos(angle) * radius
		local z = 10 + math.sin(angle) * radius * 0.9
		if math.abs(x) > 7 or z < -30 or z > 34 then
			local h = 1.2 + rand() * 1.6
			local c = tuftColors[1 + math.floor(rand() * 3)]
			local cone = Instance.new("Part")
			cone.Name = "GrassTuft"
			cone.Size = Vector3.new(1.4, h, 1.4)
			cone.CFrame = CFrame.new(x, h / 2, z)
			cone.Color = c
			cone.Material = Enum.Material.LeafyGrass
			cone.Anchored = true
			cone.Parent = world
		end
	end
	-- Fallen leaves on the ground near the sakura and maples.
	local leafColors = { Color3.fromRGB(244, 178, 205), Color3.fromRGB(220, 90, 60), Color3.fromRGB(240, 180, 80) }
	for i = 1, 60 do
		local x = -30 + rand() * 60
		local z = -50 + rand() * 90
		part("Leaf", "Part", Vector3.new(0.7, 0.12, 0.7), CFrame.new(x, 0.15, z) * CFrame.Angles(0, rand() * math.pi, 0), leafColors[1 + math.floor(rand() * 3)], Enum.Material.SmoothPlastic, world)
	end
end

-- ---------------------------------------------------------------- forest ----

local function buildForest()
	local rand = Util.seededRandom(7)
	-- Dense rings of the real tree-forest model: the forest presses in around
	-- every clearing. Varied scale and yaw so no two clusters look alike.
	local ringSpots = {}
	for ring = 1, 3 do
		local radius = 52 + ring * 14
		local count = 10 + ring * 4
		for i = 1, count do
			local angle = (i / count) * math.pi * 2 + ring * 0.35 + rand() * 0.2
			local x = math.cos(angle) * radius
			local z = 10 + math.sin(angle) * radius * 0.85
			table.insert(ringSpots, { x = x, z = z, s = 0.9 + rand() * 0.9, yaw = rand() * math.pi * 2 })
		end
	end
	-- Extra clusters filling the north and east so the forest reads as a wall.
	for i = 1, 10 do
		local x = -70 + rand() * 140
		local z = -75 + rand() * 20
		table.insert(ringSpots, { x = x, z = z, s = 1.0 + rand() * 0.8, yaw = rand() * math.pi * 2 })
	end
	for _, spot in ipairs(ringSpots) do
		local tree = cloneAsset("tree-forest", world)
		if tree then
			placeModel(tree, Vector3.new(spot.x, 0, spot.z), spot.yaw, spot.s)
		end
	end
	-- Detailed layered code pines near the paths and clearings, where the
	-- camera gets close: trunks, three foliage layers, varied tints.
	for i = 1, 46 do
		local angle = rand() * math.pi * 2
		local radius = 18 + rand() * 48
		local x = math.cos(angle) * radius
		local z = 10 + math.sin(angle) * radius * 0.85
		if math.abs(x) > 9 and not (z > 34 and z < 50 and math.abs(x) < 16) then
			local h = 14 + rand() * 12
			local tint = Color3.fromRGB(math.floor(rand() * 40), math.floor(rand() * 30), 0)
			Util.layeredPine(world, Vector3.new(x, 0, z), h, tint)
		end
	end
	-- Sakura trees: pink blossom balls on dark trunks, flanking the steps and
	-- the market street. Petals drift from them in the Living World system.
	local sakuraSpots = {
		Vector3.new(-24, 0, -46), Vector3.new(24, 0, -46),
		Vector3.new(-22, 0, -30), Vector3.new(22, 0, -30),
		Vector3.new(-20, 0, -2), Vector3.new(20, 0, 14),
		Vector3.new(-18, 0, 34), Vector3.new(18, 0, 30),
	}
	for _, pos in ipairs(sakuraSpots) do
		local trunk = Util.cylinder("SakuraTrunk", 0.9, 7, CFrame.new(pos + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(88, 60, 44), Enum.Material.Wood, world)
		trunk.CanCollide = false
		for j = 1, 4 do
			local ball = Instance.new("Part")
			ball.Name = "SakuraBloom"
			ball.Shape = Enum.PartType.Ball
			local s = 4.5 + rand() * 2.5
			ball.Size = Vector3.new(s, s * 0.8, s)
			ball.CFrame = CFrame.new(pos + Vector3.new((rand() - 0.5) * 5, 7.5 + rand() * 2.5, (rand() - 0.5) * 5))
			ball.Color = P.Sakura
			ball.Material = Enum.Material.LeafyGrass
			ball.Anchored = true
			ball.CanCollide = false
			ball.Parent = world
		end
	end
	-- A few red maples for the autumn theme.
	for _, pos in ipairs({ Vector3.new(-26, 0, 12), Vector3.new(26, 0, -14), Vector3.new(-24, 0, -44) }) do
		Util.cylinder("MapleTrunk", 0.8, 6, CFrame.new(pos + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 62, 44), Enum.Material.Wood, world)
		for j = 1, 3 do
			local ball = Instance.new("Part")
			ball.Name = "MapleCrown"
			ball.Shape = Enum.PartType.Ball
			local s = 5 + rand() * 2
			ball.Size = Vector3.new(s, s * 0.75, s)
			ball.CFrame = CFrame.new(pos + Vector3.new((rand() - 0.5) * 4, 6.5 + rand() * 2, (rand() - 0.5) * 4))
			ball.Color = Color3.fromRGB(210, 70, 45)
			ball.Material = Enum.Material.LeafyGrass
			ball.Anchored = true
			ball.CanCollide = false
			ball.Parent = world
		end
	end
	-- Far ridgelines: layered hazy silhouettes so the background has depth
	-- instead of a flat sky.
	local ridgeColors = {
		Color3.fromRGB(96, 62, 96),
		Color3.fromRGB(76, 50, 88),
		Color3.fromRGB(60, 40, 76),
	}
	for layer = 1, 3 do
		local radius = 150 + layer * 28
		for i = 1, 8 do
			local angle = (i / 8) * math.pi * 2
			local x = math.cos(angle) * radius
			local z = 10 + math.sin(angle) * radius
			local ridge = Instance.new("Part")
			ridge.Name = "Ridge"
			ridge.Size = Vector3.new(70, 26 + layer * 10, 18)
			ridge.CFrame = CFrame.new(x, 6, z) * CFrame.Angles(0, angle + math.pi / 2, 0)
			ridge.Color = ridgeColors[layer]
			ridge.Material = Enum.Material.SmoothPlastic
			ridge.Anchored = true
			ridge.CanCollide = false
			ridge.Parent = world
		end
	end
end

-- ----------------------------------------------------------------- steps ----

local function buildSteps()
	-- Ten individual stone treads climbing from the market street to the
	-- shrine landing, each with a darker front edge so the staircase reads
	-- as steps with depth, not a flat wall.
	for i = 1, 10 do
		local y = (i - 1) * 0.8
		local z = -30 - (i - 1) * 2.2
		part("Step", "Part", Vector3.new(40, 0.8, 2.4), CFrame.new(0, y + 0.4, z), P.Stone, Enum.Material.Slate, world)
		part("StepEdge", "Part", Vector3.new(40, 0.22, 0.5), CFrame.new(0, y + 0.82, z + 1.05), P.StoneDark, Enum.Material.Slate, world)
	end
	-- Side walls flanking the staircase.
	part("StepWallL", "Part", Vector3.new(2, 9, 26), CFrame.new(-21, 4.5, -40), P.StoneDark, Enum.Material.Concrete, world)
	part("StepWallR", "Part", Vector3.new(2, 9, 26), CFrame.new(21, 4.5, -40), P.StoneDark, Enum.Material.Concrete, world)
	-- Shrine landing + the small white shrine + two lanterns at the top.
	part("ShrineLanding", "Part", Vector3.new(44, 1, 10), CFrame.new(0, 8.5, -56), P.Stone, Enum.Material.Slate, world)
	part("ShrineBase", "Part", Vector3.new(10, 2, 8), CFrame.new(0, 10, -58), Color3.fromRGB(210, 205, 195), Enum.Material.SmoothPlastic, world)
	part("ShrineBody", "Part", Vector3.new(8, 5, 6), CFrame.new(0, 13.5, -58), Color3.fromRGB(232, 226, 214), Enum.Material.SmoothPlastic, world)
	part("ShrineRoof", "Part", Vector3.new(11, 1.2, 9), CFrame.new(0, 16.6, -58), Color3.fromRGB(170, 50, 45), Enum.Material.SmoothPlastic, world)
	Util.wedge("ShrineRoofTip", Vector3.new(6, 2.4, 6), CFrame.new(0, 18.4, -58), Color3.fromRGB(170, 50, 45), Enum.Material.SmoothPlastic, world)
	for _, sx in ipairs({ -6, 6 }) do
		Util.cylinder("LanternPost", 0.35, 5, CFrame.new(sx, 11.5, -54) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 45, 30), Enum.Material.Wood, world)
		local lamp = part("Lantern", "Part", Vector3.new(1.6, 2, 1.6), CFrame.new(sx, 14.2, -54), Color3.fromRGB(255, 200, 110), Enum.Material.Neon, world)
		lamp.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 190, 100)
		light.Range = 14
		light.Brightness = 1.5
		light.Parent = lamp
	end
	-- A red torii gate at the foot of the steps, marking the entrance.
	local torii = Instance.new("Model")
	torii.Name = "ToriiSteps"
	torii.Parent = world
	Util.cylinder("ToriiPillarL", 0.8, 10, CFrame.new(-6, 5, -29) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(190, 45, 35), Enum.Material.Wood, torii)
	Util.cylinder("ToriiPillarR", 0.8, 10, CFrame.new(6, 5, -29) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(190, 45, 35), Enum.Material.Wood, torii)
	part("ToriiTop", "Part", Vector3.new(16, 1.2, 2), CFrame.new(0, 10.2, -29), Color3.fromRGB(190, 45, 35), Enum.Material.Wood, torii)
	part("ToriiBeam", "Part", Vector3.new(13, 1, 1.6), CFrame.new(0, 8.4, -29), Color3.fromRGB(40, 30, 30), Enum.Material.Wood, torii)
	-- Ten sitting avatars in rows on the steps, facing south down the street.
	local shirts = {
		Color3.fromRGB(220, 90, 110), Color3.fromRGB(90, 140, 230), Color3.fromRGB(240, 200, 90),
		Color3.fromRGB(120, 200, 130), Color3.fromRGB(200, 120, 220), Color3.fromRGB(240, 240, 240),
	}
	local skins = {
		Color3.fromRGB(240, 205, 160), Color3.fromRGB(200, 160, 120), Color3.fromRGB(160, 120, 90),
	}
	local rows = { { y = 1.6, z = -32.5, n = 4 }, { y = 3.2, z = -36.9, n = 3 }, { y = 4.8, z = -41.3, n = 3 } }
	local idx = 0
	for _, row in ipairs(rows) do
		for i = 1, row.n do
			idx += 1
			local x = -12 + (i - 1) * (24 / math.max(row.n - 1, 1))
			Util.sittingAvatar(world, Vector3.new(x, row.y, row.z), 0, shirts[1 + (idx % 6)], Color3.fromRGB(60, 60, 90), skins[1 + (idx % 3)])
		end
	end
end

-- ---------------------------------------------------------------- market ----

local function buildMarket()
	-- Six stalls flank the dirt path. Each stall: four posts, a roof with an
	-- overhang and a coloured awning, a counter with goods, and a readable
	-- rarity label. The brainrot companion sits on the counter as a round
	-- character with eyes.
	for _, stall in ipairs(ThemeData.Stalls) do
		local brainrot = ThemeData.getBrainrot(stall.brainrot)
		local rarity = ThemeData.getRarity(stall.rarity)
		local pos = stall.pos
		local folder = Instance.new("Model")
		folder.Name = "Stall_" .. stall.rarity
		folder.Parent = world
		-- posts
		for _, dx in ipairs({ -3, 3 }) do
			for _, dz in ipairs({ -2.2, 2.2 }) do
				Util.part("Post", "Part", Vector3.new(0.7, 5, 0.7), CFrame.new(pos + Vector3.new(dx, 2.5, dz)), P.WoodDark, Enum.Material.Wood, folder)
			end
		end
		-- roof slab with overhang + coloured awning stripe
		Util.part("Roof", "Part", Vector3.new(8.5, 0.5, 6.5), CFrame.new(pos + Vector3.new(0, 5.4, 0)), P.Wood, Enum.Material.Wood, folder)
		Util.part("Awning", "Part", Vector3.new(8.5, 0.4, 1.6), CFrame.new(pos + Vector3.new(0, 5.1, 3.2)), rarity.color, Enum.Material.Fabric, folder)
		-- counter with a shaded interior and goods on top
		Util.part("Counter", "Part", Vector3.new(7, 2.2, 4.5), CFrame.new(pos + Vector3.new(0, 1.1, 0)), P.WoodDark, Enum.Material.Wood, folder)
		Util.part("CounterTop", "Part", Vector3.new(7.6, 0.4, 5), CFrame.new(pos + Vector3.new(0, 2.4, 0)), P.Wood, Enum.Material.Wood, folder)
		-- the brainrot companion: a round body with big eyes, sitting on the counter
		local body = Instance.new("Part")
		body.Name = "Brainrot"
		body.Shape = Enum.PartType.Ball
		body.Size = Vector3.new(2.6, 2.6, 2.6)
		body.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
		body.Color = brainrot.color
		body.Material = Enum.Material.SmoothPlastic
		body.Anchored = true
		body.Parent = folder
		for _, ex in ipairs({ -0.6, 0.6 }) do
			local eye = Instance.new("Part")
			eye.Name = "Eye"
			eye.Shape = Enum.PartType.Ball
			eye.Size = Vector3.new(0.55, 0.7, 0.4)
			eye.CFrame = CFrame.new(pos + Vector3.new(ex, 4.3, 1.2))
			eye.Color = Color3.fromRGB(255, 255, 255)
			eye.Material = Enum.Material.SmoothPlastic
			eye.Anchored = true
			eye.Parent = folder
			local pupil = Instance.new("Part")
			pupil.Name = "Pupil"
			pupil.Shape = Enum.PartType.Ball
			pupil.Size = Vector3.new(0.28, 0.36, 0.2)
			pupil.CFrame = CFrame.new(pos + Vector3.new(ex, 4.3, 1.45))
			pupil.Color = Color3.fromRGB(20, 20, 20)
			pupil.Material = Enum.Material.SmoothPlastic
			pupil.Anchored = true
			pupil.Parent = folder
		end
		-- goods: small fruit and coin piles on the counter
		for j = 1, 3 do
			local good = Instance.new("Part")
			good.Name = "Good"
			good.Shape = Enum.PartType.Ball
			good.Size = Vector3.new(0.8, 0.8, 0.8)
			good.CFrame = CFrame.new(pos + Vector3.new(-2 + j * 1.6, 3, 1.4))
			good.Color = Color3.fromRGB(240, 190, 80)
			good.Material = Enum.Material.SmoothPlastic
			good.Anchored = true
			good.Parent = folder
		end
		-- readable label above the stall
		local anchor = Instance.new("Part")
		anchor.Name = "LabelAnchor"
		anchor.Size = Vector3.new(1, 1, 1)
		anchor.CFrame = CFrame.new(pos + Vector3.new(0, 6.6, 0))
		anchor.Transparency = 1
		anchor.CanCollide = false
		anchor.Anchored = true
		anchor.Parent = folder
		Util.label(anchor, rarity.name .. "\n" .. brainrot.name .. "  $" .. tostring(brainrot.income) .. "/s", rarity.color, 240)
	end
	-- Garden lamps along the street (real embedded models).
	for _, pos in ipairs({ Vector3.new(-7, 0, -18), Vector3.new(7, 0, -18), Vector3.new(-7, 0, 12), Vector3.new(7, 0, 12) }) do
		local lamp = cloneAsset("lampu", world)
		if lamp then
			placeModel(lamp, pos, 0, 1)
		else
			Util.cylinder("LampPost", 0.3, 4, CFrame.new(pos + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(50, 45, 40), Enum.Material.Metal, world)
		end
	end
	-- Benches and a bush from the real asset models, placed along the street.
	for _, pos in ipairs({ Vector3.new(-9, 0, -4), Vector3.new(9, 0, 28) }) do
		local bench = cloneAsset("kursi", world)
		if bench then
			placeModel(bench, pos, math.pi / 2, 1)
		end
	end
	local bush = cloneAsset("bush", world)
	if bush then
		placeModel(bush, Vector3.new(-14, 0, 24), 0, 1.4)
	end
	local grass = cloneAsset("realistic-grass", world)
	if grass then
		placeModel(grass, Vector3.new(14, 0, -20), 0, 2)
	end
end

-- --------------------------------------------------------------- fountain ----

local function buildFountain()
	local c = ThemeData.Layout.Fountain
	-- Round stone rim: a ring of segments so the circle reads as built stone.
	for i = 1, 16 do
		local angle = (i / 16) * math.pi * 2
		local x = c.X + math.cos(angle) * 5
		local z = c.Z + math.sin(angle) * 5
		part("FountainRim", "Part", Vector3.new(2.2, 1.4, 1.4), CFrame.new(x, 0.7, z) * CFrame.Angles(0, -angle, 0), P.Stone, Enum.Material.Slate, world)
	end
	-- Water disc + centre spout with a falling sheet.
	local water = part("FountainWater", "Part", Vector3.new(9, 0.5, 9), CFrame.new(c + Vector3.new(0, 0.9, 0)), P.Water, Enum.Material.Glass, world)
	water.Transparency = 0.25
	water.CanCollide = false
	Util.cylinder("FountainSpout", 0.8, 3, CFrame.new(c + Vector3.new(0, 2.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), P.StoneDark, Enum.Material.Slate, world)
	local sheet = part("FountainSheet", "Part", Vector3.new(2.4, 2.6, 0.3), CFrame.new(c + Vector3.new(0, 2.4, 0)), Color3.fromRGB(200, 230, 245), Enum.Material.Glass, world)
	sheet.Transparency = 0.35
	sheet.CanCollide = false
	-- Signpost: three arrow boards pointing to the waterfall, the fountain and the cabins.
	local post = Util.cylinder("SignPost", 0.4, 6, CFrame.new(4, 3, 6) * CFrame.Angles(0, 0, math.rad(90)), P.WoodDark, Enum.Material.Wood, world)
	post.CanCollide = false
	local signs = {
		{ text = "AIR TERJUN", yaw = math.rad(35) },
		{ text = "AIR MANCUR", yaw = math.rad(-20) },
		{ text = "RUMAH KAYU", yaw = math.rad(-55) },
	}
	for i, s in ipairs(signs) do
		local board = part("SignBoard", "Part", Vector3.new(5, 1.2, 0.3), CFrame.new(4, 3.4 + i * 1.1, 6) * CFrame.Angles(0, s.yaw, 0), P.Wood, Enum.Material.Wood, world)
		board.CanCollide = false
		Util.label(board, s.text, Color3.fromRGB(255, 240, 210), 200)
	end
end

-- ---------------------------------------------------------------- karaoke ----

local function buildKaraoke()
	local c = ThemeData.Layout.KaraokeDeck
	-- Wooden deck on the lake shore, plank by plank so the floor has texture.
	for i = 0, 11 do
		local shade = 0.9 + (i % 2) * 0.14
		local col = Color3.new(P.Wood.R * shade, P.Wood.G * shade, P.Wood.B * shade)
		part("DeckPlank", "Part", Vector3.new(24, 0.5, 1.8), CFrame.new(c + Vector3.new(0, 0.4, -10 + i * 1.8)), col, Enum.Material.WoodPlanks, world)
	end
	-- The big lyric screen on posts, with a glowing lyrics label.
	for _, sx in ipairs({ -7, 7 }) do
		Util.part("ScreenPost", "Part", Vector3.new(0.8, 7, 0.8), CFrame.new(c + Vector3.new(sx, 3.5, -9)), P.WoodDark, Enum.Material.Wood, world)
	end
	local screen = part("LyricScreen", "Part", Vector3.new(16, 8, 0.8), CFrame.new(c + Vector3.new(0, 8, -9)), Color3.fromRGB(24, 18, 44), Enum.Material.SmoothPlastic, world)
	Util.label(screen, "KARAOKE\nHanya rindu yang kini tinggal", Color3.fromRGB(150, 220, 255), 320)
	-- Two speaker stacks.
	for _, sx in ipairs({ -10, 10 }) do
		Util.part("Speaker", "Part", Vector3.new(3, 6, 2.5), CFrame.new(c + Vector3.new(sx, 3, -8)), Color3.fromRGB(25, 25, 30), Enum.Material.SmoothPlastic, world)
		for _, sy in ipairs({ 1.6, 4.4 }) do
			local cone = Instance.new("Part")
			cone.Name = "SpeakerCone"
			cone.Shape = Enum.PartType.Ball
			cone.Size = Vector3.new(1.8, 1.8, 0.5)
			cone.CFrame = CFrame.new(c + Vector3.new(sx, sy, -6.6))
			cone.Color = Color3.fromRGB(60, 60, 70)
			cone.Material = Enum.Material.SmoothPlastic
			cone.Anchored = true
			cone.Parent = world
		end
	end
	-- Benches facing the screen + sitting avatars + one standing singer.
	for _, bz in ipairs({ -2, 3 }) do
		for _, bx in ipairs({ -6, 0, 6 }) do
			Util.part("KaraokeBench", "Part", Vector3.new(4.5, 0.5, 1.6), CFrame.new(c + Vector3.new(bx, 1.1, bz)), P.Wood, Enum.Material.Wood, world)
			Util.part("BenchLeg", "Part", Vector3.new(0.5, 1, 1.4), CFrame.new(c + Vector3.new(bx - 1.8, 0.5, bz)), P.WoodDark, Enum.Material.Wood, world)
			Util.part("BenchLeg", "Part", Vector3.new(0.5, 1, 1.4), CFrame.new(c + Vector3.new(bx + 1.8, 0.5, bz)), P.WoodDark, Enum.Material.Wood, world)
		end
	end
	Util.sittingAvatar(world, c + Vector3.new(-6, 1.4, -2), 0, Color3.fromRGB(240, 240, 240), Color3.fromRGB(80, 80, 120), Color3.fromRGB(240, 205, 160))
	Util.sittingAvatar(world, c + Vector3.new(2, 1.4, 3), 0, Color3.fromRGB(220, 90, 110), Color3.fromRGB(60, 60, 90), Color3.fromRGB(200, 160, 120))
	-- The singer, standing left of the screen with a mic.
	local singer = Instance.new("Model")
	singer.Name = "Singer"
	singer.Parent = world
	local sc = CFrame.new(c + Vector3.new(-9, 0, -4))
	Util.part("SingerLegL", "Part", Vector3.new(0.9, 2, 0.9), sc * CFrame.new(-0.5, 1, 0), Color3.fromRGB(60, 60, 90), Enum.Material.SmoothPlastic, singer)
	Util.part("SingerLegR", "Part", Vector3.new(0.9, 2, 0.9), sc * CFrame.new(0.5, 1, 0), Color3.fromRGB(60, 60, 90), Enum.Material.SmoothPlastic, singer)
	Util.part("SingerTorso", "Part", Vector3.new(2, 2, 1), sc * CFrame.new(0, 3, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, singer)
	local head = Util.part("SingerHead", "Part", Vector3.new(1.4, 1.3, 1.3), sc * CFrame.new(0, 4.6, 0), Color3.fromRGB(240, 205, 160), Enum.Material.SmoothPlastic, singer)
	head.Shape = Enum.PartType.Ball
	Util.part("Mic", "Part", Vector3.new(0.5, 1.6, 0.5), sc * CFrame.new(1.2, 3.6, 0.6) * CFrame.Angles(math.rad(30), 0, 0), Color3.fromRGB(40, 40, 45), Enum.Material.Metal, singer)
	-- Floating music notes (small pink note shapes: a ball + a stem).
	for i = 1, 8 do
		local nx = c.X - 12 + i * 3
		local nz = c.Z - 6 + (i % 3) * 3
		local note = Instance.new("Part")
		note.Name = "MusicNote"
		note.Shape = Enum.PartType.Ball
		note.Size = Vector3.new(0.9, 0.9, 0.5)
		note.CFrame = CFrame.new(nx, 6 + (i % 4), nz)
		note.Color = Color3.fromRGB(255, 130, 200)
		note.Material = Enum.Material.Neon
		note.Anchored = true
		note.CanCollide = false
		note.Parent = world
	end
	-- A red torii at the deck's edge.
	Util.cylinder("ToriiPillarL", 0.7, 8, CFrame.new(c + Vector3.new(-8, 4, 8)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(190, 45, 35), Enum.Material.Wood, world)
	Util.cylinder("ToriiPillarR", 0.7, 8, CFrame.new(c + Vector3.new(8, 4, 8)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(190, 45, 35), Enum.Material.Wood, world)
	part("ToriiTop", "Part", Vector3.new(20, 1, 1.8), CFrame.new(c + Vector3.new(0, 8.4, 8)), Color3.fromRGB(190, 45, 35), Enum.Material.Wood, world)
end

-- -------------------------------------------------------------------- lake ----

local function buildLake()
	local c = ThemeData.Layout.LakeCenter
	local water = part("Lake", "Part", Vector3.new(120, 0.6, 50), CFrame.new(c), P.Water, Enum.Material.Glass, world)
	water.Transparency = 0.3
	water.CanCollide = false
	-- A small wooden dock reaching into the lake from the karaoke deck.
	for i = 0, 6 do
		part("DockPlank", "Part", Vector3.new(4, 0.4, 1.8), CFrame.new(-14, 0.4, 52 + i * 1.8), P.Wood, Enum.Material.WoodPlanks, world)
	end
	-- Reeds at the water's edge.
	for i = 1, 24 do
		local x = -50 + i * 4.2
		local z = 48 + (i % 3)
		Util.cylinder("Reed", 0.15, 2.5 + (i % 3), CFrame.new(x, 1.2, z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 140, 60), Enum.Material.LeafyGrass, world)
	end
end

-- ------------------------------------------------------------------ cabins ----

local function buildCabin(pos, yaw)
	local folder = Instance.new("Model")
	folder.Name = "LogCabin"
	folder.Parent = world
	local cf = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
	-- Log walls: stacked horizontal logs with rounded ends.
	for i = 0, 7 do
		Util.cylinder("LogWall", 0.7, 10, cf * CFrame.new(0, 0.7 + i * 0.9, -3) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(140, 100, 60), Enum.Material.Wood, folder)
		Util.cylinder("LogWall", 0.7, 10, cf * CFrame.new(0, 0.7 + i * 0.9, 3) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(140, 100, 60), Enum.Material.Wood, folder)
	end
	for i = 0, 7 do
		Util.cylinder("LogEnd", 0.7, 7, cf * CFrame.new(-5, 0.7 + i * 0.9, 0) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(150, 108, 66), Enum.Material.Wood, folder)
		Util.cylinder("LogEnd", 0.7, 7, cf * CFrame.new(5, 0.7 + i * 0.9, 0) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(150, 108, 66), Enum.Material.Wood, folder)
	end
	-- Prism roof + door + warm windows.
	Util.wedge("RoofL", Vector3.new(12, 1, 5), cf * CFrame.new(0, 8.6, -1.8) * CFrame.Angles(0, 0, math.rad(-28)), Color3.fromRGB(120, 70, 45), Enum.Material.Wood, folder)
	Util.wedge("RoofR", Vector3.new(12, 1, 5), cf * CFrame.new(0, 8.6, 1.8) * CFrame.Angles(0, 0, math.rad(28)), Color3.fromRGB(120, 70, 45), Enum.Material.Wood, folder)
	Util.part("Door", "Part", Vector3.new(2.2, 4, 0.4), cf * CFrame.new(0, 2, 3.4), Color3.fromRGB(90, 60, 35), Enum.Material.Wood, folder)
	for _, wx in ipairs({ -3, 3 }) do
		local win = Util.part("Window", "Part", Vector3.new(1.8, 1.8, 0.3), cf * CFrame.new(wx, 3.4, 3.4), Color3.fromRGB(255, 200, 110), Enum.Material.Neon, folder)
		win.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 190, 100)
		light.Range = 10
		light.Brightness = 1
		light.Parent = win
	end
	-- Front porch steps.
	Util.part("Porch", "Part", Vector3.new(6, 0.6, 3), cf * CFrame.new(0, 0.3, 5), P.Stone, Enum.Material.Slate, folder)
	return folder
end

local function buildCabins()
	buildCabin(Vector3.new(-38, 0, -6), math.rad(90))
	buildCabin(Vector3.new(-44, 0, 8), math.rad(100))
	buildCabin(Vector3.new(-36, 0, 18), math.rad(80))
	-- One real small house model among them, for real 3D geometry.
	local house = cloneAsset("small-house", world)
	if house then
		placeModel(house, Vector3.new(-28, 0, 26), math.rad(45), 1)
	end
	local tree = cloneAsset("tree", world)
	if tree then
		placeModel(tree, Vector3.new(-30, 0, -14), 0, 1.2)
	end
	local log = cloneAsset("tree-log", world)
	if log then
		placeModel(log, Vector3.new(-26, 0, 12), math.rad(30), 1)
	end
end

-- --------------------------------------------------------------- waterfall ----

local function buildWaterfall()
	-- A rock cliff: stacked boulders with varied sizes and greys, so the
	-- cliff reads as layered rock, not a flat wall.
	local rand = Util.seededRandom(55)
	for layer = 1, 4 do
		local y = layer * 4
		local count = 5 - math.floor(layer / 2)
		for i = 1, count do
			local x = 44 + rand() * 8
			local z = -34 + i * 6 + rand() * 2
			local s = 5 + rand() * 3
			local rock = Instance.new("Part")
			rock.Name = "CliffRock"
			rock.Shape = Enum.PartType.Ball
			rock.Size = Vector3.new(s, s * 0.8, s)
			rock.CFrame = CFrame.new(x, y, z)
			rock.Color = Color3.fromRGB(120 + math.floor(rand() * 30), 115 + math.floor(rand() * 25), 108 + math.floor(rand() * 25))
			rock.Material = Enum.Material.Slate
			rock.Anchored = true
			rock.Parent = world
		end
	end
	-- Three white water sheets falling from the cliff top into the pond.
	for i, dx in ipairs({ -3, 0, 3 }) do
		local sheet = part("WaterSheet", "Part", Vector3.new(2.2, 15, 0.4), CFrame.new(46 + dx, 8, -20), Color3.fromRGB(210, 235, 250), Enum.Material.Glass, world)
		sheet.Transparency = 0.3
		sheet.CanCollide = false
	end
	-- Foam balls at the base + the pond.
	for i = 1, 10 do
		local foam = Instance.new("Part")
		foam.Name = "Foam"
		foam.Shape = Enum.PartType.Ball
		local s = 1 + rand() * 1.4
		foam.Size = Vector3.new(s, s * 0.6, s)
		foam.CFrame = CFrame.new(42 + rand() * 6, 0.5, -24 + rand() * 8)
		foam.Color = Color3.fromRGB(240, 248, 255)
		foam.Material = Enum.Material.SmoothPlastic
		foam.Anchored = true
		foam.CanCollide = false
		foam.Parent = world
	end
	local pond = part("Pond", "Part", Vector3.new(18, 0.5, 14), CFrame.new(42, 0.3, -20), P.Water, Enum.Material.Glass, world)
	pond.Transparency = 0.3
	pond.CanCollide = false
	-- Obby stepping stones across the pond.
	for i = 1, 5 do
		part("ObbyStone", "Part", Vector3.new(2.4, 0.8, 2.4), CFrame.new(36 + i * 2.4, 0.8, -26 + (i % 2) * 6), P.Stone, Enum.Material.Slate, world)
	end
end

-- ------------------------------------------------- campfire / egg / games ----

local function buildCampfire()
	local c = ThemeData.Layout.Campfire
	-- Stone ring + crossed logs + a fire cone with a warm point light.
	for i = 1, 8 do
		local angle = (i / 8) * math.pi * 2
		part("FireStone", "Part", Vector3.new(1, 0.8, 1), CFrame.new(c + Vector3.new(math.cos(angle) * 2.4, 0.4, math.sin(angle) * 2.4)), P.StoneDark, Enum.Material.Slate, world)
	end
	Util.cylinder("FireLog", 0.5, 4, CFrame.new(c + Vector3.new(0, 0.7, 0)) * CFrame.Angles(math.rad(70), 0, math.rad(40)), Color3.fromRGB(90, 60, 35), Enum.Material.Wood, world)
	Util.cylinder("FireLog", 0.5, 4, CFrame.new(c + Vector3.new(0, 0.7, 0)) * CFrame.Angles(math.rad(70), 0, math.rad(-40)), Color3.fromRGB(90, 60, 35), Enum.Material.Wood, world)
	local flame = Instance.new("Part")
	flame.Name = "Flame"
	flame.Size = Vector3.new(2, 3.4, 2)
	flame.CFrame = CFrame.new(c + Vector3.new(0, 2, 0))
	flame.Color = Color3.fromRGB(255, 140, 40)
	flame.Material = Enum.Material.Neon
	flame.Anchored = true
	flame.CanCollide = false
	flame.Parent = world
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 150, 60)
	light.Range = 22
	light.Brightness = 2
	light.Parent = flame
	-- Two benches around the fire with sitting avatars.
	for _, bz in ipairs({ -5, 5 }) do
		Util.part("FireBench", "Part", Vector3.new(5, 0.5, 1.6), CFrame.new(c + Vector3.new(0, 1, bz)), P.Wood, Enum.Material.Wood, world)
	end
	Util.sittingAvatar(world, c + Vector3.new(-1, 1.3, -5), 0, Color3.fromRGB(90, 140, 230), Color3.fromRGB(60, 60, 90), Color3.fromRGB(240, 205, 160))
end

local function buildEggChair()
	local c = ThemeData.Layout.EggChair
	-- Red-roof gazebo: four posts, a pyramid roof, and the egg chair hanging
	-- from a wooden stand beside it.
	for _, dx in ipairs({ -4, 4 }) do
		for _, dz in ipairs({ -4, 4 }) do
			Util.part("GazeboPost", "Part", Vector3.new(0.7, 6, 0.7), CFrame.new(c + Vector3.new(dx, 3, dz)), P.WoodDark, Enum.Material.Wood, world)
		end
	end
	Util.wedge("GazeboRoof", Vector3.new(11, 1, 11), CFrame.new(c + Vector3.new(0, 7, 0)), Color3.fromRGB(170, 50, 45), Enum.Material.SmoothPlastic, world)
	-- The egg: a hollow-feeling sphere shell (two halves) on a curved stand.
	local egg = Instance.new("Part")
	egg.Name = "EggChair"
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(3.4, 4.4, 3.4)
	egg.CFrame = CFrame.new(c + Vector3.new(7, 2.6, 0))
	egg.Color = Color3.fromRGB(150, 110, 70)
	egg.Material = Enum.Material.Wood
	egg.Anchored = true
	egg.Parent = world
	local cushion = Instance.new("Part")
	cushion.Name = "EggCushion"
	cushion.Shape = Enum.PartType.Ball
	cushion.Size = Vector3.new(2.4, 1.4, 2.4)
	cushion.CFrame = CFrame.new(c + Vector3.new(7, 1.8, 0.4))
	cushion.Color = Color3.fromRGB(245, 235, 210)
	cushion.Material = Enum.Material.Fabric
	cushion.Anchored = true
	cushion.Parent = world
	Util.cylinder("EggStand", 0.4, 6, CFrame.new(c + Vector3.new(7, 5.4, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(70, 55, 40), Enum.Material.Metal, world)
	-- The wooden "Ngobrol" sign.
	Util.cylinder("NgobrolSignPost", 0.4, 5, CFrame.new(c + Vector3.new(-7, 2.5, 4)) * CFrame.Angles(0, 0, math.rad(90)), P.WoodDark, Enum.Material.Wood, world)
	local sign = part("NgobrolSign", "Part", Vector3.new(7, 2, 0.4), CFrame.new(c + Vector3.new(-7, 5.4, 4)), P.Wood, Enum.Material.Wood, world)
	Util.label(sign, "NGOBROL", Color3.fromRGB(255, 240, 210), 220)
end

local function buildBilliard()
	local c = ThemeData.Layout.Billiard
	-- Checkered terrace: alternating light and dark tiles so the floor reads.
	for ix = 0, 7 do
		for iz = 0, 5 do
			local col = (ix + iz) % 2 == 0 and Color3.fromRGB(210, 190, 150) or Color3.fromRGB(120, 100, 80)
			part("TerraceTile", "Part", Vector3.new(2.2, 0.4, 2.2), CFrame.new(c + Vector3.new(-7.7 + ix * 2.2, 0.2, -5.5 + iz * 2.2)), col, Enum.Material.SmoothPlastic, world)
		end
	end
	-- Two billiard tables: wooden frame, blue felt, pockets, balls.
	for _, tz in ipairs({ -3, 3 }) do
		Util.part("TableFrame", "Part", Vector3.new(8, 1, 4.5), CFrame.new(c + Vector3.new(0, 1.6, tz)), Color3.fromRGB(110, 70, 40), Enum.Material.Wood, world)
		Util.part("Felt", "Part", Vector3.new(7.2, 0.3, 3.8), CFrame.new(c + Vector3.new(0, 2.2, tz)), Color3.fromRGB(30, 120, 90), Enum.Material.Fabric, world)
		for i = 1, 5 do
			local ball = Instance.new("Part")
			ball.Name = "BilliardBall"
			ball.Shape = Enum.PartType.Ball
			ball.Size = Vector3.new(0.7, 0.7, 0.7)
			ball.CFrame = CFrame.new(c + Vector3.new(-2 + i * 0.9, 2.6, tz + (i % 2) * 0.8 - 0.4))
			ball.Color = Color3.fromRGB(240, 240, 240)
			ball.Material = Enum.Material.SmoothPlastic
			ball.Anchored = true
			ball.Parent = world
		end
	end
end

local function buildSpyGarden()
	local c = ThemeData.Layout.SpyGarden
	-- Round wooden table + six red chairs on the grass, under a big tree.
	local tableTop = Instance.new("Part")
	tableTop.Name = "SpyTable"
	tableTop.Shape = Enum.PartType.Cylinder
	tableTop.Size = Vector3.new(1, 7, 7)
	tableTop.CFrame = CFrame.new(c + Vector3.new(0, 2.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	tableTop.Color = P.Wood
	tableTop.Material = Enum.Material.Wood
	tableTop.Anchored = true
	tableTop.Parent = world
	Util.cylinder("SpyTableLeg", 0.6, 2.2, CFrame.new(c + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, 0, math.rad(90)), P.WoodDark, Enum.Material.Wood, world)
	for i = 1, 6 do
		local angle = (i / 6) * math.pi * 2
		local x = c.X + math.cos(angle) * 5
		local z = c.Z + math.sin(angle) * 5
		Util.part("SpyChair", "Part", Vector3.new(1.8, 0.5, 1.8), CFrame.new(x, 1, z), Color3.fromRGB(190, 50, 45), Enum.Material.SmoothPlastic, world)
		Util.part("SpyChairBack", "Part", Vector3.new(1.8, 2, 0.4), CFrame.new(x + math.cos(angle) * 0.9, 2, z + math.sin(angle) * 0.9) * CFrame.Angles(0, -angle + math.pi / 2, 0), Color3.fromRGB(190, 50, 45), Enum.Material.SmoothPlastic, world)
	end
	Util.label(tableTop, "WHO'S THE SPY", Color3.fromRGB(255, 220, 90), 240)
end

local function buildBrickRoad()
	-- Red-brick road from the fountain plaza west to the cabins, bricks laid
	-- in alternating rows so the path has a visible pattern.
	local rand = Util.seededRandom(31)
	for i = 0, 11 do
		local x = -6 - i * 2.6
		for j = 0, 2 do
			local shade = 0.9 + rand() * 0.2
			local col = Color3.new(0.72 * shade, 0.28 * shade, 0.22 * shade)
			part("Brick", "Part", Vector3.new(2.4, 0.4, 1.8), CFrame.new(x, 0.2, -2 + j * 2 + (i % 2) * 0.9), col, Enum.Material.Slate, world)
		end
	end
	-- Sunflowers along the brick road.
	for i = 1, 8 do
		local x = -8 - i * 3
		local z = 4 + (i % 2) * 2
		Util.cylinder("SunflowerStem", 0.25, 3, CFrame.new(x, 1.5, z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 140, 60), Enum.Material.LeafyGrass, world)
		local bloom = Instance.new("Part")
		bloom.Name = "Sunflower"
		bloom.Shape = Enum.PartType.Ball
		bloom.Size = Vector3.new(1.6, 1.6, 0.6)
		bloom.CFrame = CFrame.new(x, 3.4, z)
		bloom.Color = Color3.fromRGB(255, 200, 50)
		bloom.Material = Enum.Material.SmoothPlastic
		bloom.Anchored = true
		bloom.Parent = world
	end
	-- The wooden swing under the big tree near the fountain.
	local treePos = ThemeData.Layout.SwingTree
	Util.cylinder("SwingTrunk", 1.2, 9, CFrame.new(treePos + Vector3.new(0, 4.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 64, 42), Enum.Material.Wood, world)
	for j = 1, 3 do
		local ball = Instance.new("Part")
		ball.Name = "SwingTreeCrown"
		ball.Shape = Enum.PartType.Ball
		ball.Size = Vector3.new(5.6, 4.2, 5.6)
		ball.CFrame = CFrame.new(treePos + Vector3.new((j - 2) * 2, 10 + j, (j - 2) * 1.5))
		ball.Color = Color3.fromRGB(70, 120, 55)
		ball.Material = Enum.Material.LeafyGrass
		ball.Anchored = true
		ball.Parent = world
	end
	Util.part("SwingBeam", "Part", Vector3.new(5, 0.6, 0.6), CFrame.new(treePos + Vector3.new(3, 7.5, 0)), P.WoodDark, Enum.Material.Wood, world)
	for _, dx in ipairs({ 1.6, 4.4 }) do
		Util.cylinder("SwingRope", 0.12, 3.4, CFrame.new(treePos + Vector3.new(dx, 5.8, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(200, 180, 140), Enum.Material.Fabric, world)
	end
	Util.part("SwingSeat", "Part", Vector3.new(2.4, 0.4, 1), CFrame.new(treePos + Vector3.new(3, 4, 0)), P.Wood, Enum.Material.Wood, world)
	Util.sittingAvatar(world, treePos + Vector3.new(3, 4.2, 0), math.rad(90), Color3.fromRGB(240, 200, 90), Color3.fromRGB(60, 60, 90), Color3.fromRGB(200, 160, 120))
end

-- ---------------------------------------------------------------- boss arena ----

local function buildBossArena()
	local c = ThemeData.Layout.BossArena
	-- A stone circle deep in the forest, ringed by torches, where GOD TUNG waits.
	for i = 1, 14 do
		local angle = (i / 14) * math.pi * 2
		local x = c.X + math.cos(angle) * 9
		local z = c.Z + math.sin(angle) * 9
		part("ArenaStone", "Part", Vector3.new(2.4, 1.6, 1.6), CFrame.new(x, 0.8, z) * CFrame.Angles(0, -angle, 0), P.StoneDark, Enum.Material.Slate, world)
	end
	part("ArenaFloor", "Part", Vector3.new(16, 0.6, 16), CFrame.new(c + Vector3.new(0, 0.3, 0)), P.Stone, Enum.Material.Slate, world)
	-- GOD TUNG: a big golden figure on a pedestal of rock.
	local pedestal = part("BossPedestal", "Part", Vector3.new(6, 2, 6), CFrame.new(c + Vector3.new(0, 1, 0)), P.StoneDark, Enum.Material.Slate, world)
	local boss = Instance.new("Model")
	boss.Name = "GodTung"
	boss.Parent = world
	Util.part("BossLegL", "Part", Vector3.new(1.6, 3.4, 1.6), CFrame.new(c + Vector3.new(-1.2, 3.7, 0)), Color3.fromRGB(255, 210, 80), Enum.Material.SmoothPlastic, boss)
	Util.part("BossLegR", "Part", Vector3.new(1.6, 3.4, 1.6), CFrame.new(c + Vector3.new(1.2, 3.7, 0)), Color3.fromRGB(255, 210, 80), Enum.Material.SmoothPlastic, boss)
	Util.part("BossTorso", "Part", Vector3.new(4.4, 4, 2.2), CFrame.new(c + Vector3.new(0, 7.4, 0)), Color3.fromRGB(255, 210, 80), Enum.Material.SmoothPlastic, boss)
	local bhead = Util.part("BossHead", "Part", Vector3.new(2.6, 2.4, 2.4), CFrame.new(c + Vector3.new(0, 10.6, 0)), Color3.fromRGB(255, 220, 130), Enum.Material.SmoothPlastic, boss)
	bhead.Shape = Enum.PartType.Ball
	Util.part("BossCrown", "Part", Vector3.new(3, 1, 3), CFrame.new(c + Vector3.new(0, 12.2, 0)), Color3.fromRGB(255, 190, 60), Enum.Material.Neon, boss)
	Util.label(bhead, "GOD TUNG\nHP 5,000", Color3.fromRGB(255, 214, 90), 240)
	for _, dx in ipairs({ -3, 3 }) do
		Util.part("BossArm", "Part", Vector3.new(1.4, 4, 1.4), CFrame.new(c + Vector3.new(dx, 7.6, 0)), Color3.fromRGB(255, 210, 80), Enum.Material.SmoothPlastic, boss)
	end
	-- Torches around the arena.
	for i = 1, 6 do
		local angle = (i / 6) * math.pi * 2
		local x = c.X + math.cos(angle) * 11
		local z = c.Z + math.sin(angle) * 11
		Util.cylinder("TorchPost", 0.3, 3.4, CFrame.new(x, 1.7, z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(70, 55, 40), Enum.Material.Wood, world)
		local flame = part("TorchFlame", "Part", Vector3.new(1, 1.6, 1), CFrame.new(x, 4, z), Color3.fromRGB(255, 150, 50), Enum.Material.Neon, world)
		flame.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 150, 60)
		light.Range = 12
		light.Brightness = 1.2
		light.Parent = flame
	end
end

function WorldBuilder.build()
	buildGround()
	buildForest()
	buildSteps()
	buildMarket()
	buildFountain()
	buildKaraoke()
	buildLake()
	buildCabins()
	buildWaterfall()
	buildCampfire()
	buildEggChair()
	buildBilliard()
	buildSpyGarden()
	buildBrickRoad()
	buildBossArena()
end

return WorldBuilder
