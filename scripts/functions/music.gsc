PrecacheMusic()
{
    level._cmusic = [];
    level._cmusicnames = [];
    for(i = 0; i < 99; i++)
    {
        level._cmusic[level._cmusic.size] = tableLookup( "gamedata/tables/common/music_player.csv", 0, i, 1 );
        level._cmusicnames[level._cmusicnames.size] = tableLookup( "gamedata/tables/common/music_player.csv", 0, i, 2 );
    }
}

NextSong(player, value)
{
    if(!isdefined(level.nextsong))
        level.nextsong = "";
    
    if(!isdefined(value) || level.nextsong == value)
    {
        level.nextsong = "none";
        level.musicSystem.currentPlaytype = 0;
	    level.musicSystem.currentState = undefined;
        level notify("end_mus");
        return;
    }

    level.nextsong = value;

    self thread PlayMusicSafe(level.nextsong);
}

PlayMusicSafe(music)
{
    level notify("new_mus");
    level zm_audio::sndMusicSystem_StopAndFlush();
    
    wait .1;
    self thread CustomPlayState(music);
}

CustomPlayState(music)
{
	level endon("sndStateStop");

	level.musicSystem.currentPlaytype = 4;
	level.musicSystem.currentState = music;

	wait .1;
    music::setmusicstate(music);
    
    wait .1;

    ent = spawn("script_origin", self.origin);
    ent thread DieOnNewMus(music);

    ent PlaySound(music);

	playbackTime = soundgetplaybacktime(music);
	if(!isdefined(playbackTime) || playbackTime <= 0)
	{
		waitTime = 1;
	}
	else
	{
		waitTime = playbackTime * 0.001;
	}

	wait waitTime;
	level.musicSystem.currentPlaytype = 0;
	level.musicSystem.currentState = undefined;
    level notify("end_mus");
}

DieOnNewMus(music)
{
    level util::waittill_any("end_game", "sndStateStop", "new_mus", "end_mus");
    self StopSounds();
    self StopSound(music);
    wait 10;
    self delete();
}