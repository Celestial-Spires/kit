local System = {}
local Object = nil

System.Configuration = {
	Damage = 10,
	Cooldown = 0.2,
}
System.StepMode = "PostSimulation"

local GetNextHit, _ = nil
local Root = nil

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
		local Humanoid = Character and Character:FindFirstChild("Humanoid") :: Humanoid?

		if
			Humanoid
			and API.Misc.UseThrottle(Player.UserId .. "_" .. Object:GetAttribute("ObjectGUID"), Configuration.Cooldown)
		then
			Humanoid:TakeDamage(Configuration.Damage)
		end
	end
end

return System
