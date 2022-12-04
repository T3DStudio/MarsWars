
const

ver                    : byte = 230;

degtorad               = pi/180;

////////////////////////////////////////////////////////////////////////////////
//
//  FRAME RATE
//

fr_fps                 = 60;
fr_2hfps               = fr_fps div 2;
fr_3hfps               = fr_fps div 3;
fr_4hfps               = fr_fps div 4;
fr_5hfps               = fr_fps div 5;
fr_6hfps               = fr_fps div 6;
fr_7hfps               = fr_fps div 7;
fr_8hfps               = fr_fps div 8;
fr_2h3fps              = fr_2hfps*3;   //1,5
fr_2fps                = fr_fps*2;
fr_3fps                = fr_fps*3;
fr_4fps                = fr_fps*4;
fr_5fps                = fr_fps*5;
fr_3h2fps              = fr_3hfps*2; //2/3
fr_4h3fps              = fr_4hfps*3; //3/4
fr_mpt                 = trunc(1000/fr_fps);

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
gs_win_team            = 20;

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
str_cprt               : shortstring = '[ T3DStudio (c) 2016-2022 ]';
str_ps_c               : array[0..2] of char = ('-','P','C');
str_ps_t               : char = '?';
str_ps_h               : char = '<';
str_ps_comp            : shortstring = 'AI';
str_ps_none            : shortstring = '--';
b2c                    : array[false..true] of char = ('-','+');

outlogfn               : shortstring = 'out.txt';


////////////////////////////////////////////////////////////////////////////////
//
//  Game settings borders
//

gms_g_startb           = 6;  // 0-6  max start base options
gms_g_maxai            = 11; // 0-11 max skirmish AI skills
gms_g_maxgens          = 5;  // 0-5  max neytrall generators options


////////////////////////////////////////////////////////////////////////////////
//
//  CPoints life
//

g_cgenerators_ltime    : array[0..gms_g_maxgens] of cardinal = (0,fr_fps*60*5,fr_fps*60*10,fr_fps*60*15,fr_fps*60*20,0);

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
lmt_player_chat        = 255;

lmts_menu_chat         = [0..MaxPlayers,lmt_game_message,lmt_game_end,lmt_player_defeated,lmt_player_leave,lmt_player_chat];
lmts_last_messages     = [0..255];

glcp_unit              = 0;
glcp_upgr              = 1;
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

ClientTTL              = fr_fps*10;

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

ureq_unitlimit         : cardinal = %0000000000000001;
ureq_ruid              : cardinal = %0000000000000010;
ureq_rupid             : cardinal = %0000000000000100;
ureq_energy            : cardinal = %0000000000001000;
ureq_time              : cardinal = %0000000000010000;
ureq_max               : cardinal = %0000000001000000;
ureq_builders          : cardinal = %0000000010000000; // need builders
ureq_bld_r             : cardinal = %0000000100000000;
ureq_barracks          : cardinal = %0000001000000000; // need barracks
ureq_smiths            : cardinal = %0000010000000000; // need smith
ureq_product           : cardinal = %0000100000000000; // already in production
ureq_armylimit         : cardinal = %0001000000000000;
ureq_place             : cardinal = %0010000000000000; // cant build here
ureq_busy              : cardinal = %0100000000000000; // production is busy
ureq_unknown           : cardinal = %1000000000000000; //

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
wpr_tvis               : cardinal =  %0000000000010000;
wpr_ground             : cardinal =  %0000000000100000;
wpr_air                : cardinal =  %0000000001000000;
wpr_move               : cardinal =  %0000000010000000;

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
//  UNIT ABILITIES
//

uab_teleport           = 1;
uab_building_adv       = 4;
uab_radar              = 5;
uab_htowertele         = 6;
uab_uac_rstrike        = 7;
uab_hkeeptele          = 8;
uab_rebuild            = 9;
uab_buildturret        = 10;
uab_hinvuln            = 11;
uab_spawnlost          = 13;
uab_hell_vision        = 14;
uab_advance            = 15;
uab_prodlevelup        = 16;

client_rld_abils = [
                   uab_teleport     ,
                   uab_building_adv ,
                   uab_hell_vision
                   ];
client_cast_abils= [
                   uab_radar,
                   uab_uac_rstrike
                   ];

