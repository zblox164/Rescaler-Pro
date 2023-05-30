--!nonstrict

--[[
	Written by zblox164
	Last updated 2023-05-30
]]--

--Services---------------------------
local Selection: Selection = game:GetService("Selection")
local InsertService: InsertService = game:GetService("InsertService")
local RunService: RunService = game:GetService("RunService")

--Plugin variables---------------------------
local Toolbar: PluginToolbar = plugin:CreateToolbar("Rescaler Pro")
local OpenButton = Toolbar:CreateButton("Rescaler Pro", "Click To Open", "rbxassetid://13593939261")
local ToScaleAction: PluginAction = plugin:CreatePluginAction(
	"toScale",
	"To Scale",
	"Converts the current selection UI to scale"
)

local ToOffsetAction: PluginAction = plugin:CreatePluginAction(
	"toOffset",
	"To Offset",
	"Converts the current selection UI to offset"
)

--Variables---------------------------
local MainUI = script.Parent.UI.MainUI
local LogUI: ScreenGui = script.Parent.UI.Log
local WhatsNew = script.Parent.UI.WhatsNew
local CurrentVersion: string = tostring(script.Parent.Version.Value)

--Functions---------------------------

--Sets the cursors icon---------------------------
local function SetCursor(cursorAsset)
	plugin:GetMouse().Icon = cursorAsset
end

--Give user feedback that an action has completed---------------------------
local function UserFeedback()	
	LogUI.Parent = game:GetService("CoreGui")

	task.delay(2, function()
		LogUI.Parent = script.Parent
	end)
end

--Calculates the offset of a UI element---------------------------
local function CalculateOffset(ui: GuiObject)
	local uiSize = ui.AbsoluteSize
	local Size = UDim2.new(0, uiSize.X, 0, uiSize.Y)
	
	ui.Size = Size
end

--Calculates the scale of a UI element---------------------------
local function CalculateScale(ui)
	local currentScaleX: number = ui.Size.X.Scale
	local currentOffsetScaleX: number = ui.Size.X.Offset
	
	local currentScaleY: number = ui.Size.Y.Scale
	local currentOffsetScaleY: number = ui.Size.Y.Offset
	
	local screenScaleX: number = ui.Parent.AbsoluteSize.X
	local screenScaleY: number = ui.Parent.AbsoluteSize.Y
	
	local Size: UDim2 = UDim2.new(currentScaleX + (currentOffsetScaleX/screenScaleX), 0, currentScaleY + (currentOffsetScaleY/screenScaleY), 0) 
	
	ui.Size = Size
end

--Converts all UI children to offset or scale---------------------------
local function ConvertChildren(ui: Instance, Type: string)
	for _, child: Instance in ipairs(ui:GetDescendants()) do
		if not child then continue end
		if not child:IsA("GuiObject") then continue end
		
		if Type == "Scale" then CalculateScale(child:: GuiObject); continue end
		
		CalculateOffset(child:: GuiObject)
	end
end

--Converts UI elements to offset---------------------------
local function ToOffset()
	local selection: {Instance} = Selection:Get()
	if not selection then return false end
	
	SetCursor("rbxasset://SystemCursors/Wait")
	
	for _, ui: Instance in ipairs(selection) do
		if not ui:IsA("GuiObject") then continue end

		CalculateOffset(ui:: GuiObject)
		ConvertChildren(ui, "Offset")
	end
	
	SetCursor("")

	return true
end

--Converts UI elements to scale---------------------------
local function ToScale()
	local selection: {Instance} = Selection:Get()
	if not selection then return false end
	
	SetCursor("rbxasset://SystemCursors/Wait")
	
	for _, ui: Instance in ipairs(selection) do
		if not ui:IsA("GuiObject") then continue end

		CalculateScale(ui:: GuiObject)
		ConvertChildren(ui, "Scale")
	end
	
	SetCursor("")
	
	return true
end

--Main function for starting actions---------------------------
local function Main(Type: string)
	if Type == "Scale" then
		if ToScale() then UserFeedback() end
		
		return
	end
	
	if ToOffset() then UserFeedback() end
end

--Dock Widget---------------------------
local widgetInfo: DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false,
	false,
	400,
	600,
	200,
	400
)

local widget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("Rescale Pro", widgetInfo)
widget.Title = "Rescale Pro " .. CurrentVersion
MainUI.Parent = widget

widget:BindToClose(function()
	OpenButton:SetActive(false)
end)

--Signals---------------------------
OpenButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	OpenButton:SetActive(widget.Enabled)
end)

--Actions---------------------------
ToScaleAction.Triggered:Connect(function()
	Main("Scale")
end)

ToOffsetAction.Triggered:Connect(function()
	Main("Offset")
end)

--Inputs---------------------------
MainUI.ButtonHolder.Offset.MouseButton1Click:Connect(function()
	Main("Offset")
end)

MainUI.ButtonHolder.Scale.MouseButton1Click:Connect(function()
	Main("Scale")
end)

--Hovering---------------------------
MainUI.ButtonHolder.Offset.MouseEnter:Connect(function()
	MainUI.ButtonHolder.OffsetDesc.Visible = true
end)

MainUI.ButtonHolder.Scale.MouseEnter:Connect(function()
	MainUI.ButtonHolder.ScaleDesc.Visible = true
end)

MainUI.ButtonHolder.Offset.MouseLeave:Connect(function()
	MainUI.ButtonHolder.OffsetDesc.Visible = false
end)

MainUI.ButtonHolder.Scale.MouseLeave:Connect(function()
	MainUI.ButtonHolder.ScaleDesc.Visible = false
end)

--Initialize---------------------------
local lastSeen = plugin:GetSetting("Version")

if not lastSeen or lastSeen ~= CurrentVersion then
	WhatsNew.Parent = game.CoreGui
	WhatsNew.Main.Close.MouseButton1Click:Connect(function()
		WhatsNew.Parent = script.Parent.UI
	end)
	
	print("Thank you for installing Rescale Pro 1.4.0!")
	plugin:SetSetting("Version", CurrentVersion)
end

--Loops---------------------------

--Auto update---------------------------
while true do
	task.wait(30)
	
	if not RunService:IsEdit() then continue end
	
	local testPlugin = InsertService:LoadAsset(5258946006)
	local newVersion: string = testPlugin.RescalerPro.Version.Value

	if newVersion == CurrentVersion then
		testPlugin:Destroy()
	else
		warn("Rescaler Pro " .. CurrentVersion .. " is out of date. Please update to the latest version for the best experience.")
		testPlugin:Destroy()
	end
end
