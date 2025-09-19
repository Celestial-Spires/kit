--[=[
    @class EventsAPI
    @tag API
    The Events API for the Celestial Spires Kit.
]=]
--[=[
    @class MiscAPI
    @tag API
    The Misc API for the Celestial Spires Kit.
]=]
--[=[
    @class PhysicsAPI
    @tag API
    The Physics API for the Celestial Spires Kit.
]=]
--[=[
    @class PlayerAPI
    @tag API
    The Player API for the Celestial Spires Kit.
]=]

--[=[
    @function Collect
    Collects all results of an object's event.
    @param Object Instance -- The object to collect events for.
    @param EventName string -- The event to collect results for.
    @return {any}
    @within EventsAPI
]=]

--[=[
    @function EnsureDefaults
    Ensures the default of a table.
    @param Defaults {any} -- The defaults to ensure.
    @param Table {any} -- The table to ensure.
    @within MiscAPI
]=]

--[=[
    @function EnsureInstance
    Ensures an instance exists.
    @param Parent Instance -- The parent to check.
    @param ObjectName string -- The object name to check.
    @within MiscAPI
]=]

--[=[
    @function UseThrottle
    Returns true if an ID is not throttled.
    @param ID any -- The ID to check.
    @param Cooldown number -- The cooldown.
    @return boolean -- Whether or not the ID is throttled.
    @within MiscAPI
]=]

--[=[
    @function Weld
    Welds a table of BaseParts to another BasePart.
    @param Part0 BasePart -- The part to weld everything to.
    @param Parts {BasePart} -- The parts to weld.
    @within PhysicsAPI
]=]

--[=[
    @function GetCharacter
    Gets the player's character.
    @return Model? -- The player's character.
    @within PlayerAPI
]=]

--[=[
    @function GetDeltaTime
    Gets the current DeltaTime.
    @return number -- The current DeltaTime.
    @within PlayerAPI
]=]

--[=[
    @function IsPlayerPart
    Checks if a specified part belongs to a player.
    @param Part BasePart -- The part that belongs to a player.
    @return boolean -- If the part belongs to a player.
    @return Player? -- The player the part belongs to. Can be nil.
    @within PlayerAPI
]=]

return nil