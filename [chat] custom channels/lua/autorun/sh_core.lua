chatChannels = chatChannels or {}
chatChannels.chatCommands = chatChannels.chatCommands or {}

if SERVER then 

    --[[    /////////////////////////////////////////////////////////////////////////////

               Networking

    ]]--    /////////////////////////////////////////////////////////////////////////////

    util.AddNetworkString("CCDataRequest")
    util.AddNetworkString("OpenChatConfig")
    util.AddNetworkString("ChatTableToServer")
    util.AddNetworkString("ChatTableToClient")
    util.AddNetworkString("DeleteCCTable")

    -- Loading table data onto server & sending to client to load in UI.
    net.Receive("CCDataRequest", function(len, ply) 
        local chatChannelsJSON = file.Read("chatchannel_stored.json")
        local chatChannelsTable = util.JSONToTable(chatChannelsJSON)

        net.Start("ChatTableToClient")
            net.WriteTable(chatChannelsTable)
        net.Send(ply)
    
    end)

    -- Loading UI CFG from client to server, converting to JSON & writing to file for persistence.
    net.Receive("ChatTableToServer", function(len, ply)
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
    net.Receive("DeleteCCTable", function(len, ply)
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
         
        if (text == chatChannels.configCMD and chatChannels.allowedUserGroups[ply:GetUserGroup()]) then
            net.Start("OpenChatConfig")
            net.Send(ply)

            return ""

        elseif (text == chatChannels.configCMD and not chatChannels.allowedUserGroups[ply:GetUserGroup()]) then
            ply:ChatPrint("[Chat Channels] Config Can't be accessed by "..ply:GetUserGroup().."'s")
            return ""
        end 

        local cmd = text:match("^/(%S+)")
        if not cmd then return end

        cmd = cmd:lower()
        local chatCommand = chatChannels.chatCommands[cmd]
        if not chatCommand then return end

        if not IsJobInCommand(ply, cmd) then return "" end

        local message = text:sub(#cmd + 2) 
        local nameColor = team.GetColor(ply:Team())

        if message == "" then return end

        for _, player in ipairs(player.GetAll()) do
            if IsJobInCommand(player, cmd) then
                DarkRP.talkToPerson(player, nameColor, chatCommand.prefix.." "..player:Nick(), chatCommand.color, message, ply)
            end
        end
        return ""
    end)
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