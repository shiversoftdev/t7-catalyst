//TODO SetInvisibleToPlayer(<player>, [setInvisible]) fuckery here, just cant think of what
//TODO SetVisibleToPlayer(<player>)
//TODO HidePart tag_weapon
//TODO intersection monitor
//TODO force player stance
//TODO mystery box mods
//TODO zombies mods
//TODO powerups
//TODO perk machine orbit (and reset)
//TODO void <player> ViewKick(<damage>, <origin>)
//TODO teleport zombies to player
//TODO Health Bar
//TODO spawn clone
//TODO Save/Load Position
//TODO jetpack (bo3)
//TODO real portal gun?
//TODO FORGE
//TODO Open all Doors
//TODO Gobbles menu
//TODO Turn player
//void <entity> SetScale(<scale>)
//void <entity> SetWeaponRenderOptions(<camo index>, <reticle index>, <show player tag>, <show emblem>, <show paintshop>)
//void SpawnPlane(<player>, <classname>, <origin>, [spawnflags])
//void EnumerateWeapons(<weapon type>)
menuOptions()
{
    menu = self.menu["current"];

    //prevents undefined behavior that would break the switch
    if(!isdefined(menu))
        menu = "none";

    switch(menu)
    {
        case "main":
        self addMenu("main", "by Serious");
            self addOpt("Personal Mods", ::newMenu, "Personal Mods");
            self addOpt("Powerups Menu", ::newMenu, "Powerups Menu");
            self addOpt("Zombies Menu", ::newMenu, "Zombies Menu", 2);
            self addOpt("Map Mods", ::newMenu, "Map Mods", 3);
            self addOpt("Lobby Mods", ::newMenu, "Lobby Mods", 3);
            self addOpt("Host Mods", ::newMenu, "Host Mods", 4);
            self addOpt("Game Settings", ::newMenu, "Game Settings", 4);
            self addOpt("Clients Menu", ::newMenu, "clients", 2);
        break;

        case "Personal Mods":
        self.selectedplayer = undefined;
        self addMenu("Personal Mods", "Personal Mods");
            self.selectedplayer = self;
            self playeroptions(menu);
        break;

        case "Powerups Menu":
        self AddMenu("Powerups Menu", "Powerups Menu");
            self addToggle("No Timeout", TOG_POWERUP_UNLIMITED, ::UnlimitedPowerupTime);
            self AddSliderString("Spawn Powerup", getArrayKeys(level.zombie_powerups), undefined, ::SpawnPowerup);
        break;

        case "Zombies Menu":
        self addMenu("Zombies Menu", "Zombies Menu");
            self addToggle("Zombie Minimap", "Zombie Minimap", ::ZombiesMinimap);
            self addSliderValue("Spawn Zombie", 1, 1, 40, 1, ::SpawnZombieArray);
            self addOpt("Kill All Zombies", ::KillAllZombies);
        break;

        case "Map Mods":
        self addMenu("Map Mods", "Map Mods");
            self AddMapOptions();
        break;

        case "Game Settings":
        self addMenu("Game Settings", "Game Settings");
            self addOpt("AAT Settings", ::newMenu, "aat");
            self addFactorSlider("Adjust Round Number", 1, -9, 9, 10, 1, ::AdjustRounds);
            self addToggle("Anti-Quit", TOG_MATCHFLAG_ANTIQUIT, ::PerfectAQ);
            self addToggle("Anti-Join", TOG_MATCHFLAG_ANTIJOIN, ::AntiJoin);
        break;

        case "aat":
        self addMenu("aat", "Alternate Ammo Types");
            foreach(aat in level._aat_)
                if(aat != "none")
                    self addOpt(aat, ::newMenu, aat);
        break;
        
        case "zm_aat_turned":
        case "zm_aat_dead_wire":
        case "zm_aat_fire_works":
        case "zm_aat_thunder_wall":
        case "zm_aat_blast_furnace":
        self addMenu(menu, menu);
            self addSliderValue("Activation Chance", .25, 0, 1, .05, ::EditAATParameter, menu, 0);
            self addSliderValue("Victim Cooldown", 0, 0, 60, 2, ::EditAATParameter, menu, 1);
            self addSliderValue("Personal Cooldown", 0, 0, 60, 2, ::EditAATParameter, menu, 2);
            self addSliderValue("Global Cooldown", 0, 0, 60, 2, ::EditAATParameter, menu, 3);
            self addToggle("Occurs on Death", "tog_aat_" + menu, ::ToggleAATOnDeath, menu);
        break;

        case "Lobby Mods":
        self addMenu("Lobby Mods", "Lobby Mods");
            self AddSliderString("Music Player", level._cmusic, level._cmusicnames, ::NextSong);
            self AddSliderString("Collect Parts", level._craftnames, undefined, ::GrabCraftable);
            self addOpt("Mystery Box Mods", ::newMenu, "Mystery Box Mods");
        break;

        case "Mystery Box Mods":
        self addMenu("Mystery Box Mods", "Mystery Box Mods");
            self AddOpt("Show All", ::AllBoxStates, true);
            self addopt("Hide All", ::AllBoxStates, false);
            self addToggle("Box Never Moves", TOG_NOBOXMOVE, ::BoxMoverState);
            self addToggle("Infinite Wait", TOG_ENDLESSWAIT, ::BoxEndlessWait);
            self addsliderstring("Box Cost", level._boxcosts, undefined, ::AdjustBoxCost);

        break;

        case "Host Mods":
        self addMenu("Host Mods", "Host Mods");
            self addToggle("Force Host", TOG_FORCEHOST, ::ForceHostToggle);
            self AddToggle("Fast Quit", TOG_FASTQUIT, ::FastQuitEnabler);
            self addOpt("Restart Map", ::SessionEnd, 1);
            self addOpt("End Game", ::SessionEnd, 0);
            self addOpt("Kill Server", ::SessionEnd, 2);
        break;

        case "clients":
        self.selectedplayer = undefined;
        self.allclientsmode = false;
        self addmenu( "clients", "Clients Menu" );
            self addopt("All Clients Menu", ::newmenu, "All Clients Menu", 4);
            foreach(player in level.players)
                self addopt(player getname(), ::newmenu, "client_" + (player getsuid()));

            if(level.players.size < GetDvarInt("party_maxplayers"))
                self AddOpt("Add Test Client", ::BotSpawn);
        break;

        case "All Clients Menu":
        self.allclientsmode = true;
        self.selectedplayer = self;
        self AddMenu("All Clients Menu", "All Clients Menu");
            self addToggle("Include Host", TOG_INCLUDEHOST, ::ToggleIncludeHost);
            self clientOptions(menu);
        break;
        
        default:
            self clientOptions(menu);
        break;
    }
}

