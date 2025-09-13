local System = {}
local Object = nil

System.Configuration = {
	Enabled = true,
	Buffer = 0.1,
}
System.StepMode = "PreRender"

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

	local Character = API.Player.GetCharacter()

	if not Character then
		return
	end

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart

	local CharacterPosition = HumanoidRootPart.CFrame.Position
	local RootPosition = Root.Position

    local TargetPosition = RootPosition + Vector3.one * Configuration.Buffer

	Root.CanCollide = CharacterPosition.Y >= TargetPosition.Y
end

return System
