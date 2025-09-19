--[=[
	@class ConveyorObject
	Conveyors push the player along while the player is in contact.
	@tag Objects
]=]

--[=[
	@prop Speed number
	How fast to push the player.
	This has a default value of 20.
	@within ConveyorObject
]=]
--[=[
	@prop FrameConsistent boolean
	If the speed should be consistent, even if lag occurs.
	This has a default value of true.
	@within ConveyorObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Speed = 20,
	FrameConsistent = true,
}
System.StepMode = "Heartbeat"

local Root = nil

function System:Init(API, Configuration)
	Object = API.Misc.EnsureInstance(script, "ObjectPath").Value
	Root = API.Misc.EnsureInstance(Object, "Root")

	System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())
end

function System:Step(API, Configuration)
	if not Root then
		return
	end

	Root.Velocity = Root.CFrame.LookVector * -Configuration.Speed
	Root.Arrow.OffsetStudsV += Configuration.Speed * API.Player.GetDeltaTime()

	if Root.Arrow.OffsetStudsV >= Root.Arrow.StudsPerTileV then
		Root.Arrow.OffsetStudsV = 0
	end
end

return System
