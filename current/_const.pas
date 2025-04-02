
// redefine basic types
type

integer     = int16;
pinteger    = ^int16;

////////////////////////////////////////////////////////////////////////////////
//
//  Game CONSTANTS
//


const

g_version              : byte = 234;

degtorad               = pi/180;

NOTSET                 = integer.MaxValue;

////////////////////////////////////////////////////////////////////////////////
//
//  FRAME RATE
//

fr_fps1                = 60;
fr_RateTicks           = 1000/fr_fps1;

fr_fpsd2               = fr_fps1 div 2;
fr_fpsd3               = fr_fps1 div 3;
fr_fpsd4               = fr_fps1 div 4;
fr_fpsd5               = fr_fps1 div 5;
fr_fpsd6               = fr_fps1 div 6;
fr_fpsd8               = fr_fps1 div 8;
fr_fps1d2              = fr_fpsd2*3;    // 1,5
fr_fps2                = fr_fps1*2;
fr_fps3                = fr_fps1*3;
fr_fps4                = fr_fps1*4;
fr_fps5                = fr_fps1*5;
fr_fps6                = fr_fps1*6;
fr_fps2d3              = fr_fpsd3*2;    // 2/3
fr_fps60               = fr_fps1*60;

////////////////////////////////////////////////////////////////////////////////
//
//  Game settings borders
//

gms_g_maxgens          = 5;  // 0-6  max neutrall generators options

////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

// player type
pt_none                = 0;
pt_human               = 1;
pt_ai                  = 2;

