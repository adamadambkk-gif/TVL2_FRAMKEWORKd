-- modules/interface.lua
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Interface = {}
Interface.__index = Interface

-- Premium Theme Configuration Table (Full UI Color Styling)
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 150, 255), -- Customizable Core Accent Vector
    Text = Color3.fromRGB(245, 245, 245),
    Button = Color3.fromRGB(40, 40, 40),
    FontChoice = Enum.Font.GothamBold -- Pro Font Style Selection
}

-- Constructor to spawn an independent GUI dashboard instance cleanly
function Interface.CreateWindow(titleText, backgroundAssetId)
    local self = setmetatable({}, Interface)
    
    -- Hidden injection container (Protects window frames from simple scans)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "TVL2_SuiteRenderContainer"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui
    
    -- Main UI panel background window
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 520, 0, 360)
    self.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.MainFrame
    
    -- Background Image Feature integration Hook
    if backgroundAssetId then
        local bgImage = Instance.new("ImageLabel")
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = "rbxassetid://" .. tostring(backgroundAssetId)
        bgImage.ImageTransparency = 0.85 -- Kept subtle to maintain clean readability
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.Parent = self.MainFrame
        
        local imgCorner = Instance.new("UICorner")
        imgCorner.CornerRadius = UDim.new(0, 6)
        imgCorner.Parent = bgImage
    end
    
    -- Topbar element configuration window canvas
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 38)
    topbar.BackgroundColor3 = Theme.Topbar
    topbar.BorderSizePixel = 0
    topbar.Parent = self.MainFrame
    
    local topbarCorner = Instance.new("UICorner")
    topbarCorner.CornerRadius = UDim.new(0, 6)
    topbarCorner.Parent = topbar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Theme.FontChoice
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topbar
    
    -- Internal Scrolling Container for functional feature tabs
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Size = UDim2.new(1, -24, 1, -62)
    self.Container.Position = UDim2.new(0, 12, 0, 50)
    self.Container.BackgroundTransparency = 1
    self.Container.ScrollBarThickness = 2
    self.Container.Parent = self.MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = self.Container
    
    -- Drag Functionality hook configuration
    self:EnableDragging(topbar)
    
    return self
end

-- Smooth positional dragging tracker engine logic
function Interface:EnableDragging(dragBar)
    local dragging, dragInput, dragStart, startPos
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(self.MainFrame, TweenInfo.new(0.08), {
                Position = UDim2.new(startPos.Width.Scale, startPos.Width.Offset + delta.X, startPos.Height.Scale, startPos.Height.Offset + delta.Y)
            }):Play()
        end
    end)
end

-- Method to add a responsive feature checkbox toggle control to the dashboard panel
function Interface:AddToggle(labelText, frameworkStateKey, frameworkRef)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 32)
    rowFrame.BackgroundColor3 = Theme.Button
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = self.Container
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 4)
    rowCorner.Parent = rowFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = Theme.Text
    textLabel.Font = Theme.FontChoice
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = rowFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 18)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -9)
    toggleButton.BackgroundColor3 = frameworkRef.State[frameworkStateKey] and Theme.Accent or Color3.fromRGB(65, 65, 65)
    toggleButton.Text = ""
    toggleButton.Parent = rowFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleButton
    
    -- Clicking flips the state variable inside the master runtime framework table
    toggleButton.MouseButton1Click:Connect(function()
        local currentState = not frameworkRef.State[frameworkStateKey]
        frameworkRef.State[frameworkStateKey] = currentState
        
        local targetColor = currentState and Theme.Accent or Color3.fromRGB(65, 65, 65)
        TweenService:Create(toggleButton, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)
end

-- Destroys visual elements when executing the unload command script
function Interface:DestroyUI()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return Interface
