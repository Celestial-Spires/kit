--[=[
	@class MovingPlatformObject
	Moving Platforms continually move inbetween a dynamic amount of points.
	@tag Objects
]=]

--[=[
	@prop Speed number
	How fast the platform moves.
	This has a default value of 50.
	@within MovingPlatformObject
]=]
--[=[
	@prop FrameConsistent boolean
	If the speed should be consistent, even if lag occurs.
	This has a default value of true.
	@within MovingPlatformObject
]=]
--[=[
	@prop SeamlessLoop boolean
	If the platform should loop around or reverse after finishing a lap.
	This has a default value of true.
	@within MovingPlatformObject
]=]

local System = {}
local Object = nil

System.Configuration = {
	Speed = 50,
	FrameConsistent = true,
	SeamlessLoop = true,
}
System.StepMode = "PreRender"

local Root, Decoration, Positions = nil, nil, nil
local CurrentIndex, NextIndex, Alpha, Direction = 1, 2, 0, 1

function System:Init(API, Configuration)
	Object = API.Misc.EnsureInstance(script, "ObjectPath").Value

	Root = API.Misc.EnsureInstance(Object, "Root")
	Decoration = API.Misc.EnsureInstance(Object, "Decoration")
	Positions = API.Misc.EnsureInstance(Object, "Positions")

	API.Physics.Weld(Root, Decoration:GetChildren())
	System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())

	CurrentIndex, NextIndex, Alpha, Direction = 1, 2, 0, 1
end

function System:Step(API, Configuration)
	if not Root or not Positions then
		return
	end

	local PositionParts = Positions:GetChildren()

	table.sort(PositionParts, function(A, B)
		return A.Name < B.Name
	end)

	if #PositionParts < 2 then
		return
	end

	local Speed = Configuration.Speed

	if Configuration.FrameConsistent then
		Speed *= API.Player.GetDeltaTime()
	end

	Alpha += Speed / (PositionParts[CurrentIndex].Position - PositionParts[NextIndex].Position).Magnitude

	if Alpha >= 1 then
		CurrentIndex = NextIndex
		Alpha = 0

		if Direction == 1 then
			if CurrentIndex < #PositionParts then
				NextIndex = CurrentIndex + 1
			else
				if Configuration.SeamlessLoop then
					NextIndex = 1
				else
					Direction = -1
					NextIndex = CurrentIndex - 1
				end
			end
		else
			if CurrentIndex > 1 then
				NextIndex = CurrentIndex - 1
			else
				if Configuration.SeamlessLoop then
					NextIndex = #PositionParts
				else
					Direction = 1
					NextIndex = CurrentIndex + 1
				end
			end
		end
	end

	local CFrameA = PositionParts[CurrentIndex].CFrame
	local CFrameB = PositionParts[NextIndex].CFrame

	local NewCFrame = CFrameA:Lerp(CFrameB, Alpha)

	Root.CFrame = NewCFrame
end

return System
