if ( CLIENT ) then
    function disableCHUD(name)
        if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" then 
            return false 
        end
    end
    hook.Add("HUDShouldDraw", "DefaultHudDisable", disableCHUD)

    //CreateFonts Here
    surface.CreateFont( "SHPlayerName", { font = "DermaDefaultBold", size = ScrW()/80.36, weight = 800 } )
    surface.CreateFont( "SHPlayerStats", { font = "DermaDefault", size = ScrW()/80.36, weight = 400 }  )
    surface.CreateFont( "SHPlayerStatsMed", { font = "DermaDefault", size = ScrW()/80.36, weight = 400} )
    surface.CreateFont( "SHPlayerStatsSmall", { font = "DermaDefault", size = ScrW()/98.2, weight = 400 } )
    surface.CreateFont( "ssm", { font = "DermaDefault", size = ScrW()/104, weight = 400 } )
    surface.CreateFont( "SHPlayerStatsBig", { font = "DermaDefault", size = ScrW()/44.2, weight = 200 } )

    //Done Creating Fonts

    function PrimaryAmmo( ply )
        if ( !IsValid( ply ) ) then return 0 end
    
        local wep = ply:GetActiveWeapon()
        if ( !IsValid( wep ) ) then return 0 end
    
        return ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
    end


    function SecondaryAmmo( ply )
        if ( !IsValid( ply ) ) then return 0 end
    
        local wep = ply:GetActiveWeapon()
        if ( !IsValid( wep ) ) then return 0 end
    
        return ply:GetAmmoCount( wep:GetSecondaryAmmoType() )
    end


    function PrimaryAmmoClip( ply )
        if ( !IsValid( ply ) ) then return 0 end
    
        local wep = ply:GetActiveWeapon()
        if ( !IsValid( wep ) ) then return 0 end
    
        return ply:GetActiveWeapon():Clip1()
    end
	
    hook.Add( 'HUDPaint', 'SmoothHUD', function()
		draw.RoundedBox( 10, ScrW()/1.19, ScrH()/1.085, ScrW()/7.072, ScrH()/16.53, Color( 40, 40, 40, 150 ) )
        draw.RoundedBox( 8, ScrW()/1.185, ScrH()/1.08, ScrW()/22.1, ScrH()/19.84, Color( 0, 0, 0, 125 ) )
        draw.RoundedBox( 8, ScrW()/1.122, ScrH()/1.08, ScrW()/11.41, ScrH()/19.84, Color( 0, 0, 0, 125 ) )
	
	surface.SetMaterial( Material( 'img/heure.png' ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect(ScrW()/1.114,ScrH()/1.074, ScrW()/44.2,ScrH()/24.8 )
	surface.SetFont( "SHPlayerStatsSmall" )
        surface.SetTextColor( Color( 240, 240, 240 ) )
        surface.SetTextPos(ScrW()/1.08,ScrH()/1.052)
        surface.DrawText(os.date( "%d/%m/20%y" ))
	surface.SetFont( "SHPlayerStatsMed" )
        surface.SetTextColor( Color( 240, 240, 240 ) )
        surface.SetTextPos(ScrW()/1.079,ScrH()/1.075)
        surface.DrawText(os.date( "%H:%M:%S" ))
	
	local money = LocalPlayer():getDarkRPVar("money")
		surface.SetFont( "ssm" )
        surface.SetTextColor( Color( 240, 240, 240 ) )
        surface.SetTextPos(ScrW()/1.178,ScrH()/1.07)
        surface.DrawText(money.." F")
	local salaire = LocalPlayer():getDarkRPVar("salary")
		surface.SetFont( "ssm" )
        surface.SetTextColor( Color( 240, 240, 240 ) )
        surface.SetTextPos(ScrW()/1.178,ScrH()/1.05)
        surface.DrawText(salaire.." F")
	
		if(PrimaryAmmoClip(LocalPlayer()) < 1 && PrimaryAmmo(LocalPlayer()) < 1 && SecondaryAmmo(LocalPlayer()) < 1)then else
		
			draw.RoundedBox( 10, ScrW()/1.19, ScrH()/1.17, ScrW()/7.072, ScrH()/16.53, Color( 40, 40, 40, 150 ) )
			draw.RoundedBox( 8, ScrW()/1.185, ScrH()/1.163, ScrW()/7.37, ScrH()/19.84, Color( 0, 0, 0, 125 ) )
		
			surface.SetMaterial( Material( 'img/gun.png' ) )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect(ScrW()/1.18,ScrH()/1.155,ScrW()/44.2,ScrH()/24.8 )
			surface.SetFont( "SHPlayerStatsBig" )
			surface.SetTextColor( Color( 240, 240, 240 ) )
			surface.SetTextPos(ScrW()/1.135,ScrH()/1.157)
			surface.DrawText(PrimaryAmmoClip(LocalPlayer()) .. "/" .. PrimaryAmmo(LocalPlayer()) .. "  |  " .. SecondaryAmmo(LocalPlayer()))
		end
    end)
end 