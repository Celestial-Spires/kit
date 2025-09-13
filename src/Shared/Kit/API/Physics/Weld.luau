return function(Part0: BasePart, Parts: { BasePart })
    for _, Part in pairs(Parts) do 
        if Part:IsA("BasePart") then 
            Part:SetAttribute("RelativeCFrame", Part0.CFrame:ToObjectSpace(Part.CFrame))
        end
    end

    return {
        Part0:GetPropertyChangedSignal("CFrame"):Connect(function()
            for _, Part in pairs(Parts) do 
                if Part:IsA("BasePart") then 
                    local RelativeCFrame = Part:GetAttribute("RelativeCFrame")

                    if RelativeCFrame then
                        Part.CFrame = Part0.CFrame * RelativeCFrame
                    end
                end
            end
        end)
    }
end
