Config = {}

------------------------------------------------------------------------------------------------------
-- ZOMBIES
------------------------------------------------------------------------------------------------------

Config.ZombieTypes = {

    normal = {
        models = {
            'u_m_y_zombie_01',
        },
        damage = 10,
        speed = 2.0, -- Podrías usar esto para cambiar su velocidad al perseguir
        ragdollChance = 10,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "explosive.ogg" -- Sonido específico para este tipo
    },

    fast = {
        models = {
            'g_m_m_zombie_01', -- Need build 3258 for this ped
        },
        damage = 8,
        speed = 3,
        ragdollChance = 10,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "fast.ogg"
    },

    tank = {
        models = {
            'g_m_m_zombie_02', -- Need build 3258 for this ped
        },
        damage = 20,
        speed = 1.0,
        ragdollChance = 75,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "tanque.ogg"
    }

}

------------------------------------------------------------------------------------------------------
-- ZOMBIES | GENERAL SETTINGS
------------------------------------------------------------------------------------------------------

-- Zombie Blips
Config.ShowZombieBlips = true  -- Permitir mostrar blips de zombies cercanos
Config.ZombieBlipRadius = 80.0 -- Radio en el cual se mostrarán los blips de zombies
Config.ZombieBlip = {
    Sprite = 1,      -- Icono del blip
    Colour = 1,      -- Color (1 = rojo)
    Scale = 0.7,     -- Tamaño del blip
    Name = "Zombie"  -- Nombre que aparece en el mapa
}

-- Comportamiento general
Config.SpawnRadius = 50.0
Config.ZombieAttackInterval = 1000
Config.DespawnTime = 15000
Config.MaxZombiesPerPlayer = 10

-- Vehículos
Config.ZombiesCanPullOut = false -- Activar o desactivar que los zombies puedan sacar al jugador del vehiculo
Config.PullOutChance = 50         -- Probabilidad (en %) de que un zombie intente sacar al jugador del vehículo
Config.VehicleDamageOnAttack = 25 -- Cantidad de daño que se le hace al motor del vehículo por ataque

-- Ajustes de interacción con vehículos
Config.VehicleAttackDistance = 1.5  -- Distancia a la que el zombie daña el vehículo
Config.VehiclePullOutDistance = 3.0   -- Distancia a la que el zombie intenta entrar al vehículo
Config.PushForce = 2.0              -- Fuerza con la que se empuja el vehículo
Config.DistanceTarget = 5.0         -- Distancia objetivo para que el zombie se acerque al vehículo

-- Parámetros de visión y búsqueda
Config.DayVisionDistance = 80.0
Config.NightVisionDistance = 40.0
Config.SearchTime = 10000

-- Audio/detección
Config.HearingRadius = 250.0        -- Radio base de escucha
Config.NoiseMemoryTime = 15000      -- Tiempo en ms que el zombie recuerda el último ruido

-- Ajustes de ruido adicionales
Config.FootstepsNoiseRadius = 30.0   -- Ruido generado por pasos al correr
Config.VehicleHighSpeedNoise = 100.0 -- Ruido al conducir rápido
Config.VehicleSpeedThreshold = 15.0  -- m/s, por encima de esto se considera ruidoso
Config.ClaxonNoiseRadius = 80.0      -- Ruido al tocar el claxon

Config.CollisionNoiseRadius = 120.0  -- Ruido por colisión fuerte
Config.CollisionSpeedDrop = 10.0     -- Diferencia de velocidad (m/s) considerada fuerte colisión

Config.AttackRadius = 500.0 -- Ruido si el arma está silenciada

------------------------------------------------------------------------------------------------------
-- FRAMEWORK & LOOT SETTINGS
------------------------------------------------------------------------------------------------------
Config.Framework = 'ESX' -- 'ESX' o 'QBCORE'
Config.EnableZombieLoot = true -- Activar o desactivar el sistema de loot

Config.LootKey = 38 -- E = 38 en GTA KeyMapping
Config.LootDistance = 4.0

Config.ZombieLootItems = {
    {item = 'bandage', min = 1, max = 3, chance = 50}, 
    {item = 'water', min = 1, max = 2, chance = 30},
    {item = 'bread', min = 1, max = 2, chance = 20}
}

------------------------------------------------------------------------------------------------------
-- SAFEZONES & REDZONES
------------------------------------------------------------------------------------------------------

Config.ShowRedZoneBlips = true   -- Mostrar blips de redzones
Config.RedZoneBlip = {
    Sprite = 310,
    Colour = 1,
    Scale = 1.0,
    Name = "Redzone"
}

Config.ShowSafeZoneBlips = true  -- Mostrar blips de safezones
Config.SafeZoneBlip = {
    Sprite = 305,
    Colour = 2,
    Scale = 1.0,
    Name = "Safezone"
}

-- Definir RedZones (donde pueden spawnear zombies)
Config.RedZones = {
    {coords = vector3(-2050.8552, -574.9294, 4.7846), radius = 10000.0},
    --{coords = vector3(200.0, 200.0, 200.0), radius = 300.0}
}

-- Definir SafeZones (donde los zombies desaparecen)
Config.SafeZones = {
    {coords = vector3(-2080.5789, -500.3755, 6.8020), radius = 50.0}, 
    --{coords = vector3(-350.0, -450.0, 33.0), radius = 150.0}
}