---
sidebar_position: 999
---

# Template

This is how to make a spinner:

```lua
local System = {}
local Object = nil

System.Configuration = {
    Speed = 1
}
System.StepMode = "PreRender" -- Any event under RunService!

local Root = nil

function System:Init(API, Configuration)
    Object = API.Misc.EnsureInstance(script, "ObjectPath").Value
    Root = API.Misc.EnsureInstance(Object, "Root")

    System.Configuration = API.Misc.EnsureDefaults(System.Configuration, Object:GetAttributes())
end

function System:Step(API, Configuration)
    if not Root then
        return
    end

    local Speed = Configuration.Speed

    Root.CFrame *= CFrame.new(0, Speed, 0)
end

return System
```
