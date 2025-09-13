--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputUtils = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils").Input)

local DIVE_FORCE = 80
local DIVE_VERTICAL_FORCE = 40

local DIVE_COOLDOWN = 1
local KNOCKBACK_FORCE = 1000

return function(Player: Player, Character: Model & { Humanoid: Humanoid }): { RBXScriptConnection }
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Root = Character:WaitForChild("HumanoidRootPart") :: BasePart

	if not Humanoid or not Root then
		return {}
	end

	local Diving = false
	local LastDive = 0

	local MinimumMoveInput = 0.1

	local function GetFlatForward()
		local Forward = Root.CFrame.LookVector

		return Vector3.new(Forward.X, 0, Forward.Z).Unit
	end

	local function StartDive()
		if Diving or tick() - LastDive < DIVE_COOLDOWN then
			return
		end

		Diving = true
		LastDive = tick()

		local FlatForward = GetFlatForward()
		local DiveDirection = FlatForward * DIVE_FORCE + Vector3.new(0, DIVE_VERTICAL_FORCE, 0)

		Root.AssemblyLinearVelocity = DiveDirection
	end

	local function AttemptDive()
		if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			return
		end

		StartDive()
		InputUtils.RemoveListener("Dive")
	end

	local function UpdateDiveListener()
		local InAir = Humanoid:GetState() == Enum.HumanoidStateType.Freefall
		local Moving = Humanoid.MoveDirection.Magnitude > MinimumMoveInput

		if InAir and Moving then
			InputUtils.AddListener(
				"Dive",
				{ KeyboardAndMouse = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift } },
				AttemptDive,
				false
			)
		else
			InputUtils.RemoveListener("Dive")
		end
	end

	return {
		Humanoid.Died:Connect(function()
			Diving = false
			InputUtils.RemoveListener("Dive")
		end),

		Humanoid.StateChanged:Connect(function()
			UpdateDiveListener()
			
			if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
				Diving = false
			end
		end),
		
		Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			UpdateDiveListener()
		end),
		
		Root:GetPropertyChangedSignal("Position"):Connect(function()
			if not Diving then
				return
			end

			local Forward = Root.CFrame.LookVector
			local RayParams = RaycastParams.new()

			RayParams.FilterDescendantsInstances = { Character }
			RayParams.IgnoreWater = true

			local ForwardRaycast = workspace:Raycast(Root.Position, Forward, RayParams)

			if ForwardRaycast and ForwardRaycast.Instance then
				Diving = false
				Root:ApplyImpulse(-Forward.Unit * KNOCKBACK_FORCE)
			end
		end),
	}
end
