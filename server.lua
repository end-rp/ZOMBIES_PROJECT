local QBCore = exports['qb-core']:GetCoreObject()

local Corpses = {}

RegisterNetEvent('zombies:giveLoot', function(zombieTypeKey)
    local src = source
    if not Config.EnableZombieLoot then
        return
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Config.LootMode == "zombie" then
        local zTypeData = zombieTypeKey and Config.ZombieTypes[zombieTypeKey]
        if zTypeData and zTypeData.loot then
            for _, lootData in ipairs(zTypeData.loot) do
                local chance = math.random(100)
                if chance <= lootData.chance then
                    local quantity = math.random(lootData.min, lootData.max)
                    if quantity > 0 then
                        Player.Functions.AddItem(lootData.item, quantity)
                    end
                end
            end
        end
    else
        for _, lootData in ipairs(Config.ZombieLootItems) do
            local chance = math.random(100)
            if chance <= lootData.chance then
                local quantity = math.random(lootData.min, lootData.max)
                if quantity > 0 then
                    Player.Functions.AddItem(lootData.item, quantity)
                end
            end
        end
    end
end)

QBCore.Functions.CreateCallback('zombies:hasCureItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount > 0 then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateUseableItem('cureitem', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.RemoveItem('cureitem', 1)
        TriggerClientEvent("zombies:infectionCured", source)
        print(">> [Server] Cure item used by player " .. tostring(source) .. ". Cure event sent.")
    end
end)

RegisterNetEvent('zombies:cureInfection')
AddEventHandler('zombies:cureInfection', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cureItem = Config.Infection.cureItem
    local item = Player.Functions.GetItemByName(cureItem)

    if item and item.amount >= 1 then
        Player.Functions.RemoveItem(cureItem, 1)
        TriggerClientEvent("zombies:infectionCured", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have the cure item.', 'error')
    end
end)

RegisterNetEvent('zombies:registerCorpse')
AddEventHandler('zombies:registerCorpse', function(corpseID, coords, zTypeKey)
    if not Config.EnableZombieLoot then return end
    Corpses[corpseID] = {
        coords = coords,
        zTypeKey = zTypeKey,
        looted = false
    }
end)

RegisterNetEvent('zombies:tryLootCorpse')
AddEventHandler('zombies:tryLootCorpse', function(corpseID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Config.EnableZombieLoot then return end
    if not corpseID or not Corpses[corpseID] then
        print((">> [Loot] Player %d tried to loot an invalid corpseID."):format(src))
        return
    end

    local corpseData = Corpses[corpseID]
    if corpseData.looted then
        print((">> [Loot] Player %d tried to loot an already looted corpse."):format(src))
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local corpseCoords = vector3(corpseData.coords.x, corpseData.coords.y, corpseData.coords.z)
    local dist = #(pedCoords - corpseCoords)

    if dist > 2.0 then
        print((">> [Loot] Player %d is too far to loot (%.2f m)."):format(src, dist))
        return
    end

    local zTypeData = Config.ZombieTypes[corpseData.zTypeKey]
    if Config.LootMode == "zombie" and zTypeData and zTypeData.loot then
        for _, lootData in ipairs(zTypeData.loot) do
            local chance = math.random(100)
            if chance <= lootData.chance then
                local quantity = math.random(lootData.min, lootData.max)
                if quantity > 0 then
                    Player.Functions.AddItem(lootData.item, quantity)
                end
            end
        end
    else
        for _, lootData in ipairs(Config.ZombieLootItems) do
            local chance = math.random(100)
            if chance <= lootData.chance then
                local quantity = math.random(lootData.min, lootData.max)
                if quantity > 0 then
                    Player.Functions.AddItem(lootData.item, quantity)
                end
            end
        end
    end

    Corpses[corpseID].looted = true
    print((">> [Loot] Player %d successfully looted corpseID %d."):format(src, corpseID))
end)
