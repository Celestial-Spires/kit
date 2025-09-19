--[=[
	@class BouncePadObject
	Bounce Pads make the player bounce up in the air when touched.
	@tag Objects
]=]

--[=[
	@prop Force number
	How far up to bounce the player.
	This has a default value of 10.
	@within BouncePadObject
]=]
--[=[
	@prop Cooldown number
	How long to wait before letting the player bounce again.
	This has a default value of 0.2.
	@within BouncePadObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Force = 10,
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
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: BasePart?

		if
			HumanoidRootPart
			and API.Misc.UseThrottle(Player.UserId .. "_" .. Object:GetAttribute("ObjectGUID"), Configuration.Cooldown)
		then
			HumanoidRootPart.AssemblyLinearVelocity = (Root.CFrame :: CFrame).RightVector.Unit
				* (Configuration.Force * 5)
		end
	end
end

return System
