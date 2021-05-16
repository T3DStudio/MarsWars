
var

_CYCLE            : boolean = false;
_EVENT            : pSDL_EVENT;

////////////////////////////////////////////////////////////////////////////////
//
//  GAME
//

g_addon           : boolean  = true;
g_started         : boolean  = false;
g_paused          : byte     = 0;
g_wteam           : byte     = 255;
g_mode            : byte     = 0;
g_startb          : byte     = 0;
g_shpos           : boolean  = false;
g_aislots         : byte     = 5;
g_step            : cardinal = 0;
g_plstat          : byte     = 0;
g_nunits          : integer  = 0;

g_inv_monsters    : byte = 0;
g_inv_wave_n      : byte = 0;
g_inv_time        : integer = 0;
g_inv_wave_t      : integer = 0;
g_cpoints         : array[1..MaxCPoints] of TCTPoint;
g_royal_r         : integer = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

ServerSide        : boolean = true; // only server side code

UnitStepNum       : byte = 8;

_players          : TPList;
_units            : array[0..MaxUnits   ] of TUnit;
_missiles         : array[1..MaxMissiles] of TMissile;

_uclord_c         : integer = 0;
_uregen_c         : integer = 0;

_uids             : array[byte] of TUID;
_upids            : array[byte] of TUPID;
_mids             : array[byte] of TMID;

_LastCreatedUnit  : integer = 0;
_LastCreatedUnitP : PTUnit;

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

vid_mredraw       : boolean  = true;

map_seed          : cardinal = 1;
map_rpos          : byte = 0;
map_iseed         : word     = 0;
map_mw            : integer  = 5000;
map_hmw           : integer  = 2500;
map_b1            : integer  = 0;
map_obs           : byte     = 1;
map_liq           : byte     = 1;
map_sym           : boolean  = true;
map_psx           : array[0..MaxPlayers] of integer;
map_psy           : array[0..MaxPlayers] of integer;
map_dds           : array[0..MaxDoodads] of TDoodad;
map_ddn           : integer = 0;
map_dcell         : array[0..dcn,0..dcn] of TDCell;

net_chatls        : array[0..MaxPlayers] of byte; // local state
net_chatss        : array[0..MaxPlayers] of byte; // server state
net_chat          : array[0..MaxPlayers,0..MaxNetChat] of shortstring;
net_nstat         : byte = 0;
net_sv_port       : word = 10666;
net_socket        : PUDPSocket;
net_buf           : PUDPPacket;
net_period        : byte = 0;

_rpls_file        : file;
_rpls_u           : integer = 0;
_rpls_pnui        : byte = 0;

str_startat       : array[0..gms_g_startb] of shortstring;
str_race          : array[0..r_cnt] of shortstring;
str_gmode         : array[0..gm_cnt] of shortstring;
str_addon         : array[false..true] of shortstring;
str_m_liq,
str_m_siz,
str_m_obs,
str_m_sym,
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
str_player_def    : shortstring;

fps_tt,
fps_cs,
fps_ns            : cardinal;

{$IFDEF _FULLGAME}

tmpmid            : byte = MID_Imp;

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

_eids             : array[byte] of TEID;
_effects          : array[1..vid_mvs] of TEffect;

_tdecaln          : integer = 0;
_tdecals          : array of TDecal;

map_mmcx          : single;
map_mmvw,
map_mmvh,
map_prmm          : integer;

cmp_skill         : byte = 3;
cmp_mmap          : array[0..MaxMissions] of pSDL_Surface;

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
m_brushx,
m_brushy,
m_brush           : integer;
m_bx,
m_by              : integer;
m_vmove           : boolean = false;
m_a_inv           : boolean = false;
m_mmap_move       : boolean = false;

ui_UnitSelectedNU : integer = 0;
ui_UnitSelectedpU : integer = 0;
ui_UnitSelectedn  : byte = 0;
ui_tab            : byte = 0;
ui_panel_uids     : array[0..r_cnt,0..2,0..ui_ubtns] of byte;
ui_alarms         : array[0..ui_max_alarms] of TAlarm;

ui_orders_n,                                             //
ui_orders_x,                                             //
ui_orders_y       : array[0..10] of integer;             //
ui_orders_uids    : array[0..9,false..true] of TSob;     //

