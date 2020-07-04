var

_EVENT           : pSDL_EVENT;

vid_mredraw      : boolean = true;

_warpten         : boolean = false;

_CYCLE           : boolean = false;
onlySVcode       : boolean = true;

G_Started        : boolean = false;
G_Status         : byte = 0;
G_Mode           : byte = gm_scir;
G_Step           : cardinal = 0;
G_AISlots        : byte = 5;
G_SSlots         : boolean = true;

HPlayer          : byte = 1;

_players         : TPlist;
_units           : array[0..MaxUnits  ] of TUnit;
_toids           : array[byte] of TOID;
_lcu             : integer = 0;
_lcup            : PTUnit;
_tuids           : array[byte] of TUID;
_tupids          : array[byte] of TUPID;
_missiles        : array[1..MaxMissiles] of TMissile;

utbl_start       : array[1..race_n] of byte;

_uclord_c        : integer = 0;
_uregen_c        : integer = 0;

UnitStepNum      : byte = 8;

map_seed         : cardinal = 1;
map_seed2        : integer = 0;
map_mw           : integer = 5000;
map_obs          : byte = 1;
map_liq          : byte = 1;
map_psx          : array[0..MaxPlayers] of integer;
map_psy          : array[0..MaxPlayers] of integer;
map_dds          : array[1..MaxDoodads] of TDoodad;
map_dcell        : array[0..dcn,0..dcn] of TDCell;

net_nstat        : byte = 0;
net_sv_pstr      : shortstring = '10666';
net_sv_port      : word = 10666;
net_socket       : PUDPSocket;
net_buf          : PUDPpacket;
net_period       : byte = 0;
net_msglen       : integer = 0;
net_msgrbn       : integer = 0;

str_m_liq,
str_m_siz,
str_m_obs,
str_plout        : shortstring;
str_race         : array[0..race_n] of shortstring;

str_temp:shortstring;

_rpls_file       : file;

/////////////////////  ONLY FOR FULL GAME  //////////////////////////////////////////////
{$IFDEF _FULLGAME}

_testmode        : boolean = true;
_fsttime         : boolean = false;
_draw            : boolean = true;

_svld_stat       : shortstring = '';
_svld_str        : shortstring = '';
_svld_l          : array of shortstring;
_svld_ln         : integer = 0;
_svld_ls         : integer = 0;
_svld_sm         : integer = 0;
_svld_cor        : boolean = false;

_rpls_fileo      : boolean = false;
_rpls_u          : integer = 0;
_rpls_pnui       : byte = 1;
_rpls_lrname     : shortstring = 'LastReplay';
_rpls_stat       : shortstring = '';
_rpls_rst        : byte = rpl_none;
_rpls_l          : array of shortstring;
_rpls_ln         : integer = 0;
_rpls_ls         : integer = 0;
_rpls_sm         : integer = 0;
_rpls_step       : integer = 1;
_rpls_nwrch      : boolean = false;
_rpls_log        : boolean = false;
_rpls_ic         : byte = 0;
_rpls_pause      : boolean = false;
_rpls_cor        : boolean = false;
_rpls_who        : byte = 0;

fps_cs,
fps_ns           : cardinal;

vid_mw           : integer = 800;
vid_mh           : integer = 600;

vid_vx           : integer = 0;
vid_vy           : integer = 0;
vid_fsx          : integer = 0;
vid_fsy          : integer = 0;
vid_fex          : integer = 0;
vid_fey          : integer = 0;
vid_vmm          : boolean = false;
vid_vmspd        : byte = 10;
vid_ingamecl     : byte = 255;
vid_vmb_x0       : integer = 6;
vid_vmb_y0       : integer = 6;
vid_vmb_x1       : integer = 794;
vid_vmb_y1       : integer = 594;
vid_mmvx         : integer = 0;
vid_mmvy         : integer = 0;
vid_mwa          : integer = 0;
vid_mha          : integer = 0;

vid_vsl          : array[1..vid_mvs] of PTVisSpr;
vid_vsls         : word = 0;
_effects         : array[1..vid_mvs] of TEff;

