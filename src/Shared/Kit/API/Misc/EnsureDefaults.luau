return function(Defaults: {any}, Table: {any})
    if not Defaults or typeof(Defaults) ~= "table" then 
        return {}
    end

    if not Table or typeof(Table) ~= "table" then 
        return Defaults
    end

    local TempTable = Defaults

    for Name, Value in pairs(Table) do
        TempTable[Name] = Value
    end

    return TempTable
end
