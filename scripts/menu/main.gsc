init()
{
    level.fastquit = true;

    level.clientid = 0;
    level._weapons_ = [];
	level._hero_ = [];
	level.get_player_weapon_limit = ::maxweaponschecker;
    level.old_giveStartLoadout = level.giveStartLoadout;
    level.giveStartLoadout = ::CatalystStartLoadoutOverride;
    level._teams = ["allies", "axis", "team3"];
    level._boxcosts = strtok("950,0,1,1337,420,-420,-1337,1000001,666,58008,500,100,5000,10000",",");
	foreach(weapon in getArrayKeys(level.zombie_weapons))
	{
		level._weapons_[level._weapons_.size] = weapon.name;
	}

	Array::Add(level._weapons_, "minigun", 0);
	mapSpecificWeapons();

	ArrayRemoveValue(level._weapons_, "none");

	level._aat_ = getArrayKeys(level.AAT);
	
	level.__perks = [];
	foreach(val in GetEntArray("zombie_vending", "targetname"))
	{
		Array::Add(level.__perks, val.script_noteworthy, 0);
	}

	level._camos_ = [];

	for(i = 0; i < 290; i++)
	{
		row = TableLookupRow("gamedata/weapons/common/weaponoptions.csv", i);

		if(!isdefined(row) || !isdefined(row.size) || row.size < 3)
			continue;

		if(row[1] != "camo")
			continue;
		level._camos_[santize_camoname(row[2])] = int(row[0]);
	}
	level.__attach = [];

	weapon_types = ["assault", "smg", "cqb", "lmg", "sniper", "launcher"];
	
	for(i = 1; i < 255; i++)
	{
		wtype = tableLookup( "gamedata/stats/zm/zm_statstable.csv", 0, i, 2 );

		foreach(type in weapon_types)
		{
			if(("weapon_" + type) == wtype)
			{
				
				attachments = strtok(tableLookup( "gamedata/stats/zm/zm_statstable.csv", 0, i, 8 ), " ");
				foreach(attach in attachments)
				{
					Array::Add(level.__attach, attach, 0);
				}
				
			}
		}
	}
	
	level._camonames = getArrayKeys(level._camos_);

	level._bgbnames = getArrayKeys(level.bgb);

	level._statnames = ["kills", "melee_kills", "grenade_kills", "revives", "headshots", "hits", "misses", "total_shots", "time_played_total", "perks_drank", "doors_purchased", "weighted_rounds_played", "rounds", "total_points" ];
	level._fstatnames = ["Kills", "Melee Kills", "Grenade Kills", "Revives", "Headshots", "Hits", "Misses", "Total Shots", "Time Played", "Perks Consumed", "Doors Purchased", "Weighted Rounds Played", "Rounds Total", "Total Points"];
	
    level._achieves = ["CP_COMPLETE_PROLOGUE", "CP_COMPLETE_NEWWORLD", "CP_COMPLETE_BLACKSTATION", "CP_COMPLETE_BIODOMES", "CP_COMPLETE_SGEN", "CP_COMPLETE_VENGEANCE", "CP_COMPLETE_RAMSES", "CP_COMPLETE_INFECTION", "CP_COMPLETE_AQUIFER", "CP_COMPLETE_LOTUS", "CP_HARD_COMPLETE", "CP_REALISTIC_COMPLETE", "CP_CAMPAIGN_COMPLETE", "CP_FIREFLIES_KILL", "CP_UNSTOPPABLE_KILL", "CP_FLYING_WASP_KILL", "CP_TIMED_KILL", "CP_ALL_COLLECTIBLES", "CP_DIFFERENT_GUN_KILL", "CP_ALL_DECORATIONS", "CP_ALL_WEAPON_CAMOS", "CP_CONTROL_QUAD", "CP_MISSION_COLLECTIBLES", "CP_DISTANCE_KILL", "CP_OBSTRUCTED_KILL", "CP_MELEE_COMBO_KILL", "CP_COMPLETE_WALL_RUN", "CP_TRAINING_GOLD", "CP_COMBAT_ROBOT_KILL", "CP_KILL_WASPS", "CP_CYBERCORE_UPGRADE", "CP_ALL_WEAPON_ATTACHMENTS", "CP_TIMED_STUNNED_KILL", "CP_UNLOCK_DOA", "ZM_COMPLETE_RITUALS", "ZM_SPOT_SHADOWMAN", "GOBBLE_GUM", "ZM_STORE_KILL", "ZM_ROCKET_SHIELD_KILL", "ZM_CIVIL_PROTECTOR", "ZM_WINE_GRENADE_KILL", "ZM_MARGWA_KILL", "ZM_PARASITE_KILL", "MP_REACH_SERGEANT", "MP_REACH_ARENA", "MP_SPECIALIST_MEDALS", "MP_MULTI_KILL_MEDALS", "ZM_CASTLE_EE", "ZM_CASTLE_ALL_BOWS", "ZM_CASTLE_MINIGUN_MURDER", "ZM_CASTLE_UPGRADED_BOW", "ZM_CASTLE_MECH_TRAPPER", "ZM_CASTLE_SPIKE_REVIVE", "ZM_CASTLE_WALL_RUNNER", "ZM_CASTLE_ELECTROCUTIONER", "ZM_CASTLE_WUNDER_TOURIST", "ZM_CASTLE_WUNDER_SNIPER", "ZM_ISLAND_COMPLETE_EE", "ZM_ISLAND_DRINK_WINE", "ZM_ISLAND_CLONE_REVIVE", "ZM_ISLAND_OBTAIN_SKULL", "ZM_ISLAND_WONDER_KILL", "ZM_ISLAND_STAY_UNDERWATER", "ZM_ISLAND_THRASHER_RESCUE", "ZM_ISLAND_ELECTRIC_SHIELD", "ZM_ISLAND_DESTROY_WEBS", "ZM_ISLAND_EAT_FRUIT", "ZM_STALINGRAD_NIKOLAI", "ZM_STALINGRAD_WIELD_DRAGON", "ZM_STALINGRAD_TWENTY_ROUNDS", "ZM_STALINGRAD_RIDE_DRAGON", "ZM_STALINGRAD_LOCKDOWN", "ZM_STALINGRAD_SOLO_TRIALS", "ZM_STALINGRAD_BEAM_KILL", "ZM_STALINGRAD_STRIKE_DRAGON", "ZM_STALINGRAD_FAFNIR_KILL", "ZM_STALINGRAD_AIR_ZOMBIES", "ZM_GENESIS_EE", "ZM_GENESIS_SUPER_EE", "ZM_GENESIS_PACKECTOMY", "ZM_GENESIS_KEEPER_ASSIST", "ZM_GENESIS_DEATH_RAY", "ZM_GENESIS_GRAND_TOUR", "ZM_GENESIS_WARDROBE_CHANGE", "ZM_GENESIS_WONDERFUL", "ZM_GENESIS_CONTROLLED_CHAOS", "DLC2_ZOMBIE_ALL_TRAPS", "DLC2_ZOM_LUNARLANDERS", "DLC2_ZOM_FIREMONKEY", "DLC4_ZOM_TEMPLE_SIDEQUEST", "DLC4_ZOM_SMALL_CONSOLATION", "DLC5_ZOM_CRYOGENIC_PARTY", "DLC5_ZOM_GROUND_CONTROL", "ZM_DLC4_TOMB_SIDEQUEST", "ZM_DLC4_OVERACHIEVER", "ZM_PROTOTYPE_I_SAID_WERE_CLOSED", "ZM_ASYLUM_ACTED_ALONE", "ZM_THEATER_IVE_SEEN_SOME_THINGS"];

    PrecachePerks();
	PrecacheMusic();

	level.old_lost_perk = level.perk_lost_func;
	level.perk_lost_func = ::LostPerkOverride;

    level thread FastQuitMonitor();
}

