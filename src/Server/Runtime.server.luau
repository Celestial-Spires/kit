local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Init = require(ReplicatedStorage.Shared.Init)

local WorkspaceAssets = workspace:FindFirstChild("Assets") :: Folder?
local SharedAssets = ReplicatedStorage:FindFirstChild("Assets") :: Folder?

if WorkspaceAssets and SharedAssets then
	for _, Asset in pairs(WorkspaceAssets:GetChildren()) do
		Asset.Parent = SharedAssets
	end

	WorkspaceAssets:Destroy()
end

task.spawn(function()
	repeat
		StarterPlayer.EnableMouseLockOption = false
	until StarterPlayer.EnableMouseLockOption == false
end)

local ServerChapters = script.Parent:WaitForChild("Chapters")
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

GetChapters(ServerChapters)

Init.quill:Init(Chapters)