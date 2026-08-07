
type
integer  = Smallint;
pinteger = ^integer;

const

g_version              : byte = 234;

degtorad               = pi/180;

NOTSET                 = smallint.MaxValue;

////////////////////////////////////////////////////////////////////////////////
//
//  FRAME RATE
//

fr_fps1                = 60;
fr_RateTicks           = 1000/fr_fps1;
fr_FrameMS             = round(fr_RateTicks);
fr_ifps                = fr_fps1-1;

fr_fpsh                = fr_fps1 div 2; // half
fr_fpst                = fr_fps1 div 3; // thrid
fr_fpsq                = fr_fps1 div 4; // quarter
fr_fpsq3               = fr_fps1-fr_fpsq;
fr_fpsf                = fr_fps1 div 5; // 1/5
fr_fpss                = fr_fps1 div 6; // 1/6
fr_fpso                = round(fr_fps1/8); // 1/8
fr_fpsd10              = fr_fps1 div 10;
fr_fps1h               = fr_fpsh*3;     // 1,5
fr_fps2                = fr_fps1*2;
fr_fps3                = fr_fps1*3;
fr_fps4                = fr_fps1*4;
fr_fps5                = fr_fps1*5;
fr_fps6                = fr_fps1*6;
fr_fps10               = fr_fps1*10;
fr_fpst2               = fr_fpst*2; //2/3
//fr_fps60               = fr_fps1*60;
fr_fpsd15              = fr_fps1 div 15;

////////////////////////////////////////////////////////////////////////////////
//
//  Game settings borders
//

g_MaxAISlots           = 9; // 0-9 max skirmish AI skills


////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

MaxPlayers             = 8;
LastPlayer             = MaxPlayers-1; //0-7

// player state
ps_None                = 0;
ps_human               = 1;
ps_AI                  = 2;

// map scenario
mc_ffa3                = 0;
mc_ffa4                = 1;
mc_ffa5                = 2;
mc_ffa6                = 3;
mc_ffa7                = 4;
mc_ffa8                = 5;
mc_1x1                 = 6;
mc_2x2                 = 7;
mc_3x3                 = 8;
mc_4x4                 = 9;
mc_2x2x2               = 10;
mc_2x2x2x2             = 11;
mc_KeyPoints           = 12;
mc_KotH                = 13;
mc_royale              = 14;

mc_fixed_teams         : set of byte = [mc_1x1,mc_2x2,mc_3x3,mc_4x4,mc_2x2x2,mc_2x2x2x2];

allmapscenarios        : set of byte = [mc_ffa3..mc_royale];
mc_Last                = 14;

// map neutrall generators
mapg_5                 = 0;
mapg_10                = 1;
mapg_15                = 2;
mapg_20                = 3;
mapg_inf               = 4;

mapg_Last              = 4;  // 0-4  max neutrall generators options

// map symmetry types
maps_none              = 0;
maps_point             = 1;
maps_lineV             = 2;
maps_lineH             = 3;
maps_lineL             = 4;
maps_lineR             = 5;

maps_Last              = 5; // 0-5

// map templates
mapt_lake              = 0;
mapt_island            = 1;
mapt_temple            = 2;
mapt_cave              = 3;
mapt_steppe            = 4;
mapt_canyon            = 5;

mapt_last              = 5;

mapt_ltemple_dstep1    = round(360/MaxPlayers);
mapt_ltemple_dstep2    = round(mapt_ltemple_dstep1/MaxPlayers);

// map other
map_MinSize            = 2500;
map_SizeMenuStep       = 250;

// game type
gt_none                = 0;
gt_scirmish            = 1;
gt_campaing            = 2;

// game status
gs_paused0             = 0;
{gs_paused1             = 1;
gs_paused2             = 2;
gs_paused3             = 3;
gs_paused4             = 4;
gs_paused5             = 5;
gs_paused6             = 6;   }
gs_paused7             = 7;
gs_replayend           = 10;
gs_replayerror         = 11;
gs_replaypause         = 12;
gs_waitserver          = 13;
gs_waitplayers         = 14;
gs_win_team0           = 20; // 0
{gs_win_team1           = 21;
gs_win_team2           = 22;
gs_win_team3           = 23;
gs_win_team4           = 24;
gs_win_team5           = 25;
gs_win_team6           = 26;  }
gs_win_team7           = 27;
gs_running             = 31; // last status can't be more than 31 (%00011111)

r_random               = 0;
r_hell                 = 1;
r_uac                  = 2;
r_count                = 2;  // race num 0-r_count

MaxPlayerUnits         = 125;
MinUnitLimit           = 100;
MaxPlayerLimit         = MaxPlayerUnits*MinUnitLimit;

map_MaxSize            = 8000;

zone_solid             : word = word.MaxValue;

g_GameStartTime        = fr_fps1*5+fr_fps1-1;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

str_version            = 'v54';
str_gcaption           = 'MarsWars: HELL & UAC';
str_wcaption           : shortstring = str_gcaption+', '+str_version+#0;
str_copyright          : shortstring = 'TGA[T3DStudio] (c) 2016-2026';
str_ps_ttl             : char = '?';
str_ps_Me              : char = '>';
b2c                    : array[false..true] of char = ('-','+');

outlogfn               : shortstring = 'out.txt';


////////////////////////////////////////////////////////////////////////////////
//
//  Player log
//

MaxPlayerLog           = 255;

log_to_all             = %11111111;


lmt_chat_player0       = 1;
{lmt_chat_player1       = 2;
lmt_chat_player2       = 3;
lmt_chat_player3       = 4;
lmt_chat_player4       = 5;
lmt_chat_player5       = 6;
lmt_chat_player6       = 7;}
lmt_chat_player7       = 8; // LastPlayer
lmt_chat_local         = 9;
lmt_game_message       = 10;
lmt_game_end           = 11;
lmt_game_ReadyToStart  = 12;
lmt_game_BreakStarting = 13;
lmt_game_StartsIn      = 14;
lmt_game_ResetIn       = 15;
lmt_game_Paused        = 16;
lmt_game_Resumed       = 17;
lmt_player_connected   = 18;
lmt_player_leave       = 19;
lmt_player_timeout     = 20;
lmt_player_defeated    = 21;
lmt_player_revealed    = 22;
lmt_player_surrender   = 23;
lmt_player_ready       = 24;
lmt_player_nready      = 25;
lmt_prod_BadPlace      = 26;
lmt_prod_BadOrder      = 27;
lmt_prod_CD            = 28;
lmt_prod_AllBusy       = 29;
lmt_prod_Unavailable   = 30;
lmt_unit_readyU        = 31;
lmt_unit_readyB        = 32;
lmt_unit_captured      = 33;
lmt_unit_lost          = 34;
lmt_unit_LevelUp       = 35;
lmt_unit_attackedU     = 36;
lmt_unit_attackedB     = 37;
lmt_unit_NeedBuilder   = 38;
lmt_unit_NeedProdUnit  = 39;
lmt_unit_resurrected   = 40;
lmt_unit_MaxLevel      = 41;
lmt_upgrade_InProgress = 42;
lmt_upgrade_complete   = 43;
lmt_Req_Energy         = 44;
lmt_Req_HellPower      = 45;
lmt_Req_UACLoot        = 46;
lmt_Req_Common         = 47;
lmt_Req_Limit          = 48;
lmt_Req_MaxCount       = 49;
lmt_Req_MaxBuilders    = 50;
lmt_markLook           = 51;
lmt_markAttack         = 52;
lmt_allies_attackedU   = 53;
lmt_allies_attackedB   = 54;
lmt_ability_reload     = 55;
lmt_ability_Casting    = 56;
lmt_ability_BadPlace   = 57;
lmt_ability_ReqUACNear = 58;
lmt_ability_ReqHelNear = 59;
lmt_ability_Tar2Close  = 60;
lmt_kpoint_CaptureStart= 61;
lmt_kpoint_Captured    = 62;
lmt_ngen_exh           = 63;
lmt_ngen_Captured      = 64;
lmt_ngen_Alarm         = 65;
lmt_ngen_lost          = 66;
lmt_koth_CaptureStart  = 67;
lmt_koth_Alarm         = 68;
lmt_invalid_Target     = 69;
lmt_Invalid_Order      = 70;
lmt_other_UACStrike    = 71;
lmt_other_UACScan      = 72;
lmt_replay_RecStart    = 73;
lmt_replay_RecStop     = 74;
lmt_replay_RecError    = 75;

lmts_menu_chat         = [
                          lmt_chat_player0..
                          lmt_chat_player7,
                          lmt_chat_local,
                          lmt_game_message,
                          lmt_game_end,
                          lmt_game_ReadyToStart,
                          lmt_game_BreakStarting,
                          lmt_game_StartsIn,
                          lmt_game_ResetIn,
                          lmt_game_Paused,
                          lmt_game_Resumed,
                          lmt_player_connected,
                          lmt_player_leave,
                          lmt_player_timeout,
                          lmt_player_defeated,
                          lmt_player_revealed,
                          lmt_player_surrender,
                          lmt_player_ready,
                          lmt_player_nready,
                          lmt_replay_RecStart,
                          lmt_replay_RecStop,
                          lmt_replay_RecError
                         ];
lmts_last_events       = [1..255];

lmt_argt_unit          = 0;
lmt_argt_upgrade       = 1;
lmt_argt_ability       = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  NETGAME
//

net_DefaultPort           = 10666;

net_MaxQuality            = 9;
rpls_MaxQuality           = net_MaxQuality div 2;
                                                             // 60 140 220 300 380 460 540 620 700 800
