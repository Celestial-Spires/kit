return function(Parent: Instance, ObjectName: string)
    local Object = Parent:FindFirstChild(ObjectName)

    if not Object then
        Object = Parent:WaitForChild(ObjectName, 30)
    end

    return Object
end
