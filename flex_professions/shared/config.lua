Config = {}

Config.Debug = true
Config.CoreName = {
    qb = 'qb-core',
    esx = 'es_extended',
    ox = 'ox_core',
    ox_inv = 'ox_inventory',
    qbx = 'qbx_core',
    qb_radial = 'qb-radialmenu',
}

Config.Notify = {
    client = function(msg, type, time)
        lib.notify({
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
    server = function(src, msg, type, time)
        lib.notify(src, {
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
}

Config.sql = {
    table = 'players',
    column = 'professions',
}

Config.MoneyTypes = {
    'cash',
    'bank',
    'blackmoney',
}

Config.InfiniteProfessions = false -- Set to true to allow players to have multiple professions
Config.Professions = {
    intro = {
        canEscape = false,
        title = "KIES JE BEROEP",
        desc = "Dit is de start van je verhaal, neem je tijd en kies zorgvuldig",
        jobs = {
            [1] = {
                job = "police",
                label = "POLITIE",
                desc = "Handhaaf de wet, achtervolg verdachten en bescherm Los Santos.",
                rgb = 'rgb(37, 37, 163)',
                application = true,
                travel = { -- or false to disable
                    ped = "csb_mweather",
                    vehicle = "police",
                    start = vector4(-1033.13, -2730.25, 19.70, 237.24),
                    finish = vector4(408.22, -984.57, 28.87, 227.77),
                    convo = { -- Each line is a new setence the AI will say
                        "Hallo officier! Hoe kan ik u vandaag helpen?",
                        "Blijf veilig daarbuiten!",
                    },
                },
                rewards = {
                },
            },
            [2] = {
                job = "ambulance",
                label = "AMBULANCE",
                desc = "Red levens en reageer op noodoproepjes.",
                rgb = 'rgb(217, 212, 61)',
                application = true,
                travel = { -- or false to disable
                    ped = "csb_mweather",
                    vehicle = "ambulance",
                    start = vector4(-1033.13, -2730.25, 19.70, 237.24),
                    finish = vector4(408.22, -984.57, 28.87, 227.77),
                    convo = { -- Each line is a new setence the AI will say
                        "Hallo officier! Hoe kan ik u vandaag helpen?",
                        "Blijf veilig daarbuiten!",
                    },
                },
                rewards = {
                },
            },
            [3] = {
                job = "mechanic",
                label = "MECHANIC",
                desc = "Repareer, sleep en tune wagens.",
                rgb = 'rgb(178, 59, 59)',
                application = true,
                travel = { -- or false to disable
                    ped = "csb_mweather",
                    vehicle = "truck",
                    start = vector4(-1033.13, -2730.25, 19.70, 237.24),
                    finish = vector4(408.22, -984.57, 28.87, 227.77),
                    convo = { -- Each line is a new setence the AI will say
                        "Hallo officier! Hoe kan ik u vandaag helpen?",
                        "Blijf veilig daarbuiten!",
                    },
                },
                rewards = {
                },
            },
            [4] = {
                job = "criminal",
                label = "BOEFJE",
                rgb = 'rgb(94, 48, 93)',
                desc = "Leef op de rand. Pleeg overvallen, verhandel drugs en groei.",
                application = false,
                travel = { -- or false to disable
                    ped = "csb_mweather",
                    vehicle = "taxi",
                    start = vector4(-1033.13, -2730.25, 19.70, 237.24),
                    finish = vector4(408.22, -984.57, 28.87, 227.77),
                    convo = { -- Each line is a new setence the AI will say
                        "Hallo officier! Hoe kan ik u vandaag helpen?",
                        "Blijf veilig daarbuiten!",
                    },
                },
                rewards = {
                    lockpick = {amount = 20, info = {}},
                },
            },
            [5] = {
                job = "civ",
                label = "BURGER",
                desc = "Leef vrij. Begin klein en bouw grote verhalen.",
                rgb = 'rgb(70, 133, 77)',
                application = false,
                travel = { -- or false to disable
                    ped = "csb_mweather",
                    vehicle = "taxi",
                    start = vector4(-1033.13, -2730.25, 19.70, 237.24),
                    finish = vector4(408.22, -984.57, 28.87, 227.77),
                    convo = { -- Each line is a new setence the AI will say
                        "Hallo officier! Hoe kan ik u vandaag helpen?",
                        "Blijf veilig daarbuiten!",
                    },
                },
                rewards = {
                    vehicle = "panto",
                },
            },
        }
    }
}