map_trt          : byte = 0;
map_ptrt         : byte = 255;
map_lqt          : byte = 0;
map_plqt         : byte = 255;
map_pblqt        : byte = 255;
map_mmcx         : single;
map_mmsp,
map_mmvw,
map_mmvh         : integer;
map_ADecn        : integer = 0;
map_ADecs        : array of TADec;
map_Liquidc      : array[byte] of cardinal;

map_themes       : array of TMapTheme;
map_themen       : byte = 0;
map_themec       : byte = 0;

_fscr            : boolean = false;

_vflags          : cardinal = SDL_SWSURFACE;

_RECT            : pSDL_Rect;
_screen          : pSDL_Surface;
_dsurf           : pSDL_Surface;

ter_surf         : pSDL_Surface;
ter_w,
ter_h            : integer;

_igchat          : boolean = false;
net_pnui         : byte = 5;
net_cl_svip      : cardinal = 0;
net_cl_svport    : word = 10666;
net_cl_svttl     : integer = 0;
net_cl_svpl      : byte = 0;
net_cl_svstr     : shortstring = '127.0.0.1:10666';
net_m_error      : shortstring = '';
net_clchatm      : array[0..MaxNetChat] of shortstring;
net_clchats      : byte = 0;
net_unmvsts      : byte = 0;

_menu_surf       : pSDL_Surface;
_menu            : boolean = true;
_m_sel           : byte = 0;
menu_s1          : byte = ms1_sett;
menu_s2          : byte = ms2_scir;
menu_s3          : byte = ms3_game;
m_chat           : boolean = false;
m_vrx            : integer = 0;
m_vry            : integer = 0;

m_vx             : integer = 0;
m_vy             : integer = 0;
mv_x             : integer = 0;
mv_y             : integer = 0;
m_mx             : integer = 0;
m_my             : integer = 0;
m_bx             : integer = 0;
m_by             : integer = 0;
m_vmove          : boolean = false;
m_sxs            : integer = 0;
m_sys            : integer = 0;
m_ldblclk        : byte = 0;
m_brush          : byte = 0;
m_brcolor        : cardinal = 0;
m_brtar          : integer;

ui_tminimap      : pSDL_Surface;
ui_uminimap      : pSDL_Surface;
ui_panelb,
ui_panel         : pSDL_Surface;
ui_panely        : integer = 0;
ui_panelby       : integer = 0;
ui_panelmmm      : boolean = false;
ui_redraw        : byte = 0;
ui_chatx         : integer = 0;
ui_chaty1        : integer = 0;
ui_chaty2        : integer = 0;
ui_chaty3        : integer = 0;
ui_rpabily       : integer = 0;
ui_chattar       : byte = 255;
ui_chat_shlm     : integer = 0;
ui_chat_str      : shortstring = '';
ui_tab           : byte = 0;
ui_xpws          : integer;
ui_dBW           : integer = 0;
ui_mc_x,
ui_mc_y,
ui_mc_a          : integer;
ui_mc_c          : cardinal;
ui_UIPBTNS       : array[0..ui_p_lsecwi,0..ui_p_btnsh,0..2,1..race_n] of byte;
ui_UIABTNS       : array[byte,0..ui_p_rsecwi,0..ui_p_btnsh] of byte;
ui_UIMBTNS       : array[byte,0..1,0..1] of byte;
ui_lsuc          : byte = 0;
ui_uasprites     : array[byte] of PTUSprite;
ui_umark_u       : integer = 0;
ui_umark_ut      : byte = 0;
ui_su_abil       : set of byte = [];
ui_su_bld        : boolean = false;
ui_su_aut        : set of byte = [];
ui_su_spd        : integer = 0;

ui_bldrrsx       : array[1..MaxPlayerUnits] of integer;
ui_bldrrsy       : array[1..MaxPlayerUnits] of integer;
ui_bldrrsr       : array[1..MaxPlayerUnits] of integer;
ui_bldrrsi       : byte = 0;
ui_bldblds       : array[byte] of integer;
ui_bldblda       : array[false..true] of integer;
ui_uidipts       : array[byte] of integer;
ui_uidiptu       : integer = 0;
ui_uidiptb       : integer = 0;
ui_upgripts      : array[byte] of integer;

