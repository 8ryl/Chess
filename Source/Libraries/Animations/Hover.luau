local Storage = game:GetService("ReplicatedStorage")
local Animation = game:GetService("TweenService")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local MouseOver = require(Dependencies.Client.MouseOverModule)
local Configuration = require(Dependencies.Configuration)
local Utilities = require(Dependencies.Utilities)
local Knit = require(Packages.Knit)

local PlayerGui = Utilities.GetDisplayAsync()
local Client = Utilities.GetClientAsync()

local Default = Configuration.Default

local Component = Knit.CreateController({
	Name = "Hover",
})

--[[
	This module handles button hover and click animations within the user interface.
	It uses TweenService to smoothly animate buttons when the player hovers over or clicks them.

	Settings (animation durations, sizes, etc.) are configurable via the Configuration module.

	Usage:
	- Automatically applies hover and click effects to buttons inside the Interface.Container folder.
]]

function Component:Init(Button: GuiButton)
	-- Get custom mouse enter and leave events for the button
	local MouseEnter, MouseLeave = MouseOver.MouseEnterLeaveEvent(Button)

	-- Load hovering animation settings and cache the button's original size
	local Settings, Cache = Configuration.Hovering, Button.Size

	-- Slightly increases the button’s size for a smooth hover effect.

	MouseEnter:Connect(function()
		Animation:Create(Button, Settings.Animation(Default.Off, Default.Zero), {
			Size = UDim2.fromScale(Cache.X.Scale + Settings.Size, Cache.Y.Scale + Settings.Size),
		}):Play()
	end)

	-- Smoothly restores the button to its original size.

	MouseLeave:Connect(function()
		Animation:Create(Button, Settings.Animation(Default.Off, Default.Zero), {
			Size = UDim2.fromScale(Cache.X.Scale, Cache.Y.Scale),
		}):Play()
	end)

	-- Button briefly shrinks slightly to simulate a "pressed" effect.

	Button.Activated:Connect(function()
		Animation:Create(Button, Settings.Animation(Default.On, Default.Zero), {
			Size = UDim2.fromScale(Cache.X.Scale - (Settings.Size / 2), Cache.Y.Scale - (Settings.Size / 2)),
		}):Play()
	end)
end

--[[
	Initializes the Hover component when Knit starts.
]]

function Component:KnitStart()
	local Display = PlayerGui:WaitForChild("Display")
	local Interface = Display:WaitForChild("Interface")

	for Name, Button in Interface.Container:GetChildren() do
		if not Button:IsA("GuiButton") then
			continue
		end

		Component:Init(Button)
	end
end

return Component
