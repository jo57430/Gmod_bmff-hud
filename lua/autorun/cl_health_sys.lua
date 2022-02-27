AddCSLuaFile()

if SERVER then
	resource.AddFile( "materials/healthadvanced/hud_lowhealth.vmt" )
	
	CreateConVar( "hpadv_scream", "1", { FCVAR_ARCHIVE }, "Used to enable or disable scream" )
	CreateConVar( "hpadv_legbreak", "1", { FCVAR_ARCHIVE }, "Used to enable or disable leg breaking" )
	CreateConVar( "hpadv_regenabled", "1", { FCVAR_ARCHIVE }, "Enable or disable regeneration" ) -- Not hardcoded, yay!
	CreateConVar( "hpadv_regtime", "60", { FCVAR_ARCHIVE }, "After that time health regeneration will start" )
	CreateConVar( "hpadv_regupto", "50", { FCVAR_ARCHIVE }, "Regenerate up to {n} percent" )

	
	hook.Add( "EntityTakeDamage", "healthadvanced", function( target, dmginfo )
		if ( target:IsPlayer() ) then
			target:SetNWInt( "healthadvanced_regenerate", CurTime() ) -- Start regeneration 'timer'
		end
		if ( target:IsPlayer() and dmginfo:GetDamageType() ~= DMG_FALL) and GetConVar("hpadv_scream"):GetBool() then
			target:EmitSound("vo/npc/male01/pain0"..math.random(1, 6)..".wav") -- Scream, if this is not fall damage
		end
	end )
	
	hook.Add( "Think", "healthadvanced", function()
		if not GetConVar("hpadv_regenabled"):GetBool() then return end

		local all = player.GetAll()
		
		for k, v in pairs(all) do
			
			if not (v:Health() < v:GetMaxHealth() * (math.Clamp(GetConVar("hpadv_regupto"):GetInt(), 5, 100)/100)) then return end -- Regenerate health up to 70% of max health.
			
			local time = v:GetNWInt( "healthadvanced_regenerate" ) -- Get regeneration 'timer'... time?
			local cvreg = math.Clamp(GetConVar( "hpadv_regtime" ):GetInt(), 2, 60) -- Clamped, because ... 
			
			if CurTime() - time > cvreg then
				v:SetNWInt( "healthadvanced_regenerate", CurTime()-cvreg+1 ) -- ... because of that.
				v:SetHealth( v:Health() + v:GetMaxHealth() / 100)
			end
		end
	end )

	hook.Add("GetFallDamage","healthadvanced", function( ply, speed )
		
		if speed > 700 and GetConVar("hpadv_legbreak"):GetBool() then
		
		if GetConVar("hpadv_scream"):GetBool() then
			ply:EmitSound("vo/npc/male01/pain0"..math.random(8, 9)..".wav", 120)
		end
		ply:EmitSound("healthadvanced/break.wav")
		
		local walk = ply:GetWalkSpeed()
		local run = ply:GetRunSpeed()
		local jump = ply:GetJumpPower()
		
		ply:SetWalkSpeed( 100 )
		ply:SetRunSpeed( 100 )
		ply:SetJumpPower( 0 )
		ply:SetEyeAngles( ply:EyeAngles() + Angle(0, 0, 5) )
		ply:SetNWBool( "hpadv_broken", true )
		
		local leg
		
		if tobool(math.random(0, 1)) then
			leg = "Gauche"
		else
			leg = "Droite"
		end
		
		ply:PrintMessage( HUD_PRINTCENTER, "Vous sentez une douleur intense dans votre jambe "..leg.."." )
		
		timer.Simple( 60, function()
			if ply:GetNWBool( "hpadv_broken" ) then
				ply:SetNWBool( "hpadv_broken", false )
				
				ply:SetWalkSpeed( walk )
				ply:SetRunSpeed( run )
				ply:SetJumpPower( jump )
				
				ply:SetEyeAngles( ply:EyeAngles() + Angle(0, 0, -5) )
			end
		end )
		
		elseif GetConVar("hpadv_scream"):GetBool() then
			ply:EmitSound("vo/npc/male01/pain0"..math.random(1, 6)..".wav")
		end

	end)

	hook.Add( "PlayerFootstep", "healthadvanced", function( ply, pos, foot, sound, volume, rf )
		if ply:GetNWBool( "hpadv_broken" ) and foot == 1 then
			if GetConVar("hpadv_scream"):GetBool() then
				ply:EmitSound( "vo/npc/male01/ow0"..math.random(1, 2)..".wav", nil, math.random(90, 110) )
			end
			ply:SetHealth( ply:Health() - 1 )
		end
	end)

	hook.Add( "PlayerDeath", "healthadvanced", function ( ply )
		if ply:GetNWBool( "hpadv_broken" ) then
			ply:SetNWBool( "hpadv_broken", false )
		end
	end)
