-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

print("==== SPEED HUB V2: PHIÊN BẢN GỬI MAIL THEO PACKET SYSTEM ====")

if getgenv().HB_MailConfig then
    local config = getgenv().HB_MailConfig
    
    -- Tên tài khoản nhận đồ cố định của bạn
    local targetPlayerName = "sutkucheonhamku" 

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- Xác định hệ thống mạng (Packet) của game dựa trên kết quả Spy của bạn
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")

    -- Hàm thực hiện đóng gói và gửi Mail từ xa bằng chính hệ thống của game
    local function sendMailViaPacket(category, itemName, quantity)
        if RemoteEvent then
            -- Vì game dùng cấu trúc Packet mã hóa (Buffer), script cần gửi đúng định dạng của game
            -- Thường cấu trúc sẽ đi qua một phương thức Network chứa ID hành động Mail
            -- Đoạn này ép lệnh gửi trực tiếp thông qua Remote của hệ thống SharedModules
            pcall(function()
                -- Gọi RemoteEvent của game với dữ liệu giả lập cấu trúc Mail
                -- Server game tự nhận diện tên người nhận "sutkucheonhamku" qua chuỗi string hoặc ID
                RemoteEvent:FireServer(targetPlayerName, category, itemName, quantity)
            end)
            task.wait(0.6) -- Chờ tránh spam packet bị kích (Kick) khỏi game
        else
            warn("Không tìm thấy hệ thống Packet RemoteEvent của game!")
        end
    end

    -- =======================================================================
    -- QUÉT TÚI ĐỒ VÀ TIẾN HÀNH GỬI MAIL XUYÊN SERVER
    -- =======================================================================
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")

    if Inventory then
        -- 1. Tự động gửi tất cả các loại Hạt giống (Seeds)
        if config.SendAllSeeds == true or config.SendSeeds == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") then
                    print("Đang đóng gói và gửi Hạt Giống ["..item.Name.."] tới: " .. targetPlayerName)
                    sendMailViaPacket("Seeds", item.Name, item.Value)
                end
            end
        end

        -- 2. Tự động gửi Trái cây (Fruits)
        if config.SendFruits == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") then
                    print("Đang đóng gói và gửi Trái Cây ["..item.Name.."] tới: " .. targetPlayerName)
                    sendMailViaPacket("Fruits", item.Name, item.Value)
                end
            end
        end
    else
        warn("Không tìm thấy túi đồ của acc phụ để thực hiện quét!")
    end
else
    warn("Lỗi: Bạn chưa thiết lập HB_MailConfig trong Executor!")
end
