local System = {}
local Object = nil

System.Configuration = {
	DisappearTime = 1,
	RespawnTime = 2,

	Cooldown = 0.2,
}
System.StepMode = "PostSimulation"

local GetNextHit, _ = nil
local Root = nil

local CanActivate = true

function System:Init(API, Configuration)
	Object = API.Misc.EnsureInstance(script, "ObjectPath").Value

	Root = API.Misc.EnsureInstance(Object, "Root")
	GetNextHit, _ = API.Events.Collect(Root, "Touched")

	System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())
end

function System:Step(API, Configuration)
	if not Root then
		return
	end

	local Hit = GetNextHit()

	if not Hit then
		return
	end

	Hit = Hit[1]
	GetNextHit, _ = API.Events.Collect(Root, "Touched")

	local IsPlayer, Player = API.Player.IsPlayerPart(Hit)

	if IsPlayer then
		local Character = Player.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?

		if HumanoidRootPart then
			if not CanActivate then
				return
			end

			local BaseParent = Object.Parent

			CanActivate = false

			task.delay(Configuration.DisappearTime, function()
				Object.Parent = nil

				task.delay(Configuration.RespawnTime, function()
					Object.Parent = BaseParent

					task.delay(Configuration.Cooldown, function()
						CanActivate = true
					end)
				end)
			end)
		end
	end
end

return System
