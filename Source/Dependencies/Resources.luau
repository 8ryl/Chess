local Server = game:GetService("ServerScriptService")
local Storage = game:GetService("ReplicatedStorage")

local Dependencies = Storage.Dependencies
local Directory = Server.Storage
local Chess = Directory.Chess

local Arbiter = Chess.Arbiter

local Parameters = Dependencies.Parameters

local Schema = require(Arbiter.Schema)
local Config = require(Parameters.Configuration)

local Keywords = Config.Keywords

local Resources = {}

function Resources.AccessOngoingInstance(Identifier)
	return Schema.Matches[Identifier]
end

-- Unpacks a square name into row and column numbers.

function Resources.Unpack(Square)
	local Row, Column = string.match(Square.Name, "%((%d+),%s*(%d+)%)")

	return tonumber(Row), tonumber(Column)
end

-- Converts given coordinates into a string and finds the matching square on the board

function Resources:Convert(Coordinates, Chessboard)
	local Row, Column = Coordinates.Row, Coordinates.Column
	local Identifier = string.format("(%d, %d)", Row, Column)

	return Chessboard.Board:FindFirstChild(Identifier)
end

-- Checks whether a given coordinate is within bounds (i.e. exists on the board)

function Resources.SquareInBounds(Coordinates, Chessboard)
	return Resources:Convert(Coordinates, Chessboard) ~= nil
end

-- Returns the stored piece coordinates from the match's data.

function Resources.GetCoordinates(Piece, Name)
	return Schema.Matches[Name].Pieces[Piece]
end

-- Converts a square to a Vector3 position (likely for piece movement / placement)

function Resources.GetSquareVector(Square, Chessboard)
	if Square:IsDescendantOf(Chessboard) then
		return Square.CFrame
	end
end

function Resources.Switch(Switching, Actor)
	return Switching[Actor]
end

-- Returns a move history for piece captures stating that the piece has been captured.

function Resources.Capture(Piece)
	local Coordinates = Piece:GetAttribute("Coordinates")

	local X, Y = Coordinates.Scale, Coordinates.Offset

	return {
		Piece = Piece:GetAttribute("Piece"),
		Colour = Piece:GetAttribute("Colour"),

		From = UDim.new(X, Y),

		Identifier = Piece:GetAttribute("Identifier"),
	}
end

-- Returns a move history template which could then later be used for PGN exportation, etc.

function Resources.Record(Piece, Square)
	local Row, Column = Resources.Unpack(Square)
	local Coordinates = Piece:GetAttribute("Coordinates")

	local X, Y = Coordinates.Scale, Coordinates.Offset

	return {
		Piece = Piece:GetAttribute("Piece"),
		Colour = Piece:GetAttribute("Colour"),

		To = UDim.new(Row, Column),
		From = UDim.new(X, Y),

		Timestamp = tick(),

		Capture = nil,

		Identifier = Piece:GetAttribute("Identifier"),
	}
end

return Resources
