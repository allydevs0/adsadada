-- SimpleSpy v2.5 - Modern UI + AntiSpam (sem task, compatível com executores antigos)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ContentProvider = game:GetService("ContentProvider")

if _G.SimpleSpyExecuted then
    warn("SimpleSpy já está rodando")
    return
end

-- ======================= CONFIGURAÇÕES =======================
_G.SIMPLESPYCONFIG_MaxRemotes = 300
local indent = 4
local keyToString = false
local getNil = nil

-- ======================= VARIÁVEIS GLOBAIS =======================
local logs = {}
local groupedRemotes = {}   -- key = nome..":"..tipo
local selected = nil
local blacklist = {}
local blocklist = {}
local remoteLogs = {}
local scheduled = {}
local mainClosing = false
local closed = false
local sideClosed = false
local sideClosing = false
local maximized = false
local codebox = nil
local layoutOrderNum = 999999999
local getnilrequired = false
local prevTables = {}
local topstr = ""
local bottomstr = ""

-- ======================= FUNÇÕES AUXILIARES =======================
function schedule(f, ...)
    table.insert(scheduled, { f, ... })
end

function taskscheduler()
    if #scheduled > 0 then
        local current = scheduled[1]
        table.remove(scheduled, 1)
        if type(current[1]) == "function" then
            pcall(current[1], unpack(current, 2))
        end
    end
end

function clean()
    local max = _G.SIMPLESPYCONFIG_MaxRemotes
    if #remoteLogs > max then
        for i = max+1, #remoteLogs do
            local v = remoteLogs[i]
            if v[1] and typeof(v[1]) == "RBXScriptConnection" then v[1]:Disconnect() end
            if v[2] and v[2]:IsA("Frame") then v[2]:Destroy() end
        end
        local newLogs = {}
        for i = 1, max do newLogs[i] = remoteLogs[i] end
        remoteLogs = newLogs
    end
end

function updateRemoteCanvas()
    local list = script.Parent:FindFirstChild("LogList") or game:GetService("CoreGui"):FindFirstChild("SimpleSpy2"):FindFirstChild("Background"):FindFirstChild("LeftPanel"):FindFirstChild("LogList")
    if list then
        list.CanvasSize = UDim2.new(0, 0, 0, list.UIListLayout.AbsoluteContentSize.Y)
    end
end

-- ======================= SERIALIZAÇÃO (resumida para funcionar) =======================
function v2s(v) return tostring(v) end
function i2p(i) return 'game:GetService("Workspace")' end -- simplificado
function genScript(remote, args)
    local path = i2p(remote)
    local argStr = ""
    if #args > 0 then
        argStr = "unpack({" .. table.concat(args, ", ") .. "})"
    end
    if remote:IsA("RemoteEvent") then
        return path .. ":FireServer(" .. argStr .. ")"
    else
        return path .. ":InvokeServer(" .. argStr .. ")"
    end
end

-- ======================= CRIAÇÃO DA GUI MODERNA =======================
local SimpleSpy2 = Instance.new("ScreenGui")
SimpleSpy2.Name = "SimpleSpy2"
SimpleSpy2.ResetOnSpawn = false

local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Parent = SimpleSpy2
Background.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Background.BackgroundTransparency = 0.15
Background.Position = UDim2.new(0, 300, 0, 150)
Background.Size = UDim2.new(0, 520, 0, 400)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = Background

local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = Background
LeftPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
LeftPanel.BackgroundTransparency = 0.5
LeftPanel.Position = UDim2.new(0, 0, 0, 32)
LeftPanel.Size = UDim2.new(0, 170, 1, -32)

