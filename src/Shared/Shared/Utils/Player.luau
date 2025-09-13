local Players = game:GetService("Players")
local Utils = {}

Utils.Internals = {}

function Utils.IsCharacterModel(Model: Instance): boolean
	return (Model and Model:FindFirstChild("Humanoid") and Model:FindFirstChild("HumanoidRootPart")) ~= nil
end

function Utils.IsPlayerPart(Part: BasePart): (boolean, Player | nil)
	if Part and Part.Parent then
		if Utils.IsCharacterModel(Part.Parent) then
			local Player = Players:GetPlayerFromCharacter(Part.Parent)

			if Player then
				if Part.Name == "Hitbox" then
					return true, Player
				end
			end
		end
	end

	return false, nil
end

return Utils
