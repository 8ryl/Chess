local Storage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")

local Packages = Storage.Packages
local Dependencies = Storage.Dependencies

local Parameters = Dependencies.Parameters

local Knit = require(Packages.Knit)

local Utilities = require(Dependencies.Utilities)
local Configuration = require(Parameters.Configuration)

local Camera = Utilities.GetCameraAsync()
local Mouse = Utilities.GetMouseAsync()

local Preferences = Configuration.Highlight

local Component = Knit.CreateController({
	Name = "Projector",

	Objects = {},
})

Component.Piece = nil

-- Highlights valid movement squares based on the given trajectory

function Component:Project(Trajectory, Piece, Chessboard)
	local Highlights = {} -- Stores created highlight instances

	-- Updates the current piece to the newly selected one for projection

	Component.Piece = Piece

	-- Clears existing highlights when any are currently active

	if Utilities.isNotEmpty(Component.Objects) then
		Component:Disconnect(false)
	end

	for Name, Direction in Trajectory do -- Loop sthrough each direction in the trajectory
		for Position, Path in Direction do
			local Row, Column = Path.Row, Path.Column

			-- Creates a highlight and parent it to the corresponding square

			local Highlight = Utilities.CreateInstance("Highlight", {
				Parent = Utilities.RetrieveSquareWithinBoard({
					X = Row,
					Y = Column,
				}, Chessboard),

				FillColor = BrickColor.White().Color,
				DepthMode = Enum.HighlightDepthMode.Occluded,
			})

			-- Animates the highlight to add some luxurious effect to the game.

			Utilities.Animate(Highlight, Preferences, {
				FillColor = BrickColor.Blue().Color, -- Modify this to add customization
			}):Play()

			table.insert(Highlights, Highlight) -- Adds the highlight to the list
		end
	end

	-- Connects a Mouse Click listener to trigger square selection computati		local Position, Coordinates = Mouse.Hit.Position, Camera.CFrame

	Component.Connection = Mouse.Button1Down:Connect(function()
		return Component:Compute(Piece, Chessboard)
	end)

	Component.Objects = Highlights -- Stores every active highlight for cleanup
end

-- Listens for Mouse clicks and triggers square selection computation via raycasting.

function Component:Compute(Piece, Chessboard)
	local Service = Knit.GetService("Registry")

	local Settings = Utilities.CreateRaycastParameters({
		FilterDescendantsInstances = { Chessboard.Pieces },

		FilterType = Enum.RaycastFilterType.Exclude,
	})

	local Position, Coordinates = Mouse.Hit.Position, Camera.CFrame
	local Direction = (Position - Coordinates.Position).Unit * 250

	local Raycast = workspace:Raycast(Coordinates.Position, Direction, Settings)

	if Raycast then
		return Service:CheckAvailability(Piece, Raycast.Instance)
	end
end

-- Clears every highlight from the Chessboard

function Component:Disconnect(ThenRevertCamera)
	if Component.Connection then
		Component.Connection:Disconnect()
	end

	if ThenRevertCamera then
		Camera.CameraType = Enum.CameraType.Custom
	end

	Component.Connection = nil

	for Name, Object in Component.Objects do -- Loops through the stored highlights
		Object:Destroy() -- Removes the highlight from the board
	end

	table.clear(Component.Objects)
end

function Component:KnitStart()
	local Initialization = Knit.GetService("BoardInitialization")
	local Registry = Knit.GetService("Registry")

	Registry.Disconnect:Connect(function()
		return Component:Disconnect(false)
	end)

	Initialization.Draw:Connect(function()
		return Component:Disconnect(true)
	end)

	Initialization.Resignation:Connect(function()
		return Component:Disconnect(true)
	end)
end

return Component
