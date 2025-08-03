local Storage = game:GetService("ReplicatedStorage")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Configuration = require(Dependencies.Configuration)

local Keywords = Configuration.Keywords

-- Sorry, my ADHD got the best of me. I've went insane

return {
	Board = {
		Gold = 10,
	},

	Metadata = {
		Wins = Keywords.Zero,
		Losses = Keywords.Zero,

		Level = Keywords.One,

		Playtime = Keywords.Zero, -- Probably in minutes
		NumberOfGamesPlayed = Keywords.Zero,
	},
}
