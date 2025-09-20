-- Kour6anV2.lua
local Kour6anV2 = {}
local Components = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Dependencies
local Creator = {}
Creator.New = function(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" and property ~= "Children" then
            object[property] = value
        end
    end
    
    if properties.Parent then
        object.Parent = properties.Parent
    end
    
    if properties.Children then
        for _, child in ipairs(properties.Children) do
            child.Parent = object
        end
    end
    
    return object
end

Creator.AddSignal = function(signal, callback)
    return signal:Connect(callback)
end

Creator.SpringMotor = function(initialValue, object, property)
    local motor = {
        Value = initialValue,
        OnStep = function() end
    }
    
    function motor:setGoal(goal)
        motor.Value = goal
        if object and property then
            object[property] = goal
        end
        if motor.OnStep then
            motor.OnStep(goal)
        end
    end
    
    return motor, function(newValue)
        motor:setGoal(newValue)
    end
end

Creator.OverrideTag = function(object, properties)
    for property, value in pairs(properties) do
        if object[property] ~= nil then
            object[property] = value
        end
    end
end

-- Theme system
Kour6anV2.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Foreground = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(0, 120, 215),
        Border = Color3.fromRGB(255, 255, 255),
        ToggleSlider = Color3.fromRGB(100, 100, 100),
        ToggleToggled = Color3.fromRGB(255, 255, 255),
        DropdownFrame = Color3.fromRGB(60, 60, 60),
        DropdownHolder = Color3.fromRGB(40, 40, 40),
        DropdownBorder = Color3.fromRGB(255, 255, 255),
        DropdownOption = Color3.fromRGB(50, 50, 50),
        SliderRail = Color3.fromRGB(80, 80, 80),
        Keybind = Color3.fromRGB(60, 60, 60),
        InElementBorder = Color3.fromRGB(255, 255, 255),
        DialogInput = Color3.fromRGB(255, 255, 255),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Foreground = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 120, 215),
        Border = Color3.fromRGB(0, 0, 0),
        ToggleSlider = Color3.fromRGB(180, 180, 180),
        ToggleToggled = Color3.fromRGB(255, 255, 255),
        DropdownFrame = Color3.fromRGB(220, 220, 220),
        DropdownHolder = Color3.fromRGB(240, 240, 240),
        DropdownBorder = Color3.fromRGB(0, 0, 0),
        DropdownOption = Color3.fromRGB(230, 230, 230),
        SliderRail = Color3.fromRGB(200, 200, 200),
        Keybind = Color3.fromRGB(220, 220, 220),
        InElementBorder = Color3.fromRGB(0, 0, 0),
        DialogInput = Color3.fromRGB(0, 0, 0),
    }
}

Kour6anV2.CurrentTheme = "Dark"
Kour6anV2.UseAcrylic = false

-- Utility functions
function Kour6anV2:Round(number, decimalPlaces)
    local multiplier = 10^(decimalPlaces or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function Kour6anV2:SafeCallback(callback, ...)
    if callback then
        local success, err = pcall(callback, ...)
        if not success then
            warn("Callback error:", err)
        end
    end
end

function Kour6anV2:ApplyTheme()
    local theme = self.Themes[self.CurrentTheme]
    
    local function applyThemeRecursive(object)
        if object:IsA("GuiObject") then
            if object:FindFirstChild("ThemeTag") then
                local themeTag = object.ThemeTag
                for property, value in pairs(themeTag.Value) do
                    if theme[value] then
                        object[property] = theme[value]
                    end
                end
            end
        end
        
        for _, child in ipairs(object:GetChildren()) do
            applyThemeRecursive(child)
        end
    end
    
    if self.GUI then
        applyThemeRecursive(self.GUI)
    end
end

-- Base element component
Components.Element = function(title, description, parent, hasButton)
    local Element = {}
    
    local frame = Creator.New("Frame", {
        Name = title,
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, hasButton and 40 or 50),
        Parent = parent
    })
    
    local titleLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = title,
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = frame
    })
    
    local descLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = description,
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -24, 0, 14),
        Parent = frame
    })
    
    local border = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = frame
    })
    
    local corner = Creator.New("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = frame
    })
    
    function Element:SetTitle(text)
        titleLabel.Text = text
    end
    
    function Element:SetDesc(text)
        descLabel.Text = text
    end
    
    function Element:Destroy()
        frame:Destroy()
    end
    
    Element.Frame = frame
    Element.TitleLabel = titleLabel
    Element.DescLabel = descLabel
    
    return Element
