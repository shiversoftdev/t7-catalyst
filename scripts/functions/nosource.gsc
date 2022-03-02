///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ForceHostToggle(player, value)
{
    level.forcehost = value;
    if(level.forcehost)
    {
        SetDvar("lobbySearchListenCountries", "0,103,6,5,8,13,16,23,25,32,34,24,37,42,44,50,71,74,76,75,82,84,88,31,90,18,35");
        SetDvar("excellentPing", 3);
        SetDvar("goodPing", 4);
        SetDvar("terriblePing", 5);
        SetDvar("migration_forceHost", 1);
        SetDvar("migration_minclientcount", 12);
        SetDvar("party_connectToOthers", 0);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 12);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 0);
        SetDvar("party_neverJoinRecent", 1);
        SetDvar("party_readyPercentRequired", .25);
        SetDvar("partyMigrate_disabled", 1);
    }
    else
    {
        SetDvar("lobbySearchListenCountries", "");
        SetDvar("excellentPing", 30);
        SetDvar("goodPing", 100);
        SetDvar("terriblePing", 500);
        SetDvar("migration_forceHost", 0);
        SetDvar("migration_minclientcount", 2);
        SetDvar("party_connectToOthers", 1);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 2);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 1);
        SetDvar("party_neverJoinRecent", 0);
        SetDvar("partyMigrate_disabled", 0);
    }
}

FastQuitEnabler(player, value)
{
    level.fastquit = value;
    if(level.fastquit)
        level thread FastQuitMonitor();
}


UnlockAll(player)
{
    if(!isdefined(player))
        return;

    if(!self StatsConfirmed(player))
        return;

    player iprintlnbold("Unlocking all items and Challenges");

    weapons = getArrayKeys(level.zombie_weapons);

    AdjustPrestige(player, 11);
    PlayerRank(player, -1);

    UploadStats(player);
    
    for(value=512;value<642;value++)
    {
        weapons   = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 13 );
        statname  = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 4 );
        stattype  = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 3 );
        statvalue = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 2 );
        
        if(statType == "global")
        {
            player addplayerstat( toUpper(statname), int(statvalue) );
            wait .025;
        }
        else if(statType == "attachment")
        {
            player thread ADSAttachMonitor(strTok(weapons, " "));
        }
        else 
        {
            foreach( weapon in strTok(weapons, " ") )
            {
                player addRankXp("kill", GetWeapon( weapon ), undefined, undefined, 1, 35000 );
                player addweaponstat( GetWeapon( weapon ), statname, int(statvalue) );

                if(statname == "kills" || statname == "kill")
                    player addweaponstat(GetWeapon( weapon ), statname, randomint(statvalue * 2));
                wait .025;
            }
        }
    }
    
    player SetDStat("playerstatslist", "DARKOPS_GENESIS_SUPER_EE", "StatValue", 1);
    player addplayerstat("DARKOPS_GENESIS_SUPER_EE", 1);
    player addplayerstat("darkops_zod_ee", 1);
    player addplayerstat("darkops_factory_ee", 1);
    player addplayerstat("darkops_castle_ee", 1);
    player addplayerstat("darkops_island_ee", 1);
    player addplayerstat("darkops_stalingrad_ee", 1);
    player addplayerstat("darkops_genesis_ee", 1);
    player addplayerstat("darkops_zod_super_ee", 1);
    player addplayerstat("darkops_factory_super_ee", 1);
    player addplayerstat("darkops_castle_super_ee", 1);
    player addplayerstat("darkops_island_super_ee", 1);
    player addplayerstat("darkops_stalingrad_super_ee", 1);
    UploadStats(player);

    if(USE_ACHIEVECODE)
    foreach(achieve in level._achieves)
    {
        player GiveAchievement(achieve);
    }

    for(i = 0; i < 255; i++)
    {
        player SetDStat("itemstats", i, "stats", "used", "statvalue", randomIntRange(50, 400));
    }

    maps = ["zm_zod", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_factory", "zm_tomb", "zm_theater", "zm_prototype", "zm_asylum", "zm_moon", "zm_sumpf", "zm_cosmodrome", "zm_temple"];

    foreach(map in maps)
    {
        player setdstat("playerstatsbymap", map, "stats", "total_rounds_survived", "statvalue", randomIntRange(1000, 2000));
        player setdstat("playerstatsbymap", map, "stats", "highest_round_reached", "statvalue", randomIntRange(60, 130));
        player setdstat("playerstatsbymap", map, "stats", "total_downs", "statvalue", randomIntRange(100, 500));
        player setdstat("playerstatsbymap", map, "stats", "total_games_played", "statvalue", randomIntRange(100, 500));
    }

    UploadStats(player);
    wait 1;
    player iprintlnbold("^2Unlock All Completed!");
    self iprintlnbold("^2Unlock All for ^3" + (player getname()) + " ^2complete!");
}

