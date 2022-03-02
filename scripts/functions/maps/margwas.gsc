SpawnMargwa(player, type)
{
    s_location = Array::random(level.zm_loc_types["margwa_location"]);
	if(isdefined(level.var_b398aafa[0]))
	{
		level.var_b398aafa[0].script_forcespawn = 1;
		ai = zombie_utility::spawn_zombie(level.var_b398aafa[0], "margwa", s_location);
		ai DisableAimAssist();
		ai.actor_damage_func = ::local_margwadmg;
		ai.canDamage = 0;
		ai.targetname = "margwa";
        ai.headAttached = 3;
		ai.holdFire = 1;
		e_player = zm_utility::get_closest_player(s_location.origin);
		v_dir = e_player.origin - s_location.origin;
		v_dir = VectorNormalize(v_dir);
		v_angles = VectorToAngles(v_dir);
		ai ForceTeleport(s_location.origin, v_angles);
		ai function_551e32b4();
        if(isdefined(level.var_7cef68dc))
		{
			ai thread function_8d578a58();
		}
		ai.ignore_round_robbin_death = 1;
		ai thread function_3d56f587();
        n_health = level.round_number * 100 + 100;
		ai MargwaServerUtils::margwaSetHeadHealth(n_health);
	    level.var_95981590 = ai;
	    level notify(#"hash_c484afcb");
		if(type == "Super")
			ai clientfield::set("supermargwa", 1);
		self iPrintLnBold("Margwa Spawned");
		return ai;
	}
	return undefined;
}

local_margwadmg(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex)
{
    return self [[MargwaServerUtils::margwaDamage]](inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex);
}

function_551e32b4()
{
	self.isFrozen = 1;
	self ghost();
	self notsolid();
	self PathMode("dont move");
}

function_3d56f587()
{
	util::wait_network_frame();
	self clientfield::increment("margwa_fx_spawn");
	wait 3;
	self function_26c35525();
	self.canDamage = 1;
	self.needSpawn = 1;
}

function_26c35525()
{
	self.isFrozen = 0;
	self show();
	self solid();
	self PathMode("move allowed");
}

function_8d578a58()
{
	self waittill("death", attacker, mod, weapon);
	//level notify("hash_1a2d33d7");
	[[level.var_7cef68dc]]();
}