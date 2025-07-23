local Server = game:GetService("ServerScriptService")
local Storage = game:GetService("ReplicatedStorage")
local Assets = game:GetService("ServerStorage")

local Vault = Server.Storage
local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Chess = Assets.Chessboard
local Directory = Server.Storage

local Knit = require(Packages.Knit)
local Schema = require(Vault.Schema)
local Settings = require(Dependencies.Settings)
local Utilities = require(Dependencies.Utilities)
local Configuration = require(Dependencies.Configuration)

-- Knit service responsible for initializing and deploying chessboards for matches
local Service = Knit.CreateService({
	Name = "BoardInitialization",

	Client = {
		All = Knit.CreateSignal(), -- Signal to notify clients about board setup
	},

	Board = {}, -- Namespace for board-related methods
})

local Client = Service.Client
local Matches = Schema.Matches

-- Initializes a new chessboard for a match

function Service.Board:Initialize(Content)
	-- Clone the chessboard model and assign its identifier and parent

	local Chessboard = Utilities.CloneInstance(Chess, {
		Name = Content.Identifier,
		Parent = workspace.Matches,
	})

	-- Position the chessboard based on the number of active matches

	Chessboard:PivotTo(
		CFrame.new(Vector3.new(Settings.Offset.X * #Matches, Settings.Offset.Y, Settings.Offset.Z * #Matches))
	)

	return Chessboard
end

-- Deploys the chessboard and notifies all competitors

function Service:Deploy(Content)
	-- Initialize and position the chessboard for this match

	Content.Board = Service.Board:Initialize(Content)

	-- Added in a wait function to make sure the board fully loaded in.

	task.wait(Configuration.Delay.Semi)

	-- Loop through each individual pieces inside the concurrent directory

	for Name, Folder in Content.Board.Pieces:GetChildren() do
		for Set, Piece in Folder:GetChildren() do
			-- Retrieve the stored coordinates from the piece's attributes

			local Coordinates = Piece:GetAttribute("Coordinates")

			-- yAxis refers to the vertical columns, while xAxis refers to the horizontal rows.

			local yAxis, xAxis = Coordinates.Offset, Coordinates.Scale

			-- Ensures the Row table exists before assigning a value to a specific column.

			if not Content.Storage[xAxis] then
				Content.Storage[xAxis] = {}
			end

			-- Stores the coordinates into the content's internal storage with it's piece

			Content.Storage[xAxis][yAxis] = Piece

			-- Assign a unique identifier to the piece for tracking or grouping

			Piece:SetAttribute("Identifier", Content.Identifier)
		end
	end

	-- Notify competitors about their assigned board and pieces

	for Name, Competitor in Content.Competitors do
		Client.All:Fire(Competitor.User, Content.Board, Settings.Orientation[Name], Content.Board.Pieces[Name])
	end

	-- Register this match into the active matches list

	Schema.Matches[Content.Identifier] = Content
end

return Service
