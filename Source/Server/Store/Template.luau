local Storage = game:GetService("ReplicatedStorage")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Configuration = require(Dependencies.Configuration)

local Default = Configuration.Default

-- Sorry, my ADHD got the best of me. I've went insane

return {
	Leaderboard = {
		Gold = 10,
	},

	Metadata = {
		Wins = Default.Zero,
		Losses = Default.Zero,

		Level = Default.One,

		Playtime = Default.Zero, -- Probably in minutes
		NumberOfGamesPlayed = Default.Zero,
	},
}
