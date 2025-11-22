local logger = require '@qbx_core.modules.logger'
local bucket = {}

local function resetRoutingBucket(source)
    SetPlayerRoutingBucket(source, 0)
    if bucket[source].vehicle and bucket[source].vehicle ~= 0 then
        DeleteEntity(bucket[source].vehicle)
    end
    if DeleteEntity(bucket[source].npc) and bucket[source].npc ~= 0 then
        DeleteEntity(bucket[source].npc)
    end
    bucket[source] = nil
end

lib.callback.register('flex_professions:server:setRoutingBucket', function(source, data)
    if bucket[source] then return false end
    local sourceBucket = GetPlayerRoutingBucket(source)
    if not sourceBucket then return end
    local newBucket = sourceBucket+source

    bucket[source] = {
        bucket = sourceBucket,
        npc = nil,
        vehicle = nil,
    }

    SetPlayerRoutingBucket(source, newBucket)

    local ped = GetPlayerPed(source)
    if not ped then return end

    local vehicleType = exports.qbx_core:GetVehiclesByHash(joaat(data.vehicle)).type
    local veh = CreateVehicleServerSetter(data.vehicle, vehicleType, data.start.x, data.start.y, data.start.z, data.start.w)
    while not DoesEntityExist(veh) do Wait(0) end

    if not veh then return false end
    bucket[source].vehicle = veh
    if newBucket and newBucket > 0 then
        SetEntityRoutingBucket(veh, newBucket)
    end

    local npc = CreatePed(4, joaat(data.ped), data.start.x, data.start.y, data.start.z-2, data.start.w, false, true)

    if not npc then
        resetRoutingBucket(source)
        return false
    end
    SetPedIntoVehicle(npc, veh, -1)
    bucket[source].npc = npc
    if newBucket and newBucket > 0 then
        SetEntityRoutingBucket(npc, newBucket)
    end

    SetPedIntoVehicle(ped, veh, 0)

    return NetworkGetNetworkIdFromEntity(veh), NetworkGetNetworkIdFromEntity(npc), data
end)

