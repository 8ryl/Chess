local Collection = game:GetService("CollectionService")
local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local Knit = require(Packages.Knit)

local Component = Knit.CreateController({
	Name = "AutoScale",
})

--[[ 
	Automatically updates the CanvasSize of the given object based on the
	content size of its UIListLayout child.
]]

function Component.Scale(Object)
	Object.CanvasSize = UDim2.fromOffset(
		Object:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.X,
		Object:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
	)
end

--[[ 
	Initializes the controller when Knit starts.

	Sets up listeners for all objects tagged with "AutoScale" to automatically 
	adjust their CanvasSize when their content changes.
]]

function Component:KnitStart()
	local Tags = Collection:GetTagged("AutoScale")

	-- Connect scaling to existing tagged objects
	for Name, Object in Tags do
		local Class = Object:FindFirstChildOfClass("UIListLayout")

		Class:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			return Component.Scale(Object)
		end)
	end

	-- Connect scaling for newly tagged objects in the future
	Collection:GetInstanceAddedSignal("AutoScale"):Connect(function(Object)
		local Class = Object:FindFirstChildOfClass("UIListLayout")

		Class:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			return Component.Scale(Object)
		end)
	end)
end

return Component
