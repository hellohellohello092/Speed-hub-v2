-- Khởi tạo ban đầu chống đơ máy
if not game:IsLoaded() then
    pcall(function()
        local contentProvider = game:GetService("ContentProvider")
        contentProvider:PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB V2: TÍCH HỢP CHỌN MỤC TIÊU FLING ====")

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
    AutoJoin = false, 
    AutoSendSeeds = false, 
    AutoSendFruits = false,
    FlingTargetEnabled = false
}
local targetUsername = "sutkucheonhamku"
local targetUserId = 10959698330
local selectedFlingTarget = "" -- Lưu tên người bị chọn Fling

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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
                
                -- Khóa vị trí: Dịch chuyển acc phụ dính chặt vào người kẻ địch
                myHrp.CFrame = enemyHrp.CFrame * CFrame.new(0, 0, 0.5)
                
                -- Tạo vòng xoáy vận tốc vô hạn để giật tung đối thủ
                local oldVelocity = myHrp.Velocity
                myHrp.Velocity = Vector3.new(999999, 999999, 999999)
                
                RunService.RenderStepped:Wait()
                myHrp.Velocity = oldVelocity
                
                -- Tắt va chạm bản thân để không tự chết
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- Hàm lấy danh sách tên người chơi hiện tại (loại trừ nick chính và acc phụ)
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
-- HÀM DỊCH CHUYỂN VÀ GỬI PACKET (GIỮ NGUYÊN)
-- =======================================================================
local function handleTeleport()
    local targetPlayer = Players:FindFirstChild(targetUsername)
    if not targetPlayer then
        pcall(function() TeleportService:TeleportUserIdsAsync(game.PlaceId, {targetUserId}, LocalPlayer) end)
    end
end

local function sendItemSecure(category, itemName, quantity)
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")
    if RemoteEvent then
        pcall(function() RemoteEvent:FireServer(targetUsername, category, itemName, quantity) end)
        task.wait(0.8)
    end
end

task.spawn(function()
    while true do
        task.wait(4)
        if Options.AutoSendSeeds then
            if Players:FindFirstChild(targetUsername) then
                local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
                if Inventory then
                    for _, item in pairs(Inventory:GetChildren()) do
                        if string.find(string.lower(item.Name), "seed") and item:IsA("ValueBase") and item.Value > 0 then
                            sendItemSecure("Seeds", item.Name, item.Value)
                        end
                    end
                end
            end
        end
    end
end)

-- =======================================================================
-- CẤU TRÚC GIAO DIỆN MENU HACK
-- =======================================================================
if Window then
    pcall(function()
        -- TAB 1: GỬI ĐỒ
        local MainTab = Window:MakeTab({ Name = "Chuyển Đồ", Icon = "" })
        MainTab:AddToggle({ Name = "Bật Auto Join", Default = false, Callback = function(Value) Options.AutoJoin = Value if Value then handleTeleport() end end })
        MainTab:AddToggle({ Name = "Auto Gửi Hạt Giống", Default = false, Callback = function(Value) Options.AutoSendSeeds = Value end })
        MainTab:AddButton({ Name = "Dịch Chuyển Thủ Công", Callback = function() handleTeleport() end })

        -- TAB 2: TROLL CHI TIẾT
        local TrollTab = Window:MakeTab({ Name = "Troll / Fling", Icon = "" })
        TrollTab:Section({ Name = "Fling Theo Mục Tiêu" })

        -- Ô chọn mục tiêu (Dropdown)
        local TargetDropdown = TrollTab:AddDropdown({
            Name = "Chọn Người Muốn Fling",
            Default = "Chưa chọn ai",
            Options = getPlayerList(),
            Callback = function(Value)
                selectedFlingTarget = Value
                print("Đã nhắm mục tiêu Fling: " .. Value)
            end
        })

        -- Công tắc bật tắt dí Fling mục tiêu đã chọn
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

        -- Nút bấm cập nhật lại danh sách nếu có người mới vào phòng
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