end

-- Textbox component
Components.Textbox = function(parent, hasBackground)
    local frame = Creator.New("Frame", {
        BackgroundColor3 = hasBackground and Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = hasBackground and 0 or 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = parent
    })
    
    local input = Creator.New("TextBox", {
        ClearTextOnFocus = false,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        PlaceholderColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].SubText,
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
        TextSize = 13,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Parent = frame
    })
    
    local border = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = frame
    })
    
    local corner = Creator.New("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = frame
    })
    
    return {
        Frame = frame,
        Input = input
    }
end

-- Dialog component
Components.Dialog = {}
Components.Dialog.Create = function()
    local Dialog = {}
    
    local screenGui = Creator.New("ScreenGui", {
        DisplayOrder = 10,
        IgnoreGuiInset = true,
        Parent = game:GetService("CoreGui")
    })
    
    local background = Creator.New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = screenGui
    })
    
    local root = Creator.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 400, 0, 200),
        Parent = screenGui
    })
    
    local border = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = root
    })
    
    local corner = Creator.New("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = root
    })
    
    local title = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = "Dialog",
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
        TextSize = 16,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = root
    })
    
    local buttonContainer = Creator.New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -40),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = root
    })
    
    function Dialog:Button(text, callback)
        local button = Creator.New("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = text,
            TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
            TextSize = 14,
            BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
            AutoButtonColor = false,
            Size = UDim2.new(0.5, -10, 0, 30),
            Parent = buttonContainer
        })
        
        local border = Creator.New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
            Thickness = 1,
            Parent = button
        })
        
        local corner = Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = button
        })
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Accent}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground}):Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
            screenGui:Destroy()
        end)
        
        return button
    end
    
    function Dialog:Open()
        background.Visible = true
        root.Visible = true
    end
    
    Dialog.Root = root
    Dialog.Title = title
    
    return Dialog
end

-- Toggle component
Components.Toggle = function(Idx, Config, Container, Library)
    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle",
    }

    local ToggleFrame = Components.Element(Config.Title, Config.Description, Container, true)
    ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

    Toggle.SetTitle = ToggleFrame.SetTitle
    Toggle.SetDesc = ToggleFrame.SetDesc

    local ToggleCircle = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ImageTransparency = 0.5,
        Parent = ToggleFrame.Frame,
        ThemeTag = {
            ImageColor3 = "ToggleSlider",
        },
    })

    local ToggleBorder = Creator.New("UIStroke", {
        Transparency = 0.5,
        Parent = ToggleFrame.Frame,
        ThemeTag = {
            Color = "ToggleSlider",
        },
    })

    local ToggleSlider = Creator.New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = ToggleFrame.Frame,
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 9),
        }),
        ToggleBorder,
        ToggleCircle,
    })

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end

    function Toggle:SetValue(Value)
        Value = not not Value
        Toggle.Value = Value

        Creator.OverrideTag(ToggleBorder, { Color = Toggle.Value and "Accent" or "ToggleSlider" })
        Creator.OverrideTag(ToggleCircle, { ImageColor3 = Toggle.Value and "ToggleToggled" or "ToggleSlider" })
        TweenService:Create(
            ToggleCircle,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0) }
        ):Play()
        TweenService:Create(
            ToggleSlider,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = Toggle.Value and 0 or 1 }
        ):Play()
        ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.5

        Library:SafeCallback(Toggle.Callback, Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    function Toggle:Destroy()
        ToggleFrame:Destroy()
        Library.Options[Idx] = nil
    end

    Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle:SetValue(Toggle.Value)

    Library.Options[Idx] = Toggle
    return Toggle
end

-- Slider component
Components.Slider = function(Idx, Config, Container, Library)
    local Slider = {
        Value = nil,
        Min = Config.Min,
        Max = Config.Max,
        Rounding = Config.Rounding,
        Callback = Config.Callback or function(Value) end,
        Type = "Slider",
    }

    local SliderFrame = Components.Element(Config.Title, Config.Description, Container, false)
    SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

    Slider.SetTitle = SliderFrame.SetTitle
    Slider.SetDesc = SliderFrame.SetDesc

    local SliderDot = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -7, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ThemeTag = {
            ImageColor3 = "Accent",
        },
    })

    local SliderRail = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -14, 1, 0),
    }, {
        SliderDot,
    })

    local SliderFill = Creator.New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })

    local SliderDisplay = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = "Value",
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 14),
        Position = UDim2.new(0, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        ThemeTag = {
            TextColor3 = "SubText",
        },
    })

    local SliderInner = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 0.4,
        Parent = SliderFrame.Frame,
        ThemeTag = {
            BackgroundColor3 = "SliderRail",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        Creator.New("UISizeConstraint", {
            MaxSize = Vector2.new(150, math.huge),
        }),
        SliderDisplay,
        SliderFill,
        SliderRail,
    })

    local Dragging = false

    Creator.AddSignal(SliderDot.InputBegan, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = true
        end
    end)

    Creator.AddSignal(SliderDot.InputEnded, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = false
        end
    end)

    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if
            Dragging
            and (
                Input.UserInputType == Enum.UserInputType.MouseMovement
                or Input.UserInputType == Enum.UserInputType.Touch
            )
        then
            local SizeScale =
                math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
            Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
        end
    end)

    function Slider:OnChanged(Func)
        Slider.Changed = Func
        Func(Slider.Value)
    end

    function Slider:SetValue(Value)
        self.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
        SliderDot.Position = UDim2.new((self.Value - Slider.Min) / (Slider.Max - Slider.Min), -7, 0.5, 0)
        SliderFill.Size = UDim2.fromScale((self.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)
        SliderDisplay.Text = tostring(self.Value)

        Library:SafeCallback(Slider.Callback, self.Value)
        Library:SafeCallback(Slider.Changed, self.Value)
    end

    function Slider:Destroy()
        SliderFrame:Destroy()
        Library.Options[Idx] = nil
    end

    Slider:SetValue(Config.Default)

    Library.Options[Idx] = Slider
    return Slider
end

-- Button component
Components.Button = function(Config, Container, Library)
    assert(Config.Title, "Button - Missing Title")
    Config.Callback = Config.Callback or function() end

    local ButtonFrame = Components.Element(Config.Title, Config.Description, Container, true)

    local ButtonIco = Creator.New("ImageLabel", {
        Image = "rbxassetid://10709791437",
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = ButtonFrame.Frame,
        ThemeTag = {
            ImageColor3 = "Text",
        },
    })

    Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
        Library:SafeCallback(Config.Callback)
    end)

    return ButtonFrame
