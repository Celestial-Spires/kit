--!optimize 2

local Players = game:GetService("Players")
local MovementManager = {
	priority = 7,
}

type self = typeof(MovementManager)

MovementManager.Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
MovementManager.Connections = {}

function MovementManager.CharacterAdded(self: self, Character: Model)
	for _, ConnectionTable in pairs(self.Connections) do
		for _, Connection in pairs(ConnectionTable) do
			Connection:Disconnect()
			Connection = nil
		end
	end

	for _, Descendant in pairs(Character:GetDescendants()) do
		if Descendant:IsA("BasePart") then
			--Descendant.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end

	for _, Module in pairs(script:GetDescendants()) do
		if Module:IsA("ModuleScript") then
			local Connection = require(Module)(self.Player, Character) :: RBXScriptConnection

			table.insert(self.Connections, Connection)
		end
	end
end

function MovementManager.init(self: self)
	if self.Player.Character then
		task.spawn(self.CharacterAdded, self, self.Player.Character)
	end

	self.Player.CharacterAdded:Connect(function(Character)
		task.spawn(self.CharacterAdded, self, Character)
	end)
end

return MovementManager
