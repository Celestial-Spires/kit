local LastTick = os.clock()

return function()
    local CurrentTick = os.clock()
    local DeltaTime = CurrentTick - LastTick
    
    LastTick = CurrentTick

    return DeltaTime
end