RegisterNetEvent('flex_professions:server:Apply', function(data)
    if not data or not data.jobData then return end
    local src = source
    if not SV_Config.Webhooks[data.jobData.job] then return print('setup webhook for: '..data.jobData.job) end
    local discord = SV_Config.Webhooks[data.jobData.job]
    if discord.hook == "YOUR_WEBHOOK_URL_HERE" then return print('setup webhook for: '..data.jobData.job) end
    local player = GetPlayer(src)
    logger.log({
        source = src,
        event = locale('discord.event', ((player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or data.name)) .. ' ('..player.PlayerData.citizenid or 'N/A'..')',
        message = locale('discord.message', (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or data.name, data.birth, data.why, data.fit, exports.zdiscord:getName(src), player.PlayerData.charinfo.phone or "N/A"),
        webhook = discord.hook,
        color = discord.color,
        tags = {discord.role},
    })
end)

RegisterNetEvent('flex_professions:server:resetRoutingBucket', function(jobData)
    local src = source
    local ped = GetPlayerPed(src)
    if not ped then return end
    if #(GetEntityCoords(ped) - vec3(jobData.travel.finish.x, jobData.travel.finish.y, jobData.travel.finish.z)) < 8.0 then
        local professions = GetProfessions(src)
        if professions then
            for _, v in pairs(professions) do
                if v == jobData.job then
                    return
                end
            end
        end
        if professions then
            professions[jobData.job] = true 
            SetProfessions(src, professions)
        end

        local jobs = GetJobs()
        if jobs[jobData.job] and not jobData.application then
            SetJob(src, jobData.job, 0)
        end
        
        local rewards = jobData.rewards
        if rewards then
            for k, v in pairs(rewards) do
                if Config.MoneyTypes[k] then
                    AddMoney(src, k, v[1])
                elseif k:lower() == 'vehicle' then
                    giveVehicle(src, v)
                    Config.Notify.server(src, locale('success.gotVehicle'), "success", 3000)
                else
                    AddItem(src, k, v.amount or 1, v.info or nil, nil)
                end
            end
        end
    end
    resetRoutingBucket(src)
end)

local function HasProfession(source, profession)
    local src = source
    local professions = GetProfessions(src)
    if professions then
        for _, v in pairs(professions) do
            if v == profession then
                return true
            end
        end
    end
    return false
end
exports('HasProfession', HasProfession)

lib.callback.register('flex_professions:server:HasProfession', function(source, profession)
    local src = source
    local professions = GetProfessions(src)
    if professions then
        for _, v in pairs(professions) do
            if v == profession then
                return true
            end
        end
    end
    return false
end)

lib.callback.register('flex_professions:server:HasAnyProfessionFromList', function(source, list)
    local src = source
    local professions = GetProfessions(src)
    if professions then
        for k, _ in pairs(professions) do
            for _, v in pairs(Config.Professions[list].jobs) do
                if k == v.job then
                    return true
                end
            end
        end
    end
    return false
end)

local function AddProfession(source, profession)
    local src = source
    local professions = GetProfessions(src)
    if professions then
        for _, v in pairs(professions) do
            if v == profession then
                return false
            end
        end
    end
    if professions then
        professions[profession] = true 
        SetProfessions(src, professions)
        return true
    end
    return false
end
exports('AddProfession', AddProfession)

local function RemoveProfession(source, profession)
    local src = source
    local professions = GetProfessions(src)
    if professions and type(professions) == "table" then
        if professions[profession] then
            professions[profession] = nil
            SetProfessions(src, professions)
            return true
        end
    end
    return false
end
exports('RemoveProfession', RemoveProfession)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for playerId, data in pairs(bucket) do
            SetPlayerRoutingBucket(playerId, 0)
            if data.vehicle and DoesEntityExist(data.vehicle) then
                DeleteEntity(data.vehicle)
            end
            if data.npc and DoesEntityExist(data.npc) then
                DeleteEntity(data.npc)
            end
            bucket[playerId] = nil
        end
    end
end)

lib.addCommand('addprof', {
	help = 'Add a profession to a player',
	params = {
		{ name = 'id', help = 'Citizenid or id', optional = false },
        { name = 'profession', help = 'Profession to add', optional = false },
	},
	restricted = 'group.admin',
}, function(source, args)
    local src = source
    if not args.id or not args.profession then
        return Config.Notify.server(src, locale('error.invalid_syntax'), "error", 3000)
    end
    local player = GetPlayerByCitizenId(args.id)
    if not player then
        player = GetPlayer(tonumber(args.id))
    end
    if not player then
        return Config.Notify.server(src, locale('error.player_not_found'), "error", 3000)
    end
	if AddProfession(player.PlayerData.source, args.profession) then
        return Config.Notify.server(src, locale('success.add_profession', args.profession), "success", 3000)
    else
        return Config.Notify.server(src, locale('error.add_profession_failed', args.profession), "error", 3000)
    end
end)

lib.addCommand('removeprof', {
	help = 'Remove a profession from a player',
	params = {
		{ name = 'id', help = 'Citizenid or id', optional = false },
        { name = 'profession', help = 'Profession to remove', optional = false },
	},
	restricted = 'group.admin',
}, function(source, args)
    local src = source
    if not args.id or not args.profession then
        return Config.Notify.server(src, locale('error.invalid_syntax'), "error", 3000)
    end
    local player = GetPlayerByCitizenId(args.id)
    if not player then
        player = GetPlayer(tonumber(args.id))
    end
    if not player then
        return Config.Notify.server(src, locale('error.player_not_found', args.profession), "error", 3000)
    end
	if RemoveProfession(player.PlayerData.source, args.profession) then
        return Config.Notify.server(src, locale('success.remove_profession', args.profession), "success", 3000)
    else
        return Config.Notify.server(src, locale('error.remove_profession_failed', args.profession), "error", 3000)
    end
end)

lib.addCommand('getprof', {
	help = 'Get all player professions',
	params = {
		{ name = 'id', help = 'Citizenid or id', optional = false },
	},
	restricted = 'group.admin',
}, function(source, args)
    local src = source
    if not args.id then
        return Config.Notify.server(src, locale('error.invalid_syntax'), "error", 3000)
    end
    local player = GetPlayerByCitizenId(args.id)
    if not player then
        player = GetPlayer(tonumber(args.id))
    end
    if not player then
        return Config.Notify.server(src, locale('error.player_not_found', args.profession), "error", 3000)
    end
	local professions = GetProfessions(player.PlayerData.source)
    if professions then
        local profList = ''
        if #professions > 1 then
            for k, v in pairs(professions) do
                profList = profList .. k .. ', '
            end
        else
            for k, v in pairs(professions) do
                profList = profList .. k
            end
        end
        return Config.Notify.server(src, locale('info.player_professions', profList), "info", 3000)
    else
        return Config.Notify.server(src, locale('info.player_no_professions'), "error", 3000)
    end
end)