ordx,
ordy             : array[byte] of integer;

fog_pgrid        : array[0..fog_vfwm,0..fog_vfhm] of byte;
fog_grid         : array[0..fog_vfwm,0..fog_vfhm] of byte;
fog_vfw          : byte = 0;
fog_vfh          : byte = 0;
_fog             : boolean = true;
_fcx             : array[0..MFogM,0..MFogM] of byte;
fog_surf         : array[false..true] of pSDL_Surface;

PlayerName       : shortstring = 'PlayerName';
PlayerTeam       : byte = 1;
PlayerRace       : byte = r_random;
PlayerReady      : boolean = false;
m_a_inv          : boolean = false;

k_dbl,
k_l,
k_r,
k_u,
k_d,
k_shift,
k_ctrl,
k_alt,
k_ml,
k_mr,
k_chrt           : byte;
k_chr            : char;

font_w           : integer = 0;
font_iw          : integer = 0;
font_hw          : integer = 0;
txt_line_h       : integer = 5;
txt_line_h2      : integer = 16;
txt_line_h3      : integer = 0;

c_dred,
c_awhite,
c_red,
c_ared,
c_ablue,
c_orange,
c_dorange,
c_brown,
c_yellow,
c_dyellow,
c_lava,
c_lime,
c_green,
c_dblue,
c_blue,
c_aqua,
c_white,
c_agray,
c_lgray,
c_gray,
c_dgray,
c_ablack,
c_aablack,
c_purple,
c_black          : cardinal;

////////////////////////////////////////////////////////////////////////////////

spr_mback,
spr_cursor,
spr_msl,
spr_mbackmlt     : pSDL_Surface;

spr_font         : array[char] of pSDL_Surface;

spr_Dummy        : TUSprite;
spr_pDummy       : PTUSprite;

spr_Terrains,
spr_Liquids      : array[byte] of pSDL_Surface;
ans_Terrain      : array[byte] of boolean;
anm_Liquids,
ans_Liquids,
anb_Terrain,
tdecs_animn,
tdecs_animt,
srocks_animn,
srocks_animt,
brocks_animn,
brocks_animt     : array[byte] of byte;
spr_BRocks,
spr_SRocks,
spr_TDecs,
spr_ADecs        : array[byte,false..true] of TUSprite;
tdecs_ys,
shd_TDecs        : array[byte] of integer;


spr_b_selall,
spr_b_unload,
spr_b_upload,
spr_b_ralpos,
spr_b_cancle,
spr_b_delete,
spr_b_attack,
spr_b_patrol,
spr_b_hold,
spr_b_move,
spr_b_stop,
spr_btnsel,
spr_btnaut,
spr_rvis,
spr_rspeed,
spr_rskip,
spr_rpause,
spr_rfog,
spr_rlog
                 : pSDL_Surface;

spr_b_upgrs      : array[byte] of pSDL_Surface;

spr_detect       : array[1..race_n] of TUSprite;

spr_uitab        : array[0..2] of pSDL_Surface;

spr_liquid       : array[1..LiquidMR,1..LiquidAnim] of TUSprite;
spr_liquidb      : array[1..LiquidMR] of TUSprite;

spr_lostsoul      : array[0..28] of TUsprite;
spr_imp           : array[0..52] of TUsprite;
spr_demon         : array[0..53] of TUsprite;
spr_cacodemon     : array[0..29] of TUsprite;
spr_baron         : array[0..52] of TUsprite;
spr_knight        : array[0..52] of TUsprite;
spr_cyberdemon    : array[0..56] of TUsprite;
spr_mastermind    : array[0..81] of TUsprite;
spr_pain          : array[0..37] of TUsprite;
spr_revenant      : array[0..76] of TUsprite;
spr_mancubus      : array[0..78] of TUsprite;
spr_arachnotron   : array[0..69] of TUsprite;
spr_archvile      : array[0..85] of TUsprite;

