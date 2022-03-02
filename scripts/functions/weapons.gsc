ToggleAATOnDeath(player, value, aat)
{
    level.AAT[aat].occurs_on_death = value;
}

InvisWeaponsToggle(player, state)
{
    if(!isDefined(player))
        return;
    
    player SetBVar("Invisible Weapons", state);

    if(state)
    {
        player HideViewModel();
    }
    else
    {
        player ShowViewModel();
    }
}

EditPlayerAttachment(player, result, attach)
{
    if(!isDefined(player))
        return;

    weapon = player getCurrentWeapon();
    old_aat = player.AAT[weapon];
    player.AAT[weapon] = undefined;

    attaches = GetWepAttachments(weapon.name);

    if(!isdefined(attaches))
        attaches = [];

    upgrade = zm_weapons::is_weapon_upgraded(weapon);
    options = player GetWeaponOptions(weapon);
    acvi = player GetBuildKitAttachmentCosmeticVariantIndexes(weapon, upgrade);
    
    if(result)
    {
        Array::Add(attaches, attach);
    }
    else
    {
        ArrayRemoveValue(attaches, attach);
    }

    new_weap = GetWeapon(weapon.rootweapon.name, attaches);

    player takeweapon(weapon, 1);
    player GiveWeapon(new_weap, options, acvi);
    player switchtoweaponimmediate(new_weap);

    GiveAAT(player, old_aat, false, new_weap);
    player notify("weapon_change");
}

GetWepAttachments(wepname)
{
    attaches = [];
    split = strtok(wepname, "+");
    
    for(i = 1; i < split.size; i++)
        attaches[attaches.size] = split[i];

    return attaches;
}

SetMaxWeapons(player, number)
{
    if(!isdefined(player))
        return;

    if(!isdefined(level.maxweaponsarray))
        level.maxweaponsarray = [];
    
    level.maxweaponsarray[player GetEntityNumber()] = number;
    self iprintlnbold("Player has been allowed ^2" + number + "^7 weapons");
}

maxweaponschecker(player)
{
    if(!isdefined(player)) 
        return 0;
    
    if(isdefined(player.altbody) && player.altbody)
        return 16;

    if(!isdefined(level.maxweaponsarray[player GetEntityNumber()]))
    {
        if ( player hasperk( "specialty_additionalprimaryweapon" ) )
            return 3;
        return 2;
    }
    return level.maxweaponsarray[player GetEntityNumber()];
}

GiveClientWeapon(player, weapon)
{
    if(!isdefined(weapon) || !isdefined(player))
        return;

    player zm_weapons::weapon_give(GetWeapon(weapon), 0, 0);
    player switchtoweapon(GetWeapon(weapon));

    self iprintlnbold("Player was given weapon ^2" + GetBaseWeaponItemIndex(GetWeapon(weapon)));
}

GiveAAT(player, aat, print=true, weapon)
{
    if(!isdefined(player) || !isdefined(aat))
        return;

    if(!isdefined(weapon))
        weapon = AAT::get_nonalternate_weapon(player zm_weapons::switch_from_alt_weapon(player GetCurrentWeapon()));

    player.AAT[weapon] = aat;

    player clientfield::set_to_player("aat_current", level.AAT[ player.AAT[weapon] ].var_4851adad);

    if(print)
        self iPrintLnBold("AAT ^2" + aat + "^7 awarded to player.");
}

GiveCamo(player, camoIndex)
{
    if(!isdefined(player))
        return;

    camoIndex = level._camos_[camoIndex];
    if(!isdefined(camoIndex))
        camoIndex = 0;

    weapon = player GetCurrentWeapon();

    weapon_options = player CalcWeaponOptions(camoIndex, 0, 0);

    acvi = player GetBuildKitAttachmentCosmeticVariantIndexes(weapon, player HasUpgradedWep());

    player takeweapon(weapon, 1);
    player GiveWeapon(weapon, weapon_options, acvi);
    player switchtoweaponimmediate(weapon);

    self iPrintLnBold("^2Weapon camo set!");
}

EditAATParameter(player, value = 0, AAT = "zm_aat_turned", property = 0)
{
    switch(property)
    {
        case 0:
            level.AAT[AAT].percentage = value;
        break;
        case 1:
            level.AAT[AAT].cooldown_time_entity = value;
        break;
        case 2:
            level.AAT[AAT].cooldown_time_attacker = value;
        break;
        case 3:
            level.AAT[AAT].cooldown_time_global = value;
        break;
        default:
            return;
    }
    self iPrintLnBold("Value updated");
}

HasUpgradedWep()
{
    return zm_weapons::is_weapon_upgraded(self getCurrentWeapon());
}

TogglePapWeapon(player, upgrade)
{
    if(!isdefined(player))
        return;
    
    weapon = player GetCurrentWeapon();
    o_wep = player GetCurrentWeapon();

    old_aat = player.AAT[o_wep];
    player.AAT[o_wep] = undefined;

    base = zm_weapons::get_base_weapon(weapon);

    existing = GetWepAttachments(o_wep.name);

    if(upgrade)
    {
        Array::Add(existing, "extclip", 0);
        Array::Add(existing, "fmj", 0);
    }
    else
    {
        ArrayRemoveValue(existing, "extclip");
        ArrayRemoveValue(existing, "fmj");
    }

    newwep = zm_weapons::get_base_weapon(weapon);

    if(upgrade)
        newwep = zm_weapons::get_upgrade_weapon(weapon);

    weapon_options = player GetWeaponOptions(o_wep);
    acvi = player GetBuildKitAttachmentCosmeticVariantIndexes(o_wep, upgrade);
    weapon = GetWeapon(newwep.rootweapon.name, existing);

    player takeweapon(o_wep, 1);
    player GiveWeapon(weapon, weapon_options, acvi);
    player switchtoweaponimmediate(weapon);

    GiveAAT(player, old_aat, false, weapon);
    player notify("weapon_change");
}

