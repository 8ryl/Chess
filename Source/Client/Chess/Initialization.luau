local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Knit = require(Packages.Knit)

local Settings = require(Dependencies.Settings)
local Utilities = require(Dependencies.Utilities)
local Configuration = require(Dependencies.Configuration)

local Keywords = Configuration.Keywords
local Preferences = Settings.Camera

local Client = Utilities.GetClientAsync()
local PlayerGui = Utilities.GetDisplayAsync()

local Display = PlayerGui:WaitForChild("Display")
local Interface = Display:WaitForChild("Interface")

--[[
	Knit controller that listens for chessboard initialization events.

	This component handles client-side setup, such as camera positioning
	and attaching sensors (e.g., ClickDetectors) to the chess pieces.
]]

local Component = Knit.CreateController({
	Name = "ChessInitializationListener",
})

Component.Connections = {}
Component.Cache = {}

-- Adjusts the camera to focus on the chessboard from above, considering orientation

function Component.Camera(Chessboard, Orientation)
	local Frame = Chessboard:GetBoundingBox()
	local Center = Frame.Position -- Get the chessboard's center position

	local Camera = Utilities.GetCameraAsync()

	local Yaw = math.rad(Orientation) -- Convert orientation angle from degrees to radians for rotation

	--[[ 
		Construct the camera's CFrame in multiple steps:

		1. Position the camera at the center of the chessboard.
		2. Apply rotation around the Y-axis to align the view based on the player's orientation.
		3. Offset the camera's position upward and forward/backward relative to the rotated board.
		4. Tilt the camera downward by rotating around the X-axis for a better viewing angle.
	]]

	local Base = CFrame.new(Center)
		* CFrame.Angles(Keywords.Zero, Yaw, Keywords.Zero)
		* CFrame.new(Keywords.Zero, Preferences.Offset.Y, Preferences.Offset.Z)
		* CFrame.Angles(Preferences.Tilt.X, Keywords.Zero, Keywords.Zero)

	-- Set the camera to look toward the center of the chessboard from the computed position

	Camera.CFrame = CFrame.new(Base.Position, Center)

	-- Switch camera to Scriptable mode to allow full manual control

	Camera.CameraType = Enum.CameraType.Scriptable
end

function Component:Display(Interface, Console)
	local Popup = Knit.GetController("Popup")

	for Name, Object in Interface:GetChildren() do
		if not Object:IsA("GuiObject") then
			continue
		end

		Object.Visible = Keywords.Off
	end

	for Name, Object in Console:GetChildren() do
		if not Object:IsA("GuiObject") then
			continue
		end

		Object.Visible = Keywords.On
	end

	return Popup:Reset(Keywords.Off)
end

-- Adds sensors (aka ClickDetectors) to chess pieces for interaction.

function Component.Sensors(Chessboard, Pieces)
	local Service = Knit.GetService("Registry")
	local Projector = Knit.GetController("Projector")

	-- Iterates over each piece in the provided directory.

	for Name, Object in Pieces:GetChildren() do
		-- Creates a ClickDetector for each piece (Unit).

		local Sensor = Utilities.CreateInstance("ClickDetector", {
			MaxActivationDistance = 10e6, -- Effectively unlimited activation range

			Parent = Object, -- Parents the Sensor to the piece
			Name = "Sensor", -- Names the Sensor to "Sensor"
		})

		local Attribute: string = Object:GetAttribute("Piece")

		-- Sets up the detector to respond to click input on this piece

		local Connection = Sensor.MouseClick:Connect(function()
			-- Retrieves the cached path for the object, or invoke the service method and await the result

			--[[
			There is a problem with caching is it doesn't update the cache when the piece has moved

			local Status, Path = Utilities.TryAccessOrCompute(Component.Cache, Object, function()
				-- Do not ADD an "await" call, as that automatically happens when wrapping.

				return Service[Attribute](Client, Object)
			end)
			]]

			if Object:GetAttribute("State") ~= "None" then
				return "Capture state active for the piece."
			end

			-- Disconnects an ongoing connection when there is one.

			if Projector.Connection then
				Projector:Disconnect()
			end

			local Status, Path = Service[Attribute](Client, Object):await()

			-- Guard statement to ensure the service call completed successfully

			assert(Status, "Failed to retrieve path for the specified piece via service method.")

			-- Guard statement for piece mobility turns.

			if typeof(Path) ~= "table" then
				return "Could not process move path: expected table structure."
			end

			-- Assigns the computed path to the cache only when no cached entry exists.

			if not Component.Cache[Object] then
				Component.Cache[Object] = Path
			end

			-- Project the resolved path onto the chessboard using the projector

			return Projector:Project(Path, Object, Chessboard)
		end)

		table.insert(Component.Connections, Connection)
	end
end

--[[
	Knit lifecycle method that runs when the controller starts.

	Connects to the BoardInitialization service and responds to board setup events
	by configuring the camera and enabling interaction with pieces.
]]

function Component:KnitStart()
	local Initialization = Knit.GetService("BoardInitialization")

	-- Connects to the board initialization signal to set up the camera and piece sensors.

	Initialization.All:Connect(function(Chessboard, Orientation, Pieces)
		return Component.Camera(Chessboard, Orientation),
			Component:Display(Interface, Interface.Console),
			Component.Sensors(Chessboard, Pieces)
	end)

	Initialization.Resignation:Connect(function(Winner)
		-- TODO: Implement frontend winner animations

		for Name, Connection in Component.Connections do
			Connection:Disconnect()
		end
	end)

	Initialization.Draw:Connect(function(Cause)
		-- TODO: Implement frontend Draw animations

		for Name, Connection in Component.Connections do
			Connection:Disconnect()
		end
	end)
end

return Component
