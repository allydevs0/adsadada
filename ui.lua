-- UI Library reconstruída
-- Gerado automaticamente

local UILibrary = {}

-- Cria uma nova janela
function UILibrary:CreateWindow(title)
    local window = {
        title = title or 'Window',
        tabs = {},
        position = UDim2.new(0.5, -250, 0.5, -150),
        size = UDim2.new(0, 500, 0, 300),
        visible = true,
        dragging = false,
        dragStart = nil
    }
    
    -- Criar GUI
    local screenGui = Instance.new('ScreenGui')
    screenGui.Name = 'UILibrary_' .. tostring(math.random(1000, 9999))
    screenGui.Parent = game:GetService('CoreGui')
    
    -- Frame principal
    local mainFrame = Instance.new('Frame')
    mainFrame.Name = 'MainFrame'
    mainFrame.Size = window.size
    mainFrame.Position = window.position
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Barra de título
    local titleBar = Instance.new('Frame')
    titleBar.Name = 'TitleBar'
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new('TextLabel')
    titleLabel.Name = 'TitleLabel'
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = window.title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 14
    titleLabel.Parent = titleBar
    
    -- Botão fechar
    local closeButton = Instance.new('TextButton')
    closeButton.Name = 'CloseButton'
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = 'X'
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Container de abas
    local tabContainer = Instance.new('Frame')
    tabContainer.Name = 'TabContainer'
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Área de conteúdo
    local contentArea = Instance.new('Frame')
    contentArea.Name = 'ContentArea'
    contentArea.Size = UDim2.new(1, -10, 1, -75)
    contentArea.Position = UDim2.new(0, 5, 0, 65)
    contentArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame
    
    window.Gui = screenGui
    window.MainFrame = mainFrame
    window.ContentArea = contentArea
    window.TabContainer = tabContainer
    window.CurrentTab = nil
    
    -- Método para adicionar aba
    function window:AddTab(name)
        local tab = {
            name = name,
            elements = {},
            button = nil,
            frame = nil
        }
        
        -- Criar frame da aba
        local tabFrame = Instance.new('Frame')
        tabFrame.Name = 'Tab_' .. name
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = self.ContentArea
        
        -- Criar botão da aba
        local tabButton = Instance.new('TextButton')
        tabButton.Name = 'TabButton_' .. name
        tabButton.Size = UDim2.new(0, 80, 0, 25)
        tabButton.Position = UDim2.new(0, (#self.tabs * 85), 0, 2.5)
        tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 13
        tabButton.Parent = self.TabContainer
        
        tabButton.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.frame.Visible = false
                self.CurrentTab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                self.CurrentTab.button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            tabFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            self.CurrentTab = tab
        end)
        
        tab.frame = tabFrame
        tab.button = tabButton
        table.insert(self.tabs, tab)
        
        -- Se for a primeira aba, mostrar
        if #self.tabs == 1 then
            tabFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            self.CurrentTab = tab
        end
        
        -- Métodos da aba
        function tab:AddToggle(text, callback)
            local y = (#self.elements * 35) + 5
            
            local toggleFrame = Instance.new('Frame')
            toggleFrame.Name = 'Toggle_' .. text
            toggleFrame.Size = UDim2.new(1, -10, 0, 30)
            toggleFrame.Position = UDim2.new(0, 5, 0, y)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = self.frame
            
            local label = Instance.new('TextLabel')
            label.Name = 'Label'
            label.Size = UDim2.new(0, 150, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = toggleFrame
            
            local toggleButton = Instance.new('TextButton')
            toggleButton.Name = 'ToggleButton'
            toggleButton.Size = UDim2.new(0, 50, 0, 20)
            toggleButton.Position = UDim2.new(1, -55, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            toggleButton.Text = 'OFF'
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleButton.Font = Enum.Font.Gotham
            toggleButton.TextSize = 12
            toggleButton.Parent = toggleFrame
            
            local state = false
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                    toggleButton.Text = 'ON'
                else
                    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    toggleButton.Text = 'OFF'
                end
                
                if callback then
                    callback(state)
                end
            end)
            
            local element = {
                type = 'toggle',
                frame = toggleFrame,
                button = toggleButton,
                label = label,
                set = function(value)
                    state = value
                    if state then
                        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                        toggleButton.Text = 'ON'
                    else
                        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                        toggleButton.Text = 'OFF'
                    end
                    if callback then callback(state) end
                end,
                get = function() return state end
            }
            
            table.insert(self.elements, element)
            return element
        end
        
        function tab:AddSlider(text, min, max, callback)
            local y = (#self.elements * 35) + 5
            
            local sliderFrame = Instance.new('Frame')
            sliderFrame.Name = 'Slider_' .. text
            sliderFrame.Size = UDim2.new(1, -10, 0, 40)
            sliderFrame.Position = UDim2.new(0, 5, 0, y)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = self.frame
            
            local label = Instance.new('TextLabel')
            label.Name = 'Label'
            label.Size = UDim2.new(0, 150, 0, 20)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = sliderFrame
            
            local valueLabel = Instance.new('TextLabel')
            valueLabel.Name = 'ValueLabel'
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -55, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(min)
            valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextSize = 12
            valueLabel.Parent = sliderFrame
            
            local slider = Instance.new('Frame')
            slider.Name = 'Slider'
            slider.Size = UDim2.new(1, -20, 0, 5)
            slider.Position = UDim2.new(0, 10, 0, 25)
            slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            slider.BorderSizePixel = 0
            slider.Parent = sliderFrame
            
            local fill = Instance.new('Frame')
            fill.Name = 'Fill'
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            fill.BorderSizePixel = 0
            fill.Parent = slider
            
            local button = Instance.new('TextButton')
            button.Name = 'DragButton'
            button.Size = UDim2.new(0, 10, 0, 10)
            button.Position = UDim2.new(0, -5, 0.5, -5)
            button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            button.BorderSizePixel = 0
            button.Text = ''
            button.Parent = fill
            
            local value = min
            local dragging = false
            
            button.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            game:GetService('UserInputService').InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService('RunService').RenderStepped:Connect(function()
                if dragging then
                    local mousePos = game:GetService('UserInputService'):GetMouseLocation()
                    local absPos = slider.AbsolutePosition
                    local size = slider.AbsoluteSize.X
                    local relative = math.clamp((mousePos.X - absPos.X) / size, 0, 1)
                    value = min + (max - min) * relative
                    fill.Size = UDim2.new(relative, 0, 1, 0)
                    valueLabel.Text = tostring(math.floor(value * 100) / 100)
                    if callback then callback(value) end
                end
            end)
            
            local element = {
                type = 'slider',
                frame = sliderFrame,
                label = label,
                valueLabel = valueLabel,
                slider = slider,
                fill = fill,
                button = button,
                set = function(v)
                    value = math.clamp(v, min, max)
                    local relative = (value - min) / (max - min)
                    fill.Size = UDim2.new(relative, 0, 1, 0)
                    valueLabel.Text = tostring(math.floor(value * 100) / 100)
                    if callback then callback(value) end
                end,
                get = function() return value end
            }
            
            table.insert(self.elements, element)
            return element
        end
        
        function tab:AddButton(text, callback)
            local y = (#self.elements * 35) + 5
            
            local button = Instance.new('TextButton')
            button.Name = 'Button_' .. text
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Position = UDim2.new(0, 5, 0, y)
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            button.Text = text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            button.Parent = self.frame
            
            button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            local element = {
                type = 'button',
                button = button,
                set = function(text) button.Text = text end
            }
            
            table.insert(self.elements, element)
            return element
        end
        
        function tab:AddLabel(text)
            local y = (#self.elements * 35) + 5
            
            local label = Instance.new('TextLabel')
            label.Name = 'Label_' .. text
            label.Size = UDim2.new(1, -10, 0, 20)
            label.Position = UDim2.new(0, 5, 0, y)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = self.frame
            
            local element = {
                type = 'label',
                label = label,
                set = function(text) label.Text = text end
            }
            
            table.insert(self.elements, element)
            return element
        end
        
        return tab
    end
    
    return window
end

return UILibrary