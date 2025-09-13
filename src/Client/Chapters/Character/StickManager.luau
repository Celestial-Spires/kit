--!optimize 2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local StickManager = {
	priority = 7,
}

type self = typeof(StickManager)

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait() :: Player
local Character = Player.Character or Player.CharacterAdded:Wait()

repeat
	task.wait()
until Character:FindFirstChild("HumanoidRootPart")

local Camera = workspace.CurrentCamera
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart

local LastCFrame: CFrame | nil

Player.CharacterAdded:Connect(function()
	Character = Player.Character or Player.CharacterAdded:Wait()
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

function StickManager.init(self: self)
	RunService.PreRender:Connect(function()
		local ActiveParts = {}
		local RayParams = RaycastParams.new()

		for _, Object in pairs(CollectionService:GetTagged("StickPart")) do
			local StickyPartActive = Object:GetAttribute("StickActive")

			if not StickyPartActive then
				continue
			end

			table.insert(ActiveParts, Object)
		end

		RayParams.FilterType = Enum.RaycastFilterType.Include
		RayParams.FilterDescendantsInstances = ActiveParts

		local RaycastResult = workspace:Raycast(HumanoidRootPart.CFrame.Position, Vector3.new(0, -7.5, 0), RayParams)

		if RaycastResult and RaycastResult.Instance:IsA("BasePart") then
			local ActivePart = RaycastResult.Instance :: BasePart

			if not LastCFrame then
				LastCFrame = ActivePart.CFrame
			end

			if not LastCFrame then
				return
			end

			LastCFrame = LastCFrame :: CFrame

			local ActiveCFrame = ActivePart.CFrame
			local RelativeCFrame = ActiveCFrame * LastCFrame:Inverse()

			LastCFrame = ActivePart.CFrame
			HumanoidRootPart.CFrame = RelativeCFrame * HumanoidRootPart.CFrame

			if Player.Configuration.Camera:WaitForChild("StickyCamera").Value then
				Camera.CFrame = RelativeCFrame * Camera.CFrame
			end
		else
			LastCFrame = nil
		end
	end)
end

return StickManager