on_player_connect()
{
    if(isdefined(level.nojoin) && level.nojoin)
        kick(self getEntityNumber());
    
	self.clientid = matchRecordNewPlayer(self);

	if(!isdefined(self.clientid) || self.clientid == -1)
	{
		self.clientid = level.clientid;
		level.clientid++;
	}

    if(self ishost())
    {
        precachezones();
        precacheCraftables();
        self thread CatalystAntiEnd();
    }
        
}

on_player_spawned()
{
	self.bvars = [];
    self.allclientsmode = false;

    if(!isdefined(self.originalindex))
        self.originalindex = self.characterindex;
    
    if(self isHost() && (!isdefined(self.access) || self.access < 4))
    {
        self FreezeControls( false );
        self thread initializeSetup( self, 4 );
    }
    
    self thread ProjectileFireMonitor();
    wait .1;
    self notify("stop_player_out_of_playable_area_monitor");

    wait 3;
    
    if(IS_RECOVERY)
        self enableInvulnerability();
}

lloop()
{
    if(!IS_RECOVERY)
        return;
        
    
    level.fastquit = false;

    while(1)
    {
        self ReportLootReward("3", 250);
        uploadstats(self);
        self iPrintLnBold("Awarded ^3250^7 liquid");
        wait 1;
    }
}

