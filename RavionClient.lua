--[[
    Ravion Client v13.1
    Powered by Rayfield Gen2
    Based on YARHM by Aetherion
]]

if not game:IsLoaded() then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ravion Client",
        Text = "Waiting for the game to finish loading!",
        Duration = 5
    })
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer

local window = Rayfield:CreateWindow({
    name = "Ravion Client",
    subtitle = "v13.1",
    sidebarLayout = true,
    theme = "cobalt",
    configuration = {
        autoSave   = true,
        autoLoad   = true,
        fileName   = "RavionClient",
    },
})

local dialogEvent  = Instance.new("BindableEvent")
local dialogResult = nil

local function dialog(title, description, buttons)
    dialogResult = nil
    local opts = {}
    for _, text in ipairs(buttons) do
        table.insert(opts, {
            text = text,
            callback = function()
                dialogResult = text
                dialogEvent:Fire(text)
            end,
        })
    end
    window:Popup({
        title       = title,
        content     = description,
        options     = opts,
        dismissable = false,
    })
end

local function waitfordialog()
    if dialogResult then return dialogResult end
    return dialogEvent.Event:Wait()
end

local function closedialog() end 

local function splitString(str, delim)
    local broken = {}
    if delim == nil then delim = "," end
    for w in string.gmatch(str, "[^" .. delim .. "]+") do
        table.insert(broken, w)
    end
    return broken
end

local function toTokens(str)
    local tokens = {}
    for op, name in string.gmatch(str, "([+-])([^+-]+)") do
        table.insert(tokens, { Operator = op, Name = name })
    end
    return tokens
end

local function onlyIncludeInTable(tab, matches)
    local matchTable, resultTable = {}, {}
    for _, v in pairs(matches) do matchTable[v.Name] = true end
    for _, v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable, v) end end
    return resultTable
end

local function removeTableMatches(tab, matches)
    local matchTable, resultTable = {}, {}
    for _, v in pairs(matches) do matchTable[v.Name] = true end
    for _, v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable, v) end end
    return resultTable
end

local function getPlayersByName(Name)
    Name = string.lower(Name)
    local Len, Found = #Name, {}
    for _, v in pairs(Players:GetPlayers()) do
        if Name:sub(1, 1) == "@" then
            if string.sub(string.lower(v.Name), 1, Len - 1) == Name:sub(2) then
                table.insert(Found, v)
            end
        else
            if string.sub(string.lower(v.Name), 1, Len) == Name
            or string.sub(string.lower(v.DisplayName), 1, Len) == Name then
                table.insert(Found, v)
            end
        end
    end
    return Found
end

local function getPlayer(list, speaker)
    if list == nil then return speaker.Name end
    local nameList  = splitString(list, ",")
    local foundList = {}
    for _, name in pairs(nameList) do
        if string.sub(name, 1, 1) ~= "+" and string.sub(name, 1, 1) ~= "-" then
            name = "+" .. name
        end
        local tokens = toTokens(name)
        local initialPlayers = Players:GetPlayers()
        for _, v in pairs(tokens) do
            if v.Operator == "+" then
                initialPlayers = onlyIncludeInTable(initialPlayers, getPlayersByName(v.Name))
            else
                initialPlayers = removeTableMatches(initialPlayers, getPlayersByName(v.Name))
            end
        end
        for _, v in pairs(initialPlayers) do table.insert(foundList, v) end
    end
    local foundNames = {}
    for _, v in pairs(foundList) do table.insert(foundNames, v.Name) end
    return foundNames[1]
end