else

	-- Tab in Utilities
	local function hpadv( DForm )
		DForm:CheckBox( "Enable screaming", "hpadv_scream" )
		DForm:CheckBox( "Enable breaking legs", "hpadv_legbreak" )
		DForm:NumSlider( "Time before regeneration", "hpadv_regtime", 2, 60 )
		DForm:NumSlider( "Regenerate up to ... percent", "hpadv_regupto", 1, 100 )
	end
	
	local function hpadvMenu()
		spawnmenu.AddToolMenuOption( "Utilities", "Advanced Health", "hpadv", "Options", "", "", hpadv )
	end
	
	hook.Add( "PopulateToolMenu", "hpadv_menu", hpadvMenu )

	-- Hiding stuff
	local hide = {
		CHudHealth = true,
		CHudBattery = true,
		CHudPoisonDamageIndicator = true,
	}
	
	hook.Add( "HUDShouldDraw", "healthadvanced", function( name ) -- Hide health, armor and neurotoxine indicators
		if ( hide[ name ] ) then
			return false -- This is actual hiding thing
		end
	end )
	
	hook.Add( "HUDDrawTargetID", "healthadvanced", function()
		return false -- Disable player name (and health, this is why I did this) visibility
	end)
	
	local mat = Material( "healthadvanced/hud_lowhealth" )
	
	hook.Add( "HUDPaint", "healthadvanced", function()
	
		-- Red overlay if low health
		local alpha = 128 - (LocalPlayer():Health() / LocalPlayer():GetMaxHealth()) * 128
		
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		
		-- Fix player name visibility, but without health
		local tr = LocalPlayer():GetEyeTrace()
		local tg = tr.Entity
		if IsValid(tg) and tg:GetClass() == "player" then
			if LocalPlayer():GetPos():Distance(tg:GetPos()) < 150 then
				local name = tg:GetName()
				local c = team.GetColor(tg:Team())
			
				surface.SetFont( "ChatFont" )
				surface.SetTextColor( c.r, c.g, c.b, 255 )
				surface.SetTextPos( ScrW()/2-#name*4, ScrH()/2+30 )
				surface.DrawText( name )
			end
		end
	end )
	
	hook.Add( "RenderScreenspaceEffects", "healthadvanced", function()
		
		-- Black'n'White world if low health 
		local alpha = (LocalPlayer():Health() / LocalPlayer():GetMaxHealth())
		
		local tab = {}
		tab[ "$pp_colour_colour" ] = alpha
		tab[ "$pp_colour_contrast" ] = 1 -- Without that everything turns absolutely black
		 
		DrawColorModify( tab ) 
		DrawMotionBlur( 0.03, 1 - alpha, 0.01 ) -- Less health = More Blur
	end )

	hook.Add( "Think", "healthadvanced", function()	
		if LocalPlayer():Health() < LocalPlayer():GetMaxHealth()/2 then
			LocalPlayer():SetDSP( 4, true )
		else
			LocalPlayer():SetDSP( 0, true )	
		end
	end )

end