--[=[
	@class DisappearingPlatformObject
	Disappearing Platforms fade when in contact with a player.
	@tag Objects
]=]

--[=[
	@prop DisappearTime number
	How much time it takes for the platform to disappear.
	This has a default value of 1.
	@within DisappearingPlatformObject
]=]
--[=[
	@prop RespawnTime number
	How much time it takes for the platform to reappear.
	This has a default value of 2.
	@within DisappearingPlatformObject
]=]
--[=[
	@prop Cooldown number
	How long to wait before damaging the player again.
	This has a default value of 0.2.
	@within DisappearingPlatformObject
]=]

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
