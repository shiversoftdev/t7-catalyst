ZombiesMinimap(player, result)
{
    level endon("end_game");
    player endon("disconnect");

    if(!isdefined(player))
        return;
    
    player SetBVar("Zombie Minimap", result);

    while(player GetBVarEnabled("Zombie Minimap"))
    {
        while(player IsSubversionOpen())
            WaitMin();
        
        minimap = player createRectangle("CENTER", "TOP", -300, 85, 170, 170, (0,0,0), "white", 0, .75);
        me = player createRectangle("CENTER", "TOP", -300, 75, 7, 7, (0,0,1), "white", 2, .75);
        shader = undefined;

        minimap thread emergencyDelete(player);
        me thread emergencyDelete(player);

        while(player GetBVarEnabled("Zombie Minimap") && !(player IsSubversionOpen()))
        {
            foreach(zombie in GetAITeamArray(level.zombie_team))
            {
                if(Distance(player GetOrigin(), zombie GetOrigin()) < 1000)
                {
                    if(zombie.team != player.team)
                        shader = player createRectangle("CENTER", "TOP", -300, 75, 7, 7, (1,0,0), "white", 3, .75);
                    else
                        shader = player createRectangle("CENTER", "TOP", -300, 75, 7, 7, (0,1,0), "white", 3, .75);
                    
                    shader thread updateMMPos(player getOrigin(), zombie getOrigin(), player getplayerangles());
                    shader thread emergencyDelete(player);
                }
            }
            foreach(otherplayer in level.players)
            {
                if(player == otherplayer)
                    continue;
                if(otherplayer.sessionstate == "spectator")
                    continue;
                
                shader = player createRectangle("CENTER", "TOP", -300, 75, 7, 7, (0,1,0), "white", 3, .75);
                shader thread updateMMPos(player getOrigin(), otherplayer getOrigin(), player getplayerangles());
                shader thread emergencyDelete(player);
            }
            wait 1.0125;
            waittillframeend;
        }
        me notify("noemergency");
        me destroy();
        minimap notify("noemergency");
        minimap destroy();
    }
}
 
updateMMPos(center, offset, angles)
{
    self endon("emergencyfix");
    self endon("noemergency");
    self thread PingShader();
    while(isdefined(self))
    {
        d = offset - center;
        d0 = Distance(offset, center);
        x = cos( angles[1] - ATan2( d[1], d[0] ) + 90 ) * d0;
        y = sin( angles[1] - ATan2( d[1], d[0] ) + 90 ) * d0;
        offx = x / 1000;
        if( offx > 1 )
            offx = 1;
        else if( offx < -1 )
            offx = -1;
        offy = y / 1000;
        if( offy > 1 )
            offy = 1;
        else if( offy < -1 )
            offy = -1;
        self.x = -300 - offx * 75;
        self.y = 75 - offy * 75;
        WaitMin();
    }
}

ATan2( y, x )
{
    if( x > 0 )
        return ATan( y / x );
    if( x < 0 && y >= 0 )
        return ATan( y / x ) + 180;
    if( x < 0 && y < 0 )
        return ATan( y / x ) - 180;
    if( x == 0 && y > 0 )
        return 90;
    if( x == 0 && y < 0 )
        return -90;
    return 0;
}

PingShader()
{
    self endon("emergencyfix");
    self.alpha = 1;
    self fadeovertime( .8 );
    self.alpha = 0;
    wait 1;
    self notify("noemergency");
    self Destroy();
}

emergencyDelete(player)
{
    level endon("end_game");
    player endon("disconnect");
    self endon("noemergency");

    while(isdefined(self) && !(player IsSubversionOpen()))
        WaitMin();
    
    self notify("emergencyfix");
    self destroy();
}

SpawnZombieArray(player, count = 0)
{
    if(!isdefined(player))
        return;
    
    self iPrintLnBold("Spawning Zombies");
    for(i = 0; i < count; i++)
    {
        self thread SpawnZombie(player);
        wait .25;
    }

    self iPrintLnBold("Spawning Complete");
}

SpawnZombie(player)
{
    if(!isdefined(player))
        return;
    
    direction = player getplayerangles();
    direction_vec = anglesToForward(direction);
    eye = player geteye();

    direction_vec = VectorScale(direction_vec, 10);
    trace = bullettrace(eye, eye + direction_vec, 0, undefined);

    if(isdefined(level.zombie_spawners))
    {
        if(isdefined(level.fn_custom_zombie_spawner_selection))
        {
            spawner = [[level.fn_custom_zombie_spawner_selection]]();
        }
        else if(isdefined(level.use_multiple_spawns) && level.use_multiple_spawns)
        {
            if(isdefined(level.spawner_int) && (isdefined(level.zombie_spawn[level.spawner_int].size) && level.zombie_spawn[level.spawner_int].size))
            {
                spawner = Array::random(level.zombie_spawn[level.spawner_int]);
            }
            else
            {
                spawner = Array::random(level.zombie_spawners);
            }
        }
        else
        {
            spawner = Array::random(level.zombie_spawners);
        }
        ai = zombie_utility::spawn_zombie(spawner, spawner.targetname);
    }

    if (isDefined(ai))
    {
        wait 0.25;

        ai.origin = trace["position"];
        ai.angles = player.angles + vectorScale((0, 1, 0), 180);
        ai zombie_utility::set_zombie_run_cycle("run");

        ai forceteleport(trace["position"], player.angles + vectorScale((0, 1, 0), 180));
        wait .1;
        ai.find_flesh_struct_string = "find_flesh";
        ai doDamage(1, ai.origin, player);
    }
}

KillAllZombies(player)
{
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(isdefined(zombie))
            zombie dodamage(zombie.maxhealth + 666, zombie.origin, player);
    }
}