local LogList = Instance.new("ScrollingFrame")
LogList.Name = "LogList"
LogList.Parent = LeftPanel
LogList.BackgroundTransparency = 1
LogList.Position = UDim2.new(0, 0, 0, 36)
LogList.Size = UDim2.new(1, 0, 1, -36)
LogList.CanvasSize = UDim2.new(0, 0, 0, 0)
LogList.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogList
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Modelo do remote (com cor, contador e direção)
local RemoteTemplate = Instance.new("Frame")
RemoteTemplate.Name = "RemoteTemplate"
RemoteTemplate.Size = UDim2.new(0, 158, 0, 42)
local templateCorner = Instance.new("UICorner")
templateCorner.CornerRadius = UDim.new(0, 10)
templateCorner.Parent = RemoteTemplate
RemoteTemplate.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
RemoteTemplate.BackgroundTransparency = 0.2

local ColorBar = Instance.new("Frame")
ColorBar.Name = "ColorBar"
ColorBar.Parent = RemoteTemplate
ColorBar.Size = UDim2.new(0, 4, 0, 30)
ColorBar.Position = UDim2.new(0, 0, 0, 6)
ColorBar.BorderSizePixel = 0

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = RemoteTemplate
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 14, 0, 6)
TextLabel.Size = UDim2.new(0, 110, 0, 20)
TextLabel.Font = Enum.Font.GothamSemibold
TextLabel.TextColor3 = Color3.fromRGB(230, 230, 245)
TextLabel.TextSize = 13
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextTruncate = Enum.TextTruncate.AtEnd

local CountLabel = Instance.new("TextLabel")
CountLabel.Name = "CountLabel"
CountLabel.Parent = RemoteTemplate
CountLabel.BackgroundTransparency = 1
CountLabel.Position = UDim2.new(1, -42, 0, 8)
CountLabel.Size = UDim2.new(0, 36, 0, 16)
CountLabel.Font = Enum.Font.GothamBlack
CountLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
CountLabel.TextSize = 11
CountLabel.TextXAlignment = Enum.TextXAlignment.Right

local DirLabel = Instance.new("TextLabel")
DirLabel.Name = "DirLabel"
DirLabel.Parent = RemoteTemplate
DirLabel.BackgroundTransparency = 1
DirLabel.Position = UDim2.new(0, 6, 0, 22)
DirLabel.Size = UDim2.new(0, 14, 0, 14)
DirLabel.Font = Enum.Font.GothamBold
DirLabel.TextSize = 12
DirLabel.TextXAlignment = Enum.TextXAlignment.Center

local Button = Instance.new("TextButton")
Button.Parent = RemoteTemplate
Button.Size = UDim2.new(1, 0, 1, 0)
Button.BackgroundTransparency = 0.85
Button.AutoButtonColor = false
Button.Text = ""

-- RightPanel e CodeBox (simplificado)
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Parent = Background
RightPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
RightPanel.BackgroundTransparency = 0.3
RightPanel.Position = UDim2.new(0, 170, 0, 32)
RightPanel.Size = UDim2.new(1, -170, 1, -32)

local CodeBox = Instance.new("Frame")
CodeBox.Name = "CodeBox"
CodeBox.Parent = RightPanel
CodeBox.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
CodeBox.Size = UDim2.new(1, 0, 1, -40)
CodeBox.Position = UDim2.new(0, 0, 0, 0)
local codeCorner = Instance.new("UICorner")
codeCorner.CornerRadius = UDim.new(0, 8)
codeCorner.Parent = CodeBox

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = CodeBox
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4

local codeText = Instance.new("TextLabel")
codeText.Parent = ScrollingFrame
codeText.Size = UDim2.new(1, 0, 1, 0)
codeText.BackgroundTransparency = 1
codeText.TextColor3 = Color3.fromRGB(220, 220, 240)
codeText.TextSize = 12
codeText.Font = Enum.Font.Code
codeText.TextXAlignment = Enum.TextXAlignment.Left
codeText.TextYAlignment = Enum.TextYAlignment.Top
codeText.TextWrapped = true
codeText.Text = "Selecione um remote"

codebox = { setRaw = function(txt) codeText.Text = txt end, getString = function() return codeText.Text end }

