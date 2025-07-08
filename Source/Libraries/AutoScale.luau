local Collection = game:GetService("CollectionService")
local Storage = game:GetService("ReplicatedStorage")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local Knit = require(Packages.Knit)

local Component = Knit.CreateController({
	Name = "AutoScale",
})

function Component.Scale(Object)
	Object.CanvasSize = UDim2.fromOffset(
		Object:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.X,
		Object:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
	)
end

function Component:KnitStart()
	local Tags = Collection:GetTagged("AutoScale")

	for Name, Object in Tags do
		local Class = Object:FindFirstChildOfClass("UIListLayout")

		Class:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			return Component.Scale(Object)
		end)
	end

	Collection:GetInstanceAddedSignal("AutoScale"):Connect(function(Object)
		local Class = Object:FindFirstChildOfClass("UIListLayout")

		Class:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			return Component.Scale(Object)
		end)
	end)
end

return Component
