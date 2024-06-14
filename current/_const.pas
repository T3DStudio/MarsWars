
const

g_version              : byte = 232;

degtorad               = pi/180;

NOTSET                 = smallint.MaxValue;

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
fr_fps1d2              = fr_fpsd2*3;   //1,5
fr_fps2                = fr_fps1*2;
fr_fps3                = fr_fps1*3;
fr_fps6                = fr_fps1*6;
fr_fps2d3              = fr_fpsd3*2; //2/3
fr_fps60               = fr_fps1*60;

APM_UPDPeriod          = fr_fps1*5;
APM_1Period            = fr_fps60;

////////////////////////////////////////////////////////////////////////////////
//
//  Game settings borders
//

gms_g_startb           = 6;  // 0-6  max start base options
gms_g_maxgens          = 6;  // 0-6  max neutrall generators options

////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

ps_none                = 0;  // player state
ps_play                = 1;
ps_comp                = 2;

//  Player slot state
ps_closed              = 0;
ps_observer            = 1;
ps_opened              = 2;
ps_ready               = 3;  // menu option, not state
ps_nready              = 4;  // menu option, not state
ps_swap                = 5;  // menu option, not state
ps_AI_1                = 6;  // very easy
ps_AI_2                = 7;  // easy
ps_AI_3                = 8;  // medium
ps_AI_4                = 9;  // hard
ps_AI_5                = 10;  // harder
ps_AI_6                = 11;  // very hard
ps_AI_7                = 12; // elite
ps_AI_8                = 13; // Cheater 1 (Vision)
ps_AI_9                = 14; // Cheater 2 (Vision+MultiProd)
ps_AI_10               = 15; // Cheater 3 (Vision+MultiProd+FastUProd)
ps_AI_11               = 16; // Cheater 4 (Vision+MultiProd+FastUProd+FastBProd)

gms_g_maxai            = ps_AI_11-ps_AI_1+1; // 0-11 max skirmish AI skills

ps_states_n            = 6+gms_g_maxai;

player_default_ai_level= 7;

gm_scirmish            = 0;  // game mode
gm_3x3                 = 1;
gm_2x2x2               = 2;
gm_capture             = 3;
gm_invasion            = 4;
gm_KotH                = 5;
gm_royale              = 6;

gm_ModesFixedTeams     : set of byte = [gm_3x3,gm_2x2x2,gm_invasion];
gm_ModesFixedPositions : set of byte = [gm_3x3,gm_2x2x2];

allgamemodes           : set of byte = [gm_scirmish,gm_3x3,gm_2x2x2,gm_capture,gm_invasion,gm_KotH,gm_royale];
gm_cnt                 = 6;

g_step_koth_pause      = fr_fps60*4;

gs_running             = 0;  //
{gs_paused1            = 1; 1..MaxPlayers
 gs_paused2            = 2;
 gs_paused3            = 3;
 gs_paused4            = 4;
 gs_paused5            = 5;
 gs_paused6            = 6;}
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


r_cnt                  = 2;  // race num 0-r_cnt
r_random               = 0;
r_hell                 = 1;
r_uac                  = 2;

MaxPlayers             = 6; //0-6
MaxPlayerUnits         = 125;
MinUnitLimit           = 100;
MaxPlayerLimit         = MaxPlayerUnits*MinUnitLimit;
MaxCPoints             = MaxPlayers*2;

MaxSMapW               = 8000;
MinSMapW               = 2000;
StepSMap               = 250;

map_b0                 = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  Game presets
//

gp_custom              = 0;
gp_1x1_plane           = 1;
gp_1x1_lake            = 2;
gp_1x1_cave            = 3;

//gp_count               = 4;

////////////////////////////////////////////////////////////////////////////////
//
//  CPoints life
//

g_cgenerators_ltime    : array[0..gms_g_maxgens] of cardinal = (0,0,fr_fps60*5,fr_fps60*10,fr_fps60*15,fr_fps60*20,0);
g_cgenerators_energy   = 900;

////////////////////////////////////////////////////////////////////////////////
//
//  Invastion
//

InvMaxWaves            = 20;

////////////////////////////////////////////////////////////////////////////////
//
//  PATH FIND SYSTEM
//

pf_pathmap_w           = 40;
pf_pathmap_c           = (MaxSMapW div pf_pathmap_w)+1;

pf_pathmap_hw          = pf_pathmap_w div 2;

pf_solid               : word = 65535;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

str_ver                = 'v53';
str_wcaption           : shortstring = 'The Ultimate MarsWars '+str_ver+#0;
str_cprt               : shortstring = '[ T3DStudio (c) 2016-2024 ]';
str_ps_c               : array[0..2] of char = (' ','P','C');
str_ps_t               : char = '?';
str_ps_h               : char = '<';
str_ps_none            : shortstring = '--';
str_b2c                : array[false..true] of char = ('-','+');

outlogfn               : shortstring = 'out.txt';

