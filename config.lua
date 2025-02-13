Config = {}

------------------------------------------------------------------------------------------------------
-- ZOMBIES
------------------------------------------------------------------------------------------------------

Config.MaxDensity = 0.8

Config.ZombieTypes = {

    normal = {
        models = {
            "a_f_y_juggalo_01"
        },
        damage = 10,
        armor = 0,
        speed = 2.0,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "normal.ogg",
        special = nil,
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    fast = {
        models = {
            "a_m_m_eastsa_02"
        },
        damage = 8,
        armor = 0,
        speed = 3.0,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "fast.ogg",
        special = nil,
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    tank = {
        models = {
            "a_m_m_og_boss_01"
        },
        damage = 20,
        armor = 200,
        speed = 1.0,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "tank.ogg",
        special = nil,
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    psycho = {
        models = { 
            "s_m_y_prisoner_01" 
        },
        damage = 15,
        armor = 0,
        speed = 3.0,
        ragdollChance = 50,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "psycho.ogg",
        special = "psycho",   -- Lógica de teletransporte y empuje (comportamiento "psycho")
        teleport_interval = 5000,         -- Intervalo para teletransportarse (ms)
        force_application_interval = 5000, -- Intervalo para aplicar fuerza al jugador y vehículos (ms)
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    explosive = {
        models = {
            "a_m_m_farmer_01"
        },
        damage = 25,
        armor = 0,
        speed = 2.0,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "explosive.ogg",
        special = "explosive",   -- Lógica de explosión
        explosion_radius = 3.0,    -- Radio de la explosión (metros)
        explodeDamage = 40,         -- Daño que inflige la explosión
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    toxic = {
        models = { 
            "a_m_m_salton_02" 
        },
        damage = 5,
        armor = 0,
        speed = 2.0,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "smoke.ogg",
        special = "smoke",       -- Lógica de efecto de humo
        smoke_duration = 3000,     -- Duración del humo (ms)
        smoke_interval = 5000,      -- Intervalo entre emisiones (ms)
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    electric = {
        models = { 
            "a_m_m_tennis_01" 
        },
        damage = 10,
        armor = 0,
        speed = 2.0,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "electric.ogg",
        special = "electric",  -- Lógica de efecto eléctrico
        electric_duration = 1000,   -- Duración del efecto (ms)
        electric_interval = 5000,     -- Intervalo entre efectos (ms)
        electricDamage = 20,  -- Daño eléctrico adicional
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    },

    jumper = {
        models = {
            "a_m_m_beach_01"
        },
        damage = 15,
        armor = 0,
        speed = 2.5,
        ragdollChance = 1,
        clipsets = {"move_m@drunk@verydrunk"},
        sound = "super_jump.ogg",
        special = "super_jump",  -- Se usará en la lógica para saltar
        jump_interval = 5000,     -- Intervalo (ms) entre saltos
        density = 0.1,

        loot = {
            {item = 'phone',   min = 1, max = 2, chance = 30},
            {item = 'phone', min = 1, max = 1, chance = 20},
        }
    }

}

------------------------------------------------------------------------------------------------------
-- ZOMBIES | GENERAL SETTINGS
------------------------------------------------------------------------------------------------------

-- Lvl  ----------------------------------------------------------------------------------------------
Config.ZombieLevels = {
    [1] = { extraHealth = 0,   extraArmor = 0,   extraSpeed = 0.0,  extraDamage = 0 },
    [2] = { extraHealth = 50,  extraArmor = 20,  extraSpeed = 0.2,  extraDamage = 5 },
    [3] = { extraHealth = 100, extraArmor = 50,  extraSpeed = 0.5,  extraDamage = 10 }
}

Config.MinZombieLevel = 1
Config.MaxZombieLevel = 3

Config.ShowZombieHealthBar = true  -- Activar o desactivar la barra de vida 3D
Config.ShowZombieLevel = true      -- Mostrar el texto con el nivel al lado de la barra

-- Infection -----------------------------------------------------------------------------------------
Config.Infection = {
    chance = 100,                  -- Porcentaje de probabilidad de infectar (30%)
    duration = 600000,             -- Duración de la infección en ms (1 minuto)
    cureItem = "cureitem",        -- Nombre del ítem que cura la infección
    visualEffect = "dying",  -- Nombre del TimeCycleModifier a aplicar
    visualTransitionStep = 0.05,         -- Incremento de intensidad por paso
    visualTransitionDelay = 100,           -- Tiempo (ms) entre cada paso de transición
    coughAnimation = {
        dict = "timetable@gardener@smoking_joint",
        anim = "idle_cough",       -- Nombre de la animación (ejemplo, simula tos)
        duration = 3000,          -- Duración de la animación en ms
        flag = 49,                -- Flags para la animación
        interval = 10000           -- Intervalo entre cada tos (ms)
    },
    DamagePerInterval = 15,          -- Cantidad de vida a reducir cada intervalo
    DamageInterval = 10000
}

-- Zombie Blips ---------------------------------------------------------------------------------------
Config.ShowZombieBlips = true  -- Permitir mostrar blips de zombies cercanos
Config.ZombieBlipRadius = 80.0 -- Radio en el cual se mostrarán los blips de zombies
Config.ZombieBlip = {
    Sprite = 1,      -- Icono del blip
    Colour = 1,      -- Color (1 = rojo)
    Scale = 0.7,     -- Tamaño del blip
    Name = "Zombie"  -- Nombre que aparece en el mapa
}

-- Spawn ----------------------------------------------------------------------------------------------
Config.SpawnRadius = 50.0
Config.ZombieAttackInterval = 1000
Config.DespawnTime = 15000
Config.MaxZombiesPerPlayer = 10

-- Eating ---------------------------------------------------------------------------------------------
Config.EatingDistance = 1.0

-- Vehicles -------------------------------------------------------------------------------------------
Config.ZombiesCanPullOut = false -- Activar o desactivar que los zombies puedan sacar al jugador del vehiculo
Config.PullOutChance = 50         -- Probabilidad (en %) de que un zombie intente sacar al jugador del vehículo
Config.VehicleDamageOnAttack = 25 -- Cantidad de daño que se le hace al motor del vehículo por ataque
Config.VehicleAttackDistance = 1.5  -- Distancia a la que el zombie daña el vehículo
Config.VehiclePullOutDistance = 3.0   -- Distancia a la que el zombie intenta entrar al vehículo
Config.PushForce = 2.0              -- Fuerza con la que se empuja el vehículo
Config.DistanceTarget = 5.0         -- Distancia objetivo para que el zombie se acerque al vehículo

-- Vision ---------------------------------------------------------------------------------------------
Config.DayVisionDistance = 80.0
Config.NightVisionDistance = 40.0
Config.SearchTime = 10000

-- Audio ----------------------------------------------------------------------------------------------
Config.HearingRadius = 250.0        -- Radio base de escucha
Config.NoiseMemoryTime = 15000      -- Tiempo en ms que el zombie recuerda el último ruido
Config.FootstepsNoiseRadius = 30.0   -- Ruido generado por pasos al correr
Config.VehicleHighSpeedNoise = 100.0 -- Ruido al conducir rápido
Config.VehicleSpeedThreshold = 15.0  -- m/s, por encima de esto se considera ruidoso
Config.ClaxonNoiseRadius = 80.0      -- Ruido al tocar el claxon
Config.CollisionNoiseRadius = 120.0  -- Ruido por colisión fuerte
Config.CollisionSpeedDrop = 10.0     -- Diferencia de velocidad (m/s) considerada fuerte colisión
Config.AttackRadius = 500.0 -- Ruido si el arma está silenciada

------------------------------------------------------------------------------------------------------
-- LOOT SETTINGS
------------------------------------------------------------------------------------------------------

Config.EnableZombieLoot = true -- Activar o desactivar el sistema de loot

Config.LootMode = "zombie" -- Loot mode: "global" or "zombie"

Config.LootKey = 38 -- E = 38 en GTA KeyMapping
Config.LootDistance = 4.0

Config.ZombieLootItems = {
    {item = 'ammo-9', min = 1, max = 3, chance = 50}
}

------------------------------------------------------------------------------------------------------
-- SAFEZONES & REDZONES
------------------------------------------------------------------------------------------------------

Config.SpawnZoneMode = "zombie"  -- Spawn zones mode: "global" o "zombie"

-- Blips ---------------------------------------------------------------------------------------------

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

-- ZONES --------------------------------------------------------------------------------------------

Config.RedZones = {
    {
        coords = vector3(-2050.8552, -574.9294, 4.7846),
        radius = 10000.0,
        zTypes = {"fast"} -- If you select "global", every zombie type will spawn randomly.
    }
}

Config.SafeZones = {
    {coords = vector3(-2080.5789, -500.3755, 6.8020), radius = 50.0}, 
    --{coords = vector3(-350.0, -450.0, 33.0), radius = 150.0}
} 