-- ============================================================
-- BLOX FRUIT ULTIMATE FARM v3.0 (DeltaX Mobile)
-- Bởi nhatanh Dev
-- Tính năng: Auto Fruit, Auto Farm, ESP, Auto Store, Server Hop
-- ============================================================

-- === KIỂM TRA ===
if not game then return warn("❌ Không tìm thấy game!") end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("Đợi LocalPlayer...")
    LocalPlayer = Players:WaitForChild("LocalPlayer", 5)
    if not LocalPlayer then return warn("❌ Không có LocalPlayer") end
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

if not Humanoid or not RootPart then
    return warn("❌ Không có Humanoid hoặc RootPart")
end

print("✅ Fruit Lor Ultimate v3.0 loaded!")

-- ===== CẤU HÌNH MẶC ĐỊNH =====
local Config = {
    AutoFruit = true,
    AutoFarm = false,
    ESP = true,
    AutoStore = true,
    AutoHop = true,
    FruitKeyword = "fruit",
    FarmRadius = 500,
    TeleportMethod = "CFrame", -- "CFrame" hoặc "Fly"
}

-- ===== THỐNG KÊ =====
local Stats = {
    FruitsCollected = 0,
    ServersHopped = 0,
    TotalFarms = 0,
    LastFruit = "",
}

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FruitLorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🍉 FRUIT LOR ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255,200,50)
Title.BackgroundColor3 = Color3.fromRGB(40,40,60)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Nút đóng
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

-- Hàm tạo toggle
local function addToggle(parent, text, default, callback, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -55, 0.5, -12.5)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100)
        btn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    return btn, state
end

-- Thống kê
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -10, 0, 60)
StatsFrame.Position = UDim2.new(0, 5, 0, 45)
StatsFrame.BackgroundColor3 = Color3.fromRGB(0,0,0,0.3)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = MainFrame

local StatLabels = {}
local function addStat(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(150,200,255)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = StatsFrame
    table.insert(StatLabels, lbl)
    return lbl
end
addStat("📦 Đã nhặt: 0", 0)
addStat("🔄 Đã đổi server: 0", 20)
addStat("🍎 Trái cuối: Chưa có", 40)

-- Các toggle
local y = 110
addToggle(MainFrame, "Auto Fruit Sniper", Config.AutoFruit, function(v) Config.AutoFruit = v end, y); y = y + 35
addToggle(MainFrame, "Auto Farm Level", Config.AutoFarm, function(v) Config.AutoFarm = v end, y); y = y + 35
addToggle(MainFrame, "ESP (định vị)", Config.ESP, function(v) Config.ESP = v end, y); y = y + 35
addToggle(MainFrame, "Auto Store", Config.AutoStore, function(v) Config.AutoStore = v end, y); y = y + 35
addToggle(MainFrame, "Auto Hop", Config.AutoHop, function(v) Config.AutoHop = v end, y); y = y + 35

-- Thanh trạng thái
local StatusBar = Instance.new("TextLabel")
StatusBar.Size = UDim2.new(1, -10, 0, 30)
StatusBar.Position = UDim2.new(0, 5, 0, 310)
StatusBar.Text = "⏳ Đang khởi động..."
StatusBar.TextColor3 = Color3.fromRGB(100,255,100)
StatusBar.BackgroundColor3 = Color3.fromRGB(0,0,0,0.4)
StatusBar.TextSize = 14
StatusBar.Font = Enum.Font.Gotham
StatusBar.Parent = MainFrame

-- ===== HÀM TÌM TRÁI =====
local function findFruit()
    local keyword = Config.FruitKeyword:lower()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and string.lower(obj.Name):find(keyword) then
            return obj
        end
        if obj:IsA("Model") and string.lower(obj.Name):find(keyword) then
            return obj
        end
    end
    return nil
end

-- ===== HÀM DI CHUYỂN =====
local function moveTo(pos)
    if not pos then return end
    if Config.TeleportMethod == "CFrame" then
        RootPart.CFrame = CFrame.new(pos)
    else
        -- Bay (dùng BodyVelocity)
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000,4000,4000)
        bv.Parent = RootPart
        while (RootPart.Position - pos).Magnitude > 8 do
            local dir = (pos - RootPart.Position).unit
            bv.Velocity = dir * 90 + Vector3.new(0,8,0)
            wait(0.1)
        end
        bv:Destroy()
    end
end

-- ===== NHẶT TRÁI =====
local function pickFruit(fruit)
    -- Thử remote event
    local remote = ReplicatedStorage:FindFirstChild("PickUpFruit") or
                   ReplicatedStorage:FindFirstChild("CollectFruit") or
                   ReplicatedStorage:FindFirstChild("GrabFruit") or
                   ReplicatedStorage:FindFirstChild("TakeFruit")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(fruit)
        return true
    end
    -- Dùng VirtualUser click
    if VirtualUser then
        VirtualUser:ClickButton1(Vector2.new(0,0))
        wait(0.2)
        VirtualUser:ClickButton1(Vector2.new(0,0))
        return true
    end
    return false
