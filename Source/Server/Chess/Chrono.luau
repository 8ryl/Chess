--[[
    Module: Chrono
    Purpose:
        Handles the time management system for chess matches. 
        Maintains individual timers for both players, tracks elapsed and remaining time, 
        and enforces time controls based on the selected game mode.

    Responsibilities:
        - Initializes timers when a match begins.
        - Decrements the active player's timer during their turn.
        - Pauses and resumes time based on move events.
        - Signals time expiration events to trigger game-over conditions.

    Usage:
        Required by the main game logic to manage per-player clocks and synchronize 
        time-based state changes across server and client.
]]

--TODO: Implement chronometer logic. Plan it out before working on it