local espind = (function()
    local e={} e.__index=e local a=game:GetService("RunService") local _=game:GetService("Players") local b=game:GetService("HttpService") local l=game:GetService("TweenService") e.Groups={} e.TargetIndex={} e.Defaults={AccentColor=Color3.new(1,1,0),HighlightFillTransparency=0.7,HighlightOutlineTransparency=0,HighlightDepthMode=Enum.HighlightDepthMode.AlwaysOnTop,ArrowShow=false,ArrowEdgePadding=50,ArrowMinDistance=0,ArrowSize=UDim2.new(0,30,0,30),ArrowImage="rbxassetid://97136202386756",ArrowShowDistanceText=true,ArrowDistanceFont=Enum.Font.Montserrat,ArrowDistanceTextSize=18,ShowLabel=false,LabelText="Target",LabelMaxDistance=99999,LabelOffset=Vector3.new(0,2,0),Parent=game:GetService("CoreGui")} function e.new(b)local c=setmetatable({},e) c.Settings={} for a,_ in pairs(e.Defaults)do c.Settings[a]=(b and b[a]~=nil)and b[a]or _ end local _=c.Settings.Parent or _.LocalPlayer:WaitForChild("PlayerGui") c.ScreenGui=Instance.new("ScreenGui") c.ScreenGui.Name="ESPIndicators" c.ScreenGui.IgnoreGuiInset=true c.ScreenGui.ResetOnSpawn=false c.ScreenGui.Parent=_ c.ArrowTemplate=Instance.new("ImageLabel") c.ArrowTemplate.Name="ArrowTemplate" c.ArrowTemplate.Size=c.Settings.ArrowSize c.ArrowTemplate.AnchorPoint=Vector2.new(0.5,0.5) c.ArrowTemplate.BackgroundTransparency=1 c.ArrowTemplate.Image=c.Settings.ArrowImage c.ArrowTemplate.ImageColor3=c.Settings.AccentColor c.ArrowTemplate.Visible=false c.ArrowTemplate.Parent=c.ScreenGui c.Scaler=Instance.new("UIScale") c.Scaler.Name="Scaler" c.Scaler.Scale=0 c.Scaler.Parent=c.ArrowTemplate c.Indicators={} c._updateConn=a.RenderStepped:Connect(function()c:_update()end) c._cleanupConn=a.Heartbeat:Connect(function()c:_cleanupOrphanedArrows() c:_cleanupOrphanedHighlights() c:_cleanupOrphanedLabels()end) return c end function e:AddGroup(_)local a=e.Groups[_] if not a then a={enabled=true,properties={},targets={}} e.Groups[_]=a end return a end function e:GetGroup(_)return e.Groups[_]end function e:RemoveGroup(b)local _=e.Groups[b] if not _ then return false end for _,_ in ipairs(_.targets)do local c=e.TargetIndex[_] if c then for _,a in ipairs(c)do if a==b then table.remove(c,_) break end end if#c==0 then e.TargetIndex[_]=nil end end if not e.TargetIndex[_]then self:Remove(_)end end e.Groups[b]=nil return true end function e:ClearAllGroups()for a,_ in pairs(e.Groups)do self:RemoveGroup(a)end end function e:ToggleGroup(_,a)local b=e.Groups[_] if not b then return end b.enabled=(a~=nil)and a or not b.enabled for _,_ in ipairs(b.targets)do local _=self.Indicators[_] if _ then if _.Highlight then _.Highlight.Enabled=b.enabled end if _.Arrow then _.Arrow.Visible=b.enabled and self.Settings.ArrowShow end if _.Label then _.Label.Enabled=b.enabled end end end return b.enabled end function e:SetGroupProperty(_,a,b)local _=self:AddGroup(_) _.properties[a]=b for _,_ in ipairs(_.targets)do local _=self.Indicators[_] if _ then if a=="AccentColor"then if _.Highlight then _.Highlight.FillColor=b _.Highlight.OutlineColor=b end if _.Arrow then _.Arrow.ImageColor3=b end if _.DistanceLabel then _.DistanceLabel.TextColor3=b end if _.Label and _.Label:FindFirstChild("TextLabel")then _.Label.TextLabel.TextColor3=b end end end end end function e:Add(a,g)assert(a,"ESPIndicator:Add requires a non-nil target") g=g or{} local d=Instance.new("Highlight") d.Name="Highlight_"..b:GenerateGUID(false) d.Adornee=a d.FillTransparency=g.HighlightFillTransparency or self.Settings.HighlightFillTransparency d.FillColor=g.AccentColor or self.Settings.AccentColor d.OutlineColor=g.AccentColor or self.Settings.AccentColor d.OutlineTransparency=g.HighlightOutlineTransparency or self.Settings.HighlightOutlineTransparency d.DepthMode=g.HighlightDepthMode or self.Settings.HighlightDepthMode d.Parent=self.ScreenGui local c,_,e if(g.ArrowShow or self.Settings.ArrowShow)then c=self.ArrowTemplate:Clone() c.Name="Arrow_"..b:GenerateGUID(false) c.ImageColor3=g.AccentColor or self.Settings.AccentColor c.Visible=true c.Parent=self.ScreenGui _=c:FindFirstChild("Scaler") if(g.ArrowShowDistanceText or self.Settings.ArrowShowDistanceText)then e=Instance.new("TextLabel") e.Name="DistanceLabel" e.AnchorPoint=Vector2.new(0.5,0) e.BackgroundTransparency=1 e.Font=g.ArrowDistanceFont or self.Settings.ArrowDistanceFont e.TextSize=g.ArrowDistanceTextSize or self.Settings.ArrowDistanceTextSize e.TextColor3=g.AccentColor or self.Settings.AccentColor e.Parent=c end end local f if(g.ShowLabel or self.Settings.ShowLabel)then f=Instance.new("BillboardGui") f.Name="Label_"..b:GenerateGUID(false) f.AlwaysOnTop=true f.MaxDistance=self.Settings.LabelMaxDistance f.Size=UDim2.new(0,70,0,70) f.StudsOffset=self.Settings.LabelOffset f.Adornee=a f.Parent=self.ScreenGui local _=Instance.new("TextLabel") _.Name="TextLabel" _.Size=UDim2.new(1,0,1,0) _.AnchorPoint=Vector2.new(0.5,0.5) _.Position=UDim2.new(0.5,0,0.5,0) _.BackgroundTransparency=1 _.Font=Enum.Font.SourceSansBold _.TextScaled=true _.TextWrapped=true _.TextSize=14 _.TextColor3=g.AccentColor or self.Settings.AccentColor _.Text=g.LabelText or self.Settings.LabelText _.Parent=f Instance.new("UIStroke",_)end self.Indicators[a]={Highlight=d,Arrow=c,Scaler=_,DistanceLabel=e,Label=f,Options=g} local _=g.GroupName or self.Settings.GroupName if _ then self:AddToGroup(a,_)end end function e:Remove(c)local _=self.Indicators[c] if not _ then return end if _.Highlight then _.Highlight.Adornee=nil _.Highlight:Destroy()end if _.Arrow then _.Arrow:Destroy()end if _.Label then _.Label:Destroy()end local _=e.TargetIndex[c] if _ then for _,_ in ipairs(_)do local b=e.Groups[_] if b then for a,_ in ipairs(b.targets)do if _==c then table.remove(b.targets,a) break end end end end e.TargetIndex[c]=nil end self.Indicators[c]=nil end function e:AddToGroup(c,b)local _=self:AddGroup(b) if not table.find(_.targets,c)then table.insert(_.targets,c)end local a=e.TargetIndex[c] if not a then a={} e.TargetIndex[c]=a end if not table.find(a,b)then table.insert(a,b)end for a,_ in pairs(_.properties)do self:SetGroupProperty(b,a,_)end if not _.enabled then local _=self.Indicators[c] if _ and _.Highlight then _.Highlight.Enabled=false end end return true end function e:RemoveFromGroup(d,b)local c=e.Groups[b] if not c then return false end if table.find(c.targets,d)then for _,a in ipairs(c.targets)do if a==d then table.remove(c.targets,_) break end end else return false end local c=e.TargetIndex[d] if c then for a,_ in ipairs(c)do if _==b then table.remove(c,a) break end end if#c==0 then e.TargetIndex[d]=nil end end return true end function e:GetGroupTargets(_)local _=e.Groups[_] return _ and _.targets or{}end function e:GetTargetGroups(_)return e.TargetIndex[_]or{}end function e:_cleanupOrphanedHighlights()for _,_ in ipairs(self.ScreenGui:GetChildren())do if _:IsA("Highlight")and not table.find(self:_allHighlights(),_)then _.Adornee=nil _:Destroy()end end end function e:_allHighlights()local a={} for _,_ in pairs(self.Indicators)do if _.Highlight then table.insert(a,_.Highlight)end end return a end function e:_cleanupOrphanedArrows()for _,_ in ipairs(self.ScreenGui:GetChildren())do if _:IsA("ImageLabel")and _.Name:match("^Arrow_")then if not table.find(self:_allArrows(),_)then _:Destroy()end end end end function e:_allArrows()local a={} for _,_ in pairs(self.Indicators)do if _.Arrow then table.insert(a,_.Arrow)end end return a end function e:_cleanupOrphanedLabels()for _,_ in ipairs(self.ScreenGui:GetChildren())do if _:IsA("BillboardGui")and _.Name:match("^Label_")then if not table.find(self:_allLabels(),_)then _.Adornee=nil _:Destroy()end end end end function e:_allLabels()local a={} for _,_ in pairs(self.Indicators)do if _.Label then table.insert(a,_.Label)end end return a end function e:_update()local a=workspace.CurrentCamera local _=a.ViewportSize local f,i=_.X,_.Y for _,p in pairs(self.Indicators)do local j=p.Options local h=p.Arrow local k=p.Scaler if((not h)or(not k))and self.Settings.ArrowShow then self:Remove(_) continue end if not h then continue end local n if _:IsA("Model")then n=(_.PrimaryPart and _.PrimaryPart.Position)or _:GetModelCFrame().p elseif _:IsA("BasePart")then n=_.Position else continue end local m,e=a:WorldToViewportPoint(n) local c=(a.CFrame.p-n).Magnitude local _=j.ArrowMinDistance or self.Settings.ArrowMinDistance local o=j.ArrowEdgePadding or self.Settings.ArrowEdgePadding if e and c>_ then l:Create(k,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=0}):Play()else l:Create(k,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1}):Play() local d,g=f-o*2,i-o*2 local b=a.CFrame local _=math.sqrt((d/2)^2+(g/2)^2) local a=n-b.Position local a=b:VectorToObjectSpace(a) local n=Vector2.new(a.X,a.Y).Unit local a=math.clamp(m.X,o,f-o) local b=math.clamp(m.Y,o,i-o) if a==m.X and b==m.Y and e then l:Create(k,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=0}):Play()else local _=n*_ local b if math.abs(_.Y)>g/2 then b=n*math.abs((g/2)/n.Y)else b=n*math.abs((d/2)/n.X)end local a=f/2+b.X local _=i/2-b.Y local b=math.atan2(n.X,n.Y) l:Create(h,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(a,_),Rotation=math.deg(b)}):Play()end if p.DistanceLabel then p.DistanceLabel.Text=string.format("%dm",math.round(c)) local _=(j.ArrowSize and j.ArrowSize.Y.Offset or self.Settings.ArrowSize.Y.Offset)+16 p.DistanceLabel.Position=UDim2.new(0.5,0,0,_)end end end end function e:Destroy()if self._updateConn then self._updateConn:Disconnect()end if self._cleanupConn then self._cleanupConn:Disconnect()end self:ClearAllGroups() for _,_ in pairs(self.Indicators)do if _.Highlight then _.Highlight:Destroy()end if _.Arrow then _.Arrow:Destroy()end if _.Label then _.Label:Destroy()end end self.ScreenGui:Destroy() self.Indicators={} e.Groups={} e.TargetIndex={}end return e
end)()