////////////////////////////////////////////////////////////////////////////////
//
//  UNIT BUFFs
//

MaxUnitBuffs           = 15;

ub_pain                = 1;
ub_resur               = 2;
ub_cast                = 3;
ub_slooow              = 4;
ub_clcast              = 5;
ub_invis               = 6;
ub_detect              = 7;
ub_invuln              = 8;
ub_summoned            = 9;
ub_teleeff             = 10;
ub_hvision             = 11;
ub_damaged             = 12;
ub_heal                = 13;

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

DID_R                  : array[0..7] of integer = (0,250,185,125,64,105,60,17);


////////////////////////////////////////////////////////////////////////////////
//
//  UPGRADES
//

upgr_hell_dattack      = 1;  // distance attacks damage    // t1
upgr_hell_uarmor       = 2;  // base unit armor
upgr_hell_barmor       = 3;  // base building armor
upgr_hell_mattack      = 4;  // melee attack damage
upgr_hell_regen        = 5;  // regeneration
upgr_hell_pains        = 6;  // pain state
upgr_hell_towers       = 7;  // towers range
upgr_hell_HKTeleport   = 8;  // HK teleportation
upgr_hell_paina        = 9;  // decay aura
upgr_hell_buildr       = 10; // main range
upgr_hell_hktdoodads   = 11; // HK on doodabs
upgr_hell_pinkspd      = 12; // demon move speed

upgr_hell_spectre      = 13; // demon spectre              // t2
upgr_hell_vision       = 14; // demons vision
upgr_hell_phantoms     = 15; // demons vision
upgr_hell_teleport     = 16; // Teleport reload
upgr_hell_rteleport    = 17; // revers teleport
upgr_hell_heye         = 18; // hell Eye time
upgr_hell_9bld         = 19; // 9 class building reload time
upgr_hell_totminv      = 20; // totem and eye invisible
upgr_hell_bldrep       = 21; // build restoration
upgr_hell_b478tel      = 22; // teleport towers
upgr_hell_resurrect    = 23; // archvile ability
upgr_hell_invuln       = 24; // hell invuln powerup


upgr_uac_attack        = 31; // distance attack            // t1
upgr_uac_uarmor        = 32; // base armor
upgr_uac_barmor        = 33; // base b armor
upgr_uac_melee         = 34; // repair/health upgr
upgr_uac_mspeed        = 35; // infantry speed
upgr_uac_jetpack       = 36; // jetpack for plasmagunner
upgr_uac_towers        = 37; // towers sr
upgr_uac_mainm         = 38; // CC fly
upgr_uac_ccturr        = 39; // CC turret
upgr_uac_buildr        = 40; // main sr
upgr_uac_ccldoodads    = 41; // main on doodabs
upgr_uac_float         = 42; // UACBot floating

upgr_uac_botturret     = 43; // bot turret                 // t2
upgr_uac_vision        = 44; // infatry vision
upgr_uac_commando      = 45; // commando invis
upgr_uac_airsp         = 46; // anti-air missiles splash
upgr_uac_mechspd       = 47; // mech speed
upgr_uac_mecharm       = 48; // mech arm
upgr_uac_lturret       = 49; // flyer laser turret
upgr_uac_radar_r       = 50; // Radar
upgr_uac_9bld          = 51; // 9 class building reload time
upgr_uac_plasmt        = 52; // plasma weapons fro anti-ground turret
upgr_uac_turarm        = 53; // turrets armor
upgr_uac_rstrike       = 54; // rstrike launch


upgr_fog_vision        = 249;
upgr_fast_build        = 250;
upgr_fast_product      = 251;
upgr_mult_product      = 252;
upgr_invuln            = 255;
                                                 // HELL               UAC
upgr_race_bio_armor    : array[1..r_cnt] of byte = (upgr_hell_uarmor , upgr_uac_uarmor );
upgr_race_mech_armor   : array[1..r_cnt] of byte = (0                , upgr_uac_mecharm);
upgr_race_build_armor  : array[1..r_cnt] of byte = (upgr_hell_barmor , upgr_uac_barmor );
upgr_race_bio_regen    : array[1..r_cnt] of byte = (upgr_hell_regen  , 0               );
upgr_race_mech_regen   : array[1..r_cnt] of byte = (0                , 0               );
upgr_race_build_regen  : array[1..r_cnt] of byte = (upgr_hell_bldrep , 0               );
upgr_race_bio_mspeed   : array[1..r_cnt] of byte = (0                , upgr_uac_mspeed );
upgr_race_mech_mspeed  : array[1..r_cnt] of byte = (0                , upgr_uac_mechspd);

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