end

-- Initialize the library
function Kour6anV2:Init(options)
    options = options or {}
    
    -- Create main GUI
    local screenGui = Creator.New("ScreenGui", {
        Name = "Kour6anV2",
        DisplayOrder = options.DisplayOrder or 10,
        Parent = options.Parent or game:GetService("CoreGui")
    })
    
    local mainFrame = Creator.New("Frame", {
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Parent = screenGui
    })
    
    local border = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 2,
        Parent = mainFrame
    })
    
    local corner = Creator.New("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })
    
    local titleBar = Creator.New("Frame", {
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = mainFrame
    })
    
    local titleBorder = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = titleBar
    })
    
    local title = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = options.Title or "Kour6anV2",
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = titleBar
    })
    
    local closeButton = Creator.New("ImageButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://10709790948",
        Parent = titleBar
    })
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local tabContainer = Creator.New("Frame", {
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 120, 1, -30),
        Parent = mainFrame
    })
    
    local tabBorder = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = tabContainer
    })
    
    local contentContainer = Creator.New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 120, 0, 30),
        Size = UDim2.new(1, -120, 1, -30),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 5,
        Parent = mainFrame
    })
    
    local contentLayout = Creator.New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim2.new(0, 0, 0, 10),
        Parent = contentContainer
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Library properties
    self.GUI = screenGui
    self.MainFrame = mainFrame
    self.TitleBar = titleBar
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.Options = {}
    self.OpenFrames = {}
    
    -- Add dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return self
end