local flyutility = (function()
    local l={} local _=game:GetService("Players") local b=game:GetService("RunService") local d=_.LocalPlayer local h=false local e=50 local c=2 local i=0 local g=Vector3.new() local j=nil local k=nil local f=nil local function _()if f then f:Disconnect() f=nil end if j then j:Destroy() j=nil end if k then k:Destroy() k=nil end local _=d.Character if _ then local _=_:FindFirstChildOfClass("Humanoid") if _ then _.PlatformStand=false end end h=false i=0 end local function a(_)local a=d.Character if not h or not a then l:Stop() return end local _=a:FindFirstChildOfClass("Humanoid") local d=a:FindFirstChild("HumanoidRootPart") local a=workspace.CurrentCamera if not _ or _.Health<=0 or not d or not a then l:Stop() return end local _=_.MoveDirection if _.Magnitude>0.01 then i=math.min(e,i+c) g=_.Unit else i=math.max(0,i-c)end local _=Vector3.new(g.X,0,g.Z) local c=Vector3.zero if _.Magnitude>0 then c=_.Unit*i end local f=a.CFrame.LookVector.Unit local b=g:Dot(f) local _=b<0 and-1 or 1 local a=Vector3.new(f.X,0,f.Z) if a.Magnitude>0 then a=a.Unit end local a=math.abs(g:Dot(a)) local _=f.Y*_*a local _=_*i k.Velocity=Vector3.new(c.X,_,c.Z) local _=(i/e)*30 local _=-math.rad(b*_) j.CFrame=CFrame.new(d.Position,d.Position+f)*CFrame.Angles(_,0,0)end function l:Start()if h then return end local c=d.Character if not c then return end local _=c:FindFirstChildOfClass("Humanoid") local c=c:FindFirstChild("HumanoidRootPart") if not _ or not c then return end h=true j=Instance.new("BodyGyro") j.P=100000 j.MaxTorque=Vector3.new(math.huge,math.huge,math.huge) j.CFrame=c.CFrame j.Parent=c k=Instance.new("BodyVelocity") k.P=10000 k.MaxForce=Vector3.new(math.huge,math.huge,math.huge) k.Velocity=Vector3.new(0,0,0) k.Parent=c _.PlatformStand=true f=b.Heartbeat:Connect(a)end function l:Stop()if not h then return end _()end function l:SetMaxSpeed(_)if type(_)=="number"and _>=0 then e=_ else warn("FlyUtility:SetMaxSpeed requires a non-negative number.")end end function l:GetMaxSpeed()return e end function l:IsFlying()return h end d.CharacterRemoving:Connect(function(_)if h then l:Stop()end end) return l
end)()


local function miniFling(playerToFling)
    local lp = LocalPlayer
    local PlayersSvc = Players
    local savedFPDH = workspace.FallenPartsDestroyHeight
    local function fling(TargetPlayer)
        local Character = lp.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer.Character
        local THumanoid, TRootPart, THead, Accessory, Handle
        if TCharacter:FindFirstChildOfClass("Humanoid") then
            THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        end
        if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
        if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
        if TCharacter:FindFirstChildOfClass("Accessory") then
            Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        end
        if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end
        if not (Character and Humanoid and RootPart) then return end
        if RootPart.Velocity.Magnitude < 50 then getgenv()._RavionOldPos = RootPart.CFrame end
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Name = "RavionVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        local targetPart = THead or TRootPart or Handle
        if targetPart then
            local TimeToWait, StartTime, Angle = 2, tick(), 0
            repeat
                if RootPart and THumanoid then
                    Angle = Angle + 100
                    RootPart.CFrame = CFrame.new(targetPart.Position) * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(Angle), 0, 0)
                    Character:SetPrimaryPartCFrame(RootPart.CFrame)
                    RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
                    RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    task.wait()
                end
            until targetPart.Velocity.Magnitude > 500 or targetPart.Parent ~= TargetPlayer.Character or tick() > StartTime + TimeToWait
        else
            window:Notify({ title = "Fling", content = "Can't find a part to fling." })
        end
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        if getgenv()._RavionOldPos then
            repeat
                RootPart.CFrame = getgenv()._RavionOldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv()._RavionOldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                task.wait()
            until (RootPart.Position - getgenv()._RavionOldPos.p).Magnitude < 25
        end
        workspace.FallenPartsDestroyHeight = savedFPDH
    end
    fling(playerToFling)
end


local ws, fov = 16, 70
local loopFovWs = false
local wsIncrement = 2
local ctrlClickTP = false
local noclipLoop = nil
local aimTarget, aimlockConn = nil, nil
local playerToFling = nil
local antiFling = false
local antiFlingLastPos = Vector3.zero
local flingDetectionCon, flingNeutralizerCon = nil, nil
local detectedPlayers = {}

-- Humanoid setup for infinite jump
local infJump, infJumpConnection, landedConnection = false, nil, nil
local infJumps, infJumpDeb, infJumpOnlyTwo, landed = 0, false, false, true

local function setupHumanoid(humanoid)
    if landedConnection then landedConnection:Disconnect() end
    landedConnection = humanoid.StateChanged:Connect(function(_, n)
        if n == Enum.HumanoidStateType.Landed or n == Enum.HumanoidStateType.Running then
            landed = true
            infJumps = 0
        end
    end)
end

-- Raycast helper for CTRL+Click TP
local function getRayHitPosition()
    local mouse = LocalPlayer:GetMouse()
    if not mouse then return nil end
    local camera = workspace.CurrentCamera
    local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    return result and result.Position or nil
end


local universalTab = window:CreateTab({ name = "Universal", icon = 93364949241311 })

universalTab:CreateSection({ name = "About" })
universalTab:CreateText({ name = "Ravion Client", text = "Version 13.1 • Powered by Rayfield Gen2" })
universalTab:CreateText({ name = "Credits", text = "Based on YARHM by Aetherion" })
universalTab:CreateButton({
    name = "Join our Discord",
    callback = function()
        if setclipboard then setclipboard("https://discord.gg/2jbYxvDkxr") end
        window:Notify({ title = "Discord", content = "Link copied to clipboard!" })
    end,
})

universalTab:CreateSection({ name = "Fly" })
universalTab:CreateToggle({
    name = "OP Fly", flag = "FlyEnabled",
    callback = function(state)
        if state then flyutility:Start(LocalPlayer.Character) else flyutility:Stop(LocalPlayer.Character) end
    end,
})
universalTab:CreateSlider({
    name = "Fly Speed", range = { 50, 350 }, increment = 10, value = 50, flag = "FlySpeed",
    callback = function(v) flyutility:SetMaxSpeed(v) end,
})

universalTab:CreateSection({ name = "Jumping" })
universalTab:CreateToggle({
    name = "Infinite Jump", flag = "InfJump",
    callback = function(state)
        infJump = state
        if state then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildWhichIsA("Humanoid") then
                setupHumanoid(char:FindFirstChildWhichIsA("Humanoid"))
            end
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
                if not humanoid then return end
                if infJumpOnlyTwo and infJumps >= 2 and not landed then return end
                if not infJumpDeb then
                    infJumpDeb = true
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    infJumps += 1
                    landed = false
                    task.wait(.1)
                    infJumpDeb = false
                end
            end)
        else
            if infJumpConnection then infJumpConnection:Disconnect() end
            if landedConnection then landedConnection:Disconnect() end
            infJumps, landed = 0, true
        end
    end,
})
universalTab:CreateToggle({
    name = "Limit Infinite Jump to 2", flag = "InfJumpLimit",
    callback = function(state) infJumpOnlyTwo = state; infJumps = 0 end,
})

