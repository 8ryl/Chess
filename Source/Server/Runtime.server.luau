local ServerScriptService = game:GetService("ServerScriptService")
local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages

local Knit = require(Packages.Knit)

-- Load Knit services from ServerScriptService

Knit.AddServicesDeep(ServerScriptService)

-- Start Knit and print confirmation once initialized

Knit.Start():andThen(function()
	print("Server environment initialized successfully.")
end)
