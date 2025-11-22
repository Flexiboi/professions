local function OpenProfessionMenu(list)
    local config = Config.Professions[list]
    if not config then return end
    lib.callback("flex_professions:server:HasAnyProfessionFromList", false, function(hasProfession)
        if not hasProfession or Config.InfiniteProfessions then
            if config.jobs then
                SendNUIMessage({
                    action = 'open',
                    canEscape = config.canEscape,
                    title = config.title,
                    desc = config.desc,
                    jobs = config.jobs,
                })
                SetNuiFocus(true, true)
            end
        end
    end, list)
end
exports("OpenProfessionMenu", OpenProfessionMenu)

RegisterNUICallback('select', function(data, cb)
    local jobData = data.jobData
    if jobData then
        if jobData.travel then
            lib.callback("flex_professions:server:setRoutingBucket", false, function(vehId, npcId, travel)
                if vehId and npcId and travel then
                    if #(GetEntityCoords(cache.ped) - vector3(travel.finish.x, travel.finish.y, travel.finish.z)) < 25.0 then
                        TriggerServerEvent("flex_professions:server:resetRoutingBucket", jobData)
                        return
                    end
                    if not vehId or vehId == 0 or not npcId or npcId == 0 or not travel then
                        return
                    end
                    local function waitForEntity(netId, entityType)
                        local startTime = GetGameTimer()
                        local maxWait = 10000 
                        local entity
                        
                        while GetGameTimer() - startTime < maxWait do
                            entity = NetworkGetEntityFromNetworkId(netId)
                            if entity and entity ~= 0 and DoesEntityExist(entity) then
                                return entity
                            end
                            if GetGameTimer() - startTime > 2000 then
                            end
                            Wait(500)
                        end
                        return nil
                    end
                    local veh = waitForEntity(vehId, "Vehicle")
                    local npc = waitForEntity(npcId, "NPC")
                    SetPedIntoVehicle(cache.ped, veh, 0)

                    Wait(math.random(1000, 2000))
                    TaskVehicleDriveToCoordLongrange(npc, veh, travel.finish.x, travel.finish.y, travel.finish.z, 15.0, 447, 5.0)
                    SetVehicleDoorsLocked(veh, 2)

                    CreateThread(function()
                        while DoesEntityExist(npc) do
                            local npcCoords = GetEntityCoords(npc)
                            local distance = #(npcCoords - vector3(travel.finish.x, travel.finish.y, travel.finish.z))
                            
                            if distance <= 5.0 then
                                Wait(math.random(350, 500))
                                TaskLeaveVehicle(cache.ped, veh, 0)
                                Wait(math.random(1000, 1500))
                                TriggerServerEvent("flex_professions:server:resetRoutingBucket", jobData)
                                break
                            end
                            
                            Wait(1000)
                        end
                    end)

                    CreateThread(function()
                        while DoesEntityExist(npc) do
                            local npcCoords = GetEntityCoords(npc)
                            local distance = #(npcCoords - vector3(travel.finish.x, travel.finish.y, travel.finish.z))
                            
                            if distance <= 5.0 then
                                break
                            end
                            
                            if IsPedInAnyVehicle(cache.ped, false) then
                                local currentVeh = GetVehiclePedIsIn(cache.ped, false)
                                SetVehicleDoorsLocked(currentVeh, 2)
                                DisableControlAction(0, 75, true)
                                DisableControlAction(0, 23, true)
                                DisableControlAction(0, 102, true)
                            end
                            Wait(10)
                        end

                        EnableControlAction(0, 75, true)
                        EnableControlAction(0, 23, true)
                        EnableControlAction(0, 102, true)
                    end)
                end
            end, jobData.travel)
        end
    end
end)

RegisterNUICallback('apply', function(data, cb)
    if data then
        TriggerServerEvent('flex_professions:server:Apply', data)
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false)
end)

RegisterCommand('profession', function(source, args)
    if args[1] then
        if Config.Professions[args[1]:lower()] then
            OpenProfessionMenu(args[1]:lower())
        end
    end
end)