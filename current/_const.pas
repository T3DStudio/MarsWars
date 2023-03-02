
const

ver                    : byte = 230;

degtorad               = pi/180;

NOTSET                 = 32000;

////////////////////////////////////////////////////////////////////////////////
//
//  FRAME RATE
//

fr_fps1                = 60;
fr_RateTicks           = 1000/fr_fps1;

fr_fpsd2               = fr_fps1 div 2;
fr_fpsd3               = fr_fps1 div 3;
fr_fpsd4               = fr_fps1 div 4;
fr_fpsd6               = fr_fps1 div 6;
fr_fpsd8               = fr_fps1 div 8;
fr_fps1d2              = fr_fpsd2*3;   //1,5
fr_fps2                = fr_fps1*2;
fr_fps3                = fr_fps1*3;
fr_fps2d3              = fr_fpsd3*2; //2/3
fr_fps60               = fr_fps1*60;

APM_UPDPeriod          = fr_fps1*5;
APM_1Period            = fr_fps60;

////////////////////////////////////////////////////////////////////////////////
//
//  Game settings borders
//

gms_g_startb           = 6;  // 0-6  max start base options
gms_g_maxai            = 11; // 0-11 max skirmish AI skills
gms_g_maxgens          = 5;  // 0-5  max neytrall generators options

////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

ps_none                = 0;  // player state
ps_play                = 1;
ps_comp                = 2;

gm_scirmish            = 0;  // game mode
gm_3x3                 = 1;
gm_2x2x2               = 2;
gm_capture             = 3;
gm_invasion            = 4;
gm_KotH                = 5;
gm_royale              = 6;

gm_fixed_positions     : set of byte = [gm_3x3,gm_2x2x2,gm_invasion];

allgamemodes           : set of byte = [gm_scirmish,gm_3x3,gm_2x2x2,gm_capture,gm_invasion,gm_KotH,gm_royale];
gm_cnt                 = 6;


gs_running             = 0;  //
{gs_paused1            = 1; 1..MaxPlayers
 gs_paused2            = 2;
 gs_paused3            = 3;
 gs_paused4            = 4;
 gs_paused5            = 5;
 gs_paused6            = 6;}
gs_replayend           = 10;
gs_waitserver          = 11;
gs_replaypause         = 12;
gs_win_team0           = 20; // 0
gs_win_team1           = 21;
gs_win_team2           = 22;
gs_win_team3           = 23;
gs_win_team4           = 24;
gs_win_team5           = 25;
gs_win_team6           = 26;
{
}

r_cnt                  = 2;  // race num 0-r_cnt
r_random               = 0;
r_hell                 = 1;
r_uac                  = 2;

MaxPlayers             = 6; //0-6
MaxPlayerUnits         = 125;
MinUnitLimit           = 100;
MaxPlayerLimit         = MaxPlayerUnits*MinUnitLimit;
MaxCPoints             = MaxPlayers*3;

MaxSMapW               = 7000;
MinSMapW               = 2000;
StepSMap               = 250;

map_b0                 = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  CPoints life
//

g_cgenerators_ltime    : array[0..gms_g_maxgens] of cardinal = (0,fr_fps1*60*5,fr_fps1*60*10,fr_fps1*60*15,fr_fps1*60*20,0);

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

str_ver                = 'v52';
str_wcaption           : shortstring = 'The Ultimate MarsWars '+str_ver+#0;
str_cprt               : shortstring = '[ T3DStudio (c) 2016-2023 ]';
str_ps_c               : array[0..2] of char = (' ','P','C');
str_ps_t               : char = '?';
str_ps_h               : char = '<';
str_ps_comp            : shortstring = 'AI';
str_ps_none            : shortstring = '--';
b2c                    : array[false..true] of char = ('-','+');

outlogfn               : shortstring = 'out.txt';


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
lmt_cant_build         = 14;
lmt_unit_ready         = 15;
lmt_unit_advanced      = 16;
lmt_upgrade_complete   = 17;
lmt_req_energy         = 18;
lmt_req_common         = 19;
lmt_req_ruids          = 20;
lmt_map_mark           = 21;
lmt_unit_attacked      = 22;
lmt_cant_order         = 23;
lmt_allies_attacked    = 24;
lmt_unit_limit         = 25;
lmt_unit_needbuilder   = 26;
lmt_production_busy    = 27;
lmt_already_adv        = 28;
lmt_NeedMoreProd       = 29;
lmt_MaximumReached     = 30;
lmt_player_chat        = 255;