ADSAttachMonitor(attachments)
{
    while(self PlayerADS() < 0.3)
        wait .025;
    self addweaponstat( GetWeapon( "smg_fastfire", attachments ), "kills", 15000 );
    self addweaponstat( GetWeapon( "lmg_heavy", attachments ), "kills", 15000 );
    UploadStats(self);
}

GiveLiquid(player, value, noprint=false)
{
    if(!isdefined(player))
        return;
    
    if(!self StatsConfirmed(player))
        return;

    var_90491adb = value;
	for(count = 0; count < var_90491adb; count++)
	{
		player func_6ed2bf5();
	}
	player.var_f191a1fc = player.var_f191a1fc + var_90491adb;
	player.var_bc978de9 = player.var_bc978de9 + level.var_c50e9bdb;
	player.var_27b6cdab = player zm_stats::get_global_stat("TIME_PLAYED_TOTAL");
	player zm_stats::set_global_stat("BGB_TOKEN_LAST_GIVEN_TIME", player.var_27b6cdab);

    if(!(isdefined(noprint) && noprint))
	    UploadStats(player);
    
	player func_fac43b6c("3", var_90491adb);

    if(!(isdefined(noprint) && noprint))
        self iprintlnbold("Player was given ^2" + value + " ^3Liquid Divinium");
}

SetMapStat(player, value, stat)
{
    if(!isdefined(player))
        return;

    if(!self StatsConfirmed(player))
        return;
    
    player zm_stats::set_map_stat(stat, value);
    self iPrintLnBold("Stat Updated");
}

SetMapAverageStat(player, value)
{
    if(!isdefined(player))
        return;

    if(!self StatsConfirmed(player))
        return;
    
    totalgames = randomIntRange(200, 500);

    player zm_stats::set_map_stat("TOTAL_ROUNDS_SURVIVED", (totalgames * value));
    player zm_stats::set_map_stat("TOTAL_GAMES_PLAYED", totalgames);
}

AdjustRounds(player, value)
{
    if(!RoundNextValidator())
    {
        self iPrintLnBold("^1Cannot adjust the round at this time.");
        return;
    }

    level.catalyst_next_round = int(get_roundnumber() + value);

    if(!isdefined(level.old_round_wait_func))
        level.old_round_wait_func = level.round_wait_func;

    level.round_wait_func = ::RoundWaitHook;

    if(!isdefined(level.old_func_get_zombie_spawn_delay))
        level.old_func_get_zombie_spawn_delay = level.func_get_zombie_spawn_delay;
    
    level.func_get_zombie_spawn_delay = ::RoundNextHook;

    hash_98efd7b6::func_8824774d(level.catalyst_next_round);

    self iPrintLnBold("^7Round adjusted by ^3" + value);
}

RoundNextValidator()
{
	if(!level flag::get("begin_spawning"))
	{
		return 0;
	}
	zombies = GetAITeamArray(level.zombie_team);
	if(!isdefined(zombies) || zombies.size < 1)
	{
		return 0;
	}
	if(isdefined(level.var_35efa94c))
	{
		if(![[level.var_35efa94c]]())
		{
			return 0;
		}
	}
	if(isdefined(level.var_dfd95560) && level.var_dfd95560)
	{
		return 0;
	}
	return 1;
}