Quality2Units             : array[0..net_MaxQuality] of byte = (15,35 ,55 ,75 ,95 ,115,135,155,175,200);

TTLMaxClientLobby         = fr_fps1*10;
TTLMaxClientGame          = fr_fps1*60;
TTLServer                 = fr_fps1;

net_MaxPing               = word.MaxValue-fr_FrameMS;

net_SendTimePing          = fr_fps2;
net_SendTimeClient1       = fr_fpsq;
net_SendTimeClient2       = fr_fpsd10;
net_SendTimeServer        = fr_fps1 div 30;
MaxNetBuffer              = 4096;

net_svLanAdv_port         = 63666; // local servers advertisement port
net_svLanAdv_portS        = swap(net_svLanAdv_port);
net_svLanAdv_ip           : cardinal = $FFFFFFFF; // 255.255.255.255
net_svLanAdv_time         = fr_fps1*2;

ns_none                   = 0;
ns_server                 = 1;
ns_client                 = 2;

nmid_LAN_Adv              = 2;
nmid_LobbyInfo            = 3;
nmid_connect              = 4;
nmid_ClientData           = 5;
nmid_LogMessage           = 6;
nmid_LogUpdate            = 7;
nmid_GameData             = 8;
nmid_pause                = 9;
nmid_ServerFull           = 10;
nmid_WrongVersion         = 11;
nmid_NoNewObservers       = 12;
nmid_NotConnected         = 13;
nmid_order                = 14;
nmid_PlayerLeave          = 15;
nmid_map_mark             = 16;
nmid_PlayerSurrender      = 17;
nmid_lobby_PJumpToSlot    = 18;
nmid_lobby_PAILevelScroll = 19;
nmid_lobby_PAIToggle      = 20;
nmid_lobby_PRace          = 21;
nmid_lobby_PTeam          = 22;
nmid_lobby_PObserver      = 23;
nmid_lobby_MSeed          = 24;
nmid_lobby_MScenario      = 25;
nmid_lobby_MGenerators    = 26;
nmid_lobby_MSize          = 27;
nmid_lobby_MTemplate      = 28;
nmid_lobby_MSymmetry      = 29;
nmid_lobby_MRandom        = 30;
nmid_lobby_GFixedPositions= 31;
nmid_lobby_GAISlots       = 32;
nmid_lobby_GNewObservers  = 33;
nmid_lobby_GRandomScirmish= 34;
nmid_ping_Request         = 40;
nmid_ping_Answer          = 41;
nmid_ServerInfo           = 42;
nmid_ServerInfoReq        = 43;


chat_all                  = 255;
chat_allies               = 254;

////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER ORDERS
//

uo_build               = 1;
uo_corder              = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT OTDERS
//

co_empty               = -32000;
co_rcamove             = -400;
co_rcmove              = -401;
co_destroy             = -402;
co_stand               = -403;
co_move                = -404;
co_patrol              = -405;
co_astand              = -406;
co_amove               = -407;
co_apatrol             = -408;
co_ability             = -409;
co_supgrade            = -416;
co_cupgrade            = -417;
co_sunit               = -418;
co_cunit               = -419;
co_pcancle             = -420;
co_markLook            = -421;
co_markAttack          = -422;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: requirements to attacker and some bits
//

wpr_any                : cardinal =  0;
wpr_ground             : cardinal =  1;
wpr_air                : cardinal =  2;
wpr_move               : cardinal =  4;
wpr_reload             : cardinal =  8;

aw_fsr0                = 15000;

aw_srange              =  0;            // attack range = sight range
aw_fsr                 =  aw_fsr0+7500; // attack range = sight range + (x-aw_fsr)
aw_dmelee              = -8;            // default melee range
aw_hmelee              = -64;           // default heal/reapir melee range

////////////////////////////////////////////////////////////////////////////////
//
//  Target requirements bits
//

wtr_owner_p            : cardinal = 1;         // own
wtr_owner_a            : cardinal = 1 shl 1 ;  // ally
wtr_owner_e            : cardinal = 1 shl 2 ;  // enemy
wtr_hits_h             : cardinal = 1 shl 3 ;  // 0<hits<mhits
wtr_hits_d             : cardinal = 1 shl 4 ;  // fdead_hits<hits<=0
wtr_hits_a             : cardinal = 1 shl 5 ;  // hits=mhits
wtr_bio                : cardinal = 1 shl 6 ;  // non mech
wtr_mech               : cardinal = 1 shl 7 ;  // mech
wtr_unit               : cardinal = 1 shl 8 ;  // unit
wtr_building           : cardinal = 1 shl 9 ;  // building
wtr_complete           : cardinal = 1 shl 10;  // complete=true
wtr_ncomplete          : cardinal = 1 shl 11;  // complete=false
wtr_ground             : cardinal = 1 shl 12;
wtr_fly                : cardinal = 1 shl 13;
wtr_light              : cardinal = 1 shl 14;
wtr_heavy              : cardinal = 1 shl 15;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: type
//

wpt_missle             = 1;
wpt_resurect           = 2;
wpt_heal               = 3;
wpt_unit               = 4;
wpt_directdmg          = 5;
wpt_directdmgZ         = 6;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: move status
//

wmove_impassible       = 0;
wmove_closer           = 1;
wmove_farther          = 2;
wmove_noneed           = 3;

TargetCheckSRangeBonus = 50;

////////////////////////////////////////////////////////////////////////////////
//
//  AI bits
//

ai_MaxAlarms           = 8;
ai_LastAlarm           = ai_MaxAlarms-1;

aif_base_smart_order   : cardinal = 1;
aif_base_suicide       : cardinal = 1 shl 1;
aif_base_advanceMain   : cardinal = 1 shl 2;
aif_base_advanceOther  : cardinal = 1 shl 3;
aif_base_BuilderMove   : cardinal = 1 shl 4;
aif_base_DefendOwn     : cardinal = 1 shl 5;
aif_base_DefendAlly    : cardinal = 1 shl 6;
aif_army_scout         : cardinal = 1 shl 7;
aif_army_early_attack0 : cardinal = 1 shl 8; // 'scout' attack
aif_army_early_attack1 : cardinal = 1 shl 9; // 'early minimum group' attack
aif_army_smart_order   : cardinal = 1 shl 10;
aif_army_smart_micro   : cardinal = 1 shl 11;
aif_army_smart_Target  : cardinal = 1 shl 12;
aif_upgr_smart_order   : cardinal = 1 shl 13;
aif_ability_detection  : cardinal = 1 shl 14;
aif_ability_other      : cardinal = 1 shl 15;
aif_ability_TowerRush  : cardinal = 1 shl 16;
aif_cheat_VisBuildings : cardinal = 1 shl 17;
aif_cheat_VisUnits     : cardinal = 1 shl 18;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT BUFFs
//

ub_PainState           = 0;
ub_Resurected          = 1;
ub_Cast                = 2;
ub_AltMode             = 3;
ub_Invisibility        = 4;
ub_Detector            = 5;
ub_Summoned            = 6;
ub_Teleported          = 7;
ub_HellVision          = 8;
ub_Damaged             = 9;
ub_Scaned              = 10;
ub_DecayAura           = 11;
ub_SpecPause           = 12;
ub_Heroic              = 13;
ub_SphereInvuln        = 14;
ub_SphereInvis         = 15;
ub_SphereRDamage       = 16;
ub_SphereDDamage       = 17;
ub_SphereTurbo         = 18;
ub_SphereSoul          = 19;

MaxUnitBuffs           = 20;
LastUnitBuff           = MaxUnitBuffs-1;

ub_infinity            = NOTSET;
b2ib                   : array[false..true] of smallint = (0,ub_infinity);


////////////////////////////////////////////////////////////////////////////////
//
//  OBSTACLES
//

MaxObstacles           = 800;

// Obstacles grid
MapObstaclesGridW      = 200;
MapObstaclesGridN      = map_MaxSize div MapObstaclesGridW;

ObstaclesRMin          = 10;
ObstaclesRStep         = 45;
ObstacleMinInnerR      = ObstaclesRStep*3;

////////////////////////////////////////////////////////////////////////////////
//
//  UPGRADES
//

upgr_hell_DistDamage1  = 1;  // t1 distance attacks damage    // "t1"
upgr_hell_UnitArmor    = 2;  // base unit armor
upgr_hell_BuildArmor   = 3;  // base building armor
upgr_hell_MeleeDamage  = 4;  // melee attack damage
upgr_hell_Regeneration = 5;  // regeneration
upgr_hell_PainFactor   = 6;  // pain state
upgr_hell_ADetection   = 7;  // active detection
upgr_hell_BuilderR     = 8;  // main range
upgr_hell_HKeepShift   = 9;  // HK teleportation
upgr_hell_DecayAura    = 10; // decay aura
upgr_hell_TowerR       = 11; // towers range

upgr_hell_Spectre      = 12; // demon invisibility            // "t2"
upgr_hell_UnitSightR   = 13; // demons vision
upgr_hell_Phantoms     = 14; // phantoms
upgr_hell_DistDamage2  = 15; // t2 distance attacks damage
upgr_hell_Resurrect    = 16; // archvile ability
upgr_hell_TeleportCD   = 17; // Teleport reload
upgr_hell_T2TNoCD      = 18; // Teleport-t-toteleport no cd teleportation
upgr_hell_EvilEyeR     = 19; // hell Eye time
upgr_hell_TotemInvis   = 20; // totem and eye invisible
upgr_hell_BuildRestore = 21; // build restoration
upgr_hell_TowerBlink   = 22; // teleport towers
upgr_hell_FTowerAMech  = 23; // Fire tower caco weapon


