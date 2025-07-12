local Storage = game:GetService("ReplicatedStorage")
local Server = game:GetService("ServerStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Chess = Server.Chessboard

local Knit = require(Packages.Knit)
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

-- Initializes a new chessboard for a match

function Service.Board:Initialize(Content)
	-- Clone the chessboard model and assign its identifier and parent

	local Chessboard = Utilities.CloneInstance(Chess, {
		Name = Content.Identifier,
		Parent = workspace.Matches,
	})

	-- Position the chessboard based on the number of active matches

	Chessboard:PivotTo(
		CFrame.new(
			Vector3.new(Settings.Offset.X * #Settings.Matches, Settings.Offset.Y, Settings.Offset.Z * #Settings.Matches)
		)
	)

	return Chessboard
end

-- Deploys the chessboard and notifies all competitors

function Service:Deploy(Content)
	-- Initialize and position the chessboard for this match

	Content.Board = Service.Board:Initialize(Content)

	-- Added in a wait function to make sure the board fully loaded in.

	task.wait(Configuration.Delay.Semi)

	-- Notify competitors about their assigned board and pieces

	for Name, Competitor in Content.Competitors do
		Client.All:Fire(Competitor, Content.Board, Settings.Orientation[Name], Content.Board.Pieces[Name])
	end

	-- Register this match into the active matches list

	return table.insert(Settings.Matches, Content)
end

return Service
