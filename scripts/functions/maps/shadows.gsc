ShadowsOptions()
{
	if(!isdefined(level.shadowsEESteps))
	{
		level.shadowsEESteps = ["Pack a Punch", "Eggs", "Swords", "Swords Upgraded", "Flag Step", "Boss Fight", "Full Egg"];
		level.margwatypes = ["Normal", "Super"];
	}
	self AddToggle("Margwa Spawns Allowed", TOG_SHADOWS_MARGWAS_ALLOWED, ::MarwasAllowed);
	self addSliderValue("All Pods", 3, 0, 3, 1, ::allpodstostate);
    self AddSliderValue("Spawn Meatballs", 1, 1, 40, 1, ::SpawnMB);
	self AddSliderValue("Spawn Bugs", 1, 1, 40, 1, ::special_wasp_spawn);
	self AddSliderString("Spawn a Margwa", level.margwatypes, undefined, ::SpawnMargwa);
	self AddSliderString("Complete EE Step", level.shadowsEESteps, undefined, ::ShadowsEE);
	if(!isdefined(level.var_421ff75e) || !level.var_421ff75e && !level flag::get("ee_boss_defeated"))
		self AddOpt("Enable Solo Easter Egg", ::SoloEE);
	self AddOpt("Collect Summoning Key", ::SKeyGrab);
    //TODO flyable shadows plane
}

ShadowsPlayerOptions(menu)
{
    if(!isdefined(player.var_5e82a563))
        player.var_5e82a563 = 1;

    player = self.selectedplayer;

    switch(menu)
    {
        case "player_map_mods":
			self AddToggle("Infinite Beast Mode", "Infinite Beast Mode", ::InfiniteBeast);
            self AddToggle("Meatball Rain", "Meatball Rain", ::RapsRain);
			self addToggle("Meatball Head", "Meatball Head", ::PlayerMeatballHead);
            self AddOpt("Enter Beast Mode", ::EnterBeastMode);
			if(player clientfield::get_to_player("pod_sprayer_held") == 0)
				self AddOpt("Award Fumigator", ::FumigatorGive);
            self AddSliderValue("Number of Beast Modes", player.var_5e82a563, 0, 10, 1, ::BeastmodeCounter);
            self AddSliderString("Sword Type", level.SwordTypeArray, undefined, ::AdjustPlayerSword);
			self AddSliderValue("Spawn Meatballs on Player", 1, 1, 40, 1, ::SpawnMB);
			self AddSliderValue("Spawn Bugs on Player", 1, 1, 40, 1, ::special_wasp_spawn);
			self AddSliderString("Spawn a Margwa on Player", level.margwatypes, undefined, ::SpawnMargwa);
			
        break;

        default:
            return false;
    }

    return true;
}

FumigatorGive(player)
{
	if(!isdefined(player))
		return;
	
	player clientfield::set_to_player("pod_sprayer_held", 1);
	player.var_abe77dc0 = 1;
	level flag::set("any_player_has_pod_sprayer");
	player thread shadowsuishow("zmInventory.widget_sprayer");
	self.menu[ self GetCurrentMenu() + "_cursor"] = 0;
	self thread MenuDisplayUpdate();
	self iPrintLnBold("Fumigator awarded");
}

SKeyGrab(player)
{
	level clientfield::set("quest_key");
	level flag::set("quest_key_found");
	level.var_c913a45f = 1;
	location = player geteye() + VectorScale(anglesToForward(player getplayerangles()), 10);

	key = GetEnt("quest_key_pickup", "targetname");
	key.origin = location;
	key.unitrigger_stub.origin = location;
	while(!isdefined(level._unitriggers.trigger_pool[player GetEntityNumber()]))
		wait .025;
	
	level._unitriggers.trigger_pool[player GetEntityNumber()] notify("trigger", player);
	player thread shadowsuishow("zmInventory.widget_quest_items");
	
	self iPrintLnBold("Obtained");
}

shadowsuishow(val)
{
	self clientfield::set_player_uimodel(val, 1);
	wait 3.5;
	self clientfield::set_player_uimodel(val, 0);
}

MarwasAllowed(player, result)
{
	if(result)
		level flag::set("can_spawn_margwa");
	else 
		level flag::clear("can_spawn_margwa");
}

SoloEE(player)
{
	level.var_421ff75e = true;
	self.menu[ self GetCurrentMenu() + "_cursor"] = 0;
	self thread MenuDisplayUpdate();
	self iPrintLnBold("Solo egg enabled");
}

