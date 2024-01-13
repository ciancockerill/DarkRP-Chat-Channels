local chatCommands = {
    ["gun"] = {
        jobs = {
			"gun dealer",
			"hobo",
		},
        color = Color(63, 65, 105),
        prefix = "[GUN]",
    },
    ["med"] = {
        jobs = {
			"civil protection",
			"medic"
        },
        color = Color(182, 83, 83),
        prefix = "[Medic Helpline]",
    },
}

local function IsJobInCommand(ply, command)
    local jobTable = RPExtraTeams[ply:Team()]
    if not jobTable then return false end

    local jobName = jobTable.name
    local jobList = chatCommands[command].jobs
    
    return table.HasValue(jobList, string.lower(jobName))
end

hook.Add("PlayerSay", "job_chat_message", function(ply, text, teamChat)
    local cmd = text:match("^/(%S+)")
    if not cmd then return end

    cmd = cmd:lower()
    local chatCommand = chatCommands[cmd]
    if not chatCommand then return end

    if not IsJobInCommand(ply, cmd) then return "" end

    local message = text:sub(#cmd + 2) 
    local playerName = ply:Nick()
    local nameColor = team.GetColor(ply:Team())

	if message == "" then return end

    for _, player in ipairs(player.GetAll()) do
        if IsJobInCommand(player, cmd) then
            DarkRP.talkToPerson(player, nameColor, chatCommand.prefix .. " " .. playerName, chatCommand.color, message)
        end
    end
    return ""
end)

if CLIENT then
    hook.Add("OnPlayerChat", "job_chat_message", function(ply, text, teamChat, isDead)
        for cmd, chatCommand in pairs(chatCommands) do
            local jobTable = RPExtraTeams[ply:getDarkRPVar("job")]
            if jobTable and table.HasValue(chatCommand.jobs, string.lower(jobTable.name or jobTable.Name)) then
                if not teamChat and text:sub(1, #chatCommand.prefix + 1) == "/" .. cmd then
                    chat.AddText(chatCommand.color, text)
                    return true 
                end
            end
        end
    end)
end
