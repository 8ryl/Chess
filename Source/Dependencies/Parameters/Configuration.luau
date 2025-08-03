local Configuration = {
	Delay = {
		Tick = 0.065, -- Minimum frame-level delay for rapid updates
		Fast = 0.125, -- Optimized delay for fast visual transitions
		Semi = 0.175, -- Balanced delay for moderate transitions

		Medium = 0.375, -- Standard delay for noticeable animations
		Long = 0.875, -- Extended delay for slow visual emphasis
	},

	Cooldown = {
		Small = 2.5, -- Short duration for minor system resets
		Medium = 5, -- Standard duration for general actions
		Long = 10, -- Extended duration for critical systems
	},

	Settings = {
		Size = 0.035, -- Scale increment as a decimal (3.5%)

		Opacity = { 0, 1 }, -- Panel opacity control values
		BlurEffect = { 15, 2.5 }, -- Screen blur levels during popup states
		ShadowTransparency = { 0.45, 1 }, -- Shadow intensity levels during transitions
	},
}

local Style = Enum.EasingStyle -- Easing styles
local Direction = Enum.EasingDirection -- Easing directions

local Delay = Configuration.Delay -- Delay values
local Cooldown = Configuration.Cooldown -- Cooldown values

local Settings = Configuration.Settings -- Animation settings

-- Defines parameters for various interface and gameplay elements.

Configuration.Request = TweenInfo.new(Delay.Medium, Style.Quad, Direction.Out)

-- Defines parameters for the loading screen animations.

Configuration.Loading = function(Reverses)
	return TweenInfo.new(Delay.Fast, Style.Sine, Direction.InOut, 1, Reverses)
end

-- Defines parameters for the button-on-hover animations.

Configuration.Hover = function(Repetition, Reverses)
	return TweenInfo.new(Delay.Fast, Style.Sine, Direction.InOut, Repetition, Reverses)
end

-- Defines parameters for the square highlighting animations.

Configuration.Highlight = TweenInfo.new(Delay.Fast, Style.Sine, Direction.Out)

-- Defines animation parameters for the chessboard piece movement.

Configuration.Movement = TweenInfo.new(Delay.Fast, Style.Sine, Direction.Out)

-- Sets parameters for the match request popup animations.

Configuration.Popup = TweenInfo.new(Delay.Semi, Style.Sine, Direction.Out)

return Configuration
