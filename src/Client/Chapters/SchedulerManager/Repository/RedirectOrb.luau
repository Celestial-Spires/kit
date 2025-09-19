--[=[
    @class RedirectOrbObject
    When touched, Redirect Orbs fling the player in a different trajectory, but with the same velocity.
    @tag Objects
]=]

--[=[
    @prop Cooldown number
    How long to wait before flinging the player again.
    This has a default value of 1.
    @within RedirectOrbObject
]=]
--[=[
    @prop Modifier number
    How much to multiply the player's initial velocity by.
    This has a default value of 2.
    @within RedirectOrbObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Cooldown = 1,
	Modifier = 2,
}
System.StepMode = "Heartbeat"

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
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: Part?

		if HumanoidRootPart and API.Misc.UseThrottle(Player.UserId, Configuration.Cooldown) then
			local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity
			local RedirectDirection = Root.CFrame.LookVector

			local Speed = AssemblyLinearVelocity.Magnitude
			local NewVelocity = RedirectDirection * Speed

			local TargetCFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + RedirectDirection)

			HumanoidRootPart.CFrame = TargetCFrame
			HumanoidRootPart.AssemblyLinearVelocity = NewVelocity
		end
	end
end

return System