spr_ZFormer       : array[0..52] of TUSprite;
spr_ZSergant      : array[0..52] of TUSprite;
spr_ZSSergant     : array[0..52] of TUSprite;
spr_ZCommando     : array[0..59] of TUSprite;
spr_ZBomber       : array[0..52] of TUSprite;
spr_ZFMajor       : array[0..15] of TUSprite;
spr_ZMajor        : array[0..52] of TUSprite;
spr_ZBFG          : array[0..52] of TUSprite;

spr_drone         : array[0..15] of TUSprite;
spr_scout         : array[0..44] of TUSprite;
spr_medic         : array[0..52] of TUSprite;
spr_sergant       : array[0..44] of TUSprite;
spr_ssergant      : array[0..44] of TUSprite;
spr_commando      : array[0..52] of TUSprite;
spr_bomber        : array[0..44] of TUSprite;
spr_fmajor        : array[0..15] of TUSprite;
spr_major         : array[0..44] of TUSprite;
spr_BFG           : array[0..44] of TUSprite;
spr_FAPC          : array[0..15] of TUSprite;
spr_APC           : array[0..15] of TUSprite;
spr_Terminator    : array[0..55] of TUSprite;
spr_Tank          : array[0..23] of TUSprite;
spr_Flyer         : array[0..15] of TUSprite;

spr_tur           : array[0..15] of TUSprite;
spr_rtur          : array[0..7 ] of TUSprite;

spr_HKeep,
spr_HGate,
spr_HSymbol,
spr_HPools,
spr_HTower,
spr_HTeleport     : array[0..3]  of TUsprite;

spr_UCommandCenter,
spr_UMilitaryUnit,
spr_UGenerator,
spr_UWeaponFactory,
spr_UTurret,
spr_URadar,
spr_UVehicleFactory,
spr_UPTurret,
spr_URTurret,
spr_URocketL        : array[0..3]  of TUsprite;

spr_mp              : array[1..race_n] of TUsprite;
spr_gear,
spr_toxin,
spr_mine,
spr_HMonastery,
spr_HFortress,
spr_HTotem,
spr_HAltar,
spr_HBar,
spr_db_h0,
spr_db_h1,
spr_db_u0,
spr_db_u1
: TUSprite;

spr_eff_bfg         : array[0..3] of TUsprite; //ef_bfg_
spr_eff_eb          : array[0..5] of TUsprite; //ef_eb
spr_eff_ebb         : array[0..8] of TUsprite; //ef_ebb
spr_eff_tel         : array[0..5] of TUsprite; //ef_tel
spr_eff_exp         : array[0..2] of TUsprite; //ef_exp_
spr_eff_exp2        : array[0..4] of TUsprite; //exp2_
spr_eff_g           : array[0..7] of TUsprite; //g_
spr_h_p0            : array[0..3] of TUSprite;
spr_h_p1            : array[0..3] of TUSprite;
spr_h_p2            : array[0..3] of TUSprite;
spr_h_p3            : array[0..7] of TUSprite;
spr_h_p4            : array[0..10]of TUSprite;
spr_h_p5            : array[0..7] of TUSprite;
spr_h_p6            : array[0..7] of TUSprite;
spr_h_p7            : array[0..5] of TUSprite;
spr_u_p0            : array[0..5] of TUSprite;
spr_u_p1            : array[0..3] of TUSprite;
spr_u_p2            : array[0..5] of TUSprite;
spr_u_p3            : array[0..7] of TUSprite;
spr_blood           : array[0..2] of TUSprite;

////////////////////////////////////////////////////////////////////////////////

snd_usesnd       : boolean = false;
snd_svolume      : byte = 64;
snd_mvolume      : byte = 64;
snd_ml           : array of pMIX_MUSIC;
snd_mls          : integer = 0;
snd_curm         : byte = 1;