ui_mc_x,                                                 //
ui_mc_y,                                                 // mouse click effect
ui_mc_a           : integer;                             //
ui_mc_c           : cardinal;                            //

ui_builders_n     : integer = 0;
ui_builders_x     : array[0..ui_builder_srs] of integer; //
ui_builders_y     : array[0..ui_builder_srs] of integer; // builders areas
ui_builders_r     : array[0..ui_builder_srs] of integer; //

ui_first_upgr_time: integer = 0;
ui_upgr           : array[byte] of integer;
ui_units_inapc    : array[byte] of integer;
ui_prod_units     : array[byte] of integer;
ui_units_ptime    : array[byte] of integer;
ui_prod_builds    : TSoB;
ui_uid_builds     : array[byte] of integer;
ui_uid_buildn     : integer;
ui_uid_reload     : array[byte] of integer;
ui_uibtn_move     : integer = 0; // ui move buttons
ui_uibtn_action   : integer = 0; // ui action button
ui_uibtn_f2       : integer = 0; // ui select all button
ui_upgrct         : array[byte] of byte;
ui_umark_u        : integer = 0;
ui_umark_t        : byte = 0;
ui_muc            : array[false..true] of cardinal; // unit max count color

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
k_chart           : cardinal;
k_char            : char;
k_kstring         : shortstring = '';

////////////////////////////////////////////////////////////////////////////////
//
//  COLORS
//

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

////////////////////////////////////////////////////////////////////////////////
//
//  THEMES
//

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


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITES
//

spr_liquidb       : array[1..LiquidRs ] of TMWTexture;
spr_liquid        : array[1..LiquidAnim,1..LiquidRs] of TMWTexture;
spr_crater        : array[1..crater_ri] of TMWTexture;


spr_dummy         : TMWTexture;
pspr_dummy        : PTMWTexture;

spr_dmodel,

spr_LostSoul,
spr_Imp ,
spr_Demon,
spr_Cacodemon,
spr_Baron,
spr_Knight,
spr_Cyberdemon,
spr_Mastermind,
spr_Pain,
spr_Revenant,
spr_Mancubus,
spr_Arachnotron,
spr_ArchVile,
spr_ZFormer,
spr_ZEngineer,
spr_ZSergant,
spr_ZSSergant,
spr_ZCommando,
spr_ZBomber,
spr_ZFMajor,
spr_ZMajor,
spr_ZBFG,

spr_Engineer,
spr_Medic,
spr_Sergant,
spr_SSergant,
spr_Commando,
spr_Bomber,
spr_FMajor,
spr_Major,
spr_BFG,
spr_FAPC,
spr_APC,
spr_Terminator,
spr_Tank,
spr_Flyer,
spr_Transport,

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
spr_UFactory,
spr_UAFactory,
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

spr_db_h0,
spr_db_h1,
spr_db_u0,
spr_db_u1,

spr_blood         : TMWSModel;
spr_pdmodel       : PTMWSModel;

spr_mp            : array[1..r_cnt] of TMWTexture;
spr_gear,
spr_toxin

                  : TMWTexture;


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
spr_b_paction,
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
spr_b_up          : array[1..r_cnt,0..spr_upgrade_icons] of TMWTexture;
spr_tabs          : array[0..3] of pSDL_Surface;

//spr_ui_oico       : array[1..r_cnt,false..true,byte] of pSDL_Surface;


////////////////////////////////////////////////////////////////////////////////
//
//  TEST
//

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


////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

snd_svolume        : byte = 64;
snd_mvolume        : byte = 64;
snd_music_list     : array of pMIX_MUSIC;
snd_music_list_size: integer = 0;
snd_current_music  : integer = 0;
snd_anoncer_pause  : integer = 0;
snd_anoncer_last   : PTSoundSet;
snd_unit_cmd_pause : integer = 0;
snd_unit_cmd_last  : PTSoundSet;


snd_under_attack   : array[false..true,1..r_cnt] of PTSoundSet;
snd_build_place,
snd_building,
snd_cannot_build,
snd_constr_complete,
snd_defeat,
snd_not_enough_energy,
snd_player_defeated,
snd_upgrade_complete,
snd_victory
                   : array[1..r_cnt] of PTSoundSet;

snd_radar,

