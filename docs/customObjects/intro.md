---
sidebar_position: 1
---

# Introduction

So - you want to make custom objects for your Spire. Nice!

- Firstly, you'll need the template: You can get this by going to the "Template" tab.
- Secondly, put the code into a ModuleScript and put it in the ExternalRepository folder. This can be found in ReplicatedStorage.Kit.
- Thirdly, start coding! Your custom object can be anything, aslong as it meets these guidelines:

## Guidelines

- Your custom object must be optimised for low-end devices.
- Your custom object must not be disruptive to the player's experience in major ways. If broken, this will get you **banned** from submitting Spires.
- Your custom object must not have any malicious intent or effects. If broken, this will get you **banned** from submitting Spires.

## Tips and Tricks

- Want to add EToH v5.5 and v6 Client object support? You can remove the "Step" function and the system will work fine!
- Your "StepMode" can be any event under RunService. This includes RenderStepped, Heartbeat, etc!
- Your Configuration can have any type that's compatible with Attributes.
