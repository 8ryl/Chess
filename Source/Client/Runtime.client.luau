local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Utilities = require(Dependencies.Utilities)
local Knit = require(Packages.Knit)

local Client = Utilities.GetClientAsync()
local PlayerGui = Utilities.GetDisplayAsync()

local Display = PlayerGui:WaitForChild("Display")
local Libraries = Display:WaitForChild("Libraries")

local PlayerScripts = Client:WaitForChild("PlayerScripts")

-- Load Knit controllers from the Libraries directory

Knit.AddControllersDeep(Libraries)

-- Load Knit controllers from the PlayerScripts directory

Knit.AddControllersDeep(PlayerScripts.Client)

-- Start Knit and print confirmation once initialized

Knit.Start():andThen(function()
	print("Client environment initialized successfully.")
end)
