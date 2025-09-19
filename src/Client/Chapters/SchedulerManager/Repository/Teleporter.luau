--[=[
    @class TeleporterObject
    When the origin part is touched, Teleporters teleport the player to the Destination part.
    @tag Objects
]=]

--[=[
    @prop Cooldown number
    How long to wait before teleporting the player again.
    This has a default value of 1.
    @within TeleporterObject
]=]
--[=[
    @prop Offset CFrame
    The offset the player should be teleported with.
    This has a default value of CFrame.new(0, 0, 0).
    @within TeleporterObject
]=]
--[=[
    @prop Seamless boolean
    If the player should come out at the same relative position/orientation as they came in with.
    This has a default value of true.
    @within TeleporterObject
]=]
--[=[
    @prop KeepVelocity boolean
    If the player should keep their velocity, even after teleporting.
    This has a default value of true.
    @within TeleporterObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Cooldown = 1,
	Offset = CFrame.new(0, 0, 0),

	Seamless = true,
	KeepVelocity = true,
}
System.StepMode = "Heartbeat"

local GetNextHit, _ = nil
local Origin, Destination = nil, nil

function System:Init(API, Configuration)
	Object = API.Misc.EnsureInstance(script, "ObjectPath").Value

	Origin = API.Misc.EnsureInstance(Object, "Origin")
	Destination = API.Misc.EnsureInstance(Object, "Destination")

	GetNextHit, _ = API.Events.Collect(Origin, "Touched")
	System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())
end

function System:Step(API, Configuration)
	if not Origin or not Destination then
		return
	end

	local Hit = GetNextHit()

	if not Hit then
		return
	end

	Hit = Hit[1]
	GetNextHit, _ = API.Events.Collect(Origin, "Touched")

	local IsPlayer, Player = API.Player.IsPlayerPart(Hit)

	if IsPlayer then
		local Character = Player.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: Part?

		if
			HumanoidRootPart
			and API.Misc.UseThrottle(Player.UserId .. "_" .. Object:GetAttribute("ObjectGUID"), Configuration.Cooldown)
		then
			local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity

			local SeamlessOffset = Configuration.Seamless and Origin.CFrame:ToObjectSpace(HumanoidRootPart.CFrame)
				or CFrame.new(0, 0, 0)
			local Offset = Configuration.Offset

			local TrueOffset = Offset * SeamlessOffset:Inverse()
			local DestinationCFrame = Destination.CFrame * TrueOffset

			HumanoidRootPart.CFrame = DestinationCFrame

			if Configuration.KeepVelocity then
				HumanoidRootPart.AssemblyLinearVelocity = AssemblyLinearVelocity
			end
		end
	end
end

return System