ShadowsEE(player, step)
{
	foreach(prereq in level.shadowsEESteps)
	{
		ShadowsEEStep(prereq);
		wait .25;
		if(step == prereq)
			break;
	}
	self iPrintLnBold("Step achieved");
}

ShadowsEEStep(step)
{
	switch(step)
	{
		case "Pack a Punch":
		if(isdefined(level.var_c0091dc4["pap"].var_46491092))
		{
			foreach(person in Array("boxer", "detective", "femme", "magician"))
				level thread [[ level.var_c0091dc4[person].var_46491092 ]](person);

			foreach(var_c8d6ad34 in Array("pap_basin_1", "pap_basin_2", "pap_basin_3", "pap_basin_4"))
				level flag::set(var_c8d6ad34);

			level flag::set("pap_altar");
			level thread [[ level.var_c0091dc4["pap"].var_46491092 ]]("pap");
		}
		break;
		case "Eggs":
			locker = level.var_ca7eab3b;
			locker.var_116811f0 = 3;
			foreach(var_22f3c343 in locker.var_5475b2f6)
				var_22f3c343 ghost();
			
			for(i = 0; i < 10; i++)
			{
				if(isdefined(locker.var_2c51c4a[i]))
					[[locker.var_2c51c4a[i]]]();
			}

			foreach(correct in locker.var_75a61704)
			{
				correct notify("trigger", self);
			}
		break;
		case "Swords":
			foreach(player in level.players)
			{
				if(player.sessionstate == "spectator")
				{
					if (isDefined(player.spectate_hud))
					{
						player.spectate_hud destroy();
					}
					player [[ level.spawnplayer ]]();
					wait 1;
				}
				AdjustPlayerSword(player, "Normal", true);
			}
			wait .25;
		break;
		case "Swords Upgraded":
			foreach(player in level.players)
			{
				if(player.sessionstate == "spectator")
				{
					if (isDefined(player.spectate_hud))
					{
						player.spectate_hud destroy();
					}
					player [[ level.spawnplayer ]]();
					wait 1;
				}
				AdjustPlayerSword(player, "Upgraded", true);
			}
			level flag::set("ee_begin");
		break;
		case "Flag Step":
			level flag::set("ee_book");
			level clientfield::set("ee_keeper_boxer_state", 1);
			level clientfield::set("ee_keeper_detective_state", 1);
			level clientfield::set("ee_keeper_femme_state", 1);
			level clientfield::set("ee_keeper_magician_state", 1);
			wait .25;
			foreach(person in Array("boxer", "detective", "femme", "magician"))
			{
				level flag::set("ee_keeper_" + person + "_resurrected");
				level clientfield::set("ee_keeper_" + person + "_state", 3);
			}
			wait 7.5;
		break;
		case "Boss Fight":
			level.var_421ff75e = 1; //ensure solo easter egg is possible
			FinishBossfight();
		break;
		case "Full Egg":
			while(!(level flag::get("ee_superworm_present")))
				wait 1;
			wait 2;
			level clientfield::set("ee_superworm_state", 2);
			foreach(flag in Array("ee_district_rail_electrified_1", "ee_district_rail_electrified_2", "ee_district_rail_electrified_3", "ee_final_boss_keeper_electricity_0", "ee_final_boss_keeper_electricity_1", "ee_final_boss_keeper_electricity_2"))
			{
				level flag::set(flag);
			}
			level flag::clear("ee_superworm_present");
		break;
	}

}

