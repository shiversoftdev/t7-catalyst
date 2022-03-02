GetToggleState(index = "none", player = self)
{
    if(TOG_INCLUDEHOST == index)
        return isdefined(player.ac_includehost) && player.ac_includehost;
    
    if(isdefined(self.allclientsmode) && self.allclientsmode && level.players.size > 1)
    {
        foreach(client in level.players)
        {
            if(client IsHost() && !(isdefined(self.ac_includehost) && self.ac_includehost))
                continue;

            cstate = __tgs(index, client);
            if(!(isdefined(cstate) && cstate))
                return false;
        }
        return true;
    }

    cstate = __tgs(index, player);
    return isdefined(cstate) && cstate;
}

__tgs(index, player)
{
    if(!isdefined(player))
        return false;
    
    if(!isdefined(index))
        return false;
    
    switch(index)
    {
        case TOG_FORCEHOST:
            return level.forcehost;

        case TOG_WEAPON_UPGRADED:
            return player HasUpgradedWep();

        case TOG_RETAIN_PERKS:
            return player._retain_perks;

        case TOG_ALL_PERKS:
            return player HasAllPerks();

        case TOG_ALL_MAGIC_PERKS:
            return player HasAllMagicPerks();

        case TOG_IS_DOWNED:
            return !(player laststand::player_is_in_laststand()) && player.sessionstate != "spectator";

        case TOG_IS_ALIVE:
            return player.sessionstate != "spectator";

        case TOG_INCLUDEHOST:
            return player.ac_includehost;

        case TOG_RESPAWN_W_LOADOUT:
            return player.respawn_w_loadout;

        case TOG_MATCHFLAG_ANTIQUIT:
            return level.perfect_antiquit;

        case TOG_MATCHFLAG_ANTIJOIN:
            return level.nojoin;

        case TOG_POWERUP_UNLIMITED:
            return isdefined(level._powerup_timeout_custom_time);

        case TOG_SHADOWS_MARGWAS_ALLOWED:
            return level flag::get("can_spawn_margwa");
        
        case "Godmode":
            return player InvulnerableTest();
        
        case TOG_NOBOXMOVE:
            return level.chest_min_move_usage == 999;

        case TOG_ENDLESSWAIT:
            return isdefined(level.custom_magic_box_weapon_wait) &&
                    level.custom_magic_box_weapon_wait == ::boxforever;

        case TOG_FASTQUIT:
            return level.fastquit;

        default:

            if(StrStartsWith(index, "has_attachment_"))
                return WeaponHasAttachment(player getCurrentWeapon(), GetSubStr(index, 15));                
            
            if(StrStartsWith(index, "has_perk_"))
                return player HasPerk(GetSubStr(index, 9));

            if(StrStartsWith(index, "tog_aat_"))
                return level.AAT[GetSubStr(index, 8)].occurs_on_death;

        return player GetBVarEnabled(index);
    }
}

InvulnerableTest()
{
    was_inv = self EnableInvulnerability();
    if(was_inv)
        return true;
    self disableInvulnerability();
    return false;
}

SetBVar(index, value)
{
    if(!isdefined(self.bvars))
        self.bvars = [];
    
    self.bvars[index] = isdefined(value) && value;
    return value;
}

ToggleBVar(bvar)
{
    if(!isdefined(self.bvars))
        self.bvars = [];
    
    self.bvars[bvar] = !(isdefined(self.bvars[bvar]) && self.bvars[bvar]);
    return self.bvars[bvar];
}

BoolFunction(player, result, ID)
{
    player SetBVar(ID, result);
    switch(ID)
    {
        case "Godmode":
            if(result)
                player EnableInvulnerability();
            else
                player DisableInvulnerability();
            break;
        case "Invisibility":
            if(result)
            {
                player Hide();
            }
            else
            {
                player Show();
            }
            player.ignoreme = result;
            break;
        case "Third Person":
            player setclientthirdperson( result );
            break;
    }
}

GetBVarEnabled(bvar)
{
    return (isdefined(self.bvars[bvar]) && self.bvars[bvar]);
}

