local Storage = game:GetService("ReplicatedStorage")
local Animation = game:GetService("TweenService")
local Server = game:GetService("Players")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local Parameters = Dependencies:WaitForChild("Parameters")

local Configuration = require(Parameters.Configuration)
local Utilities = require(Dependencies.Utilities)

local Queue = require(Dependencies.Queue)
local Knit = require(Packages.Knit)

local Promise = require(Packages.Promise)

local Cooldown = Configuration.Cooldown

local PlayerGui = Utilities.GetDisplayAsync()
local Client = Utilities.GetClientAsync()

local Display = PlayerGui:WaitForChild("Display")
local Interface = Display:WaitForChild("Interface")

local Popup = Interface:WaitForChild("Popup")

local Accept = Popup:FindFirstChild("Accept")
local Ignore = Popup:FindFirstChild("Ignore")

local Thumbnail = Popup:FindFirstChild("Thumbnail")
local Label = Popup:FindFirstChild("Label")

local Preferences = Configuration.Request

local Component = Knit.CreateController({
	Name = "Requests",
})

local Requests = Queue.new()

-- Handles incoming challenge requests by adding them to the queue.

local Signal, OngoingSessions = nil, {}

function Component.Process(Opponent)
	Requests:Enqueue(Opponent, function()
		Component.Display(Opponent)
	end)
end

-- Remove the session from the active sessions table to clean up

function Component.Reset(myIndex)
	table.remove(OngoingSessions, myIndex)

	return Promise.new(function()
		Animation:Create(Popup, Preferences, {
			GroupTransparency = 1, -- Fully transparent
		}):Play()

		-- Wait for the specified delay before fully hiding the popup

		task.wait(Preferences.DelayTime)

		-- Hide the popup

		Popup.Visible = false
	end)
end

-- Displays the challenge request to the client.

function Component.Display(Opponent)
	table.insert(OngoingSessions, Opponent)

	-- Store the index of the opponent in the session list for later removal

	local myIndex = #OngoingSessions

	-- Sets the thumbnail image to the opponent's avatar/headshot

	Thumbnail.Image = Utilities.GetThumbnailAsync(Opponent)

	-- Display opponent’s name and username in a format.

	Label.Text = tostring(`{Opponent.DisplayName} (@{Opponent.Name})`)

	--[[
		Connections for handling client accept / ignore actions.

		After consideration, it's unnecessary to manually disconnect these events.
		Once they are overridden, Roblox will automatically handle garbage collection of the old connections.
	]]

	Accept.Activated:Connect(function()
		if not OngoingSessions[myIndex] then
			return warn("No ongoing session was found, preventing re-entry")
		end

		-- Fire the 'Accept' signal to acknowledge the opponent's challenge

		Signal.Accept:Fire(Opponent, "Rapid") --Change the mode accordingly

		-- Accepts the request. Fires a Remote signal

		return Component.Reset(myIndex)
	end)

	Ignore.Activated:Connect(function()
		-- Ignores the opponent's challenge request

		return Component.Reset(myIndex)
	end)

	Popup.Visible = true

	-- Animates the popup's GroupTransparency property

	Animation:Create(Popup, Preferences, {
		GroupTransparency = 0,
	}):Play()

	-- Simulate user interaction delay or cooldown

	task.delay(Cooldown.Long, function()
		if not OngoingSessions[myIndex] then
			return "Session not found for the specified opponent"
		end

		local Object = Requests:Dequeue()

		warn("Concurrent requests:", Requests.Queue)

		-- Makes sure the opponent actually exists before skipping onto the said opponent.

		if Object:IsDescendantOf(Server) then
			print("Skipped, said opponent:", Object)

			return Component.Skip(Object)
		end
	end)
end

-- Skips the current request and processes the next one in the queue.

function Component.Skip(Opponent)
	if Requests:IsEmpty() then
		warn("No more requests to process, evacuating..")

		return Component.Reset()
	end

	print("Processing challenge from:", Opponent)

	return Component.Display(Opponent)
end

--[[
	Initializes the controller when Knit starts.

	Listens for incoming requests from the "Signal" service
	and processes them when received.
]]

function Component:KnitStart()
	-- Assigns the Signal variable to the service itself.

	Signal = Knit.GetService("Signal")

	-- Listens for incoming requests and processes them.

	return Signal.Info:Connect(Component.Process)
end

return Component
