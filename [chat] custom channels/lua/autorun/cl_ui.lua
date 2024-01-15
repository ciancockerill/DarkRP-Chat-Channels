chatChannels = chatChannels or {}

local openedPage = nil

function chatChannels.loadChannels()
    net.Start("CCDataRequest")
    net.SendToServer()

    net.Receive("ChatTableToClient", function()
        local chatChannelsLoaded = net.ReadTable()
        chatChannels.chatCommands = chatChannelsLoaded
    end)
end 

function chatChannels.CreateCfgUI()

    local screenWidth, screenHeight = ScrW(), ScrH()
    
    local Frame = vgui.Create("DFrame") -- Creates Parent Frame ("background")
    Frame:SetSize(screenWidth / 2, screenHeight / 1.2)
    Frame:SetTitle("")
    Frame:SetVisible(true) 
    Frame:SetDraggable(true) 
    Frame:ShowCloseButton(true) 
    Frame:MakePopup()
    Frame:Center()

    local titleLabel = vgui.Create("DLabel", Frame)
    titleLabel:SetText("Chat Channels CFG")
    titleLabel:SetFont("rem_100")
    titleLabel:SetSize(titleLabel:GetTextSize())
    titleLabel:SetPos(Frame:GetWide() / 2 - titleLabel:GetWide() / 2, Frame:GetTall() * 0.05)

    local dividerY = Frame:GetTall() / 5
    local chatSelW = Frame:GetWide() / 4    
    
    local chatSelBar = vgui.Create("DListView", Frame)
    chatSelBar:SetPos(0, dividerY)
    chatSelBar:SetSize(chatSelW, Frame:GetTall() - dividerY)
    chatSelBar:SetMultiSelect(false)
    chatSelBar:AddColumn("Channels")
    chatSelBar:SetDataHeight(screenWidth * 0.0125)
    chatSelBar:SetHideHeaders(true)

    local storedData = {}
    local storedKeys = {}

    for key, chatC in pairs(chatChannels.chatCommands) do
        table.insert(storedKeys, key)
        table.insert(storedData, chatC)

        local row = chatSelBar:AddLine(chatC.prefix)

        row.Paint = function(self, w, h)
            surface.SetDrawColor(chatC.color)
            surface.DrawRect(0,0,w,h)
        end

    end

    if (IsValid(chatSelBar:GetLine(1))) then  -- Select and open first chat channel if it exists
        chatSelBar:SelectFirstItem() 
        chatChannels.CreateCfgSettingPage(Frame, screenWidth, screenHeight, storedData[1], storedKeys[1] ) 
    end

    chatSelBar.OnRowSelected = function(panel, rowIndex, row)
        chatChannels.CreateCfgSettingPage(Frame, screenWidth, screenHeight, storedData[rowIndex], storedKeys[rowIndex])
    end

    Frame.OnClose = function()
    end 

end

