local Storage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Server = game:GetService("Players")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Knit = require(Packages.Knit)
local Settings = require(Dependencies.Settings)
local Configuration = require(Dependencies.Configuration)

local Default = Configuration.Default
local Cooldown = Configuration.Cooldown

local Service = Knit.CreateService({
	Name = "Signal",

	Client = {
		Request = Knit.CreateSignal(),

		Accept = Knit.CreateSignal(),
		Deny = Knit.CreateSignal(),

		Info = Knit.CreateSignal(),
	},
})

local Challenges = {}

-- Rejects the current challenge of the given client by resetting it to null

function Service.Reject(Client, Opponent)
	if Challenges[Client][Opponent] then
		-- Remove the challenge against the specific opponent from the client's list

		Challenges[Client][Opponent] = Default.Null
	end
end

--[[
	Handles a challenge request from a client to an opponent.

	- Stores the challenge in the Challenges table.
	- Notifies the opponent about the challenge via the Info signal.
	- Waits for a configured cooldown duration before automatically rejecting the challenge.
]]

local Signals = Service.Client -- Short reference for client signals

function Service.Request(Client, Opponent)
	if not Challenges[Client][Opponent] then
		table.insert(Challenges[Client], Opponent)

		-- Notify the opponent about the challenge.

		Signals.Info:Fire(Opponent, Client)
	end

	-- Wait for the cooldown duration, then reject the challenge automatically.

	task.wait(Cooldown.Long)

	return Service.Reject(Client, Opponent)
end

--[[
	Handles accepting a challenge from a client to an opponent.

	- Initializes the chessboard for both players
  		and starts the match using default settings (e.g., Rapid mode).
	- After deploying, it clears the challenge.
]]

function Service.Accept(Client, Opponent)
	local Initialization = Knit.GetService("BoardInitialization")

	if Challenges[Opponent] then
		-- Deploy the chessboard with the two players.

		Initialization:Deploy({
			Competitors = {
				Black = Client,
				White = Opponent,
			},

			Identifier = HttpService:GenerateGUID(Default.Off),

			Mode = Settings.Modes.Rapid, -- Game mode, can be modified later.
		})
	end

	-- Clear the challenge after accepting.

	return Service.Reject(Client)
end

-- Initializes a new challenges list for the client if it doesn't exist yet

function Service.Add(Client)
	-- Checks whether the list exists or not.

	if not Challenges[Client] then
		Challenges[Client] = {}
	end
end

--[[
	Initializes the service by connecting remote signals to their corresponding handlers.

	- Connects the Request signal to the challenge request handler.
	- Connects the Accept signal to the challenge acceptance handler.
	- Connects the Deny signal to the challenge rejection handler.
]]

function Service:KnitInit()
	-- Initialize challenges list for all currently connected players at server start
	for Name, Client in Server:GetPlayers() do
		Service.Add(Client)
	end

	-- Handle incoming challenge requests from clients
	Signals.Request:Connect(function(Client, Opponent)
		return Service.Request(Client, Opponent)
	end)

	-- Handle challenge acceptances from clients
	Signals.Accept:Connect(function(Client, Opponent)
		-- TODO: Prevent the client from initiating more than two concurrent games

		return Service.Accept(Client, Opponent)
	end)

	-- Automatically set up challenges list for players who join later
	Server.PlayerAdded:Connect(Service.Add)

	-- Handle challenge rejections from clients
	Signals.Deny:Connect(Service.Reject)
end

return Service
