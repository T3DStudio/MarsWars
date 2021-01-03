
var

_CYCLE            : boolean = false;
_EVENT            : pSDL_EVENT;

////////////////////////////////////////////////////////////////////////////////
//
//  GAME
//

g_Addon           : boolean = true;
g_Started         : boolean = false;
g_Paused          : byte = 0;
g_WTeam           : byte = 255;
g_mode            : byte = 0;
g_startb          : byte = 0;
g_shpos           : boolean = false;
g_aislots         : byte = 5;
g_step            : cardinal = 0;
g_plstat          : byte = 0;
g_nunits          : integer = 0;

g_inv_mn          : byte = 0;
g_inv_wn          : byte = 0;
g_inv_t           : integer = 0;
g_inv_wt          : integer = 0;
g_cpt_pl          : array[1..MaxCPoints] of TCTPoint;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

onlySVCode        : boolean = true; // only server side code

UnitStepNum       : byte = 8;

_players          : TPList;
_units            : array[0..MaxUnits   ] of TUnit;
_missiles         : array[1..MaxUnits   ] of TMissile;

_uclord_c         : integer = 0;
_uregen_c         : integer = 0;

_uids             : array[byte] of TUID;
_upids            : array[byte] of TUpgrade;

_lsuc             : byte = 0;
_lcu              : integer = 0;
_lcup             : PTUnit;

{tar1p             : integer;
ai_builders,
ai_uprods,
ai_pprods,
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
ai_bd             : integer;  }

HPlayer           : byte = 1;

team_army         : array[0..MaxPlayers] of integer;

vid_mredraw       : boolean = true;

map_seed          : cardinal = 1;
map_seed2         : word = 0;
map_mw            : integer = 5000;
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
_fsttime          : boolean = false;

r_panel,
r_uipanel,
r_empty,
r_minimap,
r_bminimap,
r_screen,
r_dterrain,
r_menu            : pSDL_SURFACE;
_vflags           : cardinal = SDL_HWSURFACE;   //SDL_SWSURFACE

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

PlayerName        : shortstring = 'DoomPlayer';
PlayerTeam        : byte = 1;
PlayerReady       : boolean = false;
PlayerRace        : byte = 0;

PlayerColor       : array[0..MaxPlayers] of cardinal;

vid_vw            : integer = 800;
vid_vh            : integer = 600;
vid_sw            : integer = 800;
vid_sh            : integer = 600;
vid_vmb_x0        : integer = 6;
vid_vmb_y0        : integer = 6;
vid_vmb_x1        : integer = 794;
vid_vmb_y1        : integer = 594;
vid_mwa           : integer = 0;
vid_mha           : integer = 0;
vid_terrain       : pSDL_SURFACE;
vid_rtui          : byte = 0;
vid_vx            : integer = 0;
vid_vy            : integer = 0;
vid_vmspd         : integer = 25;
vid_mmvx,
vid_mmvy          : integer;
vid_uhbars        : byte = 0;
vid_plcolors      : byte = 0;
vid_vmm           : boolean = false;
vid_ppos          : byte = 0;
vid_panelx        : integer = 0;
vid_panely        : integer = 0;
vid_mapx          : integer = 0;
vid_mapy          : integer = 0;
vid_vsl           : array[1..vid_mvs] of PTVisSpr;
vid_vsls          : word = 0;

ter_w,
ter_h             : integer;

font_ca           : array[char] of pSDL_SURFACE;

_effects          : array[1..vid_mvs     ] of TEff;

MaxTDecsS         : integer = 0;      //960 720
_TDecs            : array of TDecal;

map_mmcx          : single;
map_mmvw,
map_mmvh,
map_prmm          : integer;

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
_rpls_vidx        : byte = 0;
_rpls_vidy        : byte = 0;
_rpls_vidm        : boolean = false;
_rpls_log         : boolean = false;
_rpls_player      : byte = 0;

_cmp_sm           : integer = 0;
_cmp_sel          : integer = 0;

fog_grid          : array[0..fog_vfwm,0..fog_vfhm] of byte;
fog_pgrid         : array[0..fog_vfwm,0..fog_vfhm] of byte;
fog_vfw           : byte = 0;
fog_vfh           : byte = 0;
_fog              : boolean = true;
_fcx              : array[0..MFogM,0..MFogM] of byte;
fog_surf          : pSDL_Surface;
vid_fsx           : integer = 0;
vid_fsy           : integer = 0;
vid_fex           : integer = 0;
vid_fey           : integer = 0;