snd_ubuild,
snd_dron0,
snd_dron1,
snd_chat,
snd_click,
snd_pexp,
snd_exp,
snd_exp2,
snd_alarm,
snd_uupgr,
snd_hupgr,
snd_cast,
snd_cast2,
snd_bfgs,
snd_bfgepx,
snd_plasmas,
snd_ssg,
snd_rico,
snd_pistol,
snd_shotgun,
snd_launch,
snd_cubes,
snd_rev_c,
snd_rev_m,
snd_rev_d,
snd_rev_a,
snd_rev_ac,
snd_hshoot,
snd_man_a,
snd_man_d,
snd_man_p,
snd_man_c,
snd_zomb,
snd_ud1,
snd_ud2,
snd_z_p,
snd_z_d1,
snd_z_d2,
snd_z_d3,
snd_z_s1,
snd_z_s2,
snd_z_s3,
snd_uac_u0,
snd_uac_u1,
snd_uac_u2,
snd_pain_c,
snd_pain_p,
snd_pain_d,
snd_mindc,
snd_mindd,
snd_mindf,
snd_cyberc,
snd_cyberd,
snd_cyberf,
snd_knight,
snd_knightd,
snd_baronc,
snd_barond,
snd_cacoc,
snd_cacod,
snd_dpain,
snd_demon1,
snd_inapc,
snd_ccup,
snd_radar,
snd_teleport,
snd_d0,
snd_meat,
snd_ar_act,
snd_ar_c,
snd_ar_d,
snd_ar_f,
snd_imp,
snd_impd1,
snd_impd2,
snd_impc1,
snd_impc2,
snd_demonc,
snd_demona,
snd_demond,
snd_hmelee,
snd_arch_a,
snd_arch_at,
snd_arch_d,
snd_arch_p,
snd_arch_c,
snd_arch_f,
snd_hellbar,
snd_hell

: pMIX_CHUNK;

////////////////////////////////////////////////////////////////////////////////

_lng             : boolean = false;

str_atargets,
str_amappoint,
str_aunit,
str_aown,
str_aalies,
str_aenemies,
str_adamaged,
str_adead,
str_aalive,
str_abio,
str_amechs,
str_abuilds,
str_anoadv,
str_aauto,
str_sstarts,
str_uiarmy,
str_uienerg,
str_uimana,
str_builders,
str_selallh,
str_selall,
str_language,
str_resol,
str_game,
str_aislots,
str_req,
str_fileerr,
str_fileerw,
str_apply,
str_randoms,
str_chat,
str_server,
str_client,
str_goptions,
str_waitsv,
str_repend,
str_replay,
str_play,
str_menu,
str_time,
str_players,
str_map,
str_save,
str_load,
str_delete,
str_gsaved,
str_pause,
str_win,
str_lose,
str_sver,
str_sfull,
str_sgst,
str_team,
str_srace,
str_ready,
str_udpport,
str_connecting,
str_pnu,
str_npnu,
str_gmodet,
str_sound,
str_soundvol,
str_musicvol,
str_video,
str_maction,
str_scrollspd,
str_mousescrl,
str_fullscreen,
str_plname,
str_mrandom,
str_MObjectives,
str_MMap,
str_MPlayers     : shortstring;

str_tabs: array[0..2] of shortstring;

str_maction2,
str_connect,
str_svup,
str_lng,
str_tarchat,
str_exit,
str_reset        : array[false..true] of shortstring;

str_menu_s1,
str_menu_s2      : array[0..2] of shortstring;
str_gmode        : array[0..2] of shortstring;

str_rpl          : array[0..5] of shortstring = ('OFF','REC','REC','PLAY','PLAY','END');

str_pnua,
str_npnua        : array[0..9] of shortstring;

str_svld_errors  : array[1..4] of shortstring;

{

 true false

str_cmpd
str_startat      : array[0..3] of shortstring;
str_cmpdif,
str_inv_ml,
str_inv_time,
str_player_def,

str_npnua,
str_pnua,
str_cmpd         : array[0..4] of shortstring;

str_hint_m       : array[0..2] of shortstring;
str_hint         : array[0..2,1..2,0..26] of shortstring;
str_losst        : array[0..2] of shortstring;

 }

{$ELSE}

_cons            : array[1..maxCons] of shortstring;
_consi           : byte = 1;
_crt             : byte = 0;

{$ENDIF}





