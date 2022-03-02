WaitMin()
{
    wait .0125;
    waittillframeend;
}

is_point_inside_zone(v_origin, target_zone)
{
	temp_ent = spawn("script_origin", v_origin);
	foreach(e_volume in target_zone.Volumes)
    {
        if(temp_ent istouching(e_volume))
        {
            temp_ent delete();
            return 1;
        }
    }
	temp_ent delete();
	return 0;
}

precacheCraftables()
{
    level._craftnames =  ["All Craftables"];
    foreach(s_craftable in level.zombie_include_craftables)
    {
        array::add(level._craftnames, s_craftable.name, 0);
    }
}

GrabCraftable(player, craft_name)
{
    if(craft_name == "All Craftables")
    {
        player GrabAll();
        return;
    }
    foreach(s_craftable in level.zombie_include_craftables)
    {
        if(s_craftable.name != craft_name)
            continue;
        
        foreach(s_piece in s_craftable.a_piecestubs)
        {
            player thread zm_craftables::player_get_craftable_piece( s_piece.craftablename, s_piece.pieceName );
            wait .25;
        }
        return;
    }
}

GrabAll()
{
    foreach(s_craftable in level.zombie_include_craftables)
    {
        foreach(s_piece in s_craftable.a_piecestubs)
        {
            self thread zm_craftables::player_get_craftable_piece( s_piece.craftablename, s_piece.pieceName );
            wait .25;
        }
    }
}