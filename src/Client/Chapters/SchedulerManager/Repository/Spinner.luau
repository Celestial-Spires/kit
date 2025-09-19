--[=[
	@class SpinnerObject
	Spinners continually spin in a specified direction, moving a player with it.
	@tag Objects
]=]

--[=[
	@prop Speed number
	How fast to spin the spinner.
	This has a default value of 150.
	@within SpinnerObject
]=]
--[=[
	@prop Axis Vector3
	The direction to move the spinner in.
	This has a default value of Vector3.new(0, 1, 0).
	@within SpinnerObject
]=]
--[=[
	@prop FrameConsistent boolean
	If the speed should stay consistent, even if lag occurs.
	This has a default value of true.
	@within SpinnerObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Speed = 150,
	Axis = Vector3.new(0, 1, 0),
	FrameConsistent = true,
}
System.StepMode = "PreRender"

local Root, Decoration = nil, nil

function System:Init(API, Configuration)
	Object = API.Misc.EnsureInstance(script, "ObjectPath").Value

	Root = API.Misc.EnsureInstance(Object, "Root")
	Decoration = API.Misc.EnsureInstance(Object, "Decoration")

	API.Physics.Weld(Root, Decoration:GetChildren())
	System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())
end

function System:Step(API, Configuration)
	if not Root then
		return
	end

	local Speed = Configuration.Speed
	local Axis = Configuration.Axis

	if Configuration.FrameConsistent then
		Speed = Speed * API.Player.GetDeltaTime()
	end

	local Target = Axis * Speed

	Root.CFrame *= CFrame.Angles(Target.X, Target.Y, Target.Z)
end

return System
