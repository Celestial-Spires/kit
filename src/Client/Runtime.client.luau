local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

task.spawn(function()
	repeat
		StarterGui:SetCore("ResetButtonCallback", false)
	until StarterGui:GetCore("ResetButtonCallback") == false
end)

local Init = require(ReplicatedStorage.Shared.Init)

local ClientChapters = script.Parent:WaitForChild("Chapters")
local Chapters = Instance.new("Folder")

function GetChapters(Directory)
	for _, Chapter in pairs(Directory:GetChildren()) do
		if Chapter:IsA("ModuleScript") then
			Chapter:Clone().Parent = Chapters
		else
			GetChapters(Chapter)
		end
	end
end

GetChapters(ClientChapters)
Init.quill:Init(Chapters)