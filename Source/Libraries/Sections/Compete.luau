local Storage = game:GetService("ReplicatedStorage")
local Contenders = game:GetService("Players")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local Parameters = Dependencies:WaitForChild("Parameters")

local Configuration = require(Parameters.Configuration)
local Utilities = require(Dependencies.Utilities)

local Knit = require(Packages.Knit)

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

-- Adds a player entry to the Compete section's user interface.

function Component.Add(Client)
	local Signal = Knit.GetService("Signal")

	local Clone = Utilities.CloneInstance(Container.Object, {
		Visible = true,
		Parent = Holder,
	})

	local Username = Clone.Username
	local Thumbnail = Clone.Thumbnail
	local Challenge = Clone.Challenge

	Clone.Name = tostring(Client.DisplayName)
	Username.Text = tostring(`{Client.DisplayName} (@{Client.Name})`)

	Thumbnail.Image = Utilities.GetThumbnailAsync(Client)

	Challenge.Activated:Connect(function()
		-- 'Client' parameter resembles the challenger himself

		return Signal.Request:Fire(Client)
	end)
end

-- Removes a player entry from the Compete section's user interface

function Component.Remove(Client)
	if Holder:FindFirstChild(Client.DisplayName) then
		return Holder:FindFirstChild(Client.DisplayName):Destroy()
	end
end

-- Initializes the Compete controller when Knit starts.

function Component:KnitStart()
	for Name, Client in Contenders:GetPlayers() do
		Component.Add(Client)
	end

	Contenders.PlayerAdded:Connect(Component.Add)
	Contenders.PlayerRemoving:Connect(Component.Remove)
end

return Component
