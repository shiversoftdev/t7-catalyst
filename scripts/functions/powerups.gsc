SpawnPowerup(player, powerup = "full_ammo")
{
    if(!isdefined(player))
        return;

    origin = player GetTagOrigin("tag_weapon");
    location = origin + VectorScale(AnglesToForward(player GetPlayerAngles()), 100);

    level thread zm_powerups::specific_powerup_drop(powerup, location);
    self iPrintLnBold("Powerup spawned");
}

UnlimitedPowerupTime(player, result)
{
    if(result)
        level._powerup_timeout_custom_time = ::PowerupTimeOverride;
    else
        level._powerup_timeout_custom_time = undefined;
}

PowerupTimeOverride(powerup)
{
    return 0;
}