InfiniteAmmo(player, result)
{
    level endon("game_ended");
    level endon("game_end");
    player endon("disconnect");

    player SetBVar("Infinite Ammo", result);

    while(isdefined(player) && player GetBVarEnabled("Infinite Ammo"))
    {
        weapon = player getcurrentweapon();
        if(weapon != "none")
        {
            player setWeaponAmmoClip(weapon, 1337);
            player giveMaxAmmo(weapon);
        }
        if(player getCurrentOffHand() != "none")
            player giveMaxAmmo(player getCurrentOffHand());
        player util::waittill_any("weapon_fired", "grenade_fire", "missile_fire");
    }
}


ANoclipBind(player, result)
{
    level endon("game_ended");
    level endon("end_game");
    player endon("disconnect");

    if(!isdefined(player))
        return;
    
    player SetBVar("No Clip", result);

    if(!player GetBVarEnabled("No Clip"))
        return;
    
	player iprintlnbold("^2Press [{+frag}] ^3to ^2Toggle No Clip");

	normalized = undefined;
	scaled = undefined;
	originpos = undefined;
	player unlink();
	player.originObj delete();

	while( player GetBVarEnabled("No Clip") )
	{
		if( player fragbuttonpressed())
		{
			player.originObj = spawn( "script_origin", player.origin, 1 );
    		player.originObj.angles = player.angles;
			player PlayerLinkTo( player.originObj, undefined );

			while( player fragbuttonpressed() )
				wait .1;
			
            player iprintlnbold("No Clip ^2Enabled");
            player iPrintLnBold("[{+breath_sprint}] to move");

			player enableweapons();
			while( player GetBVarEnabled("No Clip") )
			{
				if( player fragbuttonpressed() )
					break;
                
				if( player SprintButtonPressed() )
				{
					normalized = AnglesToForward(player getPlayerAngles());
					scaled = vectorScale( normalized, 60 );
					originpos = player.origin + scaled;
					player.originObj.origin = originpos;
				}
				wait .05;
			}

			player unlink();
			player.originObj delete();

			player iprintlnbold("No Clip ^1Disabled");

			while( player fragbuttonpressed() )
				wait .1;
		}
		wait .1;
	}
}

UpdatePlayerAlive(player, result)
{
    if(!isdefined(player))
        return;

    if(!result)
    {
        player notify("player_suicide");
        player zm_laststand::bleed_out();
    }
    else
    {
        if (isDefined(player.spectate_hud))
        {
            player.spectate_hud destroy();
        }
        player [[ level.spawnplayer ]]();
    }
}

UpdatePlayerDowned(player, result)
{
    if(!isdefined(player))
        return;

    if(result)
    {
        player zm_laststand::auto_revive(player);
    }
    else
    {
        player disableInvulnerability();
        player.bvars["Godmode"] = false;
        player dodamage(player.maxhealth + 1, player.origin);
    }
}

PerfectAQ(player, result)
{
    level.perfect_antiquit = result;
    if(isdefined(result) && result)
    {
        setmatchflag("disableIngameMenu", 1);
        foreach(player in level.players)
        {
            player closeingamemenu();
        }
    } 
    else
    {
        setmatchflag( "disableIngameMenu", 0 );
    }
}

AntiJoin(player, result)
{
    level.nojoin = result;
}

BoxMoverState(player, state)
{
    if(state)
    {
        level flag::clear("moving_chest_enabled");
        foreach(chest in level.chests)
            chest.no_fly_away = 1;
        level.chest_min_move_usage = 999;
    }
    else
    {
        level flag::set("moving_chest_enabled");
        foreach(chest in level.chests)
            chest.no_fly_away = 0;
        level.chest_min_move_usage = 4;
    }

}

BoxEndlessWait(player, value)
{
    if(value)
    {
        level.custom_magic_box_weapon_wait = ::boxforever;
    }
    else
    {
        level.custom_magic_box_weapon_wait = undefined;
        level notify("boxforever");
    }
}