OccasionalStatsUpload()
{
    level endon("end_game");
    while(1)
    {
        wait 3;
        uploadstats(self);
    }
}

CatalystAntiEnd()
{
    level waittill("end_game");
    self endon("disconnect");

    text = self createText("bigfixed", 1, "CENTER", "CENTER", 0, -200, 99, 1, "Hold ^3[{+melee}]^2 to restart the match", (0,1,0));  
    text.archived = true;

    while(!self meleeButtonPressed())
        wait .025;
    map_restart(0);
}

CatalystAntiDown()
{
    self endon("end_menu");
    level endon("end_game");
    self endon("disconnect");
    self thread CatalystAntiDeath();

    self.crevtext = self createText("bigfixed", 1, "CENTER", "CENTER", 0, -200, 99, 0, "Hold ^3[{+melee}]^2 to revive yourself", (0,1,0));
    while(1)
    {
        wait 1;
        if((!self laststand::player_is_in_laststand()) || (self.sessionstate == "spectator"))
            continue;
        
        self.crevtext settext("Hold ^3[{+melee}]^2 to revive yourself");
        self.crevtext.alpha = 1;

        while(self laststand::player_is_in_laststand() && self.sessionstate != "spectator")
        {
            wait .025;
            if(!self meleeButtonPressed())
                continue;
            
            self zm_laststand::auto_revive( self );
            break;
        }

        wait 1;
        if(self.sessionstate != "spectator")
            self.crevtext.alpha = 0;
    }
}

CatalystAntiDeath()
{
    self endon("end_menu");
    level endon("end_game");
    self endon("disconnect");

    while(1)
    {
        wait 1;
        if(self.sessionstate != "spectator")
            continue;

        self.crevtext.alpha = 1;
        
        while(self.sessionstate == "spectator")
        {
            self.crevtext settext("Hold ^3Use Button^2 to respawn");
            wait .025;
            if(!self useButtonPressed())
                continue;
            
            if (isDefined(self.spectate_hud))
            {
                self.spectate_hud destroy();
            }
            self [[ level.spawnplayer ]]();

            break;
        }

        self.crevtext.alpha = 0;
    }
}

santize_camoname(camoname)
{
	if(!isdefined(camoname))
		return;
	
	result = "";
	i = 0;

	if(camoname[i] == "c")
		i = 5;

	for(; i < camoname.size; i++)
	{
		if(camoname[i] == "_")
			continue;
		
		result += camoname[i];
	}

	return result;
}