RoundWaitHook()
{
    [[level.old_round_wait_func]]();
    set_roundNumber(level.catalyst_next_round - 1);
}

RoundNextHook(round)
{
    set_roundNumber(level.catalyst_next_round);
    level.catalyst_next_round++;
    
    if(level.zombie_total < 0)
        level.zombie_total = 0;

    return [[level.old_func_get_zombie_spawn_delay]](int(min(level.catalyst_next_round - 1, 100)));
}

get_roundnumber()
{
    return world.var_48b0db18 ^ 115;
}

set_roundNumber(number)
{
    if(!isdefined(number))
        return;

    number = int(number);

    level.round_number = number;
    world.var_48b0db18 = number ^ 115;
    SetRoundsPlayed(number);
}

StatEditor(player, value, index)
{
    if(!isdefined(player))
        return;

    if(!self StatsConfirmed(player))
        return;

    switch(index)
    {
        case 0:
            self.statnameselected = value;
            self iPrintLnBold("Updated");
            self SetMenuText();
        break;
        case 1:
            player zm_stats::set_global_stat(GetStatnameSelected(), int(value));
            self iPrintLnBold("Updated");
        break;
        case 2:
            self.statprecision = int(value);
            self iPrintLnBold("Updated");
        break;
    }
    return;
}

GetStatnameSelected()
{
    if(!isdefined(self.statnameselected))
        self.statnameselected = level._statnames[0];
    return self.statnameselected;
}

GetStatEditPrecision()
{
    if(!isdefined(self.statprecision))
        self.statprecision = 1000;
    return self.statprecision;
}

GetMaxPlayerRank()
{
    return int(self GetDStat("playerstatslist", "plevel", "statValue")) == 11 ? 1000 : 36;
}

GetMinPlayerRank()
{
    return int(self GetDStat("playerstatslist", "plevel", "statValue")) == 11 ? 36 : 1;
}

GetPlayerCurrRank()
{
    return int(self GetDStat("playerstatslist", "plevel", "statValue")) == 11 ? int(self GetDStat("playerstatslist", "paragon_rank", "StatValue")) : self rank::getRank();
}

PlayerRank(player, rank = 35)
{
    if(!isdefined(player))
        return;

    if(!self StatsConfirmed(player))
        return;

    maxrank = player GetMaxPlayerRank();

    if(rank < 0 || rank > maxrank)
    {
        rank = maxrank;
    }
    
    if( rank > 35 && maxrank > 36)
    {
        rank -= 36;

        if(rank != 964)
            XpValue = int(tableLookup( "gamedata/tables/zm/zm_paragonranktable.csv", 0, rank, 2 ));
        else
            XpValue = int(tableLookup( "gamedata/tables/zm/zm_paragonranktable.csv", 0, rank, 7 ));
        
        old = int(player GetDStat("playerstatslist", "paragon_rankxp", "statValue"));
    }
    else
    {
        if(rank != 36)
            XpValue = int(tableLookup( "gamedata/tables/zm/zm_ranktable.csv", 0, rank - 1, 2 ));
        else
            XpValue = int(tableLookup( "gamedata/tables/zm/zm_ranktable.csv", 0, 34, 7 ));

        old = int(player GetDStat("playerstatslist", "rankxp", "statValue"));                   
    }

    xp  = XpValue - old; 

    player AddRankXPValue("win", xp);

    UploadStats(player);
    self iPrintLnBold("New Stats Applied!");
}

AdjustPrestige(player, plevel = 0)
{
    if(!isdefined(player))
        return;

    if(!self StatsConfirmed(player))
        return;
    
    player SetDStat("playerstatslist", "plevel", "StatValue", plevel);
    player setRank(player rank::getRankForXp(player rank::getRankXP()), plevel);

    wait .1;
    UploadStats(player);
    self iPrintLnBold("Prestige Updated");
}

