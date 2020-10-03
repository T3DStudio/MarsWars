
var

_CYCLE            : boolean = false;
_EVENT            : pSDL_EVENT;

G_Addon           : boolean = true;
G_Started         : boolean = false;
G_Paused          : byte = 0;
G_WTeam           : byte = 255;
G_mode            : byte = 0;
G_startb          : byte = 0;
G_shpos           : boolean = false;
G_aislots         : byte = 5;
G_step            : cardinal = 0;
G_plstat          : byte = 0;

g_inv_mn          : byte = 0;
g_inv_wn          : byte = 0;
g_inv_t           : integer = 0;
g_inv_wt          : integer = 0;
g_ct_pl           : array[1..MaxPlayers] of TCTPoint;

onlySVCode        : boolean = true;

UnitStepNum       : byte = 8;

_units            : array[0..MaxUnits  ] of TUnit;
_players          : TPList;
_missiles         : array[1..MaxUnits   ] of TMissile;

_uclord_c         : integer = 0;
_uregen_c         : integer = 0;

_ulst             : array[byte] of TUnit;
upgrade_time      : array[1..2,0.._uts] of integer;
upgrade_cnt       : array[1..2,0.._uts] of byte;
upgrade_ruid      : array[1..2,0.._uts] of byte;
upgrade_rupgr     : array[1..2,0.._uts] of byte;
upgrade_mfrg      : array[1..2,0.._uts] of boolean;

_lsuc             : byte = 0;
_lcu              : integer = 0;
_lcup             : PTUnit;
cl2uid            : array[1..2,false..true,0.._uts] of byte;

ai_pt,
ai_ptd,
ai_uc_e,
ai_uc_a,
ai_apcd,
ai_ux,
ai_uy,
ai_ud,
ai_bx,
ai_by,
ai_bd             : integer;

_pne_r            : array[1..2,0.._uts] of byte;

HPlayer           : byte = 1;

team_army         : array[0..MaxPlayers] of integer;

vid_mredraw       : boolean = true;

map_seed          : cardinal = 1;
map_seed2         : word = 0;
map_mw            : integer = 5000;
//map_mwc           : integer = 0;
map_aifly         : boolean = false;
map_b1            : integer;
map_obs           : byte = 1;
map_liq           : byte = 1;
map_psx           : array[0..MaxPlayers] of integer;
map_psy           : array[0..MaxPlayers] of integer;
map_dds           : array[1..MaxDoodads] of TDoodad;
map_dcell         : array[0..dcn,0..dcn] of TDCell;

net_chatls        : array[0..MaxPlayers] of byte; // local state
net_chatss        : array[0..MaxPlayers] of byte; // server state
net_chat          : array[0..MaxPlayers,0..MaxNetChat] of shortstring;
net_nstat         : byte = 0;
net_sv_port       : word = 10666;
net_socket        : PUDPSocket;
net_buf           : PUDPpacket;
net_period        : byte = 0;


_rpls_file        : file;
_rpls_u           : integer = 0;
_rpls_pnui        : byte = 0;

str_startat       : array[0..5] of shortstring;
str_race          : array[0..2] of shortstring;
str_gmode         : array[0..5] of shortstring;
str_addon         : array[false..true] of shortstring;
str_m_liq,
str_m_siz,
str_m_obs,
str_plname,
str_aislots,
str_team,
str_srace,
str_ready,
str_sstarts,
str_gaddon,
str_gmodet,
str_starta,
str_plout,
str_player_def : shortstring;

{$IFDEF _FULLGAME}

_warpten          : boolean = false;
_testmode         : byte = 0;
_testdmg          : boolean = false;
_fsttime          : boolean = false;

spr_panel,
_uipanel,
_dsurf,
_minimap,
_bminimap,
_SCREEN,
_menu_surf        : pSDL_SURFACE;
_vflags           : cardinal = SDL_SWSURFACE;

_RECT             : pSDL_RECT;

_fscr             : boolean = false;
_igchat           : boolean = false;
_draw             : boolean = true;

_menu             : boolean = true;
menu_s1           : byte = ms1_sett;
menu_s2           : byte = ms2_scir;
menu_s3           : byte = ms3_game;

m_chat            : boolean = false;

