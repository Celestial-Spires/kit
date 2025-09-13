--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StorageTemplate = require(ReplicatedStorage.Shared.Templates.Storage)

local ConfigurationManager = {
	priority = 3,
}

type self = typeof(ConfigurationManager)

local DefaultConfiguration = StorageTemplate.Configuration
local ConfigurationMap = {
	["string"] = "StringValue",
	["number"] = "NumberValue",
	["boolean"] = "BoolValue",
    ["Color3"] = "Color3Value"
}

function Deserialise(Name: string, Value: any, Parent: Instance)
	if typeof(Value) == "table" then
		local Folder = Instance.new("Folder")

		Folder.Name = Name
		Folder.Parent = Parent

		for ChildName, ChildValue in pairs(Value) do
			Deserialise(ChildName, ChildValue, Folder)
		end
	else
		local ValueType = ConfigurationMap[typeof(Value)]

        if not ValueType then
            warn(`Unsupported type for "{Name}": {typeof(Value)}`)
            return
        end

		local ValueInstance = Instance.new(ValueType)

		ValueInstance.Name = Name
		ValueInstance.Value = Value

		ValueInstance.Parent = Parent
	end
end

function ConfigurationManager.PlayerAdded(_self: self, Player: Player)
	Deserialise("Configuration", DefaultConfiguration, Player)
end

function ConfigurationManager.init(self: self)
	for _, Player in pairs(Players:GetPlayers()) do
		self:PlayerAdded(Player)
	end

	Players.PlayerAdded:Connect(function(Player)
		self:PlayerAdded(Player)
	end)
end

return ConfigurationManager