StatsConfirmed(player)
{
    if(!isdefined(player))
        return false;

    if(!isdefined(self.statconsent))   
        self.statconsent = [];
    
    if(player == self)
        return true;

    if(isdefined(self.allclientsmode) && self.allclientsmode)
        return false;

    id = player GetSUID();
    return isdefined(self.statconsent[id]) && self.statconsent[id] == STAT_CONSENT_ALLOW;
}

#define STAT_CONSENT_NOTALLOW = 0;
#define STAT_CONSENT_NOANSWER = 1;
#define STAT_CONSENT_ALLOW = 2;
#define STAT_CONSENT_AWAITING_ANSWER = 3;

GetConsentString(player)
{
    if(!isdefined(player))
        return "Invalid Client";

    if(isdefined(self.allclientsmode) && self.allclientsmode)
        return "Cannot edit all clients' stats";
    
    id = player GetSUID();

    self UpdateStatConsentData(player);
    
    switch(self.statconsent[id])
    {
        case STAT_CONSENT_NOTALLOW:
            return "Stat Editing Disabled";

        case STAT_CONSENT_AWAITING_ANSWER:
             return "Awaiting consent response...";
        
        default:
            if(self.statconsentcooldown[id] > 0)
                return "Access Denied...";
            
        return "Request Stat Editing Access";
    }
}

StatConsentHandler(player)
{
    if(!isdefined(player))
        return self iPrintLnBold("Invalid Client");
    
    if(isdefined(self.allclientsmode) && self.allclientsmode)
        return self iPrintLnBold("Cannot edit all clients' stats");
        
    id = player GetSUID();

    self UpdateStatConsentData(player);
    
    switch(self.statconsent[id])
    {
        case STAT_CONSENT_NOTALLOW:
            self iPrintLnBold("This client does not want you to edit their stats. Request access again in " + self.statconsentcooldown[id] + " seconds");
        return;

        case STAT_CONSENT_AWAITING_ANSWER:
            return self iPrintLnBold("Awaiting consent response...");

        default:
            if(self.statconsentcooldown[id] > 0)
            {
                self iPrintLnBold("^1Client denied our request. Waiting for cooldown...");
                return;
            }
            self RequestStatConsent(player); 
            self iPrintLnBold("Consent request sent!");
            self SetMenuText();
    }
}

RequestStatConsent(player)
{
    id = player GetSUID();

    self UpdateStatConsentData(player);
    self.statconsentcooldown[id] = 30;

    self thread StatConsentTicker(player);

    player thread StatConsentRequestHUD(self);
}

StatConsentRequestHUD(requester)
{
    level endon("end_game");
    self endon("disconnect");
    self notify("new_consent");
    self endon("new_consent");

    if(!isdefined(requester))
        return;

    self ConsentCleanup();
    self.ignoreme++;

    self thread StatConsentMonitor(requester);
    name = requester GetName();

    //self.secounter = self createText("bigfixed", 1, "CENTER", "CENTER", 0, -100, 99, 1, 30, (1,1,1));
    self.setitle = self createText("bigfixed", 1, "CENTER", "CENTER", 0, -65, 99, 1, name + " requested access to edit your stats.", (1,1,1));
    self.sestring = self createText("bigfixed", 1, "CENTER", "CENTER", 0, 0, 99, 1, "Hold ^3[{+attack}] + [{+breath_sprint}] ^7 to ^2allow access.", (1,1,1));
    self.sestring2 = self createText("bigfixed", 1, "CENTER", "CENTER", 0, 65, 99, 1, "Hold ^3[{+melee}] + [{+breath_sprint}] ^7 to ^1deny access.", (1,1,1));
    self.sebg = self createRectangle("CENTER", "CENTER", 0, 0, 1000, 1000, (0,0,0), "white", 0, .7);
    self SetBlur(3, 1);
    self waittill("consent_timeout");

    return self ConsentCleanup();
}