DropWeapon(player)
{
    if(!isdefined(player))
        return;
    player dropitem(player getcurrentweapon());
    self iPrintLnBold("^1Dropped!");
}

DropAllWeps(player)
{
    if(!isdefined(player))
        return;
    
    foreach(weapon in player GetWeaponsList())
    {
        player dropItem(weapon);
    }
    self iPrintLnBold("All dropped");
}

Clusters(player, value)
{
    if(!isdefined(player))
        return;
    
    player SetBVar("Cluster Grenades", value);

    player.gcluster = false;
    while(isdefined(player) && player GetBVarEnabled("Cluster Grenades"))
    {
        player waittill("grenade_fire", grenade, weapon);
        if(player.gcluster)
            continue;
        if(!(isdefined(player) && player GetBVarEnabled("Cluster Grenades")))
        {
            return;
        }
        player thread GrenadeSplit( grenade, weapon );
    }
}

grenadesplit( grenade, weapon )
{
    lastspot = (0,0,0);
    while(isdefined(grenade))
    {
        lastspot = (grenade GetOrigin());
        wait .025;
    }
    self.gcluster = true;
    self MagicGrenadeType(weapon, lastspot , (250,0,250), 2);
    self MagicGrenadeType(weapon, lastspot , (250,250,250), 2);
    self MagicGrenadeType(weapon, lastspot , (250,-250,250), 2);
    self MagicGrenadeType(weapon, lastspot , (-250,0,250), 2);
    self MagicGrenadeType(weapon, lastspot , (-250,250,250), 2);
    self MagicGrenadeType(weapon, lastspot , (-250,-250,250), 2);
    self MagicGrenadeType(weapon, lastspot , (0,0,250), 2);
    self MagicGrenadeType(weapon, lastspot , (0,250,250), 2);
    self MagicGrenadeType(weapon, lastspot , (0,-250,250), 2);
    wait .025;
    self.gcluster = false;
}

ButterFingers(player, value)
{
    level endon("game_ended");
    level endon("end_game");
    
    if(!isdefined(player))
        return;
    player endon("disconnect");

    player SetBVar("Butterfingers", value);

    while(isdefined(player) && player GetBVarEnabled("Butterfingers"))
    {
        player util::waittill_any("weapon_change", "reload");
        if(!(isdefined(player) && player GetBVarEnabled("Butterfingers")))
            return;
        
        if(randomFloat(1) <= .33)
            player dropItem(player getCurrentWeapon());
    }

}

ChargeSpecial(player)
{
    if(!isdefined(player))
        return;

    player GadgetPowerSet(0, 100);

    self iPrintLnBold("Charged!");
}

UnlimitedSpecial(player, value)
{
    level endon("game_ended");
    level endon("game_end");

    if(!isdefined(player))
        return;
    
    player endon("disconnect");

    player SetBVar("Unlimited Specialist", value);

    while(isdefined(player) && player GetBVarEnabled("Unlimited Specialist"))
    {
        if(player GadgetIsActive(0))
            player GadgetPowerSet(0, 99);
        else
        {
            if(player GadgetPowerGet(0) < 100)
                player GadgetPowerSet(0, 100);
        }
        wait .025;
    }
}

ProjectilesEdit(player, num, type)
{
    if(!isDefined(player))
        return;
    
    if(!isdefined(player.projectilelist))
        player.projectilelist = [];
    
    player.projectilelist[type] = num;

    self iPrintLnBold("Projectiles updated");
}

ProjectileFireMonitor()
{
    self endon("spawned_player");
    self endon("disconnect");
    self endon("death");
    level endon("end_game");

    while(self.sessionstate != "spectator")
    {
        self waittill("weapon_fired");

        if(!isdefined(self.projectilelist))
            continue;
        
        foreach(key, value in self.projectilelist)
        {
            if(key == "default")
                weapon = self getCurrentWeapon();
            else
                weapon = getweapon(key);
            
            if(!isdefined(value))
                continue;
            
            for(i = 0; i < value; i++)
            {
                origin = self GetTagOrigin("tag_flash");
                magicBullet(weapon, origin, self RandomWeaponTarget(self.projectilespread, origin), self);
            }
        }
    }
}

ProjectileSpread(player, value)
{
    if(!isdefined(player))
        return;
    player.projectilespread = value;
    self iPrintLnBold("Updated");
}

RandomWeaponTarget(degrees = 5, origin)
{
    rand = (randomFloatRange(-1 * degrees, degrees), randomFloatRange(-1 * degrees, degrees), randomFloatRange(-1 * degrees, degrees));
    angles = combineAngles(rand, self getPlayerAngles());
    forward = AnglesToForward(angles);
    pos = VectorScale(forward, 10000);
    
    pos += origin;
    
    return pos;
}