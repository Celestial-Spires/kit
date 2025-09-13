local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Utils = {}
local KeybindMap = require(script.KeybindMap)

Utils.Internals = {}
Utils.Internals.Listeners = {}

if RunService:IsClient() then
	local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()

	type Listener = {
		Name: string,
		Keybinds: { Enum.KeyCode },
		Callback: () -> (),
		AllowGPE: boolean,
		Connections: { RBXScriptConnection },
		Indicator: TextLabel,
	}

	function Utils.Internals.AddIndicator(Listener: Listener)
		local PlayerGui = Player.PlayerGui

		if not PlayerGui then
			return
		end

		local Indicators = PlayerGui:WaitForChild("Indicators")
		local Indicator = script.Assets.Indicator:Clone()
		
		local PreferredInput = UserInputService.PreferredInput

		Indicator.Name = Listener.Name
		Indicator.Visible = true

		Indicator.Position = UDim2.fromScale(0, 1)
		Indicator.AnchorPoint = Vector2.new(0, 1)

		Indicator.Action.Text = Listener.Name
		Indicator.Keybind.Text.Text = KeybindMap[Listener.Keybinds[PreferredInput.Name][1].Name]

		Indicator.Parent = Indicators

		return Indicator
	end

	function Utils.Internals.RemoveIndicator(ListenerName: string)
		local PlayerGui = Player.PlayerGui
		local Indicators = PlayerGui ~= nil and PlayerGui:FindFirstChild("Indicators")

		if not Indicators then
			return
		end

		local Indicator = Indicators:FindFirstChild(ListenerName)

		if Indicator then
			Indicator:Destroy()
		end
	end

	function Utils.AddListener(
		ListenerName: string,
		ListenerKeybinds: { Enum.KeyCode },
		ListenerCallback: () -> (),
		AllowGPE: boolean
	): Listener
		for _, ExistingListener in ipairs(Utils.Internals.Listeners) do
			if ExistingListener.Name == ListenerName then
				return ExistingListener
			end
		end

		local Listener = {
			Name = ListenerName,
			Keybinds = ListenerKeybinds,
			Callback = ListenerCallback,
			AllowGPE = AllowGPE,
			Connections = {},
		}

		for _, InputType in pairs(Listener.Keybinds) do
			for _, Keybind in pairs(InputType) do
				local Connection = UserInputService.InputBegan:Connect(function(Input, GPE)
					if not AllowGPE and GPE == true then
						return
					end

					if Input.KeyCode == Keybind or Input.UserInputType == Keybind and Listener["Callback"] then
						Listener.Callback()
					end
				end)

				table.insert(Listener.Connections, Connection)
			end
		end

		Listener.Indicator = Utils.Internals.AddIndicator(Listener)
		table.insert(Utils.Internals.Listeners, Listener)

		return Listener
	end

	function Utils.RemoveListener(ListenerName: string)
		for Index, Listener in ipairs(Utils.Internals.Listeners) do
			if Listener.Name == ListenerName then
				for _, Connection in pairs(Listener.Connections) do
					Connection:Disconnect()
					Connection = nil
				end

				Utils.Internals.RemoveIndicator(Listener.Name)

				table.remove(Utils.Internals.Listeners, Index)
				table.clear(Listener)

				Listener = nil

				break
			end
		end
	end
end

return Utils
