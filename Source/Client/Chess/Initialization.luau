local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Knit = require(Packages.Knit)

local Settings = require(Dependencies.Settings)
local Utilities = require(Dependencies.Utilities)
local Configuration = require(Dependencies.Configuration)

local Default = Configuration.Default
local Preferences = Settings.Camera

--[[
	Knit controller that listens for chessboard initialization events.

	This component handles client-side setup, such as camera positioning
	and attaching sensors (e.g., ClickDetectors) to the chess pieces.
]]

local Component = Knit.CreateController({
	Name = "ChessInitializationListener",
})

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
	print(Chessboard, Pieces)

	-- TODO: Attach ClickDetectors to pieces for player interaction
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
