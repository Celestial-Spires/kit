local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quill = require(ReplicatedStorage.Packages.Quill)

local Init = {}

Init.Context = "Both"

function Init:Init(Chapters)
    Quill():register_chapters(Chapters):begin_reading()
end

return Init