const

degtorad             = pi/180;

ver                  : byte = 100;

outlogfn             = 'out.txt';
str_ver              = 'v50b';
str_wcaption         = 'The Ultimate MarsWars'+' '+str_ver;
str_cprt             = '[ T3DStudio (C) 2016-2020 ]';

k_kbstr              : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','[',']','{','}',' ','_',',','.','(',')','<','>','-','+','`','@','#','%','?',':','$'];

str_ps_none          : shortstring = '--';
str_ps_comp          : shortstring = 'AI';
str_ps_c             : array[0..2] of char = ('-','P','C');
str_ps_t             : char = '?';
str_ps_h             : char = '<';
str_xN               : array[0..4] of shortstring = ('-','x1','x2','x3','x4');
b2pm                 : array[false..true] of shortstring = (#15+'-'+#25,#18+'+'+#25);

race_n               = 2;

NameLen              = 12;
ChatLen              = 38;

vid_fps              = 60;
vid_2fps             = vid_fps*2;
vid_3fps             = vid_fps*3;
vid_mpt              = trunc(1000/vid_fps);
vid_h2fps            = vid_fps div 2;
vid_h3fps            = vid_fps div 3;
vid_2h3fps           = vid_h3fps*2;
vid_h4fps            = vid_fps div 4;
vid_h5fps            = vid_fps div 5;
vid_h8fps            = vid_fps div 8;
ClientTTL            = vid_fps*5;
ServerTTL            = vid_fps*10;

MaxPlayers           = 6;
MaxPlayerUnits       = 110;
MaxUnits             = MaxPlayers*MaxPlayerUnits;
MaxDoodads           = 500;
MaxMissiles          = MaxUnits;

MaxSMapW             = 7000;
MinSMapW             = 3000;

MaxNetChat           = 15;
MaxNetBuffer         = 4096;
NetTickN             = 2;

ddc_div              = 1000000;
ddc_cf               = (MaxSMapW*MaxSMapW) div ddc_div;

dcw                  = 200;
dcn                  = MaxSMapW div dcw;

////////////////////////////////////////////////////////////////////////////////
//
//  Network message ID
//

nmid_startinf        = 100;
nmid_connect         = 101;
nmid_sver            = 102;
nmid_sgst            = 103;
nmid_sfull           = 104;
nmid_chat            = 105;
nmid_clchup          = 106;
nmid_pause           = 109;
nmid_shap            = 110;
nmid_ncon            = 111;
nmid_order           = 112;
nmid_plout           = 113;
nmid_swapp           = 114;
nmid_clinf           = 115;
nmid_getinfo         = 116;

////////////////////////////////////////////////////////////////////////////////
//
//  Network status
//

ns_none              = 0;
ns_srvr              = 1;
ns_clnt              = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  Player status
//

ps_none              = 0;
ps_play              = 1;
ps_comp              = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  Race
//

r_random             = 0;
r_hell               = 1;
r_uac                = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  Game mode
//

gm_scir              = 0;
gm_tdm2              = 1;
gm_tdm3              = 2;

def_ai               = 4;

////////////////////////////////////////////////////////////////////////////////
//
//  Doodads ID
//

DID_LiquidR1         = 1;
DID_LiquidR2         = 2;
DID_LiquidR3         = 3;
DID_LiquidR4         = 4;
DID_BRock            = 5;
DID_SRock            = 6;
DID_Other            = 7;

DID_R                : array[1..7] of integer = (65,125,185,250,100,60,17);

////////////////////////////////////////////////////////////////////////////////
//
//  Unit fly height
//

uf_ground            = 0;
uf_soaring           = 1;
uf_fly               = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  Conditionals for attack
//

atm_none             = 0;
atm_bunker           = 1;
atm_stturr           = 2;
atm_inapc            = 3;
atm_inmove           = 4;
atm_always           = 10;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: requirements to attacker
//

wpr_any              = 0;
wpr_adv              = 1;
wpr_nadv             = 2;
wpr_netst            = 7;

////////////////////////////////////////////////////////////////////////////////
//
//  Weapon: type
//

wpt_msle             = 0;
wpt_resur            = 1;
wpt_heal             = 2;
wpt_uspwn            = 3;
wpt_ddmg             = 4;

////////////////////////////////////////////////////////////////////////////////
//
//  Player order
//

po_uorder            = 1;
po_uordera           = 2;
po_dblselect         = 3;
po_adblselect        = 4;
po_select            = 5;
po_aselect           = 6;
po_selorder          = 7;
po_setorder          = 8;
po_selspec           = 9;

////////////////////////////////////////////////////////////////////////////////
//
//  Unit order
//

uo_rightcl           = 0;
uo_move              = 1;
uo_smove             = 2;
uo_attack            = 3;
uo_patrol            = 4;
uo_spatrol           = 5;
uo_stop              = 6;
uo_hold              = 7;
uo_auto              = 8;
uo_prod              = 9;
uo_upload            = 10;
uo_unload            = 11;
uo_rallpos           = 12;
uo_destroy           = 13;
uo_uteleport         = 14;
uo_spawndron         = 15;
uo_archresur         = 16;
uo_botrepair         = 17;
uo_spawnlost         = 18;

////////////////////////////////////////////////////////////////////////////////
//
//  Unit buffs
//

ub_advanced          = 0;
ub_pain              = 1;
ub_hellpower         = 2;
ub_resur             = 3;
ub_cast              = 4;
ub_invis             = 5;
ub_detect            = 6;
ub_teleff            = 20;
ub_born              = 21;
ub_invuln            = 22;

_ubuffs              = 31;
_bufinf              = 32000;

////////////////////////////////////////////////////////////////////////////////
//
//  Target flag
//

at_map               = %1000000000000000; // target: need map point ?
at_unit              = %0100000000000000; // target: need unit ?
                     // OWNER                0 any owner
at_ownp              = %0001000000000000; // 1 own
at_owna              = %0010000000000000; // 2 ally
at_owne              = %0011000000000000; // 3 enemy
                     // HITS                 0 any hits
at_hith              = %0000010000000000; // 1 damaged
at_hitd              = %0000100000000000; // 2 dead
at_hita              = %0000110000000000; // 3 alive
                     // CLASS                0 bio+mechs+builds
at_bio               = %0000001000000000; // 1 bio
at_mechs             = %0000000100000000; // 2 mech
at_builds            = %0000001100000000; // 3 builds
                     // BLD                  0 any
at_bld               = %0000000010000000; // 1 must bld
                     // ADV                  0 any
at_noadv             = %0000000001000000; // 1 must be no advanced
at_adv               = %0000000001100000; // 3 must be    advanced
                     // FLY                  0 any
at_fly               = %0000000000010000; // 1 fly
at_ground            = %0000000000011000; // 3 ground only

at_anytar            = at_map+at_unit;
at_aall              = at_unit+at_hita;
at_aown              = at_unit+at_hita+at_ownp;
at_aally             = at_unit+at_hita+at_owna;
at_aenemy            = at_unit+at_hita+at_owne;
at_resur             = at_unit+at_hitd+at_owna;
at_mrepair           = at_unit+at_hith+at_owna+at_mechs+at_bld;
at_aground           = at_unit+at_hita+at_owne+at_ground;

////////////////////////////////////////////////////////////////////////////////
//
//  Missile flag
//

mf_2xspd             = %10000000;
mf_insta             = %01000000;
mf_ihhdam            = %00100000;
mf_ihdam             = %00010000;
mf_i1dam             = %00001000;
mf_homing            = %00000100;

////////////////////////////////////////////////////////////////////////////////
//
//  Units ID
//

UID_LostSoul         = 1;
UID_Imp              = 2;
UID_Demon            = 3;
UID_Cacodemon        = 4;
UID_Knight           = 5;
UID_Cyberdemon       = 6;
UID_Mastermind       = 7;
UID_Pain             = 8;
UID_Revenant         = 9;
UID_Mancubus         = 10;
UID_Arachnotron      = 11;
UID_Archvile         = 12;

UID_ZFormer          = 13;
UID_ZSergant         = 14;
UID_ZCommando        = 15;
UID_ZBomber          = 16;
UID_ZMajor           = 17;
UID_ZBFG             = 18;

UID_HKeep            = 19;
UID_HGate            = 20;
UID_HSymbol          = 21;
UID_HPools           = 22;
UID_HTower           = 23;
UID_HTeleport        = 24;
UID_HMonastery       = 25;
UID_HTotem           = 26;
UID_HAltar           = 27;
UID_HMilitaryUnit    = 28;
UID_HFortress        = 29;

UID_Dron             = 36;
UID_Scout            = 37;
UID_Medic            = 38;
UID_Sergant          = 39;
UID_Commando         = 40;
UID_Bomber           = 41;
UID_Major            = 42;
UID_BFG              = 43;
UID_FAPC             = 44;
UID_APC              = 45;
UID_Terminator       = 46;
UID_Tank             = 47;
UID_Flyer            = 48;

UID_Mine             = 49;

UID_UCommandCenter   = 50;
UID_UMilitaryUnit    = 51;
UID_UGenerator       = 52;
UID_UWeaponFactory   = 53;
UID_UTurret          = 54;
UID_URadar           = 55;
UID_UVehicleFactory  = 56;
UID_UPTurret         = 57;
UID_URTurret         = 58;
UID_URocketL         = 59;

singleuids           = [1..60];

MID_Imp              = 2;
MID_Cacodemon        = 3;
MID_Baron            = 4;
MID_HRocket          = 5;
MID_Revenant         = 6;
MID_Mancubus         = 7;
MID_YPlasma          = 8;
MID_BPlasma          = 9;
MID_Bullet           = 10;
MID_Bulletx2         = 11;
MID_TBullet          = 12;
MID_SShot            = 13;
MID_SSShot           = 14;
MID_BFG              = 15;
MID_Granade          = 16;
MID_Mine             = 17;
MID_Blizzard         = 18;
MID_URocket          = 19;
MID_ArchFire         = 20;

////////////////////////////////////////////////////////////////////////////////
//
//  Other game constants
//


base_1r              = 300;
base_hr              = base_1r div 2;
base_ir              = base_1r+(base_1r div 2);
base_2r              = base_1r*2;
base_yr              = base_2r+(base_1r div 3);
base_3r              = base_1r*3;
_uclord_p            = vid_h2fps;
_uregen_p            = vid_2fps;
MinUSTP              = 8;
bld_dec_mr           = 5;
dead_hits            = -12*vid_fps;
rdead_hits           = -85;
idead_hits           = dead_hits+vid_3fps;
ndead_hits           = dead_hits-1;
dead_time            = -dead_hits;
gavno_hits           = -30;
apc_exp_damage       = 50;
MaxAttacks           = 2;
MaxOrderList         = 63;
_mms                 = 126;
_d2shi               = abs(dead_hits div 126)+1;   // 5

                                                               //           hell  uac
race_pstyle          : array[false..true,1..race_n] of boolean = {units :}((false,false),  // true = warpgate / false - classic
                                                                 {builds:} (true ,false)); // true = classic  / false = uac(dron)
race_bsmana          : array[false..true,1..race_n] of byte    = {units :}((5    ,0    ),  // units
                                                                 {builds:} (25   ,0    )); // builds

/////////////////////  ONLY FOR FULL GAME  /////////////////////////////////////
{$IFDEF _FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
//  Unit effects
//

ueff_create          = 0;
ueff_startb          = 1;
ueff_pain            = 2;
ueff_death           = 3;
ueff_fdeath          = 4;
ueff_foot            = 5;
_ueffs_ctypen        = 6;
MaxUIDSnds           = 3;


LiquidMR             = 4;
_buffst              : array[false..true] of smallint = (0,_bufinf);

fly_height           = 32;

////////////////////////////////////////////////////////////////////////////////
//
//  Effect ID
//

EID_DPain            = 100;
EID_DLostSoul        = 101;
EID_BFG              = 102;
EID_BExp             = 103;
EID_BBExp            = 104;
EID_Teleport         = 105;
EID_Exp              = 106;
EID_Exp2             = 107;
EID_Gavno            = 108;
EID_HKT_h            = 109;
EID_HKT_s            = 110;
EID_db_h0            = 111;
EID_db_h1            = 112;
EID_db_u0            = 113;
EID_db_u1            = 114;
EID_Blood            = 115;
EID_ArchFire         = 116;
EID_HUpgr            = 117;
EID_HMilitaryUnit    = 118;

////////////////////////////////////////////////////////////////////////////////
//
//  Text style
//

ta_left              = 0;
ta_middle            = 1;
ta_right             = 2;
ta_FVleft            = 3;
ta_Fmiddle           = 4;
ta_Fright            = 5;
ta_FVmiddle          = 6;
ta_FVright           = 7;

////////////////////////////////////////////////////////////////////////////////
//
//  Menu tabs
//

ms1_sett             = 0;
ms1_svld             = 1;
ms1_reps             = 2;
ms2_camp             = 0;
ms2_scir             = 1;
ms2_mult             = 2;
ms3_snd              = 0;
ms3_vid              = 1;
ms3_game             = 2;

////////////////////////////////////////////////////////////////////////////////
//
//  Replay
//

rpl_none             = 0;
rpl_whead            = 1;
rpl_wunit            = 2;
rpl_rhead            = 3;
rpl_runit            = 4;
rpl_end              = 5;

////////////////////////////////////////////////////////////////////////////////
//
//  Strings
//

str_loading          = 'LOADING...';
cfgfn                = 'cfg';
str_f_race           : array[1..race_n] of shortstring = ('hell\','uac\');

str_f_grp            = 'graphic\';
str_f_mapg           = 'map\';
str_f_adec           = 'adt';
str_f_ter            = 'ter';
str_f_liq            = 'liquid_';
str_f_drckb          = 'rockb';
str_f_drcks          = 'rocks';
str_f_dothr          = 'dec_';
str_mtheme           = 'themes.txt';

str_f_msc            : shortstring = 'music\';
str_f_snd            : shortstring = 'sound\';
str_f_sv             : shortstring = 'save\';
str_e_sv             : shortstring = '.mws';
str_f_rpl            : shortstring = 'replay\';
str_e_rpl            : shortstring = '.mwr';
str_screenshot       : shortstring = 'MVSCR_';

chat_type            : array[false..true] of char = ('|',' ');

//hp_char              = #5;
adv_char             = #6;
//hp_detect            = #7;
//hp_pshield           = #8;

////////////////////////////////////////////////////////////////////////////////
//
//  Graphic
//

grp_extn             = 3;
grp_exts             : array[1..grp_extn] of shortstring = ('.png','.jpg','.bmp');

vid_4fps             = vid_fps*4;
chat_shlm_t          = vid_4fps;
vid_maxw             = 1024;
vid_minw             = 800;
vid_maxh             = 768;
vid_minh             = 600;
vid_mvs              = 700;
vid_bpp              = 32;
vid_BW               = 43;
vid_ab               = 110;
vid_2BW              = vid_BW*2;
vid_hBW              = vid_BW div 2;
vid_2hBW             = vid_hBW+vid_BW;
vid_menu_cprtx       = vid_minw div 2;

ui_p_uplnh           = 14;
ui_p_uplnhh          = (ui_p_uplnh div 2)+1;
ui_mmwidth           = vid_BW*3+ui_p_uplnh;
ui_p_btnsh           = 2;
ui_p_lsecw           = 10;
ui_p_lsecwi          = ui_p_lsecw-1;
ui_p_minispx         = ui_mmwidth+(ui_p_lsecwi*vid_BW);
ui_p_minisphlx1      = ui_p_minispx+vid_2BW;
ui_p_minisphly       = ui_p_uplnh+vid_2BW;
ui_p_rsecw           = 3;
ui_p_rsecwi          = ui_p_rsecw-1;
ui_p_rsecx           = 1+ui_p_lsecw;
ui_p_xtimer          = ui_mmwidth+vid_BW*6+3;
ui_p_xenrgy          = ui_mmwidth+3;
ui_p_xmanay          = ui_mmwidth+vid_2BW+3;
ui_p_xarmy           = ui_mmwidth+vid_2BW+vid_2BW+3;
//ui_p_xmana           = ui_mmwidth+vid_BW*ui_p_rsecx+3;
ui_p_mainbtns        = ui_p_lsecw+ui_p_rsecw;
ui_p_xsbtns          = ui_p_mainbtns+1;
ui_p_xchat           = ui_mmwidth+vid_BW*ui_p_xsbtns;
ui_p_ychat           = ui_p_uplnh+vid_2BW;
ui_p_lhintx          = vid_BW*5;
ui_p_rhintx          = ui_mmwidth+ui_p_rsecx*vid_BW;
ui_mmmpx             = 160-(ui_mmwidth div 2)+1;
ui_mmmpy             = 198-(ui_mmwidth div 2);


{
vid_meucprtx         = ;
ui_paneltmx          =
ui_btnch             = 2;
ui_ptbsx             = 1;
ui_pabsx             = ui_ptbsx+ui_pbtnsw;
ui_panelmmx          = }

ui_redrawp           = vid_h5fps;
ui_redrawph          = ui_redrawp div 2;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

MFogM                = 30;
fog_cw               = 32;
fog_chw              = fog_cw div 2;
fog_cr               = round(fog_chw*1.45);
fog_cxr              = fog_cr-fog_chw;
fog_vfwm             = (vid_maxw div fog_cw)+1;
fog_vfhm             = ((vid_maxh-ui_mmwidth) div fog_cw)+1;

ChatLen2             = 253;
SvRpLen              = 15;

menu_svld_m          = 9;
menu_rpls_m          = 10;
menu_camp_m          = 16;

svld_size            = 254505;
rpl_size             = 1570;

k_kbdig              : set of Char = ['0'..'9'];
k_kbaddr             : set of Char = ['0'..'9','.',':'];

AUDIO_FREQUENCY      : INTEGER = MIX_DEFAULT_FREQUENCY; //22050;
AUDIO_FORMAT         : WORD    = AUDIO_S16;
AUDIO_CHANNELS       : INTEGER = 1;
AUDIO_CHUNKSIZE      : INTEGER = 1024;                  //4096;
                                           // 60 120 180 240 315 390 450 510 575 660
_cl_pnua             : array[0..9] of byte = (20,40 ,60 ,80 ,105,130,150,170,195,220);

LiquidAnim           = 4;
CraterMR             = 3;
CraterD              : array[1..CraterMR] of smallint = (56,106,160);
CraterR              : array[1..CraterMR] of smallint = (28,53 ,80 );

map_flydpth          : array[0..2] of smallint = (0,10000,20000);

////////////////////////////////////////////////////////////////////////////////
//
//  Menu items
//

ms_extbck            = 1;
ms_strrst            = 2;
ms_ms1set            = 3;
ms_ms1svl            = 4;
ms_ms1rpl            = 5;
ms_ms2cmp            = 6;
ms_ms2scr            = 7;
ms_ms2mlt            = 8;
ms_cmpdif            = 9;
ms_cmpmis            = 10;
ms_mapsed            = 11;
ms_mapset            = 12;
ms_plname            = 13;
ms_plstat            = 14;
ms_plrace            = 15;
ms_plteam            = 16;
ms_gameop            = 17;
ms_gamers            = 18;
ms_setpln            = 27;
ms_mltcht            = 29;
ms_mltsvu            = 30;
ms_mltsvp            = 31;
ms_mltcla            = 32;
ms_mltpnu            = 33;
ms_mltcon            = 34;
ms_mlttem            = 35;
ms_mltrac            = 36;
ms_mltred            = 37;
ms_svldfl            = 38;
ms_svldsn            = 39;
ms_svldsv            = 40;
ms_svldld            = 41;
ms_svlddl            = 42;
ms_rplsfl            = 43;
ms_rplspl            = 44;
ms_rplsdl            = 45;
ms_rplson            = 46;
ms_rplsfn            = 47;
ms_rplspn            = 48;
ms_ms3snd            = 49;
ms_ms3vid            = 50;
ms_ms3gam            = 51;
ms_setting           = 52;
{$ELSE}
ded_sv_color        : array[0..MaxPlayers] of shortstring = ('GRAY','RED','ORANGE','YELLOW','LIME','AQUA','BLUE');
maxCons             = 24;
maxConsL            = 80;
{$ENDIF}


