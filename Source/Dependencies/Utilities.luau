local Storage = game:GetService("ReplicatedStorage")
local Animation = game:GetService("TweenService")
local Server = game:GetService("Players")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Promise = require(Packages.Promise)

local Utilities = {}

--[[
	Returns the local player instance.
]]

function Utilities.GetClientAsync()
	return Server.LocalPlayer
end

--[[
	Retrieves the PlayerGui of the local player.
	This is used to access and manage the player's user interface elements.
]]

function Utilities.GetDisplayAsync()
	return Utilities.GetClientAsync():WaitForChild("PlayerGui")
end

-- Retrieves the Camera instance currently used by the client

function Utilities.GetCameraAsync()
	return workspace.CurrentCamera
end

--[[
	Fetches the player's avatar thumbnail asynchronously.

	@param Client - The player object to fetch the thumbnail for.
	@return The player's headshot thumbnail URL.
]]

function Utilities.GetThumbnailAsync(Client)
	return Server:GetUserThumbnailAsync(Client.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352)
end

--[[
	Converts a boolean value into a corresponding "bit" (On/Off) value.

	@param Boolean - The condition to check.
	@param Bits - A table containing .On and .Off values.
	@return Bits.On if Boolean is true, otherwise Bits.Off.
]]

function Utilities.ConvertBooleanAsBits(Boolean, Bits)
	return Boolean and Bits.On or Bits.Off
end

--[[
	Creates a new Roblox instance with the given class name and sets its properties.

	@param Class (string) - The class name of the Roblox instance to create (e.g., "Part", "Folder").
	@param Properties (table) - A table containing property names and their corresponding values to assign.

	@return Instance - The created and configured instance.
]]

function Utilities.CreateInstance(Class, Properties)
	local Object = Instance.new(Class) -- Create the new instance.

	-- Apply the provided properties to the instance.

	for Name, Value in Properties do
		Object[Name] = Value
	end

	return Object -- Return the configured instance.
end

--[[
	Clones an instance and applies the given properties to the clone.

	@param Instance Instance -- The original instance to clone.
	@param Properties table -- A table containing property names and their corresponding values to apply to the clone.

	@return Instance -- The cloned instance with the applied properties.
]]

function Utilities.CloneInstance(Instance, Properties)
	local Clone = Instance:Clone() -- Create a deep copy of the original instance.

	-- Apply the provided properties to the cloned instance.
	for Name, Value in Properties do
		Clone[Name] = Value
	end

	return Clone -- Return the configured instance.
end

-- Creates a new Raycast parameters with the given class name and sets its properties.

function Utilities.CreateRaycastParameters(Properties)
	local Raycast = RaycastParams.new()

	for Name, Value in Properties do
		Raycast[Name] = Value
	end

	return Raycast
end

-- Creates an animation for the given object using the provided parameters.

function Utilities.Animate(Object, TweenInfo, Properties)
	return Animation:Create(Object, TweenInfo, Properties)
end

-- Accesses the Mouse object associated with the client on the client-side

function Utilities.GetMouseAsync()
	return Utilities.GetClientAsync():GetMouse()
end

-- Checks whether the dictionary is non-empty (contains at least one key-value pair).

function Utilities.isNotEmpty(Dictionary)
	return next(Dictionary) ~= nil
end

-- Finds and returns the board square at the given coordinates

function Utilities.RetrieveSquareWithinBoard(Coordinates, Chessboard)
	local X, Y = Coordinates.X, Coordinates.Y -- Retrieves the row and column coordinates
	local Identifier = string.format("(%s, %s)", X, Y) -- Formats the coordinates into a name string

	return Chessboard.Board:FindFirstChild(Identifier) -- Looks for the square in the board model
end

-- Attempts to access a value in a dictionary and returns a Promise-wrapped result

function Utilities.AccessWithinDictionaryAsync(Dictionary, Object)
	-- Create a new promise to validate and access a dictionary entry

	return Promise.new(function(Resolve, Reject)
		local Direction = Dictionary[Object]

		-- Reject the promise with error metadata when the entry is missing

		if not Direction then
			return Reject({ Status = 404, Message = "Error" })
		end

		-- Resolve the promise with success metadata and the value when the entry exists

		return Resolve({ Status = 200, Message = "OK" }, Direction)
	end)
end

-- Flattens a dictionary containing arrays into a single array.

function Utilities.FlattenDictionaryIntoArray(Dictionary)
	local Flattened = {}

	for Name, Inner in Dictionary do
		-- Skip if the inner value is not a table

		if table.find({ typeof(Dictionary[Name]) }, "table") then
			-- Iterate through the nested table and insert its key-value pairs into the flattened table
			for Key, Value in Inner do
				Flattened[Key] = Value
			end

			continue -- Skip the rest of this loop iteration
		end

		-- Directly insert non-table values into the flattened result
		Flattened[Name] = Inner
	end

	-- Return the merged table containing all inner values flattened into a single-level dictionary
	return Flattened
end

-- Access a value from the provided cache; execute the fallback callback when no entry is found

function Utilities.TryAccessOrCompute(Cache, Object, Callback)
	-- Retrieve the object from the cache using a promise-based lookup

	local Status, Response, Direction = Utilities.AccessWithinDictionaryAsync(Cache, Object):await()

	-- Return the cached result on successful access

	if Status then
		return Status, Direction, Response
	end

	-- Execute the fallback callback and return its result

	return Callback(Response):await()
end

-- Performs a deep clone of a dictionary (including nested tables).

function Utilities.CloneDictionary(Dictionary)
	local Copy = {}

	-- Iterate through each key-value pair in the original dictionary

	for Key, Value in Dictionary do
		if typeof(Value) ~= "table" then
			Copy[Key] = Value
		else
			-- Recursively clone nested tables

			Copy[Key] = Utilities.CloneDictionary(Value)
		end
	end

	return Copy
end

return Utilities -- Returns the Utilities module.
