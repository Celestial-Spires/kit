local RunService = game:GetService("RunService")

local CurrentContext = RunService:IsClient() and "Client" or (RunService:IsServer() and "Server" or "None")
local Runtimes = {}

for _, RuntimeModule in pairs(script:GetChildren()) do
    local Runtime = require(RuntimeModule)
    local Context = Runtime.Context or "Both"

    if (Context == "Both") or (CurrentContext == Context) then 
        Runtimes[RuntimeModule.Name:lower()] = Runtime
    end
end

return Runtimes