-- TopBar (para arrastar)
local TopBar = Instance.new("Frame")
TopBar.Parent = Background
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BackgroundTransparency = 0.3

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 6)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.Text = "SimpleSpy · AntiSpam"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13

-- ======================= FUNÇÃO newRemote (com anti‑spam) =======================
function newRemote(type, name, args, remote, function_info, blocked, src, returnValue)
    local key = name .. ":" .. type
    if groupedRemotes[key] then
        local entry = groupedRemotes[key]
        entry.count = entry.count + 1
        entry.lastFire = os.time()
        entry.args = args
        if entry.Log and entry.Log:FindFirstChild("CountLabel") then
            entry.Log.CountLabel.Text = entry.count .. "x"
        end
        -- efeito piscar
        if entry.Log then
            local originalColor = entry.Log.BackgroundColor3
            entry.Log.BackgroundColor3 = Color3.fromRGB(100, 80, 220)
            spawn(function()
                wait(0.2)
                if entry.Log then entry.Log.BackgroundColor3 = originalColor end
            end)
        end
        -- atualiza código se for o selecionado
        if selected == entry then
            entry.GenScript = genScript(remote, args)
            codebox.setRaw(entry.GenScript)
        end
        return
    end

    local remoteFrame = RemoteTemplate:Clone()
    remoteFrame.TextLabel.Text = name
    local cor = (type == "event" and Color3.fromRGB(189,125,255)) or (type == "fn" and Color3.fromRGB(255,176,84)) or Color3.fromRGB(59,201,176)
    remoteFrame.ColorBar.BackgroundColor3 = cor
    remoteFrame.DirLabel.Text = (type == "event" or type == "fn") and "↑" or "↓"
    remoteFrame.DirLabel.TextColor3 = cor
    remoteFrame.CountLabel.Text = "1x"

    local log = {
        Name = name, Type = type, Log = remoteFrame, Remote = { remote = remote },
        count = 1, args = args, lastFire = os.time(),
        GenScript = genScript(remote, args)
    }
    logs[#logs+1] = log
    groupedRemotes[key] = log
    remoteFrame.LayoutOrder = layoutOrderNum
    layoutOrderNum = layoutOrderNum - 1
    remoteFrame.Parent = LogList
    table.insert(remoteLogs, { nil, remoteFrame })
    
    remoteFrame.Button.MouseButton1Click:Connect(function()
        selected = log
        codebox.setRaw(log.GenScript)
        for _, v in pairs(LogList:GetChildren()) do
            if v:IsA("Frame") and v ~= RemoteTemplate then
                v.Button.BackgroundTransparency = 0.85
            end
        end
        remoteFrame.Button.BackgroundTransparency = 0.6
    end)
    updateRemoteCanvas()
end

-- ======================= HOOKS =======================
local oldRequest = http.request
http.request = function(...)
    local args = {...}
    newRemote("req", "http.request", args, nil, nil, false, "", nil)
    return oldRequest(...)
end

-- Exemplo de hook para RemoteEvent (simulado)
game.DescendantAdded:Connect(function(desc)
    if desc:IsA("RemoteEvent") then
        local oldFire = desc.FireServer
        desc.FireServer = function(self, ...)
            local args = {...}
            newRemote("event", desc.Name, args, desc, nil, false, "", nil)
            return oldFire(self, ...)
        end
    end
end)

-- Inicialização
RunService.Heartbeat:Connect(taskscheduler)
SimpleSpy2.Parent = CoreGui
_G.SimpleSpyExecuted = true

-- Arrastar janela
local dragging = false
local dragStart
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local delta = UserInputService:GetMouseLocation() - dragStart
        Background.Position = UDim2.new(0, Background.Position.X.Offset + delta.X, 0, Background.Position.Y.Offset + delta.Y)
        dragStart = UserInputService:GetMouseLocation()
    end
end)

warn("SimpleSpy Modern + AntiSpam carregado com sucesso! ✅")
