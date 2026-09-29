local trainDatas = {}

local function isValidEntity(netid)

    if netid == nil then return false end
    local entity = NetworkGetEntityFromNetworkId(netid)
    if entity ~= 0 then
        if GetNetTypeFromEntity(entity) == 14 then return true
        else return false end
    else return false end
end


RegisterNetEvent('rdc_npc:Server:storeTrainDatas', function(key, value)

    if value == nil or type(value) ~= 'table' then return end

    local data = trainDatas[key] or {}
    if string.find(key, "TROLLEY") then
        for k, v in pairs(value) do
            data[k] = {
                NETWORK_ID = v.NETWORK_ID,
                ENTITY_ID = NetworkGetEntityFromNetworkId(v.NETWORK_ID)
            }
        end
    end
    trainDatas[key] = data
    print(json.encode(trainDatas))
end)

RegisterNetEvent('rdc_npc:Server:requestTrain', function(key)

    local resultData = {
        MESSAGE = 'NO_TABLE',
        KEY = key,
        NETWORK_ID = {}
    }

    local data = trainDatas[key]
    if data == nil then
        TriggerClientEvent('rdc_npc:Client:onTrainRequestHandled',
            source, resultData)
        return
    end

    if key == 'TROLLEY_STDENIS' then
        local count = 0
        for k, v in pairs(data) do

            if not isValidEntity(v.NETWORK_ID) then
                resultData.MESSAGE = 'INVALID_NETWORK_ID'
                break
            end

            count += 1
            resultData.NETWORK_ID[k] = v.NETWORK_ID
        end

        if count == 2 then
            resultData.MESSAGE = 'VALIDATION_PASSED'
        end
    else
        if not isValidEntity(data.NETWORK_ID) then
            resultData.MESSAGE = 'INVALID_NETWORK_ID'
        else
            resultData.MESSAGE = 'VALIDATION_PASSED'
            table.insert(resultData.NETWORK_ID, data.NETWORK_ID)
        end
    end
    TriggerClientEvent('rdc_npc:Client:onTrainRequestHandled', source, resultData)
end)
