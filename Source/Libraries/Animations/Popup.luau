local Storage = game:GetService("ReplicatedStorage")
local Animation = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Packages = Storage:WaitForChild("Packages")
local Dependencies = Storage:WaitForChild("Dependencies")

local Configuration = require(Dependencies.Configuration)
local Utilities = require(Dependencies.Utilities)
local Knit = require(Packages.Knit)

local PlayerGui = Utilities.GetDisplayAsync()

local Display = PlayerGui:WaitForChild("Display")

local Interface = Display:WaitForChild("Interface")
local Sections = Interface:WaitForChild("Sections")
local Container = Interface:WaitForChild("Container")

local Settings = Configuration.Popup
local Default = Configuration.Default

local Component = Knit.CreateController({
	Name = "Popup",
})

-- Stores whether the popup panel is currently shown or hidden (true/false).

Component.State = Default.Off

--[[
	Toggles (Displays/Hides) the panel with animations.

	@param Panel (CanvasGroup) - The UI panel to animate.
	@param Input - The user input that triggered the toggle (not used here).

	This function also animates:
	- Blur effect in Lighting
	- Shadow overlay transparency
	- Panel's group transparency

	After toggling, it flips Component.State to its opposite value.
]]

-- Class 'Panel' should always be of type 'CanvasGroup'

function Component.Switch(Panel, Switch)
	local States = {
		Blur = Utilities.ConvertBooleanAsBits(Switch, Settings.Blur),
		Shadow = Utilities.ConvertBooleanAsBits(Switch, Settings.Shadow),
		Panel = Utilities.ConvertBooleanAsBits(Switch, Settings.Panel),
	}

	local Blur = Lighting:FindFirstChildOfClass("BlurEffect")
	local Shadow = Interface:WaitForChild("Shadow")

	Animation:Create(Blur, Settings.Animation, {
		Size = States.Blur,
	}):Play()

	Animation:Create(Shadow, Settings.Animation, {
		BackgroundTransparency = States.Shadow,
	}):Play()

	Animation:Create(Panel, Settings.Animation, {
		GroupTransparency = States.Panel,
	}):Play()

	Panel.Visible = Switch
end

--[[
	Initializes the Popup controller when Knit starts.

	Connects every button inside the Container to their matching panel in the Sections folder.
	When a button is clicked, it toggles the corresponding panel with animation.
]]

function Component:KnitStart()
	for Name, Button in Container:GetChildren() do
		if not Button:IsA("GuiButton") then
			continue
		end

		if not Sections:FindFirstChild(Button.Name) then
			continue
		end

		Button.Activated:Connect(function(Input)
			for Name, Panel in Sections:GetChildren() do
				Component.Switch(Panel, Default.Off)
			end

			Component.State = not Component.State

			return Component.Switch(Sections:FindFirstChild(Button.Name), Component.State)
		end)
	end
end

return Component
