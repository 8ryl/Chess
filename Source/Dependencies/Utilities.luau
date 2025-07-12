local Server = game:GetService("Players")

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

return Utilities
