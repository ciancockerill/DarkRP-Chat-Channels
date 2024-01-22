chatChannels = chatChannels or {}
chatChannels.chatCommands = chatChannels.chatCommands or {}

if SERVER then 
    local fileP = "chatchannel_stored.json"

    --[[    /////////////////////////////////////////////////////////////////////////////

               Networking

    ]]--    /////////////////////////////////////////////////////////////////////////////

    util.AddNetworkString("ChatTable_RequestEntries")
    util.AddNetworkString("ChatTable_OpenConfigUI")
    util.AddNetworkString("ChatTable_EntryToServer")
    util.AddNetworkString("ChatTable_EntryToClient")
    util.AddNetworkString("ChatTable_DeleteConfigEntry")

    -- Loading table data onto server & sending to client to load in UI.
    net.Receive("ChatTable_RequestEntries", function(len, ply)
        if !(chatChannels.verifyNetMessages(ply)) then return end

        local chatChannelsJSON = file.Read("chatchannel_stored.json")

        if (string.len(chatChannelsJSON) < 1) then 
            return
        end 

        local chatChannelsTable = util.JSONToTable(chatChannelsJSON)
        

        net.Start("ChatTable_EntryToClient")
            net.WriteTable(chatChannelsTable)
        net.Send(ply)
    
    end)

    -- Loading UI CFG from client to server, converting to JSON & writing to file for persistence.
    net.Receive("ChatTable_EntryToServer", function(len, ply)
        if !(chatChannels.verifyNetMessages(ply)) then return end

        local appendData = net.ReadTable()
        local appendKey = net.ReadString()
        local newKey = net.ReadString()

        local chatChannelsJSON = file.Read("chatchannel_stored.json")

        chatChannels.chatCommands = util.JSONToTable(chatChannelsJSON) or {}
    
        chatChannels.chatCommands[appendKey] = chatChannels.chatCommands[newKey]
        chatChannels.chatCommands[newKey] = appendData

        file.Write("chatchannel_stored.json", util.TableToJSON(chatChannels.chatCommands))
    end)

    -- Deleting table data from client to server 
    net.Receive("ChatTable_DeleteConfigEntry", function(len, ply)
        if !(chatChannels.verifyNetMessages(ply)) then return end

        local chatChannelsJSON = file.Read("chatchannel_stored.json")
        chatChannels.chatCommands = util.JSONToTable(chatChannelsJSON) or {}
    
        local key = net.ReadString()
        chatChannels.chatCommands[key] = nil 
    
        file.Write("chatchannel_stored.json", util.TableToJSON(chatChannels.chatCommands))
    end)
    

    --[[    /////////////////////////////////////////////////////////////////////////////

                Chat Functionality

    ]]--    /////////////////////////////////////////////////////////////////////////////

    local function IsJobInCommand(ply, command)
        local jobTable = RPExtraTeams[ply:Team()]

        if not jobTable then return false end

        local jobName = jobTable.name
        local jobList = chatChannels.chatCommands[command].jobs
        
        return table.HasValue(jobList, string.lower(jobName))
    end

    hook.Add("PlayerSay", "job_chat_message", function(ply, text, teamChat)

        if (text == chatChannels.configCMD) then
            if (chatChannels.allowedUserGroups[ply:GetUserGroup()]) then
                net.Start("ChatTable_OpenConfigUI")
                net.Send(ply)
    
                return ""
            else 
                ply:ChatPrint("[Chat Channels] Config Can't be accessed by "..ply:GetUserGroup().."'s")

                return ""
            end
        end

        local cmd = text:match("^/(%S+)")
        if not cmd then return end

        cmd = cmd:lower()

        -- If chat command doesn't exist or players job isn't in command, chat sends nothing to 
        if (not chatChannels.chatCommands[cmd]) or (not IsJobInCommand(ply, cmd)) then 
            return ""
        end

        local message = text:sub(#cmd + 2) 
        local nameColor = team.GetColor(ply:Team())

        -- Prevents blank message spam
        if message == "" then return end

        for _, player in ipairs(player.GetAll()) do
            if IsJobInCommand(player, cmd) then
                DarkRP.talkToPerson(player, nameColor, chatCommand.prefix.." "..player:Nick(), chatCommand.color, message, ply)
            end
        end

        return ""

    end)

    --[[    /////////////////////////////////////////////////////////////////////////////

                Server Functions

    ]]--    /////////////////////////////////////////////////////////////////////////////

    -- Validates Usergroup on server side & verifies if the file exists.
    function chatChannels.verifyNetMessages(ply)
        if !(chatChannels.allowedUserGroups[ply:GetUserGroup()]) then
            print("[Chat Channels] Player: ".. ply:GetName().." ("..ply:SteamID() .. ")".. " tried to alter Chat Channel Config")
            return false
        end

        if !(file.Exists(fileP, "DATA")) then
            file.Write("chatchannel_stored.json", "")
            print("[Chat Channels] Load File Unavailable, Corrupted or this is your first time loading it - Data File Created.")
    
            return false
        end

        return true
    end

end 

if CLIENT then
    
    for i = 1, 100 do
        surface.CreateFont("rem_"..i, {
            font = "REM Regular",
            size = i,
        })
    end

    hook.Add("OnPlayerChat", "job_chat_message", function(ply, text, teamChat, isDead)

        for cmd, chatCommand in pairs(chatChannels.chatCommands) do
            local jobTable = RPExtraTeams[ply:getDarkRPVar("job")]

            if jobTable and table.HasValue(chatChannels.chatCommands.jobs, string.lower(jobTable.name or jobTable.Name)) then
                if not teamChat and text:sub(1, #chatCommand.prefix + 1) == "/" .. cmd then
                    chat.AddText(chatChannels.chatCommands.color, text)
                    return true 
                end
            end
            
        end
    end)
    
end