snd_uac_cc,
snd_uac_barracks,
snd_uac_generator,
snd_uac_smith,
snd_uac_ctower,
snd_uac_radar,
snd_uac_rtower,
snd_uac_factory,
snd_uac_tech,
snd_uac_rls,
snd_uac_nucl,
snd_uac_suply,
snd_uac_rescc,

snd_uac_reload,
snd_uac_hdeath,

snd_APC_ready,
snd_APC_move,

snd_bfgmarine_ready,
snd_bfgmarine_annoy,
snd_bfgmarine_attack,
snd_bfgmarine_select,
snd_bfgmarine_move,

snd_commando_ready,
snd_commando_annoy,
snd_commando_attack,
snd_commando_select,
snd_commando_move,

snd_engineer_ready,
snd_engineer_annoy,
snd_engineer_attack,
snd_engineer_select,
snd_engineer_move,

snd_medic_ready,
snd_medic_annoy,
snd_medic_select,
snd_medic_move,

snd_plasmamarine_ready,
snd_plasmamarine_annoy,
snd_plasmamarine_attack,
snd_plasmamarine_select,
snd_plasmamarine_move,

snd_rocketmarine_ready,
snd_rocketmarine_annoy,
snd_rocketmarine_attack,
snd_rocketmarine_select,
snd_rocketmarine_move,

snd_shotgunner_ready,
snd_shotgunner_annoy,
snd_shotgunner_attack,
snd_shotgunner_select,
snd_shotgunner_move,

snd_ssg_ready,
snd_ssg_annoy,
snd_ssg_attack,
snd_ssg_select,
snd_ssg_move,

snd_tank_ready,
snd_tank_annoy,
snd_tank_attack,
snd_tank_select,
snd_tank_move,

snd_terminator_ready,
snd_terminator_annoy,
snd_terminator_attack,
snd_terminator_select,
snd_terminator_move,

snd_transport_ready,
snd_transport_annoy,
snd_transport_select,
snd_transport_move,

snd_uacfighter_ready,
snd_uacfighter_annoy,
snd_uacfighter_attack,
snd_uacfighter_select,
snd_uacfighter_move,

snd_hell_hk,
snd_hell_hgate,
snd_hell_hsymbol,
snd_hell_hpool,
snd_hell_htower,
snd_hell_hteleport,
snd_hell_htotem,
snd_hell_hmon,
snd_hell_hfort,
snd_hell_haltar,
snd_hell_hbuild,

snd_zimba_death,
snd_zimba_ready,
snd_zimba_pain,
snd_zimba_move,

snd_hell_pain,
snd_hell_melee,
snd_hell_attack,
snd_hell_move,

snd_revenant_death,
snd_revenant_ready,
snd_revenant_melee,
snd_revenant_attack,
snd_revenant_move,

snd_pain_ready,
snd_pain_death,
snd_pain_pain,

snd_mastermind_ready,
snd_mastermind_death,
snd_mastermind_foot,

snd_mancubus_ready,
snd_mancubus_death,
snd_mancubus_pain,
snd_mancubus_attack,

snd_lost_move,

snd_knight_ready,
snd_knight_death,
snd_baron_ready,
snd_baron_death,

snd_imp_ready,
snd_imp_death,
snd_imp_move,

snd_demon_ready,
snd_demon_death,
snd_demon_melee,

snd_cyber_ready,
snd_cyber_death,
snd_cyber_foot,

snd_caco_death,
snd_caco_ready,

snd_archvile_death,
snd_archvile_attack,
snd_archvile_fire,
snd_archvile_pain,
snd_archvile_ready,
snd_archvile_move,

snd_arachno_death,
snd_arachno_move,
snd_arachno_foot,
snd_arachno_ready,

{snd_jetpoff,
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
snd_demon1, }
snd_click,
snd_chat,
snd_rico,
snd_bfg_exp,
snd_flyer_s,
snd_flyer_a,
{,
snd_ccup,
, }
snd_meat,
snd_building_explode,
snd_mine_place,
snd_inapc,
snd_teleport,
snd_pexp,
snd_exp
{
,
,

snd_hellbar,
snd_hell,
snd_hpower }       : PTSoundSet;


{$ELSE}

consoley : integer = 0;
str_m_seed,
str_plstat: shortstring;

{$ENDIF}













