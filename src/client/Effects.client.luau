-- Effects: living-world ambience on the client — drifting sakura petals,
-- fireflies at dusk, and warm light shafts through the pines. All client-side
-- so they cost the server nothing.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local effects = Instance.new("Folder")
effects.Name = "Effects"
effects.Parent = Workspace

local petals = {}
local fireflies = {}

local function makePetal()
	local petal = Instance.new("Part")
	petal.Name = "Petal"
	petal.Size = Vector3.new(0.5, 0.08, 0.5)
	petal.Color = Color3.fromRGB(244, 178, 205)
	petal.Material = Enum.Material.SmoothPlastic
	petal.Anchored = true
	petal.CanCollide = false
	petal.CFrame = CFrame.new(math.random(-50, 50), math.random(12, 22), math.random(-60, 60))
	petal.Parent = effects
	table.insert(petals, { part = petal, speed = 0.6 + math.random() * 0.8, sway = math.random() * math.pi * 2 })
end

local function makeFirefly()
	local fly = Instance.new("Part")
	fly.Name = "Firefly"
	fly.Shape = Enum.PartType.Ball
	fly.Size = Vector3.new(0.35, 0.35, 0.35)
	fly.Color = Color3.fromRGB(255, 220, 120)
	fly.Material = Enum.Material.Neon
	fly.Anchored = true
	fly.CanCollide = false
	fly.CFrame = CFrame.new(math.random(-40, 40), math.random(2, 8), math.random(-40, 50))
	fly.Parent = effects
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 210, 110)
	light.Range = 4
	light.Brightness = 0.7
	light.Parent = fly
	table.insert(fireflies, { part = fly, base = fly.Position, phase = math.random() * math.pi * 2 })
end

for _ = 1, 40 do
	makePetal()
end
for _ = 1, 24 do
	makeFirefly()
end

-- Warm light shafts: tall translucent wedges angled like low sun through trees.
for i = 1, 6 do
	local shaft = Instance.new("Part")
	shaft.Name = "LightShaft"
	shaft.Size = Vector3.new(3, 26, 0.4)
	shaft.CFrame = CFrame.new(-30 + i * 12, 13, -20 + (i % 3) * 18) * CFrame.Angles(0, 0, math.rad(28))
	shaft.Color = Color3.fromRGB(255, 210, 140)
	shaft.Material = Enum.Material.Glass
	shaft.Transparency = 0.82
	shaft.Anchored = true
	shaft.CanCollide = false
	shaft.Parent = effects
end

RunService.RenderStepped:Connect(function(dt)
	local t = tick()
	for _, p in ipairs(petals) do
		local pos = p.part.Position
		local ny = pos.Y - p.speed * dt
		if ny < 0.2 then
			ny = 18 + math.random() * 6
		end
		local nx = pos.X + math.sin(t + p.sway) * dt * 1.4
		p.part.CFrame = CFrame.new(nx, ny, pos.Z) * CFrame.Angles(0, t + p.sway, 0)
	end
	for _, f in ipairs(fireflies) do
		local b = f.base
		f.part.CFrame = CFrame.new(
			b.X + math.sin(t * 0.7 + f.phase) * 2,
			b.Y + math.sin(t * 1.1 + f.phase) * 0.8,
			b.Z + math.cos(t * 0.5 + f.phase) * 2
		)
	end
end)