upgr_uac_DistDamage    = 31; // distance attack               // "t1"
upgr_uac_BioArmor      = 32; // infantry armor
upgr_uac_BuildArmor    = 33; // base b armor
upgr_uac_RepairTools   = 34; // repair/health upgr
upgr_uac_BioSpeed      = 35; // infantry speed
upgr_uac_SSMWeapon     = 36; // antiaircrafter surface-to-surface attack
upgr_uac_ADetection    = 37; // active detection
upgr_uac_BuilderR      = 38; // main sr
upgr_uac_CCFly         = 39; // CC fly ability
upgr_uac_CCAttack      = 40; // CC turret
upgr_uac_TowerR        = 41; // towers sr

upgr_uac_DronTurret    = 42; // dron turret                   // "t2"
upgr_uac_UnitSightR    = 43; // infatry vision
upgr_uac_CommandoInvis = 44; // commando invis
upgr_uac_AASplash      = 45; // anti-air missiles splash
upgr_uac_MechSpeed     = 46; // mech speed
upgr_uac_MechArmor     = 47; // mech arm
upgr_uac_TerAAWeapon   = 48; // termintator anti-air weapon
upgr_uac_Transport     = 49; // transport capacity upgrade
upgr_uac_RadarR        = 50; // Radar
upgr_uac_TurretPlasma  = 51; // plasma weapons fro anti-ground turret
upgr_uac_TurretArmor   = 52; // turrets armor


upgr_fprod_build       = 251;
upgr_fprod_upgr        = 252;
upgr_fprod_unit        = 253;
upgr_invuln            = 254;



////////////////////////////////////////////////////////////////////////////////
//
//  MISSILES
//

MID_Imp                = 101;
MID_Cacodemon          = 102;
MID_Baron              = 103;
MID_CyberRocket        = 104;
MID_Revenant           = 105;
MID_Mancubus           = 106;
MID_YPlasma            = 107;
MID_BPlasma            = 108;
MID_Bullet             = 109;
MID_SShot              = 110;
MID_SSShot             = 111;
MID_BFG                = 112;
MID_Granade            = 113;
MID_Tank               = 114;
MID_Blizzard           = 115;
MID_ArchFire           = 116;
MID_Flyer              = 117;
MID_URocket            = 119;
MID_URocketS           = 120;
MID_Chaingun           = 121;
MID_SChaingun          = 122;


mh_none                = 0;
mh_magnetic            = 1;
mh_homing              = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  UNITS
//

MaxUnits               = LastPlayer*MaxPlayerUnits+MaxPlayerUnits;
MaxMissiles            = MaxUnits;

MaxUnitWeapons         = 4;
LastUnitArms           = MaxUnitWeapons-1;  //0-3

MaxUnitLevel           = 4;
LastUnitLevel          = MaxUnitLevel-1;  //0-3

// damage modificator

MaxDamageModFactors    = 2 ;
LastDamageModFactor    = MaxDamageModFactors-1; //0..1

dm_AntiUnitBioHeavy2   = 1 ; //   2*[unit bio heavy]
dm_SSGShot2            = 2 ; //   2*[unit bio heavy] 0.5*[mech]
dm_AntiUnitBioLight2   = 3 ; //   2*[unit bio light]
dm_AntiUnitBio2        = 4 ; //   2*[unit bio]       0.5*[buildings]
dm_AntiUnitMech2       = 5 ; //   2*[unit mech]
dm_AntiUnitLight2      = 6 ; //   2*[unit light]
dm_AntiFly2            = 7 ; //   2*[fly]
dm_AntiGroundLight2    = 8 ; //   2*[light ground]
dm_RSMShot             = 9 ; //   2*[buildings]
dm_Siege4              = 10; //   4*[buildings]
dm_Lost                = 11; //                      0.5*[mech]
dm_BFG                 = 12; // 0.5*[buildings]
dm_AntiBio2            = 13; //   2*[unit bio]
dm_AntiHeavy2          = 14; //   2*[unit heavy]


// LIMIT
ul1                    = MinUnitLimit;
//ul1q                   = MinUnitLimit+(MinUnitLimit div 4);
ul1h                   = MinUnitLimit+(MinUnitLimit div 2);
ul2                    = MinUnitLimit*2;
ul3                    = MinUnitLimit*3;
ul4                    = MinUnitLimit*4;
ul5                    = MinUnitLimit*5;
//ul6                    = MinUnitLimit*6;
//ul8                    = MinUnitLimit*8;
ul10                   = MinUnitLimit*10;
ul12                   = MinUnitLimit*12;
ul15                   = MinUnitLimit*15;
ul20                   = MinUnitLimit*20;
ul30                   = MinUnitLimit*30;

// production time
ptime1                 = 20;
ptimeh                 = ptime1 div 2;
ptimeq                 = ptimeh div 2;
ptime1h                = ptime1+ptimeh;
ptime1q                = ptime1+ptimeq;
ptime2                 = ptime1*2;
ptime3                 = ptime1*3;
ptime4                 = ptime1*4;
ptime5                 = ptime1*5;
ptime10                = ptime1*10;

uf_ground              = false;
uf_fly                 = true;

mvxy_none              = 0;
mvxy_relative          = 1;
mvxy_strict            = 2;

BaseDamage1            = 45;
BaseDamageh            = BaseDamage1 div 2;
BaseDamaget            = BaseDamage1 div 3;
//BaseDamageq            = BaseDamage1 div 4;
BaseDamage1h           = BaseDamage1+BaseDamageh;
BaseDamage2            = BaseDamage1*2;
BaseDamage3            = BaseDamage1*3;
BaseDamage4            = BaseDamage1*4;
BaseDamage5            = BaseDamage1*5;
BaseDamage6            = BaseDamage1*6;
//BaseDamage8            = BaseDamage1*8;
BaseDamage10           = BaseDamage1*10;

BaseRegen1             = 5;
BaseRegenh             = BaseRegen1 div 2;

BaseDamageLevel1       = 2.5;
BaseArmorLevel1        = 2.5;

UpgradeUnitSpeedBonus  = 2;
UpgradeDamageBonus1    = 7;
UpgradeArmorBonus1     = 7;
UpgradeUnitArmorBonus  = UpgradeArmorBonus1;
UpgradeBuildArmorBonus = UpgradeArmorBonus1*2+round(UpgradeArmorBonus1/2);

BaseHeal1              = BaseRegen1*4;
BaseHealBonus1         = BaseHeal1 div 3;
BaseRepair1            = BaseRegen1*4;
BaseRepairBonus1       = BaseRepair1 div 3;

DecayAuraDamage        = UpgradeDamageBonus1;

////////////////////////////////////////////////////////////////////////////////
//
//  UIDs
//

// HELL

UID_HKeep              = 1;
UID_HAKeep             = 2;
UID_HGate              = 3;
UID_HPools             = 4;
UID_HPentagram         = 5;
UID_HMonastery         = 6;
UID_HFortress          = 7;
UID_HFTower            = 8;
UID_HTotem             = 9;
UID_HTeleport          = 10;
UID_HEyeNest           = 11;
UID_HEye               = 12;
UID_HAltar             = 13;
UID_HCommandCenter     = 14;
UID_HACommandCenter    = 15;
UID_HBarracks          = 16;
UID_HMarker            = 17;

UID_LostSoul           = 20;
UID_Phantom            = 21;
UID_Imp                = 22;
UID_Demon              = 23;
UID_Cacodemon          = 24;
UID_Knight             = 25;
UID_Baron              = 26;
UID_Revenant           = 27;
UID_Pain               = 28;
UID_Mancubus           = 29;
UID_Arachnotron        = 30;
UID_Archvile           = 31;
UID_Cyberdemon         = 32;
UID_Mastermind         = 33;

UID_ZMedic             = 35;
UID_ZEngineer          = 36;
UID_ZSergant           = 37;
UID_ZSSergant          = 38;
UID_ZCommando          = 39;
UID_ZAntiaircrafter    = 40;
UID_ZSiegeMarine       = 41;
UID_ZFPlasmagunner     = 42;
UID_ZBFGMarine         = 43;

// UAC

UID_UCommandCenter     = 50;
UID_UACommandCenter    = 51;
UID_UBarracks          = 52;
UID_UFactory           = 53;
UID_UWeaponFactory     = 54;
UID_UScienceCenter     = 55;
UID_UComputerStation   = 56;
UID_UGTurret           = 57;
UID_UATurret           = 58;
UID_URadar             = 59;
UID_UAcademy           = 60;
UID_UHPowerConductor   = 61;
UID_URMStation         = 62;

UID_UPortal            = 65;
UID_UBaseMil           = 66;
UID_UBaseCom           = 67;
UID_UBaseGen           = 68;
UID_UBaseRef           = 69;
UID_UBaseNuc           = 70;
UID_UBaseLab           = 71;
UID_USPort             = 72;

UID_Engineer           = 80;
UID_Medic              = 81;
UID_Sergant            = 82;
UID_SSergant           = 83;
UID_Commando           = 84;
UID_Antiaircrafter     = 85;
UID_SiegeMarine        = 86;
UID_FPlasmagunner      = 87;
UID_BFGMarine          = 88;
UID_UTransport         = 89;
UID_UACDron            = 90;
UID_Terminator         = 91;
UID_Tank               = 92;
UID_Flyer              = 93;


uids_hell              = [1 ..49];
uids_uac               = [50..99];