////////////////////////////////////////////////////////////////////////////////
//
//  UNITS
//

MaxUnits               = MaxPlayers*MaxPlayerUnits+MaxPlayerUnits;
MaxUnitWeapons         = 7;  //0-7
MaxUnitLevel           = 3;  //0-3
MaxMissiles            = MaxUnits;

ul1                    = MinUnitLimit;
ul1hh                  = MinUnitLimit+(MinUnitLimit div 4);
ul1h                   = MinUnitLimit+(MinUnitLimit div 2);
ul2                    = MinUnitLimit*2;
ul3                    = MinUnitLimit*3;
ul4                    = MinUnitLimit*4;
ul5                    = MinUnitLimit*5;
ul10                   = MinUnitLimit*10;
ul12                   = MinUnitLimit*12;
ul20                   = MinUnitLimit*20;
ul30                   = MinUnitLimit*30;
ul100                  = MinUnitLimit*100;
ul110                  = MinUnitLimit*110;

uf_ground              = false;
uf_fly                 = true;

MaxUnitGroups          = 10;

mvxy_none              = 0;
mvxy_relative          = 1;
mvxy_strict            = 2;

BaseDamage1            = 70;
BaseDamageh            = BaseDamage1 div 2;
BaseDamagehh           = BaseDamage1 div 4;
BaseDamage1hh          = BaseDamage1+BaseDamagehh;
BaseDamage1h           = BaseDamage1+BaseDamageh;
BaseDamage2            = BaseDamage1*2;
BaseDamage3            = BaseDamage1*3;
BaseDamage4            = BaseDamage1*4;
BaseDamage5            = BaseDamage1*5;
BaseDamage10           = BaseDamage1*10;
BaseDamage20           = BaseDamage1*20;

BaseDamageBonus1       = 6;
BaseDamageLevel1       = BaseDamageBonus1 div 2;
BaseArmorBonus1        = 6;
BaseArmorBonush        = BaseArmorBonus1 div 2;
BaseArmorBonus1h       = BaseArmorBonus1+BaseArmorBonush;
BaseArmorLevel1        = BaseArmorBonush;

BaseHeal1              = BaseDamageh;
BaseHealBonus1         = BaseDamageBonus1*2;
BaseRepair1            = BaseDamageh;
BaseRepairBonus1       = BaseDamageBonus1*3;

ExpLevel1              = fr_fps*45;

////////////////////////////////////////////////////////////////////////////////
//
//  UIDs
//

// HELL

UID_HKeep              = 1;
UID_HGate              = 2;
UID_HSymbol            = 3;
UID_HASymbol           = 4;
UID_HPools             = 5;
UID_HTower             = 6;
UID_HTeleport          = 7;
UID_HEye               = 8;
UID_HMonastery         = 9;
UID_HTotem             = 10;
UID_HAltar             = 11;
UID_HFortress          = 12;
UID_HCommandCenter     = 13;
UID_HBarracks          = 14;

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
UID_ZSiege             = 40;
UID_ZMajor             = 41;
UID_ZFMajor            = 42;
UID_ZBFG               = 43;

// UAC

UID_UCommandCenter     = 50;
UID_UBarracks          = 51;
UID_UFactory           = 52;
UID_UGenerator         = 53;
UID_UAGenerator        = 54;
UID_UWeaponFactory     = 55;
UID_URadar             = 56;
UID_URMStation         = 57;
UID_UTechCenter        = 58;
UID_UGTurret           = 59;
UID_UATurret           = 60;
UID_UNuclearPlant      = 61;
UID_UMine              = 62;

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
UID_Siege              = 86;
UID_Major              = 87;
UID_FMajor             = 88;
UID_BFG                = 89;
UID_FAPC               = 90;
UID_UACBot             = 91;
UID_Terminator         = 92;
UID_Tank               = 93;
UID_Flyer              = 94;
UID_APC                = 95;
UID_UTransport         = 96;