universalTab:CreateSection({ name = "Hitbox" })
local hitboxExp = 1
local aggressiveExp = false
local loopHitboxCon = nil
universalTab:CreateInput({
    name = "Hitbox Expander", placeholder = "Size (1 = normal)",
    callback = function(text)
        hitboxExp = tonumber(text) or 1
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
                local sizeArg = tonumber(text)
                if aggressiveExp then
                    for _, part in ipairs(v.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Size = (not sizeArg or sizeArg == 1) and Vector3.new(2,1,1) or Vector3.new(sizeArg,sizeArg,sizeArg)
                            part.Transparency = 0.2
                        end
                    end
                else
                    local root = v.Character:FindFirstChild('HumanoidRootPart')
                    if root and root:IsA("BasePart") then
                        root.Size = (not sizeArg or sizeArg == 1) and Vector3.new(2,1,1) or Vector3.new(sizeArg,sizeArg,sizeArg)
                        root.Transparency = 0.2
                        root.CanCollide = false
                    end
                end
            end
        end
        window:Notify({ title = "Hitbox", content = "Hitboxes expanded." })
    end,
})
universalTab:CreateToggle({
    name = "Loop Hitbox Expansion", flag = "LoopHitbox",
    callback = function(state)
        if state then
            loopHitboxCon = RunService.Heartbeat:Connect(function()
                for _, v in ipairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
                        local sizeArg = tonumber(hitboxExp)
                        local size = (not sizeArg or sizeArg == 1) and Vector3.new(2,1,1) or Vector3.new(sizeArg,sizeArg,sizeArg)
                        if aggressiveExp then
                            for _, part in ipairs(v.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Size = size
                                    part.Transparency = 0.2
                                end
                            end
                        else
                            local root = v.Character:FindFirstChild('HumanoidRootPart')
                            if root and root:IsA("BasePart") then
                                root.Size = size
                                root.Transparency = 0.2
                                root.CanCollide = false
                            end
                        end
                    end
                end
            end)
        elseif loopHitboxCon then
            loopHitboxCon:Disconnect()
            loopHitboxCon = nil
        end
    end,
})
universalTab:CreateToggle({
    name = "Aggressive Hitbox (All Parts)", flag = "AggressiveHitbox",
    callback = function(state) aggressiveExp = state end,
})

universalTab:CreateSection({ name = "Speed & View" })
universalTab:CreateInput({
    name = "Walkspeed", placeholder = "16",
    callback = function(text)
        local char = LocalPlayer.Character
        local hu = char and char:FindFirstChildOfClass("Humanoid")
        if not hu then return end
        hu.WalkSpeed = tonumber(text) or 16
        ws = tonumber(text) or 16
        window:Notify({ title = "Walkspeed", content = "Set to " .. hu.WalkSpeed })
    end,
})
universalTab:CreateButton({
    name = "Increase Walkspeed",
    callback = function()
        local hu = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hu then return end
        ws = ws + wsIncrement
        hu.WalkSpeed = hu.WalkSpeed + wsIncrement
        window:Notify({ title = "Walkspeed", content = "Now " .. hu.WalkSpeed })
    end,
})
universalTab:CreateButton({
    name = "Decrease Walkspeed",
    callback = function()
        local hu = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hu then return end
        ws = ws - wsIncrement
        hu.WalkSpeed = hu.WalkSpeed - wsIncrement
        window:Notify({ title = "Walkspeed", content = "Now " .. hu.WalkSpeed })
    end,
})
universalTab:CreateInput({
    name = "Walkspeed Increment", placeholder = "2",
    callback = function(text)
        wsIncrement = tonumber(text) or 2
    end,
})
universalTab:CreateInput({
    name = "Field of View", placeholder = "70",
    callback = function(text)
        local v = tonumber(text) or 70
        TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { FieldOfView = v }):Play()
        fov = v
    end,
})
universalTab:CreateToggle({
    name = "Loop Walkspeed & FOV", flag = "LoopWSFOV",
    callback = function(state) loopFovWs = state end,
})

RunService.RenderStepped:Connect(function()
    if loopFovWs then
        workspace.CurrentCamera.FieldOfView = fov
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = ws
        end
    end
end)

universalTab:CreateSection({ name = "Teleports" })
universalTab:CreateToggle({
    name = "CTRL+Click Teleport", flag = "CtrlClickTP",
    callback = function(state) ctrlClickTP = state end,
})
universalTab:CreateInput({
    name = "Teleport to Player", placeholder = "Player name",
    callback = function(text)
        local targetName = getPlayer(text, LocalPlayer)
        if not targetName then
            window:Notify({ title = "Teleport", content = "Player not found." }); return
        end
        local tp = Players:FindFirstChild(targetName)
        if not (tp and tp.Character) then return end
        local targetHrp = tp.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return end
        local lh = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if lh then lh.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 5, 0)) end
    end,
})
universalTab:CreateButton({
    name = "Spectate Players",
    callback = function()
        local listplayers = Players:GetPlayers()
        if #listplayers == 0 then return end
        local i = 1
        local cur = listplayers[i]
        if not (cur and cur.Character and cur.Character:FindFirstChildOfClass("Humanoid")) then return end
        workspace.CurrentCamera.CameraSubject = cur.Character:FindFirstChildOfClass("Humanoid")
        local loop
        loop = task.spawn(function()
            while true do
                local subj = workspace.CurrentCamera.CameraSubject
                dialog("Spectating", "Now spectating: " .. (subj and subj.Parent and subj.Parent.Name or "?"), {"Previous", "Stop", "Next"})
                local action = waitfordialog()
                if action == "Stop" then
                    local myH = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    workspace.CurrentCamera.CameraSubject = myH
                    task.cancel(loop); break
                elseif action == "Next" then
                    i = i + 1; if i > #listplayers then i = 1 end
                elseif action == "Previous" then
                    i = i - 1; if i < 1 then i = #listplayers end
                end
                cur = listplayers[i]
                if cur and cur.Character and cur.Character:FindFirstChildOfClass("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = cur.Character:FindFirstChildOfClass("Humanoid")
                end
            end
        end)
    end,
})

UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if ctrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    and inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = getRayHitPosition()
        if not pos then
            window:Notify({ title = "Teleport", content = "Couldn't find a place to teleport to." }); return
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(pos) end
    end
end)

universalTab:CreateSection({ name = "Aim Lock" })
universalTab:CreateInput({
    name = "Aim Lock Target", placeholder = "Player name",
    callback = function(text)
        local name = getPlayer(text, LocalPlayer)
        if not name or not Players:FindFirstChild(name) then
            window:Notify({ title = "Aim Lock", content = "Player not found." }); return
        end
        aimTarget = Players:FindFirstChild(name)
        window:Notify({ title = "Aim Lock", content = "Target set to " .. aimTarget.Name })
    end,
})
universalTab:CreateButton({
    name = "Aim Lock On",
    callback = function()
        if aimlockConn then aimlockConn:Disconnect() end
        if not aimTarget then
            window:Notify({ title = "Aim Lock", content = "Set a target first." }); return
        end
        aimlockConn = RunService.RenderStepped:Connect(function()
            if not aimTarget then return end
            local hrp = aimTarget.Character and aimTarget.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, hrp.Position)
        end)
        window:Notify({ title = "Aim Lock", content = "Aim lock is now on." })
    end,
})
universalTab:CreateButton({
    name = "Aim Lock Off",
    callback = function()
        if aimlockConn then aimlockConn:Disconnect(); aimlockConn = nil end
        window:Notify({ title = "Aim Lock", content = "Aim lock is now off." })
    end,
})