m_vrx,
m_vry,
mv_x,
mv_y              : integer;

PlayerName        : shortstring = 'Player';
PlayerTeam        : byte = 1;
PlayerReady       : boolean = false;
PlayerRace        : byte = 0;

plcolor           : array[0..MaxPlayers] of cardinal;

vid_mw            : integer = 800;
vid_mh            : integer = 600;
vid_vmb_x0        : integer = 6;
vid_vmb_y0        : integer = 6;
vid_vmb_x1        : integer = 794;
vid_vmb_y1        : integer = 594;
vid_mwa           : integer = 0; //vid_mw+vid_ab;
vid_mha           : integer = 0; //vid_mh+vid_ab*2;
vid_uiuphx        : integer = 0;
vid_ingamecl      : byte = 0;

vid_terrain       : pSDL_SURFACE;
vid_rtui          : byte = 0;

ter_w,
ter_h             : integer;

font_ca           : array[char] of pSDL_SURFACE;

_effects          : array[1..vid_mvs     ] of TEff;

MaxTDecsS         : byte = 0;      //960 720
_TDecs            : array of TTDec;

map_trt           : byte=0;
map_ptrt          : byte = 255;
map_crt           : byte=0;
map_pcrt          : byte = 255;
map_lqt           : byte=0;
map_plqt          : byte = 255;
map_mm_liqc       : cardinal = 0;
map_mmcx          : single;
map_mmvw,
map_mmvh,
map_prmm          : integer;
map_flydpth       : array[0..2] of integer;
map_hell          : boolean = true;

cmp_skill         : byte = 3;
cmp_mmap          : array[0..MaxMissions] of pSDL_Surface;
cmp_ait2p         : word = 0;

net_cl_svip       : cardinal = 0;
net_cl_svport     : word = 10666;
net_cl_svttl      : integer = 0;
net_cl_svpl       : byte = 0;
net_m_error       : shortstring = '';
net_sv_pstr       : shortstring = '10666';
net_cl_svstr      : shortstring = '127.0.0.1:10666';
net_chat_shlm     : integer = 0;
net_chat_str      : shortstring = '';
net_chat_tar      : byte = 255;
net_pnui          : byte = 4;

_svld_stat        : shortstring = '';
_svld_str         : shortstring = '';
_svld_l           : array of shortstring;
_svld_ln          : integer = 0;
_svld_ls          : integer = 0;
_svld_sm          : integer = 0;

_rpls_fileo       : boolean = false;
_rpls_pnu         : byte = 0;
_rpls_lrname      : shortstring = 'LastReplay';
_rpls_stat        : shortstring = '';
_rpls_rst         : byte = rpl_none;
_rpls_l           : array of shortstring;
_rpls_ln          : integer = 0;
_rpls_ls          : integer = 0;
_rpls_sm          : integer = 0;
_rpls_step        : integer = 1;
_rpls_nwrch       : boolean = false;
_rpls_log         : boolean = false;

_cmp_sm           : integer = 0;
_cmp_sel          : integer = 0;

vid_vx            : integer = 0;
vid_vy            : integer = 0;
vid_vmspd         : integer = 25;
vid_mmvx,
vid_mmvy          : integer;
vid_vmm           : boolean = false;

vid_vsl           : array[1..vid_mvs] of TVisSpr;
vid_vsls          : word = 0;

fog_grid          : array[0..fog_vfwm,0..fog_vfhm] of byte;
fog_pgrid         : array[0..fog_vfwm,0..fog_vfhm] of byte;
fog_vfw           : byte = 0;
fog_vfh           : byte = 0;
_fog              : boolean = true;
_fcx              : array[0..MFogM,0..MFogM] of byte;
fog_surf          : array[false..true] of pSDL_Surface;
vid_fsx           : integer = 0;
vid_fsy           : integer = 0;
vid_fex           : integer = 0;
vid_fey           : integer = 0;

_lng              : boolean = false;

ordn,
ordx,
ordy              : array[0..9] of integer;

_m_sel,
m_sxs,
m_sys,
m_mx,
m_my,
m_vx,
m_vy              : integer;
m_ldblclk,
m_sbuildc         : cardinal;
m_sbuild          : integer;
m_bx,
m_by              : byte;
m_vmove           : boolean = false;
m_a_inv           : boolean = false;