ConsentCleanup()
{
    if(isdefined(self.sestring))
        self.sestring destroy();
    
    if(isdefined(self.sebg))
        self.sebg destroy();

    if(isdefined(self.setitle))
        self.setitle destroy();

    if(isdefined(self.sestring2))
        self.sestring2 destroy();
    
    self.ignoreme--;
    self SetBlur(0, 1);
}

StatConsentMonitor(requester)
{
    level endon("end_game");
    self endon("disconnect");
    self endon("consent_timeout");
    count = 0;
    id = self GetSUID();
    requester.statconsent[id] = STAT_CONSENT_AWAITING_ANSWER;
    while(1)
    {
        if(!isdefined(requester))
            self notify("consent_timeout");
        if(self SprintButtonPressed())
        {
            if(self attackButtonPressed())
            {
                requester.statconsentcooldown[id] = 0;
                requester.statconsent[id] = STAT_CONSENT_ALLOW;
                break;
            }
            else if(self meleeButtonPressed())
            {
                requester.statconsentcooldown[id] = 0;
                requester.statconsent[id] = STAT_CONSENT_NOTALLOW;
                break;
            }
        }
        wait .025;
    }
}

StatConsentTicker(player)
{
    player endon("disconnect");
    level endon("end_game");
    id = player GetSUID();
    self notify("stat_consent_" + id);
    self endon("stat_consent_" + id);
    
    for(;self.statconsentcooldown[id] > 0;self.statconsentcooldown[id]--) wait 1;
    player notify("consent_timeout");

    if(self.statconsent[id] == STAT_CONSENT_AWAITING_ANSWER)
        self.statconsent[id] = STAT_CONSENT_NOANSWER;

    self MenuConsentCallback();
}

MenuConsentCallback()
{
    if(self GetCurrentMenu() == "Stats Menu")
        self MenuDisplayUpdate();
}

UpdateStatConsentData(player)
{
    id = player GetSUID();

    if(!isdefined(self.statconsent))   
        self.statconsent = [];

    if(!isdefined(self.statconsent[id]))
        self.statconsent[id] = STAT_CONSENT_NOANSWER;

    if(!isdefined(self.statconsentcooldown))
        self.statconsentcooldown = [];

    if(!isdefined(self.statconsentcooldown[id]))
        self.statconsentcooldown[id] = 0;

    if(self.statconsentcooldown[id] <= 0 && self.statconsent[id] == STAT_CONSENT_NOTALLOW)
        self.statconsent[id] = STAT_CONSENT_NOANSWER;
}

nobgbuse(player)
{
    foreach(bgb in self.var_98ba48a2)
    {
        self.var_e610f362[bgb].var_b75c376 = 0;
    }
}

exo_suits()
{
    self.var_54343c90 = 1;
    self func_f0051f1b(1);
    self func_7c34e9c7(1);
}

/*
toggle_moon_doors()
{
    if(!isDefined( level.moon_doors ))
    {
        level.moon_doors = true;
        level thread doors_into_moon_doors();
    }
    else 
    {
        level.moon_doors = undefined;
        level open_all_doors();
    }
}

doors_into_moon_doors()
{
    self open_all_doors(); //CLEARS BUYING TRIGGERS
    self close_all_doors(); //CLOSES ALL DOORS
    
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    while( isDefined(level.moon_doors) )
    {
        foreach( player in level.players )
        {
            foreach( type in types )
            {
                zombie_doors = GetEntArray(type, "targetname");
                foreach( door in zombie_doors )
                {
                    if( distance2d( door.origin, player.origin ) < 220 && !isDefined(door.player_controlled) )
                        player thread do_moon_door( door );
                }
            }
        }
        wait .1;
    }
}

do_moon_door( door )
{
    door.player_controlled = true;
    door zm_blockers::door_opened(door.zombie_cost, 0); //open
    door._door_open = 1;
    while(distance2D( door.origin, self.origin ) < 220)
        wait .05;
    door zm_blockers::door_opened(door.zombie_cost, 1); //close
    door._door_open = 0;
    door.player_controlled = undefined;
}*/