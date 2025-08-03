local Storage = game:GetService("ReplicatedStorage")

local Dependencies = Storage.Dependencies
local Packages = Storage.Packages

local Parameters = Dependencies.Parameters

local Configuration = require(Parameters.Configuration)

local Queue = {}

-- Simple FIFO (First-In, First-Out) Queue System.

Queue.__index = Queue

-- Creates a new queue instance.

function Queue.new()
	return setmetatable({
		Queue = {}, -- Stores items in the queue
		Start = 1, -- Index of the first item (initially set to one)
		Finish = 0, -- Index of the last item (starts at zero, meaning empty queue)
	}, Queue)
end

-- Adds an item to the queue (enqueue). Optionally runs a callback function after adding.

function Queue:Enqueue(Item, Callback)
	self.Finish += 1 -- Move the finish index forward
	self.Queue[self.Finish] = Item -- Store the item at the finish index

	-- Calls the callback function after enqueuing, if one was provided.

	if Callback then
		return Callback(Item, self.Queue)
	end
end

-- Removes and returns the first item in the queue (dequeue).

function Queue:Dequeue()
	if self:IsEmpty() then
		return print("Queue is empty!") -- Queue has no items
	end

	local Object = self.Queue[self.Start] -- Get the first item in the queue

	self.Queue[self.Start] = nil -- Clear the reference for garbage collection
	self.Start += 1 -- Move the start index forward

	return Object
end

-- Checks whether the queue is empty or not.

function Queue:IsEmpty()
	return self.Start > self.Finish
end

-- Returns the current size of the queue.

function Queue:Size()
	return self.Finish - self.Start + 1
end

return Queue