uids_marines           = [UID_Engineer ,UID_Medic ,UID_Sergant ,UID_SSergant ,UID_Commando ,UID_Antiaircrafter ,UID_SiegeMarine , UID_FPlasmagunner ,UID_BFGMarine ];
uids_zimbas            = [UID_ZEngineer,UID_ZMedic,UID_ZSergant,UID_ZSSergant,UID_ZCommando,UID_ZAntiaircrafter,UID_ZSiegeMarine, UID_ZFPlasmagunner,UID_ZBFGMarine];
uids_arch_res          = [UID_Imp,UID_Demon,UID_Cacodemon,UID_Knight,UID_Baron,UID_Revenant,UID_Mancubus,UID_Arachnotron]+uids_zimbas;
uids_demons            = [UID_LostSoul..UID_Archvile]+uids_zimbas;
uids_all               = [0..255];


////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ACTIONS
//

ua_move                = 0;
ua_hold                = 1;
ua_amove               = 2;
ua_ability1            = 3;
ua_ability2            = 4;
ua_ability3            = 5;

ua_patrol              = 6; // only for client data transfer
ua_apatrol             = 7; // only for function

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ABILITIES
//

uab_Teleport           = 1;
uab_Recall             = 2;
uab_UACScan            = 3;
uab_UACStrike          = 4;
uab_HEyeSpawn          = 5;
uab_HTowerBlink        = 6;
uab_HKeepShift         = 7;
uab_HKeepAura          = 8;
uab_SpawnLost          = 9;
uab_SpawnLostTo        = 10;
uab_HEyeVision         = 11;
uab_UACCCLand          = 12;
uab_UACCCLandTo        = 13;
uab_HellCCLand         = 14;
uab_HellCCLandTo       = 15;

uab_Unload             = 16;
uab_UnloadTo           = 17;

uab_SphereSoul         = 20;
uab_SphereInvis        = 21;
uab_SphereInvuln       = 22;
uab_SphereRDamage      = 23;
uab_SphereDDamage      = 24;
uab_SphereTurbo        = 25;

uab_UACGeneral         = 26;
uab_Bribe              = 27;
uab_Hack               = 28;

uab_ToHAKeep           = 30;
uab_ToHGate            = 31;
uab_ToHPools           = 35;
uab_ToHACommandCenter  = 36;
uab_ToHBarracks        = 37;

uab_ToUACommandCenter  = 40;
uab_ToUBarracks        = 41;
uab_ToUFactory         = 42;
uab_ToUWeaponFactory   = 43;
uab_ToUAGTurret        = 47;
uab_ToUAATurret        = 48;
uab_ToUACDron          = 49;
uab_ToUGTurretTo       = 50;
uab_ToUATurretTo       = 51;
uab_LvlUpURadar        = 52;
uab_LvlUpURMStation    = 53;

uab_HSpecter           = 55;
uab_HStealth           = 56;
uab_HHTShroud          = 57;
uab_HT2TNoCD           = 58;
uab_UAASplash          = 59;


////////////////////////////////////////////////////////////////////////////////
//
//  Key Points
//


map_generators_LFSecs  : array[0..mapg_Last] of cardinal = (        60*5,        60*10,        60*15,        60*20,0);
map_generators_LFTicks : array[0..mapg_Last] of cardinal = (fr_fps1*60*5,fr_fps1*60*10,fr_fps1*60*15,fr_fps1*60*20,0);
map_generators_EnergyS = 1000;
map_generators_EnergyO = 2000;
map_generators_LimitS  = ul1;
map_generators_LimitO  = ul5;

MaxKeyPoints           = MaxPlayers*3;
LastKeyPoint           = MaxKeyPoints-1;
KeyPointLifeClientMax  = (1 shl 10)-1; // 1024
KeyPointLifeClientCX   = KeyPointLifeClientMax/(60*20);
KeyPointLifeClientXC   = (60*20)/KeyPointLifeClientMax;

keyPoint_CTime_Def_Sec = ptimeh;
keyPoint_CTime_Def_Tick= fr_fps1*keyPoint_CTime_Def_Sec;
keyPoint_CTime_Gen_Tick= fr_fps1*ptime1;
keyPoint_CTime_KotH_Sec= ptime3;
keyPoint_CTime_KotH_Tick= fr_fps1*keyPoint_CTime_KotH_Sec;
keyPoint_DefR          = 100;
keyPoint_GenR          = 75;
keyPoint_GenNB         = keyPoint_GenR-25;
keyPoint_KotR          = 350;
keyPoint_KotRW         = round(keyPoint_KotR/1.44);

keyPoint_mcN           = 4;
keyPoint_mcDirStep     = 360 div keyPoint_mcN;

keyPoint_KotH_pause_sec= 60*5;
keyPoint_KotH_pause    = fr_fps1*keyPoint_KotH_pause_sec;


////////////////////////////////////////////////////////////////////////////////
//
//  SCOREBOARD
//


psc_units_created      = 0;
psc_units_summoned     = 1;
psc_units_resurected   = 2;
psc_units_captured     = 3;
psc_units_lost         = 4;
psc_units_destroyed    = 5;
psc_builds_created     = 6;
psc_builds_summoned    = 7;
psc_builds_captured    = 8;
psc_builds_lost        = 9;
psc_builds_destroyed   = 10;
psc_upgrades_level     = 11;
psc_units_ExpTotal     = 12;

psc_Last               = 12;

psi_res_energy_max     = 0;
psi_res_UACLoot        = 1;
psi_res_HellPower      = 2;

psi_Last               = 2;


////////////////////////////////////////////////////////////////////////////////
//
//  OTHER
//

PlayerMaxBuilders      = 4;

UACGeneralsMax         = 4;

fr_mancubus_rld        = fr_fps2+fr_fpsh;  //2.5
fr_mancubus_rld_s1     = fr_fps2-fr_fpss;
fr_mancubus_rld_s2     = fr_fps1+fr_fpss;
fr_mancubus_rld_s3     = fr_fpsh;

fr_archvile_s          = fr_fps1+fr_fpss;

MaxPlayerNameLen       = 14;

hits_dead              = -ptime1*fr_fps1;
hits_fdead             = hits_dead+fr_fps3;
hits_ndead             = hits_dead-1;

hits_resurrected       = -fr_fps1h;

hits_fdead_border      = -BaseDamage1*3;

base_r1                = 350;
base_rh                = base_r1 div 2;
base_r1h               = base_r1+(base_r1 div 2);
base_r2                = base_r1*2;
base_r3                = base_r1*3;
base_r4                = base_r1*4;
//base_r5                = base_r1*5;
base_r6                = base_r1*6;

scirmish_MaxLost       = 20;
scirmish_MaxHAltar     = 3;

transport_exp_damage   = BaseDamage4;
regen_period           = fr_fps1;
regen_period1          = regen_period/fr_fps1;
order_period           = fr_fpsh+1;
MinVisionTime          = fr_fps2;

HellPower_Max          = 15000;
HellPower_PerLimit     = 100;
HellPower_PerHP        = 10;
HellPower_AddPeriod    = fr_fps1;
HellPower_Add1         = HellPower_PerLimit;
HellPower_Add2         = HellPower_Add1+(HellPower_Add1 div 2);
HellPower_Add3         = HellPower_Add1*2;
UACLoot_Max            = 30000;

UACStrike_Revealing_sec= 5;
UACStrike_Revealing    = UACStrike_Revealing_sec*fr_fps1;

detection_time_sec     = 8;
detection_time         = fr_fps1*detection_time_sec;

hell_vision_time       = fr_fps1*detection_time_sec;

step_build_reload      = fr_fps1*5;
max_build_reload       = step_build_reload*2;

melee_r                = 8;

dir_stepX              : array[0..7] of integer = (1, 1, 0,-1,-1,-1,0,1);
dir_stepY              : array[0..7] of integer = (0,-1,-1,-1, 0, 1,1,1);

soul_regen             = 3;
soul_maxHeal           = 1000;
soul_time              = soul_maxHeal div soul_regen;
soul_time_sec          = round(soul_time/fr_fps1);
invis_time_sec         = 60;
invis_time             = fr_fps1*invis_time_sec;
invuln_time_sec        = 30;
invuln_time            = fr_fps1*invuln_time_sec;
rdamage_time_sec       = 30;
rdamage_time           = fr_fps1*rdamage_time_sec;
ddamage_time_sec       = 20;
ddamage_time           = fr_fps1*ddamage_time_sec;
dturbo_time_sec        = 15;
dturbo_time            = fr_fps1*dturbo_time_sec;

tank_sr                = 20;
rocket_sr              = tank_sr*2;
bfg_sr                 = rocket_sr*4;
blizzard_sr            = rocket_sr*3;

player_default_ai_level= 5;
sintMaxHits            = 126;
_d2shi                 = abs(hits_dead div 125)+1;   // 5

fly_z                  = 80;
fly_hz                 = fly_z div 2;
fly_height             : array[false..true] of integer = (1,fly_z);

pain_time_hell         = fr_fps1;
pain_time_uac          = fr_fpsh;

