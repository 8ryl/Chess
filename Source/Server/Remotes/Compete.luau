local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Knit = require(Packages.Knit)
local Configuration = require(Dependencies.Configuration)

local Default = Configuration.Default

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

function Service.Reject(Client)
	if Challenges[Client] then
		Challenges[Client] = Default.Null
	end
end

function Service.Request(Client, Opponent)
	if not Challenges[Client] then
		Challenges[Client] = Opponent

		Service.Client.Info:Fire(Opponent, Client)
	end

	task.wait(Configuration.Cooldown.Long)

	return Service.Reject(Client)
end

function Service.Accept(Client, Opponent)
	if Challenges[Client] then
		-- TODO: Initializes the chessboard for the two players.
	end

	return Service.Reject(Client)
end

function Service:KnitInit()
	Service.Client.Request:Connect(function(Client, Opponent)
		return Service.Request(Client, Opponent)
	end)

	Service.Client.Accept:Connect(function(Client, Opponent)
		return Service.Request(Client, Opponent)
	end)

	Service.Client.Deny:Connect(Service.Reject)

	print("Successfully initialized the remote side.")
end

return Service