//  Player slot state
pss_closed             = 0;
pss_observer           = 1;
pss_opened             = 2;
pss_ready              = 3;  // menu option, not state
pss_nready             = 4;  // menu option, not state
pss_swap               = 5;  // menu option, not state
pss_sobserver          = 6;  // menu option, not state
pss_splayer            = 7;  // menu option, not state
pss_AI_1               = 8;  // very easy
//pss_AI_2             = 9;  // easy
pss_AI_3               = 10; // medium
{pss_AI_4              = 11; // hard
pss_AI_5               = 12; // harder
pss_AI_6               = 13; // very hard
pss_AI_7               = 14; // elite
pss_AI_8               = 15; // Cheater 1 (Vision)
pss_AI_9               = 16; // Cheater 2 (Vision+MultiProd)
pss_AI_10              = 17; // Cheater 3 (Vision+MultiProd+FastUProd)   }
pss_AI_11              = 18; // Cheater 4 (Vision+MultiProd+FastUProd+FastBProd)

gms_g_maxai            = pss_AI_11-pss_AI_1+1; // 0-11 max skirmish AI skills

ps_states_n            = 8+gms_g_maxai;

player_default_ai_level= 7;

gm_scirmish            = 0;  // game mode
gm_4x4                 = 1;
gm_2x2x2x2             = 2;
gm_capture             = 3;
gm_KotH                = 4;
gm_royale              = 5;
gm_assault             = 6;

gm_ModesFixedTeams     : set of byte = [gm_4x4,gm_2x2x2x2,gm_assault];

allgamemodes           : set of byte = [gm_scirmish,gm_4x4,gm_2x2x2x2,gm_capture,gm_KotH,gm_royale,gm_assault];
gms_count              = 6;

g_step_koth_pause      = fr_fps60*4;

{gs_paused0            = 0; 0..MaxPlayers
 gs_paused1            = 1;
 gs_paused2            = 2;
 gs_paused3            = 3;
 gs_paused4            = 4;
 gs_paused5            = 5;
 gs_paused6            = 6;
 gs_paused7            = 7;}
gs_replayend           = 10;
gs_replayerror         = 11;
gs_waitserver          = 12;
gs_replaypause         = 13;
gs_win_team0           = 20; // 0
gs_win_team1           = 21;
gs_win_team2           = 22;
gs_win_team3           = 23;
gs_win_team4           = 24;
gs_win_team5           = 25;
gs_win_team6           = 26;
gs_win_team7           = 27;
gs_running             = 255;

r_cnt                  = 2;  // race num 0-r_cnt
r_random               = 0;
r_hell                 = 1;
r_uac                  = 2;

MaxPlayer              = 8;
LastPlayer             = MaxPlayer-1;
MaxPlayerUnits         = 125;
MinUnitLimit           = 100;
MaxPlayerLimit         = MaxPlayerUnits*MinUnitLimit;
MaxCPoints             = MaxPlayer*2+(MaxPlayer div 2);

MapCellW               = 88;
MapCellhW              = MapCellW div 2;
MapSizeCellnStep       = 4;
MinMapSizeCelln        = 16;
MaxMapSizeCelln        = 96;

MaxMapSize             = (MapCellW*MaxMapSizeCelln)-1;
MinMapSize             = (MapCellW*MinMapSizeCelln)-1;
StepMapSize            =  MapCellW*MapSizeCellnStep;

mgsl_free              = 0;
mgsl_nobuild           = 1;
mgsl_liquid            = 2;
mgsl_rocks             = 3;

////////////////////////////////////////////////////////////////////////////////
//
//  Game presets
//

gp_custom              = 0;
gp_1x1_plane           = 1;
gp_1x1_lake            = 2;
gp_1x1_cave            = 3;

////////////////////////////////////////////////////////////////////////////////
//
//  CPoints
//

g_cgenerators_ltime    : array[0..gms_g_maxgens] of cardinal = (0,fr_fps60*5,fr_fps60*10,fr_fps60*15,fr_fps60*20,0);
g_cgenerators_energy   = 900;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

str_ver                = 'v54';
str_wcaption           : shortstring = 'The Ultimate MarsWars '+str_ver+#0;
str_cprt               : shortstring = '[ T3DStudio (c) 2016-2025 ]';
str_pt_none            : shortstring = '--';
str_b2c                : array[false..true] of char = ('-','+');
str_defaultPlayerName  = 'DoomPlayer';

outlogfn               : shortstring = 'out.txt';

k_kbstr                : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','[',']','{','}','_',',','.','(',')','-','+','`','&','@','#','%','?','$',' '];
k_pname                : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','[',']','{','}','_',',','.','(',')','-','+','`','&','@','#','%','?','$'    ];


////////////////////////////////////////////////////////////////////////////////
//
//  Player log
//

MaxPlayerLog           = 255;

log_to_all             = %11111111;

{
lmt_chat0              = 0;  = player humber
lmt_chat1              = 1;
lmt_chat2              = 2;
lmt_chat3              = 3;
lmt_chat4              = 4;
lmt_chat5              = 5;
lmt_chat6              = 6;
lmt_chat7              = 7;}
lmt_player_chat        = 8;
lmt_game_message       = 10;
lmt_game_end           = 11;
lmt_player_defeated    = 12;
lmt_player_leave       = 13;
lmt_player_surrender   = 14;
lmt_cant_build         = 15;
lmt_unit_ready         = 16;
lmt_unit_promoted      = 17;
lmt_upgrade_complete   = 18;
lmt_req_energy         = 19;
lmt_req_common         = 20;
lmt_req_ruids          = 21;
lmt_map_mark           = 22;
lmt_unit_attacked      = 23;
lmt_cant_order         = 24;
lmt_allies_attacked    = 25;
lmt_unit_limit         = 26;
lmt_unit_needbuilder   = 27;
lmt_production_busy    = 28;
lmt_already_adv        = 29;
lmt_NeedMoreProd       = 30;
lmt_MaximumReached     = 31;

lmts_menu_chat         = [
                          0..LastPlayer,
                          lmt_game_message,
                          lmt_game_end,
                          lmt_player_surrender,
                          lmt_player_defeated,
                          lmt_player_leave,
                          lmt_player_chat
                         ];
lmts_last_messages     = [0..255];

lmt_argt_unit          = 0;
lmt_argt_upgr          = 1;

////////////////////////////////////////////////////////////////////////////////
//
//  NETGAME
//

cl_UpT_arrayN          = 9;
cl_UpT_arrayN_RPLs     = cl_UpT_arrayN div 2;
                                                         // 60  100 200 300 400 500 600 700 800 900
cl_UpT_array           : array[0..cl_UpT_arrayN] of byte = (15 ,25 ,50 ,75 ,100,125,150,175,200,225);

ClientTTL              = fr_fps1*10;
ServerTTL              = fr_fps1;

NetTickN               = 2;
MaxNetBuffer           = 4096;

net_svlsearch_port     = 63666; // local servers advertisement port
net_svlsearch_portS    = swap(net_svlsearch_port);
net_localAdv_ip        : cardinal = $FFFFFFFF; // 255.255.255.255
net_localAdv_time      = fr_fps1*2;

ns_single              = 0;
ns_server              = 1;
ns_client              = 2;

nmid_lobby_info        = 3;
nmid_connect           = 4;
nmid_client_info       = 5;
nmid_log_chat          = 6;
nmid_log_upd           = 7;
nmid_snapshot          = 8;
nmid_pause             = 9;
nmid_server_full       = 10;
nmid_wrong_ver         = 11;
nmid_game_started      = 12;
nmid_notconnected      = 13;
nmid_order             = 15;
nmid_player_leave      = 16;
nmid_map_mark          = 17;
nmid_lobbby_preset     = 18;
nmid_lobbby_mapseed    = 19;
nmid_lobbby_mapsize    = 20;
nmid_lobbby_type       = 21;
nmid_lobbby_symmetry   = 22;
nmid_lobbby_playerslot = 23;
nmid_lobbby_playerteam = 24;
nmid_lobbby_playerrace = 25;
nmid_lobbby_gamemode   = 26;
nmid_lobbby_generators = 27;
nmid_lobbby_FixStarts  = 28;
nmid_lobbby_DeadPObs   = 29;
nmid_lobbby_EmptySlots = 30;
nmid_surrender         = 31;
nmid_start             = 32;
nmid_break             = 33;
nmid_getinfo           = 62;
nmid_localadv          = 67;


////////////////////////////////////////////////////////////////////////////////
//
//  UNIT & UPGRADES REQUIREMENTS BITS
//

ureq_unitlimit         : cardinal = 1;
ureq_ruid              : cardinal = 1 shl 1;
ureq_rupid             : cardinal = 1 shl 2;
ureq_energy            : cardinal = 1 shl 3;
ureq_time              : cardinal = 1 shl 4;
ureq_max               : cardinal = 1 shl 5;
ureq_builders          : cardinal = 1 shl 6;  // need builders
ureq_bld_r             : cardinal = 1 shl 7;  //
ureq_barracks          : cardinal = 1 shl 8;  // need barracks
ureq_smiths            : cardinal = 1 shl 9;  // need smith
ureq_product           : cardinal = 1 shl 10; // already in production
ureq_armylimit         : cardinal = 1 shl 11;
ureq_place             : cardinal = 1 shl 12; // cant build here
ureq_busy              : cardinal = 1 shl 13; // production is busy
ureq_unknown           : cardinal = 1 shl 14; //
ureq_alreadyAdv        : cardinal = 1 shl 15; //
ureq_needbuilders      : cardinal = 1 shl 16; // need more builders
ureq_common            : cardinal = 1 shl 17; // common

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT/PLAYER OTDERS
//

// mouse brush
// 0..255   - unit
// -1..-255 - ability
mb_empty               = integer.MinValue;
mb_mark                = -306;

po_build               = 1;
po_unit_order_set      = 2;
po_prod_unit_start     = 3;
po_prod_unit_stop      = 4;
po_prod_upgr_start     = 5;
po_prod_upgr_stop      = 6;
po_prod_stop           = 7;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ACTIONS/ABILITIES
//

ua_amove               = 1;
ua_move                = 2;
ua_apatrol             = 3;
ua_patrol              = 4;
ua_astay               = 5;
ua_stay                = 6;
ua_destroy             = 7;

ua_unload              = 10;
ua_unloadto            = 11;

ua_Upgrade             = 15;

ua_HKeepPainAura       = 16;
ua_HKeepBlink          = 17;
ua_HR2Totem            = 18;
ua_HR2Tower            = 19;
ua_HShortBlink         = 20;
ua_HTeleport           = 21;
ua_HRecall             = 22;
ua_HellVision          = 23;
ua_HSphereArmor        = 24;
ua_HSphereDamage       = 25;
ua_HSphereHaste        = 26;

ua_HSpawnLost          = 27;
ua_HSpawnLostTo        = 28;

ua_UCCUp               = 30;
ua_UCCLand             = 31;
ua_UTurretG2A          = 32;
ua_UTurretA2G          = 33;
ua_UTurret2Drone       = 34;
ua_UScan               = 35;
ua_UStrike             = 36;
ua_USphereSoul         = 37;
ua_USphereInvis        = 38;
ua_USphereInvuln       = 39;


ua_f2                  = [ua_amove,ua_move,ua_astay];
ua_toAll               = [ua_move,
                          ua_amove,
                          ua_patrol,
                          ua_apatrol,
                          ua_stay,
                          ua_astay,
                          ua_destroy ];

// write unit reload data if ability in
client_rld_abils       = [
                         //ua_Teleport
                         ];
// write unit reload data if uid in
client_rld_uids        = [
                          //UID_ArchVile
                         ];
// write unit cast info if ability in
client_cast_abils      = [
                         //ua_UACScan  ,
                         //ua_UACStrike,
                         //ua_HInvulnerability
                         ];

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: requirements to attacker and some flags
//

wpr_any                : cardinal =  0;
wpr_avis               : cardinal =  1;
wpr_ground             : cardinal =  1 shl 1;
wpr_air                : cardinal =  1 shl 2;
wpr_move               : cardinal =  1 shl 3;
wpr_reload             : cardinal =  1 shl 4;

aw_fsr0                = 15000;

aw_srange              =  0;            // attack range = sight range
aw_fsr                 =  aw_fsr0+7500; // attack range = sight range + (x-aw_fsr)
aw_dmelee              = -8;            // default melee range
aw_hmelee              = -75;           // default heal/reapir melee range

////////////////////////////////////////////////////////////////////////////////
//
//  Target requirements flags
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
wtr_stun               : cardinal = 1 shl 16;
wtr_nostun             : cardinal = 1 shl 17;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: type
//

wpt_missle             = 1;
wpt_resurect           = 2;
wpt_heal               = 3;
wpt_unit               = 4;
wpt_directdmg          = 5;
wpt_directdmgZ            = 6;
wpt_suicide            = 7;

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
//  Weapon: priority type
//

wtp_Default            = 0;
wtp_hits               = 1;
wtp_Rmhits             = 2;
wtp_distance           = 3;
wtp_building           = 4;
wtp_UnitLightBio       = 5;
wtp_UnitBioLight       = 7;
wtp_UnitBioHeavy       = 8;
wtp_UnitMech           = 10;
wtp_UnitBio            = 11;
wtp_Bio                = 12;
wtp_Light              = 13;
wtp_UnitLight          = 14;
wtp_BuildingHeavy      = 15;
wtp_Scout              = 16;
wtp_notme_hits         = 17;
wtp_Fly                = 18;
wtp_nolost_hits        = 19;
wtp_max_hits           = 20;
wtp_limit              = 21;
wtp_limitaround        = 22;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: damage modificator
//

MaxDamageModFactors    = 1;  // 0..1

dm_AntiUnitBioHeavy    = 1 ; // 1.5*[unit bio heavy]
dm_SSGShot             = 2 ; // 1.5*[unit bio heavy] 0.5*[mech]
dm_AntiUnitBioLight    = 3 ; // 1.5*[unit bio light]
dm_AntiUnitBio         = 4 ; // 1.5*[unit bio]       0.5*[buildings]
dm_AntiUnitMech        = 5 ; // 1.5*[unit mech]
dm_AntiUnitLight       = 6 ; // 1.5*[unit light]
dm_AntiFly             = 7 ; // 1.5*[fly]
dm_AntiHeavy           = 8 ; // 1.5*[heavy]
dm_AntiLight           = 9 ; // 1.5*[light]
dm_AntiBuildingLight   = 10; // 1.5*[buildings light]
dm_Cyber               = 11; //   3*[buildings]      0.5*[light]
dm_Siege               = 12; //   3*[buildings]
dm_Blizzard            = 13; //   5*[buildings]      0.5*[light]
dm_Lost                = 14; //                      0.5*[mech ]
dm_BFG                 = 15; // limituse*


////////////////////////////////////////////////////////////////////////////////
//
//  AI FLAGS
//

ai_limit_border        = MaxPlayerLimit-(7*MinUnitLimit);

aif_base_smart_order   : cardinal = 1 shl 1;
aif_base_suicide       : cardinal = 1 shl 2;
aif_base_advance       : cardinal = 1 shl 3;
aif_army_smart_order   : cardinal = 1 shl 4;
aif_army_scout         : cardinal = 1 shl 5;
aif_army_advance       : cardinal = 1 shl 6;
aif_army_smart_micro   : cardinal = 1 shl 7;
aif_army_teleport      : cardinal = 1 shl 8;
aif_upgr_smart_opening : cardinal = 1 shl 9;
aif_ability_detection  : cardinal = 1 shl 10;
aif_ability_other      : cardinal = 1 shl 11;
aif_ability_mainsave   : cardinal = 1 shl 12;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT BUFFs
//

ub_Pain                = 0;
ub_Resurect            = 1;
ub_Cast                = 2;
ub_CCast               = 3;
ub_Invis               = 4;
ub_Detect              = 5;
ub_Invuln              = 6;
ub_Summoned            = 7;
ub_Teleport            = 8;
ub_HVision             = 9;
ub_Damaged             = 10;
ub_Heal                = 11;
ub_Scaned              = 12;
ub_Decay               = 13;
ub_ArchFire            = 14;
ub_PauseUnload         = 15;
ub_PauseResurect       = 16;

MaxUnitBuffs           = 16;

_ub_infinity           = NOTSET;
b2ib                   : array[false..true] of integer = (0,_ub_infinity);



////////////////////////////////////////////////////////////////////////////////
//
//  MAP OTHER
//

// map template types
mapt_steppe            = 0;
mapt_canyon            = 1;
mapt_clake             = 2;
mapt_ilake             = 3;
mapt_island            = 4;
mapt_shore             = 5;
mapt_sea               = 6;

// map symmetry types
maps_none              = 0;
maps_point             = 1;
maps_lineV             = 2;
maps_lineH             = 3;
maps_lineL             = 4;
maps_lineR             = 5;

gms_m_types            = 6;  // 0-gms_m_types  max map types
gms_m_symm             = 5;  // 0-gms_m_symm  max map symmetry types

////////////////////////////////////////////////////////////////////////////////
//
//  UPGRADES
//

upgr_hell_t1attack     = 1;  // t1 distance attacks damage    // t1
upgr_hell_uarmor       = 2;  // base unit armor
upgr_hell_barmor       = 3;  // base building armor
upgr_hell_mattack      = 4;  // melee attack damage
upgr_hell_regen        = 5;  // regeneration
upgr_hell_pains        = 6;  // pain state
upgr_hell_buildr       = 7;  // main range
upgr_hell_HKTeleport   = 8;  // HK teleportation
upgr_hell_paina        = 10; // decay aura
upgr_hell_towers       = 11; // towers range

upgr_hell_spectre      = 13; // demon spectre                 // t2
upgr_hell_vision       = 14; // demons vision
upgr_hell_phantoms     = 15; // demons vision
upgr_hell_t2attack     = 16; // t2 distance attacks damage
upgr_hell_teleport     = 17; // Teleport reload
upgr_hell_rteleport    = 18; // revers teleport
upgr_hell_heye         = 19; // hell Eye time
upgr_hell_totminv      = 20; // totem and eye invisible
upgr_hell_bldrep       = 21; // build restoration
upgr_hell_tblink       = 22; // teleport towers
upgr_hell_resurrect    = 23; // archvile ability
upgr_hell_invuln       = 24; // hell invuln powerup


upgr_uac_attack        = 31; // distance attack               // t1
upgr_uac_uarmor        = 32; // base armor
upgr_uac_barmor        = 33; // base b armor
upgr_uac_melee         = 34; // repair/health upgr
upgr_uac_mspeed        = 35; // infantry speed
upgr_uac_ssgup         = 36; // expansive bullets
upgr_uac_buildr        = 37; // main sr
upgr_uac_CCFly         = 38; // CC fly
upgr_uac_ccturr        = 40; // CC turret
upgr_uac_towers        = 41; // towers sr

upgr_uac_botturret     = 43; // bot turret                    // t2
upgr_uac_vision        = 44; // infatry vision
upgr_uac_commando      = 45; // commando invis
upgr_uac_airsp         = 46; // anti-air missiles splash
upgr_uac_mechspd       = 47; // mech speed
upgr_uac_mecharm       = 48; // mech arm
upgr_uac_lturret       = 49; // flyer laser turret
upgr_uac_transport     = 50; // transport capacity upgrade
upgr_uac_radar_r       = 51; // Radar
upgr_uac_plasmt        = 52; // plasma weapons fro anti-ground turret
upgr_uac_turarm        = 53; // turrets armor
upgr_uac_rstrike       = 54; // rstrike launch


upgr_fog_vision        = 249;
upgr_fast_build        = 250;
upgr_fast_product      = 251;
upgr_mult_product      = 252;
upgr_invuln            = 255;

// BASIC RACE UPGRADES                                      HELL                UAC
upgr_race_armor_bio         : array[1..r_cnt] of byte    = (upgr_hell_uarmor  , upgr_uac_uarmor  );
upgr_race_armor_mech        : array[1..r_cnt] of byte    = (0                 , upgr_uac_mecharm );
upgr_race_armor_build       : array[1..r_cnt] of byte    = (upgr_hell_barmor  , upgr_uac_barmor  );
upgr_race_regen_bio         : array[1..r_cnt] of byte    = (upgr_hell_regen   , 0                );
upgr_race_regen_mech        : array[1..r_cnt] of byte    = (0                 , 0                );
upgr_race_regen_build       : array[1..r_cnt] of byte    = (upgr_hell_bldrep  , 0                );
upgr_race_mspeed_bio        : array[1..r_cnt] of byte    = (0                 , upgr_uac_mspeed  );
upgr_race_mspeed_mech       : array[1..r_cnt] of byte    = (0                 , upgr_uac_mechspd );
upgr_race_unit_srange       : array[1..r_cnt] of byte    = (upgr_hell_vision  , upgr_uac_vision  );
upgr_race_srange_unit_bonus : array[1..r_cnt] of integer = (25                , 25               );

////////////////////////////////////////////////////////////////////////////////
//
//  MISSILES
//

MID_Imp                = 101;
MID_Cacodemon          = 102;
MID_Baron              = 103;
MID_HRocket            = 104;
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
MID_Mine               = 118;
MID_URocket            = 119;
MID_URocketS           = 120;
MID_Chaingun           = 121;
MID_MChaingun          = 122;


mh_none                = 0;
mh_magnetic            = 1;
mh_homing              = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  UNITS
//

MaxUnits               = MaxPlayer*MaxPlayerUnits;
MaxUnitWeapons         = 3;  //0-3
MaxUnitLevel           = 3;  //0-3
MaxMissiles            = MaxUnits;

// LIMIT
ul1                    = MinUnitLimit;
ul1hh                  = MinUnitLimit+(MinUnitLimit div 4);
ul1h                   = MinUnitLimit+(MinUnitLimit div 2);
ul2                    = MinUnitLimit*2;
ul3                    = MinUnitLimit*3;
ul4                    = MinUnitLimit*4;
ul5                    = MinUnitLimit*5;
ul6                    = MinUnitLimit*6;
ul8                    = MinUnitLimit*8;
ul10                   = MinUnitLimit*10;
ul12                   = MinUnitLimit*12;
ul15                   = MinUnitLimit*15;
ul20                   = MinUnitLimit*20;
ul32                   = MinUnitLimit*32;
ul100                  = MinUnitLimit*100;
ul110                  = MinUnitLimit*110;

// production time
ptime1                 = 20;
ptimeh                 = ptime1  div 2;
ptime2h                = ptimeh  div 2;
ptime4h                = ptime2h div 2;
ptime1h                = ptime1+ptimeh;
ptime1hh               = ptime1+ptime2h;
ptime2                 = ptime1*2;
ptime3                 = ptime1*3;
ptime4                 = ptime1*4;
ptime5                 = ptime1*5;
ptime6                 = ptime1*6;

uf_ground              = false;
uf_fly                 = true;

MaxUnitGroups          = 9;  //0..9

BaseDamage1            = 52;
BaseDamageh            = BaseDamage1 div 2;
BaseDamageh4           = BaseDamage1 div 4;
BaseDamage1h           = BaseDamage1+BaseDamageh;
BaseDamage2            = BaseDamage1*2;
BaseDamage3            = BaseDamage1*3;
BaseDamage4            = BaseDamage1*4;
BaseDamage5            = BaseDamage1*5;
BaseDamage6            = BaseDamage1*6;
BaseDamage8            = BaseDamage1*8;
BaseDamage10           = BaseDamage1*10;

BaseDamageBonus1       = 7;
BaseDamageBonus3       = BaseDamageBonus1*3;
BaseDamageLevel1       = 2;
BaseArmorBonus1        = 7;
BaseArmorBonus2        = BaseArmorBonus1*2;
BaseArmorLevel1        = 2;

BaseHeal1              = (BaseDamage1 div 7)*3;
BaseHealBonus1         = BaseDamageBonus1*2;
BaseRepair1            = (BaseDamage1 div 7)*3;
BaseRepairBonus1       = BaseDamageBonus1*2;

DecayAuraDamage        = 6;

ExpLevel1              = fr_fps1*ptime1;

////////////////////////////////////////////////////////////////////////////////
//
//  UIDs
//

// HELL

UID_HKeep              = 1;
UID_HGate              = 2;
UID_HSymbol            = 3;
UID_HPools             = 4;
UID_HTower             = 5;
UID_HTeleport          = 6;
UID_HEye               = 7;
UID_HMonastery         = 8;
UID_HTotem             = 9;
UID_HAltar             = 10;
UID_HFortress          = 11;
UID_HCommandCenter     = 12;
UID_HBarracks          = 13;
UID_HPentagram         = 14;

UID_LostSoul           = 20;
UID_Phantom            = 21;
UID_Imp                = 22;
UID_Demon              = 23;
UID_Cacodemon          = 24;
UID_Knight             = 25;
UID_Baron              = 26;
UID_Pain               = 27;
UID_Revenant           = 28;
UID_Mancubus           = 29;
UID_Arachnotron        = 30;
UID_Archvile           = 31;
UID_Mastermind         = 32;
UID_Cyberdemon         = 33;

UID_ZMedic             = 34;
UID_ZEngineer          = 35;
UID_ZSergant           = 36;
UID_ZSSergant          = 37;
UID_ZCommando          = 38;
UID_ZAntiaircrafter    = 39;
UID_ZSiegeMarine       = 40;
UID_ZFPlasmagunner     = 41;
UID_ZBFGMarine         = 42;

// UAC

UID_UCommandCenter     = 51;
UID_UBarracks          = 52;
UID_UFactory           = 53;
UID_UGenerator         = 54;
UID_UWeaponFactory     = 55;
UID_URadar             = 56;
UID_URMStation         = 57;
UID_UTechCenter        = 58;
UID_UGTurret           = 59;
UID_UATurret           = 60;
UID_UComputerStation   = 61;

UID_UBaseMil           = 65;
UID_UBaseCom           = 66;
UID_UBaseGen           = 67;
UID_UBaseRef           = 68;
UID_UBaseNuc           = 69;
UID_UBaseLab           = 70;
UID_UCBuild            = 71;
UID_USPort             = 72;
UID_UPortal            = 73;

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


uids_hell              = [1 ..50];
uids_uac               = [51..99];

uids_marines           = [UID_Engineer ,UID_Medic   ,UID_Sergant ,UID_SSergant ,UID_Commando ,UID_Antiaircrafter ,UID_SiegeMarine , UID_FPlasmagunner ,UID_BFGMarine ];
uids_zimbas            = [UID_ZEngineer,UID_ZMedic ,UID_ZSergant,UID_ZSSergant,UID_ZCommando,UID_ZAntiaircrafter,UID_ZSiegeMarine, UID_ZFPlasmagunner,UID_ZBFGMarine];
uids_arch_res          = [UID_Imp,UID_Demon,UID_Cacodemon,UID_Knight,UID_Baron,UID_Revenant,UID_Mancubus,UID_Arachnotron]+uids_zimbas;
uids_demons            = [UID_LostSoul..UID_Archvile]+uids_zimbas;
uids_all               = [0..255];

uid_race_start_base    : array[1..r_cnt] of byte = (UID_HKeep    ,UID_UCommandCenter );

////////////////////////////////////////////////////////////////////////////////
//
//  OTHER
//


// mancubus attack sequense timing
fr_mancubus_rld        = fr_fps2+fr_fpsd2;  //2.5
fr_mancubus_rld_s1     = fr_fps2-fr_fpsd6;
fr_mancubus_rld_s2     = fr_fps1+fr_fpsd6;
fr_mancubus_rld_s3     = fr_fpsd2;

// archvile attack timing
fr_archvile_s          = fr_fps1+fr_fpsd6;

PlayerNameLen          = 13;

dead_hits              = -ptime1*fr_fps1;
fdead_hits             = dead_hits+fr_fps3;
ndead_hits             = dead_hits-1;

fdead_hits_border      = -130;

base_1r                = 350;
base_hr                = base_1r div 2;
base_1rh               = base_1r+(base_1r div 2);
base_2r                = base_1r*2;
base_3r                = base_1r*3;
base_4r                = base_1r*4;
base_5r                = base_1r*5;
base_6r                = base_1r*6;

apc_exp_damage         = BaseDamage4;
regen_period           = fr_fps1*2;
order_period           = fr_fpsd2+1;
MinVisionTime          = fr_fps2;

radar_reload           = fr_fps1*60;
radar_vision_time      = radar_reload-(fr_fps1*8);

hell_vision_time       = fr_fps1*8;

mstrike_reload         = fr_fps1*ptime2;
haltar_reload          = fr_fps1*ptime2;

step_build_reload      = fr_fps1*4;
max_build_reload       = step_build_reload*4;

melee_r                = 8;
mine_r                 = melee_r*3;

dir_stepX              : array[0..7] of integer = (1,1,0,-1,-1,-1,0,1);
dir_stepY              : array[0..7] of integer = (0,-1,-1,-1,0,1,1,1);

invuln_time            = fr_fps1*30;
teleport_SecPerLimit   = 6;

tank_sr                = 20;
rocket_sr              = tank_sr*2;
mine_sr                = rocket_sr*2;
blizzard_sr            = rocket_sr*4;

_mms                   = 126;
_d2shi                 = abs(dead_hits div 125)+1;   // 5

gm_cptp_gtime          = fr_fps1*ptime2h;
gm_cptp_time           = fr_fps1*ptimeh;
gm_cptp_r              = 100;

fly_z                  = 80;
fly_hz                 = fly_z div 2;
fly_height             : array[false..true] of integer = (1,fly_z);

pain_time              = fr_fps1;

unit_MaxSpeed          = MapCellhW-1;


random_table           : array[byte] of byte = (
//   0      1    2    3    4    5    6    7    8    9   10   11   12   13   14    15
     0  ,   8, 109, 220, 222, 241, 149, 107,  75, 248, 254, 140,  16,  66,  74,   21,
     211,  47,  80, 242, 154,  27, 205, 128, 161,  89,  77,  36,  95, 110,  85,   48,
     212, 140, 211, 249,  22,  79, 200,  50,  28, 188,  52, 140, 202, 120,  68,  145,
     62 ,  70, 184, 190,  91, 197, 152, 224, 149, 104,  25, 178, 252, 182, 202,  182,
     141, 197,   4,  81, 181, 242, 145,  42,  39, 227, 156, 198, 225, 193, 219,   93,
     122, 175, 249,   0, 175, 143,  70, 239,  46, 246, 163,  53, 163, 109, 168,  135,
     2  , 235,  25,  92,  20, 145, 138,  77,  69, 166,  78, 176, 173, 212, 166,  113,
     94 , 161,  41,  50, 239,  49, 111, 164,  70,  60,   2,  37, 171,  75, 136,  156,
     11 ,  56,  42, 146, 138, 229,  73, 146,  77,  61,  98, 196, 135, 106,  63,  197,
     195,  86,  96, 203, 113, 101, 170, 247, 181, 113,  80, 250, 108,   7, 255,  237,
     129, 226,  79, 107, 112, 166, 103, 241,  24, 223, 239, 120, 198,  58,  60,   82,
     128,   3, 184,  66, 143, 224, 145, 224,  81, 206, 163,  45,  63,  90, 168,  114,
     59 ,  33, 159,  95,  28, 139, 123,  98, 125, 196,  15,  70, 194, 253,  54,   14,
     109, 226,  71,  17, 161,  93, 186,  87, 244, 138,  20,  52, 123, 251,  26,   36,
     17 ,  46,  52, 231, 232,  76,  31, 221,  84,  37, 216, 165, 212, 106, 197,  242,
     98 ,  43,  39, 175, 254, 145, 190,  84, 118, 222, 187, 136, 120, 163, 236,  249);

{$IFDEF _FULLGAME}


_buffst                : array[false..true] of integer = (0,_ub_infinity);

str_ps_sv              : char = '@';

char_start             : char = '+';
char_gen               : char = '*';
char_cp                : char = '=';

ChatLen2               = 200;
dead_time              = -dead_hits;
char_detect            = #7;
char_advanced          = #10;

spr_upgrade_icons      = 24;

max_CamSpeed           = 127;



////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE DEPTH
//

// neytral generators
sd_liquid              = -32000;
sd_tcraters            = MaxMapSize+sd_liquid;
// doodads
sd_rocks               = MaxMapSize+sd_tcraters;
sd_build               = MaxMapSize+sd_rocks;
sd_ground              = MaxMapSize+sd_build;
sd_fly                 = MaxMapSize+sd_ground;
sd_marker              = MaxMapSize+sd_fly;

map_flydepths          : array[false..true] of integer = (sd_ground,sd_fly);


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
smt_fmajor             = 9;  //UID_Majot,UID_ZMajor
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


////////////////////////////////////////////////////////////////////////////////
//
//  EFFECTS
//

EID_BFG                = 200;
EID_BExp               = 201;
EID_BBExp              = 202;
EID_Teleport           = 203;
EID_Exp                = 204;
EID_Exp2               = 205;
EID_Gavno              = 206;
EID_HKeep_H            = 207;
EID_HKeep_S            = 208;
EID_HAKeep_H           = 209;
EID_HAKeep_S           = 210;
EID_db_h0              = 211;
EID_db_h1              = 212;
EID_db_u0              = 213;
EID_db_u1              = 214;
EID_Blood              = 215;
EID_ArchFire           = 216;
EID_ULevelUp           = 217;
EID_HLevelUp           = 218;
EID_HVision            = 219;
EID_Invuln             = 220;

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
//  TEXT
//

ta_LU                  = 0;   // |^| | |
ta_MU                  = 1;   // | |^| |
ta_RU                  = 2;   // | | |^|
ta_LM                  = 3;   // |-| | |
ta_MM                  = 4;   // | |-| |
ta_RM                  = 5;   // | | |-|
ta_LD                  = 6;   // |_| | |
ta_MD                  = 7;   // | |_| |
ta_RD                  = 8;   // | | |_|
ta_chat                = 9;
ta_MMR                 = 10;  // |  |- |

basefont_w1            = 8;
basefont_w2            = basefont_w1*2;
basefont_w3            = basefont_w1*3;
basefont_w4            = basefont_w1*4;
basefont_wh            = basefont_w1 div 2;
basefont_wq            = basefont_w1 div 4;
basefont_wq3           = basefont_wq*3;
basefont_w5            = basefont_w1*5;
basefont_w1h           = basefont_w1+basefont_wh;

chat_all               = 255;
chat_allies            = 254;

////////////////////////////////////////////////////////////////////////////////
//
//  VIDEO & UI
//

fr_ifps                = fr_fps1-1;

vid_bpp                = 32;
vid_minw               = 800;
vid_minh               = 600;
vid_maxw               = 1440;
vid_maxh               = 1080;

vid_rw_list            : array[0..7] of integer = (vid_minw,960,1024,1280,1360,1366,1400,vid_maxw);
vid_rh_list            : array[0..7] of integer = (vid_minh,680,720 ,768 ,800 ,900 ,1050,vid_maxh);

vid_MaxScreenSprites   = 1000; // max vis sprites;
vid_blink_persecond    = 6;
vid_blink_period1      = fr_fps1  div vid_blink_persecond;
vid_blink_periodh      = vid_blink_period1 div 2;
vid_blink_period2      = vid_blink_period1*2;

vid_panel_period       = fr_fps1 div 6;

ui_alarm_time          = vid_blink_period2;

vid_BW                 = 48;
vid_BW2                = vid_BW*2;
vid_panel_bw           = 3;                   // panel button width
vid_panel_bblock       = vid_panel_bw*vid_panel_bw;
vid_panel_pw           = vid_BW*vid_panel_bw; // panel pixel width
vid_panel_pwi          = vid_panel_pw-1;
vid_panel_pwu          = vid_panel_pw+1;
vid_panel_bh           = 9;
vid_panel_ph           = vid_panel_bh*vid_BW+vid_BW;
vid_panel_phi          = vid_panel_ph-1;
vid_tBW                = vid_panel_pw div 4;
vid_hBW                = vid_BW div 2;
vid_hhBW               = vid_hBW div 2;
vid_oiw                = 18;
vid_oihw               = vid_oiw+(vid_oiw div 2);
vid_oisw               = vid_oiw-(vid_oiw div 4);
vid_oips               = 2*vid_oiw+vid_oisw;

ui_max_alarms          = 12;

ui_bottomsy            = vid_BW*4;
ui_hwp                 = vid_panel_pw div 2;
ui_ubtns               = 23;

////////////////////////////////////////////////////////////////////////////////
//
//  MENU
//

MaxMissions            = 21;
//CMPMaxSkills           = 6;

chat_type              : array[false..true] of char = ('|',' ');
log_LastMesTime        = fr_fps1*3;
log_LastMesMaxN        = log_LastMesTime*6;

menu_logo_h            = 96;

menu_main_mp_bw1       = 300;
menu_main_mp_bwh       = menu_main_mp_bw1 div 2;
menu_main_mp_bwq       = menu_main_mp_bw1 div 4;
menu_main_mp_bw3q      = menu_main_mp_bwq*3;
menu_main_mp_bh1       = 38;
menu_main_mp_bh2       = menu_main_mp_bh1*2;
menu_main_mp_bh3       = menu_main_mp_bh1*3;
menu_main_mp_bhh       = menu_main_mp_bh1 div 2;
menu_main_mp_bhq       = menu_main_mp_bh1 div 4;
menu_main_mp_bhq3      = menu_main_mp_bhq*3;
menu_main_mp_bh1q      = menu_main_mp_bhq*5;
menu_main_mp_bh1h      = menu_main_mp_bh1+menu_main_mp_bhh;
menu_main_mp_bh3q      = menu_main_mp_bhq*3;

menu_players_namew     = basefont_w1+(basefont_w1*PlayerNameLen)+
                                     (basefont_w1*8            )+basefont_w2;
menu_players_racew     = basefont_w1+(basefont_w1*7            )+basefont_w2;
menu_players_teamw     = basefont_w1+(basefont_w1*7            )+basefont_w2;
menu_map_settingsw     = basefont_w1+(basefont_w1*20           )+basefont_w2;

menu_netsearch_lineh   = menu_main_mp_bh1;
menu_netsearch_listh   = 8;

menu_replays_lineh     = menu_main_mp_bhh;
menu_replays_listh     = 16;

menu_saveload_lineh    = menu_main_mp_bhh;
menu_saveload_listh    = 16;

////////////////////////   menu pages

mp_main                   = 0;
mp_campaings              = 1;
mp_scirmish               = 2;
mp_saveload               = 3;
mp_loadreplay             = 4;
mp_aboutgame              = 5;
mp_settings               = 6;

////////////////////////   menu items

////  MAIN
mi_StartGame              = 1;
mi_StartScirmish          = 2;
mi_StartCampaing          = 3;

mi_EndGame                = 5;
mi_EndSurrender           = 6;
mi_EndLeave               = 7;
mi_EndReplayQuit          = 8;

mi_SaveLoad               = 9;

mi_Settings               = 11;
mi_AboutGame              = 12;
mi_back                   = 13;
mi_exit                   = 14;

mi_title_Campaings        = 21;
mi_title_Scirmish         = 22;
mi_title_SaveLoad         = 23;
mi_title_LoadReplay       = 25;
mi_title_Settings         = 26;
mi_title_AboutGame        = 27;
mi_title_players          = 28;
mi_title_map              = 29;
mi_title_GameOptions      = 30;
mi_title_multiplayer      = 31;
mi_title_ReplayInfo1      = 32;
mi_title_ReplayInfo2      = 33;
mi_title_ReplayPlayback   = 34;
mi_title_SaveInfo     = 35;

////  SETTINGS

mi_settings_game          = 41;
mi_settings_replay        = 42;
mi_settings_network       = 43;
mi_settings_video         = 44;
mi_settings_sound         = 45;

////  SETTINGS GAME LINES
mi_settings_ColoredShadows= 51;
mi_settings_ShowAPM       = 52;
mi_settings_HitBars       = 53;
mi_settings_MRBAction     = 54;
mi_settings_ScrollSpeed   = 55;
mi_settings_MouseScroll   = 56;
mi_settings_PlayerName    = 57;
mi_settings_Langugage     = 58;
mi_settings_PanelPosition = 59;
mi_settings_MMapPosition  = 60;
mi_settings_PlayerColors  = 61;

////  REPLAYING OPTIONS
mi_settings_Replaying     = 65;
mi_settings_ReplayName    = 66;
mi_settings_ReplayQuality = 67;

////  NETWORK SETTINGS
mi_settings_Client        = 70;
mi_settings_ClientQuality = 71;

////  SETTINGS VIDEO LINES
mi_settings_ResWidth      = 81;
mi_settings_ResHeight     = 82;
mi_settings_ResApply      = 83;
mi_settings_Fullscreen    = 84;
mi_settings_ShowFPS       = 85;

////  SETTINGS SOUND LINES
mi_settings_SoundVol      = 91;
mi_settings_MusicVol      = 92;
mi_settings_NextTrack     = 93;
mi_settings_PlayListSize  = 94;
mi_settings_MusicReload   = 95;


////  SCIRMISH PLAYERS
mi_player_status0         = 110;
mi_player_status1         = 111;
mi_player_status2         = 112;
mi_player_status3         = 113;
mi_player_status4         = 114;
mi_player_status5         = 115;
mi_player_status6         = 116;
mi_player_status7         = 117;

mi_player_race0           = 120;
mi_player_race1           = 121;
mi_player_race2           = 122;
mi_player_race3           = 123;
mi_player_race4           = 124;
mi_player_race5           = 125;
mi_player_race6           = 126;
mi_player_race7           = 127;

mi_player_team0           = 130;
mi_player_team1           = 131;
mi_player_team2           = 132;
mi_player_team3           = 133;
mi_player_team4           = 134;
mi_player_team5           = 135;
mi_player_team6           = 136;
mi_player_team7           = 137;

mi_player_color0          = 140;
mi_player_color1          = 141;
mi_player_color2          = 142;
mi_player_color3          = 143;
mi_player_color4          = 144;
mi_player_color5          = 145;
mi_player_color6          = 146;
mi_player_color7          = 147;

////  MAP PARAMS
mi_map_Preset             = 151;
mi_map_Seed               = 152;
mi_map_Size               = 153;
mi_map_Type               = 154;
mi_map_Sym                = 155;
mi_map_Random             = 156;
mi_map_Theme              = 157;
mi_map_MiniMap            = 158;

////  GAME OPTIONS
mi_game_mode              = 161;
mi_game_generators        = 162;
mi_game_FixStarts         = 163;
mi_game_DeadPbserver      = 164;
mi_game_EmptySlots        = 165;
mi_game_RandomSkrimish    = 166;

////  MULTIPLAYER
mi_mplay_ServerCaption    = 180;
mi_mplay_ServerPort       = 181;
mi_mplay_ServerStart      = 182;
mi_mplay_ServerStop       = 183;
mi_mplay_ClientCaption    = 184;
mi_mplay_ClientAddress    = 185;
mi_mplay_ClientConnect    = 186;
mi_mplay_ClientDisconnect = 187;
mi_mplay_ClientStatus     = 188;
mi_mplay_ChatCaption      = 189;
mi_mplay_Chat             = 190;
mi_mplay_NetSearchCaption = 191;
mi_mplay_NetSearchStart   = 192;
mi_mplay_NetSearchStop    = 193;
mi_mplay_NetSearchList    = 194;
mi_mplay_NetSearchCon     = 195;

////  REPLAYS
mi_replays_list           = 200;
mi_replays_play           = 201;
mi_replays_delete         = 202;

////  SAVE LOAD
mi_saveload_list          = 210;
mi_saveload_fname         = 211;
mi_saveload_save          = 212;
mi_saveload_load          = 213;
mi_saveload_delete        = 214;

/////////////////////////////


aummat_attacked_u      = 1;
aummat_attacked_b      = 2;
aummat_created_u       = 3;
aummat_created_b       = 4;
aummat_advance         = 5;
aummat_upgrade         = 6;
aummat_info            = 7;

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
sss_sssize             : array[0..sss_count-1] of integer = (1,12,1,3,1,1);

snd_MaxSoundVolume     = 127;
snd_PlayListSizeMax    = 50;

////////////////////////////////////////////////////////////////////////////////
//
//  SAVE/LOAD/REPLAY
//

rpls_state_none        = 0;
rpls_state_write       = 1;
rpls_state_read        = 2;

ReplayNameLen          = 15;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

MFogM                  = 64;
fog_CellW              = 44;
fog_CellHW             = fog_CellW div 2;
fog_vfwm               = (vid_maxw div fog_CellW)+2;
fog_vfhm               = (vid_maxh div fog_CellW)+2;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

cfgfn                  : shortstring = 'cfg';
str_screenshot         : shortstring = 'MVSCR_';
str_loading_srf        : shortstring = 'MAKING SURFACES...';
str_loading_gfx        : shortstring = 'LOADING GRAPHICS...';
str_loading_sfx        : shortstring = 'LOADING SOUNDS...';
str_loading_msc        : shortstring = 'LOADING MUSIC...';
str_loading_ini        : shortstring = 'INIT GAME...';
str_f_grp              : shortstring = 'graphic\';
str_f_map              : shortstring = 'map\';
str_f_snd              : shortstring = 'sound\';
str_e_music            : shortstring = '.ogg';
str_f_svld             : shortstring = 'save\';
str_e_svld             : shortstring = '.mws';
str_f_rpls             : shortstring = 'replay\';
str_e_rpls             : shortstring = '.mwr';

race_dir               : array[1..r_cnt] of shortstring = ('hell\'          ,'uac\'          );
race_units             : array[1..r_cnt] of shortstring = ('hell\units\'    ,'uac\units\'    );
race_buildings         : array[1..r_cnt] of shortstring = ('hell\buildings\','uac\buildings\');
race_upgrades          : array[1..r_cnt] of shortstring = ('hell\upgrades\' ,'uac\upgrades\' );
race_missiles          : array[1..r_cnt] of shortstring = ('hell\missiles\' ,'uac\missiles\' );
effects_folder         : shortstring = 'effs\';
missiles_folder        : shortstring = 'missiles\';

ui_limitstr            : shortstring = '125';

tc_player0             = #0;
{tc_player1             = #1;
tc_player2             = #2;
tc_player3             = #3;
tc_player4             = #4;
tc_player5             = #5;
tc_player6             = #6;}
tc_player7             = #7;
tc_nl1                 = #11;
tc_nl2                 = #12;
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

tc_SpecialChars        = [tc_player0..tc_default];

//b2cc                   : array[false..true] of string[3] = (tc_red+'-'+tc_default,tc_lime+'+'+tc_default);

sep_comma              = ',';
sep_scomma             = ', ';
sep_sdot               = '. ';
sep_sdots              = '; ';
sep_wdash              = tc_white+'-';

////////////////////////////////////////////////////////////////////////////////
//
//  INPUT
//

k_LastCharStuckDealy   = fr_fps1 div 3;
kt_TwiceDelay          = fr_fps1 div 4;
k_kbdig                : set of Char = ['0'..'9'];

// key mapping

km_mouse_l             = SDL_BUTTON_LEFT;
km_mouse_r             = SDL_BUTTON_RIGHT;
km_mouse_m             = SDL_BUTTON_MIDDLE;
km_mouse_wd            = SDL_BUTTON_WHEELDOWN;
km_mouse_wu            = SDL_BUTTON_WHEELUP;
km_arrow_up            = sdlk_up;
km_arrow_down          = sdlk_down;
km_arrow_left          = sdlk_left;
km_arrow_right         = sdlk_right;
km_lshift              = sdlk_lshift;
km_rshift              = sdlk_rshift;
km_lctrl               = sdlk_lctrl;
km_rctrl               = sdlk_rctrl;
km_lalt                = sdlk_lalt;
km_ralt                = sdlk_ralt;
km_Screenshot          = sdlk_print;
km_Esc                 = sdlk_escape;
km_Enter               = sdlk_return;
km_Space               = sdlk_space;
km_GamePause           = sdlk_pause;
km_Tab                 = sdlk_tab;

km_test_FastTime       = sdlk_end;
km_test_InstaProd      = sdlk_home;
km_test_ToggleAI       = sdlk_pageup;
km_test_iddqd          = sdlk_pagedown;
km_test_FogToggle      = sdlk_backspace;
km_test_DrawToggle     = sdlk_insert;
km_test_NullUpgrades   = SDLK_F3;
km_test_BePlayer0      = SDLK_F4;
km_test_BePlayer1      = SDLK_F5;
km_test_BePlayer2      = SDLK_F6;
km_test_BePlayer3      = SDLK_F7;
km_test_BePlayer4      = SDLK_F8;
km_test_BePlayer5      = SDLK_F9;
km_test_BePlayer6      = SDLK_F10;
km_test_BePlayer7      = SDLK_F11;
km_test_debug0         = SDLK_KP0;
km_test_debug1         = SDLK_KP1;

km_group0              = sdlk_0;
km_group9              = sdlk_9;

////////////////////////////////////////////////////////////////////////////////
//
//  HOTKEYS
//

HotKeysArraySize  = 26;


////////////////////////////////////////////////////////////////////////////////
//
//  MAP THEME
//

MaxTileSet             = 255;

theme_n                = 9;

theme_anim_step_n      = 3;
theme_anim_tile_step   = MapCellW div theme_anim_step_n;

// theme edge terrain style
tes_fog                = 0;
tes_nature             = 1;
tes_tech               = 2;

// theme animation style
tas_ice                = 0;
tas_liquid             = 1;
tas_magma              = 2;

tGridDecorsMax         = 2;
tGridDecorD            = 360 div tGridDecorsMax;
tGridDecorR            = MapCellW div 4;

{$ELSE }

str_ps_comp            : shortstring =  'AI';
str_ps_cheater         : shortstring =  'cheater';

str_gnstarted          : shortstring = 'Not started';
str_grun               : shortstring = 'Run';
str_gpaused            : shortstring = 'Paused by player #';
str_gwinner            : shortstring = 'Won by a team #';
str_udpport            : shortstring = ' UPD port: ';
str_gstatus            : shortstring = 'Game status:   ';
str_gpreset            : shortstring = 'Game preset:   ';
str_gsettings          : shortstring = 'Game settings:';
str_map                : shortstring = 'Map';

str_m_seed             : shortstring = 'Seed';
str_m_type             : shortstring = 'Type';
str_m_typel            : array[0..gms_m_types] of shortstring = ('Steppe','Cave','Lake','Lake w/Islands','Island','Sea shore','Sea');
str_m_siz              : shortstring = 'Size';
str_m_sym              : shortstring = 'Symmetry';
str_m_syml             : array[0..gms_m_symm] of shortstring = ('no','point','line |','line -','line \','line /');
str_aislots            : shortstring = 'Fill empty slots:         ';
str_fstarts            : shortstring = 'Fixed player starts:      ';
str_gmode              : shortstring = 'Game mode:                ';
str_gmodel             : array[0..gms_count    ] of shortstring = ('Skirmish','3x3','2x2x2','Capturing points','Invasion','King of the Hill','Battle Royal');
str_cgenerators        : shortstring = 'Generators:               ';
str_cgeneratorsl       : array[0..gms_g_maxgens] of shortstring = ('none','own,no new builders','5 min','10 min','15 min','20 min','infinity');
str_deadobservers      : shortstring = 'Observer mode after lose: ';
str_starta             : shortstring = 'Builders at game start:   ';
str_plname             : shortstring = 'Player name';
str_msg_PlayerPaused   : shortstring = 'player paused the game';
str_msg_PlayerResumed  : shortstring = 'player has resumed the game';
str_msg_PlayerLeave    : shortstring = ' left the game';
//str_player_def         : shortstring = ' was terminated!';

str_plstat             : shortstring = 'State';
str_team               : shortstring = 'Team';
str_srace              : shortstring = 'Race';

str_racel              : array[0..r_cnt       ] of shortstring = ('RANDOM','HELL','UAC');

str_observer           : shortstring = 'OBSERVER';
{$ENDIF}



