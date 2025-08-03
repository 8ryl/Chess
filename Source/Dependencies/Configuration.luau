local Configuration = {}

--[[
	Defines every constant such as:, delays, animation properties, and interface behavior parameters.

	This file centralizes every tweakable value to maintain consistency across the game.
	Direct edits alter the timing, styling, and visual responses of interface elements.
]]

-- Time intervals (in seconds) for internal processes and visual transitions

Configuration.Delay = {
	Tick = 0.065, -- Minimum frame-level delay for rapid updates
	Fast = 0.125, -- Optimized delay for fast visual transitions
	Semi = 0.175, -- Balanced delay for moderate transitions
	Medium = 0.375, -- Standard delay for noticeable animations
	Long = 0.875, -- Extended delay for slow visual emphasis
}

-- Preset cooldown durations (in seconds) for gameplay systems and user actions

Configuration.Cooldown = {
	Small = 2.5, -- Short duration for minor system resets
	Medium = 5, -- Standard duration for general actions
	Long = 10, -- Extended duration for critical systems
}

-- Base constants representing numerical and logical defaults

Configuration.Keywords = {
	Zero = math.round(0.25), -- Rounded baseline transparency or scale factor
	One = math.round(1.25), -- Rounded maximum opacity or size factor

	On = true, -- Logical true state
	Off = false, -- Logical false state
	Null = nil, -- Null state reference
}

local Keywords = Configuration.Keywords
local Delay = Configuration.Delay

-- Configuration block for challenge request prompts and associated animations

Configuration.Request = {
	Delay = Delay.Medium, -- Duration of challenge prompt transition

	Style = Enum.EasingStyle.Quad, -- Easing style for request animation
	Direction = Enum.EasingDirection.Out, -- Easing direction for request animation
}

-- Parameters for popup panels including visual depth, shadows, and opacity adjustments

Configuration.Popup = {
	Delay = Delay.Semi, -- Duration of popup entry and exit

	Style = Enum.EasingStyle.Sine, -- Easing style for smooth popup motion
	Direction = Enum.EasingDirection.Out, -- Easing direction for popup motion

	Blur = { On = 15, Off = 2.5 }, -- Screen blur levels during popup states
	Shadow = { On = 0.45, Off = Keywords.One }, -- Shadow intensity levels during transitions
	Panel = { On = Keywords.Zero, Off = Keywords.One }, -- Panel opacity control values
}

-- Parameters for piece selection highlights

Configuration.Highlight = {
	Delay = Delay.Fast, -- Duration of highlight effect

	Style = Enum.EasingStyle.Sine, -- Easing style for highlight transition
	Direction = Enum.EasingDirection.Out, -- Easing direction for highlight transition
}

-- Parameters for chess piece movement animations

Configuration.Movement = {
	Delay = Delay.Fast, -- Duration of piece translation

	Style = Enum.EasingStyle.Sine, -- Easing style for movement
	Direction = Enum.EasingDirection.Out, -- Easing direction for movement
}

-- Parameters for hover-based scale effects

Configuration.Hovering = {
	Size = 0.035, -- Scale increment as a decimal (3.5%)

	Delay = Delay.Fast, -- Duration of hover scaling

	Style = Enum.EasingStyle.Sine, -- Easing style for hover scaling
	Direction = Enum.EasingDirection.Out, -- Easing direction for hover scaling
}

Configuration.Loading = {
	Size = 0.075,

	Delay = Delay.Long, -- Duration of hover scaling

	Style = Enum.EasingStyle.Quint, -- Easing style for hover scaling
	Direction = Enum.EasingDirection.Out, -- Easing direction for hover scaling
}

-- Predefined TweenInfo instances for animations used in multiple components

Configuration.Request.Animation =
	TweenInfo.new(Configuration.Request.Delay, Configuration.Request.Style, Configuration.Request.Direction)

Configuration.Loading.Animation = function(Count, Reverses)
	return TweenInfo.new(
		Configuration.Hovering.Delay,
		Configuration.Hovering.Style,
		Configuration.Hovering.Direction,
		Count or Keywords.Zero,
		Reverses or Keywords.Off
	)
end

Configuration.Highlight.Animation =
	TweenInfo.new(Configuration.Highlight.Delay, Configuration.Highlight.Style, Configuration.Highlight.Direction)

Configuration.Movement.Animation =
	TweenInfo.new(Configuration.Movement.Delay, Configuration.Movement.Style, Configuration.Movement.Direction)

Configuration.Popup.Animation =
	TweenInfo.new(Configuration.Popup.Delay, Configuration.Popup.Style, Configuration.Popup.Direction)

-- Dynamic TweenInfo generator for hover animations with adjustable repeat and reverse properties

Configuration.Hovering.Animation = function(Count, Reverses)
	return TweenInfo.new(
		Configuration.Hovering.Delay,
		Configuration.Hovering.Style,
		Configuration.Hovering.Direction,
		Reverses or Keywords.Zero,
		Count or Keywords.Off
	)
end

return Configuration