ui_mc_x,
ui_mc_y,
ui_mc_a           : integer;
ui_mc_c           : cardinal;

ui_panelmmm       : boolean = false;
ui_tab            : byte = 0;
ui_bldrs_x        : array[0.._uts] of integer;
ui_bldrs_y        : array[0.._uts] of integer;
ui_bldrs_r        : array[0.._uts] of integer;
ui_muc            : array[false..true] of cardinal;
//ui_mupc           : array[false..true] of cardinal;
ui_trnt           : array[0.._uts] of integer;
ui_trntc          : array[0.._uts] of integer;
ui_trntca         : integer = 0;
ui_uimove         : integer = 0;
ui_uselected      : integer = 0;
ui_uiaction       : integer = 0;
ui_upgrc          : byte;
ui_upgrct         : array[0.._uts] of byte;
ui_upgrl          : integer = 0;
ui_upgr           : array[0.._uts] of integer;
ui_apc            : array[0.._uts] of integer;
ui_blds           : array[0.._uts] of integer;
ui_bldsc          : integer;
ui_alrms          : array[0..vid_uialrm_n] of TAlarm;
ui_umark_u        : integer = 0;
ui_umark_t        : byte = 0;
ui_msk            : byte = 0;
ui_msks           : shortint = 0;
ui_orderu         : array[0..9,false..true] of TSob;
ui_rad_rld        : array[false..true] of cardinal;

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
k_chrt            : cardinal;
k_chr             : char;

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
c_gray,
c_dgray,
c_ablack,
c_purple,
c_black           : cardinal;

fps_cs,
fps_ns            : cardinal;

spr_liquid        : array[1..LiquidAnim,0..3] of TUSprite;
spr_tdecs,
spr_tdecsh,
spr_decs,
spr_decsh,
spr_srocks,
spr_srocksh,
spr_brocks,
spr_brocksh
                  : TUSpriteL;
spr_tdecsi,
spr_tdecshi,
spr_decsi,
spr_decshi,
spr_srocksi,
spr_srockshi,
spr_brocksi,
spr_brockshi,
t_decsi           : integer;

spr_crater        : array[1..crater_ri] of TUSprite;

spr_dummy         : TUsprite;

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
spr_ZEngineer     : array[0..31] of TUSprite;
spr_ZSergant      : array[0..52] of TUSprite;
spr_ZSSergant     : array[0..52] of TUSprite;
spr_ZCommando     : array[0..59] of TUSprite;
spr_ZBomber       : array[0..52] of TUSprite;
spr_ZFMajor       : array[0..15] of TUSprite;
spr_ZMajor        : array[0..52] of TUSprite;
spr_ZBFG          : array[0..52] of TUSprite;

spr_engineer      : array[0..44] of TUSprite;
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

//spr_HTa : TUsprite;

spr_UCommandCenter,
spr_UMilitaryUnit,
spr_UGenerator,
spr_UWeaponFactory,
spr_UTurret,
spr_URadar,
spr_UVehicleFactory,
spr_UPTurret,
spr_URTurret,
spr_URocketL      : array[0..3]  of TUsprite;

spr_eff_bfg       : array[0..3] of TUsprite; //ef_bfg_
spr_eff_eb        : array[0..5] of TUsprite; //ef_eb
spr_eff_ebb       : array[0..8] of TUsprite; //ef_ebb
spr_eff_tel       : array[0..5] of TUsprite; //ef_tel
spr_eff_exp       : array[0..2] of TUsprite; //ef_exp_
spr_eff_exp2      : array[0..4] of TUsprite; //exp2_
spr_eff_g         : array[0..7] of TUsprite; //g_
spr_h_p0          : array[0..3] of TUSprite;
spr_h_p1          : array[0..3] of TUSprite;
spr_h_p2          : array[0..3] of TUSprite;
spr_h_p3          : array[0..7] of TUSprite;
spr_h_p4          : array[0..10]of TUSprite;
spr_h_p5          : array[0..7] of TUSprite;
spr_h_p6          : array[0..7] of TUSprite;
spr_h_p7          : array[0..5] of TUSprite;
spr_u_p0          : array[0..5] of TUSprite;
spr_u_p1          : array[0..3] of TUSprite;
spr_u_p2          : array[0..5] of TUSprite;
spr_u_p3          : array[0..3] of TUSprite;
spr_trans         : array[0..7] of TUSprite;
spr_sport         : array[0..1] of TUSprite;
spr_blood         : array[0..2] of TUSprite;
spr_ubase         : array[0..5] of TUSprite;
spr_cbuild        : array[0..3] of TUSprite;
spr_mp            : array[1..2] of TUsprite;
spr_gear,
spr_toxin,
spr_mine,
spr_HFortress,
spr_HMonastery,
spr_HTotem,
spr_HAltar,
spr_HBar,
spr_HEye,
spr_db_h0,
spr_db_h1,
spr_db_u0,
spr_db_u1,
spr_u_portal      : TUSprite;

