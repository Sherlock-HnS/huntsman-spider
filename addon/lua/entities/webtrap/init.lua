AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local size = 8
function ENT:Initialize()
    self.InitTime = CurTime()

    self:SetModel("models/spiderweb/spiderweb.mdl")

    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInit(SOLID_BBOX)
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)
    self:SetTrigger(true)
    
    self:SetModelScale(size*5, 1)
    self:SetCollisionBounds(Vector(-size, -size, 1)/4, Vector(size, size, 1)/4)
    
    self:SetHealth(0)
    self:SetMaxHealth(40)
end

function ENT:Use(activator, caller)
end

function ENT:BitePlayer(ply)
	local newPos = ply:GetPos()
	newPos.x = self:GetPos().x
	newPos.y = self:GetPos().y
	ply:SetPos(newPos)

	ply:TakeDamage(10, self:GetOwner())
    
	ply:EmitSound("physics/flesh/flesh_squishy_impact_hard1.wav", 125)
    --ply:SetEyeAngles((self:GetPos()-ply:GetPos()):Angle())
    
    ply:HangEffect({
        name = "Web Trapped",
        time = 999,
        trapEnt = self,
    })

    if IsValid(self:GetOwner()) then
        SlashModules.PillAbility(self:GetOwner(), "Boost")
    end

    local hKey = tostring(self)
    hook.Add("KeyPress", hKey, function(ply2, key)
        if !IsValid(ply) or !IsValid(self) then
            if IsValid(self) then
                self:Remove()
            elseif IsValid(ply) then
                ply:TakeEffect("Web Trapped", 1)
            end

            hook.Remove("KeyPress", hKey)
            
            return
        elseif ply != ply2 or key != IN_JUMP then
            return
        end
        
        self:SetHealth(self:Health() + 1)

        if self:Health() >= self:GetMaxHealth() then
            self:Remove()
            ply:TakeEffect("Web Trapped", 1)
        end
    end)
end

function ENT:StartTouch(ent)
    local sTime = self.InitTime+1-CurTime()
    
    if self.TOUCHED or !IsValid(ent) or !ent:IsPlayer() then return end
    if IsValid(ent.pk_pill_ent) or ent:HasEffect("Web Trapped") then return end

    self.TOUCHED = true
    
    self:BitePlayer(ent)
end