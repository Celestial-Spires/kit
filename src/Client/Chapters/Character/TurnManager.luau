--!optimize 2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TurnManager = {
	priority = 7,
}

type self = typeof(TurnManager)

TurnManager.Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
TurnManager.Character = TurnManager.Player.Character or TurnManager.Player.CharacterAdded:Wait()

TurnManager.Humanoid = TurnManager.Character:WaitForChild("Humanoid")
TurnManager.HumanoidRootPart = TurnManager.Character:WaitForChild("HumanoidRootPart")
TurnManager.RootJoint = TurnManager.HumanoidRootPart:WaitForChild("RootJoint")

TurnManager.ROLL_ANGLE = math.rad(15)
TurnManager.PITCH_ANGLE = math.rad(5)
TurnManager.LEAN_SPEED = 10

TurnManager.ORIGINAL_C0 = TurnManager.RootJoint.C0
TurnManager.LeanCFrame = CFrame.new()
TurnManager.TargetC0 = TurnManager.ORIGINAL_C0

function TurnManager.init(self: self)
	RunService.PreRender:Connect(function(DeltaTime)
		local MoveVelocity = self.Humanoid:GetMoveVelocity()
		local RelativeVelocity = self.HumanoidRootPart.CFrame:VectorToObjectSpace(MoveVelocity)

		local Pitch = 0
		local Roll = 0

		if self.Humanoid.WalkSpeed ~= 0 then
			Pitch = math.clamp(RelativeVelocity.Z / self.Humanoid.WalkSpeed, -1, 1) * self.PITCH_ANGLE
			Roll = -math.clamp(RelativeVelocity.X / self.Humanoid.WalkSpeed, -1, 1) * self.ROLL_ANGLE
		end

		self.LeanCFrame = self.LeanCFrame:Lerp(CFrame.Angles(0, Roll, Pitch), math.min(DeltaTime * self.LEAN_SPEED, 1))
		self.TargetC0 = self.ORIGINAL_C0 * self.LeanCFrame

		self.RootJoint.C0 = self.TargetC0
	end)
end

return TurnManager
