local Players = game:GetService("Players")

return function()
    local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()

    if not Player then 
        return nil
    end

    local Character = Player.Character or Player.CharacterAdded:Wait()

    if not Character then 
        return nil
    end

    return Character
end
