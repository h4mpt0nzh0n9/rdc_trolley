
-- Trolley Entity Experiment

local trolleyModel = 'trolley01x'
local pedModel = 's_m_m_genconductor_01'

-- DE-BUG
local USE_PACIFIC_UNION_LIVERY = true
local trainDatas = {
    ['TROLLEY_STDENIS'] = {
        ['RED_LOOP'] = {
            ENTITY_ID = nil,
            NETWORK_ID = nil,
            DIRECTION = false,
            SPAWN_COORD = {
                x = 2496.828125,
                y = -1195.184326,
                z = 49.294476          
            },
            TRACK = -1716490906
        },
        ['BLUE_LOOP'] = {
            ENTITY_ID = nil,
            NETWORK_ID = nil,
            DIRECTION = true,
            SPAWN_COORD = {
                x = 2758.990967,
                y = -1371.182739,
                z = 46.512714          
            },
            TRACK = -1739625337
        }
    }
}

local function addBlipForTrain(entity)
    local Blip = BlipAddForEntity(joaat('BLIP_STYLE_TRAIN'), entity)
    SetBlipName(Blip, '轨道电车')
end

local function initMissionTrain()

    local hash = joaat(trolleyModel)
    RequestModel(hash, true)
    while not HasModelLoaded(hash) do
        Wait(100)
    end

    local data = trainDatas['TROLLEY_STDENIS']
    for _, v in pairs(data) do
        v.ENTITY_ID =
            CreateMissionTrain(joaat('trolley_config'),
                v.SPAWN_COORD.x, v.SPAWN_COORD.y, v.SPAWN_COORD.z, v.DIRECTION, true, false, true)
        NetworkRegisterEntityAsNetworked(v.ENTITY_ID)
        SetTrainStopsForStations(v.ENTITY_ID, true)
        v.NETWORK_ID = NetworkGetNetworkIdFromEntity(v.ENTITY_ID)
        SetNetworkIdExistsOnAllMachines(v.NETWORK_ID, true)
        --
        local ped = joaat('PLACEHOLDER_PED')
        repeat
            ped = GetPedInVehicleSeat(v.ENTITY_ID, -1)
            Wait(100)
        until GetEntityModel(ped) == joaat(pedModel)

        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        --

        addBlipForTrain(v.ENTITY_ID)
        if USE_PACIFIC_UNION_LIVERY then SetVehicleLivery(v.ENTITY_ID, 1) end

    end
    Wait(200)
    TriggerServerEvent('rdc_npc:Server:storeTrainDatas', 'TROLLEY_STDENIS', data)

    --
end
RegisterCommand('trainevent', initMissionTrain, false)

local function scriptRoute(route, passedStation)

    if passedStation == 3 then
        if route == 'BLUE_LOOP'  then
            SetTrainTrackJunctionSwitch(-1739625337, 10, false)
        elseif route == 'RED_LOOP' then
            SetTrainTrackJunctionSwitch(-1739625337, 10, true)
        end
    elseif passedStation == 7 then
        local rand = math.random(2)
        if rand == 1 then
            SetTrainTrackJunctionSwitch(-1739625337, 0, true)
        elseif rand == 2 then
            SetTrainTrackJunctionSwitch(-1739625337, 0, false)
        end
    end
end

CreateThread(function()

    local spawnedCount, data = 0, trainDatas['TROLLEY_STDENIS']
    --
    while true do
        if spawnedCount ~= 2 then
            for _, v in pairs(data) do
                if v.NETWORK_ID == nil then goto INVALID_NETWORK_ID end
                --
                v.ENTITY_ID = NetworkGetEntityFromNetworkId(v.NETWORK_ID)
                if DoesEntityExist(v.ENTITY_ID) then
                    NetworkRequestControlOfEntity(v.ENTITY_ID)
                    --
                    addBlipForTrain(v.ENTITY_ID)
                    spawnedCount += 1
                end
            end
        end
        --
        for k, v in pairs(data) do
            local passedStation = GetCurrentStationForTrain(v.ENTITY_ID)
            scriptRoute(k, passedStation)
        end
        --
        ::INVALID_NETWORK_ID::
        Wait(3000)
    end
end)

RegisterNetEvent('rdc_npc:Client:onTrainRequestHandled', function(resultData)

    if resultData.KEY == 'TROLLEY_STDENIS' then
        if resultData.MESSAGE ~= 'VALIDATION_PASSED' then
            initMissionTrain()
        else
            local data = trainDatas[resultData.KEY]
            for k, v in pairs(resultData.NETWORK_ID) do
                data[k].NETWORK_ID = v
            end
        end
    end
    print(json.encode(resultData))
end)