_lng              : boolean = false;

_m_sel,
m_sxs,
m_sys,
m_mx,
m_my,
m_vx,
m_vy              : integer;
m_ldblclk,
m_brushc          : cardinal;
m_brush           : integer;
m_bx,
m_by              : integer;
m_vmove           : boolean = false;
m_a_inv           : boolean = false;

ui_puids          : array[0..r_cnt,0..2,0..ui_ubtns] of byte;
ui_ordn,
ui_ordx,
ui_ordy           : array[0..10] of integer;
ui_orderu         : array[0..9 ] of TSob;
ui_mc_x,
ui_mc_y,
ui_mc_a           : integer;
ui_mc_c           : cardinal;
ui_panelmmm       : boolean = false;
ui_tab            : byte = 0;
ui_muc            : array[false..true] of cardinal;
ui_builders_x     : array[0..ui_builder_srs] of integer;
ui_builders_y     : array[0..ui_builder_srs] of integer;
ui_builders_r     : array[0..ui_builder_srs] of integer;
ui_units_ptime    : array[byte] of integer;
ui_units_prodc    : array[byte] of integer;
ui_units_proda    : integer = 0;
ui_uimove         : integer = 0; // ui move buttons
ui_uiaction       : integer = 0; // ui action button
ui_battle_units   : integer = 0; // ui select all button
ui_upgrct         : array[byte] of byte;
ui_upgr_time      : integer = 0;
ui_upgr           : array[byte] of integer;
ui_units_inapc    : array[byte] of integer;
ui_prod_units     : array[byte] of integer;
ui_prod_builds    : TSoB;
ui_blds           : array[byte] of integer;
ui_bldsc          : integer;
ui_alrms          : array[0..vid_uialrm_n] of TAlarm;
ui_umark_u        : integer = 0;
ui_umark_t        : byte = 0;
ui_msk            : byte = 0;
ui_msks           : shortint = 0;
ui_rad_rld        : array[false..true] of cardinal;

ui_uiuphx         : integer = 0;
ui_ingamecl       : byte = 0;
ui_textx          : integer = 0;  // timer/chat screen X
ui_texty          : integer = 0;  // timer/chat screen Y
ui_hinty          : integer = 0;  // hints screen Y
ui_chaty          : integer = 0;  // chat screen Y
ui_oicox          : integer = 0;  // order icons screen X
ui_iy             : integer = 0;
ui_energx         : integer = 0;
ui_armyx          : integer = 0;

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

fps_tt,
fps_cs,
fps_ns            : cardinal;

//theme

theme_i           : integer = 0;

theme_liquid_animt: byte;
theme_liquid_animm: byte;
theme_liquid_color: cardinal = 0;

theme_map_trt     : integer=0;
theme_map_ptrt    : integer = -1;
theme_map_crt     : integer=0;
theme_map_pcrt    : integer = -1;
theme_map_lqt     : integer=0;
theme_map_plqt    : integer = -1;
theme_map_blqt    : integer=0;
theme_map_pblqt   : integer = -1;
theme_liquid_style: byte = 0;
theme_crater_style: byte = 0;

theme_decals,
theme_decors,
theme_srocks,
theme_brocks,
theme_craters,
theme_liquids,
theme_bliquids,
theme_terrains    : TIntList;
theme_decaln,
theme_decorn,
theme_srockn,
theme_brockn,
theme_cratern,
theme_liquidn,
theme_bliquidn,
theme_terrainn    : integer;

theme_spr_decals,
theme_spr_decors,
theme_spr_srocks,
theme_spr_brocks,
theme_spr_liquids,
theme_spr_terrains: TUSpriteList;
theme_spr_decaln,
theme_spr_decorn,
theme_spr_srockn,
theme_spr_brockn,
theme_spr_liquidn,
theme_spr_terrainn: integer;

theme_anm_decors,
theme_anm_srocks,
theme_anm_brocks  : TThemeAnimL;

theme_anm_liquids : array of byte;     // animation type
theme_ant_liquids : array of byte;     // animation period
theme_clr_liquids : array of cardinal; // minimap color

