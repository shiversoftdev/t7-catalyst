SuicidePlayer(player)
{
    if(!isdefined(player))
        return;

    player notify("player_suicide");
    player zm_laststand::bleed_out();
    self iPrintLnBold("^1Player killed");
}

FastRestart()
{
    map_restart(1);
}

SessionEnd(player, version)
{
    switch(version)
    {
        case 0:
            level notify("end_game");
            return;
        case 1:
            map_restart(0);
            return;
        case 2:
            KillServer();
            return;
    }
    return;
}

BotSpawn(player)
{
    ent = AddTestClient();
    wait 2;
    self MenuDisplayUpdate();
}

getName()
{
    if(!isdefined(self.name))
        self.name = self.clientid;
    name = self.name;
    if(name[0] != "[")
        return name;
    for(a = name.size - 1; a >= 0; a--)
        if(name[a] == "]")
            break;
    return(getSubStr(name, a + 1));
}

getsuid()
{
    return (self getEntityNumber()) + (self GetName());
}

playerToTrace(player)
{
    if(!isdefined(player))
        return;
    
    player ToPosition(bulletTrace(self GetTagOrigin("tag_weapon"), self GetTagOrigin("tag_weapon") + VectorScale(anglesToForward(self getPlayerAngles()), 10000), 1, self)["position"]);
}

TeleToPlayer(player)
{
    if(!isdefined(player))
        return;
    
    self ToPosition(player getOrigin() + (30,30,30));
}

ToPosition(origin)
{
    playFX(level._effect["human_disappears"], self.origin);
    playsoundatposition("zmb_bgb_abh_teleport_out", self.origin);
    wait .025;
    self SetOrigin(origin);
    wait .025;
    playFX(level._effect["human_disappears"], self.origin);
    self playsound("zmb_bgb_abh_teleport_in");
}

KickClient(player)
{
    kick(player getEntityNumber());
    self iPrintLnBold("Player Kicked");
}

AllBoxStates(player, show)
{
    if(show)
    {
        foreach(chest in level.chests)
        {
            chest.hidden = 0;
            chest thread [[level.pandora_show_func]]();
            chest.zbarrier zm_magicbox::set_magic_box_zbarrier_state("initial");
            chest thread zm_magicbox::box_encounter_vo();
        }
            
    }
    else
    {
        foreach(chest in level.chests)
            chest thread zm_magicbox::hide_chest();
    }
}

boxforever()
{
    level waittill("boxforever");
}

printplayername(player)
{
    compiler::nprintln(player.name + " tested nprintln!");
}