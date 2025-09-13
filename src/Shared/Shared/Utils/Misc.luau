local Utils = {}

function Utils.EnforceDefaults(Defaults: { [string]: any }, Table: { [string]: any })
	if not Defaults then
		return {}
	end

	if not Table then
		return Defaults
	end

	local CombinedTable = table.clone(Defaults)

	for Name, Value in pairs(Table) do
		CombinedTable[Name] = Value
	end

	return CombinedTable
end

return Utils
