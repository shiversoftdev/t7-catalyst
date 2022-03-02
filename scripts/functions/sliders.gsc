AdjustPoints(player, value)
{
    if(!isdefined(value) || !isdefined(player))
        return;
    
    if(value >= 0)
    {
        player zm_score::add_to_player_score(value);
    }
    else
    {
        player zm_score::minus_to_player_score(-1 * value);
    }

    self iPrintLnBold("Adjusted points by ^3" + value);
}

UpdateClientSpeed(player, value)
{
    if(!isdefined(player))
        return;
    if(!isdefined(value))
        value = 1;

    player SetMoveSpeedScale(value);
    
    self iPrintLnBold("Player speed updated to ^2" + value);
}

SetPlayerModelIndex(player, index)
{
    if(!isdefined(player))
        return;
    if(!isdefined(index))
        index = 0;
    player DetachAll();
    player.characterindex = index;
    player SetCharacterBodyType(index);
    player SetCharacterBodyStyle(0);
    player SetCharacterHelmetStyle(0);
    player clientfield::set_player_uimodel("zmInventory.player_character_identity", player.characterindex);
    self iPrintLnBold("Set model index");
}

BGBGiver(player, bgb)
{
    if(!isdefined(player))
        return;
    if(!isdefined(bgb))
        return;

    player thread bgb::func_b107a7f3(bgb, 0);

    self iPrintLnBold("Gave player ^2" + bgb);
}

EditMaxHealth(player, value)
{
    if(!isdefined(player))
        return;
    player.maxhealth = value;
    player.health = player.maxhealth;
    self iPrintLnBold("Health updated");
}

SaveLoad(player, option)
{
    if(!isdefined(player))
        return;
    
    switch(option)
    {
        case "Clear":
            player.clocations = [];
            self iPrintLnBold("Cleared");
            self SetMenuText();
            return;
        break;

        case "Save":
            struct = spawnstruct();
            struct.origin = player GetOrigin();
            struct.angles = player getPlayerAngles();
            player.clocations[player.clocations.size] = struct;
            self iPrintLnBold("Saved");
            self SetMenuText();
            return;
        break;
        
        default:
            player ToPosition(option.origin);
            player setPlayerAngles(option.angles);
            self iPrintLnBold("Loaded");
        return;
    }
}

GetSaveloadList()
{
    arr = ["Clear", "Save"];
    if(!isdefined(self.clocations))
        self.clocations = [];
    
    return ArrayCombine(arr, self.clocations, 0, 0);
}

GetSaveloadPretty()
{
    arr = ["Clear", "Save"];

    if(!isdefined(self.clocations))
        self.clocations = [];
    
    for(i = 1; i <= self.clocations.size; i++)
    {
        Array::Add(arr, "Location " + i, 0);
    }

    return arr;
}

TeleZone(player, zone)
{
    if(!isdefined(player) || !isdefined(zone))
        return;
    respawn_points = struct::get_array("player_respawn_point", "targetname");
    target_zone = level.zones[zone];
    target_point = undefined;

    foreach(point in respawn_points)
    {
        if(is_point_inside_zone(point.origin, target_zone))
        {
            target_point = point;
        }
    }

    if(!isdefined(target_point))
        return self iPrintLnBold("^1Cannot locate a spawn point in this zone");
    
    player ToPosition(target_point.origin);
    self iPrintLnBold("Teleported");
}

PlayerSwapTeam(player, value)
{
    player.sessionteam = value;
    player SetTeam(value);
    player._encounters_team = value;
    player.team = value;
    player.pers["team"] = value;
    player notify( "joined_team" );
    level notify( "joined_team" );

    self iPrintLnBold("Team adjusted");
}

AdjustBoxCost(player, strval)
{
    foreach(box in level.chests)
        box.zombie_cost = Int(strval);
    
    self iPrintLnBold("Box cost updated to ^2" + strval);
}