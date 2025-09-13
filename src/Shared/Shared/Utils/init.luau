local Utils = {}

for _, Util in pairs(script:GetChildren()) do 
    Utils[Util.Name] = require(Util) :: {[string]: any}
end

return Utils