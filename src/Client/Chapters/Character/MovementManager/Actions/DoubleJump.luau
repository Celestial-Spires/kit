--!optimize 2

local UserInputService = game:GetService("UserInputService")
local DoubleJumpAnimation = 98828051081915

return function(Player: Player, Character: Model & { Humanoid: Humanoid }): { RBXScriptConnection }
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Root = Character:WaitForChild("HumanoidRootPart") :: BasePart

	if not Humanoid or not Root then
		return {}
	end

	local Animator = Humanoid:WaitForChild("Animator") :: Animator
	local Animation = Instance.new("Animation")

	Animation.AnimationId = "rbxassetid://" .. DoubleJumpAnimation

	if not Animator then
		return {}
	end

	local AnimationTrack = Animator:LoadAnimation(Animation)

	local CanDoubleJump = false
	local JumpCount = 0

	return {
		UserInputService.InputBegan:Connect(function(Input, GPE)
			if GPE then
				return
			end

			if Input.KeyCode == Enum.KeyCode.Space then
				if JumpCount == 0 then
					JumpCount = 1
					CanDoubleJump = true
				elseif JumpCount == 1 and CanDoubleJump then
					JumpCount = 2
					CanDoubleJump = false

					AnimationTrack:Play()
					Root.AssemblyLinearVelocity = Vector3.new(0, Humanoid.JumpPower * 1.2, 0)
				end
			end
		end),

		Humanoid.StateChanged:Connect(function(_, NewState)
			if NewState == Enum.HumanoidStateType.Landed then
				JumpCount = 0
				CanDoubleJump = false
			end
		end),

		Humanoid.Touched:Connect(function(Hit, _)
			if Hit:HasTag("RefillDoubleJump") then
				if Hit:GetAttribute("DoubleJumpDebounce") then 
					return
				end

				Hit:SetAttribute("DoubleJumpDebounce", true)

				JumpCount = 1
				CanDoubleJump = true

				task.delay(0.5, function()
					Hit:SetAttribute("DoubleJumpDebounce", false)
				end)
			end
		end),
	}
end
