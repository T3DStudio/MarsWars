
const

ver                    : byte = 225;

degtorad               = pi/180;

vid_fps                = 60;
vid_hfps               = vid_fps div 2;
vid_hhfps              = vid_hfps div 2;
vid_2fps               = vid_fps*2;
vid_3fps               = vid_fps*3;
vid_mpt                = trunc(1000/vid_fps)-1;

NameLen                = 13;
ChatLen                = 38;

ns_none                = 0;
ns_srvr                = 1;
ns_clnt                = 2;

ps_none                = 0;
ps_play                = 1;
ps_comp                = 2;

gm_scir                = 0;
gm_2fort               = 1;
gm_3fort               = 2;
gm_ct                  = 3;
gm_inv                 = 4;
gm_coop                = 5;

r_random               = 0;
r_hell                 = 1;
r_uac                  = 2;

uf_ground              = 0;
uf_soaring             = 1;
uf_fly                 = 2;

NetTickN               = 2;

MaxPlayers             = 6;
MaxPlayerUnits         = 110;
MaxDoodads             = 650;
MaxUnits               = MaxPlayers*MaxPlayerUnits+MaxPlayerUnits;
MaxNetChat             = 16;
MaxNetBuffer           = 4096;
MaxSMapW               = 7000;
MinSMapW               = 3000;

ddc_div                = 1000000;
ddc_cf                 = (MaxSMapW*MaxSMapW) div ddc_div;

dcw                    = 200;
dcn                    = MaxSMapW div dcw;

build_b                = 5;

_uts                   = 31;         //0-31
_utsh                  = _uts div 2; //0-15
_ubuffs                = 15;
MaxUpgrs               = 23;

_pnua                  : array[0..9] of byte = (55,75,95,115,135,155,175,195,215,235);

ClientTTL              = vid_fps*10;

