if SERVER then
    AddCSLuaFile()
end

sound.Add({ 
	name = "spider.step", 
	channel = CHAN_STATIC, 
	volume = 1, 
	level = 80,
	pitch = 100,
	sound = {
		"spiderstep1.wav",
		"spiderstep2.wav",
		"spiderstep3.wav",
		"spiderstep4.wav",
		"spiderstep5.wav",
		"spiderstep6.wav",
	}
})

pk_pills.packStart("Huntsman Spider", "AnalogHorrorPills_blastnit_spider", "pills/pill_blast_sider.png")
pk_pills.register('pill_blast_sider', {
    printName = 'Huntsman Spider',  
    model = "models/blastnit/Husntamn/JackieSpider.mdl",
    modelScale = '0.7',

    hull = Vector(32, 32, 32),

    abilities = {
        {
            name = "Night Vision",
            key = KEY_F,
            hnsKeyLabel = "F",
            hnsIcon = "night_vision.png",
            cooldown = 1,
            mat = Material("night_vision.png", "smooth"),
            func = function(ply, pill) end -- Client Stuff
        },
        {
            name = "Web Trap",
            key = KEY_E,
            hnsKeyLabel = "E",
            hnsIcon = "pill_blast_sider/trap.png",
            cooldown = 10,
            mat = Material("pill_blast_sider/trap.png", "smooth"),
            func = function(ply, pill)
                local totalWebs = ents.FindByClass("webtrap")
                if #totalWebs >= 3 then totalWebs[1]:Remove() end

                local tr = util.TraceLine({
                    start = pill:GetPos(),
                    endpos = pill:GetPos() - Vector(0, 0, 10000),
                    filter = {ply, pill}
                })

                if !tr.Hit then return false end

                local ang = tr.HitNormal:Angle()
                --ang.y = math.random(180)
                ang.p = ang.p + 90

                local trap = ents.Create("webtrap")
                trap:SetModelScale(.01)
                trap:SetPos(tr.HitPos)
                trap:SetAngles(ang)
                trap:SetOwner(ply)
                trap:Spawn()

                pill:EmitSound("npc/headcrab_poison/ph_hiss1.wav", 125)
            end
        },
        {
            name = "Camo",
            key = KEY_R,
            hnsKeyLabel = "R",
            hnsIcon = "pill_blast_sider/camo.png",
            cooldown = 10,
            mat = Material("pill_blast_sider/camo.png", "smooth"),
            func = function(ply, pill)
                local pillForm = pill:GetPillForm()
                local pillTbl = pill.formTable

                local puppet = pill:GetPuppet()

                local camOffset = pill.formTable.camera and pill.formTable.camera.offset or Vector(0, 0, 64)

                if ply:GetMoveType() == MOVETYPE_NONE then
                    puppet:SetMaterial("")
                    puppet:DrawShadow(true)

                    ply:SetMoveType(MOVETYPE_WALK)
                    ply:SetViewOffset(camOffset)
    
                    ply:TakeEffect("Spider Camo", 1)
                else
                    local tr = util.TraceLine({
                        start = pill:GetPos(),
                        endpos = pill:GetPos() + Vector(0, 0, 1000),
                        filter = {ply, pill}
                    })

                    if !tr.Hit or tr.HitSky then return false end

                    ply:SetVelocity(Vector(0, 0, 1000))
                    
                    local found = false
                    for i = 0, 10 do
                        timer.Simple(0.1*i, function()
                            if found then return end
                            if !IsValid(ply) or !IsValid(pill) then return end
                            
                            local tr = util.TraceLine({
                                start = pill:GetPos(),
                                endpos = pill:GetPos() + Vector(0, 0, 75),
                                filter = {ply, pill}
                            })
    
                            if !tr.Hit then return end
                            found = true
                            
                            ply:SetPos(tr.HitPos - Vector(0, 0, 60))
    
                            puppet:DrawShadow(false)

                            ply:SetViewOffset(camOffset - Vector(0, 0, 100))
                            
                            ply:SetMoveType(MOVETYPE_NONE)
    
                            ply:HangEffect({
                                name = "Spider Camo",
                                time = 999,
                            })
                        end)
                    end

                    return 1
                end
            end
        },
        {
            name = "Boost",
            key = "PASSIVE",
            hnsKeyLabel = "PASSIVA",
            hnsIcon = "pill_blast_sider/boost.png",
            cooldown = 10,
            mat = Material("pill_blast_sider/boost.png", "smooth"),
            func = function(ply, pill)
                ply:HangEffect({
                    name = "Spider Boost",
                    time = 10,
                })

                pill:EmitSound("npc/headcrab_poison/ph_talk"..math.random(3)..".wav", 125)
            end
        },
    },

    noragdoll = true,
    anims = {
        default = {
            idle = "idle",
            jumpscare = "kill",
            walk = "walk",
            run = "run",
            attack = "attack 1",
            jump = "jump",
        },
    },
    moveSpeed = {
        walk = 200,
        run = 600,
        ducked = 20,
    },
    sounds = {
		step = 'spider.step',
    },
    type = 'ply',
    camera = {
        offset = Vector(0, 0, 50),
        dist = 200,
    },
    jumpPower = 0,
    health = 2000,
    movePoseMode = "xy",
    aim = {
        xPose ="aim_yaw",
        yPose = "aim_pitch",
        nocrosshair = true
    },   
    canAim = function(ply,ent) return ent.active end,    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            return SlashModules.Jumpscare(ply)
        end
    },
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },
    noragdoll = true,
    reload = function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
    jump = function(ply, ent) end,
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
    SlashModules.ConfigureHNSAbilities(form)
end)