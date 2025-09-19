--[=[
	@class ZiplineObject
	When the hitbox is touched, the player moves along the zipline smoothly.
	@tag Objects
]=]

--[=[
	@prop Speed number
	How fast the player should move across the zipline.
	This has a default value of 25.
	@within ZiplineObject
]=]
--[=[
	@prop Cooldown number
	How long to wait before letting the player move across the zipline again.
	This has a default value of 1.
	@within ZiplineObject
]=]
--[=[
	@prop Points number
	How many points the rope path should have.
	This has a default value of 10.
	@within ZiplineObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Speed = 25,
	Cooldown = 1,
	Points = 10,
}
System.StepMode = "Heartbeat"

local GetNextHit, _ = nil
local Origin, Destination, Hitbox = nil, nil, nil

local AnimationID = 73609172222996

function GeneratePath(Attachment0: Attachment, Attachment1: Attachment, RopeConstraint: RopeConstraint, Points: number)
	local Path = {}

	local StartPosition = Attachment0.WorldPosition
	local EndPosition = Attachment1.WorldPosition
	local RopeLength = RopeConstraint.Length

	local Midpoint = ((StartPosition + EndPosition) / 2) - Vector3.new(0, RopeLength * 0.25, 0)

	for Index = 0, Points do
		local Time = Index / Points

		local Point1 = StartPosition:Lerp(Midpoint, Time)
		local Point2 = Midpoint:Lerp(EndPosition, Time)

		local Point = Point1:Lerp(Point2, Time)

		table.insert(Path, Point)
	end

	return Path
end

function MoveAlongPath(Character: Model, Path: { Vector3 }, Speed: number)
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		Humanoid.PlatformStand = true
	end

	task.spawn(function()
		for Index = 1, #Path do
			local Point = Path[Index]
			local NextPoint = Path[Index + 1]

			if not NextPoint then
				break
			end

			local Distance = (NextPoint - Point).Magnitude
			local Duration = Distance / Speed

			local StartTime = os.clock()

			while os.clock() - StartTime < Duration do
				local Alpha = (os.clock() - StartTime) / Duration
				HumanoidRootPart.CFrame = CFrame.new(Point:Lerp(NextPoint, Alpha), NextPoint)

				task.wait()
			end

			HumanoidRootPart.CFrame = CFrame.new(NextPoint, Point)
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		end

		if Humanoid then
			for _, Track in pairs((Humanoid.Animator :: Animator):GetPlayingAnimationTracks()) do
				Track:Stop()
			end

			Humanoid.PlatformStand = false
		end
	end)
end

function System:Init(API, Configuration)
	Object = API.Misc.EnsureInstance(script, "ObjectPath").Value

	Origin = API.Misc.EnsureInstance(Object, "Origin")
	Destination = API.Misc.EnsureInstance(Object, "Destination")
	Hitbox = API.Misc.EnsureInstance(Object, "Hitbox")

	GetNextHit, _ = API.Events.Collect(Hitbox, "Touched")
	System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())
end

function System:Step(API, Configuration)
	if not Origin or not Destination or not Hitbox then
		return
	end

	local Hit = GetNextHit()

	if not Hit then
		return
	end

	Hit = Hit[1]
	GetNextHit, _ = API.Events.Collect(Hitbox, "Touched")

	local IsPlayer, Player = API.Player.IsPlayerPart(Hit)

	if IsPlayer then
		local Character = Player.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart") :: Part?
		local Humanoid = Character and Character:FindFirstChild("Humanoid") :: Humanoid?

		if
			HumanoidRootPart
			and Humanoid
			and API.Misc.UseThrottle(Player.UserId .. "_" .. Object:GetAttribute("ObjectGUID"), Configuration.Cooldown)
		then
			local Animator = Humanoid:WaitForChild("Animator") :: Animator
			local Animation = Instance.new("Animation")

			Animation.AnimationId = "rbxassetid://" .. AnimationID

			local Path = GeneratePath(
				Origin.Root.Attachment,
				Destination.Root.Attachment,
				Origin.Root.RopeConstraint,
				Configuration.Points
			)

			local Track = Animator:LoadAnimation(Animation)

			Track.Looped = true
			Track:Play()

			MoveAlongPath(Character, Path, Configuration.Speed)
		end
	end
end

return System