uids_hell              = [1 ..49];
uids_uac               = [50..99];

uids_marines           = [UID_Engineer ,UID_Medic   ,UID_Sergant ,UID_SSergant ,UID_Commando ,UID_Antiaircrafter ,UID_Siege , UID_Major, UID_FMajor ,UID_BFG ];
uids_zimbas            = [UID_ZEngineer,UID_ZFormer ,UID_ZSergant,UID_ZSSergant,UID_ZCommando,UID_ZAntiaircrafter,UID_ZSiege, UID_ZMajor,UID_ZFMajor,UID_ZBFG];
uids_arch_res          = [UID_Imp,UID_Demon,UID_Cacodemon,UID_Knight,UID_Baron,UID_Revenant,UID_Mancubus,UID_Arachnotron]+uids_zimbas;
uids_demons            = [UID_LostSoul..UID_Archvile]+uids_zimbas;
uids_all               = [0..255];
//uids_coopspawn         = marines+demons+[UID_UACBot,UID_Terminator,UID_Tank,UID_Flyer];

uid_race_start_base    : array[1..r_cnt] of integer = (UID_HKeep    ,UID_UCommandCenter);
uid_race_9bld          : array[1..r_cnt] of integer = (UID_HFortress,UID_UNuclearPlant );


////////////////////////////////////////////////////////////////////////////////
//
//  OTHER
//


fr_mancubus_rld        = fr_2fps+fr_2hfps;
fr_mancubus_rld_s1     = fr_2fps-fr_6hfps;
fr_mancubus_rld_s2     = fr_fps +fr_6hfps;
fr_mancubus_rld_s3     = fr_2hfps;

fr_archvile_s          = fr_fps +fr_6hfps;

NameLen                = 13;
//ChatLen                = 38;

dead_hits              = -25*fr_fps;
fdead_hits             = dead_hits+fr_5fps;
ndead_hits             = dead_hits-1;

fdead_hits_border      = -130;

base_r                 = 350;
base_ir                = base_r+(base_r div 2);
base_rr                = base_r*2;
base_3r                = base_r*3;
base_4r                = base_r*4;
base_6r                = base_r*6;

apc_exp_damage         = BaseDamage4;
regen_period           = fr_fps*2;
order_period           = fr_2hfps+1;
vistime                = order_period+2;

radar_reload           = fr_fps*60;
radar_vision_time      = radar_reload-(fr_fps*8);

hell_vision_time       = fr_fps*8;

mstrike_reload         = fr_fps*30;

step_build_reload      = fr_fps*3;
max_build_reload       = step_build_reload*5;

melee_r                = 8;
mine_r                 = melee_r*3;

dir_stepX              : array[0..7] of integer = (1,1,0,-1,-1,-1,0,1);
dir_stepY              : array[0..7] of integer = (0,-1,-1,-1,0,1,1,1);

building_adv_reload    : array[false..true] of integer = (fr_fps*45,0);

invuln_time            = fr_fps*30;

tank_sr                = 20;
rocket_sr              = tank_sr*2;
mine_sr                = rocket_sr*2;
blizzard_sr            = rocket_sr*4;

bld_dec_mr             = 6;
player_default_ai_level= 7;
_mms                   = 126;
_d2shi                 = abs(dead_hits div 125)+1;   // 5

gm_cptp_time           = fr_fps*20;
gm_cptp_r              = 100;

fly_z                  = 80;
fly_hz                 = fly_z div 2;
fly_height             : array[false..true] of integer = (1,fly_z);

pain_time              = order_period;

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

_hotkeyA : array[0.._mhkeys] of cardinal = (SDLK_Q    , SDLK_W , SDLK_SPACE ,
                                            SDLK_A    , SDLK_S , SDLK_D ,
                                            SDLK_Z    , SDLK_X , SDLK_C ,

                                            SDLK_C    , SDLK_F2, SDLK_Delete,
                                            0         , 0      , 0,
                                            0         , 0      , 0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);
_hotkeyA2: array[0.._mhkeys] of cardinal = (0 , 0 , SDLK_LCtrl ,
                                            0 , 0 , 0 ,
                                            0 , 0 , 0 ,

                                            SDLK_LCtrl , 0, 0,
                                            0 , 0, 0,
                                            0 , 0, 0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);

