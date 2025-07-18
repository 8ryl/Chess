--[[
	This module defines common constants, delays, animation settings, and interface-related parameters.
	It centralizes every tweakable value for easy adjustments across the game.

	Developer Note: Modify the values at your own risk, might cause some problems!
]]

local Configuration = {
	-- Delay presets (in seconds) for various animations

	Delay = {
		Tick = 0.065, -- Very fast
		Fast = 0.125, -- Fast delay
		Semi = 0.175, -- Slight delay
		Medium = 0.375, -- Moderate delay
		Long = 0.875, -- Long delay
	},
}

-- Cooldown durations (in seconds) for certain actions or systems

Configuration.Cooldown = {
	Small = 2.5,
	Medium = 5,
	Long = 10,
}

-- Default constants for common logic and interface usage

Configuration.Default = {
	Zero = math.round(0.25), -- Rounded value often used for transparency
	One = math.round(1.25), -- Rounded value often used for full or near-full opacity

	On = true, -- Boolean 'On' state
	Off = false, -- Boolean 'Off' state
	Null = nil, -- Represents a null state
}

local Default = Configuration.Default

-- Settings specific to challenge requests

Configuration.Request = {
	Delay = Configuration.Delay.Medium, -- How long the animation lasts

	Style = Enum.EasingStyle.Quad, -- Easing style for animation
	Direction = Enum.EasingDirection.Out, -- Easing direction for animation
}

-- Settings for panel popup interfaces (do not modify the Blur/Shadow/Panel values!

Configuration.Popup = {
	Delay = Configuration.Delay.Semi, -- Animation duration for popups

	Style = Enum.EasingStyle.Sine, -- Easing style for smooth animations
	Direction = Enum.EasingDirection.Out, -- Easing direction

	Blur = { On = 15, Off = 2.5 },
	Shadow = { On = 0.45, Off = Default.One },
	Panel = { On = Default.Zero, Off = Default.One },
}

Configuration.Highlight = {
	Delay = Configuration.Delay.Fast, -- Duration of highlight animation

	Style = Enum.EasingStyle.Sine, -- Easing style for highlight
	Direction = Enum.EasingDirection.Out, -- Easing direction for highlight
}

-- Represents the piece movement

Configuration.Movement = {
	Delay = Configuration.Delay.Fast, -- Duration of highlight animation

	Style = Enum.EasingStyle.Sine, -- Easing style for highlight
	Direction = Enum.EasingDirection.Out, -- Easing direction for highlight
}

Configuration.Hovering = {
	Delay = Configuration.Delay.Semi, -- Duration of hover animation

	Style = Enum.EasingStyle.Sine, -- Easing style for hover
	Direction = Enum.EasingDirection.Out, -- Easing direction for hover
}

Configuration.Hovering.Size = 2.5 / 100 -- Scale change percentage for hover effect (5% larger)

local Request = Configuration.Request
local Highlight = Configuration.Highlight
local Popup = Configuration.Popup
local Movement = Configuration.Movement
local Hovering = Configuration.Hovering

-- Pre-built TweenInfo Animations

Request.Animation = TweenInfo.new(Request.Delay, Request.Style, Request.Direction)

Highlight.Animation = TweenInfo.new(Highlight.Delay, Highlight.Style, Highlight.Direction)

Movement.Animation = TweenInfo.new(Movement.Delay, Movement.Style, Movement.Direction)

Popup.Animation = TweenInfo.new(Popup.Delay, Popup.Style, Popup.Direction)

-- Function returning TweenInfo for hover animations (reversible with optional repeat count)
Hovering.Animation = function(Count, Reversable)
	return TweenInfo.new(
		Hovering.Delay,
		Hovering.Style,
		Hovering.Direction,

		Reversable or Default.Zero, -- Number of repeats (default zero)
		Count or Default.Off -- Whether the animation reverses (default false)
	)
end

return Configuration
