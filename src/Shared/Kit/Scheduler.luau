--[=[
	@class SchedulerClass
	@tag Scheduler
	The scheduler used internally in the Celestial Spires Kit.
]=]

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

--[=[
	Create a new Scheduler.
	@param Scope string -- The scope to use for the new scheduler.
	@within SchedulerClass
]=]
function Scheduler.new(Scope: string)
	local self = setmetatable({}, Scheduler)

	self.Runtimes = {} :: { string }
	self.Systems = {} :: { [string]: System }

	self.Scope = Scope

	return self
end

--[=[
	Add a system to the scheduler.
	@param System {} | ModuleScript -- The system to add to the scheduler.
	@param SystemName string -- The name of the system to add.
	@within SchedulerClass
]=]
function Scheduler.AddSystem(self: Scheduler, System: System | ModuleScript, SystemName: string)
	if typeof(System) == "ModuleScript" then 
		System = require(System) :: System
	end

	if not self.Systems[SystemName] then
		self.Systems[SystemName] = System
	end
end

--[=[
	Removes a system from the scheduler.
	@param SystemName string -- The name of the system to remove.
	@within SchedulerClass
]=]
function Scheduler.RemoveSystem(self: Scheduler, SystemName: string)
	if self.Systems[SystemName] then
		self.Systems[SystemName] = nil
	end
end

--[=[
	Steps the scheduler.
	@param Function string -- The function name to call.
	@param StepMode string? -- The step mode to check for.
	@within SchedulerClass
]=]
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

--[=[
	Sets the scheduler's valid runtimes.
	@param Runtimes { string } -- The runtimes to set.
	@within SchedulerClass
]=]
function Scheduler.SetRuntimes(self: Scheduler, Runtimes: { string })
	self.Runtimes = Runtimes
end

--[=[
	Starts the scheduler.
	@within SchedulerClass
]=]
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
