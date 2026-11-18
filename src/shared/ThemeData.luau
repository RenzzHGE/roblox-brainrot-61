-- ThemeData: the cast, the ladder and the world layout for BRAINROT MEGA UNIVERSE.
-- A dense dark-olive pine forest at sunset; NGOBROL hangout spots tucked into clearings.

local ThemeData = {}

ThemeData.GameTitle = "BRAINROT MEGA UNIVERSE"
ThemeData.OwnerName = "RenzzHGE"

-- Rarity ladder: name, colour, base income multiplier, weight.
ThemeData.Rarities = {
	{ name = "COMMON", color = Color3.fromRGB(168, 175, 186), mult = 1.0, weight = 40 },
	{ name = "RARE", color = Color3.fromRGB(74, 160, 255), mult = 2.6, weight = 26 },
	{ name = "EPIC", color = Color3.fromRGB(178, 102, 255), mult = 5.2, weight = 16 },
	{ name = "LEGENDARY", color = Color3.fromRGB(255, 190, 60), mult = 9.5, weight = 10 },
	{ name = "MYTHIC", color = Color3.fromRGB(255, 92, 168), mult = 15.0, weight = 6 },
	{ name = "GOD", color = Color3.fromRGB(255, 214, 90), mult = 24.0, weight = 2 },
}

ThemeData.Mutations = {
	{ name = "Normal", mult = 1.0, color = Color3.fromRGB(255, 255, 255) },
	{ name = "Golden", mult = 2.0, color = Color3.fromRGB(255, 215, 90) },
	{ name = "Diamond", mult = 4.0, color = Color3.fromRGB(150, 220, 255) },
	{ name = "Rainbow", mult = 8.0, color = Color3.fromRGB(255, 130, 220) },
}

-- 30 brainrots. income is $/s at base (COMMON x1). Colour is the body colour.
ThemeData.Brainrots = {
	{ name = "Chimpanzini Bananini", rarity = "COMMON", income = 120, color = Color3.fromRGB(150, 190, 80) },
	{ name = "Pipi Kiwi", rarity = "COMMON", income = 95, color = Color3.fromRGB(120, 200, 90) },
	{ name = "Brr Brr Patapim", rarity = "COMMON", income = 140, color = Color3.fromRGB(140, 170, 220) },
	{ name = "Frigo Camelo", rarity = "COMMON", income = 110, color = Color3.fromRGB(170, 200, 210) },
	{ name = "Trippi Troppi", rarity = "COMMON", income = 130, color = Color3.fromRGB(190, 150, 110) },
	{ name = "Tung Tung Sahur", rarity = "RARE", income = 380, color = Color3.fromRGB(150, 110, 70) },
	{ name = "Boneca Ambalabu", rarity = "RARE", income = 340, color = Color3.fromRGB(200, 120, 150) },
	{ name = "Cappuccino Assassino", rarity = "RARE", income = 410, color = Color3.fromRGB(120, 85, 55) },
	{ name = "La Vaca Saturno", rarity = "RARE", income = 360, color = Color3.fromRGB(220, 220, 230) },
	{ name = "Giraffa Celeste", rarity = "RARE", income = 430, color = Color3.fromRGB(240, 200, 120) },
	{ name = "Tralalero Tralala", rarity = "EPIC", income = 640, color = Color3.fromRGB(90, 140, 220) },
	{ name = "Bombombini Gusini", rarity = "EPIC", income = 590, color = Color3.fromRGB(200, 90, 80) },
	{ name = "Las Tralaleritas", rarity = "EPIC", income = 680, color = Color3.fromRGB(100, 170, 230) },
	{ name = "Chicleteira Bicicleteira", rarity = "EPIC", income = 610, color = Color3.fromRGB(240, 140, 190) },
	{ name = "Pot Hotspot", rarity = "EPIC", income = 720, color = Color3.fromRGB(220, 120, 60) },
	{ name = "Bombardiro Crocodilo", rarity = "LEGENDARY", income = 900, color = Color3.fromRGB(90, 160, 100) },
	{ name = "Crocodilo Ananas", rarity = "LEGENDARY", income = 860, color = Color3.fromRGB(140, 190, 90) },
	{ name = "Sahur Combinasion", rarity = "LEGENDARY", income = 950, color = Color3.fromRGB(170, 120, 80) },
	{ name = "Karkerkar Kurkur", rarity = "LEGENDARY", income = 880, color = Color3.fromRGB(200, 160, 110) },
	{ name = "Los Tralaleritos", rarity = "LEGENDARY", income = 1020, color = Color3.fromRGB(110, 150, 240) },
	{ name = "Lirili Larila", rarity = "MYTHIC", income = 1160, color = Color3.fromRGB(250, 200, 120) },
	{ name = "Graipuss Medussi", rarity = "MYTHIC", income = 1100, color = Color3.fromRGB(160, 110, 200) },
	{ name = "La Grande Combinasion", rarity = "MYTHIC", income = 1240, color = Color3.fromRGB(230, 180, 90) },
	{ name = "Los Crocodillitos", rarity = "MYTHIC", income = 1180, color = Color3.fromRGB(100, 170, 110) },
	{ name = "Tigroligre Frutonni", rarity = "MYTHIC", income = 1300, color = Color3.fromRGB(240, 150, 80) },
	{ name = "GOD TUNG", rarity = "GOD", income = 1420, color = Color3.fromRGB(255, 210, 80) },
	{ name = "GOD Tralala", rarity = "GOD", income = 1500, color = Color3.fromRGB(120, 160, 255) },
	{ name = "GOD Crocodilo", rarity = "GOD", income = 1580, color = Color3.fromRGB(110, 180, 120) },
	{ name = "GOD Lirili", rarity = "GOD", income = 1650, color = Color3.fromRGB(255, 190, 120) },
	{ name = "GOD Sahur", rarity = "GOD", income = 1800, color = Color3.fromRGB(200, 140, 90) },
}

