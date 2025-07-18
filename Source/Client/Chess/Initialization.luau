local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Knit = require(Packages.Knit)

local Settings = require(Dependencies.Settings)
local Utilities = require(Dependencies.Utilities)
local Configuration = require(Dependencies.Configuration)

local Default = Configuration.Default
local Preferences = Settings.Camera

local Client = Utilities.GetClientAsync()

--[[
	Knit controller that listens for chessboard initialization events.

	This component handles client-side setup, such as camera positioning
	and attaching sensors (e.g., ClickDetectors) to the chess pieces.
]]

local Component = Knit.CreateController({
	Name = "ChessInitializationListener",
})

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
		* CFrame.Angles(Default.Zero, Yaw, Default.Zero)
		* CFrame.new(Default.Zero, Preferences.Offset.Y, Preferences.Offset.Z)
		* CFrame.Angles(Preferences.Tilt.X, Default.Zero, Default.Zero)

	-- Set the camera to look toward the center of the chessboard from the computed position

	Camera.CFrame = CFrame.new(Base.Position, Center)

	-- Switch camera to Scriptable mode to allow full manual control

	Camera.CameraType = Enum.CameraType.Scriptable
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

		Sensor.MouseClick:Connect(function()
			-- Retrieves the cached path for the object, or invoke the service method and await the result

			--[[
			There is a problem with caching is it doesn't update the cache when the piece has moved

			local Status, Path = Utilities.TryAccessOrCompute(Component.Cache, Object, function()
				-- Do not ADD an "await" call, as that automatically happens when wrapping.

				return Service[Attribute](Client, Object)
			end)
			]]

			if Projector.Connection then
				return "There is already an ongoing connection"
			end

			local Status, Path = Service[Attribute](Client, Object):await()

			-- Guard statement to ensure the service call completed successfully

			assert(Status, "Failed to retrieve path for the specified piece via service method.")

			-- Assigns the computed path to the cache only when no cached entry exists.

			if not Component.Cache[Object] then
				Component.Cache[Object] = Path
			end

			-- Project the resolved path onto the chessboard using the projector

			return Projector:Project(Path, Object, Chessboard)
		end)
	end
end

--[[
	Knit lifecycle method that runs when the controller starts.

	Connects to the BoardInitialization service and responds to board setup events
	by configuring the camera and enabling interaction with pieces.
]]

function Component:KnitStart()
	local Service = Knit.GetService("BoardInitialization")

	-- Connects to the board initialization signal to set up the camera and piece sensors.

	Service.All:Connect(function(Chessboard, Orientation, Pieces)
		return Component.Camera(Chessboard, Orientation), Component.Sensors(Chessboard, Pieces)
	end)
end

return Component
