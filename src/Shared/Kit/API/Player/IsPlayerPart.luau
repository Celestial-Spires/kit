local Players = game:GetService("Players")

return function(Part: BasePart?): (boolean, Player?)
    if not Part or not Part.Parent then
        return false, nil
    end

    local Player = Players:GetPlayerFromCharacter(Part.Parent)

    if Player then
        return true, Player
    end

    return false, nil
end