end

-- ===== CẤT VÀO KHO =====
local function storeFruit(fruit)
    if not Config.AutoStore then return false end
    local storeRemote = ReplicatedStorage:FindFirstChild("StoreFruit") or
                        ReplicatedStorage:FindFirstChild("Storage") or
                        ReplicatedStorage:FindFirstChild("PutFruit")
    if storeRemote and storeRemote:IsA("RemoteEvent") then
        storeRemote:FireServer(fruit)
        return true
    end
    return false
end

-- ===== ESP =====
local espObjects = {}
local function updateESP()
    if Config.ESP then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Head") and v ~= Character then
                if not espObjects[v] then
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "ESPBox"
                    bill.Size = UDim2.new(0, 50, 0, 50)
                    bill.Adornee = v.Head
                    bill.AlwaysOnTop = true
                    bill.Parent = v
                    local f = Instance.new("Frame")
                    f.Size = UDim2.new(1,0,1,0)
                    f.BackgroundColor3 = Color3.fromRGB(255,0,0)
                    f.BackgroundTransparency = 0.4
                    f.BorderSizePixel = 1
                    f.BorderColor3 = Color3.fromRGB(255,255,0)
                    f.Parent = bill
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1,0,0,18)
                    lbl.Position = UDim2.new(0,0,1,0)
                    lbl.Text = v.Name
                    lbl.TextColor3 = Color3.fromRGB(255,255,255)
                    lbl.TextSize = 12
                    lbl.BackgroundTransparency = 1
                    lbl.Parent = bill
                    espObjects[v] = bill
                end
            end
        end
    else
        for v, bill in pairs(espObjects) do
            if bill then bill:Destroy() end
        end
        espObjects = {}
    end
end

-- ===== TÌM QUÁI CHO AUTO FARM =====
local function findMob()
    local best, minDist = nil, 99999
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") then
            if v ~= Character and v.Name ~= LocalPlayer.Name then
                local dist = (RootPart.Position - v.Head.Position).Magnitude
                if dist < minDist and dist > 5 then
                    minDist = dist
                    best = v
                end
            end
        end
    end
    return best, minDist
end

-- ===== VÒNG LẶP CHÍNH =====
local function updateStats()
    if StatLabels[1] then StatLabels[1].Text = "📦 Đã nhặt: " .. Stats.FruitsCollected end
    if StatLabels[2] then StatLabels[2].Text = "🔄 Đã đổi server: " .. Stats.ServersHopped end
    if StatLabels[3] then StatLabels[3].Text = "🍎 Trái cuối: " .. Stats.LastFruit end
end

spawn(function()
    while true do
        wait(0.3)
        
        -- ESP
        updateESP()
        
        -- Auto Farm
        if Config.AutoFarm then
            local mob, dist = findMob()
            if mob and dist < Config.FarmRadius then
                moveTo(mob.Head.Position + Vector3.new(0,5,0))
                VirtualUser:ClickButton1(Vector2.new(0,0))
            end
        end
        
        -- Auto Fruit
        if Config.AutoFruit then
            local fruit = findFruit()
            if fruit then
                local pos = fruit:IsA("Tool") and fruit.Handle and fruit.Handle.Position or fruit:IsA("Model") and fruit.Head and fruit.Head.Position or fruit.Position
                if pos then
                    StatusBar.Text = "🔍 Tìm thấy: " .. fruit.Name
                    moveTo(pos)
                    wait(0.3)
                    if pickFruit(fruit) then
                        Stats.FruitsCollected = Stats.FruitsCollected + 1
                        Stats.LastFruit = fruit.Name
                        StatusBar.Text = "✅ Đã nhặt " .. fruit.Name
                        -- Cất kho
                        if storeFruit(fruit) then
                            StatusBar.Text = StatusBar.Text .. " + cất kho"
                        end
                        updateStats()
                    else
                        StatusBar.Text = "⚠️ Nhặt thất bại"
                    end
                end
            else
                if Config.AutoHop then
                    StatusBar.Text = "❌ Không có trái, đổi server..."
                    TeleportService:Teleport(game.PlaceId)
                    Stats.ServersHopped = Stats.ServersHopped + 1
                    updateStats()
                    wait(5)
                else
                    StatusBar.Text = "❌ Không có trái, chờ..."
                end
            end
        end
        
        wait(0.5)
    end
end)

print("✅ Fruit Lor Ultimate sẵn sàng! Menu hiện ngay khi chạy.")