_hotkeyR : array[0.._mhkeys] of cardinal = (SDLK_Q , SDLK_W , SDLK_E ,
                                            SDLK_A , SDLK_S , SDLK_D ,
                                            SDLK_Z , SDLK_X , SDLK_C ,

                                            SDLK_R , SDLK_T , SDLK_Y ,
                                            SDLK_F , SDLK_G , SDLK_H ,
                                            0,0,0,

                                            0,0,0,
                                            0,0,0,
                                            0,0,0);
_hotkeyR2: array[0.._mhkeys] of cardinal = (0 , 0 , 0 ,
                                            0 , 0 , 0 ,
                                            0 , 0 , 0 ,

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

ChatLen2               = 255;
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
sd_tcraters            = MaxSMapW+sd_liquid;
// doodads
sd_brocks              = MaxSMapW+sd_tcraters;
sd_srocks              = MaxSMapW+sd_brocks;
sd_ground              = MaxSMapW+sd_srocks;
sd_fly                 = MaxSMapW+sd_ground;
sd_marker              = MaxSMapW+sd_fly;

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
EID_HKT_h              = 207;
EID_HKT_s              = 208;
EID_db_h0              = 209;
EID_db_h1              = 210;
EID_db_u0              = 211;
EID_db_u1              = 212;
EID_Blood              = 213;
EID_ArchFire           = 214;
EID_ULevelUp           = 215;
EID_HLevelUp           = 216;
EID_HVision            = 217;
EID_Invuln             = 218;
EID_HAMU               = 219;
EID_HMU                = 220;
EID_HCC                = 221;

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

////////////////////////////////////////////////////////////////////////////////
//
//  VIDEO & UI
//

fr_ifps                = fr_fps-1;

vid_bpp                = 32;
vid_minw               = 800;
vid_minh               = 600;
vid_maxw               = 1360;
vid_maxh               = 768;
vid_ab                 = 128;
vid_mvs                = 500; // max vis sprites;
vid_rtuir              = 6;
vid_rtuis              = fr_fps div vid_rtuir;
vid_rtuish             = vid_rtuis div 2;
vid_uialrm_t           = fr_2fps div vid_rtuir;
//vid_uialrm_ti          = vid_uialrm_t div 4;

//vid_uialrm_mr          = vid_uialrm_t-(vid_uialrm_t div 3);
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

chat_type              : array[false..true] of char = ('|',' ');
chat_shlm_t            = fr_fps*3;
chat_shlm_max          = chat_shlm_t*5;

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

//svld_size              = 791345;
rpl_hsize              = 1575;

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
tc_default             = #25;

b2cc                   : array[false..true] of string[3] = (tc_red+'-'+tc_default,tc_lime+'+'+tc_default);

////////////////////////////////////////////////////////////////////////////////
//
//  INPUT
//

k_chrtt                = fr_fps div 3;
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
str_aislots              : shortstring = 'Fill empty slots:   ';
str_sstarts              : shortstring = 'Show player starts: ';
str_gmodet               : shortstring = 'Game mode:          ';
str_cgenerators          : shortstring = 'Neutral generators: ';
str_starta               : shortstring = 'Starting base:      ';
str_plname               : shortstring = 'Player name';
str_plout                : shortstring = ' left the game';
str_player_def           : shortstring = ' was terminated!';

str_cgeneratorsM         : array[0..5] of shortstring = ('none','5 min','10 min','15 min','20 min','infinity');

str_plstat               : shortstring = 'State';
str_team                 : shortstring = 'Team';
str_srace                : shortstring = 'Race';
str_ready                : shortstring = 'Ready';

str_startat              : array[0..gms_g_startb] of shortstring = ('1 builder','2 builders','3 builders','4 builders','5 builders','6 builders','7 builders');
str_race                 : array[0..r_cnt       ] of shortstring = ('RANDOM','HELL','UAC');
str_gmode                : array[0..gm_cnt      ] of shortstring = ('Skirmish','Two bases','Three bases','Capturing points','Invasion','Assault','Royal Battle');
str_addon                : array[false..true    ] of shortstring = ('UDOOM','DOOM 2');


{$ENDIF}



