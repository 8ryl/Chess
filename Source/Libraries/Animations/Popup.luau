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

local Preferences = Configuration.Popup

local Settings = Configuration.Settings

local Component = Knit.CreateController({
	Name = "Popup",
})

-- Represents the current popup visibility state as a Boolean flag.

Component.State = false

-- Resets every panel in Sections to a defined visibility state.

function Component:Reset(Switch)
	for Name, Panel in Sections:GetChildren() do
		if not Panel:IsA("CanvasGroup") then
			continue
		end

		-- Delegates the visibility and animation control of each panel to Component.Switch.

		Component.Switch(Panel, Switch or false)
	end
end

-- Animates a specified panel and related visual effects based on a Boolean state.

function Component.Switch(Panel, Switch)
	local States = {
		Blur = Utilities.ConvertBooleanAsBits(Switch, Settings.BlurEffect),
		Shadow = Utilities.ConvertBooleanAsBits(Switch, Settings.ShadowTransparency),
		Opacity = Utilities.ConvertBooleanAsBits(Switch, Settings.Opacity),
	}

	local Blur = Lighting:FindFirstChildOfClass("BlurEffect")
	local Shadow = Interface:WaitForChild("Shadow")

	-- Tweens the blur effect size to the target value.

	Utilities.Animate(Blur, Preferences, {
		Size = States.Blur,
	}):Play()

	-- Tweens the shadow overlay transparency to the target value.

	Utilities.Animate(Shadow, Preferences, {
		BackgroundTransparency = States.Shadow,
	}):Play()

	-- Tweens the panel transparency to the target value.

	Utilities.Animate(Panel, Preferences, {
		GroupTransparency = States.Opacity,
	}):Play()

	-- Applies the final visibility state to the panel.

	Panel.Visible = Switch
end

-- Initializes the Popup controller and binds buttons to their respective panels.

function Component:KnitStart()
	for Name, Button in Container:GetChildren() do
		if not Button:IsA("GuiButton") then
			continue
		end

		if not Sections:FindFirstChild(Button.Name) then
			continue
		end

		Button.Activated:Connect(function(Input)
			-- Resets all panels to the Keywords hidden state.

			for Name, Panel in Sections:GetChildren() do
				Component.Switch(Panel, false)
			end

			-- Inverts the current popup state and applies to the selected panel.

			Component.State = not Component.State

			-- Animates and displays the matching panel.

			return Component.Switch(Sections:FindFirstChild(Button.Name), Component.State)
		end)
	end
end

return Component