ai_names_max           = 57;
ai_names_o             : array[0..ai_names_max-1] of shortstring = (
                         ' TGA'       ,' NRM'       ,' BFG'       ,' Dant3'    ,' marat'    ,' Notarget'  ,' Am$ek'     ,' Chainie'   ,' BND'       ,' NicoTheFug',
                         ' Mud'       ,' Aurora'    ,' Archi'     ,' print423' ,' Rising'   ,' KolyanRPG' ,' Boiec'     ,' ManWithGun',' Teran'     ,' ZZYZX'     ,
                         ' Jet'       ,' ABK'       ,' NekoRanger',' OutCast'  ,' Igara'    ,' VoZj'      ,' Raymund'   ,' Murphy'    ,' Jabberwock',' NikcGreen' ,
                         ' Zetor'     ,' Bertie'    ,' Doomersov' ,' Seifer'   ,' Mostcus'  ,' CWolf'     ,' Ipse'      ,' Sergh'     ,' cybermind' ,' Dem'       ,
                         ' Romero'    ,' Carmack'   ,' Keen'      ,' BJ'       ,' Doomguy'  ,' Slayer'    ,' Ranger'    ,' Grunt'     ,' Deimos'    ,' Phobos'    ,
                         ' Bitterman' ,' [LeD]JakeC',' Wereknight',' ArKnife'  ,' Revento'  ,' DRON12261' ,' Krik_IDDQD');

DefaultTargetWeight    = 100;