playeroptions(menu)
{
    player = self.selectedplayer;
    if(isdefined(player))
        self thread MenuDCUpdate(player);
    switch(menu)
    {
        case "Weapon Mods":
        self addmenu("Weapon Mods", self FormatTitle("Weapon Mods"));
            self addToggle("Pack a Punch", TOG_WEAPON_UPGRADED, ::TogglePapWeapon);
            self AddOpt("Edit Attachments", ::newmenu, "Edit Attachments");
            self AddOpt("Edit Projectiles", ::newmenu, "Edit Projectiles", 2);
            self addSliderString("Give Weapon", level._weapons_, undefined, ::GiveClientWeapon);
            self addSliderString("Set Weapon Camo", level._camonames, undefined, ::GiveCamo);
            self addSliderString("Set Weapon AAT", level._aat_, undefined, ::GiveAAT);
            self addSliderValue("Set Max Weapons", 2, 0, 8, 1, ::SetMaxWeapons);
            self addToggle("Respawn with Loadout", TOG_RESPAWN_W_LOADOUT, ::CatalystRespawnLoadout);
            self addToggle("Cluster Grenades", "Cluster Grenades", ::Clusters);
            self addToggle("Unlimited Specialist", "Unlimited Specialist", ::UnlimitedSpecial);
            self addOpt("Charge Specialist", ::ChargeSpecial);
            self AddToggle("Invisible Weapons", "Invisible Weapons", ::InvisWeaponsToggle);
            self addOpt("Drop Weapon", ::DropWeapon);
            self addOpt("Drop all Weapons", ::DropAllWeps);
            self addToggle("Butterfingers", "Butterfingers", ::Butterfingers);

        if(!self.dynamicupdate)
            self thread UpdateWeapMenu(player);
        break;

        case "Edit Projectiles":
        self addmenu("Edit Projectiles", self FormatTitle("Edit Projectiles"));
            self addSliderValue("Projectile Spread", 5, 1, 45, 1, ::ProjectileSpread);
            self addSliderValue("Current Weapon", 0, 0, 20, 1, ::ProjectilesEdit, "default");
            self addSliderValue("Rockets", 0, 0, 20, 1, ::ProjectilesEdit, "launcher_standard_upgraded");
            self addSliderValue("Ray Gun", 0, 0, 20, 1, ::ProjectilesEdit, "ray_gun");
            self addSliderValue("Ray Gun Upgraded", 0, 0, 20, 1, ::ProjectilesEdit, "ray_gun_upgraded");

        break;

        case "Edit Attachments":
        self addmenu("Edit Attachments", self FormatTitle("Edit Attachments"));
            foreach(attach in level.__attach)
            {
                self addToggle(attach, "has_attachment_" + attach, ::EditPlayerAttachment, attach);
            }
        
        if(!self.dynamicupdate)
            self thread UpdateWeapMenu(player);
        break;

        case "Perks Menu":
        self addMenu("Perks Menu", self FormatTitle("Perks Menu"));
            self AddOpt("Magic Perks Menu", ::newMenu, "Magic Perks Menu");
            self AddToggle("Keep Perks While Downed", TOG_RETAIN_PERKS, ::RetainPerksToggle);
            self addToggle("All Perks", TOG_ALL_PERKS, ::ClientAllPerks);
            foreach(perk in level.__perks)
            {
                self addToggle(perk, "has_perk_" + perk, ::ClientPerk, perk);
            }
        break;

        case "Magic Perks Menu":
        self addMenu("Magic Perks Menu", self FormatTitle("Magic Perks Menu"));
            self addToggle("All Magic Perks", TOG_ALL_MAGIC_PERKS, ::ClientMagicPerkAll);
            foreach(perk in level._magicperks)
            {
                self addToggle(perk, "has_perk_" + perk, ::ClientMagicPerk, perk);
            }
        break;

        case "Stats Menu":
        self AddMenu("Stats Menu", self FormatTitle("Stats Menu"));

        if(self StatsConfirmed(player))
        {
            self addOpt("Unlock All", ::UnlockAll);
            self addSliderValue("Rank Up", player GetPlayerCurrRank(), player GetMinPlayerRank(), player GetMaxPlayerRank(), 1, ::PlayerRank);
            self addSliderValue("Set Prestige", player GetDStat("playerstatslist", "plevel", "statValue"), 0, 15, 1, ::AdjustPrestige);
            self addSliderValue("Give Liquid Divinium", 5, 1, 15, 1, ::GiveLiquid);
            self addSliderValue("Map Highest Round", 0, 0, 255, 5, ::SetMapStat, "HIGHEST_ROUND_REACHED");
            self addSliderValue("Map Average Rounds", 0, -255, 255, 5, ::SetMapAverageStat);
            self addSliderString("Select Stat", level._statnames, level._fstatnames, ::StatEditor, 0);
            self addSliderValue("Set Stat Value", int(player zm_stats::get_global_stat(self GetStatnameSelected())), 0, 2147400000, self GetStatEditPrecision(), ::StatEditor, 1);
            self.sliders[self getrcurs_id(self.eMenu.size - 1)] = int(player zm_stats::get_global_stat(self GetStatnameSelected()));
            self addFactorSlider("Adjust Precision", 3, -9, 9, 10, 1, ::StatEditor, 2);
        }
        else
        {
            self AddOpt(self GetConsentString(player), ::StatConsentHandler);
        }

        break;

        case "Main Mods":
        self AddMenu("Main Mods", self FormatTitle("Main Mods"));
            self AddOpt("Nlog Test", ::printplayername);
            self addToggle("Godmode", "Godmode", ::BoolFunction, "Godmode");
            self addToggle("Infinite Ammo", "Infinite Ammo", ::InfiniteAmmo);
            self addToggle("Invisibility", "Invisibility", ::BoolFunction, "Invisibility");
            self addToggle("Third Person", "Third Person", ::BoolFunction, "Third Person");
            self addToggle("No Clip Bind", "No Clip", ::ANoclipBind);
            self AddToggle("Revived", TOG_IS_DOWNED, ::UpdatePlayerDowned);
            self AddToggle("Alive", TOG_IS_ALIVE, ::UpdatePlayerAlive);

            self addSliderString("Give Gobblegum", level._bgbnames, undefined, ::BGBGiver);

            self addFactorSlider("Adjust Points", 3, -6, 6, 10, 1, ::AdjustPoints);
            self addSliderValue("Speed Multiplier", 1, 0, 5, .1, ::UpdateClientSpeed);
            self addSliderValue("Model Index", 0, 0, 8, 1, ::SetPlayerModelIndex);
            self addsliderstring("Switch Teams", level._teams, undefined, ::PlayerSwapTeam);
            self AddSlidervalue("Max Health", 100, 0, 10000, 25, ::EditMaxHealth);
        break;

        case "Teleport Menu":
        self AddMenu("Teleport Menu", self FormatTitle("Teleport Menu"));
            if(!isdefined(self.allclientsmode) || !self.allclientsmode)
                self AddSliderString("Saved Locations", player GetSaveloadList(), player GetSaveloadPretty(), ::SaveLoad);
            self AddSliderString("Teleport To Location", level._telezones, level._telezones_pretty, ::TeleZone);
            self AddOpt("Teleport to Crosshair", ::playerToTrace);
            self AddOpt("Teleport to Player", ::TeleToPlayer);
        break;

        case "Misc Mods":
         self AddMenu("Misc Mods", self FormatTitle("Misc Mods"));
            self addSliderValue("Spawn Zombies on Player", 2, 1, 40, 1, ::SpawnZombieArray);
        break;

        default:

            if(AddMapPlayerOptions(menu))
                return;
            
            self addopt("Main Mods", ::newMenu, "Main Mods");
            self addopt("Weapon Mods", ::newMenu, "Weapon Mods");
            self addOpt("Perks Menu", ::newMenu, "Perks Menu");
            self addOpt("Teleport Menu", ::newMenu, "Teleport Menu");
            self addOpt("Map Mods", ::newMenu, "player_map_mods");
            self AddOpt("Stats Menu", ::newMenu, "Stats Menu");
            self addopt("Misc Mods", ::newMenu, "Misc Mods");
            if(isdefined(self.allclientsmode) && self.allclientsmode && (!isdefined(self.ac_includehost) || !self.ac_includehost) || player != self && !player IsHost())
                self AddOpt("Kick Player", ::KickClient);
 
        break;
    }
}