spr_liquidb       : array[1..LiquidRs ] of TMWSprite;
spr_liquid        : array[1..LiquidAnim,1..LiquidRs] of TMWSprite;
spr_crater        : array[1..crater_ri] of TMWSprite;


spr_dummy         : TMWSprite;
pspr_dummy        : PTMWSprite;

spr_dmodel,

spr_lostsoul,
spr_imp ,
spr_demon,
spr_cacodemon,
spr_baron,
spr_knight,
spr_cyberdemon,
spr_mastermind,
spr_pain,
spr_revenant,
spr_mancubus,
spr_arachnotron,
spr_archvile,
spr_ZFormer,
spr_ZEngineer,
spr_ZSergant,
spr_ZSSergant,
spr_ZCommando,
spr_ZBomber,
spr_ZFMajor,
spr_ZMajor,
spr_ZBFG,

spr_engineer,
spr_medic,
spr_sergant,
spr_ssergant,
spr_commando,
spr_bomber,
spr_fmajor,
spr_major,
spr_BFG,
spr_FAPC,
spr_APC,
spr_Terminator,
spr_Tank,
spr_Flyer,
spr_trans,

spr_HKeep,
spr_HGate,
spr_HAGate,
spr_HSymbol,
spr_HPools,
spr_HAPools,
spr_HTower,
spr_HTeleport,
spr_HMonastery,
spr_HTotem,
spr_HAltar,
spr_HFortress,
spr_HCC,
spr_HMUnit,
spr_HMUnita,
spr_HEye,

spr_UCommandCenter,
spr_UMilitaryUnit,
spr_UAMilitaryUnit,
spr_UGenerator,
spr_UWeaponFactory,
spr_UAWeaponFactory,
spr_UTurret,
spr_URadar,
spr_UVehicleFactory,
spr_UPTurret,
spr_URTurret,
spr_UNuclearPlant,
spr_URocketL,
spr_Mine,
//spr_u_portal,

spr_eff_bfg,
spr_eff_eb,
spr_eff_ebb,
spr_eff_tel,
spr_eff_exp,
spr_eff_exp2,
spr_eff_g,
spr_h_p0,
spr_h_p1,
spr_h_p2,
spr_h_p3,
spr_h_p4,
spr_h_p5,
spr_h_p6,
spr_h_p7,
spr_u_p0,
spr_u_p1,
spr_u_p2,
spr_u_p3,

spr_blood         : TMWSModel;
spr_pdmodel       : PTMWSModel;

spr_mp,
spr_gear,
spr_toxin,

spr_db_h0,
spr_db_h1,
spr_db_u0,
spr_db_u1         : TMWSprite;


spr_c_mars,
spr_c_hell,
spr_c_earth,
spr_c_phobos,
spr_c_deimos ,
spr_b_rfast,
spr_b_rskip,
spr_b_rfog,
spr_b_rclck,
spr_b_rlog,
spr_b_rstop,
spr_b_rvis,
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
//spr_b_b           : array[1..r_cnt,byte] of pSDL_Surface;
//spr_b_u           : array[1..r_cnt,byte] of pSDL_Surface;
//spr_b_up          : array[1..r_cnt,0..ui_ubtns] of pSDL_Surface;
spr_tabs          : array[0..3] of pSDL_Surface;

//spr_ui_oico       : array[1..r_cnt,false..true,byte] of pSDL_Surface;

/// text


str_pcolors       : array[0..4] of shortstring;
str_uhbars        : array[0..2] of shortstring;
str_panelposp     : array[0..3] of shortstring;
str_panelpos,
str_uhbar,
str_pcolor,
str_all,
str_orders,
str_req,
str_uprod,
str_bprod,
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
str_hint_a        : array[0..1] of shortstring;
str_hint_m        : array[0..2] of shortstring;
str_hint          : array[0..3,1..r_cnt,byte] of shortstring;
str_rpl           : array[0..5] of shortstring = ('OFF','REC','REC','PLAY','PLAY','END');
str_svld_errors   : array[1..4] of shortstring;
str_camp_t        : array[0..MaxMissions] of shortstring;
str_camp_o        : array[0..MaxMissions] of shortstring;
str_camp_m        : array[0..MaxMissions] of shortstring;



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

snd_build         : array[1..r_cnt] of pMIX_CHUNK;

snd_jetpoff,
snd_jetpon,
snd_oof,
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