FinishBossfight()
{
	level flag::set("ee_boss_defeated");
	level notify(#"hash_a881e3fa");
	level notify(#"hash_fbc505ba");
	if(isdefined(level.var_dbc3a0ef) && isdefined(level.var_dbc3a0ef.var_93dad597))
	{
		level.var_dbc3a0ef.var_93dad597 delete();
	}
	foreach(person in Array("boxer", "detective", "femme", "magician"))
	{
		if(isdefined(level.var_f86952c7["boss_1_" + person]))
		{
			zm_unitrigger::unregister_unitrigger(level.var_f86952c7["boss_1_" + person]);
		}
		level clientfield::set( "ee_keeper_" + person + "_state", 7);
		wait 0.1;
	}
}

PlayerMeatballHead(player, result)
{
	if(!isdefined(player))
		return;
	
	player SetBVar("Meatball Head", result);
	if(result)
	{
		meatball = spawn("script_model", player.origin);
		meatball SetModel("veh_t7_drone_insanity_elemental_v2");
		meatball NotSolid();
		meatball LinkTo(player, "j_head", (16,0,-20));
		player thread MeatballDelete(meatball);
	}
	else
	{
		player notify("Meatball Head");
	}
}

MeatballDelete(meatball)
{
	self util::waittill_any("death", "disconnect", "Meatball Head");
	meatball delete();
}

AdjustPlayerSword(player, type, noprint=false)
{
    if(!isdefined(level.var_15954023.weapons))
        level.var_15954023.weapons = [];

    if(!isDefined(level.var_15954023.weapons[player.originalindex]))
    {
        return;
    }
    
    weapon = level.var_15954023.weapons[player.originalindex][1];
    switch(type)
    {
        case "Normal":
             weapon = level.var_15954023.weapons[player.originalindex][1];
        break;

        case "Upgraded":
            weapon = level.var_15954023.weapons[player.originalindex][2];
        break;

        default:
            player takeWeapon(level.var_15954023.weapons[player.originalindex][1]);
            player takeWeapon(level.var_15954023.weapons[player.originalindex][2]);
			if(!noprint)
				self iPrintLnBold("Sword Updated");
            return;
    }

    player.sword_power = 1;
    player notify(#"hash_b29853d8");
    if(isdefined(player.var_c0d25105))
    {
        player.var_c0d25105 notify("returned_to_owner");
    }
    player.var_86a785ad = 1;
    player notify(#"hash_b29853d8");
    player zm_weapons::weapon_give(weapon, 0, 0, 1);
    player GadgetPowerSet(0, 100);
    player.current_sword = player.current_hero_weapon;

    if(!noprint)
		self iPrintLnBold("Sword Updated");
}

BeastmodeCounter(player, value)
{
    if(!isdefined(player))
        return;
    
    player.var_5e82a563 = value;

    self iPrintLnBold("Beastmodes Set!");    
}

InfiniteBeast(player, result)
{
    if(!isdefined(player))
        return;
    
    player SetBVar("Infinite Beast Mode", result);

    while(isdefined(player) && player GetBVarEnabled("Infinite Beast Mode"))
    {
        player.var_39f3c137 = 1;
        wait .025;
    }
}

EnterBeastMode(player)
{
    if(!isdefined(player))
        return;

    player thread Altbody("beast_mode");

    self iPrintLnBold("Beast mode activated");
}

Altbody(name)
{
	self.altbody = 1;
	self function_39fc0f41(name);
    self enableusability();
	self waittill(#"hash_f0078f48");
	self function_32a45d2d(name);
	self.altbody = 0;
}

function_32a45d2d(name, trigger)
{
	clientfield::set("player_altbody", 0);
	clientfield::set_to_player("player_in_afterlife", 0);
	callback = level.var_3b231394[name];
	if(isdefined(callback))
	{
		self [[callback]](name, trigger);
	}
	if(!isdefined(self.var_a8e4afcf))
	{
		self.var_a8e4afcf = [];
	}
	visionset = level.var_b48c4996[name];
	if(isdefined(visionset))
	{
		visionset_mgr::deactivate("visionset", visionset, self);
		self.var_a8e4afcf[name] = 0;
	}
	self thread function_d97ca744(name);
	self unsetPerk("specialty_playeriszombie");
	self DetachAll();
	self thread zm_altbody::func_72c3fae0(0);
	self [[level.giveCustomCharacters]]();
}

function_d97ca744(name, trigger)
{
	loadout = level.var_740d155e[name];
	if(isdefined(loadout))
	{
		if(isdefined(self.var_67e131e7[name]))
		{
			self zm_weapons::switch_back_primary_weapon(self.var_67e131e7[name].current, 1);
			self.var_67e131e7[name] = undefined;
			self util::waittill_any_timeout(1, "weapon_change_complete");
		}
		self zm_weapons::player_take_loadout(loadout);

		self func_b47ed897();//???
		//self EnableWeaponCycling();
	}
}

function_39fc0f41(name, trigger)
{
	charIndex = level.var_3f7a17f[name];
	self.var_b2356a6c = self.origin;
	self.var_227fe352 = self.angles;
	self setPerk("specialty_playeriszombie");
	self thread zm_altbody::func_72c3fae0(1);
	self SetCharacterBodyType(charIndex);
	self SetCharacterBodyStyle(0);
	self SetCharacterHelmetStyle(0);
	clientfield::set_to_player("player_in_afterlife", 1);
	self function_96a57786(name);
	self thread function_43af326a(name);
	callback = level.var_16cbb1a8[name];
	if(isdefined(callback))
	{
		self [[callback]](name, trigger);
	}
	clientfield::set("player_altbody", 1);
}

function_43af326a(name)
{
	if(!isdefined(self.var_a8e4afcf))
	{
		self.var_a8e4afcf = [];
	}
	visionset = level.var_b48c4996[name];
	if(isdefined(visionset))
	{
		if(isdefined(self.var_a8e4afcf[name]) && self.var_a8e4afcf[name])
		{
			visionset_mgr::deactivate("visionset", visionset, self);
			util::wait_network_frame();
			util::wait_network_frame();
			if(!isdefined(self))
			{
				return;
			}
		}
		visionset_mgr::activate("visionset", visionset, self);
		self.var_a8e4afcf[name] = 1;
	}
}

function_96a57786(name)
{
	loadout = level.var_740d155e[name];
	if(isdefined(loadout))
	{
		//self DisableWeaponCycling();
		self.get_player_weapon_limit = ::maxweaponschecker;
		self.var_67e131e7[name] = zm_weapons::player_get_loadout();
		self zm_weapons::player_give_loadout(loadout, 0, 1);
		if(!isdefined(self.var_8b5ec154))
		{
			self.var_8b5ec154 = [];
		}
		if(isdefined(self.var_8b5ec154[name]) && self.var_8b5ec154[name])
		{
			self SetEverHadWeaponAll(1);
		}
		self.var_8b5ec154[name] = 1;
		self util::waittill_any_timeout(1, "weapon_change_complete");
		self func_b47ed897();
	}
}

RapsRain(player, result)
{
    level endon("game_ended");
	level endon("end_game");

	if(!isdefined(player))
		return;

    player endon("disconnect");

    player SetBVar("Raps Rain", result);

    player.rapscount = 0;
    while(isdefined(player) && player GetBVarEnabled("Raps Rain"))
    {
        if(player.rapscount < 8)
        {
            SpawnMB(player) thread RapsRainDeathMonitor(player);
            player.rapscount++;
        }
        wait .25;
    }
}

RapsRainDeathMonitor(owner)
{
    self waittill("death");
    if(isdefined(owner))
        owner.rapscount--;
}

SpawnMB(player, count = 1)
{
    if(!isdefined(player))
        player = array::random(level.players);

    s_spawn_loc = calculate_spawn_position(player);

    if(!isdefined(s_spawn_loc))
	{
		return;
	}

	for(i = 0; i < count; i++)
	{
		ai = zombie_utility::spawn_zombie(level.raps_spawners[0]);
		if(isdefined(ai))
		{
			ai.favoriteenemy = player;
			ai.favoriteenemy.hunted_by++;
			s_spawn_loc thread raps_spawn_fx(ai, s_spawn_loc);
		}
		wait .1;
	}
	self iPrintLnBold("Meatballs Spawned");
    return ai;
}

calculate_spawn_position(favorite_enemy)
{
	position = favorite_enemy.last_valid_position;
	if(!isdefined(position))
	{
		position = favorite_enemy.origin;
	}
	if(level.players.size == 1)
	{
		N_RAPS_SPAWN_DIST_MIN = 450;
		N_RAPS_SPAWN_DIST_MAX = 900;
	}
	else if(level.players.size == 2)
	{
		N_RAPS_SPAWN_DIST_MIN = 450;
		N_RAPS_SPAWN_DIST_MAX = 850;
	}
	else if(level.players.size == 3)
	{
		N_RAPS_SPAWN_DIST_MIN = 700;
		N_RAPS_SPAWN_DIST_MAX = 1000;
	}
	else
	{
		N_RAPS_SPAWN_DIST_MIN = 800;
		N_RAPS_SPAWN_DIST_MAX = 1200;
	}
	query_result = PositionQuery_Source_Navigation(position, N_RAPS_SPAWN_DIST_MIN, N_RAPS_SPAWN_DIST_MAX, 200, 32, 16);
	if(query_result.data.size)
	{
		a_s_locs = Array::randomize(query_result.data);
		if(isdefined(a_s_locs))
		{
			foreach(s_loc in a_s_locs)
			{
				if(zm_utility::check_point_in_enabled_zone(s_loc.origin, 1, level.active_zones))
				{
					s_loc.origin = s_loc.origin + VectorScale((0, 0, 1), 16);
					return s_loc;
				}
			}
		}
	}
	return undefined;
}

raps_spawn_fx(ai, ent)
{
	ai endon("death");
	if(!isdefined(ent))
	{
		ent = self;
	}
	ai vehicle_ai::set_state("scripted");
	trace = bullettrace(ent.origin, ent.origin + VectorScale((0, 0, -1), 720), 0, ai);
	raps_impact_location = trace["position"];
	angle = VectorToAngles(ai.favoriteenemy.origin - ent.origin);
	angles = (ai.angles[0], angle[1], ai.angles[2]);
	ai.origin = raps_impact_location;
	ai.angles = angles;
	ai Hide();
	pos = raps_impact_location + VectorScale((0, 0, 1), 720);
	if(!BulletTracePassed(ent.origin, pos, 0, ai))
	{
		trace = bullettrace(ent.origin, pos, 0, ai);
		pos = trace["position"];
	}
	portal_fx_location = spawn("script_model", pos);
	portal_fx_location SetModel("tag_origin");
	PlayFXOnTag(level._effect["raps_portal"], portal_fx_location, "tag_origin");
	ground_tell_location = spawn("script_model", raps_impact_location);
	ground_tell_location SetModel("tag_origin");
	PlayFXOnTag(level._effect["raps_ground_spawn"], ground_tell_location, "tag_origin");
	ground_tell_location playsound("zmb_meatball_spawn_tell");
	playsoundatposition("zmb_meatball_spawn_rise", pos);
	ai thread cleanup_meteor_fx(portal_fx_location, ground_tell_location);
	wait 0.5;
	raps_meteor = spawn("script_model", pos);
	model = ai.model;

	raps_meteor SetModel(model);
	raps_meteor.angles = angles;
	raps_meteor PlayLoopSound("zmb_meatball_spawn_loop", 0.25);
	PlayFXOnTag(level._effect["raps_meteor_fire"], raps_meteor, "tag_origin");
	fall_dist = sqrt(DistanceSquared(pos, raps_impact_location));
	fall_time = fall_dist / 720;
	raps_meteor moveto(raps_impact_location, fall_time);
	raps_meteor.ai = ai;
	raps_meteor thread cleanup_meteor();
	wait fall_time;
	raps_meteor delete();
	if(isdefined(portal_fx_location))
	{
		portal_fx_location delete();
	}
	if(isdefined(ground_tell_location))
	{
		ground_tell_location delete();
	}
	ai vehicle_ai::set_state("combat");
	ai.origin = raps_impact_location;
	ai.angles = angles;
	ai show();
	playFX(level._effect["raps_impact"], raps_impact_location);
	playsoundatposition("zmb_meatball_spawn_impact", raps_impact_location);
	Earthquake(0.3, 0.75, raps_impact_location, 512);
	ai zombie_setup_attack_properties_raps();
	ai SetVisibleToAll();
	ai.ignoreme = 0;
	ai notify("visible");
}

zombie_setup_attack_properties_raps()
{
	self zm_spawner::zombie_history("zombie_setup_attack_properties()");
	self.ignoreall = 0;
	self.meleeAttackDist = 64;
	self.disableArrivals = 1;
	self.disableExits = 1;
}

cleanup_meteor_fx(portal_fx, ground_tell)
{
	self waittill("death");
	if(isdefined(portal_fx))
	{
		portal_fx delete();
	}
	if(isdefined(ground_tell))
	{
		ground_tell delete();
	}
}

cleanup_meteor()
{
	self endon("death");
	self.ai waittill("death");
	self delete();
}

//level.var_6fa2f6ca.var_5d8c3695 pods
allpodstostate(player, target)
{
	self iPrintLnBold("Pods updated");
	level.var_7cf7b906 = 1;
	level notify("debug_pod_spawn");
	wait 1;

	foreach(pod in level.var_6fa2f6ca.var_5d8c3695)
		pod thread setpodlevel(target);

	wait 1;
	level.var_7cf7b906 = 0;
}

setpodlevel(podlevel)
{
	self.var_8486ae6a = podlevel;
	self.model clientfield::set("update_fungus_pod_level", self.var_8486ae6a);
}