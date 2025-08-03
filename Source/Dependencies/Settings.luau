return {
	--[[
		Offset settings for precise chessboard positioning and related calculations.

		Developer Note:
		- These values are highly sensitive and carefully calibrated for correct board alignment.
		- Please do NOT modify them unless you fully understand the system.

		- Changing them may cause serious alignment issues in the game.
	]]

	Offset = {
		X = 500, -- Horizontal offset on the X-axis
		Y = 250, -- Vertical offset on the Y-axis
		Z = 500, -- Horizontal offset on the Z-axis
	},

	Orientation = {
		White = -90, -- Orientation angle for the white player’s perspective
		Black = 90, -- Orientation angle for the black player’s perspective
	},

	-- Camera position configuration relative to the chessboard

	Camera = {
		Offset = {
			Y = 45, -- Height offset: how far above the chessboard the camera is placed
			Z = 15, -- Depth offset: how far the camera moves forward / back relative to the chessboard's center after rotation
		},

		Tilt = {
			X = math.rad(-30), -- Tilt angle on the X-axis, in radians (negative = tilting downwards)
		},
	},

	-- Game modes with their respective settings

	Modes = {
		Rapid = {
			Time = 10, -- Time per player in minutes (Chess.com)
			Increment = 0, -- Increment per player in seconds.

			-- You can add more properties here later, such as increment or delays
		},

		Blitz = {
			Time = 2.5, -- Time per player in minutes (Chess.com)
			Increment = 1.25, -- Increment per player in seconds.
		},

		Keywords = {
			Time = 15, -- Time per player in minutes (Chess.com)
			Increment = 2.5, -- Increment per player in seconds.
		},
	},
}
