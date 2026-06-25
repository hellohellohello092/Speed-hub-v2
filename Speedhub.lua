-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

print("==== SPEED HUB V2: CHẾ ĐỘ GỬI MAIL KHÔNG CẦN CHUNG PHÒNG ====")

if getgenv().HB_MailConfig then
    local config = getgenv().HB_MailConfig
    
    -- Cố định luôn tên người nhận là nick chính của bạn
    local targetPlayerName = "sutkucheonhamku" 

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- =======================================================================
    -- ĐƯỜNG DẪN MAIL CỦA GAME (THAY TÊN "SendMail" BẰNG TÊN TRÊN SIMPLESPY CỦA BẠN)
    -- =======================================================================
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    local MailRemote = Remotes:FindFirstChild("SendMail") or Remotes:FindFirstChild("MailboxEvent")

    -- Hàm thực hiện gửi mail trực tiếp bằng Tên chuỗi (String)
    local function sendMailItem(category, itemName, quantity)
        if MailRemote then
            -- Gọi lệnh gửi Mail của game (truyền tên nick chính, loại đồ, tên đồ, số lượng)
            -- Lưu ý: Tùy game cấu trúc tham số có thể đảo vị trí, SimpleSpy sẽ hiện rõ vị trí này
            MailRemote:FireServer(targetPlayerName, category, itemName, quantity)
            task.wait(0.6) -- Chờ một chút tránh bị game chặn do gửi quá nhanh
        else
            warn("Chưa cấu hình đúng tên Remote Mail của Grow a Garden 2!")
        end
    end

    -- =======================================================================
    -- QUÉT TÚI ĐỒ VÀ TIẾN HÀNH GỬI MAIL
    -- =======================================================================
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")

    if Inventory then
        -- 1. Gửi tất cả Hạt giống nếu bật SendAllSeeds hoặc SendSeeds
        if config.SendAllSeeds == true or config.SendSeeds == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") then
                    print("Đang gửi Mail Hạt Giống ["..item.Name.."] tới: " .. targetPlayerName)
                    sendMailItem("Seeds", item.Name, item.Value)
                end
            end
        end

        -- 2. Gửi Trái cây nếu bật SendFruits
        if config.SendFruits == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") then
                    print("Đang gửi Mail Trái Cây ["..item.Name.."] tới: " .. targetPlayerName)
                    sendMailItem("Fruits", item.Name, item.Value)
                end
            end
        end
    else
        warn("Không tìm thấy túi đồ để quét vật phẩm gửi Mail!")
    end
else
    warn("Lỗi: Bạn chưa thiết lập HB_MailConfig trong Executor!")
end