AddMapOptions()
{
    switch(level.script)
    {
        default:
            self shadowsOptions();
        break;
    }
}

AddMapPlayerOptions(menu)
{
    if(menu == "player_map_mods")
        self AddMenu("player_map_mods", self FormatTitle("Map Mods"));
    switch(level.script)
    {
        default:
            return self ShadowsPlayerOptions(menu);
    }
}

FormatTitle(base)
{
    if(isdefined(self.allclientsmode) && self.allclientsmode)
        return base + " - All Clients";

    if(!isdefined(self.selectedplayer))
        return base;
    
    name = self.selectedplayer GetName();

    if(!isdefined(name))
        return base;

    return base + " - " + name;
}

ToggleIncludeHost(player, value)
{
    if(player != self)
        return;
    player.ac_includehost = value;
}

clientOptions(menu)
{ 
    if(menu == "Access Menu")
    {
        self AddMenu("Access Menu", self FormatTitle("Access Menu"));
        for(e=0;e<level.status.size-1;e++)
            self addOpt("Give " + level.status[e], ::initializeSetup, e);
        
        if(isdefined(self.selectedplayer))
            self thread MenuDCUpdate(self.selectedplayer);
        return;
    }

    if(self SafeGetAllPlayersMode() && menu == "All Clients Menu")
    {
        self playeroptions(menu);
        
        self addopt("Access Menu", ::newMenu, "Access Menu");
        return;
    }

    foreach(player in level.players)
    {
        if(menu == ("client_" + player getsuid()))
        {
            self addmenu("client_" + (player getsuid()), player getName());
            self.selectedplayer = player;
            self playeroptions(menu);
            
            if(player != self)
                self addopt("Access Menu", ::newMenu, "Access Menu");
            
            return;
        }
    }

    if(isdefined(self.selectedplayer))
        self playeroptions(menu);
}

MenuDCUpdate(player)
{
    self endon("disconnect");
    level endon("end_game");
    self endon("menu_exited");
    self endon("new_menu");

    player waittill("disconnect");

    self thread SetMainImmediate();
}

UpdateWeapMenu(player)
{
    self endon("new_menu");
    self endon("menu_exited");
    self.dynamicupdate = true;
    while(1)
    {
        player waittill("weapon_change");
        self setMenuText();
    }
}