mapSpecificWeapons()
{
	switch(level.script)
	{
		default:
			Array::Add(level._weapons_, "tesla_gun", 0);
			Array::Add(level._weapons_, "zombie_beast_grapple_dwr", 0);
			level.SwordTypeArray = ["None", "Normal", "Upgraded"];
		break;
	}
}

CatalystVerifiedCallback()
{
    self thread CatalystAntiDown();
    self thread CatalystRespawnLoadout(self, true);
}

CatalystRespawnLoadout(player, result)
{
    if(!isdefined(player))
        return;
    
    player.respawn_w_loadout = result;
    
    if(result)
    {
        player thread LoadoutRecorder();
    }
}

LoadoutRecorder()
{
    self endon("disconnect");
    level endon("end_game");
    while(self.respawn_w_loadout)
    {
        wait 3;
        if(self laststand::player_is_in_laststand())
            continue;
        
        if(self.sessionstate == "spectator")
            continue;

        self.catalyst_loadout = [];
        self.catalyst_perks = [];
        foreach(weapon in self GetWeaponsList())
        {
            struct = spawnstruct();
            struct.weapon = weapon;
            struct.aat = self.AAT[weapon];
            struct.options = self GetWeaponOptions(weapon);
            self.catalyst_loadout[self.catalyst_loadout.size] = struct;
        }

        foreach(perk in level.__perks)
        {
            if(self HasPerk(perk))
                self.catalyst_perks[self.catalyst_perks.size] = perk;
        }
    }
}

GiveCatalystLoadout()
{
    if(!isdefined(self.respawn_w_loadout) || !self.respawn_w_loadout)
        return;
    
    if(!isdefined(self.catalyst_loadout))
        return;
    
    foreach(weapon in self getWeaponsListPrimaries())
        self takeWeapon(weapon);

    foreach(item in self.catalyst_loadout)
    {
        weapon = item.weapon;
        options = item.options;
        
        switch(true)
        {
            case zm_utility::is_melee_weapon(weapon):
            case zm_utility::is_hero_weapon(weapon):
            case zm_utility::is_lethal_grenade(weapon):
            case zm_utility::is_tactical_grenade(weapon):
            case zm_utility::is_placeable_mine(weapon):
            case zm_utility::is_offhand_weapon(weapon):
                self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
            break;

            default:
                acvi = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, zm_weapons::is_weapon_upgraded(weapon));
                self GiveWeapon(weapon, options, acvi);
                self switchtoweaponimmediate(weapon);
                GiveAAT(self, item.aat, false, weapon);
            break;
        }
    }
    
    foreach(perk in self.catalyst_perks)
    {
        self SetPerk(perk);
        self thread zm_perks::vending_trigger_post_think(self, perk);
    }
    //todo Gobblegum
}

CatalystStartLoadoutOverride()
{
    if(isdefined(level.old_giveStartLoadout))
        self [[ level.old_giveStartLoadout ]]();
    
    if(!isdefined(self.respawn_w_loadout) || !self.respawn_w_loadout || !isdefined(self.catalyst_loadout))
        return;
    
    self GiveCatalystLoadout();
}

precachezones()
{
    spawns = struct::get_array("player_respawn_point", "targetname");
    level._telezones = [];
    level._telezones_pretty = [];
    foreach(spawn in spawns)
    {
        zname = zm_zonemgr::get_zone_from_position(spawn.origin, 1);
        if(!isdefined(zname))
            continue;
        Array::Add(level._telezones, zname, 0);
        Array::Add(level._telezones_pretty, GetSubStr(zname, 5), 0);
    }
}

FastQuitMonitor()
{
    level notify("fastquitmonitor");
    level endon("fastquitmonitor");
    level waittill("end_game");
    if(level.fastquit)
        exitLevel(0);
}