function chatChannels.CreateCfgSettingPage(parent, screenWidth, screenHeight, data, cmd, oldName)
    if !openedPage == nil then openedPage:Close() end -- if a page already opened close it and open new one just selected.

    local padding = screenHeight * 0.01

    local settingPanel = vgui.Create("DPanel", parent)
    settingPanel:SetSize(parent:GetWide() * 0.75, parent:GetTall() * 0.8)
    settingPanel:SetPos(parent:GetWide() / 4, parent:GetTall() / 5)

    -- Top Labels
    local labelY = padding * 1

    local prefixLabel = vgui.Create("DLabel", settingPanel)
    prefixLabel:SetPos(padding * 15, labelY)
    prefixLabel:SetTextColor(Color(0,0,0))
    prefixLabel:SetText("Prefix")
    prefixLabel:SetFont("rem_25")
    prefixLabel:SetSize(prefixLabel:GetTextSize())

    local cmdLabel = vgui.Create("DLabel", settingPanel)
    cmdLabel:SetPos(settingPanel:GetWide() - padding * 21.5, labelY)
    cmdLabel:SetTextColor(Color(0,0,0))
    cmdLabel:SetText("Command")
    cmdLabel:SetFont("rem_25")
    cmdLabel:SetSize(cmdLabel:GetTextSize())

    -- Text Entry
    local entryY = labelY + padding * 2.5

    local prefixEntry = vgui.Create("DTextEntry", settingPanel)
    prefixEntry:SetSize(padding * 15, padding * 2)
    prefixEntry:SetPos(prefixLabel:GetX() - padding * 5.5, entryY)
    prefixEntry:SetText(data.prefix)

    local cmdEntry = vgui.Create("DTextEntry", settingPanel)
    cmdEntry:SetSize(padding * 7.5, padding * 2)
    cmdEntry:SetPos(cmdLabel:GetX() + padding / 2, entryY)
    cmdEntry:SetText(cmd)

    -- Job Label
    local jobLabel = vgui.Create("DLabel", settingPanel)
    jobLabel:SetFont("rem_25")
    jobLabel:SetText("Job Selection")
    jobLabel:SetTextColor(Color(0,0,0))
    jobLabel:SetSize(jobLabel:GetTextSize())
    jobLabel:SetPos(settingPanel:GetWide() / 2 - jobLabel:GetWide() / 2, cmdEntry:GetY() + padding * 3)

    -- Job DList
    local jobDList = vgui.Create("DListView", settingPanel)
    jobDList:SetSize(settingPanel:GetWide() / 2, settingPanel:GetTall() / 2)
    jobDList:SetPos(settingPanel:GetWide() / 2 - jobDList:GetWide() / 2, jobLabel:GetY() + padding * 3)
    jobDList:AddColumn("DarkRP Jobs")
    jobDList:SetHideHeaders(true)
    jobDList:SetMultiSelect(false)
    jobDList:SetDataHeight(padding * 2)

    local channelCol = jobDList:AddColumn("In Channel?")
    channelCol:SetFixedWidth(padding * 10)

    for _, job in pairs(RPExtraTeams) do -- Adds all jobs to the list & if they're currently enabled in channel
        local line = jobDList:AddLine(job.name, " ")

        local checkbox = vgui.Create("DCheckBox", line)
        checkbox:SetValue(table.HasValue(data.jobs, string.lower(job.name)))
        checkbox:SetPos(jobDList:GetWide() - channelCol:GetWide() / 2 - checkbox:GetWide() / 2, line:GetTall() / 2 - checkbox:GetTall() / 2)
    end

    -- Color Label
    local colorLabel = vgui.Create("DLabel", settingPanel)
    colorLabel:SetFont("rem_25")
    colorLabel:SetText("Colour Selection")
    colorLabel:SetTextColor(Color(0,0,0))
    colorLabel:SetSize(colorLabel:GetTextSize())
    colorLabel:SetPos(settingPanel:GetWide() / 2 - colorLabel:GetWide() / 2, jobDList:GetY() + jobDList:GetTall() + padding * 1.5)

    -- Color List
    local colorList = vgui.Create("DColorMixer", settingPanel)
    colorList:SetSize(settingPanel:GetWide() / 1.5, settingPanel:GetTall() / 6)
    colorList:SetPos(settingPanel:GetWide() / 2 - colorList:GetWide() / 2, colorLabel:GetY() + colorLabel:GetTall() + padding)
    colorList:SetColor(data.color)
    colorList:SetAlphaBar(false)

    -- Save Button
    local saveButton = vgui.Create("DButton", settingPanel)
    saveButton:SetText("Save")
    saveButton:SetSize(padding * 10, padding * 3.5)
    saveButton:SetPos(settingPanel:GetWide() / 2 - saveButton:GetWide() / 2, colorList:GetY() + colorList:GetTall() + padding * 3)
    saveButton:SetPaintBackground(true)
    saveButton:SetTextColor(Color(0,0,0))
    saveButton:SetFont("rem_20")

    saveButton.DoClick = function()

        local prefixData = prefixEntry:GetText()
        local keyCommand = cmdEntry:GetText()
        local jobsData = {}

        for _, line in pairs(jobDList:GetLines()) do -- Checkbox is the 2nd Child of DTextEntry Line. If Ticked (true) then add the job name to job table.
            if line:GetChild(2):GetChecked() then
                table.insert(jobsData, string.lower(line:GetValue(1)))
            end
        end 

        local colorData = colorList:GetColor()

        local saveData = {
            jobs = jobsData,
            prefix = prefixData,
            color = colorData
            }

        net.Start("ChatTableToServer")
            net.WriteTable(saveData)
            net.WriteString(cmd)
            net.WriteString(keyCommand)
        net.SendToServer()

        chatChannels.loadChannels()
        parent:Close()

    end 
end

net.Receive("OpenChatConfig", function() -- Opens GUI on client from Server request
    chatChannels.loadChannels()
    chatChannels.CreateCfgUI()
end)


