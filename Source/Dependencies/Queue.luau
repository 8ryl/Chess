local Storage = game:GetService("ReplicatedStorage")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Configuration = require(Dependencies.Configuration)

local Keywords = Configuration.Keywords

local Queue = {}

--[[
	Simple FIFO (First-In, First-Out) Queue System.

	This module allows you to enqueue and dequeue items in order,
	useful for task scheduling, request handling, or similar use cases.
]]

Queue.__index = Queue

--[[
	Creates a new queue instance.
	Initializes the internal queue table and start/finish indices for efficient operations.
]]

function Queue.new()
	return setmetatable({
		Queue = {}, -- Stores items in the queue
		Start = Keywords.One, -- Index of the first item (initially set to one)
		Finish = Keywords.Zero, -- Index of the last item (starts at zero, meaning empty queue)
	}, Queue)
end

--[[
	Adds an item to the queue (enqueue).
	Optionally runs a callback function after adding.

	@param Item - The item to add to the queue.
	@param Callback - (Optional) Function to execute after enqueueing.
	@return The result of the callback function, if provided.
]]

function Queue:Enqueue(Item, Callback)
	self.Finish += Keywords.One -- Move the finish index forward
	self.Queue[self.Finish] = Item -- Store the item at the finish index

	-- Calls the callback function after enqueuing, if one was provided.

	if Callback then
		return Callback(Item, self.Queue)
	end
end

--[[
	Removes and returns the first item in the queue (dequeue).

	@param Item - (Optional, unused here) The item to remove (Keywords behavior removes the first item).
	@return The dequeued item, or a warning message if the queue is empty.
]]

function Queue:Dequeue()
	if self:IsEmpty() then
		return "Queue is empty!" -- Queue has no items
	end

	local Object = self.Queue[self.Start] -- Get the first item in the queue

	self.Queue[self.Start] = Keywords.Null -- Clear the reference for garbage collection
	self.Start += Keywords.One -- Move the start index forward

	return Object
end

--[[
	Checks whether the Queue is empty or not.
]]

function Queue:IsEmpty()
	return self.Start > self.Finish
end

--[[
	Returns the current size of the queue.

	@return The number of items in the queue.
]]

function Queue:Size()
	return self.Finish - self.Start + Keywords.One
end

return Queue
