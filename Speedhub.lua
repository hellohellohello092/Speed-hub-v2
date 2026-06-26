-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

-- Khởi tạo thư viện giao diện Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Tạo cửa sổ Menu chính
local Window = OrionLib:MakeWindow({
    Name = "Speed Hub V2 - Grow a Garden 2", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "SpeedHubConfig"
})

-- Các biến lưu trạng thái hoạt động của chức năng
local Options = {
    AutoJoin = false,
    AutoSendSeeds = false,
    AutoSendFruits = false
}

-- Thông tin tài khoản nhận đồ
local targetUsername = "sutkucheonhamku"
local targetUserId = 10959698330

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =======================================================================
-- TÁC VỤ XỬ LÝ NGẦM (BACKGROUND LOOPS)
-- =======================================================================

-- Hàm tự động dịch chuyển tìm nick chính
local function handleTeleport()
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer and Options.AutoJoin then
        OrionLib:MakeNotification({
            Name = "Hệ thống Dịch Chuyển",
            Content = "Không tìm thấy nick chính. Đang quét tìm server...",
            Image = "rbxassetid://4483345991",
            Time = 5
        })
        
        -- Thử cách 1: ID trực tiếp
        local success, _ = pcall(function()
            TeleportService:TeleportUserIdsAsync(game.PlaceId, {targetUserId}, LocalPlayer)
        end)
        
        -- Cách 2: Server Hop nếu lỗi
        if not success then
            pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local serverData = HttpService:JSONDecode(game:HttpGet(url))
                if serverData and serverData.data then
                    local availableServers = {}
                    for _, server in pairs(serverData.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            table.insert(availableServers, server.id)
                        end
                    end
                    if #availableServers > 0 then
                        local randomServer = availableServers[math.random(1, #availableServers)]
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
                    end
                end
            end)
        end
    end
end

-- Hệ thống gửi Packet an toàn
local function sendItemSecure(category, itemName, quantity)
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")
    
    if RemoteEvent then
        pcall(function()
            RemoteEvent:FireServer(targetUsername, category, itemName, quantity)
        end)
        task.wait(0.6)
    end
end

-- Vòng lặp quét túi đồ và gửi vật phẩm tự động
task.spawn(function()
    while task.wait(3) do
        local targetPlayer = Players:FindFirstChild(targetUsername)
        -- Chỉ gửi đồ khi đã ở chung phòng với tài khoản chính
        if targetPlayer then
            local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
            if Inventory then
                -- Quét Hạt giống
                if Options.AutoSendSeeds then
                    for _, item in pairs(Inventory:GetChildren()) do
                        if string.find(string.lower(item.Name), "seed") and item:IsA("ValueBase") and item.Value > 0 then
                            sendItemSecure("Seeds", item.Name, item.Value)
                        end
                    end
                end
                -- Quét Trái cây
                if Options.AutoSendFruits then
                    for _, item in pairs(Inventory:GetChildren()) do
                        if string.find(string.lower(item.Name), "fruit") and item:IsA("ValueBase") and item.Value > 0 then
                            sendItemSecure("Fruits", item.Name, item.Value)
                        end
                    end
                end
            end
        end
    end
end)

-- =======================================================================
-- THIẾT KẾ CÁC TAB VÀ NÚT BẤM TRÊN MENU INTERFACE
-- =======================================================================

-- Tạo Tab Chức Năng Chính
local MainTab = Window:MakeTab({
    Name = "Chức Năng",
    Icon = "rbxassetid://4483345991",
    PremiumOnly = false
})

MainTab:AddSection({
    Name = "Tự Động Kết Nối"
})

-- Ô chọn bật tắt Auto Join
MainTab:AddToggle({
    Name = "Bật Auto Join (Theo đuôi Nick Chính)",
    Default = false,
    Callback = function(Value)
        Options.AutoJoin = Value
        if Value then
            handleTeleport()
        end
    end
})

MainTab:AddSection({
    Name = "Tự Động Chuyển Kho"
})

-- Ô chọn bật tắt gửi Hạt Giống
MainTab:AddToggle({
    Name = "Auto Gửi Tất Cả Hạt Giống (Seeds)",
    Default = false,
    Callback = function(Value)
        Options.AutoSendSeeds = Value
    end
})

-- Ô chọn bật tắt gửi Trái Cây
MainTab:AddToggle({
    Name = "Auto Gửi Tất Cả Trái Cây (Fruits)",
    Default = false,
    Callback = function(Value)
        Options.AutoSendFruits = Value
    end
})

-- Thêm nút bấm hỗ trợ ép dịch chuyển tức thời thủ công nếu muốn
MainTab:AddButton({
    Name = "Dịch Chuyển Thủ Công Đến Nick Chính",
    Callback = function()
        handleTeleport()
    end
})

-- Tab thông tin cấu hình hệ thống
local InfoTab = Window:MakeTab({
    Name = "Thông Tin",
    Icon = "rbxassetid://4483345991",
    PremiumOnly = false
})

InfoTab:AddLabel("Tài khoản nhận: " .. targetUsername)
InfoTab:AddLabel("ID cấu hình: " .. tostring(targetUserId))

-- Kết thúc khởi tạo Menu
OrionLib:Init()
