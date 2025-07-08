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

return Utilities
