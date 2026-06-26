-- Chờ game tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

print("==== SPEED HUB V2: TỰ ĐỘNG DỊCH CHUYỂN ĐẾN SERVER NICK CHÍNH ====")

if getgenv().HB_MailConfig then
    local config = getgenv().HB_MailConfig
    
    -- Tên tài khoản chính nhận đồ của bạn
    local targetUsername = "sutkucheonhamku" 

    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- =======================================================================
    -- BƯỚC 1: KIỂM TRA VÀ TỰ ĐỘNG NHẢY SERVER (AUTO JOIN)
    -- =======================================================================
    local targetPlayer = Players:FindFirstChild(targetUsername)

    if not targetPlayer then
        print("Không thấy nick chính trong phòng này. Đang quét tìm Server của nick chính...")
        
        local success, err = pcall(function()
            local gameId = game.PlaceId
            -- Lấy danh sách các Server công khai hiện tại của game
            local url = "https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Desc&limit=100"
            local serverData = HttpService:JSONDecode(game:HttpGet(url))
            
            -- Để tính năng này chạy tốt nhất, bạn hãy bật chế độ "Who can follow me" thành "Everyone" trong cài đặt Quyền riêng tư (Privacy) của nick chính sutkucheonhamku.
            -- Script sẽ tự tìm server hoặc nhảy liên tục (Hop Server) cho đến khi bắt gặp nick chính.
            if serverData and serverData.data then
                local availableServers = {}
                for _, server in pairs(serverData.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(availableServers, server.id)
                    end
                end
                
                if #availableServers > 0 then
                    local randomServerId = availableServers[math.random(1, #availableServers)]
                    print("Đang dịch chuyển sang Server mới: " .. tostring(randomServerId))
                    TeleportService:TeleportToPlaceInstance(gameId, randomServerId, LocalPlayer)
                else
                    warn("Không tìm thấy server trống nào thích hợp để nhảy!")
                end
            end
        end)
        
        if not success then
            warn("Lỗi khi tìm kiếm server: ", err)
        end
        return -- Dừng script lại tại đây để đợi game load chuyển phòng
    end

    -- =======================================================================
    -- BƯỚC 2: KHI ĐÃ VÀO CHUNG PHÒNG -> TIẾN HÀNH GỬI ĐỒ
    -- =======================================================================
    print(" Chúc mừng! Đã tìm thấy nick chính '" .. targetUsername .. "' chung phòng. Tiến hành gửi đồ...")

    -- Gọi hệ thống Packet mà bạn đã bắt được bằng SimpleSpy ở bước trước
    local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local PacketModule = SharedModules and SharedModules:FindFirstChild("Packet")
    local RemoteEvent = PacketModule and PacketModule:FindFirstChild("RemoteEvent")

    local function sendItemSecure(category, itemName, quantity)
        if RemoteEvent then
            pcall(function()
                -- Vì đứng chung phòng nên Server game sẽ chấp nhận Packet gửi này trực tiếp
                RemoteEvent:FireServer(targetUsername, category, itemName, quantity)
            end)
            task.wait(0.5) -- Chờ 0.5 giây để tránh bị lỗi spam packet
        else
            warn("Không tìm thấy RemoteEvent của hệ thống Packet!")
        end
    end

    -- Quét túi đồ (Inventory) của tài khoản clone để dọn sạch kho
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")

    if Inventory then
        -- Tự động gửi Hạt giống (Seeds)
        if config.SendAllSeeds == true or config.SendSeeds == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "seed") then
                    print("Đang chuyển Hạt Giống: " .. item.Name .. " (Số lượng: " .. tostring(item.Value) .. ")")
                    sendItemSecure("Seeds", item.Name, item.Value)
                end
            end
        end

        -- Tự động gửi Trái cây (Fruits)
        if config.SendFruits == true then
            for _, item in pairs(Inventory:GetChildren()) do
                if string.find(string.lower(item.Name), "fruit") then
                    print("Đang chuyển Trái Cây: " .. item.Name .. " (Số lượng: " .. tostring(item.Value) .. ")")
                    sendItemSecure("Fruits", item.Name, item.Value)
                end
            end
        end
        print("==== ĐÃ HOÀN THÀNH GỬI ĐỒ VỀ NICK CHÍNH ====")
    else
        warn("Không tìm thấy túi đồ để quét vật phẩm!")
    end
else
    warn("Lỗi: Bạn chưa thiết lập bảng cấu hình HB_MailConfig!")
end
