local selectionService = game:GetService("Selection")
local insertService = game:GetService("InsertService")

local toolbar = plugin:CreateToolbar("Offset to Scale")
local button = toolbar:CreateButton("Offset to Scale", "Click to convert", "rbxassetid://9621130331")

local UI = script.Parent.UI
local ve = tostring(script.Parent.Version.Value)

local function convertUI(ui)
	local currentSX = ui.Size.X.Scale
	local currentSY = ui.Size.Y.Scale
	
	local currentPX = ui.Position.X.Scale
	local currentPY = ui.Position.Y.Scale
	
	local currentOSX = ui.Size.X.Offset
	local currentOSY = ui.Size.Y.Offset
	
	local currentOPX = ui.Position.X.Offset
	local currentOPY = ui.Position.Y.Offset
	
	local screenScaleX = ui.Parent.AbsoluteSize.X
	local screenScaleY = ui.Parent.AbsoluteSize.Y
	
	ui.Size = UDim2.new(currentSX + (currentOSX / screenScaleX), 0, currentSY + (currentOSY / screenScaleY), 0)
	ui.Position = UDim2.new(currentPX + (currentOPX / screenScaleX), 0, currentPY + (currentOPY / screenScaleY), 0) 
end

local function convertChildren(ui)
	for i, child in pairs(ui:GetDescendants()) do
		if child then
			if child:IsA("GuiObject") then
				convertUI(child)
			end
		end
	end
end

     
button.Click:Connect(function()
	local selection = selectionService:Get()
	
	if selection then
		for i, ui in ipairs(selection) do
			if ui:IsA("GuiObject") then
				convertUI(ui)
			end
			
			convertChildren(ui)
		end
		
		task.spawn(function()
			UI.Parent = game:GetService("CoreGui")
			
			task.wait(2)
			
			UI.Parent = script.Parent
		end)
	end
end)

while true do
	task.wait(30)

	local testPlugin = insertService:LoadAsset(5258946006)
	local _version = testPlugin:WaitForChild("GUIRESCALER").Version.Value

	if _version == ve then
		testPlugin:Destroy()
	else
		warn("Offset to Scale " .. ve .. " is out of date. Please update to the latest version for the best experience.")
		testPlugin:Destroy()
	end
end