outlogfn               : shortstring = 'out.txt';
str_ver                = 'v49';
str_wcaption           : shortstring = 'The Ultimate MarsWars '+str_ver+#0;
str_cprt               : shortstring = '[ T3DStudio (c) 2016-2020 ]';
str_ps_c               : array[0..2] of char = ('-','P','C');
str_ps_t               : char = '?';
str_ps_comp            : shortstring = 'AI';
str_ps_h               : char = '<';
str_ps_none            : shortstring = '--';
b2pm                   : array[false..true] of string[3] = (#15+'-'+#25,#18+'+'+#25);
_str_mx                : array[0..12] of shortstring = ('-','x1','x2','x3','x4','x5','x6','x7','x8','x9','x10','x11','x12');

nmid_startinf          = 3;
nmid_connect           = 4;
nmid_clinf             = 5;
nmid_chat              = 6;
nmid_chatclupd         = 7;
nmid_shap              = 8;
nmid_pause             = 9;
nmid_sfull             = 10;
nmid_sver              = 11;
nmid_sgst              = 12;
nmid_ncon              = 13;
nmid_swapp             = 14;
nmid_order             = 15;
nmid_plout             = 16;
nmid_getinfo           = 66;

uo_build               = 1;
uo_dblselect           = 2;
uo_adblselect          = 3;
uo_select              = 4;
uo_aselect             = 5;
uo_selorder            = 6;
uo_setorder            = 7;
uo_move                = 8;
uo_delete              = 9;
uo_action              = 10;
uo_specsel             = 11;
uo_addorder            = 12;

ua_move                = 1;
ua_amove               = 2;
ua_hold                = 3;
ua_unload              = 4;

ub_advanced            = 0;
ub_pain                = 1;
ub_toxin               = 2;
ub_gear                = 3;
ub_resur               = 4;
ub_cast                = 5;
ub_stopafa             = 6;
ub_slooow              = 7;
ub_clcast              = 8;
ub_invis               = 9;
ub_detect              = 10;
ub_invuln              = 11;
ub_notarget            = 12;
ub_born                = 13;
ub_cnttrans            = 14;
ub_teleeff             = 15;

_bufinf                = 32000;


DID_LiquidR1           = 1;
DID_LiquidR2           = 2;
DID_LiquidR3           = 3;
DID_LiquidR4           = 4;
DID_BRock              = 5;
DID_SRock              = 6;
DID_Other              = 7;

dids_liquids           = [DID_LiquidR1..DID_LiquidR4];

DID_R                  : array[0..7] of integer = (0,65,125,185,250,100,60,17);

upgr_attack            = 0;  // distance attack
upgr_armor             = 1;  // base armor
upgr_build             = 2;  // base b armor
upgr_melee             = 3;  // melee attack / repair/health upgr

upgr_regen             = 4;  // hell
upgr_mspeed            = 4;  // uac

upgr_pains             = 5;  // pain state
upgr_plsmt             = 5;  // plasma turrent for turret and apcs

upgr_vision            = 6;  // detectors

upgr_towers            = 7;  // towers sr

upgr_5bld              = 8;  // Teleport/Radar
upgr_mainm             = 9;  // Main b move

upgr_ucomatt           = 10; // CC turret
upgr_paina             = 10; // decay aura

upgr_mainr             = 11; // main sr

upgr_pinkspd           = 12; // demon speed
upgr_mines             = 12; // mines for engineers

upgr_misfst            = 13; // missiles fast
upgr_minesen           = 13; // mine-sensor

upgr_6bld              = 14; // Souls / adv

upgr_2tier             = 15; // Tier 2

upgr_revtele           = 16; // revers teleport
upgr_blizz             = 16; // blizzard launch

upgr_revmis            = 17; // revenant missile
upgr_mechspd           = 17; // mech speed

upgr_mecharm           = 18; // mech arm
upgr_totminv           = 18; // totem and eye invisible

upgr_6bld2             = 19; // 6bld upgr
upgr_bldrep            = 19; // build repair

upgr_mainonr           = 20; // main on doodabs

upgr_b478tel           = 21; // teleport towers and altars
upgr_turarm            = 21; // turrets armor

upgr_hinvuln           = 22; // hell invuln powerup
upgr_rturrets          = 22; // rocket turrets

upgr_bldenrg           = 23; // additional energy

upgr_prodatm           = 24; // 9 class building reload time

upgr_advbld            = 28;
upgr_advbar            = 29;

upgr_invuln            = 31;


MID_Imp                = 101;
MID_Cacodemon          = 102;
MID_Baron              = 103;
MID_HRocket            = 104;
MID_Revenant           = 105;
MID_RevenantS          = 106;
MID_Mancubus           = 107;
MID_YPlasma            = 108;
MID_BPlasma            = 109;
MID_Bullet             = 110;
MID_Bulletx2           = 111;
MID_TBullet            = 112;
MID_MBullet            = 113;
MID_SShot              = 114;
MID_SSShot             = 115;
MID_BFG                = 116;
MID_Granade            = 117;
MID_Tank               = 118;
MID_Mine               = 119;
MID_Blizzard           = 120;
MID_ArchFire           = 121;
MID_Flyer              = 122;


UID_LostSoul           = 1;
UID_Imp                = 2;
UID_Demon              = 3;
UID_Cacodemon          = 4;
UID_Baron              = 5;
UID_Cyberdemon         = 6;
UID_Mastermind         = 7;
UID_Pain               = 8;
UID_Revenant           = 9;
UID_Mancubus           = 10;
UID_Arachnotron        = 11;
UID_Archvile           = 12;
UID_ZFormer            = 13;
UID_ZEngineer          = 14;
UID_ZSergant           = 15;
UID_ZCommando          = 16;
UID_ZBomber            = 17;
UID_ZMajor             = 18;
UID_ZBFG               = 19;
UID_HEye               = 20;


UID_Engineer           = 31;
UID_Medic              = 32;
UID_Sergant            = 33;
UID_Commando           = 34;
UID_Bomber             = 35;
UID_Major              = 36;
UID_BFG                = 37;
UID_FAPC               = 38;
UID_APC                = 39;
UID_Terminator         = 40;
UID_Tank               = 41;
UID_Flyer              = 42;
UID_Mine               = 43;
UID_UTransport         = 44;

UID_HKeep              = 49;
UID_HGate              = 50;
UID_HSymbol            = 51;
UID_HPools             = 52;
UID_HTower             = 53;
UID_HTeleport          = 54;
UID_HMonastery         = 55;
UID_HTotem             = 56;
UID_HAltar             = 57;
UID_HFortress          = 58;
UID_HCommandCenter     = 59;
UID_HMilitaryUnit      = 60;

UID_UCommandCenter     = 61;
UID_UMilitaryUnit      = 62;
UID_UGenerator         = 63;
UID_UWeaponFactory     = 64;
UID_UTurret            = 65;
UID_URadar             = 66;
UID_UVehicleFactory    = 67;
UID_UPTurret           = 68;
UID_URocketL           = 69;
UID_URTurret           = 70;
UID_UNuclearPlant      = 71;

UID_UBaseMil           = 72;
UID_UBaseCom           = 73;
UID_UBaseGen           = 74;
UID_UBaseRef           = 75;
UID_UBaseNuc           = 76;
UID_UBaseLab           = 77;
UID_UCBuild            = 78;
UID_USPort             = 79;


UID_Portal             = 90;
UID_CoopPortal         = 91;

uids_hell              = [UID_LostSoul..UID_ZBFG,UID_HEye,UID_HKeep..UID_HMilitaryUnit];
uids_uac               = [UID_Engineer..UID_UTransport,UID_UCommandCenter..UID_USPort];

t2                     = [UID_URocketL,UID_URTurret,UID_HTotem,UID_HAltar,UID_Terminator,UID_Tank,UID_Flyer,UID_Pain..UID_Archvile];

marines                = [UID_Engineer ,UID_Medic   ,UID_Sergant ,UID_Commando ,UID_Bomber ,UID_Major ,UID_BFG ];
zimbas                 = [UID_ZEngineer,UID_ZFormer ,UID_ZSergant,UID_ZCommando,UID_ZBomber,UID_ZMajor,UID_ZBFG];
gavno                  = marines+[UID_Imp]+zimbas-[UID_ZEngineer];
arch_res               = [UID_Imp..UID_Baron,UID_Revenant..UID_Arachnotron,UID_ZFormer..UID_ZBFG];
demons                 = [UID_LostSoul..UID_Archvile]+zimbas;
whocanattack           = demons+marines+[UID_Terminator..UID_Flyer,UID_Mine,UID_APC,UID_FAPC,UID_HTower,UID_HTotem,UID_HCommandCenter,UID_UCommandCenter,UID_UTurret,UID_UPTurret,UID_URTurret];
whocanmp               = [UID_HGate,UID_UMilitaryUnit,UID_HTeleport,UID_UVehicleFactory,UID_HMilitaryUnit];

coopspawn              = marines+demons+[UID_Terminator,UID_Tank,UID_Flyer];

slowturn               = [UID_APC,UID_Tank];

armor_lite             = marines+zimbas+[UID_LostSoul,UID_Imp,UID_Revenant];
type_massive           = [UID_Cyberdemon,UID_Mastermind,UID_Mancubus,UID_Arachnotron];

clnet_rld              = [UID_UVehicleFactory,UID_HTeleport,UID_UNuclearPlant,UID_HFortress];

{
0    UID_HKeep,UID_HFortress    UID_UCommandCenter     UID_LostSoul        UID_Engineer
1    UID_HGate                  UID_UMilitaryUnit      UID_Imp             UID_Medic
2    UID_HSymbol                UID_UGenerator         UID_Demon           UID_Sergant
3    UID_HPools                 UID_UWeaponFactory     UID_Cacodemon       UID_Commando
4    UID_HTower                 UID_UTurret            UID_Baron           UID_Bomber
5    UID_HTeleport              UID_URadar             UID_Cyberdemon      UID_Major
6    UID_HMonastery             UID_UVehicleFactory    UID_Mastermind      UID_BFG
7    UID_HTotem                 UID_URTurret           UID_Pain            UID_FAPC
8    UID_HAltar                 UID_URocketL           UID_Revenant        UID_APC
9                                                      UID_Mancubus        UID_Terminator
10                                                     UID_Arachnotron     UID_Tank
11                                                     UID_Archvile        UID_Flyer
12   UID_HEye                   UID_Mine               Zimbas
13
14
15
}

upgr_1                 : array[1..2] of set of byte = ([upgr_6bld,upgr_b478tel,upgr_hinvuln],[upgr_blizz]);
ai_d2alrm              : array[false..true] of integer = (150,15);
builder_enrg           : array[0..4] of byte = (6,7,8,9,10);
base_r                 = 350;
base_rr                = base_r*2;
base_3r                = base_r*3;
base_ir                = base_r+(base_r div 2);
base_rA                : array[0..2] of integer = (280,320,360);
uaccc_fly              = 23;
apc_exp_damage         = 70;
regen_per              = vid_fps*2;
_uclord_p              = vid_hfps+1;
vistime                = _uclord_p+1;
gavno_dth_h            = -45;
dead_hits              = -12*vid_fps;
idead_hits             = dead_hits+vid_3fps;
ndead_hits             = dead_hits-1;
radar_time             = vid_fps*30;
radar_rlda             : array[0..5] of integer = (radar_time-vid_fps*3,radar_time-vid_fps*5,radar_time-vid_fps*7,radar_time-vid_fps*9,radar_time-vid_fps*11,radar_time-vid_fps*13);
radar_rsg              : array[0..5] of integer = (200,225,250,275,300,325);
eye_rsg                : array[0..5] of integer = (250,275,300,325,350,375);
melee_r                = 8;
missile_mr             = 500;
gear_time              : array[false..true] of byte = (vid_fps,vid_fps*2);
dir_stepX              : array[0..7] of integer = (1,1,0,-1,-1,-1,0,1);
dir_stepY              : array[0..7] of integer = (0,-1,-1,-1,0,1,1,1);
rocket_sr              = 45;
map_ffly_fapc          : array[false..true] of byte = (3,6);
towers_sr              : array[0..5] of integer = (250,265,280,295,310,325);
blizz_r                = 150;
mech_adv_rel           : array[false..true] of integer = (vid_fps*12,vid_fps*6);
uac_adv_rel            : array[false..true] of integer = (vid_fps*3,vid_fps);
g_ct_pr                = 150;
g_ct_ct                : array[1..2] of integer = (vid_fps*10,vid_fps*5);
bld_dec_mr             = 8;
def_ai                 = 4;
pain_time              = vid_hfps;
hinvuln_time           = (vid_fps*30);
_mms                   = 126;
_d2shi                 = abs(dead_hits div 126)+1;   // 5
advprod_rld            : array[false..true] of integer = (vid_fps*120,vid_fps*60);

_sbs_ucls              = [5,6,8];

fly_height             = 30;

MaxUnitProds           = 1;

{$IFDEF _FULLGAME}

whocanaction           = [UID_Engineer,UID_UCommandCenter,UID_APC,UID_FAPC,UID_LostSoul,UID_Pain,UID_Mine,UID_UTurret,UID_UPTurret];

_buffst                : array[false..true] of smallint = (0,_bufinf);

str_ps_sv              : char = '@';

ChatLen2               = 255;
dead_time              = -dead_hits;
hp_detect              = #7;
hp_pshield             = #8;
adv_char               = #10;
revenant_ra            : array[false..true] of integer = (45,20);

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
EID_HUpgr              = 215;
EID_HAMU               = 216;
EID_HMU                = 218;
EID_HCC                = 219;

vid_ifps               = vid_fps-1;
vid_bpp                = 32;
vid_minw               = 800;
vid_minh               = 600;
vid_maxw               = 1360;
vid_maxh               = 768;
vid_ab                 = 100;
vid_mvs                = 500; // max vis sprites;
vid_rtuir              = 6;
vid_rtuis              = vid_fps div vid_rtuir;
vid_rtuish             = vid_rtuis div 2;
vid_uialrm_t           = vid_fps div (vid_rtuir div 3);
vid_uialrm_ti          = vid_uialrm_t div 3;
vid_uialrm_n           = 10;
vid_uialrm_mr          = vid_uialrm_t-(vid_uialrm_t div 3);
vid_BW                 = 44;
vid_2BW                = vid_BW*2;
vid_panel              = vid_BW*3;
vid_tBW                = vid_panel div 4;
vid_2tBW               = vid_tBW*2;
//vid_3tBW               = vid_panel div 4;
vid_hBW                = vid_BW div 2;
vid_oiw                = 18;
vid_oihw               = vid_oiw+(vid_oiw div 2);
vid_oisw               = vid_oiw-(vid_oiw div 4);
vid_oips               = 2*vid_oiw+vid_oisw;
vid_svld_m             = 7;
vid_rpls_m             = 8;
vid_camp_m             = 11;

ui_h3bw                = vid_BW-vid_tBW;
ui_bottomsy            = vid_BW*4;
ui_tabsy               = vid_panel+ui_h3bw;
ui_hwp                 = vid_panel div 2;
ui_iy                  = vid_panel+3;
ui_energx              = (ui_hwp+ui_h3bw) div 2;
ui_armyx               = (ui_hwp+ui_h3bw+vid_panel) div 2;
ui_textx               = vid_panel+4;

ui_menu_map_zx0        = 76;
ui_menu_map_zy0        = 110;
ui_menu_map_zx1        = 381;
ui_menu_map_zy1        = 289;
ui_menu_map_ys         = 19;
ui_menu_map_x0         = ((ui_menu_map_zx0+ui_menu_map_zx1) div 2)- vid_panel;
ui_menu_map_y0         = ((ui_menu_map_zy0+ui_menu_map_zy1) div 2)-(vid_panel div 2);
ui_menu_map_rx0        = ui_menu_map_x0+16+vid_panel;
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
ui_menu_ssr_x3         = ui_menu_ssr_x1-10;
ui_menu_ssr_x2         = ui_menu_ssr_x3-127;
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

AUDIO_FREQUENCY        : INTEGER = MIX_DEFAULT_FREQUENCY; //22050;
AUDIO_FORMAT           : WORD    = AUDIO_S16;
AUDIO_CHANNELS         : INTEGER = 1;
AUDIO_CHUNKSIZE        : INTEGER = 1024;                  //4096;

svld_size              = 219833;
rpl_size               = 1574;

rpl_none               = 0;
rpl_whead              = 1;
rpl_wunit              = 2;
rpl_rhead              = 3;
rpl_runit              = 4;
rpl_end                = 5;

SvRpLen                = 15;

MFogM                  = 30;
fog_cw                 = 32;
fog_chw                = fog_cw div 2;
fog_cr                 = round(fog_chw*1.45);
fog_cxr                = fog_cr-fog_chw;
fog_vfwm               = ((vid_maxw-vid_panel) div fog_cw)+1;
fog_vfhm               = (vid_maxh div fog_cw)+1;

ta_left                = 0;
ta_middle              = 1;
ta_right               = 2;

font_w                 = 8;
font_iw                = font_w-1;

txt_line_h             = 5;
txt_line_h2            = 25-font_w;

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

chat_shlm_t            = vid_fps*5;

cfgfn                  : shortstring = 'cfg';
str_screenshot         : shortstring = 'MVSCR_';
str_loading            : shortstring = 'LOADING...'+#0;
str_folder_gr          : shortstring = 'graphic\';
str_msc_fold           : shortstring = 'music\';
str_snd_fold           : shortstring = 'sound\';
str_svld_dir           : shortstring = 'save\';
str_svld_ext           : shortstring = '.mws';
str_rpls_dir           : shortstring = 'replay\';
str_rpls_ext           : shortstring = '.mwr';

chat_type              : array[false..true] of char = ('|',' ');

k_chrtt                = vid_fps div 3;
k_kbstr                : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','[',']','{','}',' ','_',',','.','(',')','<','>','-','+','`','@','#','%','?',':','$'];
k_kbdig                : set of Char = ['0'..'9'];
k_kbaddr               : set of Char = ['0'..'9','.',':'];


//_net_pnua              : array[0..4] of byte = (50,100,150,200,250);

LiquidAnim             = 4;

crater_ri              = 4;
crater_r               : array[1..crater_ri] of integer = (33,60,88,110);


{$ELSE }

{$ENDIF}