spr_c_mars,
spr_c_hell,
spr_c_earth,
spr_c_phobos,
spr_c_deimos ,
spr_b_rfast,
spr_b_rskip,
spr_b_rfog,
spr_b_rlog,
spr_b_rstop,
spr_b_action,
spr_b_attack,
spr_b_move,
spr_b_patrol,
spr_b_apatrol,
spr_b_stop,
spr_b_hold,
spr_b_selall,
spr_b_cancel,
spr_b_delete,
spr_b_knight,
spr_b_baron,
spr_iob_knight,
spr_iob_baron,
spr_mback,
spr_cursor        : pSDL_Surface;
spr_b_b           : array[1..2,0.._uts] of pSDL_Surface;
spr_b_u           : array[1..2,0.._uts] of pSDL_Surface;
spr_b_up          : array[1..2,0..MaxUpgrs] of pSDL_Surface;
spr_tabs          : array[0..3] of pSDL_Surface;

spr_ui_oico       : array[1..2,false..true,0.._uts] of pSDL_Surface;

/// text

str_all,
str_orders,
str_req,
str_language,
str_resol,
str_apply,
str_randoms,
str_chattars,
str_chat,
str_server,
str_client,
str_goptions,
str_waitsv,
str_cmpdif,
str_repend,
str_replay,
str_play,
str_inv_ml,
str_inv_time,
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
str_udpport,
str_connecting,
str_pnu,
str_npnu,
str_soundvol,
str_musicvol,
str_maction,
str_scrollspd,
str_mousescrl,
str_fullscreen,
str_mrandom,
str_MObjectives,
str_MMap,
str_MPlayers      : shortstring;
str_npnua,
str_pnua          : array[0..9] of shortstring;
str_cmpd          : array[0..CMPMaxSkills] of shortstring;
str_hint_t        : array[0..3] of shortstring;
str_hint_m        : array[0..2] of shortstring;
str_hint          : array[0..3,1..2,0.._uts] of shortstring;
str_rpl           : array[0..5] of shortstring = ('OFF','REC','REC','PLAY','PLAY','END');
str_svld_errors   : array[1..4] of shortstring;
str_camp_t        : array[0..MaxMissions] of shortstring;
str_camp_o        : array[0..MaxMissions] of shortstring;
str_camp_m        : array[0..MaxMissions] of shortstring;

str_un_name,
str_un_descr,
str_un_hint,
str_up_name,
str_up_descr,
str_up_hint       : array[0..255] of shortstring;

str_connect,
str_svup,
str_lng,
str_maction2,
str_exit,
str_reset         : array[false..true] of shortstring;
str_menu_s1,
str_menu_s2,
str_menu_s3       : array[0..2] of shortstring;


// sounds

snd_svolume       : byte = 64;
snd_mvolume       : byte = 64;
snd_ml            : array of pMIX_MUSIC;
snd_mls           : integer = 0;
snd_curm          : byte = 1;

snd_build         : array[1..2] of pMIX_CHUNK;

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
snd_fly_a1,
snd_fly_a,
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
snd_click,
snd_chat,
snd_inapc,
snd_ccup,
snd_radar,
snd_teleport,
snd_pexp,
snd_exp,
snd_exp2,
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
snd_hell,
snd_hpower        : pMIX_CHUNK;


{$ELSE}

consoley : integer = 0;
str_m_seed,
str_plstat: shortstring;

{$ENDIF}













