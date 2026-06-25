-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

print("==== SPEED HUB V2: KHỞI ĐỘNG HỆ THỐNG ====")

if getgenv().HB_MailConfig then
    local config = getgenv().HB_MailConfig
    
    -- THAY ĐỔI TÊN NGƯỜI NHẬN MẶC ĐỊNH TẠI ĐÂY
    local rawTargetName = "sutkucheonhamku" 
    local targetPlayerName = nil

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- =======================================================================
    -- SỬ DỤNG HÀM ĐỂ TÌM CHÍNH XÁC TÊN NGƯỜI NHẬN TRONG SERVER
    -- =======================================================================
    for _, player in pairs(Players:GetPlayers()) do
        -- Kiểm tra xem tài khoản "sutkucheonhamku" có trong server không
        if string.find(string.lower(player.Name), string.lower(rawTargetName)) or 
           string.find(string.lower(player.DisplayName), string.lower(rawTargetName)) then
            targetPlayerName = player.Name -- Lấy Username gốc
            break
        end
    end

    -- Nếu tìm thấy tài khoản "sutkucheonhamku" trong server thì mới chạy tiếp
    if targetPlayerName then
        print(" Đã tìm thấy nick chính trong server: " .. targetPlayerName)
        
        -- Nơi nhận lệnh của game (Thay thế tên Remote chính xác bằng SimpleSpy)
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        local SendGiftRemote = Remotes:FindFirstChild("SendGift") or Remotes:FindFirstChild("GiftEvent")

        -- Hàm thực hiện gửi đồ
        local function sendItem(category, itemName, quantity)
            if SendGiftRemote then
                -- Hệ thống sẽ luôn bốc tên "sutkucheonhamku" để gửi đi
                SendGiftRemote:FireServer(targetPlayerName, category, itemName, quantity)
                task.wait(0.5) -- Chờ 0.5 giây để tránh bị lỗi spam/kick
            else
                warn("Chưa cấu hình đúng tên Remote gửi đồ của game!")
            end
        end

        -- =======================================================================
        -- QUÉT TÚI ĐỒ VÀ GỬI
        -- =======================================================================
        local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")

        if Inventory then
            -- Gửi tất cả Hạt giống nếu bật SendAllSeeds hoặc SendSeeds
            if config.SendAllSeeds == true or config.SendSeeds == true then
                for _, item in pairs(Inventory:GetChildren()) do
                    if string.find(string.lower(item.Name), "seed") then
                        print("Đang tự động gửi Hạt Giống ["..item.Name.."] tới: " .. targetPlayerName)
                        sendItem("Seeds", item.Name, item.Value)
                    end
                end
            end

            -- Gửi Trái cây nếu bật SendFruits
            if config.SendFruits == true then
                for _, item in pairs(Inventory:GetChildren()) do
                    if string.find(string.lower(item.Name), "fruit") then
                        print("Đang tự động gửi Trái Cây ["..item.Name.."] tới: " .. targetPlayerName)
                        sendItem("Fruits", item.Name, item.Value)
                    end
                end
            end
        else
            warn("Không tìm thấy túi đồ (Inventory) của tài khoản clone!")
        end

    else
        warn(" Không tìm thấy tài khoản '" .. tostring(rawTargetName) .. "' trong Server này! Vui lòng cho nick chính vào chung server.")
    end
else
    warn("Lỗi: Bạn chưa thiết lập HB_MailConfig trong Executor!")
end
