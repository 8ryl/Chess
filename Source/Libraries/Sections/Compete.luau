local Storage = game:GetService("ReplicatedStorage")
local Server = game:GetService("Players")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local Configuration = require(Dependencies.Configuration)
local Utilities = require(Dependencies.Utilities)
local Knit = require(Packages.Knit)

local Default = Configuration.Default

local PlayerGui = Utilities.GetDisplayAsync()

local Display = PlayerGui:WaitForChild("Display")
local Interface = Display:WaitForChild("Interface")

local Sections = Interface:WaitForChild("Sections")

local Compete = Sections:FindFirstChild("Compete")

local Container = Compete:FindFirstChild("Container")
local Holder = Compete:FindFirstChild("Holder")

local Component = Knit.CreateController({
	Name = "Compete",
})

--[[
	Adds a player entry to the Compete section's user interface.
]]

function Component.Add(Client)
	local Signal = Knit.GetService("Signal")
	local Clone = Container.Object:Clone()

	local Username = Clone.Username
	local Thumbnail = Clone.Thumbnail
	local Challenge = Clone.Challenge

	Clone.Name = tostring(Client.DisplayName)
	Username.Text = tostring(`{Client.DisplayName} (@{Client.Name})`)

	Thumbnail.Image = Utilities.GetThumbnailAsync(Client)

	Challenge.Activated:Connect(function()
		-- 'Client' parameter resembles the challenger himself

		Signal.Request:Fire(Client)
	end)

	Clone.Parent = Holder
	Clone.Visible = Default.On
end

--[[
	Removes a player entry from the Compete section's user interface
]]

function Component.Remove(Client)
	return Holder:FindFirstChild(Client.DisplayName):Destroy()
end

--[[
	Initializes the Compete controller when Knit starts.
]]

function Component:KnitStart()
	for Name, Client in Server:GetPlayers() do
		Component.Add(Client)
	end

	Server.PlayerAdded:Connect(Component.Add)
	Server.PlayerRemoving:Connect(Component.Remove)
end

return Component
