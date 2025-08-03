local Storage = game:GetService("ReplicatedStorage")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Configuration = require(Dependencies.Configuration)

-- Sorry, my ADHD got the best of me. I've went insane

return {
	Board = {
		Gold = 10,
	},

	Metadata = {
		Wins = 0,
		Losses = 0,

		Level = 1,

		Playtime = 0, -- Probably in minutes
		NumberOfGamesPlayed = 0,
	},
}
