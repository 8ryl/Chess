local Storage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Settings = require(Dependencies.Settings)
local Configuration = require(Dependencies.Configuration)

local Parameters = {
	Matches = {}, -- Stores the data for ongoing matches
}

-- Initializes and returns a chess match template with players, settings, state, and a unique identifier.

function Parameters.Template(Client, Opponent, Name)
	return {
		Competitors = {
			Black = { -- Contains metadata for the black-side player
				User = Client, -- Reference to the player instance controlling black
				Time = Settings.Modes[Name].Time, -- Assigned time control for black, based on selected mode
			},

			White = { -- Contains metadata for the white-side player
				User = Opponent, -- Reference to the player instance controlling white
				Time = Settings.Modes[Name].Time, -- Assigned time control for white, based on selected mode

				-- Placeholder for custom square highlighting or additional attributes
			},
		},

		History = {}, -- Records and stores every piece movement in the board.
		Storage = {}, -- Stores the board cell the piece currently resides in

		-- ^ This dictionary is used to track the position of pieces on the board.
		-- It follows the structure: Storage[Colour][Row][Column] = piece

		Mode = Settings.Modes[Name] or Settings.Modes.Default, -- Game mode, can be modified later.

		Identifier = HttpService:GenerateGUID(Configuration.Default.Off),
	}
end

-- Generates a structured log entry for a move, including piece type, colour, origin, destination,

function Parameters.Logs(Piece, Row, Column, Coordinates, Identifier)
	return {
		Piece = Piece:GetAttribute("Piece"), -- The type of piece (e.g., Rook, Pawn)
		Colour = Piece:GetAttribute("Colour"), -- The colour (e.g., White, Black)

		To = UDim.new(Row, Column), -- Destination square (as a UDim)
		From = UDim.new(Coordinates.Scale, Coordinates.Offset), -- Starting square (as a UDim)

		Timestamp = os.clock(), -- Time of move (in seconds since session start)

		MoveNo = #Parameters.Matches[Identifier].History + 1, -- Sequential move index
	}
end

-- Generates a structured log entry when a capture occurs, storing the captured piece’s type,

function Parameters.Capture(Identifier, Row, Column)
	return {
		Piece = Parameters.Matches[Identifier].Storage[Row][Column]:GetAttribute("Piece"), -- Captured piece type
		Colour = Parameters.Matches[Identifier].Storage[Row][Column]:GetAttribute("Colour"), -- Captured piece colour

		Coordinates = Parameters.Matches[Identifier].Storage[Row][Column]:GetAttribute("Coordinates"), -- Position at capture
	}
end

return Parameters
