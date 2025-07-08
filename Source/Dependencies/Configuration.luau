--[[
	Configuration Module

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

--[[
	Default constants for common logic and interface usage

	I use 'Zero' and 'One' for consistency—personal preference for cleaner-looking code.
]]

Configuration.Default = {
	Zero = math.round(0.25), -- Rounded value often used for transparency
	One = math.round(1.25), -- Rounded value often used for full or near-full opacity

	On = true, -- Boolean 'On' state
	Off = false, -- Boolean 'Off' state
	Null = nil, -- Represents a null/empty state
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

	Blur = { On = 15, Off = 2.5 }, -- Blur intensity for background effect
	Shadow = { On = 0.45, Off = Default.One }, -- Transparency of shadow overlay
	Panel = { On = Default.Zero, Off = Default.One }, -- Transparency of panel (zero = visible)

	Style = Enum.EasingStyle.Sine, -- Easing style for smooth animations
	Direction = Enum.EasingDirection.Out, -- Easing direction
}

-- Settings for hover animations on buttons

Configuration.Hovering = {
	Delay = Configuration.Delay.Semi, -- Duration of hover animation

	Size = 2.5 / 100, -- Scale change percentage for hover effect (5% larger)

	Style = Enum.EasingStyle.Sine, -- Easing style for hover
	Direction = Enum.EasingDirection.Out, -- Easing direction for hover
}

-- Pre-built TweenInfo for Request animations
Configuration.Request.Animation =
	TweenInfo.new(Configuration.Popup.Delay, Configuration.Popup.Style, Configuration.Popup.Direction)

-- Pre-built TweenInfo for Popup animations
Configuration.Popup.Animation =
	TweenInfo.new(Configuration.Popup.Delay, Configuration.Popup.Style, Configuration.Popup.Direction)

-- Function returning TweenInfo for hover animations (reversible with optional repeat count)
Configuration.Hovering.Animation = function(Count, Reversable)
	return TweenInfo.new(
		Configuration.Hovering.Delay,
		Configuration.Hovering.Style,
		Configuration.Hovering.Direction,

		Reversable, -- Number of repeats (default zero)
		Count -- Whether the animation reverses (default false)
	)
end

return Configuration
