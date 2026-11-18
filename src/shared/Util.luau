-- Util: small shared helpers for building parts, labels and sitting avatars.

local Util = {}

-- Deterministic pseudo-random from a seed, so the forest looks the same every run.
function Util.seededRandom(seed)
	local state = seed % 2147483647
	if state <= 0 then
		state += 2147483646
	end
	return function()
		state = (state * 16807) % 2147483647
		return (state - 1) / 2147483646
	end
end

function Util.part(name, className, size, cframe, color, material, parent)
	local part = Instance.new(className or "Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.Parent = parent
	return part
end

function Util.wedge(name, size, cframe, color, material, parent)
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.Parent = parent
	return part
end

-- A cylinder part (used for trunks, logs, lamp posts, torii pillars).
function Util.cylinder(name, radius, height, cframe, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, radius * 2, radius * 2)
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.Parent = parent
	return part
end

-- A floating name label with a dark pill behind it, readable from the camera.
function Util.label(parent, text, textColor, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(size or 220, 56)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0
	gui.Parent = parent
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	label.TextSize = 20
	label.Font = Enum.Font.GothamBold
	label.TextWrapped = true
	label.Parent = frame
	return gui
end

-- A blocky sitting avatar (head, torso, bent legs, arms) that reads as a person
-- sitting down, not a plain coloured block. Faces the given yaw.
function Util.sittingAvatar(parent, position, yaw, shirt, pants, skin)
	local model = Instance.new("Model")
	model.Name = "SittingAvatar"
	model.Parent = parent
	local cf = CFrame.new(position) * CFrame.Angles(0, yaw, 0)
	-- torso, slightly leaned back
	Util.part("Torso", "Part", Vector3.new(2, 2, 1), cf * CFrame.new(0, 1.6, 0) * CFrame.Angles(math.rad(-12), 0, 0), shirt, Enum.Material.SmoothPlastic, model)
	-- head
	local head = Util.part("Head", "Part", Vector3.new(1.4, 1.3, 1.3), cf * CFrame.new(0, 3.1, 0.2), skin, Enum.Material.SmoothPlastic, model)
	head.Shape = Enum.PartType.Ball
	-- hair cap
	Util.part("Hair", "Part", Vector3.new(1.5, 0.6, 1.4), cf * CFrame.new(0, 3.7, 0.2), Color3.fromRGB(60, 40, 26), Enum.Material.SmoothPlastic, model)
	-- thighs forward, shins down (bent knees)
	Util.part("LegL", "Part", Vector3.new(0.9, 0.9, 1.8), cf * CFrame.new(-0.55, 0.9, 0.9), pants, Enum.Material.SmoothPlastic, model)
	Util.part("LegR", "Part", Vector3.new(0.9, 0.9, 1.8), cf * CFrame.new(0.55, 0.9, 0.9), pants, Enum.Material.SmoothPlastic, model)
	Util.part("ShinL", "Part", Vector3.new(0.85, 1.6, 0.85), cf * CFrame.new(-0.55, 0.1, 1.75), pants, Enum.Material.SmoothPlastic, model)
	Util.part("ShinR", "Part", Vector3.new(0.85, 1.6, 0.85), cf * CFrame.new(0.55, 0.1, 1.75), pants, Enum.Material.SmoothPlastic, model)
	-- arms resting on the knees
	Util.part("ArmL", "Part", Vector3.new(0.8, 1.8, 0.8), cf * CFrame.new(-1.35, 1.5, 0.7) * CFrame.Angles(math.rad(35), 0, 0), shirt, Enum.Material.SmoothPlastic, model)
	Util.part("ArmR", "Part", Vector3.new(0.8, 1.8, 0.8), cf * CFrame.new(1.35, 1.5, 0.7) * CFrame.Angles(math.rad(35), 0, 0), shirt, Enum.Material.SmoothPlastic, model)
	return model
end

-- A layered pine: visible trunk + three stacked foliage cones of shrinking size,
-- each a different shade, so the tree reads as detailed geometry, never a flat cone.
function Util.layeredPine(parent, position, height, tint)
	local model = Instance.new("Model")
	model.Name = "CodePine"
	model.Parent = parent
	local trunkH = height * 0.22
	Util.cylinder("Trunk", height * 0.045, trunkH, CFrame.new(position + Vector3.new(0, trunkH / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(96, 70, 46), Enum.Material.Wood, model)
	local shades = {
		Color3.fromRGB(44, 76, 42),
		Color3.fromRGB(56, 94, 50),
		Color3.fromRGB(72, 108, 58),
	}
	local baseY = position.Y + trunkH * 0.7
	for i = 1, 3 do
		local w = height * (0.42 - (i - 1) * 0.11)
		local h = height * 0.34
		local y = baseY + (i - 1) * height * 0.24
		local cone = Instance.new("Part")
		cone.Name = "Foliage" .. i
		cone.Shape = Enum.PartType.Ball
		cone.Size = Vector3.new(w, h, w)
		cone.CFrame = CFrame.new(position + Vector3.new(0, y, 0))
		cone.Color = shades[i]
		cone.Material = Enum.Material.LeafyGrass
		cone.Anchored = true
		cone.Parent = model
		-- a small cone tip on top for the silhouette
		if i == 3 then
			local tip = Instance.new("Part")
			tip.Name = "Tip"
			tip.Size = Vector3.new(w * 0.4, height * 0.16, w * 0.4)
			tip.CFrame = CFrame.new(position + Vector3.new(0, y + h * 0.45, 0))
			tip.Color = Color3.fromRGB(122, 110, 62)
			tip.Material = Enum.Material.LeafyGrass
			tip.Anchored = true
			tip.Parent = model
		end
	end
	if tint then
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") and d.Name:find("Foliage") then
				d.Color = d.Color:Lerp(tint, 0.25)
			end
		end
	end
	return model
end

return Util
