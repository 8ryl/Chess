local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Utilities = require(Dependencies.Utilities)
local Knit = require(Packages.Knit)

local PlayerGui = Utilities.GetDisplayAsync()

local Display = PlayerGui:WaitForChild("Display")
local Libraries = Display:WaitForChild("Libraries")

-- Load Knit controllers from the Libraries folder

Knit.AddControllersDeep(Libraries)

-- Start Knit and print confirmation once initialized

Knit.Start():andThen(function()
	print("Client environment initialized successfully.")
end)
