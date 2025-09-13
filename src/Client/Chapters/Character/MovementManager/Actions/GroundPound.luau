--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputUtils = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils").Input)

local VERTICAL_FORCE = -50
local START_DELAY = 0.3
local GP_COOLDOWN = 1

return function(Player: Player, Character: Model & { Humanoid: Humanoid }): { RBXScriptConnection }
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Root = Character:WaitForChild("HumanoidRootPart") :: BasePart

	if not Humanoid or not Root then
		return {}
	end

	local GroundPounding = false
	local LastGroundPound = 0

	local MinimumMoveInput = 0.1

	local function StartGroundPound()
		if GroundPounding or tick() - LastGroundPound < GP_COOLDOWN then
			return
		end

		GroundPounding = true
		LastGroundPound = tick()

        Root.Anchored = true

		task.delay(START_DELAY, function()
		    local GroundPoundDirection = Vector3.new(0, VERTICAL_FORCE, 0)
            
            Root.Anchored = false
            Root.AssemblyLinearVelocity = GroundPoundDirection
		end)
	end

	local function AttemptGroundPound()
		if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			return
		end

		StartGroundPound()
		InputUtils.RemoveListener("Ground Pound")
	end

	local function UpdateGroundPoundListener()
		local InAir = Humanoid:GetState() == Enum.HumanoidStateType.Freefall
		local Moving = Humanoid.MoveDirection.Magnitude > MinimumMoveInput

		if InAir and not Moving then
			InputUtils.AddListener(
				"Ground Pound",
				{ KeyboardAndMouse = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift } },
				AttemptGroundPound,
				false
			)
		else
			InputUtils.RemoveListener("Ground Pound")
		end
	end

	return {
		Humanoid.Died:Connect(function()
			GroundPounding = false
			InputUtils.RemoveListener("Ground Pound")
		end),

		Humanoid.StateChanged:Connect(function()
			UpdateGroundPoundListener()

			if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
				GroundPounding = false
			end
		end),

		Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			UpdateGroundPoundListener()
		end),

		Root:GetPropertyChangedSignal("Position"):Connect(function()
			if not GroundPounding then
				return
			end
            
			local RayParams = RaycastParams.new()

			RayParams.FilterDescendantsInstances = { Character }
			RayParams.IgnoreWater = true

			local DownRaycast = workspace:Raycast(Root.Position, Vector3.new(0, -5, 0), RayParams)

			if DownRaycast and DownRaycast.Instance then
				if DownRaycast.Instance:HasTag("DestroyOnGroundPound") then
					DownRaycast.Instance:Destroy()
					return
				end

				GroundPounding = false
			end
		end),
	}
end
