local Configuration = {}

for _, Module in pairs(script:GetChildren()) do
	if Module:IsA("ModuleScript") then
		local Value = require(Module)

		Configuration[Module.Name] = Value
	end
end

return Configuration
