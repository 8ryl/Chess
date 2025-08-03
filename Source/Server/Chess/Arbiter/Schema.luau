--[[
    Global state container for active chess matches.

    Each entry within `Matches` represents a unique match instance.

    Provides:
      • A standardized `Trajectory` structure used as a template for piece movement
       calculations across all match sessions.
      • A `Matches` container, where each active match is stored and indexed
        by a unique identifier.

    Serves as a shared data schema across server modules responsible for board
    management, movement validation, and historical logging.
]]

return {
	Currency = "Gold",

	Trajectory = { -- Template container for directional movement vectors used in pathfinding.
		Vertical = {}, -- Vertical movement path
		Horizontal = {}, -- Horizontal movement path

		Left = {}, -- Diagonal movement to the left
		Right = {}, -- Diagonal movement to the right
	},

	Matches = {}, -- Dictionary indexed by a unique identifier, mapping to individual match states.
}
