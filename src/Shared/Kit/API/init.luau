local API = {}

function Traverse(Object: Instance, Parent)
	if Object:IsA("Folder") then
		Parent[Object.Name] = {}

		for _, Child in pairs(Object:GetChildren()) do
			Traverse(Child, Parent[Object.Name])
		end
	elseif Object:IsA("ModuleScript") then
		Parent[Object.Name] = require(Object) :: () -> ()
	end
end

for _, Folder in pairs(script:GetChildren()) do
	Traverse(Folder, API)
end

export type API = typeof(API)

return API