ThemeData.Modes = { "Hangout", "Steal", "Tycoon", "Obby", "Arena" }
ThemeData.BossName = "GOD TUNG"
ThemeData.BossHealth = 5000

-- The six market stalls: rarity, brainrot index into Brainrots, stall position.
-- The street runs north (-Z, steps) to south (+Z, lake). Stalls flank the dirt path.
ThemeData.Stalls = {
	{ rarity = "COMMON", brainrot = 1, pos = Vector3.new(-11, 0, -12) },
	{ rarity = "RARE", brainrot = 6, pos = Vector3.new(11, 0, -12) },
	{ rarity = "EPIC", brainrot = 11, pos = Vector3.new(-11, 0, 4) },
	{ rarity = "LEGENDARY", brainrot = 16, pos = Vector3.new(11, 0, 4) },
	{ rarity = "MYTHIC", brainrot = 21, pos = Vector3.new(-11, 0, 20) },
	{ rarity = "GOD", brainrot = 26, pos = Vector3.new(11, 0, 20) },
}

-- World layout anchors (studs). North is -Z (steps/shrine), south is +Z (lake).
ThemeData.Layout = {
	Spawn = Vector3.new(0, 8.5, -34),
	Fountain = Vector3.new(0, 0, 0),
	StepsTop = Vector3.new(0, 8, -52),
	Shrine = Vector3.new(0, 8, -58),
	KaraokeDeck = Vector3.new(0, 0, 42),
	LakeCenter = Vector3.new(0, -0.4, 72),
	Waterfall = Vector3.new(48, 0, -22),
	Campfire = Vector3.new(-34, 0, 26),
	EggChair = Vector3.new(34, 0, 22),
	Billiard = Vector3.new(32, 0, -6),
	SpyGarden = Vector3.new(-32, 0, -18),
	Cabins = Vector3.new(-38, 0, 2),
	BossArena = Vector3.new(52, 0, -48),
	SwingTree = Vector3.new(14, 0, 10),
}

-- Sunset palette.
ThemeData.Palette = {
	SkyTop = Color3.fromRGB(112, 62, 140),
	SkyHorizon = Color3.fromRGB(255, 150, 90),
	Sun = Color3.fromRGB(255, 226, 160),
	PineDark = Color3.fromRGB(38, 66, 38),
	PineMid = Color3.fromRGB(52, 88, 48),
	PineTip = Color3.fromRGB(122, 110, 62),
	Trunk = Color3.fromRGB(96, 70, 46),
	Sakura = Color3.fromRGB(244, 178, 205),
	Stone = Color3.fromRGB(168, 160, 148),
	StoneDark = Color3.fromRGB(120, 112, 102),
	Wood = Color3.fromRGB(146, 104, 62),
	WoodDark = Color3.fromRGB(104, 72, 42),
	Dirt = Color3.fromRGB(178, 138, 92),
	Grass = Color3.fromRGB(86, 148, 62),
	Water = Color3.fromRGB(64, 130, 170),
}

function ThemeData.getRarity(name)
	for _, r in ipairs(ThemeData.Rarities) do
		if r.name == name then
			return r
		end
	end
	return ThemeData.Rarities[1]
end

function ThemeData.getBrainrot(index)
	return ThemeData.Brainrots[index]
end

return ThemeData