CreateThread(function()

    local isLoggedIn = false
    repeat
        isLoggedIn = LocalPlayer.state.isLoggedIn
        Wait(1000)
    until isLoggedIn == true
    --
    TriggerServerEvent('rdc_npc:Server:requestTrain', 'TROLLEY_STDENIS')
end)

local function deleteTrain()

    local data = trainDatas['TROLLEY_STDENIS']
    for _, v in pairs(data) do
        if v.ENTITY_ID ~= nil then
            if DoesEntityExist(v.ENTITY_ID) then
                DeleteEntity(v.ENTITY_ID)
            end
        end
    end
end

RegisterCommand('deletetrain', deleteTrain, false)

AddEventHandler('onResourceStop', function(resourceName)

    if GetCurrentResourceName() ~= resourceName then return end
    --
    deleteTrain()
    --
end)







-- CreateThread(function()

--     local spawnedCount = 0
--     while true do
--         if spawnedCount ~= 2 then
--             for _, v in pairs(trainDatas) do
--                 if v.NETWORK_ID == nil then goto continue end
--                 v.ENTITY_ID = NetworkGetEntityFromNetworkId(v.NETWORK_ID)
--                 if DoesEntityExist(v.ENTITY_ID) then spawnedCount += 1 end
--             end
--             ::continue::
--         end

--         for k, v in pairs(trainDatas) do
--             local passedStation = GetCurrentStationForTrain(v.ENTITY_ID)
--             scriptRoute(k, passedStation)
--         end
--         Wait(3000)
--     end
-- end)



-- local function initMissionTrain()

--     local hash = joaat(trolleyModel)
--     RequestModel(hash, true)
--     while not HasModelLoaded(hash) do
--         Wait(100)
--     end

--     for k, v in pairs(trainDatas) do

--         v.ENTITY_ID =
--             CreateMissionTrain(joaat('trolley_config'),
--                 v.SPAWN_COORD.x, v.SPAWN_COORD.y, v.SPAWN_COORD.z, v.DIRECTION, true, false, true)
--         NetworkRegisterEntityAsNetworked(v.ENTITY_ID)
--         SetTrainStopsForStations(v.ENTITY_ID, true)
--         v.NETWORK_ID = NetworkGetNetworkIdFromEntity(v.ENTITY_ID)
--         SetNetworkIdExistsOnAllMachines(v.NETWORK_ID, true)

--         if USE_PACIFIC_UNION_LIVERY then SetVehicleLivery(v.ENTITY_ID, 1) end

--         local Blip = BlipAddForEntity(joaat('BLIP_STYLE_TRAIN'), v.ENTITY_ID)
--         -- if k == 'RED_LOOP' then BlipAddModifier(Blip, joaat('BLIP_MODIFIER_MP_COLOR_2'))
--         -- else BlipAddModifier(Blip, joaat('BLIP_MODIFIER_MP_COLOR_1')) end
--         SetBlipName(Blip, '轨道电车')

--         local message = string.format('CLIENT TRAIN SPAWNED: ENEITY = %d | NETWORKID = %d | OWNER = %d', v.ENTITY_ID, v.NETWORK_ID, NetworkGetEntityOwner(v.ENTITY_ID))
--         print(message)

--         TriggerServerEvent('rdc_npc:Server:storeTrainDatas', trainDatas[k], 'trolley')
--     end

--     for k, v in pairs(trainDatas) do
--         Wait(500) -- WAIT FOR MS, SPAWNING DRIVER NEEDS TIME.
--         local ped = GetPedInVehicleSeat(v.ENTITY_ID, -1)
--         SetEntityAsMissionEntity(ped, true, true) -- SET IT AS MISSION ENTITY THAT TOLD ENGINE NOT TO DELETE THIS.
--         SetEntityInvincible(ped, true) -- SET IT INVINCIBLE
--     end

--     -- TriggerServerEvent('rdc_npc:Server:storeTrainDatas', trainDatas, 'trolley')
-- end

-- RegisterCommand('trainevent', initMissionTrain, false) -- TEST SPAWN

-- local function scriptRoute(route, passedStation) -- ONLY FOR TROLLEY IN ST.DENIS

--     if passedStation == 3 then
--         if route == 'BLUE_LOOP_' .. SPECIFIC_TAG  then
--             SetTrainTrackJunctionSwitch(-1739625337, 10, false)
--         elseif route == 'RED_LOOP_' .. SPECIFIC_TAG then
--             SetTrainTrackJunctionSwitch(-1739625337, 10, true)
--         end
--     elseif passedStation == 7 then
--         local rand = math.random(2)
--         if rand == 1 then
--             SetTrainTrackJunctionSwitch(-1739625337, 0, true)
--         elseif rand == 2 then
--             SetTrainTrackJunctionSwitch(-1739625337, 0, false)
--         end
--     end
-- end

