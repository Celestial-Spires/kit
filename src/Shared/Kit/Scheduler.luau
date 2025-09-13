local RunService = game:GetService("RunService")
local API = require(script.Parent.API)

local Scheduler = {}
Scheduler.__index = Scheduler

Scheduler.Systems = {}

type System = {
	Configuration: { [string]: any },
	System: (API.API, { [string]: any }) -> (),
}

type Scheduler = typeof(Scheduler)

function Scheduler.new(Scope: string)
	local self = setmetatable({}, Scheduler)

	self.Runtimes = {} :: { string }
	self.Systems = {} :: { [string]: System }

	self.Scope = Scope

	return self
end

function Scheduler.AddSystem(self: Scheduler, System: System | ModuleScript, SystemName: string)
	if typeof(System) == "ModuleScript" then 
		System = require(System) :: System
	end

	if not self.Systems[SystemName] then
		self.Systems[SystemName] = System
	end
end

function Scheduler.RemoveSystem(self: Scheduler, SystemName: string)
	if self.Systems[SystemName] then
		self.Systems[SystemName] = nil
	end
end

function Scheduler.Step(self: Scheduler, Function: string, StepMode: string?)
	Function = Function or "Step"
	StepMode = Function == "Step" and (StepMode or "PreRender")

	for _, System in pairs(self.Systems) do
		if not System[Function] then
			continue
		end

		local SystemStep = System.StepMode or "PreRender"

		if (Function ~= "Step") or (SystemStep == StepMode) then
			task.spawn(System[Function], System, API, System.Configuration)
		end
	end
end

function Scheduler.SetRuntimes(self: Scheduler, Runtimes: { string })
	self.Runtimes = Runtimes
end

function Scheduler.Start(self: Scheduler)
	self:Step("Init")

	for _, Runtime in pairs(self.Runtimes) do
		if RunService[Runtime] and typeof(RunService[Runtime]) == "RBXScriptSignal" then
			RunService[Runtime]:Connect(function()
				self:Step("Step", Runtime)
			end)
		end
	end
end

return Scheduler
