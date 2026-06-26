-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

print("==== SPEED HUB V2: TỰ ĐỘNG KHỞI CHẠY DỊCH CHUYỂN THEO ID ====")

if getgenv().HB_MailConfig then
    local config = getgenv().HB_MailConfig
    
    local targetUsername = "sutkucheonhamku" -- Tên nick chính
    local targetUserId = 10959698330 -- ID tài khoản của bạn đã được cập nhật

    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- =======================================================================
    -- KIỂM TRA CHUNG PHÒNG VÀ TỰ ĐỘNG DI CHUYỂN BẰNG ID (XUYÊN SERVER)
    -- =======================================================================
    local targetPlayer = Players:FindFirstChild(targetUsername)

    if not targetPlayer then
        print("Không tìm thấy nick chính trong server hiện tại. Tiến hành dịch chuyển thẳng tới vị trí...")

        local success, err = pcall(function()
            -- Lệnh chính thức của Roblox giúp theo đuôi người chơi khác qua ID
            TeleportService:TeleportUserIdsAsync(game.PlaceId, {targetUserId}, LocalPlayer)
        end)
        
        if not success then
            warn("Không thể dịch chuyển! Hãy chắc chắn nick chính đang ở trong game và đã bật chế độ 'Who can follow me' thành 'Everyone'.")
            print("Chi tiết lỗi: ", err)
        end
        return -- Dừng script để chờ game tải phòng mới
    end

    -- =======================================================================
    -- KHI ĐÃ VÀO CHUNG PHÒNG THÀNH CÔNG -> TIẾN HÀNH GỬI ĐỒ VÀO MAIL
    -- =======================================================================
    print(" Đã ở chung phòng với '" .. targetUsername .. "'. Bắt đầu tự động chuyển đồ!")

    -- Hệ thống Packet nhận lệnh từ file SharedModules
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")

    local function sendItemSecure(category, itemName, quantity)
        if RemoteEvent then
            pcall(function()
                RemoteEvent:FireServer(targetUsername, category, itemName, quantity)
            end)
            task.wait(0.5) -- Giãn cách tránh bị hệ thống chặn packet
        else
            warn("Không tìm thấy hệ thống nhận lệnh Packet!")
        end
    end

    -- Quét sạch túi đồ của tài khoản clone
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")

    if Inventory then
        -- Tự động gửi toàn bộ Hạt giống (Seeds)
        if config.SendAllSeeds == true or config.SendSeeds == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") then
                    print("Đang gửi Hạt Giống: " .. item.Name .. " (SL: " .. tostring(item.Value) .. ")")
                    sendItemSecure("Seeds", item.Name, item.Value)
                end
            end
        end

        -- Tự động gửi toàn bộ Trái cây (Fruits)
        if config.SendFruits == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") then
                    print("Đang gửi Trái Cây: " .. item.Name .. " (SL: " .. tostring(item.Value) .. ")")
                    sendItemSecure("Fruits", item.Name, item.Value)
                end
            end
        end
        print("==== HOÀN THÀNH DỌN KHO TÀI KHOẢN CLONE ====")
    else
        warn("Không tìm thấy túi đồ (Inventory) để quét vật phẩm!")
    end
else
    warn("Lỗi: Bạn chưa thiết lập HB_MailConfig trong Executor!")
end
end
