return function(Object: Instance, EventName: string)
	local Event = Object[EventName]

	if typeof(Event) == "RBXScriptSignal" then
		local Queue = {}
		local Index = 0

		local Connection = Event:Connect(function(...)
			Index += 1
			Queue[Index] = { ... }
		end)
		
		local function Pop()
			if Index == 0 then
				return
			end

			local Arguments = table.remove(Queue, 1)

			Index -= 1
			Connection:Disconnect()

			return Arguments
		end

		return Pop
	end

	return nil
end
