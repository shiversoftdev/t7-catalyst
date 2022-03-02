#include scripts\codescripts\struct;
#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_message_shared;
#include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
#include scripts\shared\aat_shared;
#include scripts\shared\ai\margwa;
#include scripts\shared\ai\zombie_utility;
#include scripts\shared\flag_shared;
#include scripts\shared\vehicle_ai_shared;
#include scripts\shared\laststand_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\audio_shared;
#include scripts\shared\music_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\scene_shared;
#include scripts\shared\ai_shared;

#include scripts\zm\gametypes\_hud_message;
#include scripts\zm\_util;
#include scripts\zm\_zm;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_score;
#include scripts\zm\_zm_stats;
#include scripts\zm\gametypes\_globallogic;
#include scripts\zm\gametypes\_globallogic_score;
#include scripts\zm\_zm_weapons;
#include scripts\zm\_zm_perks;
#include scripts\zm\_zm_utility;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_spawner;
#include scripts\zm\_zm_laststand;
#include scripts\zm\_zm_altbody;
#include scripts\zm\_zm_magicbox;
#include scripts\zm\bgbs\_zm_bgb_round_robbin;
#include scripts\zm\_zm_audio;
#include scripts\zm\_zm_powerups;
#include scripts\zm\_zm_zonemgr;
#include scripts\zm\craftables\_zm_craftables;
#include scripts\zm\_zm_unitrigger;
#include scripts\zm\craftables\_zm_craftables;

#namespace serious;

autoexec __init__sytem__()
{
	system::register("serious", ::__init__, undefined, undefined);
}

__init__()
{
	SetDvar("g_maxDroppedWeapons", 24);
	
	level.strings  = [];
    level.status   = strTok("No Access;Normal Access;Trusted Access;VIP Access;Host", ";");
    level.menuName = "Catalyst";
	callback::on_start_gametype(::init);
	callback::on_connect(::on_player_connect);
	callback::on_spawned(::on_player_spawned);
}

#define IS_RECOVERY = false;
#define USE_ACHIEVECODE = false;

#define TOG_FORCEHOST = 1;
#define TOG_WEAPON_UPGRADED = 2;
#define TOG_RETAIN_PERKS = 3;
#define TOG_ALL_PERKS = 4;
#define TOG_ALL_MAGIC_PERKS = 5;
#define TOG_IS_DOWNED = 6;
#define TOG_IS_ALIVE = 7;
#define TOG_INCLUDEHOST = 8;
#define TOG_RESPAWN_W_LOADOUT = 9;
#define TOG_MATCHFLAG_ANTIQUIT = 10;
#define TOG_MATCHFLAG_ANTIJOIN = 11;
#define TOG_POWERUP_UNLIMITED = 12;
#define TOG_SHADOWS_MARGWAS_ALLOWED = 13;
#define TOG_FASTQUIT = 14;
#define TOG_NOBOXMOVE = 15;
#define TOG_ENDLESSWAIT = 16;