--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExternalRepository = ReplicatedStorage.Kit.ExternalRepository
local SchedulerClass = require(ReplicatedStorage.Kit.Scheduler)

local SchedulerManager = {
	priority = 7,
}

type self = typeof(SchedulerManager)

type System = {
	Configuration: { [string]: any },
	StepMode: string,

	[string]: (({ [string]: any }, { string: any }) -> ())?,
}

function SchedulerManager.init(self: self)
	self.ScriptsFolder = script:FindFirstChild("ActiveScripts") or Instance.new("Folder")
	self.RepositoryFolder = script:FindFirstChild("Repository")

	assert(self.RepositoryFolder ~= nil, "Repository folder not found!")

	self.ScriptsFolder.Name = "ActiveScripts"
	self.ScriptsFolder.Parent = script

	self.Scheduler = SchedulerClass.new("Spire Kit")

	local Runtimes = {}

	for _, Object in pairs(workspace:GetDescendants()) do
		if Object:HasTag("Invisible") then
			Object.Transparency = 1
		end

		if Object:HasTag("SpireObject") then
			local ObjectName = Object:GetAttribute("Name") or Object.Name
			local Module

			if self.RepositoryFolder:WaitForChild(ObjectName) then 
				Module = self.RepositoryFolder:WaitForChild(ObjectName)
			elseif ExternalRepository:WaitForChild(ObjectName) then
				Module = ExternalRepository:WaitForChild(ObjectName)
			else
				continue
			end

			Object:SetAttribute("ObjectGUID", game:GetService("HttpService"):GenerateGUID(false))

			Module = Module:Clone()

			Module.Name = Module.Name .. "_" .. Object:GetAttribute("ObjectGUID")
			Module.Parent = self.ScriptsFolder

			local ObjectPath = Module:FindFirstChild("ObjectPath") or Instance.new("ObjectValue")

			ObjectPath.Name = "ObjectPath"
			ObjectPath.Value = Object

			ObjectPath.Parent = Module

			local System = require(Module) :: System
			local StepMode = System["StepMode"] or "PreRender"

			if not table.find(Runtimes, StepMode) then
				table.insert(Runtimes, StepMode)
			end

			task.spawn(function()
				self.Scheduler:AddSystem(System, Module.Name)
			end)
		end
	end

	self.Scheduler:SetRuntimes(Runtimes)
	self.Scheduler:Start()
end

return SchedulerManager
