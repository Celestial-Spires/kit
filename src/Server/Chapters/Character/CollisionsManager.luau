--!optimize 2

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local CollisionsManager = {
	priority = 7
}

type self = typeof(CollisionsManager)

function CollisionsManager.PlayerAdded(_self: self, Player: Player)
	if Player.Character then
		for _, Descendant in pairs(Player.Character:GetDescendants()) do
			if Descendant:IsA("BasePart") then
				Descendant.CollisionGroup = "Player"
			end
		end

		Player.Character.DescendantAdded:Connect(function(Descendant)
			if Descendant:IsA("BasePart") then
				Descendant.CollisionGroup = "Player"
			end
		end)
	end

	Player.CharacterAdded:Connect(function(Character)
		for _, Descendant in pairs(Character:GetDescendants()) do
			if Descendant:IsA("BasePart") then
				Descendant.CollisionGroup = "Player"
			end
		end

		Character.DescendantAdded:Connect(function(Descendant)
			if Descendant:IsA("BasePart") then
				Descendant.CollisionGroup = "Player"
			end
		end)
	end)
end

function CollisionsManager.init(self: self)
	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)

	for _, Player in pairs(Players:GetPlayers()) do
		self:PlayerAdded(Player)
	end

	Players.PlayerAdded:Connect(function(Player)
		self:PlayerAdded(Player)
	end)
end

return CollisionsManager