-- Tab creation
function Kour6anV2:CreateTab(name)
    local Tab = {}
    
    local button = Creator.New("TextButton", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = name,
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
        TextSize = 13,
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.TabContainer
    })
    
    local border = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = button
    })
    
    button.MouseButton1Click:Connect(function()
        -- Hide all content
        for _, child in pairs(self.ContentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        
        -- Show this tab's content
        if Tab.Content then
            Tab.Content.Visible = true
        end
    end)
    
    local content = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self.ContentContainer
    })
    
    local contentLayout = Creator.New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim2.new(0, 0, 0, 10),
        Parent = content
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    function Tab:AddSection(title)
        local Section = {}
        
        local frame = Creator.New("Frame", {
            BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 40),
            LayoutOrder = #content:GetChildren(),
            Parent = content
        })
        
        local border = Creator.New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
            Thickness = 1,
            Parent = frame
        })
        
        local corner = Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = frame
        })
        
        local titleLabel = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = title,
            TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Parent = frame
        })
        
        local container = Creator.New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 40),
            Size = UDim2.new(1, 0, 0, 0),
            Parent = frame
        })
        
        local containerLayout = Creator.New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim2.new(0, 0, 0, 10),
            Parent = container
        })
        
        containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, containerLayout.AbsoluteContentSize.Y)
            frame.Size = UDim2.new(1, -20, 0, 40 + containerLayout.AbsoluteContentSize.Y)
        end)
        
        function Section:AddButton(config)
            return Components.Button(config, container, Kour6anV2)
        end
        
        function Section:AddToggle(id, config)
            config.Container = container
            config.Library = Kour6anV2
            return Components.Toggle(id, config, container, Kour6anV2)
        end
        
        function Section:AddSlider(id, config)
            config.Container = container
            config.Library = Kour6anV2
            return Components.Slider(id, config, container, Kour6anV2)
        end
        
        function Section:AddDropdown(id, config)
            -- Placeholder for dropdown implementation
            local dropdown = {
                SetValues = function() end,
                SetValue = function() end,
                OnChanged = function() end,
                Destroy = function() end
            }
            return dropdown
        end
        
        function Section:AddColorpicker(id, config)
            -- Placeholder for colorpicker implementation
            local colorpicker = {
                SetValue = function() end,
                SetValueRGB = function() end,
                OnChanged = function() end,
                Destroy = function() end
            }
            return colorpicker
        end
        
        function Section:AddKeybind(id, config)
            -- Placeholder for keybind implementation
            local keybind = {
                SetValue = function() end,
                OnClick = function() end,
                OnChanged = function() end,
                Destroy = function() end
            }
            return keybind
        end
        
        function Section:AddInput(id, config)
            -- Placeholder for input implementation
            local input = {
                SetValue = function() end,
                OnChanged = function() end,
                Destroy = function() end
            }
            return input
        end
        
        function Section:AddParagraph(config)
            -- Placeholder for paragraph implementation
            local paragraph = {
                Destroy = function() end
            }
            return paragraph
        end
        
        Section.Frame = frame
        Section.Container = container
        
        return Section
    end
    
    Tab.Button = button
    Tab.Content = content
    
    -- Make first tab active by default
    if #self.TabContainer:GetChildren() == 1 then
        button.MouseButton1Click:Fire()
    end
    
    return Tab
end

-- Theme management
function Kour6anV2:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        self:ApplyTheme()
    end
end

function Kour6anV2:ToggleAcrylic(enabled)
    self.UseAcrylic = enabled
    -- Implement acrylic effect if needed
end

function Kour6anV2:ToggleTransparency(enabled)
    if enabled then
        self.MainFrame.BackgroundTransparency = 0.5
        self.TabContainer.BackgroundTransparency = 0.5
        for _, child in ipairs(self.ContentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundTransparency = 0.5
            end
        end
    else
        self.MainFrame.BackgroundTransparency = 0
        self.TabContainer.BackgroundTransparency = 0
        for _, child in ipairs(self.ContentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundTransparency = 0
            end
        end
    end
end

function Kour6anV2:Notify(options)
    -- Create a notification
    local notification = Creator.New("Frame", {
        Name = "Notification",
        BackgroundColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Foreground,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -300, 1, -80),
        Size = UDim2.new(0, 280, 0, 60),
        Parent = self.GUI
    })
    
    local border = Creator.New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Border,
        Thickness = 1,
        Parent = notification
    })
    
    local corner = Creator.New("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    local title = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = options.Title or "Notification",
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].Text,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 16),
        Parent = notification
    })
    
    local content = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = options.Content or "",
        TextColor3 = Kour6anV2.Themes[Kour6anV2.CurrentTheme].SubText,
        TextSize = 12,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 28),
        Size = UDim2.new(1, -20, 0, 24),
        Parent = notification
    })
    
    -- Animate in
    notification.Position = UDim2.new(1, -300, 1, 80)
    TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(1, -300, 1, -80)}):Play()
    
    -- Remove after duration
    task.delay(options.Duration or 5, function()
        if notification and notification.Parent then
            TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(1, -300, 1, 80)}):Play()
            task.wait(0.3)
            notification:Destroy()
        end
    end)
end

-- Include component implementations
Kour6anV2.Components = Components

return Kour6anV2