universalTab:CreateSection({ name = "Fling" })
universalTab:CreateInput({
    name = "Target Fling Player", placeholder = "Player name",
    callback = function(text)
        local name = getPlayer(text, LocalPlayer)
        if not name or not Players:FindFirstChild(name) then
            window:Notify({ title = "Fling", content = "Player not found." }); return
        end
        playerToFling = Players:FindFirstChild(name)
        window:Notify({ title = "Fling", content = "Target set to " .. playerToFling.Name })
    end,
})
universalTab:CreateButton({
    name = "Fling Target",
    callback = function()
        if not playerToFling or not Players:FindFirstChild(playerToFling.Name) then
            window:Notify({ title = "Fling", content = "Target a player first." }); return
        end
        if antiFling then
            window:Notify({ title = "Fling", content = "Turn off anti-fling to use fling." }); return
        end
        miniFling(playerToFling)
    end,
})
universalTab:CreateToggle({
    name = "Anti-Fling", flag = "AntiFling",
    callback = function(state)
        antiFling = state
        if state then
            window:Notify({ title = "Anti-Fling", content = "Activated." })
            flingDetectionCon = RunService.Heartbeat:Connect(function()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl.Character and pl.Character:IsDescendantOf(workspace) and pl.Character.PrimaryPart then
                        if pl.Character.PrimaryPart.AssemblyAngularVelocity.Magnitude > 50
                        or pl.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                            if not detectedPlayers[pl.Name] then
                                window:Notify({ title = "Anti-Fling", content = "Flinger detected: " .. pl.Name })
                                detectedPlayers[pl.Name] = true
                            end
                            for _, p in ipairs(pl.Character:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.CanCollide = false
                                    p.AssemblyAngularVelocity = Vector3.zero
                                    p.AssemblyLinearVelocity = Vector3.zero
                                    p.CustomPhysicalProperties = PhysicalProperties.new(0,0,0)
                                end
                            end
                        end
                    end
                end
            end)
            flingNeutralizerCon = RunService.Heartbeat:Connect(function()
                local pp = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                if pp then
                    if pp.AssemblyLinearVelocity.Magnitude > 250 or pp.AssemblyAngularVelocity.Magnitude > 250 then
                        window:Notify({ title = "Anti-Fling", content = "You were flung - neutralizing." })
                        pp.AssemblyLinearVelocity = Vector3.zero
                        pp.AssemblyAngularVelocity = Vector3.zero
                        if antiFlingLastPos ~= Vector3.zero then
                            pp.CFrame = CFrame.new(antiFlingLastPos)
                        end
                    else
                        antiFlingLastPos = pp.Position
                    end
                end
            end)
        else
            if flingDetectionCon then flingDetectionCon:Disconnect() end
            if flingNeutralizerCon then flingNeutralizerCon:Disconnect() end
            detectedPlayers = {}
            window:Notify({ title = "Anti-Fling", content = "Deactivated." })
        end
    end,
})

universalTab:CreateSection({ name = "Miscellaneous" })
universalTab:CreateButton({
    name = "Anti-AFK Detection",
    callback = function()
        local pl = LocalPlayer
        if getconnections then
            for _, c in pairs(getconnections(pl.Idled)) do
                if c.Disable then c:Disable() elseif c.Disconnect then c:Disconnect() end
            end
        else
            pl.Idled:Connect(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
        end
    end,
})
universalTab:CreateButton({ name = "Hide Menu", callback = function() window:Hide() end })
universalTab:CreateButton({
    name = "FPS Boost",
    callback = function()
        dialog("FPS Boosting", "FPS boosting can have unpredictable effects. Continue?", {"FPS boost anyway", "Nevermind"})
        if waitfordialog() == "FPS boost anyway" then
            local Terrain = workspace:FindFirstChildOfClass('Terrain')
            if Terrain then
                Terrain.WaterWaveSize, Terrain.WaterWaveSpeed = 0, 0
                Terrain.WaterReflectance, Terrain.WaterTransparency = 0, 0
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            pcall(function() settings().Rendering.QualityLevel = 1 end)
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart")
                or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    v.Material = "Plastic"; v.Reflectance = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Explosion") then
                    v.BlastPressure, v.BlastRadius = 1, 1
                end
            end
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
                or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect")
                or v:IsA("DepthOfFieldEffect") then
                    v.Enabled = false
                end
            end
        end
    end,
})
universalTab:CreateButton({
    name = "Noclip",
    callback = function()
        if noclipLoop then noclipLoop:Disconnect() end
        noclipLoop = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, child in pairs(char:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
                end
            end
        end)
    end,
})
universalTab:CreateButton({
    name = "Reclip",
    callback = function()
        if noclipLoop then noclipLoop:Disconnect(); noclipLoop = nil end
        window:Notify({ title = "Reclip", content = "You may need to reset your character." })
    end,
})
universalTab:CreateButton({
    name = "Get Ping",
    callback = function()
        window:Notify({ title = "Ping", content = math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms" })
    end,
})
universalTab:CreateButton({
    name = "Open Developer Console",
    callback = function()
        game.StarterGui:SetCore("DevConsoleVisible", true)
    end,
})


local mm2Tab = window:CreateTab({ name = "Murder Mystery 2", icon = 80387863064905 })

local mm2EspParent = (gethui and gethui()) or game:GetService("CoreGui")
local mm2Esp       = espind.new({ ArrowEdgePadding = 50, ArrowShowDistanceText = false, Parent = mm2EspParent })

local playerESP       = false
local gunDropESP      = false
local trapDetection   = false
local hideMeEsp       = false
local autoGetDroppedGun = false
local gunDropTakeExp  = false
local instakillshoot  = false
local spawnAtPlayer   = false
local loopThrow       = false
local shootOffset     = 2.8
local offsetToPingMult = 1
local playerData      = {}
local simulateKnifeThrow = false

-- Try to hook MM2 remotes (silently fail if not in MM2)
if game.ReplicatedStorage:FindFirstChild("Remotes") then
    local remotes = game.ReplicatedStorage.Remotes
    if remotes:FindFirstChild("Gameplay") then
        local pdc = remotes.Gameplay:FindFirstChild("PlayerDataChanged")
        if pdc then
            pdc.OnClientEvent:Connect(function(data)
                playerData = data
                if playerESP then
                    mm2Esp:RemoveGroup("players")
                    -- Re-add via reloadESP if defined
                end
            end)
        end
    end
end

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Knife") then return i end
    end
    if playerData then
        for player, data in pairs(playerData) do
            if data.Role == "Murderer" and Players:FindFirstChild(player) then
                return Players:FindFirstChild(player)
            end
        end
    end
    return nil
end

local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Gun") then return i end
    end
    if playerData then
        for player, data in pairs(playerData) do
            if data.Role == "Sheriff" and Players:FindFirstChild(player) then
                return Players:FindFirstChild(player)
            end
        end
    end
    return nil
end

local function findSheriffThatsNotMe()
    for _, i in ipairs(Players:GetPlayers()) do
        if i == LocalPlayer then continue end
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i == LocalPlayer then continue end
        if not i.Character then continue end
        if i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

local function reloadMM2ESP()
    if not playerESP then return end
    mm2Esp:RemoveGroup("players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer and hideMeEsp then continue end
        if player.Character then
            if player == findMurderer() then
                mm2Esp:Add(player.Character, { AccentColor = Color3.new(1,0,0.0157), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Murderer", ShowLabel = true, GroupName = "players" })
            elseif player == findSheriff() then
                mm2Esp:Add(player.Character, { AccentColor = Color3.new(0,0.6,1), ArrowShow = false, ShowLabel = false, GroupName = "players" })
            else
                mm2Esp:Add(player.Character, { AccentColor = Color3.new(0,1,0.0314), ArrowShow = false, ShowLabel = false, GroupName = "players" })
            end
        end
    end
end

local function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
    end
    return nil
end

local function getPredictedPosition(player, offset)
    local char = player.Character
    if not char then return Vector3.new(0,0,0) end
    local upper = char:FindFirstChild("UpperTorso")
    local hum   = char:FindFirstChild("Humanoid")
    if not upper or not hum then return Vector3.new(0,0,0) end
    local velocity = upper.AssemblyLinearVelocity
    local moveDir = hum.MoveDirection
    local predicted = upper.Position + (velocity * Vector3.new(0.75, 0.5, 0.75)) * (offset / 15) + moveDir * offset
    predicted = predicted * ((LocalPlayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01) + 1)
    return predicted
end

mm2Tab:CreateSection({ name = "ESPs" })
mm2Tab:CreateToggle({
    name = "Player ESP", flag = "MM2_PlayerESP",
    callback = function(state)
        playerESP = state
        if state then
            if not findMurderer() or not findSheriff() then
                window:Notify({ title = "ESP", content = "Waiting for roles..." })
            end
            reloadMM2ESP()
        else
            mm2Esp:RemoveGroup("players")
        end
    end,
})
mm2Tab:CreateToggle({
    name = "Dropped Gun ESP", flag = "MM2_GunESP",
    callback = function(state)
        gunDropESP = state
        if state then
            local map = getMap()
            if map and map:FindFirstChild("GunDrop") then
                mm2Esp:Add(map:FindFirstChild("GunDrop"), { AccentColor = Color3.new(0.9529,1,0.0745), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Dropped gun!", ShowLabel = true, GroupName = "gun" })
            end
        else
            mm2Esp:RemoveGroup("gun")
        end
    end,
})
mm2Tab:CreateToggle({
    name = "Trap ESP", flag = "MM2_TrapESP",
    callback = function(state)
        trapDetection = state
        if state then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "Trap" and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
                    v.Transparency = 0
                    mm2Esp:Add(v, { AccentColor = Color3.new(1,0,0), ArrowShow = false, ShowLabel = true, LabelText = "Trap", GroupName = "trap" })
                end
            end
        else
            mm2Esp:RemoveGroup("trap")
        end
    end,
})
mm2Tab:CreateToggle({
    name = "Hide My Own ESP", flag = "MM2_HideMe",
    callback = function(state) hideMeEsp = state; reloadMM2ESP() end,
})

mm2Tab:CreateSection({ name = "Tools" })
mm2Tab:CreateButton({
    name = "Shoot Murderer",
    callback = function()
        if findSheriff() ~= LocalPlayer then
            window:Notify({ title = "Shoot", content = "You're not sheriff/hero." }); return
        end
        local murderer = findMurderer() or findSheriffThatsNotMe()
        if not murderer then
            window:Notify({ title = "Shoot", content = "No target." }); return
        end
        local char = LocalPlayer.Character
        if not char then return end
        if not char:FindFirstChild("Gun") then
            local hum = char:FindFirstChild("Humanoid")
            if LocalPlayer.Backpack:FindFirstChild("Gun") then
                hum:EquipTool(LocalPlayer.Backpack:FindFirstChild("Gun"))
            else
                window:Notify({ title = "Shoot", content = "No gun." }); return
            end
        end
        local hrp = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            window:Notify({ title = "Shoot", content = "No HRP." }); return
        end
        local predicted = getPredictedPosition(murderer, shootOffset)
        local args
        if instakillshoot then
            args = { CFrame.new(hrp.Position + Vector3.new(0,1,0)), CFrame.new(hrp.Position) }
        else
            args = { CFrame.new(char.RightHand.Position), CFrame.new(predicted) }
        end
        char:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
    end,
})
mm2Tab:CreateButton({
    name = "Knife Throw to Closest",
    callback = function()
        if findMurderer() ~= LocalPlayer then
            window:Notify({ title = "Knife", content = "You're not murderer." }); return
        end
        local char = LocalPlayer.Character
        if not char then return end
        if not char:FindFirstChild("Knife") then
            local hum = char:FindFirstChild("Humanoid")
            if LocalPlayer.Backpack:FindFirstChild("Knife") then
                hum:EquipTool(LocalPlayer.Backpack:FindFirstChild("Knife"))
            else
                window:Notify({ title = "Knife", content = "No knife." }); return
            end
        end
        -- Find nearest player
        local nearest, shortest = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local lhrp = char:FindFirstChild("HumanoidRootPart")
                local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                if lhrp and ohrp then
                    local d = (lhrp.Position - ohrp.Position).Magnitude
                    if d < shortest then shortest = d; nearest = p end
                end
            end
        end
        if not (nearest and nearest.Character) then
            window:Notify({ title = "Knife", content = "No target." }); return
        end
        local nhrp = nearest.Character:FindFirstChild("HumanoidRootPart")
        if not nhrp then return end
        local args = { CFrame.new(char.RightHand.Position), CFrame.new(getPredictedPosition(nearest, shootOffset + 1)) }
        if spawnAtPlayer then args[1] = CFrame.new(nhrp.Position + (nhrp.CFrame.LookVector * 5)) end
        char:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args))
    end,
})
mm2Tab:CreateToggle({
    name = "Auto Knife Throw", flag = "MM2_AutoKnife",
    callback = function(state) loopThrow = state end,
})
task.spawn(function()
    while task.wait(1.5) do
        if loopThrow and findMurderer() == LocalPlayer then
            -- reuse the same logic silently; simplified
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Knife") then
                local nhrp
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        nhrp = p.Character.HumanoidRootPart; break
                    end
                end
                if nhrp then
                    local args = { CFrame.new(char.RightHand.Position), CFrame.new(getPredictedPosition(nhrp.Parent ~= nil and Players:GetPlayerFromCharacter(nhrp.Parent) or nil, shootOffset)) }
                    pcall(function()
                        char.Knife.Events.KnifeThrown:FireServer(unpack(args))
                    end)
                end
            end
        end
    end
end)
mm2Tab:CreateButton({
    name = "Delayed Shoot Murderer",
    callback = function()
        if findSheriff() ~= LocalPlayer then
            window:Notify({ title = "Shoot", content = "You're not sheriff." }); return
        end
        local murderer = findMurderer() or findSheriffThatsNotMe()
        if not murderer then
            window:Notify({ title = "Shoot", content = "No target." }); return
        end
        local char = LocalPlayer.Character
        if not char then return end
        if not char:FindFirstChild("Gun") then
            local hum = char:FindFirstChild("Humanoid")
            if LocalPlayer.Backpack:FindFirstChild("Gun") then hum:EquipTool(LocalPlayer.Backpack:FindFirstChild("Gun")) end
        end
        RunService.Stepped:Connect(function()
            local hrp = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
            local myhrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and myhrp and char:FindFirstChild("Gun") then
                local origin = myhrp.Position
                local dir = (Vector3.new(hrp.Position.X, origin.Y, hrp.Position.Z) - origin).Unit * 1000
                local result = workspace:Raycast(origin, dir)
                if result and result.Instance == hrp then
                    local predicted = getPredictedPosition(murderer, shootOffset)
                    char.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, predicted, "AH2")
                end
            end
        end)
    end,
})
mm2Tab:CreateInput({
    name = "Shoot Offset", placeholder = "2.8",
    callback = function(text) shootOffset = tonumber(text) or 2.8 end,
})
mm2Tab:CreateInput({
    name = "Offset-to-Ping Multiplier", placeholder = "1",
    callback = function(text) offsetToPingMult = tonumber(text) or 1 end,
})

mm2Tab:CreateSection({ name = "Fun" })
mm2Tab:CreateButton({
    name = "God Mode (Unstable)",
    callback = function()
        local Cam = workspace.CurrentCamera
        local Pos, Char = Cam.CFrame, LocalPlayer.Character
        local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
        if not Human then return end
        local nHuman = Human:Clone()
        nHuman.Parent, LocalPlayer.Character = Char, nil
        nHuman:SetStateEnabled(15, false)
        nHuman:SetStateEnabled(1, false)
        nHuman:SetStateEnabled(0, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()
        LocalPlayer.Character = Char
        Cam.CameraSubject = nHuman
        Cam.CFrame = Pos
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local animate = Char:FindFirstChild("Animate")
        if animate then animate.Disabled = true; task.wait(); animate.Disabled = false end
        nHuman.Health = nHuman.MaxHealth
    end,
})
mm2Tab:CreateButton({
    name = "Kill Everyone (Murderer)",
    callback = function()
        if findMurderer() ~= LocalPlayer then
            window:Notify({ title = "Kill All", content = "You're not murderer." }); return
        end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Knife") then
            window:Notify({ title = "Kill All", content = "No knife equipped." }); return
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + char.HumanoidRootPart.CFrame.LookVector * 1
            end
        end
        char.Knife.Stab:FireServer("Slash")
    end,
})
mm2Tab:CreateButton({
    name = "Hold Everyone Hostage",
    callback = function()
        if findMurderer() ~= LocalPlayer then
            window:Notify({ title = "Hostage", content = "You're not murderer." }); return
        end
        local char = LocalPlayer.Character
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Anchored = true
                p.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + char.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
        window:Notify({ title = "Hostage", content = "All players held in place." })
    end,
})
mm2Tab:CreateButton({
    name = "Teleport to Lobby",
    callback = function()
        local lobby = workspace:FindFirstChild("Lobby")
        local char = LocalPlayer.Character
        local spawnLoc = lobby and lobby:FindFirstChild("Spawns") and lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation")
        if char and spawnLoc then char:MoveTo(spawnLoc.Position) end
    end,
})
mm2Tab:CreateButton({
    name = "Teleport to Map",
    callback = function()
        local map = getMap()
        if not map then return end
        local spawns = map:FindFirstChild("Spawns")
        if spawns then
            local list = spawns:GetChildren()
            local char = LocalPlayer.Character
            if char and #list > 0 then
                char:MoveTo(list[math.random(1, #list)].Position)
            end
        end
    end,
})
mm2Tab:CreateButton({
    name = "Fling Sheriff",
    callback = function()
        local s = findSheriff()
        if s then miniFling(s) else window:Notify({ title = "Fling", content = "No sheriff." }) end
    end,
})
mm2Tab:CreateButton({
    name = "Fling Murderer",
    callback = function()
        local m = findMurderer()
        if m then miniFling(m) else window:Notify({ title = "Fling", content = "No murderer." }) end
    end,
})
mm2Tab:CreateButton({
    name = "Copy Murderer Username",
    callback = function()
        local m = findMurderer()
        if m and setclipboard then setclipboard(m.Name); window:Notify({ title = "Copy", content = "Copied " .. m.Name }) end
    end,
})
mm2Tab:CreateButton({
    name = "Copy Sheriff Username",
    callback = function()
        local s = findSheriff()
        if s and setclipboard then setclipboard(s.Name); window:Notify({ title = "Copy", content = "Copied " .. s.Name }) end
    end,
})
mm2Tab:CreateToggle({
    name = "Auto Get Dropped Gun", flag = "MM2_AutoGun",
    callback = function(state) autoGetDroppedGun = state end,
})
mm2Tab:CreateToggle({
    name = "Experimental Gun Take", flag = "MM2_ExpGun",
    callback = function(state) gunDropTakeExp = state end,
})
mm2Tab:CreateButton({
    name = "Send Roles to Chat",
    callback = function()
        local textchannels = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
        local m = findMurderer() or {}
        local s = findSheriff() or {}
        for _, tc in ipairs(textchannels) do
            if tc.Name ~= "RBXSystem" then
                local mName = m.Name or "-"
                local sName = s.Name or "-"
                pcall(function()
                    tc:SendAsync(string.format("Murderer: %s | Sheriff: %s | <<Ravion>>", mName, sName))
                end)
            end
        end
    end,
})


if game.GameId == 372226183 then
    local ftfTab = window:CreateTab({ name = "Flee the Facility" })
    local ftfEspParent = (gethui and gethui()) or game:GetService("CoreGui")
    local ftfEsp = espind.new({ ArrowEdgePadding = 50, ArrowShowDistanceText = false, Parent = ftfEspParent })
    local ftfPlayers, ftfPCs, ftfPods, ftfExits, ftfLockers, ftfHideArrows = false, false, false, false, false, false
    local wslock, ftfWs = false, 18

    local function getBeast()
        for _, player in ipairs(Players:GetPlayers()) do
            local c = player.Character
            if c and c:FindFirstChild("BeastPowers") then return player end
        end
    end

    local function reloadFTFESP()
        ftfEsp:ClearAllGroups()
        if ftfPlayers then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if player == getBeast() then
                        ftfEsp:Add(player.Character, { AccentColor = Color3.new(1,0,0), ArrowShow = not ftfHideArrows, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Beast", ShowLabel = not ftfHideArrows, GroupName = "players" })
                    else
                        ftfEsp:Add(player.Character, { AccentColor = Color3.new(0,1,0), ArrowShow = false, ShowLabel = false, GroupName = "players" })
                    end
                end
            end
        end
        if ftfPCs then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "ComputerTable" then
                    if obj.Screen and obj.Screen.Color == Color3.fromRGB(40, 127, 71) then
                        ftfEsp:Add(obj, { AccentColor = Color3.new(0.13,0.33,0.0078), ArrowShow = false, ArrowShowDistanceText = false, ShowLabel = false, GroupName = "pcs" })
                    else
                        ftfEsp:Add(obj, { AccentColor = Color3.new(0,0.37,1), ArrowShow = not ftfHideArrows, ArrowMinDistance = 99999, ArrowShowDistanceText = false, ArrowSize = UDim2.new(0,10,0,10), ShowLabel = false, GroupName = "pcs" })
                    end
                end
            end
        end
        if ftfPods then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "FreezePod" then
                    ftfEsp:Add(obj, { AccentColor = Color3.new(0,1,1), ArrowShow = false, ShowLabel = false, GroupName = "pods" })
                end
            end
        end
        if ftfExits then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "ExitDoor" then
                    ftfEsp:Add(obj, { AccentColor = Color3.new(1,1,0), ArrowShow = false, ShowLabel = false, GroupName = "exits" })
                end
            end
        end
        if ftfLockers then
            for _, obj in ipairs(game:GetService("CollectionService"):GetTagged("LOCKER")) do
                ftfEsp:Add(obj, { AccentColor = Color3.new(1,0.0549,0.6235), ArrowShow = false, ShowLabel = false, GroupName = "lockers" })
            end
        end
    end

    ftfTab:CreateSection({ name = "ESPs" })
    ftfTab:CreateToggle({ name = "Players", flag = "FTF_Players", callback = function(s) ftfPlayers = s; reloadFTFESP() end })
    ftfTab:CreateToggle({ name = "PCs",     flag = "FTF_PCs",     callback = function(s) ftfPCs = s;     reloadFTFESP() end })
    ftfTab:CreateToggle({ name = "Pods",    flag = "FTF_Pods",    callback = function(s) ftfPods = s;    reloadFTFESP() end })
    ftfTab:CreateToggle({ name = "Exits",   flag = "FTF_Exits",   callback = function(s) ftfExits = s;   reloadFTFESP() end })
    ftfTab:CreateToggle({ name = "Lockers", flag = "FTF_Lockers", callback = function(s) ftfLockers = s; reloadFTFESP() end })
    ftfTab:CreateToggle({ name = "Hide Arrows & Labels", flag = "FTF_HideArrows", callback = function(s) ftfHideArrows = s; reloadFTFESP() end })

    ftfTab:CreateSection({ name = "Tools" })
    ftfTab:CreateButton({
        name = "Third Person Camera",
        callback = function()
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 400
            window:Notify({ title = "Camera", content = "Third-person unlocked." })
        end,
    })
    ftfTab:CreateButton({ name = "Reload ESP", callback = reloadFTFESP })
    ftfTab:CreateButton({
        name = "Flashlight",
        callback = function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local existing = hrp:FindFirstChildOfClass("PointLight")
            if existing then existing:Destroy() return end
            local light = Instance.new("PointLight", hrp)
            light.Brightness = 2.5
            light.Range = 999999
        end,
    })

    RunService.Heartbeat:Connect(function()
        if wslock then
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = ftfWs end
        end
    end)

    ftfTab:CreateInput({
        name = "Locked Walkspeed", placeholder = "18",
        callback = function(text)
            ftfWs = tonumber(text) or 18
            wslock = true
        end,
    })
    ftfTab:CreateButton({ name = "Unlock Walkspeed", callback = function() wslock = false end })
end


if game.GameId == 6331902150 then
    local forsakenTab = window:CreateTab({ name = "Forsaken" })
    local forsakenEspParent = (gethui and gethui()) or game:GetService("CoreGui")
    local forsakenEsp = espind.new({ ArrowEdgePadding = 50, ArrowShowDistanceText = true, Parent = forsakenEspParent })

    local fsPlayers, fsItems, fsGenerators = false, false, false
    local prioritizeMedkit, infiniteStamina, noCooldownSolve = false, false, false

    local function addForsakenPlayer(p)
        forsakenEsp:Add(p, { AccentColor = Color3.new(0.149,1,0), ArrowShow = false, ShowLabel = false, GroupName = "players" })
    end
    local function addForsakenKiller(k)
        forsakenEsp:Add(k, { AccentColor = Color3.new(1,0,0), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Killer", ShowLabel = true, GroupName = "players" })
    end
    local function addForsakenItem(i)
        local cfg = { AccentColor = Color3.new(0.031,0.917,1), ArrowShow = false, ShowLabel = false, GroupName = "items" }
        if prioritizeMedkit and i.Name == "Medkit" then
            window:Notify({ title = "Forsaken", content = "Medkit spawned!" })
            cfg = { AccentColor = Color3.new(1,1,1), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Medkit", ShowLabel = true, GroupName = "items" }
        end
        forsakenEsp:Add(i, cfg)
    end
    local function addForsakenGenerator(g)
        local prog = g:FindFirstChild("Progress")
        local pv = prog and prog.Value or 0
        local label = tostring(math.floor(pv)) .. "%"
        local show = pv < 100
        local color = pv >= 100 and Color3.new(0,0.5,0) or Color3.new(0.984,1,0)
        forsakenEsp:Add(g, { AccentColor = color, ArrowShow = show, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,20,0,20), ShowLabel = show, LabelText = label, GroupName = "generators" })
    end

    forsakenTab:CreateSection({ name = "ESPs" })
    forsakenTab:CreateToggle({
        name = "Players", flag = "FS_Players",
        callback = function(s)
            fsPlayers = s
            if s then
                local surv = workspace.Players and workspace.Players:FindFirstChild("Survivors")
                local killers = workspace.Players and workspace.Players:FindFirstChild("Killers")
                if surv then for _, p in ipairs(surv:GetChildren()) do addForsakenPlayer(p) end end
                if killers then
                    local k = killers:GetChildren()[1]
                    if k then addForsakenKiller(k) end
                end
            else
                forsakenEsp:RemoveGroup("players")
            end
        end,
    })
    forsakenTab:CreateToggle({
        name = "Items", flag = "FS_Items",
        callback = function(s)
            fsItems = s
            if s then
                local ingame = workspace.Map and workspace.Map:FindFirstChild("Ingame")
                if ingame then
                    for _, i in ipairs(ingame:GetChildren()) do
                        if i.Name ~= "Map" then addForsakenItem(i) end
                    end
                end
            else
                forsakenEsp:RemoveGroup("items")
            end
        end,
    })
    forsakenTab:CreateToggle({
        name = "Generators", flag = "FS_Generators",
        callback = function(s)
            fsGenerators = s
            if s then
                local ingame = workspace.Map and workspace.Map:FindFirstChild("Ingame")
                local map = ingame and ingame:FindFirstChild("Map")
                if map then
                    for _, g in ipairs(map:GetChildren()) do
                        if g.Name == "Generator" then addForsakenGenerator(g) end
                    end
                end
            else
                forsakenEsp:RemoveGroup("generators")
            end
        end,
    })
    forsakenTab:CreateToggle({
        name = "Prioritize Medkit", flag = "FS_Medkit",
        callback = function(s) prioritizeMedkit = s end,
    })

    forsakenTab:CreateSection({ name = "Tools" })
    local solveCD = false
    forsakenTab:CreateButton({
        name = "Finish Nearest Generator",
        callback = function()
            if solveCD and not noCooldownSolve then
                window:Notify({ title = "Forsaken", content = "Cooldown (4s)" }); return
            end
            solveCD = true
            local char = LocalPlayer.Character
            if not char or not char.PrimaryPart then return end
            local ingame = workspace.Map and workspace.Map:FindFirstChild("Ingame")
            local map = ingame and ingame:FindFirstChild("Map")
            if not map then return end
            local closest, shortest = nil, math.huge
            for _, obj in ipairs(map:GetChildren()) do
                if obj.Name == "Generator" and obj:IsA("Model") and obj.PrimaryPart then
                    local d = (char.PrimaryPart.Position - obj.PrimaryPart.Position).Magnitude
                    if d < shortest then shortest = d; closest = obj end
                end
            end
            if closest and closest:FindFirstChild("Remotes") then
                closest.Remotes.RE:FireServer()
            end
            task.wait(4)
            solveCD = false
        end,
    })
    forsakenTab:CreateToggle({
        name = "Bypass Solver Cooldown", flag = "FS_BypassCD",
        callback = function(s) noCooldownSolve = s end,
    })
    forsakenTab:CreateToggle({
        name = "Infinite Stamina", flag = "FS_InfStamina",
        callback = function(s)
            infiniteStamina = s
            if not s then
                pcall(function()
                    require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting).StaminaLossDisabled = false
                end)
            end
        end,
    })
    task.spawn(function()
        while task.wait(1) do
            if infiniteStamina then
                pcall(function()
                    require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting).StaminaLossDisabled = true
                end)
            end
        end
    end)
    forsakenTab:CreateInput({
        name = "Sprint Speed", placeholder = "26 (default)",
        callback = function(text)
            pcall(function()
                require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting).SprintSpeed = tonumber(text) or 26
            end)
        end,
    })
    forsakenTab:CreateInput({
        name = "Stamina Gain Rate", placeholder = "20 (default)",
        callback = function(text)
            pcall(function()
                require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting).StaminaGain = tonumber(text) or 20
            end)
        end,
    })
end

window:Notify({
    title = "Ravion Client v13.1",
    content = "Loaded successfully. Use the tabs on the left to browse features.",
    duration = 6,
})