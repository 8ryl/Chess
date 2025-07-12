local Script = game:GetService("ServerScriptService")
local Storage = game:GetService("ReplicatedStorage")
local Server = game:GetService("Players")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Directory = Script.Server
local Store = Directory.Store

local Knit = require(Packages.Knit)
local Template = require(Store.Template)
local ProfileStore = require(Packages.Store)

local Configuration = require(Dependencies.Configuration)
local Utilities = require(Dependencies.Utilities)

local Cooldown = Configuration.Cooldown
local Default = Configuration.Default

local Service = Knit.CreateService({
	Name = "DatabaseHandlerModule",
})

Service.Client = {}
Service.Profiles = {}

-- Change the database name before releasing to reset the data.

local Database = ProfileStore.New("LiveDemo", Template)

--[[
  Defines the Profile type based on the return type of Database:StartSessionAsync().
  This helps with type checking and autocomplete for profile-related variables.
]]

type Profile = typeof(Database:StartSessionAsync())

-- Returns a unique key string for the player's profile.

function Service.RetrieveProfileKeyIdentifier(Client: Player)
	return tostring(Client.UserId)
end

-- Allows the client to fetch their saved data.

function Service.Client.GetProfileDataAsync(Client: Player)
	return Service.Profiles[Client].Data
end

-- Removes the player's profile from memory upon disconnection.

function Service.Remove(Player: Player)
	Service.Profiles[Player] = Default.Null
end

--[[
  Initializes a player's profile session.

  - Starts a data session for the player.
  - Kicks the player if their profile can't be loaded.
  - Adds GDPR-compliant user ID tracking.
  - Fills missing data fields with default values.
  - Handles session locking and auto-disconnects.
  - If the player has already left, the session is ended immediately.
  - Otherwise, sets up the leaderboard and stores the profile.
]]

function Service.Connect(Client: Player)
	--[[
    Starts a data session for the player.

  - Generates a unique profile key for the player.
  - Cancels the session if the player has left before it finishes.
  ]]

	local Profile: Profile = Database:StartSessionAsync(Service.RetrieveProfileKeyIdentifier(Client), {
		Cancel = function()
			return not Client:IsDescendantOf(Server)
		end,
	})

	-- If the session couldn't start, kick the player to prevent issues.

	if not Profile then
		return Client:Kick("Data error occured, retry again later.")
	end

	Profile:AddUserId(Client.UserId) -- GDPR compliance.
	Profile:Reconcile() -- Fills in missing data fields from the template.

	-- Handles unexpected session end (e.g., profile locked elsewhere).

	Profile.OnSessionEnd:Connect(function()
		return Client:Kick("Data error occured, retry again later."), Service.Remove(Client)
	end)

	-- Check if the player is still in the game after session setup.

	if Client:IsDescendantOf(Server) then
		-- Store the profile and initialize the player's leaderboard.

		Service.Profiles[Client] = Profile

		return Service:Initialize(Client, Profile)
	else
		-- If the player already left, end the session and clean up.

		Profile:EndSession()

		return Service.Remove(Client)
	end
end

-- Ends a player's data session and removes their profile when they leave the game.

function Service.Disconnect(Client: Player)
	local Profile = Service.Profiles[Client]

	assert(Profile, "No profile was found during the disconnection process.")

	return Profile:EndSession(), Service.Remove(Client)
end

--[[
  Sets up the player's leaderboard ("leaderstats") folder.

  - Creates an IntValue for each data point in the player's profile.
  - Automatically updates the profile data when leaderboard values change.
]]

function Service:Initialize(Client: Player, Profile: Profile)
	local Board = Utilities.CreateInstance("Folder", {
		Name = "leaderstats",
		Parent = Client,
	})

	for Name, Value in Profile.Data.Leaderboard do
		local Object = Utilities.CreateInstance("IntValue", {
			Name = Name,
			Value = Value,
			Parent = Board,
		})

		Object:GetPropertyChangedSignal("Value"):Connect(function()
			Profile.Data.Leaderboard[Name] = Object.Value
		end)
	end
end

--[[
  Initializes the service when the game starts.

  - Connects all currently connected players.
  - Connects player added/removed events to handle profile loading/unloading.
]]

function Service:KnitStart()
	for Name, Player in Server:GetPlayers() do
		task.spawn(Service.Connect, Player)
	end

	Server.PlayerAdded:Connect(Service.Connect)
	Server.PlayerRemoving:Connect(Service.Disconnect)
end

return Service
