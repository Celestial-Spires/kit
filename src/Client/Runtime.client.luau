local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = Player.Character or Player.CharacterAdded:Wait()

if not Character:FindFirstChild("Torso") then 
	warn("Game is not set to R6 - Spire Kit will not function.")
	return
end

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