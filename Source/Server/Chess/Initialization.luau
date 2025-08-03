local Server = game:GetService("ServerScriptService")
local Storage = game:GetService("ReplicatedStorage")
local Assets = game:GetService("ServerStorage")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages
local Directory = Server.Storage
local Chess = Directory.Chess

local Parameters = Dependencies.Parameters

local Arbiter = Chess.Arbiter

local Chessboard = Assets.Chessboard

local Knit = require(Packages.Knit)

local Schema = require(Arbiter.Schema)
local Settings = require(Parameters.Settings)

local Utilities = require(Dependencies.Utilities)
local Configuration = require(Parameters.Configuration)

-- Knit service for creating, positioning, and managing chessboards during match sessions
local Service = Knit.CreateService({
	Name = "BoardInitialization",

	Client = {
		All = Knit.CreateSignal(), -- Broadcasts board setup to connected players
		Draw = Knit.CreateSignal(), -- Sends draw outcome details to connected players
		Resignation = Knit.CreateSignal(), -- Sends resignation outcome details to connected players
	},

	Board = {}, -- Holds chessboard-specific functions
})

local Client = Service.Client
local Matches = Schema.Matches

-- Generates a new chessboard model and places it in the match environment

function Service.Board:Initialize(Content)
	-- Creates a copy of the chessboard model, assigns the match identifier, and attaches it to the workspace

	local Chessboard = Utilities.CloneInstance(Chessboard, {
		Name = Content.Identifier,
		Parent = workspace.Matches,
	})

	-- Moves the chessboard to a location based on the number of currently active matches

	Chessboard:PivotTo(
		CFrame.new(Vector3.new(Settings.Offset.X * #Matches, Settings.Offset.Y, Settings.Offset.Z * #Matches))
	)

	return Chessboard
end

-- Sets up a chessboard and communicates the setup to all players in the match

function Service:Deploy(Identifier, Content)
	Content.Identifier = Identifier

	-- Builds and places the chessboard for this specific match session

	Content.Board = Service.Board:Initialize(Content)

	-- Waits briefly to guarantee the board assets finish loading

	task.wait(Configuration.Delay.Semi)

	-- Populates the internal storage table with all chess pieces from the created chessboard

	local Board = Content.Board

	for Name, Folder in Board.Pieces:GetChildren() do
		for Set, Piece in Folder:GetChildren() do
			-- Retrieves the coordinate data stored in the piece attributes

			local Coordinates = Piece:GetAttribute("Coordinates")

			-- Maps Offset as the vertical index (y-axis) and Scale as the horizontal index (x-axis)

			local yAxis, xAxis = Coordinates.Offset, Coordinates.Scale

			-- Prepares the row table in storage for incoming column data

			if not Content.Storage[xAxis] then
				Content.Storage[xAxis] = {}
			end

			-- Inserts the piece into the storage table using its grid coordinates

			Content.Storage[xAxis][yAxis] = Piece

			-- Tags the piece with the current match identifier for tracking

			Piece:SetAttribute("Identifier", Identifier)
		end
	end

	-- Notifies all participating players of their orientation, pieces, and board assignment

	for Name, Competitor in Content.Competitors do
		Client.All:Fire(Competitor.Contender, Board, Settings.Orientation[Name], Board.Pieces[Name])
	end

	-- Records this match and its data in the active matches registry

	Schema.Matches[Identifier] = Content
end

-- Handles the resignation outcome for a given match and rewards the winner

function Service:Resign(Identifier, Winner: "Black" | "White")
	local Database = Knit.GetService("Database")

	-- Verifies that the match session exists in the active registry

	if not Schema.Matches[Identifier] then
		return "Invalid operation: no active match session associated with the provided Identifier."
	end

	local Content = Schema.Matches[Identifier]
	local User = Content.Competitors[Winner]

	if not Database:RetrieveDataAsynchronously(User.Contender) then
		return "Operation aborted: persistent profile data unavailable for the specified user."
	end

	-- Adds logic for ending the match timer later

	local Data = Database:RetrieveDataAsynchronously(User.Contender)

	-- Increases the player’s stored currency value for winning the match

	Data.Board[Schema.Currency] += 1

	-- Sends a disconnect signal to both players to end the session

	for Name, Competitor in Content.Competitors do
		Client.Disconnect:Fire(Competitor.Contender, User)
	end

	-- Removes the chessboard model from the game and frees memory

	Content.Board:Destroy()
end

-- Handles a draw outcome by rewarding both players and cleaning up the match
function Service:Draw(Identifier, Cause)
	local Database = Knit.GetService("Database")

	-- Verifies that the match session exists in the active registry

	if not Schema.Matches[Identifier] then
		return "Invalid operation: no active match session associated with the provided Identifier."
	end

	-- Adds logic for ending the match timer later

	local Content = Schema.Matches[Identifier]

	-- Processes both players’ rewards and notifies them of the draw result

	for Name, Competitor in Content.Competitors do
		if not Database:RetrieveDataAsynchronously(Competitor.Contender) then
			return "Operation aborted: persistent profile data unavailable for the specified user."
		end

		local Data = Database:RetrieveDataAsynchronously(Competitor.Contender)

		-- Adds half the standard currency reward to each player’s profile data

		Data.Board[Schema.Currency] += 0.5

		-- Notifies the player about the draw cause

		Client.Draw:Fire(Competitor.Contender, Cause)
	end

	-- Removes the chessboard model from the game and frees memory

	Content.Board:Destroy()
end

return Service
