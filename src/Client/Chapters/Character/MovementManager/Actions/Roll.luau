--!optimize 2

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputUtils = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils").Input)

local ROLL_FORCE = 50
local KNOCKBACK_FORCE = 1000
local ROLL_TIME = 1

local LastRoll = os.clock()
local RollAnimation = 106309665696606

return function(Player: Player, Character: Model & { Humanoid: Humanoid }): { RBXScriptConnection }
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Root = Character:WaitForChild("HumanoidRootPart") :: BasePart

	if not Humanoid or not Root then
		return {}
	end

	local Animator = Humanoid:WaitForChild("Animator") :: Animator
	local Animation = Instance.new("Animation")

	Animation.AnimationId = "rbxassetid://" .. RollAnimation

	if not Animator then
		return {}
	end

	local AnimationTrack = Animator:LoadAnimation(Animation)

	AnimationTrack:AdjustSpeed(2)
	AnimationTrack.Looped = true

	local BaseWalkSpeed = Humanoid.WalkSpeed
	local BaseJumpPower = Humanoid.JumpPower

	local BaseC1 = Root:WaitForChild("RootJoint").C1

	local Rolling = false
	local LastForward = Root.CFrame.LookVector

	local MinimumMoveInput = 0.1

	local function GetFlatForward()
		local Forward = Root.CFrame.LookVector

		return Vector3.new(Forward.X, 0, Forward.Z).Unit
	end

	local function StartRoll()
		if Rolling then
			return
		end

		LastRoll = os.clock()
		Rolling = true

		--AnimationTrack:Play()
		Humanoid.JumpPower = BaseJumpPower * 1.25
	end

	local function AttemptRoll()
		if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
			return
		end

		StartRoll()
		InputUtils.RemoveListener("Roll")
	end

	local function UpdateRollListener()
		local OnGround = Humanoid:GetState() == Enum.HumanoidStateType.Running
		local Moving = Humanoid.MoveDirection.Magnitude > MinimumMoveInput

		if OnGround and Moving then
			InputUtils.AddListener(
				"Roll",
				{ KeyboardAndMouse = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift } },
				AttemptRoll,
				false
			)
		else
			AnimationTrack:Stop()
			Humanoid.JumpPower = BaseJumpPower

			InputUtils.RemoveListener("Roll")
		end
	end

	return {
		UserInputService.InputBegan:Connect(function(Input, GPE)
			if GPE then
				return
			end

			if Input.KeyCode == Enum.KeyCode.Space then
				Rolling = false

				AnimationTrack:Stop()
				Humanoid.JumpPower = BaseJumpPower

				InputUtils.RemoveListener("Roll")
			end
		end),

		Humanoid.Died:Connect(function()
			Rolling = false

			AnimationTrack:Stop()
			Humanoid.JumpPower = BaseJumpPower

			InputUtils.RemoveListener("Roll")
		end),

		Humanoid.StateChanged:Connect(function(_, NewState)
			UpdateRollListener()

			if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				AnimationTrack:Stop()
				Humanoid.JumpPower = BaseJumpPower

				Rolling = false
			end
		end),

		Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			UpdateRollListener()
		end),

		RunService.PreRender:Connect(function()
			if Rolling then
				InputUtils.RemoveListener("Roll")

				if os.clock() - LastRoll >= ROLL_TIME then
					Rolling = false

					AnimationTrack:Stop()
					Humanoid.JumpPower = BaseJumpPower

					InputUtils.AddListener(
						"Roll",
						{ KeyboardAndMouse = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift } },
						AttemptRoll,
						false
					)

					return
				end

				local Forward = GetFlatForward()

				if not LastForward then
					LastForward = Forward
				end

				Humanoid.WalkSpeed = 0
				Root.AssemblyLinearVelocity = LastForward * ROLL_FORCE

				local RayParams = RaycastParams.new()

				RayParams.FilterDescendantsInstances = { Character }
				RayParams.IgnoreWater = true

				local ForwardRaycast = workspace:Raycast(Root.Position, LastForward, RayParams)
				local DownRaycast = workspace:Raycast(Root.Position, Vector3.new(0, -5, 0), RayParams)

				if ForwardRaycast and ForwardRaycast.Instance then
					Rolling = false
					AnimationTrack:Stop()

					Humanoid.JumpPower = BaseJumpPower
					Root:ApplyImpulse(-LastForward.Unit * KNOCKBACK_FORCE)
				end

				if not (DownRaycast and DownRaycast.Instance) then
					Rolling = false
				end
			else
				Rolling = false
				LastForward = nil

				Humanoid.WalkSpeed = BaseWalkSpeed
				Root.RootJoint.C1 = BaseC1
			end
		end),
	}
end