{$IFDEF _FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
//  REPLAYS
//

rpls_WriteTimeServer   = fr_fps1 div 30;

////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

snd_MaxMusicListSize   = 15;
snd_MaxSoundVolume     = 200;

////////////////////////////////////////////////////////////////////////////////
//
//  INPUT
//

iAct_any               = 0;
iAct_mlb               = 1;
iAct_mrb               = 2;
iAct_mmb               = 3;

iAct_mwu               = 4;
iAct_mwd               = 5;

iAct_left              = 6;
iAct_right             = 7;
iAct_up                = 8;
iAct_down              = 9;

iAct_esc               = 10;
iAct_return            = 11;
iAct_control           = 12;
iAct_alt               = 13;
iAct_shift             = 14;
iAct_backspace         = 15;

iAct_ScreenShot        = 16;
iAct_Tab               = 17;
iAct_Delete            = 18;

iAct_LastEvent         = 19;

iAct_USetGroup0        = 20;
iAct_USetGroup1        = 21;
iAct_USetGroup2        = 22;
iAct_USetGroup3        = 23;
iAct_USetGroup4        = 24;
iAct_USetGroup5        = 25;
iAct_USetGroup6        = 26;
iAct_USetGroup7        = 27;
iAct_USetGroup8        = 28;
iAct_USetGroup9        = 29;

iAct_UAddGroup1        = 31;
iAct_UAddGroup2        = 32;
iAct_UAddGroup3        = 33;
iAct_UAddGroup4        = 34;
iAct_UAddGroup5        = 35;
iAct_UAddGroup6        = 36;
iAct_UAddGroup7        = 37;
iAct_UAddGroup8        = 38;
iAct_UAddGroup9        = 39;

iAct_UASlGroup1        = 41;
iAct_UASlGroup2        = 42;
iAct_UASlGroup3        = 43;
iAct_UASlGroup4        = 44;
iAct_UASlGroup5        = 45;
iAct_UASlGroup6        = 46;
iAct_UASlGroup7        = 47;
iAct_UASlGroup8        = 48;
iAct_UASlGroup9        = 49;

iAct_USelGroup1        = 51;
iAct_USelGroup2        = 52;
iAct_USelGroup3        = 53;
iAct_USelGroup4        = 54;
iAct_USelGroup5        = 55;
iAct_USelGroup6        = 56;
iAct_USelGroup7        = 57;
iAct_USelGroup8        = 58;
iAct_USelGroup9        = 59;

iAct_Control_UAbility1 = 60;
iAct_Control_UAbility2 = 61;
iAct_Control_UAbility3 = 62;
iAct_Control_UAMove    = 64;
iAct_Control_UAStop    = 65;
iAct_Control_UAPatrol  = 66;
iAct_Control_UMove     = 67;
iAct_Control_UStop     = 68;
iAct_Control_UPatrol   = 69;
iAct_Control_UProdCncl = 70;
iAct_Control_UDestroy  = 71;
iAct_Control_USelBase  = 72;
iAct_Control_USelArmy  = 73;
iAct_Control_MarkLook  = 74;
iAct_Control_MarkAttack= 75;
iAct_Control_ToggleRec = 76;
iAct_Control_ShowScores= 77;

iAct_Replay_Fast       = 110;
iAct_Replay_Back2      = 111;
iAct_Replay_Back10     = 112;
iAct_Replay_Back60     = 113;
iAct_Replay_Forward2   = 114;
iAct_Replay_Forward10  = 115;
iAct_Replay_Forward60  = 116;
iAct_Replay_Pause      = 117;
iAct_Replay_POV        = 118;
iAct_Replay_Log        = 119;
iAct_Replay_Fog        = 120;
iAct_Replay_PlayerAll  = 121;
iAct_Replay_Player0    = 122;
iAct_Replay_Player1    = 123;
iAct_Replay_Player2    = 124;
iAct_Replay_Player3    = 125;
iAct_Replay_Player4    = 126;
iAct_Replay_Player5    = 127;
iAct_Replay_Player6    = 128;
iAct_Replay_Player7    = 129;

iAct_Observer_Fog      = 130;
iAct_Observer_POV      = 131;
iAct_Observer_PlayerAll= 132;
iAct_Observer_Player0  = 133;
iAct_Observer_Player1  = 134;
iAct_Observer_Player2  = 135;
iAct_Observer_Player3  = 136;
iAct_Observer_Player4  = 137;
iAct_Observer_Player5  = 138;
iAct_Observer_Player6  = 139;
iAct_Observer_Player7  = 140;

iAct_SProd1            = 141;
iAct_SProd2            = 142;
iAct_SProd3            = 143;
iAct_SProd4            = 144;
iAct_SProd5            = 145;
iAct_SProd6            = 146;
iAct_SProd7            = 147;
iAct_SProd8            = 148;
iAct_SProd9            = 149;
iAct_SProd10           = 150;
iAct_SProd11           = 151;
iAct_SProd12           = 152;
iAct_SProd13           = 153;
iAct_SProd14           = 154;
iAct_SProd15           = 155;
iAct_SProd16           = 156;
iAct_SProd17           = 157;
iAct_SProd18           = 158;
iAct_SProd19           = 159;
iAct_SProd20           = 160;
iAct_SProd21           = 161;
iAct_SProd22           = 162;
iAct_SProd23           = 163;
iAct_SProd24           = 164;

iAct_ToggleWindowed    = 170;
iAct_TogglePlayersColor= 171;

iAct_InGameChat        = 200;
iAct_InGameChatAll     = 201;
iAct_InGameChatAllies  = 202;
iAct_InGamePause       = 203;
iAct_InGameMenu        = 204;

{$IFDEF TESTMODE}
iAct_test_FastTime     = 210;
iAct_test_InstaProd    = 211;
iAct_test_ToggleAI     = 212;
iAct_test_iddqd        = 213;
iAct_test_FogToggle    = 214;
iAct_test_DrawToggle   = 215;
iAct_test_NullUpgrades = 216;
iAct_test_BePlayer0    = 217;
iAct_test_BePlayer1    = 218;
iAct_test_BePlayer2    = 219;
iAct_test_BePlayer3    = 220;
iAct_test_BePlayer4    = 221;
iAct_test_BePlayer5    = 222;
iAct_test_BePlayer6    = 223;
iAct_test_BePlayer7    = 224;
iAct_test_AddHellPower = 225;
iAct_test_AddUACLoot   = 226;
iAct_test_debug0       = 227;
iAct_test_debug1       = 228;
{$ENDIF}

apm_Acts               = [1..255]-[iAct_ScreenShot,
                                   iAct_mwu,iAct_mwd,
                                   iAct_mmb,iAct_esc,
                                   iAct_left,
                                   iAct_right,
                                   iAct_up,
                                   iAct_down,
                                   iAct_return,
                                   iAct_control,
                                   iAct_alt,
                                   iAct_shift,
                                   iAct_backspace,
                                   iAct_ToggleWindowed,
                                   iAct_InGameChat,
                                   iAct_InGameChatAll,
                                   iAct_InGameChatAllies,
                                   iAct_InGamePause,
                                   iAct_InGameMenu,
                                   iAct_Control_ToggleRec,
                                   iAct_Control_ShowScores
                                   ];

apm_period_sec         = 10;
apm_period_min         = 60/apm_period_sec;
apm_period_ticks       = fr_fps1*apm_period_sec;

k_LastCharStuckDelay   = fr_fps1 div 3;
kt_TwiceDelay          = fr_fps1 div 4;

CharSetCommon          = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','[',']','{','}',' ','_',',','.','(',')','<','>','-','+','`','@','#','%','?',':','$'];
CharSetDigits          = ['0'..'9'];
CharSetAll             = CharSetCommon+CharSetDigits;

////////////////////////////////////////////////////////////////////////////////
//
//  OTHER UI
//

buff_Bool2InfTime      : array[false..true] of smallint = (0,ub_infinity);

char_gen               : char = '+';
char_kp                : char = #0;
char_koth              : char = ' ';

dead_time              = -hits_dead;
char_detect            = #7;

spr_upgrade_icons      = 22;

MaxUnitGroups          = 9;

pingGradeStep          = 35;

rpls_UIcamXYt1b        = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  NET CLIENT
//

net_ServerListTTL      = net_SendTimePing*2;

////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE DEPTH
//

// terrain
sd_liquidBack          = -32002;
sd_liquidFront         = -32000;
sd_decals              = map_MaxSize+sd_liquidFront; // -24000
sd_Obstacles2          = map_MaxSize+sd_decals;      // -16000
sd_Obstacles1          = map_MaxSize+sd_Obstacles2;  // -8000
sd_build               = map_MaxSize+sd_Obstacles1;  //  0
sd_ground              = map_MaxSize+sd_build;       //  8000
sd_fly                 = map_MaxSize+sd_ground;      //  16000
sd_marker              = map_MaxSize+sd_fly;         //  24000

map_flydepths          : array[false..true] of smallint = (sd_ground,sd_fly);


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE MODEL KINDS
//

smt_effect             = 0;  // simple missile or effect
smt_missile            = 1;  // missile with direction
smt_buiding            = 2;
smt_turret             = 3;
smt_turret2            = 4;
smt_lost               = 5;  //UID_Lost
smt_imp                = 6;  //UID_Imp,UID_Demon,UID_ZFormer,UID_ZSergant,UID_ZBomber,UID_ZBFG,UID_Baron,UID_Cyberdemon:
smt_zengineer          = 7;  //UID_ZEngineer
smt_zcommando          = 8;  //UID_ZCommando
smt_fplasmag           = 9;  //UID_Majot,UID_ZMajor
smt_caco               = 10; //UID_Cacodemon
smt_mmind              = 11; //UID_Mastermind
smt_pain               = 12; //UID_Pain
smt_revenant           = 13; //UID_Revenant
smt_mancubus           = 14; //UID_Mancubus
smt_archno             = 15; //UID_Arachnotron
smt_arch               = 16; //UID_ArachVile
smt_apc                = 17; //UID_APC
smt_fapc               = 18; //UID_FAPC
smt_marine0            = 19; //UID_Engineer,UID_Sergant,UID_Bomber,UID_BFG
smt_medic              = 20; //UID_Medic
smt_commando           = 21; //UID_Commando
smt_tank               = 22; //UID_Tank
smt_terminat           = 23; //UID_Terminator
smt_transport          = 24; //UID_Transport
smt_flyer              = 25; //UID_FLyer
smt_effect2            = 26; // simple missile or effect


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE MODEL STATES
//

sms_walk               = 0;
sms_stand              = 1;
sms_pain               = 2;
sms_cast               = 3;
sms_dready             = 4;
sms_dattack            = 5;
sms_mattack            = 6;
sms_death              = 7;
sms_build              = 8;
sms_transform          = 9;


////////////////////////////////////////////////////////////////////////////////
//
//  EFFECTS
//

EID_BFG                = 200;
EID_BExp               = 201;
EID_BBExp              = 202;
EID_Teleport           = 203;
EID_Exp1               = 204;
EID_Exp2               = 205;
EID_Exp3               = 206;
EID_InfantryGibs       = 207;
EID_HKeep_H            = 208;
EID_HKeep_S            = 209;
EID_HAKeep_H           = 210;
EID_HAKeep_S           = 211;
EID_db_h0              = 212;
EID_db_h1              = 213;
EID_db_u0              = 214;
EID_db_u1              = 215;
EID_Blood              = 216;
EID_ArchFire           = 217;
EID_ULevelUp           = 218;
EID_HLevelUp           = 219;
EID_HVision            = 220;
EID_PowerUp            = 221;
EID_UnitCaptured       = 222;

unit_floating_ticks    = fr_fps2;
unit_floating_h        = 2;
unit_floating_ticks2dir= 360/unit_floating_ticks;

////////////////////////////////////////////////////////////////////////////////
//
//  UNITS INFO
//

uinfo_line             = 1;
uinfo_rect             = 2;
uinfo_box              = 3;
uinfo_circle           = 4;
uinfo_sprite           = 5;
uinfo_text             = 6;

////////////////////////////////////////////////////////////////////////////////
//
//  FONT
//

ta_LU                  = 0;
ta_LM                  = 1;
ta_LB                  = 2;
ta_MU                  = 3;
ta_MM                  = 4;
ta_MB                  = 5;
ta_RU                  = 6;
ta_RM                  = 7;
ta_RB                  = 8;
ta_LA                  = 9;
ta_MA                  = 10;

font_w1                = 8;
font_wh                = font_w1 div 2;
font_wq                = font_w1 div 4;
font_w2                = font_w1*2;
//font_w3                = font_w1*3;
font_w5                = font_w1*5;
//font_w6                = font_w1*6;
font_wi                = font_w1-1;
font_w1h               = font_w1+(font_w1 div 2);

txt_line_h1            = font_w1+font_wq;
txt_line_h2            = font_w1+font_wh+1;
txt_line_h3            = font_w1+font_w2+1;

////////////////////////////////////////////////////////////////////////////////
//
//  VIDEO & UI
//

vid_sdlvflags          = SDL_HWSURFACE+SDL_RESIZABLE;   //SDL_SWSURFACE
vid_bpp                = 32;
vid_minw               = 800;
vid_minh               = 600;

vid_MaxScreenSprites   = 2000; // max vis sprites;

cpp_left               = 0;
cpp_right              = 1;
cpp_top                = 2;
cpp_bottom             = 3;

tab_Buildings          = 0;
tab_Units              = 1;
tab_Upgrades           = 2;
tab_Controls           = 3;

ui_update_persecond    = 6;
ui_update_period1      = fr_fps1 div ui_update_persecond;
ui_blink_persecond     = 6;
ui_blink_period1       = fr_fps1  div ui_blink_persecond;
ui_blink_periodh       = ui_blink_period1 div 2;
ui_blink_period2       = ui_blink_period1*2;
ui_alarm_time          = ui_blink_period2;

ui_MaxPlayersColor     = 5;
ui_MaxHealthBars       = 2;
ui_MaxControlPanelPos  = 3;
ui_MaxCamSpeed         = 127;

ui_ButtonW1            = 48;
ui_ButtonW2            = ui_ButtonW1*2;
ui_ButtonWh            = ui_ButtonW1 div 2;
ui_ButtonWq            = ui_ButtonWh div 2;
ui_CtrlPanelBW         = 3;
ui_CtrlPanelBlock      = ui_CtrlPanelBW*ui_CtrlPanelBW;
ui_CtrlPanelBH         = ui_CtrlPanelBW+10;
ui_CtrlPanelBL         = ui_CtrlPanelBH-1;
ui_CtrlPanelW          = ui_ButtonW1*ui_CtrlPanelBW;
ui_CtrlPanelWh         = ui_CtrlPanelW div 2;
ui_CtrlPanelWb         = ui_CtrlPanelW+1;
ui_CtrlPanelH          = ui_ButtonW1*ui_CtrlPanelBH;
ui_TabButtonW          = ui_CtrlPanelW div 4;

ui_GroupIcoW1          = 18;
ui_GroupIcoW1h         = ui_GroupIcoW1+(ui_GroupIcoW1 div 2);
ui_GroupIcoWq3         = ui_GroupIcoW1-(ui_GroupIcoW1 div 4);
ui_GroupIcoW2q3        = 2*ui_GroupIcoW1+ui_GroupIcoWq3;

ui_max_alarms          = 32;

ui_ButtonsNum          = (ui_CtrlPanelBH-ui_CtrlPanelBW-2)*ui_CtrlPanelBW-1;

chat_type              : array[false..true] of char = ('|',' ');

ui_log_TimeLast        = fr_fps1*3;
ui_log_TimeMax         = ui_log_TimeLast*8;

ui_Objectives_LineLen  = 27;

ui_HintLineLenUnit     = 50;


// abilities

uambt_self             = -257;
uambt_sightR           = -258;
uambt_Blizzard         = -259;

////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

sss_count              = 6;

sss_ui                 = 0;
sss_world              = 1;
sss_mmap               = 2;
sss_anoncer            = 3;
sss_ucommand           = 4;
sss_music              = 5;

// sound sources set size
sss_sssize             : array[0..sss_count-1] of smallint = (1,12,1,3,1,1);

////////////////////////////////////////////////////////////////////////////////
//
//  SAVE/LOAD/REPLAY
//
rpls_none              = 0;
rpls_write             = 1;
rpls_read              = 2;

MaxReplayPrefixLen     = 20;

////////////////////////////////////////////////////////////////////////////////
//
//  MAP
//

map_Decals_Max          = 117;
map_Decals_w            = 2000;
map_Decals_h            = 2000;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

fog_MaxR               = 64;
fog_cw                 = 48;
fog_chw                = fog_cw div 2;
fog_cr                 = round(fog_chw*1.45);
fog_ds                 = fog_cw-fog_cr;

fog_TileSetSize        = 15;

////////////////////////////////////////////////////////////////////////////////
//
//  MENU
//

mi_Back                = 1;
mi_Break               = 2;
mi_Exit                = 3;

mi_StartNow            = 10;
mi_StartTimer          = 11;
mi_StopTimer           = 12;
mi_Surrender           = 13;
mi_Campaings           = 14;
mi_Scirmish            = 15;
mi_SaveLoad            = 16;
mi_Replays             = 17;
mi_Settings            = 18;
mi_Help                = 19;

mi_caption_Campaings   = 20;
mi_caption_Scirmish    = 21;
mi_caption_SaveLoad    = 22;
mi_caption_Replays     = 23;
mi_caption_Settings    = 24;
mi_caption_Help        = 25;
mi_caption_SVSearch    = 26;

////  SETTINGS
mi_settings_Game       = 30;
mi_settings_Record     = 31;
mi_settings_Video      = 32;
mi_settings_Sound      = 33;

mi_SG_PlayerName       = 40;
mi_SG_Language         = 41;
mi_SG_ColoredShadows   = 42;
mi_SG_PlayersColor     = 43;
mi_SG_ShowAPM          = 44;
mi_SG_HealthBars       = 45;
mi_SG_RightClickAction = 46;
mi_SG_ScrollSpeed      = 47;
mi_SG_MouseScroll      = 48;
mi_SG_ControlPanelPos  = 49;
mi_SG_ControlPanelAuto = 50;
mi_SG_ShowPlayerScrns  = 51;

mi_SR_RecordGames      = 55;
mi_SR_RecordPrefix     = 56;
mi_SR_RecordQuality    = 57;

mi_SV_ResolutionW      = 60;
mi_SV_ResolutionH      = 61;
mi_SV_ResolutionApply  = 62;
mi_SV_Windowed         = 63;
mi_SV_ShowFPS          = 64;
mi_SV_MenuScaling      = 65;

mi_SS_SoundVolume      = 70;
mi_SS_MusicVolume      = 71;
mi_SS_PlayerNext       = 72;
mi_SS_PlaylistSize     = 73;
mi_SS_ReloadPlaylist   = 74;
mi_SS_RenewPlaylist    = 75;
mi_SS_Playlist         = 76;

////  REPLAYS
mi_Replays_list        = 80;
mi_Replays_info        = 81;
mi_Replays_play        = 82;
mi_Replays_delete      = 83;

////  SAVE LOAD
mi_SaveLoad_list       = 90;
mi_SaveLoad_info       = 91;
mi_SaveLoad_fname      = 92;
mi_SaveLoad_save       = 93;
mi_SaveLoad_load       = 94;
mi_SaveLoad_delete     = 95;

//// SCIRMISH PLAYERS BLOCK
mi_Players_Panel       = 100;
mi_Players_CName       = 101;
mi_Players_CState      = 102;
mi_Players_CRace       = 103;
mi_Players_CTeam       = 104;
mi_Players_CColor      = 105;
mi_Players_CPing       = 106;
mi_Players_CObs        = 107;
mi_Players_Ready       = 108;

mi_Players_AIskil0     = 110;
{mi_Players_AIskil1     = 111;
mi_Players_AIskil2     = 112;
mi_Players_AIskil3     = 113;
mi_Players_AIskil4     = 114;
mi_Players_AIskil5     = 115;
mi_Players_AIskil6     = 116; }
mi_Players_AIskil7     = 117;

mi_Players_Slot0       = 120;
{mi_Players_Slot1       = 121;
mi_Players_Slot2       = 122;
mi_Players_Slot3       = 123;
mi_Players_Slot4       = 124;
mi_Players_Slot5       = 125;
mi_Players_Slot6       = 126;}
mi_Players_Slot7       = 127;

mi_Players_State0      = 130;
{mi_Players_State1      = 131;
mi_Players_State2      = 132;
mi_Players_State3      = 133;
mi_Players_State4      = 134;
mi_Players_State5      = 135;
mi_Players_State6      = 136; }
mi_Players_State7      = 137;

mi_Players_Race0       = 140;
{mi_Players_Race1       = 141;
mi_Players_Race2       = 142;
mi_Players_Race3       = 143;
mi_Players_Race4       = 144;
mi_Players_Race5       = 145;
mi_Players_Race6       = 146;   }
mi_Players_Race7       = 147;

mi_Players_Team0       = 150;
{mi_Players_Team1       = 151;
mi_Players_Team2       = 152;
mi_Players_Team3       = 153;
mi_Players_Team4       = 154;
mi_Players_Team5       = 155;
mi_Players_Team6       = 156;  }
mi_Players_Team7       = 157;

mi_Players_Ping0       = 160;
{mi_Players_Ping1       = 161;
mi_Players_Ping2       = 162;
mi_Players_Ping3       = 163;
mi_Players_Ping4       = 164;
mi_Players_Ping5       = 165;
mi_Players_Ping6       = 166;
mi_Players_Ping7       = 167; }

mi_Players_Obs0        = 170;
{mi_Players_Obs1        = 171;
mi_Players_Obs2        = 172;
mi_Players_Obs3        = 173;
mi_Players_Obs4        = 174;
mi_Players_Obs5        = 175;
mi_Players_Obs6        = 176;}
mi_Players_Obs7        = 177;

//// SCIRMISH MAP BLOCK
mi_Map_Panel           = 180;
mi_Map_Map             = 181;
mi_Map_Scenario        = 182;
mi_Map_Generators      = 183;
mi_Map_Seed            = 184;
mi_Map_Size            = 185;
mi_Map_Template        = 186;
mi_Map_Symmetry        = 187;
mi_Map_Theme           = 188;
mi_Map_Random          = 189;

//// SCIRMISH GAME BLOCK
mi_Game_Panel          = 190;
mi_Game_FixedPositions = 191;
mi_Game_AISlots        = 192;
mi_Game_NewObservers   = 193;
mi_Game_Random         = 194;

//// SCIRMISH MULTIPLAYER BLOCK
mi_MP_Panel            = 200;
mi_MP_ServerToggle     = 201;
mi_MP_ServerPort       = 202;
mi_MP_ServerLANVis     = 203;
mi_MP_Connect          = 204;
mi_MP_Disconnect       = 205;
mi_MP_ClientAddress    = 206;
mi_MP_ClientQuality    = 207;
mi_MP_ClientServerList = 208;
mi_MP_ChatList         = 209;
mi_MP_ChatLine         = 210;

mi_NetServers_List     = 211;
mi_NetServers_Connect  = 212;
mi_NetServers_Add      = 213;
mi_NetServers_Delete   = 214;


//// SCIRMISH INFO
mi_SubCaptionInfoLine  = 220;
mi_UnderBottomInfoLine = 221;

////  HELP
mi_help_Credits        = 230;
mi_help_GameControls   = 231;
mi_help_GameHotKeys    = 232;
mi_help_GameUI         = 233;
mi_help_GameMechanics  = 234;
mi_help_UnitsInfo      = 235;
mi_help_UnitsBalance   = 236;
mi_help_UpgradesInfo   = 237;
mi_help_Other          = 238;

mi_help_InfoPanel      = 240;
mi_help_InfoList       = 241;
mi_help_ImgUI          = 242;
mi_help_ImgUUpgrade    = 243;
mi_help_ImgGenerators  = 244;
mi_help_ImgKeyPoints   = 245;
mi_help_ImgKotH        = 246;

//// CAMPAIGNs

mi_camp_Difficulty     = 250;
mi_camp_Campaigns      = 251;
mi_camp_Missions       = 252;
mi_camp_MissionInfo    = 253;
mi_camp_MissionObj     = 254;
mi_camp_MissionLoc     = 255;

////////////////////////////////////////////////////////////////////////////////

// menu item activation type
miat_TextEdit          = 0;
miat_BtnLeft           = 1;
miat_MWhell            = 2;
miat_BtnRight          = 3;
miat_BtnDLeft          = 4;

menu_w                 = 800;
menu_hw                = menu_w div 2;
menu_h                 = 600;
menu_hh                = menu_h div 2;
menu_logoh             = 64;

menu_BaseW1            = 28;
menu_BaseWh            = menu_BaseW1 div 2;
menu_BaseW1h           = 28+menu_BaseWh;
menu_BaseW2            = menu_BaseW1*2;
menu_BasehW            = menu_BaseW1 div 2;
menu_SmallW            =(menu_BaseW1 div 4)*3;
menu_ListLineH         =(menu_BaseW1 div 3)*2;
menu_PListLineH        = menu_ListLineH-2;
menu_ListLinehH        = menu_ListLineH div 2;

menu_CaptionhW         = menu_BaseW1*3;
menu_BigButtonW1       = menu_BaseW1*3+menu_BaseWh;
menu_BigButtonWImg     = menu_BigButtonW1+(menu_BigButtonW1 div 4)*3;
menu_BigButtonH1       = menu_BaseW1;
menu_BigButtonHh       = menu_BigButtonH1 div 2;
menu_StepFromBottom    = menu_BaseW1+menu_BasehW;
menu_ItemCaptionhW     = menu_BaseW1*3;
menu_LowerBorderY      = menu_h-menu_StepFromBottom-menu_BigButtonH1;

menu_underLogoY        = menu_logoh+menu_BaseW1;
menu_CaptionH          = menu_BaseW1;
menu_underCaptionY     = menu_underLogoY+menu_CaptionH+menu_BaseW1;

menu_border1           = 125;
menu_BarStepX          = font_w1h;

menu_AddressLen        = 30;

menu_BaseList1H        = 18;
menu_ServerListH       = 9;
menu_ServerLineH       = menu_ListLineH*2;
menu_ServerListAddrW1  = font_w2+font_w1*menu_AddressLen;
menu_ServerListAddrWh  = menu_ServerListAddrW1 div 2;
menu_ListLineWChars1   = 60;
menu_ListLineWCharsh   = menu_ListLineWChars1 div 2;
menu_ListW1            = menu_ListLineWChars1*font_w1+font_w1;
menu_ListWh            = menu_ListW1 div 2;

menu_PlayListLine1H    = menu_ListLineH;
menu_PlayListH         = 10;

menu_CampListW         = (menu_ListWh div 4)*3;
menu_CampLineH         = 16;
menu_CampListSize      = 5;
menu_CampListH         = menu_CampLineH*menu_CampListSize;
menu_MissLineH         = 16;
menu_MissListSize      = 10;
menu_MissListH         = menu_BaseList1H*menu_MissListSize;
menu_InfoLineH         = 12;
menu_infoListSize      = 20;
menu_infoListH         = menu_infoListSize*menu_InfoLineH+font_wh;
menu_infoLineSize      = 64;
menu_InfoLineW         = font_w2+menu_infoLineSize*font_w1;
menu_ObjLineW          = ((menu_InfoLineW-menu_BaseW1) div 5)*3;
menu_objListH          = 6*menu_InfoLineH;
menu_LocLineW          = menu_InfoLineW-menu_ObjLineW-menu_BaseW1;

menu_PlayersStateW     = font_w1h+menu_ListLineH;
menu_PlayersNameW      = font_w2+MaxPlayerNameLen*font_w1;
menu_PlayersRaceW      = font_w1h+6*font_w1+font_wh;
menu_PlayersTeamW      = font_w1h+3*font_w1;
menu_PlayersPingW      = font_w1h+4*font_w1+font_wh;
menu_PlayersObsW       = font_w1h+3*font_w1+font_wh;
menu_PlayersW          = menu_PlayersStateW+menu_PlayersNameW+menu_PlayersRaceW+menu_PlayersTeamW+menu_PlayersPingW+menu_PlayersObsW;

menu_msg_x0            = menu_hw-menu_ListWh;
menu_msg_y0            = menu_hh-menu_BaseW2;
menu_msg_x1            = menu_hw+menu_ListWh;
menu_msg_y1            = menu_hh+menu_BaseW2;
menu_msg_textx         = menu_hw;
menu_msg_captiony      = menu_hh-menu_BaseW1h;
menu_msg_bodyy         = menu_hh;
menu_msg_btny          = menu_hh+menu_BaseW1h;
menu_msg_btn1x0        = menu_msg_x0;
menu_msg_btn1y0        = menu_hh+menu_BaseW1;
menu_msg_btn1x1        =(menu_msg_x0+menu_msg_x1)div 2;
menu_msg_btn1y1        = menu_msg_y1;
menu_msg_btn1tx        =(menu_msg_btn1x0+menu_msg_btn1x1)div 2;
menu_msg_btn2x0        = menu_msg_btn1x1;
menu_msg_btn2x1        = menu_msg_x1;
menu_msg_btn2tx        =(menu_msg_btn2x0+menu_msg_btn2x1)div 2;

menu_HelpIDBTNw        = ui_ButtonW1;
menu_HelpIDBlockBTNW   = 3;
menu_HelpIDBlockBTNH   = 7;
menu_HelpIDBlockW      = menu_HelpIDBlockBTNW*menu_HelpIDBTNw;
menu_HelpIDBlockH      = menu_HelpIDBlockBTNH*menu_HelpIDBTNw;
ui_DocLineLen1         = 56;//(menu_w-(menu_BaseW1*3+menu_BigButtonW)) div font_w1; //56;
ui_DocLineLen2         = 76;
ui_DocListH            = 35;

////////////////////////////////////////////////////////////////////////////////
//
//  CAMPAING
//

camp_MaxDiff           = 4;

camp_BattleRoyaleS     = fr_fpsh-4;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRING/TEXT
//

str_loading_gfx        : shortstring = 'LOADING GRAPHICS...'+#0;
str_loading_sfx        : shortstring = 'LOADING SOUNDS...'+#0;
str_loading_msc        : shortstring = 'LOADING MUSIC...'+#0;
str_loading_netdns     : shortstring = 'RESOLVING DNS...'+#0;

str_ConfigFName        : shortstring = 'marswars.cfg';
str_ScreenShotPrefix   : shortstring = 'MWSCR_';

fileExt_save           : shortstring = '.mws';
fileExt_Replay         : shortstring = '.mwr';
fileExt_Scrshot        : shortstring = '.png';

folder_Race            : array[1..r_count] of shortstring = ('hell\'          ,'uac\'          );
folder_RaceUI          : array[1..r_count] of shortstring = ('hell\ui\'       ,'uac\ui\'       );
folder_RaceUnits       : array[1..r_count] of shortstring = ('hell\units\'    ,'uac\units\'    );
folder_RaceBuildings   : array[1..r_count] of shortstring = ('hell\buildings\','uac\buildings\');
folder_RaceUpgrades    : array[1..r_count] of shortstring = ('hell\upgrades\' ,'uac\upgrades\' );
folder_RaceMissiles    : array[1..r_count] of shortstring = ('hell\missiles\' ,'uac\missiles\' );
folder_graphic         : shortstring = 'graphic\';
folder_screenshots     : shortstring = 'screenshots\';
folder_map             : shortstring = 'map\';
folder_sound           : shortstring = 'sound\';
folder_music_menu      : shortstring = 'music\menu\';
folder_music_game      : shortstring = 'music\game\';
folder_save            : shortstring = 'save\';
folder_replay          : shortstring = 'replay\';
folder_effects         : shortstring = 'effs\';
folder_ui              : shortstring = 'ui\';

ui_limitstr            : shortstring = '125';

tc_player0             = #0;
{tc_player1             = #1;
tc_player2             = #2;
tc_player3             = #3;
tc_player4             = #4;
tc_player5             = #5;
tc_player6             = #6;}
tc_player7             = #7;
tc_nl1                 = #8;
tc_nl2                 = #9;
tc_nl3                 = #10;
tc_docbr               = #11;
tc_doccpt              = #12;
tc_doccnt              = #13;
tc_purple              = #14;
tc_red                 = #15;
tc_orange              = #16;
tc_yellow              = #17;
tc_lime                = #18;
tc_aqua                = #19;
tc_blue                = #20;
tc_gray                = #21;
tc_white               = #22;
tc_green               = #23;
tc_dgray               = #24;
tc_default             = #25;

tc_RankUAC             = #176;
tc_RankHell            = #177;

tc_SpecChars           = [tc_player0..tc_default];

str_UnitLevel          : array[0..LastUnitlevel,1..r_count] of string[3] = ((''                                 ,''                              ),
                                                                            (tc_RankHell                        ,tc_RankUAC                      ),
                                                                            (tc_RankHell+tc_RankHell            ,tc_RankUAC+tc_RankUAC           ),
                                                                            (tc_RankHell+tc_RankHell+tc_RankHell,tc_RankUAC+tc_RankUAC+tc_RankUAC));

sep_comma              = ',';
sep_scomma             = ', ';
sep_sdot               = '. ';
sep_wdash              = '-';
sep_space              = ' ';
sep_slash              = '/';

MaxChatStringLength    = 220;

////////////////////////////////////////////////////////////////////////////////
//
//  MAP THEME
//

crater_ri              = 4;
crater_r               : array[1..crater_ri] of smallint = (33,60,88,110);

LiquidAnimCount        = 4;

{$IFDEF TESTMODE}
////////////////////////////////////////////////////////////////////////////////
//
//  TEST MODE
//

testmode_HellPower     = 1000;
testmode_UACLoot       = testmode_HellPower;
{$ENDIF}

{$ELSE }

ded_GameEndTime          = fr_fps1*60+fr_fps1-1;

str_GameLobby            : shortstring = 'Lobby';
str_GameStarted          : shortstring = 'Started';
str_GameWFPlayers        : shortstring = 'Waiting for players';
str_GameEnded            : shortstring = 'Won by a team #';
str_GamePaused           : shortstring = 'Paused by ';
str_UDPPort              : shortstring = ' UPD port: ';
str_GameStatus           : shortstring = 'Game status: ';
str_GameOptions          : shortstring = 'Game options:';
str_MapOptions           : shortstring = 'Map options:';

str_map_GeneratorsL      : array[0..5       ] of shortstring = ('none','5 min','10 min','15 min','20 min','infinity');
str_map_ScenarioL        : array[0..mc_Last ] of shortstring = ('FFA(3)',
                                                                'FFA(4)',
                                                                'FFA(5)',
                                                                'FFA(6)',
                                                                'FFA(7)',
                                                                'FFA(8)',
                                                                '1x1',
                                                                '2x2',
                                                                '3x3',
                                                                '4x4',
                                                                '2x2x2',
                                                                '2x2x2x2',
                                                                'key points',
                                                                'KotH',
                                                                'Royal Battle');
str_map_SymmetryL        : array[0..maps_Last] of shortstring = ('no',
                                                                 'point',
                                                                 'line |',
                                                                 'line -',
                                                                 'line \',
                                                                 'line /');

str_map_TemplateL        : array[0..mapt_Last] of shortstring = ('lake',
                                                                 'island',
                                                                 'temple',
                                                                 'cave',
                                                                 'steppe',
                                                                 'canyon');

str_map_Scenario         : shortstring = 'Scenario';
str_map_Generators       : shortstring = 'Generators';
str_map_Seed             : shortstring = 'Seed';
str_map_Size             : shortstring = 'Size';
str_map_Template         : shortstring = 'Template';
str_map_Symmetry         : shortstring = 'Symmetry';
str_game_AISlots         : shortstring = 'Fill empty slots';
str_game_FixedPositions  : shortstring = 'Fixed player starts';
str_game_NoNewObservers  : shortstring = 'New observers after game start';
str_gmsg_PlayerPaused    : shortstring = 'player paused the game';
str_gmsg_PlayerResumed   : shortstring = 'player has resumed the game';

str_Player               : shortstring = 'Player';
str_State                : shortstring = 'State';
str_team                 : shortstring = 'Team';
str_srace                : shortstring = 'Race';
str_ping                 : shortstring = 'Ping';

str_ps_AI                : shortstring = 'AI';
str_ps_Hum               : shortstring = 'Hum.';

str_race                 : array[0..r_count] of shortstring = ('RANDOM','HELL','UAC');
str_observer             : shortstring = 'OBSERVER';

{$ENDIF}



