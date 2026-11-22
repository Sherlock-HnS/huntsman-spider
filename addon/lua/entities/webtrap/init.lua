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

	if SherlockHNS then
        ply:SetNWEntity("blast_web_trap", self)
        self:CallOnRemove("ReleaseHNSWeb", function()
            if IsValid(ply) and ply:GetNWEntity("blast_web_trap") == self then
                ply:SetNWEntity("blast_web_trap", NULL)
            end
        end)
    else
        ply:TakeDamage(10, self:GetOwner())
    end
    
	ply:EmitSound("physics/flesh/flesh_squishy_impact_hard1.wav", 125)
    --ply:SetEyeAngles((self:GetPos()-ply:GetPos()):Angle())
    
    SlashModules.ApplyTargetEffect(ply, self:GetOwner(), {
        name = "Web Trapped",
        time = 999,
        trapEnt = self,
    })

    if IsValid(self:GetOwner()) then
        SlashModules.PillAbility(self:GetOwner(), "Boost")
    end

    local hKey = tostring(self)
    self:CallOnRemove("RemoveWebInput", function()
        hook.Remove("KeyPress", hKey)
        if IsValid(ply) and ply:HasEffect("Web Trapped") then ply:TakeEffect("Web Trapped", 999) end
    end)
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

    if SherlockHNS and (not IsValid(self:GetOwner()) or not SherlockHNS.CanTarget(ent, self:GetOwner())) then return end
    self.TOUCHED = true
    
    self:BitePlayer(ent)
end

function ENT:Think()
    if SherlockHNS and not self.TOUCHED then
        local mins, maxs = self:WorldSpaceAABB()
        for _, target in ipairs(ents.FindInBox(mins, maxs)) do
            self:StartTouch(target)
            if self.TOUCHED then break end
        end
    end
    self:NextThink(CurTime() + 0.1)
    return true
end