local Throttles = {}

return function(ID: any, Cooldown: number)
    local Current = os.clock()
    local Last = Throttles[ID] or 0

    if Current - Last >= Cooldown then
        Throttles[ID] = Current
        
        return true
    end

    return false
end