k_kbstr                : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','[',']','{','}',' ','_',',','.','(',')','-','+','`','&','@','#','%','?','$'];

str_defaultPlayerName  = 'DoomPlayer';

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
lmt_chat6              = 6; }
lmt_game_message       = 10;
lmt_game_end           = 11;
lmt_player_defeated    = 12;
lmt_player_leave       = 13;
lmt_player_surrender   = 14;
lmt_cant_build         = 15;
lmt_unit_ready         = 16;
lmt_unit_advanced      = 17;
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
lmt_UsepsabilityOrder  = 32;
lmt_player_chat        = 255;

lmts_menu_chat         = [
                          0..MaxPlayers,
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

{
uia_nonew              = 0;
uia_trynew             = 1;
uia_newstrict          = 2;  }

////////////////////////////////////////////////////////////////////////////////
//
//  NETGAME
//

cl_UpT_arrayN          = 9;
cl_UpT_arrayN_RPLs     = cl_UpT_arrayN div 2;
                                                         // 60 140 220 300 380 460 540 620 700 800
cl_UpT_array           : array[0..cl_UpT_arrayN] of byte = (15,35 ,55 ,75 ,95 ,115,135,155,175,200);

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
nmid_lobbby_builders   = 27;
nmid_lobbby_generators = 28;
nmid_lobbby_FixStarts  = 29;
nmid_lobbby_DeadPbserver=30;
nmid_lobbby_EmptySlots = 31;
nmid_surrender         = 32;
nmid_start             = 33;
nmid_break             = 34;
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
ureq_usepsaorder       : cardinal = 1 shl 18; // need use s ability in point

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT/PLAYER OTDERS
//

mb_empty               = smallint.MinValue;
mb_move                = -1;
mb_attack              = -2;
mb_patrol              = -3;
mb_apatrol             = -4;
mb_psability           = -5;
mb_mark                = -6;

po_build               = 1;
po_select_rect_set     = 2; // select rect
po_select_rect_add     = 3; // select rect shift
po_select_uid_set      = 4; // select uid
po_select_uid_add      = 5; // select uid shift
po_select_group_set    = 6; // select group
po_select_group_add    = 7; // select group shift
po_select_special_set  = 8; // select f2
po_unit_order_set      = 9;
po_unit_group_set      = 10;
po_unit_group_add      = 11;
po_prod_unit_start     = 12;
po_prod_unit_stop      = 13;
po_prod_upgr_start     = 14;
po_prod_upgr_stop      = 15;
po_prod_stop           = 16;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ACTIONS
//


uo_nothing             = 0;
uo_move                = 1;
uo_attack              = 2;
uo_patrol              = 3;
uo_apatrol             = 4;
uo_stay                = 5;
uo_hold                = 6;
uo_sability            = 7;
uo_psability           = 8;
uo_rebuild             = 9;
uo_destroy             = 10;
uo_unload              = 11;

ua_attack              = 0;
ua_hold                = 1;
ua_move                = 2;
ua_unload              = 3;
ua_psability           = 4;

{ua_move                = 1;
ua_hold                = 2;
ua_amove               = 3;
ua_unload              = 4;
ua_psability           = 5;

ua_patrol              = 6; // only for client data transfer    }

////////////////////////////////////////////////////////////////////////////////
//
//  Conditionals for attack
//

atm_none               = 0;   // cant attack
atm_always             = 1;   // can attack
atm_bunker             = 2;   // can attack, units inside can attack too
atm_sturret            = 3;   // can attack when somebody inside
atm_inapc              = 4;   // can attack only when in apc


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
aw_hmelee              = -64;           // default heal/reapir melee range

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
wpt_directdmgZ         = 6;
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

MaxUnitBuffs           = 15;

ub_Pain                = 0;
ub_Resurect            = 1;
ub_Cast                = 2;
ub_Slow                = 3;
ub_CCast               = 4;
ub_Invis               = 5;
ub_Detect              = 6;
ub_Invuln              = 7;
ub_Summoned            = 8;
ub_Teleport            = 9;
ub_HVision             = 10;
ub_Damaged             = 11;
ub_Heal                = 12;
ub_Scaned              = 13;
ub_Decay               = 14;
ub_ArchFire            = 15;

_ub_infinity           = NOTSET;
b2ib                   : array[false..true] of smallint = (0,_ub_infinity);



////////////////////////////////////////////////////////////////////////////////
//
//  MAP
//

terrrain_cellw         = 80;
terrrain_celln         = MaxSMapW div terrrain_cellw;

mapt_steppe            = 0;
mapt_cave              = 1;
mapt_lake              = 2;
mapt_shore             = 3;
mapt_sea               = 4;

gms_m_types            = 4;  // 0-4  max map types
gms_m_symm             = 2;  // 0-2  max map symmetry types

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
upgr_hell_extbuild     = 9;  // buildings on doodabs
upgr_hell_paina        = 10; // decay aura
upgr_hell_towers       = 11; // towers range
upgr_hell_ghostm       = 12; // ghost monsters

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
upgr_uac_extbuild      = 39; // buildings on doodabs
upgr_uac_ccturr        = 40; // CC turret
upgr_uac_towers        = 41; // towers sr
upgr_uac_soaring       = 42; // UACBot floating

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

// BASIC RACE UPGRADES                                 HELL                UAC
upgr_race_armor_bio         : array[1..r_cnt] of byte    = (upgr_hell_uarmor  , upgr_uac_uarmor  );
upgr_race_armor_mech        : array[1..r_cnt] of byte    = (0                 , upgr_uac_mecharm );
upgr_race_armor_build       : array[1..r_cnt] of byte    = (upgr_hell_barmor  , upgr_uac_barmor  );
upgr_race_regen_bio         : array[1..r_cnt] of byte    = (upgr_hell_regen   , 0                );
upgr_race_regen_mech        : array[1..r_cnt] of byte    = (0                 , 0                );
upgr_race_regen_build       : array[1..r_cnt] of byte    = (upgr_hell_bldrep  , 0                );
upgr_race_mspeed_bio        : array[1..r_cnt] of byte    = (0                 , upgr_uac_mspeed  );
upgr_race_mspeed_mech       : array[1..r_cnt] of byte    = (0                 , upgr_uac_mechspd );
upgr_race_extbuilding       : array[1..r_cnt] of byte    = (upgr_hell_extbuild, upgr_uac_extbuild);
upgr_race_unit_srange       : array[1..r_cnt] of byte    = (upgr_hell_vision  , upgr_uac_vision  );
upgr_race_srange_unit_bonus : array[1..r_cnt] of smallint= (25                , 25               );

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

MaxUnits               = MaxPlayers*MaxPlayerUnits+MaxPlayerUnits;
MaxUnitWeapons         = 3;  //0-3
MaxUnitLevel           = 3;  //0-3
MaxMissiles            = MaxUnits;

// damage modificator

MaxDamageModFactors    = 1;

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
ptime1                 = 28;
ptimeh                 = ptime1  div 2;
ptimehh                = ptimeh  div 2;
ptimehhh               = ptimehh div 2;
ptime1h                = ptime1+ptimeh;
ptime1hh               = ptime1+ptimehh;
ptime2                 = ptime1*2;
ptime3                 = ptime1*3;
ptime4                 = ptime1*4;
ptime5                 = ptime1*5;
ptime6                 = ptime1*6;

uf_ground              = false;
uf_fly                 = true;

MaxUnitGroups          = 10;

mvxy_none              = 0;
mvxy_relative          = 1;
mvxy_strict            = 2;

BaseDamage1            = 62;
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

BaseDamageBonus1       = 8;
BaseDamageBonus3       = BaseDamageBonus1*3;
BaseDamageLevel1       = BaseDamageBonus1/4;
BaseArmorBonus1        = 8;
BaseArmorBonus2        = BaseArmorBonus1*2;
BaseArmorLevel1        = BaseArmorBonus1/4;

BaseHeal1              = (BaseDamage1 div 8)*3;
BaseHealBonus1         = BaseDamageBonus1*2;
BaseRepair1            = (BaseDamage1 div 8)*3;
BaseRepairBonus1       = BaseDamageBonus1*2;

DecayAuraDamage        = BaseDamage1 div 10;

ExpLevel1              = fr_fps1*30;

////////////////////////////////////////////////////////////////////////////////
//
//  UIDs
//

// HELL

UID_HKeep              = 1;
UID_HAKeep             = 2;
UID_HGate              = 3;
UID_HSymbol            = 4;
UID_HASymbol           = 5;
UID_HPools             = 6;
UID_HTower             = 7;
UID_HTeleport          = 8;
UID_HEye               = 9;
UID_HMonastery         = 10;
UID_HTotem             = 11;
UID_HAltar             = 12;
UID_HFortress          = 13;
UID_HCommandCenter     = 14;
UID_HACommandCenter    = 15;
UID_HBarracks          = 16;
UID_HPentagram         = 17;

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

UID_ZFormer            = 34;
UID_ZEngineer          = 35;
UID_ZSergant           = 36;
UID_ZSSergant          = 37;
UID_ZCommando          = 38;
UID_ZAntiaircrafter    = 39;
UID_ZSiegeMarine       = 40;
UID_ZFPlasmagunner     = 41;
UID_ZBFGMarine         = 42;

// UAC

UID_UCommandCenter     = 50;
UID_UACommandCenter    = 51;
UID_UBarracks          = 52;
UID_UFactory           = 53;
UID_UGenerator         = 54;
UID_UAGenerator        = 55;
UID_UWeaponFactory     = 56;
UID_URadar             = 57;
UID_URMStation         = 58;
UID_UTechCenter        = 59;
UID_UGTurret           = 60;
UID_UATurret           = 61;
UID_UComputerStation   = 62;
UID_UMine              = 63;

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
UID_APC                = 94;


uids_hell              = [1 ..49];
uids_uac               = [50..99];

uids_marines           = [UID_Engineer ,UID_Medic   ,UID_Sergant ,UID_SSergant ,UID_Commando ,UID_Antiaircrafter ,UID_SiegeMarine , UID_FPlasmagunner ,UID_BFGMarine ];
uids_zimbas            = [UID_ZEngineer,UID_ZFormer ,UID_ZSergant,UID_ZSSergant,UID_ZCommando,UID_ZAntiaircrafter,UID_ZSiegeMarine, UID_ZFPlasmagunner,UID_ZBFGMarine];
uids_arch_res          = [UID_Imp,UID_Demon,UID_Cacodemon,UID_Knight,UID_Baron,UID_Revenant,UID_Mancubus,UID_Arachnotron]+uids_zimbas;
uids_demons            = [UID_LostSoul..UID_Archvile]+uids_zimbas;
uids_all               = [0..255];

//T1                     = all by default
T2                     = [UID_UTechCenter,UID_UComputerStation,UID_HMonastery,UID_HFortress,UID_Terminator,UID_Tank,UID_Flyer,UID_Pain,UID_Revenant,UID_Mancubus,UID_Arachnotron]+uids_zimbas-[UID_ZBFGMarine];
T3                     = [UID_BFGMarine,UID_ZBFGMarine,UID_Archvile,UID_HTotem,UID_URMStation,UID_HAltar,UID_Cyberdemon,UID_Mastermind];

uid_race_start_fbase   : array[1..r_cnt] of smallint = (UID_HKeep    ,UID_UCommandCenter );
uid_race_start_abase   : array[1..r_cnt] of smallint = (UID_HAKeep   ,UID_UACommandCenter);

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ABILITIES
//

uab_Teleport           = 1;
uab_UACScan            = 2;
uab_HTowerBlink        = 3;
uab_UACStrike          = 4;
uab_HKeepBlink         = 5;
uab_RebuildInPoint     = 6;
uab_HInvulnerability   = 7;
uab_SpawnLost          = 8;
uab_HellVision         = 9;
uab_CCFly              = 10;

client_rld_abils       = [
                         uab_Teleport
                         ];
client_rld_uids        = [
                          UID_ArchVile
                         ];
client_cast_abils      = [
                         uab_UACScan  ,
                         uab_UACStrike,
                         uab_HInvulnerability
                         ];

////////////////////////////////////////////////////////////////////////////////
//
//  OTHER
//


fr_mancubus_rld        = fr_fps2+fr_fpsd2;  //2.5
fr_mancubus_rld_s1     = fr_fps2-fr_fpsd6;
fr_mancubus_rld_s2     = fr_fps1+fr_fpsd6;
fr_mancubus_rld_s3     = fr_fpsd2;

fr_archvile_s          = fr_fps1+fr_fpsd6;

NameLen                = 13;

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
vistime                = fr_fps1d2;

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

bld_dec_mr             = 6;
_mms                   = 126;
_d2shi                 = abs(dead_hits div 125)+1;   // 5

gm_cptp_gtime          = fr_fps1*ptimehh;
gm_cptp_time           = fr_fps1*ptimeh;
gm_cptp_r              = 100;

fly_z                  = 80;
fly_hz                 = fly_z div 2;
fly_height             : array[false..true] of smallint = (1,fly_z);

pain_time              = fr_fps1;

{$IFDEF _FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
//  HOTKEYS
//

_mhkeys  = 26;
_hotkey1 : array[0.._mhkeys] of cardinal = (SDLK_R , SDLK_T , SDLK_Y ,
                                            SDLK_F , SDLK_G , SDLK_H ,
                                            SDLK_V , SDLK_B , SDLK_N ,

                                            SDLK_U , SDLK_I , SDLK_O ,
                                            SDLK_J , SDLK_K , SDLK_L ,
                                            SDLK_R , SDLK_T , SDLK_Y ,

                                            SDLK_F , SDLK_G , SDLK_H ,
                                            SDLK_V , SDLK_B , SDLK_N ,
                                            SDLK_R , SDLK_T , SDLK_Y );

_hotkey2 : array[0.._mhkeys] of cardinal = (0      , 0      , 0      ,
                                            0      , 0      , 0      ,
                                            0      , 0      , 0      ,

                                            0      , 0      , 0      ,
                                            0      , 0      , 0      ,
                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl,

                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl,
                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl,
                                            SDLK_LCtrl, SDLK_LCtrl, SDLK_LAlt);

_hotkeyA : array[0.._mhkeys] of cardinal = (SDLK_Q    , SDLK_W    , SDLK_E ,
                                            SDLK_A    , SDLK_S    , SDLK_D ,
                                            SDLK_Z    , SDLK_X    , SDLK_C ,

                                            SDLK_C    , SDLK_F2   , SDLK_Delete,
                                            SDLK_F5   , SDLK_Z    , 0,
                                            0         , 0         , 0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);
_hotkeyA2: array[0.._mhkeys] of cardinal = (0          , 0         , 0 ,
                                            0          , 0         , 0 ,
                                            0          , 0         , 0 ,

                                            SDLK_LCtrl , 0         , 0,
                                            0          , SDLK_LCtrl, 0,
                                            0          , 0         , 0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);

_hotkeyR : array[0.._mhkeys] of cardinal = (SDLK_Q , SDLK_W , SDLK_E ,
                                            SDLK_A , SDLK_S , SDLK_D ,
                                            SDLK_Z , 0      , SDLK_0 ,

                                            SDLK_1 , SDLK_2 , SDLK_3 ,
                                            SDLK_4 , SDLK_5 , SDLK_6 ,
                                            0,0,0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);
_hotkeyO : array[0.._mhkeys] of cardinal = (SDLK_Q , SDLK_W , SDLK_0 ,
                                            SDLK_1 , SDLK_2 , SDLK_3 ,
                                            SDLK_4 , SDLK_5 , SDLK_6 ,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);


_buffst                : array[false..true] of smallint = (0,_ub_infinity);

str_ps_sv              : char = '@';

char_start             : char = '+';
char_gen               : char = '*';
char_cp                : char = '=';

ChatLen2               = 200;
dead_time              = -dead_hits;
char_detect            = #7;
char_advanced          = #10;

spr_upgrade_icons      = 24;

vid_maxplcolors        = 6;

max_CamSpeed           = 127;

////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE DEPTH
//

// terrain
sd_liquid_back         = -32500;
sd_liquid              = -32000;
// neytral generators
sd_tcraters            = MaxSMapW+sd_liquid;    // -24000
// doodads
sd_brocks              = MaxSMapW+sd_tcraters;  // -16000
sd_srocks              = MaxSMapW+sd_brocks;    // -8000
sd_build               = MaxSMapW+sd_srocks;    //  0
sd_ground              = MaxSMapW+sd_build;     //  8000
sd_fly                 = MaxSMapW+sd_ground;    //  16000
sd_marker              = MaxSMapW+sd_fly;       //  24000

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

ta_left                = 0;
ta_middle              = 1;
ta_right               = 2;
ta_chat                = 3;
ta_rightmid            = 4;
ta_x0y0                = 5;
ta_x1y1                = 6;

font_w                 = 8;
font_hw                = font_w div 2;
font_hhw               = font_w div 4;
font_34                =(font_w div 4)*3;
font_5w                = font_w*5;
font_iw                = font_w-1;
font_3hw               = font_w+(font_w div 2);
font_6hw               = font_3hw*2;

txt_line_h1            = font_w+2;
txt_line_h2            = 25-font_w;
txt_line_h3            = font_w+5;

chat_all               = 255;
chat_allies            = 254;
{chat_1                 = 1;
chat_2                 = 2;
chat_3                 = 3;
chat_4                 = 4;
chat_5                 = 5;
chat_6                 = 6;}

////////////////////////////////////////////////////////////////////////////////
//
//  VIDEO & UI
//

fr_ifps                = fr_fps1-1;

vid_bpp                = 32;
vid_minw               = 800;
vid_minh               = 600;
vid_maxw               = 1360;
vid_maxh               = 768;

vid_rw_list            : array[0..4] of Smallint = (vid_minw,960,1024,1280,vid_maxw);
vid_rh_list            : array[0..3] of Smallint = (vid_minh,680,720,vid_maxh);

vid_ab                 = 128;
vid_MaxScreenSprites   = 500; // max vis sprites;
vid_blink_persecond    = 6;
vid_blink_period1      = fr_fps1  div vid_blink_persecond;
vid_blink_periodh      = vid_blink_period1 div 2;
vid_blink_period2      = vid_blink_period1*2;

vid_panel_period       = fr_fps1 div 6;

ui_alarm_time          = vid_blink_period2;

vid_BW                 = 48;
vid_2BW                = vid_BW*2;
vid_panelw             = vid_BW*3;
vid_panelwi            = vid_panelw-1;
vid_tBW                = vid_panelw div 4;
vid_hBW                = vid_BW div 2;
vid_oiw                = 18;
vid_oihw               = vid_oiw+(vid_oiw div 2);
vid_oisw               = vid_oiw-(vid_oiw div 4);
vid_oips               = 2*vid_oiw+vid_oisw;
vid_svld_m             = 9;
vid_rpls_m             = 10;
vid_camp_m             = 11;
vid_srch_m             = 2;

ui_max_alarms          = 12;

ui_bottomsy            = vid_BW*4;
ui_hwp                 = vid_panelw div 2;
ui_ubtns               = 23;

ui_menu_list_item_H    = font_w*2;
ui_menu_list_item_S    = font_w div 2;

////////////////////////   menu items
////  MAIN
mi_exit                = 1;
mi_back                = 2;
mi_start               = 3;
mi_break               = 4;
mi_surrender           = 5;

////  MAP PARAMS
mi_map_params1         = 11;
mi_map_params2         = 12;
mi_map_params3         = 13;
mi_map_params4         = 14;
mi_map_params5         = 15;
mi_map_params6         = 16;
mi_map_params7         = 17;

////  TABS SETTINGS SAVELOAD REPLAYS
mi_tab_settings        = 21;
mi_tab_saveload        = 22;
mi_tab_replays         = 23;

////  TABS SETTINGS
mi_settings_game       = 24;
mi_settings_video      = 25;
mi_settings_sound      = 26;

////  SETTINGS GAME LINES
mi_settings_ColoredShadows= 31;
mi_settings_ShowAPM       = 32;
mi_settings_HitBars       = 33;
mi_settings_MRBAction     = 34;
mi_settings_ScrollSpeed   = 35;
mi_settings_MouseScroll   = 36;
mi_settings_PlayerName    = 37;
mi_settings_Langugage     = 38;
mi_settings_PanelPosition = 39;
mi_settings_PlayerColors  = 40;
mi_settings_game11        = 41;

////  SETTINGS VIDEO LINES
mi_settings_video1     = 51;
mi_settings_video2     = 52;
mi_settings_ResWidth   = 53;
mi_settings_ResHeight  = 54;
mi_settings_ResApply   = 55;
mi_settings_video6     = 56;
mi_settings_Fullscreen = 57;
mi_settings_video8     = 58;
mi_settings_ShowFPS    = 59;
mi_settings_video10    = 60;
mi_settings_video11    = 61;

////  SETTINGS SOUND LINES
mi_settings_sound1     = 71;
mi_settings_sound2     = 72;
mi_settings_SoundVol   = 73;
mi_settings_MusicVol   = 74;
mi_settings_sound5     = 75;
mi_settings_NextTrack  = 76;
mi_settings_sound7     = 77;
mi_settings_sound8     = 78;
mi_settings_sound9     = 79;
mi_settings_sound10    = 80;
mi_settings_sound11    = 81;

////  SAVE LOAD
mi_saveload_list       = 90;
mi_saveload_fname      = 91;
mi_saveload_save       = 92;
mi_saveload_load       = 93;
mi_saveload_delete     = 94;

////  REPLAYS
mi_replays_list        = 97;
mi_replays_play        = 98;
mi_replays_delete      = 99;

////  PLAYERS

mi_player_status1      = 111;
mi_player_status2      = 112;
mi_player_status3      = 113;
mi_player_status4      = 114;
mi_player_status5      = 115;
mi_player_status6      = 116;

mi_player_race1        = 121;
mi_player_race2        = 122;
mi_player_race3        = 123;
mi_player_race4        = 124;
mi_player_race5        = 125;
mi_player_race6        = 126;

mi_player_team1        = 131;
mi_player_team2        = 132;
mi_player_team3        = 133;
mi_player_team4        = 134;
mi_player_team5        = 135;
mi_player_team6        = 136;

////  CAMPAINGS SCIRMISH MULTIPLAYER

mi_tab_campaing        = 141;
mi_tab_game            = 142;
mi_tab_multiplayer     = 143;

////  GAME
mi_game_GameCaption    = 150;
mi_game_mode           = 151;
mi_game_builders       = 152;
mi_game_generators     = 153;
mi_game_FixStarts      = 154;
mi_game_DeadPbserver   = 155;
mi_game_EmptySlots     = 156;
mi_game_RandomSkrimish = 157;

mi_game_RecordCaption  = 158;
mi_game_RecordStatus   = 159;
mi_game_RecordName     = 160;
mi_game_RecordQuality  = 161;

////  MULTIPLAYER
mi_mplay_ServerCaption = 170;
mi_mplay_ServerPort    = 171;
mi_mplay_ServerToggle  = 172;
mi_mplay_ClientCaption = 173;
mi_mplay_ClientAddress = 174;
mi_mplay_ClientConnect = 175;
mi_mplay_ClientQuality = 176;
mi_mplay_Chat          = 177;
mi_mplay_NetSearch     = 178;
mi_mplay_NetSearchList = 179;
mi_mplay_NetSearchCon  = 180;

/////////////////////////////    MAIN MENU ZONES

//// main buttons
ui_menu_mbutton_lx0    = 32;
ui_menu_mbutton_lx1    = 107;
ui_menu_mbutton_rx0    = 692;
ui_menu_mbutton_rx1    = 767;
ui_menu_mbutton_y0     = 544;
ui_menu_mbutton_y1     = 571;

//// map section
ui_menu_map_zx0        = 76;    // full zone
ui_menu_map_zy0        = 110;
ui_menu_map_zx1        = 381;
ui_menu_map_zy1        = 253;
ui_menu_map_cx         = (ui_menu_map_zx0+ui_menu_map_zx1) div 2;   // caption
ui_menu_map_cy         = ui_menu_map_zy0-font_3hw-2;
ui_menu_map_lh         = 20;                                        // line height
ui_menu_map_lhh        = ui_menu_map_lh div 2;
ui_menu_map_mx0        = ui_menu_map_zx0;                           // map position
ui_menu_map_my0        = ((ui_menu_map_zy0+ui_menu_map_zy1) div 2)-(vid_panelw div 2)+1;
ui_menu_map_ph         = ui_menu_map_lh*7;                          // parameters count
ui_menu_map_px0        = ui_menu_map_mx0+vid_panelw+ui_menu_map_lhh-font_w;// parameters block
ui_menu_map_py0        = ui_menu_map_my0+1;
ui_menu_map_px1        = ui_menu_map_zx1-ui_menu_map_lhh+font_w;
ui_menu_map_py1        = ui_menu_map_py0+ui_menu_map_ph;

//// settings save/load replays  tabs
ui_menu_ssr_zx0        = 76;    // full zone
ui_menu_ssr_zy0        = 290;
ui_menu_ssr_zx1        = 381;
ui_menu_ssr_zy1        = 523;
ui_menu_ssr_lh         = 18;    // line height
ui_menu_ssr_cw         = round((ui_menu_ssr_zx1-ui_menu_ssr_zx0)/3); // col width
ui_menu_ssr_cx         = (ui_menu_ssr_zx0+ui_menu_ssr_zx1) div 2;    // center x

//// players section
ui_menu_pls_zx0        = 418;   // full zone
ui_menu_pls_zy0        = 110;
ui_menu_pls_zx1        = 723;
ui_menu_pls_zy1        = 253;
ui_menu_pls_lh         = 23;
ui_menu_pls_lhh        = ui_menu_pls_lh div 2;
ui_menu_pls_cptx       = (ui_menu_pls_zx0+ui_menu_pls_zx1) div 2;
ui_menu_pls_cpty       = ui_menu_pls_zy0-font_3hw-2;
ui_menu_pls_pbh        = ui_menu_pls_lh*MaxPlayers; // players block height
ui_menu_pls_pbx0       = ui_menu_pls_zx0;           // players block
ui_menu_pls_pby0       = ((ui_menu_pls_zy0+ui_menu_pls_zy1)div 2)-(ui_menu_pls_pbh div 2);
ui_menu_pls_pbx1       = ui_menu_pls_zx1;
ui_menu_pls_pby1       = ((ui_menu_pls_zy0+ui_menu_pls_zy1)div 2)+(ui_menu_pls_pbh div 2);

ui_menu_pls_cx_race    = ui_menu_pls_pbx0+font_w*NameLen+font_w*4;
ui_menu_pls_cx_team    = ui_menu_pls_cx_race+font_w*9;
ui_menu_pls_cx_color   = ui_menu_pls_cx_team+font_w*10;

ui_menu_pls_border     = ui_menu_pls_lh div 4;
ui_menu_pls_color_x0   = ui_menu_pls_cx_color+ui_menu_pls_border;
ui_menu_pls_color_x1   = ui_menu_pls_pbx1    -ui_menu_pls_border+1;

ui_menu_nsrch_lh       = txt_line_h3;
ui_menu_nsrch_lh2      = txt_line_h3*2;
ui_menu_nsrch_lh3      = txt_line_h3*3;
ui_menu_nsrch_zx0      = ui_menu_pls_pbx0;
ui_menu_nsrch_zy0      = ui_menu_pls_pby0;
ui_menu_nsrch_zx1      = ui_menu_pls_pbx1;
ui_menu_nsrch_zy1      = ui_menu_pls_pby0+ui_menu_nsrch_lh3*3;

//// campaings game multiplayer  tabs
ui_menu_cgm_zx0        = 418;
ui_menu_cgm_zy0        = 290;
ui_menu_cgm_zx1        = 723;
ui_menu_cgm_zy1        = 523;
ui_menu_cgm_lh         = 18;
ui_menu_cgm_cw         = round((ui_menu_cgm_zx1-ui_menu_cgm_zx0)/3); // col width
ui_menu_cgm_cx         = (ui_menu_cgm_zx0+ui_menu_cgm_zx1) div 2;    // center x

{ui_menu_csm_xs         = 102;
ui_menu_csm_xhs        = ui_menu_csm_xs div 2;
ui_menu_csm_ys         = 18;
ui_menu_csm_2ys        = ui_menu_csm_ys*2;
//ui_menu_csm_yhs        = ui_menu_csm_ys div 2;
ui_menu_csm_ycs        = 10;
ui_menu_csm_xct        = ui_menu_csm_x0+2;
ui_menu_csm_xc         = (ui_menu_csm_x0+ui_menu_csm_x1) div 2;
ui_menu_csm_x2         = ui_menu_csm_x0+ui_menu_csm_xs;
ui_menu_csm_x3         = ui_menu_csm_x2+ui_menu_csm_xs;
ui_menu_csm_xt0        = ui_menu_csm_x0+6;
ui_menu_csm_xt1        = ui_menu_csm_x0+18;
ui_menu_csm_xt2        = ui_menu_csm_x1-6;
ui_menu_csm_xt3        = ui_menu_csm_xc+6;  }


chat_type              : array[false..true] of char = ('|',' ');
log_LastMesTime        = fr_fps1*3;
log_LastMesMaxN        = log_LastMesTime*6;

ui_menu_chat_height    = 17; // lines
ui_menu_chat_width     = 37; // chars

ui_dBW                 = vid_BW-font_w-3;


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
sss_sssize             : array[0..sss_count-1] of smallint = (1,12,1,3,1,1);

max_svolume            = 127;

////////////////////////////////////////////////////////////////////////////////
//
//  SAVE/LOAD/REPLAY
//

rpls_file_none         = 0;
rpls_file_write        = 1;
rpls_file_read         = 2;

rpls_state_none        = 0;
rpls_state_write       = 1;
rpls_state_read        = 2;

SvRpLen                = 15;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

MFogM                  = 64;
fog_cw                 = 32;
fog_chw                = fog_cw div 2;
fog_cr                 = round(fog_chw*1.45);
fog_vfwm               = (vid_maxw div fog_cw)+2;
fog_vfhm               = (vid_maxh div fog_cw)+2;

{fog_mm_Min             = 1;
fog_mm_Max             = vid_panelwi; }

////////////////////////////////////////////////////////////////////////////////
//
//  MENU
//

ms1_sett               = 0;
ms1_svld               = 1;
ms1_reps               = 2;

ms2_camp               = 0;
ms2_game               = 1;
ms2_mult               = 2;

ms3_game               = 0;
ms3_vido               = 1;
ms3_sond               = 2;

MaxMissions            = 21;
CMPMaxSkills           = 6;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE STRINGS
//

cfgfn                  : shortstring = 'cfg';
str_screenshot         : shortstring = 'MVSCR_';
str_loading_gfx        : shortstring = 'LOADING GRAPHICS...'+#0;
str_loading_sfx        : shortstring = 'LOADING SOUNDS...'+#0;
str_loading_msc        : shortstring = 'LOADING MUSIC...'+#0;
str_f_grp              : shortstring = 'graphic\';
str_f_map              : shortstring = 'map\';
str_f_snd              : shortstring = 'sound\';
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
tc_player5             = #5;}
tc_player6             = #6;
tc_nl1                 = #11;
tc_nl2                 = #12;
tc_nl3                 = #13;
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

k_chrtt                = fr_fps1 div 3;
k_kbdig                : set of Char = ['0'..'9'];
k_kbaddr               : set of Char = ['0'..'9','.',':'];

////////////////////////////////////////////////////////////////////////////////
//
//  MAP THEME
//

MaxTileSet             = 16;

theme_n                = 1;
theme_name             : array[0..theme_n-1] of shortstring = (tc_lime  +'TECH BASE'
                                                               {tc_blue  +'TECH BASE'  ,
                                                               tc_white +'PLANET'     ,
                                                               tc_white +'PLANET MOON',
                                                               tc_gray  +'CAVES'      ,
                                                               tc_aqua  +'ICE CAVES'  ,
                                                               tc_orange+'HELL'       ,
                                                               tc_yellow+'HELL CAVES' });
theme_anim_step_n      = 3;
theme_anim_tile_step   = terrrain_cellw div theme_anim_step_n;

// theme edge terrain style
tes_fog                = 0;
tes_nature             = 1;
tes_tech               = 2;

// theme animation style
tas_none               = 0;
tas_liquid             = 1;
tas_magma              = 2;

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
str_m_typel            : array[0..gms_m_types] of shortstring = ('Steppe','Cave','Lake','Sea shore','Sea');
str_m_siz              : shortstring = 'Size';
str_m_sym              : shortstring = 'Symmetry';
str_m_syml             : array[0..gms_m_symm] of shortstring = ('no','point','line');
str_aislots            : shortstring = 'Fill empty slots:         ';
str_fstarts            : shortstring = 'Fixed player starts:      ';
str_gmode              : shortstring = 'Game mode:                ';
str_gmodel             : array[0..gm_cnt      ] of shortstring = ('Skirmish','3x3','2x2x2','Capturing points','Invasion','King of the Hill','Battle Royal');
str_cgenerators        : shortstring = 'Generators:               ';
str_cgeneratorsl       : array[0..gms_g_maxgens] of shortstring = ('none','own,no new builders','5 min','10 min','15 min','20 min','infinity');
str_deadobservers      : shortstring = 'Observer mode after lose: ';
str_starta             : shortstring = 'Builders at game start:   ';
str_plname             : shortstring = 'Player name';
str_PlayerPaused       : shortstring = 'player paused the game';
str_PlayerResumed      : shortstring = 'player has resumed the game';
str_plout              : shortstring = ' left the game';
//str_player_def         : shortstring = ' was terminated!';

str_plstat             : shortstring = 'State';
str_team               : shortstring = 'Team';
str_srace              : shortstring = 'Race';

str_racel              : array[0..r_cnt       ] of shortstring = ('RANDOM','HELL','UAC');

str_observer           : shortstring = 'OBSERVER';
{$ENDIF}