-- CreateThread(function()

--     local spawnedCount = 0
--     while true do
--         if spawnedCount ~= 2 then
--             for _, v in pairs(trainDatas) do
--                 if v.NETWORK_ID == nil then goto continue end
--                 v.ENTITY_ID = NetworkGetEntityFromNetworkId(v.NETWORK_ID)
--                 if DoesEntityExist(v.ENTITY_ID) then spawnedCount += 1 end
--             end
--             ::continue::
--         end

--         for k, v in pairs(trainDatas) do
--             local passedStation = GetCurrentStationForTrain(v.ENTITY_ID)
--             scriptRoute(k, passedStation)
--         end
--         Wait(3000)
--     end
-- end)


-- RegisterNetEvent('rdc_npc:Client:onTrainRequestHandled')

-- AddEventHandler('rdc_npc:Client:onTrainRequestHandled', function(resultDatas)
--     if resultDatas.track == 'TROLLEY' then
--         if not resultDatas.message == 'VALIDATION_PASSED' then
--             initMissionTrain()
--         else
--             for k, v in pairs(resultDatas.networkId) do
--                 trainDatas[k].NETWORK_ID = v
--                 local entity = NetworkGetEntityFromNetworkId(v)
--                 print(entity)
--             end
--         end
--     end
-- end)

        
-- RegisterCommand('drawroute', function()

--     if USE_DEBUG then
--         DEBUG_TRAIN_TRACK_JUNCTION = {}
--         for i = 0, 40 do
--             local juncCoord = Citizen.InvokeNative(0x785639D89F8451AB, -1739625337, i, Citizen.ResultAsVector())
--             if juncCoord == nil then return end

--             table.insert(DEBUG_TRAIN_TRACK_JUNCTION, {
--                 idx = i,
--                 x = juncCoord.x, y = juncCoord.y, z = juncCoord.z + 1
--             })
--         end
--     end
-- end, false)

-- local function drawText3d(x, y, z, text, colour, bgalpha)
--     local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
--     if not onScreen then return end

--     local scale = 0.7
--     SetTextScale(0.0, 0.5 * scale)
--     if type(colour) == 'table' then
--         if #(colour) == 4 then
--             SetTextColor(colour[1], colour[2], colour[3], colour[4])
--         elseif #(colour) == 3 then
--             SetTextColor(colour[1], colour[2], colour[3], 255)
--         else
--             SetTextColor(255, 255, 255, 255)
--         end
--     end
--     SetTextDropshadow(2, 0, 0, 0, 255)

--     local lineCount = select(2, string.gsub(text, "~n~", "")) + 1
--     local textLength = #text - (bgalpha ~= 0 and 3 or 0)
--     local textWidth  = (0.005 * textLength / lineCount * scale) + (0.01 * scale)
--     local textHeight = 0.03 * lineCount * scale
--     local offsetY    = _y + textHeight / 2.2

--     DrawRect(_x, offsetY, textWidth, textHeight, 0, 0, 0, bgalpha)

--     Citizen.InvokeNative(0xADA9255D, 0)
--     Citizen.InvokeNative(0xBE5261939FBECB8C, true)
--     Citizen.InvokeNative(0xd79334a4bb99bad1,
--         Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", text, Citizen.ResultAsLong()), _x, _y)
-- end

-- CreateThread(function()

--     while true do
--         if DEBUG_DRAW_ROUTE then

--             if #DEBUG_TRAIN_TRACK_JUNCTION == 0 then
--                 Wait(1000)
--             end

--             for k, v in ipairs(DEBUG_TRAIN_TRACK_JUNCTION) do
--                 local nextCoord = k + 1
--                 if k == #DEBUG_TRAIN_TRACK_JUNCTION then nextCoord = 1 end

--                 DrawLine(v.x, v.y, v.z,
--                     DEBUG_TRAIN_TRACK_JUNCTION[nextCoord].x, DEBUG_TRAIN_TRACK_JUNCTION[nextCoord].y, DEBUG_TRAIN_TRACK_JUNCTION[nextCoord].z,
--                         0, 255, 0, 255)
--                 local message = string.format('JUNC INDEX: %d', v.idx)
--                 drawText3d(v.x, v.y, v.z, message, {255, 255, 255}, 1.0)
--             end
--         end
--         Wait(1)
--     end
-- end)


