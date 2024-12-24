local zombies = {}
local zombieHealth = {} -- Tabla para guardar la salud anterior de cada zombie
local currentZombieCount = 0
local zombieBlips = {}

-- Variables para detección auditiva
local lastNoisePos = nil
local lastNoiseTime = 0
local lastNoiseRadius = Config.HearingRadius

local soundManager = exports['xsound']

local attackAnimations = {
    {dict = "anim@ingame@melee@unarmed@streamed_core_zombie", anim = "short_90_punch"},
    {dict = "anim@ingame@melee@unarmed@streamed_variations_zombie", anim = "heavy_punch_b_var_2"}
}

local VehicleAttackDistance = Config.VehicleAttackDistance
local VehicleEnterDistance = Config.VehiclePullOutDistance
local PushForce = Config.PushForce
local DistanceTarget = Config.DistanceTarget

function playZombieAttack(zombie)
    local attack = attackAnimations[math.random(#attackAnimations)]
    RequestAnimDict(attack.dict)
    while not HasAnimDictLoaded(attack.dict) do
        Wait(0)
    end
    TaskPlayAnim(zombie, attack.dict, attack.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

function IsNight()
    local hour = GetClockHours()
    return (hour >= 20 or hour < 6)
end

function GetVisionDistance()
    if IsNight() then
        return Config.NightVisionDistance
    else
        return Config.DayVisionDistance
    end
end

function makeNoise(coords, radius)
    lastNoisePos = coords
    lastNoiseTime = GetGameTimer()
    lastNoiseRadius = radius
end

function GetNoisePositionIfRecent()
    if lastNoisePos and (GetGameTimer() - lastNoiseTime) < Config.NoiseMemoryTime then
        return lastNoisePos, lastNoiseRadius
    end
    return nil, 0
end

function canZombieSeePlayer(zombie, playerPed, distance)
    if distance > GetVisionDistance() then
        return false
    end
    return HasEntityClearLosToEntity(zombie, playerPed, 17)
end

function damageVehicle(vehicle)
    local currentEngineHealth = GetVehicleEngineHealth(vehicle)
    local newHealth = currentEngineHealth - Config.VehicleDamageOnAttack
    if newHealth < 0 then newHealth = 0 end
    SetVehicleEngineHealth(vehicle, newHealth)

    ApplyForceToEntity(vehicle, 1, 0.0, -PushForce, 0.2, 0.0, 0.0, 0.0, false, true, true, false, true, true)

    local xOffset = (math.random() - 0.5) * 0.5
    local yOffset = (math.random() - 0.5) * 0.5
    local zOffset = 0.0
    SetVehicleDamage(vehicle, xOffset, yOffset, zOffset, 50.0, 0.1, true)
end

function pullPlayerOutOfVehicle(zombie, playerPed, vehicle)
    ClearPedTasksImmediately(playerPed)
    TaskLeaveVehicle(playerPed, vehicle, 16)
    Wait(1000)
    if IsPedInAnyVehicle(playerPed, false) then
        ClearPedTasksImmediately(playerPed)
        TaskLeaveVehicle(playerPed, vehicle, 16)
    end
    playZombieAttack(zombie)
    ApplyDamageToPed(playerPed, Config.ZombieDamage, false)
end

function searchArea(zombie, coords, duration)
    TaskGoToCoordAnyMeans(zombie, coords.x, coords.y, coords.z, 1.0, 0, 0, 786603, 0)
    local endTime = GetGameTimer() + duration
    while GetGameTimer() < endTime and DoesEntityExist(zombie) and not IsPedDeadOrDying(zombie, true) do
        Wait(500)
    end

    if DoesEntityExist(zombie) and not IsPedDeadOrDying(zombie, true) then
        local animDict = "anim@ingame@move_m@zombie@strafe"
        local animName = "idle"

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
        TaskPlayAnim(zombie, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

        Wait(5000)
        ClearPedTasks(zombie)
        TaskWanderStandard(zombie, 10.0, 10)
    end
end

function isInZone(coords, zoneCoords, radius)
    return #(coords - zoneCoords) <= radius
end

function playerInRedZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.RedZones) do
        if isInZone(playerCoords, zone.coords, zone.radius) then
            return true
        end
    end
    return false
end

function zombieInSafeZone(zombieCoords)
    for _, zone in ipairs(Config.SafeZones) do
        if isInZone(zombieCoords, zone.coords, zone.radius) then
            return true
        end
    end
    return false
end

-- Estado para saber si el zombie está corriendo o no
-- para no re-asignar tareas innecesariamente
local zombieStates = {} -- zombieStates[zombie] = { isRunning = false, originalClipset = "..."}

-- Nueva función: Ajustar velocidad del zombie y clipset según estado
-- Cuando el jugador esté sprintando y distancia > 2, el zombie corre (sin clipset) tras el jugador usando TaskGoToEntity a zombieType.speed
-- Cuando el jugador deja de sprintar o está a <= 2m, el zombie vuelve a su clipset original y velocidad normal
function updateZombieMovementStyle(zombie, zombieType, playerPed, distanceToPlayer)
    local playerSpeed = GetEntitySpeed(playerPed)
    local isPlayerSprinting = playerSpeed > 2.0 -- umbral para "sprint"

    if not zombieStates[zombie] then
        -- Guardar estado inicial
        zombieStates[zombie] = {isRunning = false, originalClipset = nil}
    end

    if zombieStates[zombie].originalClipset == nil then
        -- Guardar un clipset original (el que ya tiene puesto)
        zombieStates[zombie].originalClipset = zombieType.clipsets[1] 
    end

    if isPlayerSprinting and distanceToPlayer > 2.0 then
        -- Quitar clipset y correr
        if not zombieStates[zombie].isRunning then
            -- Cambiar a modo correr
            ResetPedMovementClipset(zombie, 1.0)
            Wait(500)
            -- Asignar tarea con TaskGoToEntity con mayor velocidad
            TaskGoToEntity(zombie, playerPed, -1, 0.0, zombieType.speed, 1073741824, 0)
            zombieStates[zombie].isRunning = true
        else
            -- Ya está corriendo, asegurarse de que sigue persiguiendo
            TaskGoToEntity(zombie, playerPed, -1, 0.0, zombieType.speed, 1073741824, 0)
        end
    else
        -- Volver a clipset normal
        if zombieStates[zombie].isRunning then
            local clipset = zombieStates[zombie].originalClipset
            RequestAnimSet(clipset)
            while not HasAnimSetLoaded(clipset) do
                Wait(0)
            end
            SetPedMovementClipset(zombie, clipset, 1.0)
            Wait(500)
            TaskGoToEntity(zombie, playerPed, -1, 0.0, 1.0, 1073741824, 0)
            zombieStates[zombie].isRunning = false
        else
            -- Ya está en modo normal, asegurar que persigue con velocidad normal
            TaskGoToEntity(zombie, playerPed, -1, 0.0, 1.0, 1073741824, 0)
        end
    end
end

function spawnZombie()
    if not playerInRedZone() then
        return
    end

    if currentZombieCount >= Config.MaxZombiesPerPlayer then
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local spawnX = playerCoords.x + math.random(-Config.SpawnRadius, Config.SpawnRadius)
    local spawnY = playerCoords.y + math.random(-Config.SpawnRadius, Config.SpawnRadius)
    local spawnZ = playerCoords.z + 50.0  -- empezar un poco arriba, para asegurar encontrar suelo

    -- Encontrar la coordenada de suelo
    local foundGround, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ, false)
    local tries = 0
    while (not foundGround) and (tries < 100) do
        spawnZ = spawnZ - 1.0
        foundGround, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ, false)
        tries = tries + 1
        Wait(200)
    end
    
    if not foundGround then
        -- No se encontró suelo tras varios intentos, abortar spawn
        return
    end

    -- Ahora groundZ es la altura del suelo
    spawnZ = groundZ

    local zombieTypesKeys = {}
    for k,_ in pairs(Config.ZombieTypes) do
        table.insert(zombieTypesKeys, k)
    end
    local chosenTypeKey = zombieTypesKeys[math.random(#zombieTypesKeys)]
    local zombieType = Config.ZombieTypes[chosenTypeKey]

    local model = zombieType.models[math.random(#zombieType.models)]
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local zombie = CreatePed(4, model, spawnX, spawnY, spawnZ, 0.0, true, true)
    SetPedFleeAttributes(zombie, 0, false)
    SetBlockingOfNonTemporaryEvents(zombie, true)
    SetPedConfigFlag(zombie, 42, true)
    SetPedCombatAttributes(zombie, 46, true)
    DisablePedPainAudio(zombie, true)
    StopCurrentPlayingAmbientSpeech(zombie)
    StopPedSpeaking(zombie, true)

    TaskWanderStandard(zombie, 10.0, 10)
    SetPedAsEnemy(zombie, false)
    SetPedCombatAttributes(zombie, 46, false)
    SetPedFleeAttributes(zombie, 0, 0)
    SetPedCombatAbility(zombie, 0)
    SetPedCombatMovement(zombie, 0)
    SetPedCombatRange(zombie, 0)
    SetPedTargetLossResponse(zombie, 0)
    SetPedAlertness(zombie, 0)
    SetPedAccuracy(zombie, 0)

    local clipset = zombieType.clipsets[math.random(#zombieType.clipsets)]
    RequestAnimSet(clipset)
    while not HasAnimSetLoaded(clipset) do
        Wait(0)
    end
    SetPedMovementClipset(zombie, clipset, 1.0)

    table.insert(zombies, zombie)
    currentZombieCount = currentZombieCount + 1

    zombieHealth[zombie] = GetEntityHealth(zombie)

    local soundFile = 'nui://' .. GetCurrentResourceName() .. '/sounds/' .. zombieType.sound
    local soundId = "zombie_sound_" .. tostring(zombie)
    local zCoords = GetEntityCoords(zombie)
    soundManager:PlayUrlPos(soundId, soundFile, 0.5, zCoords, true)
    soundManager:Distance(soundId, 20.0)

    Citizen.CreateThread(function()
        local lastKnownPlayerPos = nil
        local searching = false

        while DoesEntityExist(zombie) do
            Wait(Config.ZombieAttackInterval)
            if IsPedDeadOrDying(zombie, true) then break end

            local zPos = GetEntityCoords(zombie)
            soundManager:Position(soundId, zPos)

            if zombieInSafeZone(zPos) then
                soundManager:Destroy(soundId)
                DeleteEntity(zombie)
                for i, z in ipairs(zombies) do
                    if z == zombie then
                        table.remove(zombies, i)
                        currentZombieCount = currentZombieCount - 1
                        break
                    end
                end
                break
            end

            local playerPed = PlayerPedId()
            local zombieCoords = zPos
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - zombieCoords)

            local currentHealth = GetEntityHealth(zombie) or 0
            if DoesEntityExist(zombie) and currentHealth < (zombieHealth[zombie] or 0) then
                zombieHealth[zombie] = currentHealth
                makeNoise(zPos, Config.AttackRadius)
            else
                if DoesEntityExist(zombie) then
                    zombieHealth[zombie] = currentHealth
                end
            end            

            local seePlayer = canZombieSeePlayer(zombie, playerPed, distance)

            local noisePos, noiseRadius = GetNoisePositionIfRecent()
            local hearPlayer = false
            if noisePos and #(zombieCoords - noisePos) < noiseRadius then
                hearPlayer = true
            end

            if seePlayer then
                lastKnownPlayerPos = playerCoords
                
                -- Actualizar estilo de movimiento según sprint del jugador y distancia
                updateZombieMovementStyle(zombie, zombieType, playerPed, distance)

                if IsPedInAnyVehicle(playerPed, false) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    local distToVehicle = #(zombieCoords - GetEntityCoords(vehicle))
                    
                    if distToVehicle < DistanceTarget then
                        -- Ya se reconfiguró el estilo arriba, aquí mantenemos la lógica igual
                        -- Podrías opcionalmente volver a llamar updateZombieMovementStyle aquí si lo deseas
                        
                        TaskGoToEntity(zombie, vehicle, -1, 0.0, 1.0, 1073741824, 0)

                        if distToVehicle < VehicleAttackDistance then
                            playZombieAttack(zombie)
                            damageVehicle(vehicle)
                        end
                        
                        if Config.ZombiesCanPullOut then
                            local rand = math.random(100)
                            if rand <= Config.PullOutChance and distToVehicle < VehicleEnterDistance then
                                SetPedCanBeDraggedOut(playerPed, true)
                                TaskEnterVehicle(zombie, vehicle, -1, -1, 2.0, 8, 0)
            
                                Citizen.Wait(2000)
                                if not IsPedInAnyVehicle(playerPed, false) then
                                    playZombieAttack(zombie)
                                    ApplyDamageToPed(playerPed, zombieType.damage, false)
                                else
                                    playZombieAttack(zombie)
                                    damageVehicle(vehicle)
                                end
                            else
                                if distToVehicle < VehicleAttackDistance then
                                    playZombieAttack(zombie)
                                    damageVehicle(vehicle)
                                    
                                    local rand = math.random(100)
                                    if rand <= zombieType.ragdollChance then
                                        local playerPed = PlayerPedId()
                                        if IsPedInAnyVehicle(playerPed, false) then
                                            ClearPedTasksImmediately(playerPed)
                                            
                                            local vehCoords = GetEntityCoords(vehicle)
                                            local offsetPos = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, 0.0, 0.0)
                                            SetEntityCoords(playerPed, offsetPos.x, offsetPos.y, offsetPos.z)
                                            
                                            Wait(500)
                                        end
                                
                                        if not IsPedInAnyVehicle(playerPed, false) then
                                            SetPedCanRagdoll(playerPed, true)
                                            SetPedToRagdoll(playerPed, 1000, 1000, 0, true, true, false)
                                        end
                                    end
                                end
                            end
                        else
                            if distToVehicle < VehicleAttackDistance then
                                playZombieAttack(zombie)
                                damageVehicle(vehicle)
                            end
                        end
                    end
                else
                    -- Jugador a pie, ataque normal
                    if distance <= 2.0 then
                        playZombieAttack(zombie)
                        ApplyDamageToPed(playerPed, zombieType.damage, false)
                    
                        local rand = math.random(100)
                        if rand <= zombieType.ragdollChance then
                            SetPedCanRagdoll(playerPed, true)
                            SetPedToRagdoll(playerPed, 1000, 1000, 0, true, true, false)
                        end

                        updateZombieMovementStyle(zombie, zombieType, playerPed, distance)
                    end
                end
            elseif hearPlayer then
                lastKnownPlayerPos = noisePos
                TaskGoToCoordAnyMeans(zombie, noisePos.x, noisePos.y, noisePos.z, 1.0, 0, 0, 786603, 0)
                updateZombieMovementStyle(zombie, zombieType, playerPed, #(GetEntityCoords(playerPed) - zPos))
            elseif lastKnownPlayerPos and not searching then
                searching = true
                searchArea(zombie, lastKnownPlayerPos, Config.SearchTime)
                lastKnownPlayerPos = nil
                searching = false
                updateZombieMovementStyle(zombie, zombieType, playerPed, #(GetEntityCoords(playerPed) - zPos))
            else
                updateZombieMovementStyle(zombie, zombieType, playerPed, #(GetEntityCoords(playerPed) - zPos))
            end

            if Config.ShowZombieBlips then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distToPlayer = #(GetEntityCoords(zombie) - playerCoords)
                if distToPlayer <= Config.ZombieBlipRadius then
                    if not zombieBlips[zombie] then
                        local blip = AddBlipForEntity(zombie)
                        SetBlipSprite(blip, Config.ZombieBlip.Sprite)
                        SetBlipColour(blip, Config.ZombieBlip.Colour)
                        SetBlipScale(blip, Config.ZombieBlip.Scale)
                        SetBlipAsShortRange(blip, false)
            
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(Config.ZombieBlip.Name)
                        EndTextCommandSetBlipName(blip)
            
                        zombieBlips[zombie] = blip
                    end
                else
                    if zombieBlips[zombie] then
                        RemoveBlip(zombieBlips[zombie])
                        zombieBlips[zombie] = nil
                    end
                end
            end            
        end
        
        if zombieBlips[zombie] then
            RemoveBlip(zombieBlips[zombie])
            zombieBlips[zombie] = nil
        end

        soundManager:Destroy(soundId)
        zombieHealth[zombie] = nil
    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        spawnZombie()
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i = #zombies, 1, -1 do
            local zombie = zombies[i]
            if DoesEntityExist(zombie) and GetEntityHealth(zombie) <= 0 then
                -- Zombie muerto encontrado
                local deadZombie = zombie

                -- Iniciar un hilo separado para manejar este zombie muerto
                Citizen.CreateThread(function()
                    local deathTime = GetGameTimer()
                    local looted = false

                    while DoesEntityExist(deadZombie) and (GetGameTimer() - deathTime) < Config.DespawnTime do
                        Wait(0)
                        local playerPed = PlayerPedId()
                        local playerCoords = GetEntityCoords(playerPed)
                        local zCoords = GetEntityCoords(deadZombie)
                        local distance = #(playerCoords - zCoords)

                        if Config.EnableZombieLoot and distance < 1.5 then
                            DrawMarker(20, zCoords.x, zCoords.y, zCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 150, false, true, 2, false, nil, nil, false)
                            
                            if IsControlJustReleased(0, Config.LootKey) then
                                TriggerServerEvent('zombies:giveLoot')
                                looted = true
                                break
                            end
                        end
                    end

                    -- Después de lootear o cumplirse el tiempo
                    if DoesEntityExist(deadZombie) then
                        DeleteEntity(deadZombie)
                    end
                end)

                -- Remover este zombie de la lista inmediatamente
                table.remove(zombies, i)

                if zombieBlips[zombie] then
                    RemoveBlip(zombieBlips[zombie])
                    zombieBlips[zombie] = nil
                end

                zombieHealth[zombie] = nil
                currentZombieCount = currentZombieCount - 1
            end
        end
    end
end)

Citizen.CreateThread(function()
    local playerPed = PlayerPedId()
    local lastVehicleSpeed = 0.0
    while true do
        Wait(1000)
        playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local isInVehicle = IsPedInAnyVehicle(playerPed, false)
        local speed = 0.0

        if isInVehicle then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            speed = GetEntitySpeed(vehicle)
        else
            speed = GetEntitySpeed(playerPed)
        end

        if not isInVehicle then
            if speed > 2.0 and not GetPedStealthMovement(playerPed) then
                makeNoise(coords, Config.FootstepsNoiseRadius)
            end
        end

        if isInVehicle and speed > Config.VehicleSpeedThreshold then
            makeNoise(coords, Config.VehicleHighSpeedNoise)
        end

        if isInVehicle then
            local speedDrop = lastVehicleSpeed - speed
            if speedDrop > Config.CollisionSpeedDrop then
                makeNoise(coords, Config.CollisionNoiseRadius)
            end
            lastVehicleSpeed = speed
        else
            lastVehicleSpeed = 0.0
        end

        if isInVehicle and IsControlPressed(0, 86) then
            makeNoise(coords, Config.ClaxonNoiseRadius)
        end
    end
end)

Citizen.CreateThread(function()
    if Config.ShowRedZoneBlips then
        for _, zone in ipairs(Config.RedZones) do
            local radiusBlip = AddBlipForRadius(zone.coords, zone.radius)
            SetBlipColour(radiusBlip, Config.RedZoneBlip.Colour)
            SetBlipAlpha(radiusBlip, 128)
            
            local blipMarker = AddBlipForCoord(zone.coords)
            SetBlipSprite(blipMarker, Config.RedZoneBlip.Sprite)
            SetBlipColour(blipMarker, Config.RedZoneBlip.Colour)
            SetBlipScale(blipMarker, Config.RedZoneBlip.Scale)
            SetBlipAsShortRange(blipMarker, true)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.RedZoneBlip.Name)
            EndTextCommandSetBlipName(blipMarker)
        end
    end

    if Config.ShowSafeZoneBlips then
        for _, zone in ipairs(Config.SafeZones) do
            local radiusBlip = AddBlipForRadius(zone.coords, zone.radius)
            SetBlipColour(radiusBlip, Config.SafeZoneBlip.Colour)
            SetBlipAlpha(radiusBlip, 128)

            local blipMarker = AddBlipForCoord(zone.coords)
            SetBlipSprite(blipMarker, Config.SafeZoneBlip.Sprite)
            SetBlipColour(blipMarker, Config.SafeZoneBlip.Colour)
            SetBlipScale(blipMarker, Config.SafeZoneBlip.Scale)
            SetBlipAsShortRange(blipMarker, true)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.SafeZoneBlip.Name)
            EndTextCommandSetBlipName(blipMarker)
        end
    end
end)