lmts_menu_chat         = [
                          0..MaxPlayers,
                          lmt_game_message,
                          lmt_game_end,
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

_cl_pnun               = 9;
                                                    // 60 140 220 300 380 460 540 620 700 800
_cl_pnua               : array[0.._cl_pnun] of byte = (15,35 ,55 ,75 ,95 ,115,135,155,175,200);

ClientTTL              = fr_fps1*10;

NetTickN               = 2;
MaxNetBuffer           = 4096;

ns_none                = 0;
ns_srvr                = 1;
ns_clnt                = 2;

nmid_lobby_info        = 3;
nmid_connect           = 4;
nmid_client_info       = 5;
nmid_log_chat          = 6;
nmid_chatclupd         = 7;
nmid_snapshot          = 8;
nmid_pause             = 9;
nmid_server_full       = 10;
nmid_wrong_ver         = 11;
nmid_game_started      = 12;
nmid_notconnected      = 13;
nmid_swapp             = 14;
nmid_order             = 15;
nmid_player_leave      = 16;
nmid_map_mark          = 17;
nmid_getinfo           = 66;


////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER ORDERS
//

uo_build               = 1;
uo_dblselect           = 2;
uo_adblselect          = 3;
uo_select              = 4;
uo_aselect             = 5;
uo_selorder            = 6;
uo_setorder            = 7;
uo_corder              = 8;
uo_specsel             = 9;
uo_addorder            = 10;


////////////////////////////////////////////////////////////////////////////////
//
//  UNIT & UPGRADES REQUIREMENTS BITS
//

ureq_unitlimit         : cardinal = 1;    // 1
ureq_ruid              : cardinal = 2;    // 2
ureq_rupid             : cardinal = 4;    // 4
ureq_energy            : cardinal = 8;    // 8
ureq_time              : cardinal = 16;   // 16
ureq_max               : cardinal = 32;   // 32
ureq_builders          : cardinal = 64;   // need builders  64
ureq_bld_r             : cardinal = 128;  //                 128
ureq_barracks          : cardinal = 256;  // need barracks     512
ureq_smiths            : cardinal = 512;  // need smith          1024
ureq_product           : cardinal = 1024; // already in production
ureq_armylimit         : cardinal = 2048;
ureq_place             : cardinal = 4096; // cant build here
ureq_busy              : cardinal = 8192; // production is busy
ureq_unknown           : cardinal = 16384;//
ureq_alreadyAdv        : cardinal = 32768;//
ureq_needbuilders      : cardinal = 65536;// need more builders
ureq_common            : cardinal =131072;// common

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT OTDERS
//

co_empty               = -32000;
co_destroy             = -111;
co_rcamove             = -101;
co_rcmove              = -100;
co_stand               = -90;
co_move                = -91;
co_patrol              = -92;
co_astand              = -93;
co_amove               = -94;
co_apatrol             = -95;
co_paction             = -79;
co_action              = -80;
co_supgrade            = -81;
co_cupgrade            = -82;
co_suprod              = -83;
co_cuprod              = -84;
co_pcancle             = -85;
co_mmark               = -86;
co_rebuild             = -87;

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT ACTIONS
//

ua_move                = 1;
ua_hold                = 2;
ua_amove               = 3;
ua_unload              = 4;
ua_paction             = 5;

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
wpr_zombie             : cardinal =  %0000000000001000;
wpr_avis               : cardinal =  %0000000000010000;
wpr_ground             : cardinal =  %0000000000100000;
wpr_air                : cardinal =  %0000000001000000;
wpr_move               : cardinal =  %0000000010000000;
wpr_reload             : cardinal =  %0000000100000000;

aw_fsr0                = 15000;

aw_srange              =  0;            // attack range = sight range
aw_fsr                 =  aw_fsr0+7500; // attack range = sight range + (x-aw_fsr)
aw_dmelee              = -8;            // default melee range
aw_hmelee              = -64;           // default heal/reapir melee range

////////////////////////////////////////////////////////////////////////////////
//
//  Target requirements flags
//

wtr_owner_p            : cardinal = %000000000000000000001;  // own
wtr_owner_a            : cardinal = %000000000000000000010;  // ally
wtr_owner_e            : cardinal = %000000000000000000100;  // enemy
wtr_hits_h             : cardinal = %000000000000000001000;  // 0<hits<mhits
wtr_hits_d             : cardinal = %000000000000000010000;  // hits<=0
wtr_hits_a             : cardinal = %000000000000000100000;  // hits=mhits
wtr_bio                : cardinal = %000000000000001000000;  // non mech
wtr_mech               : cardinal = %000000000000010000000;  // mech and !building
wtr_building           : cardinal = %000000000000100000000;  // building
wtr_bld                : cardinal = %000000000001000000000;  // bld=true
wtr_nbld               : cardinal = %000000000010000000000;  // bld=false
wtr_ground             : cardinal = %000000000100000000000;
wtr_fly                : cardinal = %000000001000000000000;
wtr_adv                : cardinal = %000000010000000000000;
wtr_nadv               : cardinal = %000000100000000000000;
wtr_light              : cardinal = %000001000000000000000;
wtr_nlight             : cardinal = %000010000000000000000;
wtr_stun               : cardinal = %000100000000000000000;
wtr_nostun             : cardinal = %001000000000000000000;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: type
//

wpt_missle             = 0;
wpt_resurect           = 1;
wpt_heal               = 2;
wpt_unit               = 3;
wpt_directdmg          = 4;
wpt_suicide            = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: move status
//

wmove_impassible       = 0;
wmove_closer           = 1;
wmove_farther          = 2;
wmove_noneed           = 3;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: priority type
//

wtp_default            = 0;
wtp_hits               = 1;
wtp_rmhits             = 2;
wtp_distance           = 3;
wtp_building           = 4;
wtp_unit_light_bio     = 5;
wtp_unit_bio_nostun    = 6;
wtp_unit_bio_light     = 7;
wtp_unit_bio_nlight    = 8;
wtp_unit_mech_nostun   = 9;
wtp_unit_mech          = 10;
wtp_bio                = 11;
wtp_light              = 12;
wtp_unit_light         = 13;
wtp_building_nlight    = 14;
wtp_scout              = 15;
wtp_notme_hits         = 16;
wtp_fly                = 17;
wtp_nolost_hits        = 18;
wtp_max_hits           = 19;


////////////////////////////////////////////////////////////////////////////////
//
//  AI FLAGS
//

ai_limit_border        = MaxPlayerLimit-(10*MinUnitLimit);

aif_base_smart_opening : cardinal = 1;
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

_ub_infinity           = 32000;
b2ib                   : array[false..true] of integer = (0,_ub_infinity);



////////////////////////////////////////////////////////////////////////////////
//
//  OBSTACLES
//

MaxDoodads             = 700;

//
ddc_div                = 1000000;
ddc_cf                 = (MaxSMapW*MaxSMapW) div ddc_div; // 36

// doodads cell
dcw                    = 200;
dcn                    = MaxSMapW div dcw;

DID_LiquidR1           = 1;
DID_LiquidR2           = 2;
DID_LiquidR3           = 3;
DID_LiquidR4           = 4;
DID_BRock              = 5;
DID_SRock              = 6;
DID_Other              = 7;

dids_liquids           = [DID_LiquidR1..DID_LiquidR4];

DID_R                  : array[0..7] of integer = (0,255,185,125,64,105,60,17);


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
upgr_hell_paina        = 9;  // decay aura
upgr_hell_extbuild     = 10; // HK on doodabs
upgr_hell_towers       = 11; // towers range
upgr_hell_pinkspd      = 12; // demon move speed

upgr_hell_spectre      = 13; // demon spectre                 // t2
upgr_hell_vision       = 14; // demons vision
upgr_hell_phantoms     = 15; // demons vision
upgr_hell_t2attack     = 16; // t2 distance attacks damage
upgr_hell_teleport     = 17; // Teleport reload
upgr_hell_rteleport    = 18; // revers teleport
upgr_hell_heye         = 19; // hell Eye time
upgr_hell_totminv      = 20; // totem and eye invisible
upgr_hell_bldrep       = 21; // build restoration
upgr_hell_b478tel      = 22; // teleport towers
upgr_hell_resurrect    = 23; // archvile ability
upgr_hell_invuln       = 24; // hell invuln powerup


upgr_uac_attack        = 31; // distance attack               // t1
upgr_uac_uarmor        = 32; // base armor
upgr_uac_barmor        = 33; // base b armor
upgr_uac_melee         = 34; // repair/health upgr
upgr_uac_mspeed        = 35; // infantry speed
upgr_uac_painn         = 36; // expansive bullets
upgr_uac_buildr        = 37; // main sr
upgr_uac_CCFly         = 38; // CC fly
upgr_uac_ccturr        = 39; // CC turret
upgr_uac_extbuild      = 40; // main on doodabs
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
                                                    // HELL                UAC
upgr_race_armor_bio    : array[1..r_cnt] of byte    = (upgr_hell_uarmor  , upgr_uac_uarmor  );
upgr_race_armor_mech   : array[1..r_cnt] of byte    = (0                 , upgr_uac_mecharm );
upgr_race_armor_build  : array[1..r_cnt] of byte    = (upgr_hell_barmor  , upgr_uac_barmor  );
upgr_race_regen_bio    : array[1..r_cnt] of byte    = (upgr_hell_regen   , 0                );
upgr_race_regen_mech   : array[1..r_cnt] of byte    = (0                 , 0                );
upgr_race_regen_build  : array[1..r_cnt] of byte    = (upgr_hell_bldrep  , 0                );
upgr_race_mspeed_bio   : array[1..r_cnt] of byte    = (0                 , upgr_uac_mspeed  );
upgr_race_mspeed_mech  : array[1..r_cnt] of byte    = (0                 , upgr_uac_mechspd );
upgr_race_extbuilding  : array[1..r_cnt] of byte    = (upgr_hell_extbuild, upgr_uac_extbuild);
upgr_race_srange       : array[1..r_cnt] of byte    = (upgr_hell_vision  , upgr_uac_vision  );
upgr_race_srange_bonus : array[1..r_cnt] of integer = (25                , 25               );

////////////////////////////////////////////////////////////////////////////////
//
//  MISSILES
//

MID_Imp                = 101;
MID_Cacodemon          = 102;
MID_Baron              = 103;
MID_HRocket            = 104;
MID_Revenant           = 105;
MID_Mancubus           = 107;
MID_YPlasma            = 108;
MID_BPlasma            = 109;
MID_Bullet             = 110;
MID_SShot              = 114;
MID_SSShot             = 115;
MID_BFG                = 116;
MID_Granade            = 117;
MID_Tank               = 118;
MID_Blizzard           = 120;
MID_ArchFire           = 121;
MID_Flyer              = 122;
MID_Mine               = 123;
MID_URocket            = 124;
MID_URocketS           = 125;
MID_Chaingun           = 126;
MID_Chaingun2          = 127;


////////////////////////////////////////////////////////////////////////////////
//
//  UNITS
//

MaxUnits               = MaxPlayers*MaxPlayerUnits+MaxPlayerUnits;
MaxUnitWeapons         = 7;  //0-7
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
ul30                   = MinUnitLimit*30;
ul100                  = MinUnitLimit*100;
ul110                  = MinUnitLimit*110;

// production time
ptime1                 = 28;
ptimeh                 = ptime1 div 2;
ptimehh                = ptimeh div 2;
ptime2h3               = (ptime1 div 3)*2; //2/3
ptime1h                = ptime1+ptimeh;
ptime1hh               = ptime1+ptimehh;
ptime2                 = ptime1*2;
ptime3                 = ptime1*3;
ptime4                 = ptime1*4;
ptime5                 = ptime1*5;

uf_ground              = false;
uf_fly                 = true;

MaxUnitGroups          = 10;

mvxy_none              = 0;
mvxy_relative          = 1;
mvxy_strict            = 2;

BaseDamage1            = 62;
BaseDamageh            = BaseDamage1 div 2;
BaseDamage1h           = BaseDamage1+BaseDamageh;
BaseDamage2            = BaseDamage1*2;
BaseDamage3            = BaseDamage1*3;
BaseDamage4            = BaseDamage1*4;
BaseDamage8            = BaseDamage1*8;
BaseDamage10           = BaseDamage1*10;

BaseDamageBonus1       = 6;
BaseDamageBonush       = BaseDamageBonus1 div 2;
BaseDamageLevel1       = BaseDamageBonush;
BaseArmorBonus1        = 6;
BaseArmorBonush        = BaseArmorBonus1 div 2;
BaseArmorBonus2        = BaseArmorBonus1*2;
BaseArmorLevel1        = BaseArmorBonush;

BaseHeal1              = BaseDamageh;
BaseHealBonus1         = BaseDamageBonus1*2;
BaseRepair1            = BaseDamageh;
BaseRepairBonus1       = BaseDamageBonus1*3;

ExpLevel1              = fr_fps1*45;

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
UID_HPentagram         = 11;
UID_HTotem             = 12;
UID_HAltar             = 13;
UID_HFortress          = 14;
UID_HCommandCenter     = 15;
UID_HACommandCenter    = 16;
UID_HBarracks          = 17;

UID_LostSoul           = 20;
UID_Phantom            = 21;
UID_Imp                = 22;
UID_Demon              = 23;
UID_Cacodemon          = 24;
UID_Knight             = 25;
UID_Baron              = 26;
UID_Cyberdemon         = 27;
UID_Mastermind         = 28;
UID_Pain               = 29;
UID_Revenant           = 30;
UID_Mancubus           = 31;
UID_Arachnotron        = 32;
UID_Archvile           = 33;

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
UID_UNuclearPlant      = 62;
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

//T1                     = uids_marines+uids_zimbas+[UID_UTransport,UID_UACDron,UID_UGTurret,UID_UATurret,UID_LostSoul,UID_Imp,UID_Demon,UID_Cacodemon,UID_Knight,UID_Baron]-[UID_BFGMarine,UID_ZBFGMarine];
T2                     = [UID_BFGMarine,UID_Terminator,UID_Tank,UID_Flyer,UID_ZBFGMarine,UID_Cyberdemon,UID_Mastermind,UID_Pain,UID_Revenant,UID_Mancubus,UID_Arachnotron];
T3                     = [UID_Archvile,UID_HTotem,UID_URMStation,UID_HAltar];

uid_race_start_base    : array[1..r_cnt] of integer = (UID_HKeep    ,UID_UCommandCenter);

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
uab_HInvulnerability   = 8;
uab_SpawnLost          = 9;
uab_HellVision         = 10;
uab_CCFly              = 11;

client_rld_abils = [
                   uab_Teleport
                   ];
client_rld_uids  = [
                   UID_ArchVile
                   ];
client_cast_abils= [
                   uab_UACScan  ,
                   uab_UACStrike
                   ];

////////////////////////////////////////////////////////////////////////////////
//
//  OTHER
//


fr_mancubus_rld        = fr_fps2+fr_fpsd2;
fr_mancubus_rld_s1     = fr_fps2-fr_fpsd6;
fr_mancubus_rld_s2     = fr_fps1+fr_fpsd6;
fr_mancubus_rld_s3     = fr_fpsd2;

fr_archvile_s          = fr_fps1+fr_fpsd6;

NameLen                = 13;

dead_hits              = -ptime1*fr_fps1;
fdead_hits             = dead_hits+fr_fps3;
ndead_hits             = dead_hits-1;

fdead_hits_border      = -130;

base_r                 = 350;
base_rh                = base_r div 2;
base_ir                = base_r+(base_r div 2);
base_rr                = base_r*2;
base_3r                = base_r*3;
base_4r                = base_r*4;
base_6r                = base_r*6;

apc_exp_damage         = BaseDamage4;
regen_period           = fr_fps1*2;
order_period           = fr_fpsd2+1;
vistime                = order_period+2;

radar_reload           = fr_fps1*60;
radar_vision_time      = radar_reload-(fr_fps1*8);

hell_vision_time       = fr_fps1*8;

mstrike_reload         = fr_fps1*60;

step_build_reload      = fr_fps1*4;
max_build_reload       = step_build_reload*4;

melee_r                = 8;
mine_r                 = melee_r*3;

dir_stepX              : array[0..7] of integer = (1,1,0,-1,-1,-1,0,1);
dir_stepY              : array[0..7] of integer = (0,-1,-1,-1,0,1,1,1);

invuln_time            = fr_fps1*30;

tank_sr                = 20;
rocket_sr              = tank_sr*2;
mine_sr                = rocket_sr*2;
blizzard_sr            = rocket_sr*4;

bld_dec_mr             = 6;
player_default_ai_level= 7;
_mms                   = 126;
_d2shi                 = abs(dead_hits div 125)+1;   // 5

gm_cptp_gtime          = fr_fps1*ptimehh;
gm_cptp_time           = fr_fps1*ptimeh;
gm_cptp_r              = 100;
gm_cptp_energy         = 600;

fly_z                  = 80;
fly_hz                 = fly_z div 2;
fly_height             : array[false..true] of integer = (1,fly_z);

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
                                            SDLK_F5   , SDLK_SPACE, 0,
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
                                            SDLK_Z , SDLK_X , SDLK_0 ,

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


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITE DEPTH
//

// terrain
sd_liquid_back         = -32500;
sd_liquid              = -32000;
// neytral generators
sd_tcraters            = MaxSMapW+sd_liquid;    // -25000
// doodads
sd_brocks              = MaxSMapW+sd_tcraters;  // -18000
sd_srocks              = MaxSMapW+sd_brocks;    // -11000
sd_build               = MaxSMapW+sd_srocks;    // -4000
sd_ground              = MaxSMapW+sd_build;     //  3000
sd_fly                 = MaxSMapW+sd_ground;    //  10000
sd_marker              = MaxSMapW+sd_fly;       //  17000

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

ta_left                = 0;
ta_middle              = 1;
ta_right               = 2;
ta_chat                = 3;

font_w                 = 8;
font_hw                = font_w div 2;
font_iw                = font_w-1;
font_3hw               = font_w+(font_w div 2);
font_6hw               = font_3hw*2;

txt_line_h             = 5;
txt_line_h2            = 25-font_w;

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
vid_ab                 = 128;
vid_mvs                = 500; // max vis sprites;
vid_blink_persecond    = 6;
vid_blink_period1      = fr_fps1  div vid_blink_persecond;
vid_blink_periodh      = vid_blink_period1 div 2;
vid_blink_period2      = vid_blink_period1*2;

ui_alarm_time          = vid_blink_period2;

vid_BW                 = 48;
vid_2BW                = vid_BW*2;
vid_panelw             = vid_BW*3;
vid_tBW                = vid_panelw div 4;
vid_hBW                = vid_BW div 2;
vid_oiw                = 18;
vid_oihw               = vid_oiw+(vid_oiw div 2);
vid_oisw               = vid_oiw-(vid_oiw div 4);
vid_oips               = 2*vid_oiw+vid_oisw;
vid_svld_m             = 7;
vid_rpls_m             = 8;
vid_camp_m             = 11;

ui_max_alarms          = 12;

ui_bottomsy            = vid_BW*4;
ui_hwp                 = vid_panelw div 2;
ui_ubtns               = 23;

ui_menu_map_zx0        = 76;
ui_menu_map_zy0        = 110;
ui_menu_map_zx1        = 381;
ui_menu_map_zy1        = 289;
ui_menu_map_ys         = 19;
ui_menu_map_x0         = ((ui_menu_map_zx0+ui_menu_map_zx1) div 2)- vid_panelw;
ui_menu_map_y0         = ((ui_menu_map_zy0+ui_menu_map_zy1) div 2)-(vid_panelw div 2);
ui_menu_map_rx0        = ui_menu_map_x0+16+vid_panelw;
ui_menu_map_rx1        = ui_menu_map_zx1-12;
ui_menu_map_y1         = ui_menu_map_y0+(ui_menu_map_ys*7);
ui_menu_map_tx0        = ui_menu_map_rx0+6;
ui_menu_map_tx1        = ui_menu_map_rx0+((ui_menu_map_rx1-ui_menu_map_rx0) div 2);

ui_menu_ssr_x0         = 76;
ui_menu_ssr_y0         = 326;
ui_menu_ssr_x1         = 381;
ui_menu_ssr_y1         = 523;
ui_menu_ssr_xs         = 102;
ui_menu_ssr_xhs        = ui_menu_ssr_xs div 2;
ui_menu_ssr_xhhs       = ui_menu_ssr_xhs div 2;
ui_menu_ssr_ys         = 18;
ui_menu_ssr_barl       = 127;
ui_menu_ssr_x3         = ui_menu_ssr_x1-10;
ui_menu_ssr_x2         = ui_menu_ssr_x3-ui_menu_ssr_barl;
ui_menu_ssr_x4         = ui_menu_ssr_x0+ui_menu_ssr_xs;
ui_menu_ssr_x5         = ui_menu_ssr_x0+ui_menu_ssr_xs*2;
ui_menu_ssr_x6         = ui_menu_ssr_x5+ui_menu_ssr_xhs;
ui_menu_ssr_x7         = ui_menu_ssr_x3-ui_menu_ssr_barl;
ui_menu_ssr_x7t        = ui_menu_ssr_x7-font_w;
ui_menu_ssr_x7r        = ui_menu_ssr_x7+font_w;
ui_menu_ssr_xt0        = ui_menu_ssr_x6-ui_menu_ssr_xhhs;
ui_menu_ssr_xt1        = ui_menu_ssr_x6+ui_menu_ssr_xhhs;
ui_menu_ssl_x0         = (ui_menu_ssr_x0+ui_menu_ssr_x1) div 2;

ui_menu_pls_x0         = 418;
ui_menu_pls_y0         = 110;
ui_menu_pls_x1         = 723;
ui_menu_pls_y1         = 253;
ui_menu_pls_ys         = 18;
ui_menu_pls_zh         = (MaxPlayers*ui_menu_pls_ys);
ui_menu_pls_xc         = (ui_menu_pls_x0+ui_menu_pls_x1) div 2;
ui_menu_pls_zy0        = ((ui_menu_pls_y0+ui_menu_pls_y1) div 2)-(ui_menu_pls_zh div 2);
ui_menu_pls_zy1        = ui_menu_pls_zy0+ui_menu_pls_zh;
ui_menu_pls_zxn        = ui_menu_pls_x0+16;   // name
ui_menu_pls_zxs        = ui_menu_pls_zxn+130; // status
ui_menu_pls_zxr        = ui_menu_pls_zxs+24;  // race
ui_menu_pls_zxt        = ui_menu_pls_zxr+64;  // team
ui_menu_pls_zxc        = ui_menu_pls_zxt+24;  // color box
ui_menu_pls_zxe        = ui_menu_pls_x1-16;
ui_menu_pls_zxnt       =  ui_menu_pls_zxn+6;
ui_menu_pls_zxst       = (ui_menu_pls_zxs+ui_menu_pls_zxr) div 2;
ui_menu_pls_zxrt       = (ui_menu_pls_zxr+ui_menu_pls_zxt) div 2;
ui_menu_pls_zxtt       = (ui_menu_pls_zxt+ui_menu_pls_zxc) div 2;
ui_menu_pls_zxc1       = ui_menu_pls_zxc+8;
ui_menu_pls_zxc2       = ui_menu_pls_zxe-8;

ui_menu_csm_x0         = 418;
ui_menu_csm_y0         = 290;
ui_menu_csm_x1         = 723;
ui_menu_csm_y1         = 522;
ui_menu_csm_xs         = 102;
ui_menu_csm_xhs        = ui_menu_csm_xs div 2;
ui_menu_csm_ys         = 18;
ui_menu_csm_2ys        = ui_menu_csm_ys*2;
//ui_menu_csm_yhs        = ui_menu_csm_ys div 2;
ui_menu_csm_ycs        = 10;
ui_menu_csm_xct        = ui_menu_csm_x0+2;
ui_menu_csm_xc         = (ui_menu_csm_x0+ui_menu_csm_x1) div 2;
ui_menu_csm_x2         = ui_menu_csm_x0+ui_menu_csm_xs;
ui_menu_csm_x3         = ui_menu_csm_x2+ui_menu_csm_xs;
ui_menu_csm_xt0        = ui_menu_csm_x0+8;
ui_menu_csm_xt1        = ui_menu_csm_x0+24;
ui_menu_csm_xt2        = ui_menu_csm_x1-8;
ui_menu_csm_xt3        = ui_menu_csm_xc+8;


chat_type              : array[false..true] of char = ('|',' ');
chat_shlm_t            = fr_fps1*3;
chat_shlm_max          = chat_shlm_t*6;

ui_menu_chat_height    = 13; // lines
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

sss_sssize             : array[0..sss_count-1] of integer = (1,12,1,3,1,1);

////////////////////////////////////////////////////////////////////////////////
//
//  SAVE/LOAD/REPLAY
//

rpls_file_none         = 0;
rpls_file_write        = 1;
rpls_file_read         = 2;

rpl_none               = 0;
rpl_whead              = 1;
rpl_wunit              = 2;
rpl_rhead              = 3;
rpl_runit              = 4;
rpl_end                = 5;

SvRpLen                = 15;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

MFogM                  = 64;
fog_cw                 = 32;
fog_chw                = fog_cw div 2;
fog_cr                 = round(fog_chw*1.45);
//fog_cxr                = fog_cr-fog_chw;
fog_vfwm               = (vid_maxw div fog_cw)+2;
fog_vfhm               = (vid_maxh div fog_cw)+2;

////////////////////////////////////////////////////////////////////////////////
//
//  MENU
//

ms1_sett               = 0;
ms1_svld               = 1;
ms1_reps               = 2;

ms2_camp               = 0;
ms2_scir               = 1;
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
str_loading            : shortstring = 'LOADING...'+#0;
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

b2cc                   : array[false..true] of string[3] = (tc_red+'-'+tc_default,tc_lime+'+'+tc_default);

////////////////////////////////////////////////////////////////////////////////
//
//  INPUT
//

k_chrtt                = fr_fps1 div 3;
k_kbstr                : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','[',']','{','}',' ','_',',','.','(',')','<','>','-','+','`','@','#','%','?',':','$'];
k_kbdig                : set of Char = ['0'..'9'];
k_kbaddr               : set of Char = ['0'..'9','.',':'];

////////////////////////////////////////////////////////////////////////////////
//
//  MAP THEME
//

LiquidAnim             = 4;
LiquidRs               = 4;

crater_ri              = 4;
crater_r               : array[1..crater_ri] of integer = (33,60,88,110);

theme_n                = 8;
theme_name             : array[0..theme_n-1] of shortstring = (tc_lime  +'TECH BASE'  ,
                                                               tc_blue  +'TECH BASE'  ,
                                                               tc_white +'PLANET'     ,
                                                               tc_white +'PLANET MOON',
                                                               tc_gray  +'CAVES'      ,
                                                               tc_aqua  +'ICE CAVES'  ,
                                                               tc_orange+'HELL'       ,
                                                               tc_yellow+'HELL CAVES' );

{$ELSE }


str_gnstarted            : shortstring = 'Not started';
str_grun                 : shortstring = 'Run';
str_gpaused              : shortstring = 'Paused by player #';
str_udpport              : shortstring = ' UPD port: ';
str_gstatus              : shortstring = 'Game status:   ';
str_gsettings            : shortstring = 'Game settings:';
str_map                  : shortstring = 'Map';

str_m_seed               : shortstring = 'Seed';
str_m_liq                : shortstring = 'Lakes';
str_m_siz                : shortstring = 'Size';
str_m_obs                : shortstring = 'Obstacles';
str_m_sym                : shortstring = 'Symmetry';
str_aislots              : shortstring = 'Fill empty slots:         ';
str_fstarts              : shortstring = 'Fixed player starts:      ';
str_gmodet               : shortstring = 'Game mode:                ';
str_cgenerators          : shortstring = 'Neutral generators:       ';
str_deadobservers        : shortstring = 'Observer mode after lose: ';
str_starta               : shortstring = 'Builders at game start:   ';
str_plname               : shortstring = 'Player name';
//str_plout                : shortstring = ' left the game';
//str_player_def           : shortstring = ' was terminated!';

str_cgeneratorsM         : array[0..5] of shortstring = ('none','5 min','10 min','15 min','20 min','infinity');

str_plstat               : shortstring = 'State';
str_team                 : shortstring = 'Team';
str_srace                : shortstring = 'Race';
//str_ready                : shortstring = 'Ready';

str_race                 : array[0..r_cnt       ] of shortstring = ('RANDOM','HELL','UAC');
str_gmode                : array[0..gm_cnt      ] of shortstring = ('Skirmish','Two bases','Three bases','Capturing points','Invasion','Assault','Royal Battle');
str_observer             : shortstring = 'OBSERVER';

{$ENDIF}



