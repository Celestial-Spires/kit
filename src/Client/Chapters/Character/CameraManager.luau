--!optimize 2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CameraManager = {
	priority = 7,
}

type self = typeof(CameraManager)

CameraManager.Weight = 5
CameraManager.Camera = workspace.CurrentCamera

CameraManager.Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
CameraManager.Character = CameraManager.Player.Character or CameraManager.Player.CharacterAdded:Wait()

repeat
	task.wait()
until CameraManager.Character:FindFirstChild("Head")

CameraManager.HumanoidRootPart = CameraManager.Character:WaitForChild("HumanoidRootPart") :: BasePart
CameraManager.Subject = Instance.new("Part")

CameraManager.Subject.Transparency = 1
CameraManager.Subject.Size = Vector3.one * 0.5

CameraManager.Subject.Anchored = true
CameraManager.Subject.CanCollide = false
CameraManager.Subject.CanQuery = false
CameraManager.Subject.CanTouch = false

CameraManager.Subject.Position = CameraManager.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
CameraManager.Subject.Parent = CameraManager.Camera

function CameraManager.init(self: self)
	RunService.PreRender:Connect(function(DeltaTime)
		if
			(self.Camera.CFrame.Position - self.Subject.Position).Magnitude < 1
			or (self.Camera.CFrame.Position - self.HumanoidRootPart.Position + Vector3.new(0, 2, 0)).Magnitude < 1
		then
			self.Camera.CameraSubject = self.HumanoidRootPart
			self.Subject.Position = self.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
		else
			self.Camera.CameraSubject = self.Subject
			self.Subject.Position =
				self.Subject.Position:Lerp(self.HumanoidRootPart.Position + Vector3.new(0, 2, 0), 1 / self.Weight)
		end
	end)
end

return CameraManager
