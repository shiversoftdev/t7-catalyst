special_wasp_spawn(spawn_enemy, n_to_spawn = 1, n_radius = 32, n_half_height = 32, b_non_round, spawn_fx = 1, b_return_ai = 1)
{
	wasp = GetEntArray("zombie_wasp", "targetname");
	count = 0;
	while(count < n_to_spawn)
	{
		if(isdefined(level.wasp_spawn_func))
		{
			spawn_point = [[level.wasp_spawn_func]](spawn_enemy);
		}
		while(!isdefined(spawn_point))
		{
			if(!isdefined(spawn_point))
			{
				spawn_point = wasp_spawn_logic(spawn_enemy);
			}
			if(isdefined(spawn_point))
			{
				break;
			}
			wait 0.05;
		}
		spawner = level.wasp_spawners[0];
		ai = zombie_utility::spawn_zombie(spawner);
		v_spawn_origin = spawn_point.origin;
		if(isdefined(ai))
		{
			queryResult = PositionQuery_Source_Navigation(v_spawn_origin, 0, n_radius, n_half_height, 15, "navvolume_small");
			if(queryResult.data.size)
			{
				point = queryResult.data[RandomInt(queryResult.data.size)];
				v_spawn_origin = point.origin;
			}
			ai.does_not_count_to_round = b_non_round;
			level thread wasp_spawn_init(ai, v_spawn_origin, spawn_fx);
			count++;
		}
        ai.favoriteenemy = spawn_enemy;
        wait .1;
	}
	if(b_return_ai)
	{
		return ai;
	}
	return 1;
}

wasp_spawn_logic(favorite_enemy)
{
    switch(level.players.size)
	{
		case 4:
		{
			spawn_dist_max = 600;
			break;
		}
		case 3:
		{
			spawn_dist_max = 700;
			break;
		}
		case 2:
		{
			spawn_dist_max = 900;
			break;
		}
		case 1:
		default:
		{
			spawn_dist_max = 1200;
            break;
		}
	}
	queryResult = PositionQuery_Source_Navigation(favorite_enemy.origin + (0, 0, randomIntRange(40, 100)), 300, spawn_dist_max, 10, 10, "navvolume_small");
	a_points = Array::randomize(queryResult.data);
	foreach(point in a_points)
	{
		if(BulletTracePassed(point.origin, favorite_enemy.origin, 0, favorite_enemy))
		{
			level.old_wasp_spawn = point;
			return point;
		}
	}
    return a_points[0];
}

wasp_spawn_init(ai, origin, should_spawn_fx)
{
	if(!isdefined(should_spawn_fx))
	{
		should_spawn_fx = 1;
	}
	ai endon("death");
	ai SetInvisibleToAll();
	if(isdefined(origin))
	{
		v_origin = origin;
	}
	else
	{
		v_origin = ai.origin;
	}
	if(should_spawn_fx)
	{
		playFX(level._effect["lightning_wasp_spawn"], v_origin);
	}
	wait 1.5;
	Earthquake(0.3, 0.5, v_origin, 256);
	if(isdefined(ai.favoriteenemy))
	{
		angle = VectorToAngles(ai.favoriteenemy.origin - v_origin);
	}
	else
	{
		angle = ai.angles;
	}
	angles = (ai.angles[0], angle[1], ai.angles[2]);
	ai.origin = v_origin;
	ai.angles = angles;

	ai thread wasp_behind_audio();
	ai.ignoreall = 0;
	ai.meleeAttackDist = 64;
	ai.disableArrivals = 1;
	ai.disableExits = 1;
	ai ai::set_behavior_attribute("firing_rate", "fast");

	if(isdefined(level._wasp_death_cb))
	{
		ai callback::add_callback(#"hash_acb66515", level._wasp_death_cb);
	}

	ai SetVisibleToAll();
	ai.ignoreme = 0;
	ai notify("visible");
}

wasp_behind_audio()
{
	self thread stop_wasp_sound_on_death();
	self endon("death");
	self util::waittill_any("wasp_running", "wasp_combat");
	wait 3;
	while(1)
	{
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			waspAngle = AngleClamp180(VectorToAngles(self.origin - players[i].origin)[1] - players[i].angles[1]);
			if(isalive(players[i]) && !isdefined(players[i].reviveTrigger))
			{
				if(Abs(waspAngle) > 90 && Distance2D(self.origin, players[i].origin) > 100)
				{
					wait 3;
				}
			}
		}
		wait 0.75;
	}
}

stop_wasp_sound_on_death()
{
	self waittill("death");
	self stopsounds();
}