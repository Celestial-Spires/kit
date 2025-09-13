local RunService = game:GetService("RunService")
local Utils = {}

Utils.Internals = {}

if RunService:IsClient() then
	local BASE_RESOLUTION = Vector2.new(1280, 832)
	local MIN_SCALE = 0.75
	local DOMINANT_AXIS = 0.5

	function Utils.Internals.CalculateScale(Viewport: Vector2)
		local Width = math.log(Viewport.X / BASE_RESOLUTION.X, 2)
		local Height = math.log(Viewport.Y / BASE_RESOLUTION.Y, 2)
		local Centered = Width + (Height - Width) * DOMINANT_AXIS

		return math.max(2 ^ Centered, MIN_SCALE)
	end

	function Utils.usePx(Pixels: number)
		local Camera = workspace.CurrentCamera

		local function GetScale()
			local ViewportSize = Camera.ViewportSize

			if ViewportSize.X == 0 or ViewportSize.Y == 0 then
				return 1
			end

			return Utils.Internals.CalculateScale(ViewportSize)
		end

		return function()
			return Pixels * GetScale()
		end
	end
end

return Utils
