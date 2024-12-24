local isESX = false
local isQB = false

if GetResourceState('es_extended') == 'started' then
    isESX = true
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    isQB = true
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent('zombies:giveLoot', function()
    local src = source
    local xPlayer = nil

    if not Config.EnableZombieLoot then
        return
    end

    if Config.Framework == 'ESX' and isESX then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'QBCORE' and isQB then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end

    if xPlayer then
        for _, lootData in ipairs(Config.ZombieLootItems) do
            local chance = math.random(100)
            if chance <= lootData.chance then
                local quantity = math.random(lootData.min, lootData.max)
                if quantity > 0 then
                    if Config.Framework == 'ESX' then
                        xPlayer.addInventoryItem(lootData.item, quantity)
                    elseif Config.Framework == 'QBCORE' then
                        xPlayer.Functions.AddItem(lootData.item, quantity)
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[lootData.item], 'add')
                    end
                end
            end
        end
    end
end)
