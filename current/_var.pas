
var

GameCycle         : boolean = false;
sys_EVENT         : pSDL_EVENT;

////////////////////////////////////////////////////////////////////////////////
//
//  GAME
//

g_started         : boolean  = false;
g_status          : byte     = 0;
g_mode            : byte     = 0;
g_start_base      : byte     = 2;
g_fixed_positions : boolean  = false;
g_generators      : byte     = 2;
g_ai_slots        : byte     = {$IFDEF _FULLGAME}player_default_ai_level{$ELSE}0{$ENDIF};
g_deadobservers   : boolean  = true;
g_step            : cardinal = 0;
g_player_astatus  : byte     = 0;
g_player_rstatus  : byte     = 0;
g_cl_units        : integer  = 0;
g_slot_state      : array[0..MaxPlayers] of byte;

g_inv_limit       : longint  = 0;
g_inv_wave_n      : byte     = 0;
g_inv_wave_t_next : integer  = 0;
g_inv_wave_t_curr : integer  = 0;
g_royal_r         : integer  = 0;
g_cpoints         : array[1..MaxCPoints] of TCTPoint;

////////////////////////////////////////////////////////////////////////////////
//
//  BASE
//

ServerSide        : boolean = true; // only server side code

UnitMoveStepTicks : byte = 8;
LastCreatedUnit   : integer = 0;
LastCreatedUnitP  : PTUnit;
PlayerClient      : byte = 1; // 'this' player
PlayerLobby       : byte = 1; // Player who can change game settings
player_APMdata    : array[0..MaxPlayers] of TAPMCounter;

g_players         : TPList;
g_units           : array[0..MaxUnits   ] of TUnit;
g_punits          : array[0..MaxUnits   ] of PTUnit;
g_missiles        : array[1..MaxMissiles] of TMissile;
g_uids            : array[byte] of TUID;
g_upids           : array[byte] of TUPID;
g_mids            : array[byte] of TMID;
g_dmods           : array[byte] of TDamageMod;

g_cycle_order     : integer = 0;
g_cycle_regen     : integer = 0;

g_random_i        : word = 0;
g_random_p        : byte = 0;

g_preset_cur      : byte = 0;
g_preset_n        : byte = 0;
g_presets         : array of TGamePreset;

map_seed          : cardinal = 1;
map_mw            : integer  = 5000;
map_hmw           : integer  = 2500;
map_b1            : integer  = 0;
map_type          : byte     = 0;
map_symmetry      : byte     = 0;
map_symmetryDir,
map_symmetryX0,
map_symmetryY0,
map_symmetryX1,
map_symmetryY1    : integer;
map_psx           : array[0..MaxPlayers] of integer;
map_psy           : array[0..MaxPlayers] of integer;
map_grid          : array[0..terrrain_celln,0..terrrain_celln] of TMapTerrainGridCell;

pf_pathgrid_areas : array[0..pf_pathmap_c,0..pf_pathmap_c] of word;
//pf_pathgrid_tmpg  : array[0..pf_pathmap_c,0..pf_pathmap_c] of byte;
//pf_pathgrid_tmpb  : byte;
//pfNodes           : array[1..pfMaxNodes] of TPFNode;
//pfNodes_c         : integer;

net_status        : byte = ns_single;
net_port          : word = 10666;
net_socket        : PUDPSocket;
net_buffer        : PUDPPacket;
net_bufpos        : integer = 0;
net_period        : byte = 0;
net_log_n         : word = 0;
net_wudata_t      : TWUDataTime;
net_cpoints_t     : TWCPDataTime;
net_localAdv      : boolean = true;
net_localAdv_timer: integer = 0;

rpls_file         : file;
rpls_u            : integer = 0;
rpls_pnui         : byte = 0;
rpls_log_n        : word = 0;
rpls_wudata_t     : TWUDataTime;
rpls_cpoints_t    : TWCPDataTime;

fr_FPSSecond,
fr_FPSSecondD,
fr_FPSSecondU,
fr_FPSSecondN,
fr_FPSSecondC,
fr_FrameCount,
fr_LastTicks,
fr_BaseTicks      : cardinal;

wtrset_all,
wtrset_enemy,
wtrset_enemy_alive,
wtrset_enemy_alive_light,
wtrset_enemy_alive_ground,
wtrset_enemy_alive_ground_light,
wtrset_enemy_alive_ground_mech,
wtrset_enemy_alive_fly,
wtrset_enemy_alive_fly_mech,
wtrset_enemy_alive_fly_buildings,
wtrset_enemy_alive_mech,
wtrset_enemy_alive_mech_nstun,
wtrset_enemy_alive_buildings,
wtrset_enemy_alive_units,
wtrset_enemy_alive_ground_buildings,
wtrset_enemy_alive_bio,
wtrset_enemy_alive_bio_light,
wtrset_enemy_alive_bio_nstun,
wtrset_enemy_alive_heavy_bio,
wtrset_enemy_alive_ground_heavy,
wtrset_enemy_alive_ground_heavy_bio,
wtrset_enemy_alive_ground_bio,
wtrset_enemy_alive_ground_light_bio,
wtrset_heal,
wtrset_repair,
wtrset_resurect   : cardinal;

u_royal_cd,
u_royal_d         : integer;

{$IFDEF _FULLGAME}

_RX2Y             : array[0..MFogM,0..MFogM] of integer;

test_mode         : byte = 0;
test_fastprod     : boolean = false;
sys_uncappedFPS   : boolean = false;
sys_fog           : boolean = false;

r_panel,
r_uipanel,
r_empty,
r_minimap,
r_bminimap,
//r_sminimap,
r_screen,
r_dterrain,
r_menu            : pSDL_SURFACE;
r_vflags          : cardinal = SDL_HWSURFACE;   //SDL_SWSURFACE

r_RECT            : pSDL_RECT;

r_blink1_colorb,
r_blink2_colorb   : boolean;
r_blink1_color_BG,
r_blink1_color_BY,
r_blink2_color_BG,
r_blink2_color_BY : cardinal;
r_blink3          : byte;

r_minimap_scan_blink
                  : boolean = false;

ingame_chat       : byte = 0;
vid_fullscreen    : boolean = false;
r_draw            : boolean = true;

vid_map_RedrawBack: boolean = false;

menu_state        : boolean = true;
menu_remake       : boolean = false;
menu_redraw       : boolean = false;
menu_item         : integer;
menu_s1           : byte = ms1_sett;
menu_s2           : byte = ms2_game;
menu_s3           : byte = ms3_game;
menu_items        : array[byte] of TMenuItem;
menu_list_n,
menu_list_selected,
menu_list_current,
menu_list_x,
menu_list_y,
menu_list_w       : integer;
menu_list_items   : array of TMenuListItem;

menu_res_w,
menu_res_h,
menu_x,
menu_y            : integer;

PlayerName        : shortstring = str_defaultPlayerName;

PlayerColor       : array[0..MaxPlayers] of cardinal;

UIPlayer          : byte = 1;

vid_vw            : integer = 800;
vid_vh            : integer = 600;
vid_cam_w         : integer = 800;
vid_cam_hw        : integer = 400;
vid_cam_h         : integer = 600;
vid_cam_hh        : integer = 300;
vid_vmb_x0        : integer = 6;
vid_vmb_y0        : integer = 6;
vid_vmb_x1        : integer = 794;
vid_vmb_y1        : integer = 594;
vid_mwa           : integer = 0;
vid_mha           : integer = 0;
vid_cam_x         : integer = 0;
vid_cam_y         : integer = 0;
vid_CamSpeed      : integer = 25;
vid_mmvx,
vid_mmvy          : integer;
vid_uhbars        : byte = 0;
vid_plcolors      : byte = 0;
vid_APM           : boolean = false;
vid_FPS           : boolean = false;
vid_CamMScroll    : boolean = false;
vid_ColoredShadow : boolean = true;
vid_PannelPos     : byte = 0;
vid_panelx        : integer = 0;
vid_panely        : integer = 0;
vid_mapx          : integer = 0;
vid_mapy          : integer = 0;
vid_Sprites_list  : array of PTVSprite;
vid_Sprites_n     : word = 0;
vid_UIItem_list   : array of TUIItem;
vid_UIItem_n      : word = 0;
vid_blink_timer1  : integer = 0;
vid_blink_timer2  : integer = 0;
vid_panel_timer   : byte = 0;

vid_fog_grid      : array[0..fog_vfwm,0..fog_vfhm] of boolean;
vid_fog_pgrid     : array[0..fog_vfwm,0..fog_vfhm] of boolean;
vid_fog_vfw       : byte = 0;
vid_fog_vfh       : byte = 0;
vid_fog_sx        : integer = 0;
vid_fog_sy        : integer = 0;
vid_fog_ex        : integer = 0;
vid_fog_ey        : integer = 0;

vid_fog_BaseSurf  : pSDL_Surface;
vid_fog_tiles     : TMWTileSet;

{vid_fog_mm        : array[fog_mm_Min..fog_mm_Max] of pSDL_Surface;
vid_fog_mmn       : word;
vid_fog_mmx,
vid_fog_mmy,
vid_fog_mmr       : array of integer;}

ter_w,
ter_h             : integer;

font_ca           : array[char] of TMWTexture;

g_eids            : array[byte] of TEID;
g_effects         : array[1..vid_MaxScreenSprites] of TEffect;

ms_eid_bio_death_uids
                  : TSoB;

_tdecaln          : integer = 0;
_tdecals          : array of TDecal;

map_mmcx          : single;
map_mmvw,
map_mmvh          : integer;

campain_skill     : byte = 3;
campain_seed      : cardinal = 0;
campain_mission   : byte = 0;
campain_mmap      : array[0..MaxMissions] of pSDL_Surface;
campain_mission_n : integer = 0;

log_LastMesTimer  : integer = 0;

net_cl_svpreset   : shortstring = '';
net_cl_svip       : cardinal = 0;
net_cl_svport     : word = 10666;
net_cl_svttl      : integer = 0;
net_cl_svstr      : shortstring = '127.0.0.1:10666';
net_status_str    : shortstring = '';
net_sv_pstr       : shortstring = '10666';
net_chat_str      : shortstring = '';
net_chat_tar      : byte = 255;
net_pnui          : byte = 4;

net_svsearch      : boolean = false;
net_svsearch_list : array of TServerInfo;
net_svsearch_listn: integer = 0;
net_svsearch_scroll: integer = 0;
net_svsearch_sel  : integer = 0;


svld_str_info     : shortstring = '';
svld_str_fname    : shortstring = '';
svld_list         : array of shortstring;
svld_list_size    : integer = 0;
svld_list_sel     : integer = 0;
svld_list_scroll  : integer = 0;
svld_file_size    : cardinal = 0;

rpls_fstatus      : byte = 0;    // file status (none,write,read)
rpls_pnu          : integer = 0; // quality
rpls_str_name     : shortstring = 'LastReplay';
rpls_str_path     : shortstring = '';
rpls_str_info     : shortstring = '';
rpls_state        : byte = rpls_state_none;
rpls_list         : array of shortstring;
rpls_list_size    : integer = 0;
rpls_list_sel     : integer = 0;
rpls_list_scroll  : integer = 0;
rpls_ReadPosN     : int64 = 0;
rpls_ReadPosL     : array of TReplayPos;
rpls_ForwardStep  : integer = 1;
rpls_vidx         : byte = 0;
rpls_vidy         : byte = 0;
rpls_player       : byte = 0;
rpls_showlog      : boolean = false;
rpls_plcam        : boolean = false;
rpls_ticks        : byte = 0;
rpls_file_head_size
                  : cardinal = 0;
rpls_file_size    : cardinal = 0;


mouse_select_x0,
mouse_select_y0,
mouse_map_x,
mouse_map_y,
mouse_x,
mouse_y           : integer;
mleft_dbl_click,
m_brushc          : cardinal;
m_brushx,
m_brushy,
m_brush           : integer;
m_bx,
m_by              : integer;
m_vmove           : boolean = false;
m_action          : boolean = true;
m_mmap_move       : boolean = false;

ui_language       : boolean = false;

ui_UnitSelectedNU : integer = 0;
ui_UnitSelectedpU : integer = 0;
ui_UnitSelectedn  : byte = 0;
ui_tab            : byte = 0;
ui_panel_uids     : array[0..r_cnt,0..2,0..ui_ubtns] of byte;
ui_alarms         : array[0..ui_max_alarms] of TAlarm;

ui_groups_n,                                             //
ui_groups_d,                                             //
ui_groups_x,                                             //
ui_groups_y       : array[0..MaxUnitGroups] of integer;             //
ui_groups_uids    : array[0..MaxUnitGroups,false..true] of TSob;    //

ui_mc_x,                                                 //
ui_mc_y,                                                 // mouse click effect
ui_mc_a           : integer;                             //
ui_mc_c           : cardinal;                            //

ui_uprod_max,
ui_uprod_cur,
ui_uprod_first    : integer;
ui_units_InTransport,
ui_uprod_uid_max,
ui_uprod_uid_time,
ui_pprod_max,
ui_pprod_time     : array[byte] of integer;
ui_pprod_first    : integer;
ui_bprod_possible : TSoB;
ui_bprod_uid_count,
ui_bprod_ucl_count,
ui_bprod_ucl_time : array[byte] of integer;
ui_bprod_first,
ui_bprod_all      : integer;
ui_uid_reload     : array[byte] of integer;
ui_bucl_reload    : array[byte] of integer;
ui_uibtn_move     : integer = 0;   // ui move buttons
ui_uibtn_sability : integer = 0;   // ui action uid
ui_uibtn_rebuild  : integer = 0;   // ui rebuild button
ui_uhint          : integer = 0;
ui_umark_u        : integer = 0;
ui_umark_t        : byte = 0;
ui_max_color,                                       // unit max count color
ui_cenergy,                                         // energy limit colors
ui_limit,                                           // unit limit colors
ui_blink_color2,
ui_blink_color1   : array[false..true] of cardinal;

ui_uiuphx         : integer = 0;
ui_uiuphy         : integer = 0;
ui_uiplayery      : integer = 0;
ui_ingamecl       : byte = 0;
ui_textx          : integer = 0;  // timer/chat screen X
ui_texty          : integer = 0;  // timer/chat screen Y
ui_hinty1         : integer = 0;  // hints screen Y 1
ui_hinty2         : integer = 0;  // hints screen Y 2
ui_hinty3         : integer = 0;  // hints screen Y 3
ui_hinty4         : integer = 0;  // hints screen Y 4
ui_logy           : integer = 0;  // LOG screen Y
ui_chaty          : integer = 0;  // chat screen Y
ui_oicox          : integer = 0;  // order icons screen X
ui_energx         : integer = 0;
ui_energy         : integer = 0;
ui_armyx          : integer = 0;
ui_armyy          : integer = 0;
ui_apmx           : integer = 0;
ui_apmy           : integer = 0;
ui_fpsx           : integer = 0;
ui_fpsy           : integer = 0;
ui_GameLogHeight: integer = 0;
ui_menu_btnsy     : integer = 0;
ui_menu_btnsh     : integer = 0;

ui_log_s          : array of shortstring;
ui_log_t          : array of byte;
ui_log_c          : array of cardinal;
ui_log_n          : integer = 0;

k_dbl             : boolean = false;
k_dblk            : cardinal;
ks_dbl,
ks_left,
ks_right,
ks_up,
ks_down,
ks_shift,
ks_ctrl,
ks_alt,
ks_mleft,
ks_mright,
ks_mmiddle,
ks_LastChar       : integer;
k_LastChar        : char;
k_keyboard_string : shortstring = '';

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
c_alime,
c_green,
c_agreen,
c_dblue,
c_blue,
c_aqua,
c_aaqua,
c_white,
c_agray,
c_ltgray,
c_gray,
c_dgray,
c_ablack,
c_purple,
c_black           : cardinal;

////////////////////////////////////////////////////////////////////////////////
//
//  THEMES
//

theme_cur           : integer = 0;
{
theme_liquid_animt: byte;
theme_liquid_animm: byte;
theme_liquid_color: cardinal = 0;

theme_map_terrain1 : integer=0;
theme_map_pterrain1: integer = -1;
theme_map_terrain2 : integer=0;
theme_map_pterrain2: integer = -1;
theme_map_liquid  : integer=0;
theme_map_pliquid : integer = -1;
theme_liquid_style: byte = 0;
theme_crater_style: byte = 0;

theme_anm_decors,
theme_anm_srocks,
theme_anm_brocks  : TThemeAnimL;

theme_anm_liquids : array of byte;     // animation type
theme_ant_liquids : array of byte;     // animation period
theme_clr_liquids : array of cardinal; // minimap color     }

theme_tile_terrain    : pSDL_Surface = nil;
theme_tile_crater     : pSDL_Surface = nil;
theme_tile_liquid     : pSDL_Surface = nil;

theme_tileset_crater  : TMWTileSet;
theme_tileset_liquid  : array[0..theme_anim_step_n-1] of TMWTileSet;

theme_crater_tes      : byte = tes_nature; // theme liquid edge style
theme_liquid_tes      : byte = tes_nature; // theme liquid edge style
theme_liquid_anim     : byte = tas_none;   // theme liquid animation style
theme_liquid_mmcolor  : cardinal = 0;      // theme liquid minimap color

theme_tile_terrain_id,
theme_tile_crater_id,
theme_tile_liquid_id  : integer;

theme_cur_decal_l,
theme_cur_decor_l,
theme_cur_srock_l,
theme_cur_brock_l,
theme_cur_crater_l,
theme_cur_liquid_l,
theme_cur_terrain_tas_l,
theme_cur_terrain_l   : TIntList;
theme_cur_decal_n,
theme_cur_decor_n,
theme_cur_srock_n,
theme_cur_brock_n,
theme_cur_crater_n,
theme_cur_liquid_n,
theme_cur_terrain_n   : integer;

theme_all_decal_l,
theme_all_decor_l,
theme_all_srock_l,
theme_all_brock_l,
theme_all_terrain_l   : TMWTextureList;
theme_all_decal_n,
theme_all_decor_n,
theme_all_srock_n,
theme_all_brock_n,
theme_all_terrain_n   : integer;

theme_all_terrain_mmcolor
                      : array of cardinal;

////////////////////////////////////////////////////////////////////////////////
//
//  SPRITES
//


spr_dummy         : TMWTexture;
pspr_dummy        : PTMWTexture;

spr_dmodel,

spr_LostSoul,
spr_phantom,
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
spr_ZAntiaircrafter,
spr_ZSiege,
spr_ZFMajor,
spr_ZBFG,

spr_Engineer,
spr_Scout,
spr_Medic,
spr_Sergant,
spr_SSergant,
spr_Commando,
spr_Antiaircrafter,
spr_Siege,
spr_FMajor,
spr_BFG,
spr_FAPC,
spr_APC,
spr_Terminator,
spr_Tank,
spr_Flyer,
spr_Transport,
spr_UACBot,

spr_HKeep,
spr_HAKeep,
spr_HGate,
spr_HAGate,
spr_HSymbol,
spr_HASymbol,
spr_HPools,
spr_HAPools,
spr_HTower,
spr_HTeleport,
spr_HMonastery,
spr_HTotem,
spr_HAltar,
spr_HFortress,
spr_HPentagram,
spr_HCommandCenter,
spr_HACommandCenter,
spr_HBarracks,
spr_HABarracks,
spr_HEye,

spr_UCommandCenter,
spr_UACommandCenter,
spr_UBarracks,
spr_UABarracks,
spr_UFactory,
spr_UAFactory,
spr_UGenerator,
spr_UAGenerator,
spr_UWeaponFactory,
spr_UAWeaponFactory,
spr_UTurret,
spr_URadar,
spr_UVehicleFactory,
spr_UTechCenter,
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
spr_eff_gtel,
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
spr_u_p1s,
spr_u_p2,
spr_u_p3,
spr_u_p8,

spr_db_h0,
spr_db_h1,
spr_db_u0,
spr_db_u1,

spr_blood         : TMWSModel;
spr_pdmodel       : PTMWSModel;

spr_mp            : array[1..r_cnt] of TMWTexture;
spr_b4_a,
spr_b7_a,
spr_b9_a,
spr_ptur,
spr_scan,
spr_decay,
spr_invuln,
spr_hvision,
spr_stun          : TMWTexture;


spr_c_mars,
spr_c_hell,
spr_c_earth,
spr_c_phobos,
spr_c_deimos ,
spr_b_mmark,
spr_b_rfast,
spr_b_rskip,
spr_b_rback,
spr_b_rfog,
spr_b_rclck,
spr_b_rlog,
spr_b_rstop,
spr_b_rvis,
spr_b_action,
spr_b_paction,
spr_b_attack,
spr_b_rebuild,
spr_b_move,
spr_b_patrol,
spr_b_apatrol,
spr_b_stop,
spr_b_hold,
spr_b_selall,
spr_b_cancel,
spr_b_delete,
spr_mback,
spr_cursor        : pSDL_Surface;
spr_b_up          : array[1..r_cnt,0..spr_upgrade_icons] of TMWTexture;
spr_tabs          : array[0..3] of pSDL_Surface;
spr_cp_koth,
spr_cp_out,
spr_cp_gen        : TMWTexture;

//spr_ui_oico       : array[1..r_cnt,false..true,byte] of pSDL_Surface;


////////////////////////////////////////////////////////////////////////////////
//
//  TEST
//

str_bool          : array[false..true   ] of shortstring;
str_teams         : array[0..MaxPlayers ] of shortstring;
str_map_typel     : array[0..gms_m_types] of shortstring;
str_ability_name  : array[byte          ] of shortstring;
str_racel         : array[0..r_cnt      ] of shortstring;
str_gmode         : array[0..gm_cnt     ] of shortstring;
str_map_syml      : array[0..gms_m_symm ] of shortstring;
str_ability_unload,
str_need_energy,
str_cant_build,
str_cant_prod,
str_check_reqs,
str_transformation,
str_upgradeslvl,
str_demons,
str_except,
str_UnitArming,
str_weapon_melee,
str_weapon_ranged,
str_weapon_zombie,
str_weapon_ressurect,
str_weapon_heal,
str_weapon_spawn,
str_weapon_suicide,
str_weapon_targets,
str_weapon_damage,
str_splashresist,
str_hits,
str_srange,
str_ability,
str_builder,
str_barrack,
str_smith,
str_IncEnergyLevel,
str_CanRebuildTo,
str_TargetLimit,
str_NextTrack,
str_PlayerPaused,
str_PlayerResumed,
str_attr_alive,
str_attr_dead,
str_attr_detector,
str_attr_invuln,
str_attr_stuned,
str_attr_level,
str_attr_building,
str_attr_unit,
str_attr_mech,
str_attr_bio,
str_attr_light,
str_attr_heavy,
str_attr_fly,
str_attr_ground,
str_attr_floater,
str_unit_advanced,
str_attr_transport,
str_advanced,
str_upgrade_complete,
str_building_complete,
str_unit_complete,
str_unit_attacked,
str_base_attacked,
str_allies_attacked,
str_cant_execute,
str_NeedpsabilityOrder,
str_maxlimit_reached,
str_mapMark,
str_need_more_builders,
str_production_busy,
str_cant_advanced,
str_NeedMoreProd,
str_MaximumReached,
str_map_type,
str_map_size,
str_map_sym,
str_plname,
str_aislots,
str_generators,
str_DeadObservers,
str_Address,
str_ready,
str_nready,
str_fstarts,
str_gmodet,
str_starta,
str_ps_comp,
str_ps_cheater,
str_plsurrender,
str_plout,
str_player_def    : shortstring;
str_PlayerSlots   : array[0..ps_states_n-1    ] of shortstring;
str_generatorsO   : array[0..gms_g_maxgens    ] of shortstring;
str_pcolors       : array[0..vid_maxplcolors-1] of shortstring;
str_uhbars        : array[0..2] of shortstring;
str_panelposp     : array[0..3] of shortstring;
str_panelpos,
str_ColoredShadow,
str_uhbar,
str_pcolor,
str_all,
str_orders,
str_requirements,
str_req,
str_uprod,
str_bprod,
str_language,
str_resol_width,
str_resol_height,
str_apply,
str_randoms,
str_menu_chat,
str_chat_all,
str_chat_allies,
str_server,
str_client,
str_goptions,
str_waitsv,
str_gsunknown,
str_cmpdif,
str_repend,
str_reperror,
str_replay,
str_replay_status,
str_replay_name,
str_play,
str_inv_ml,
str_inv_time,
str_menu,
str_time,
str_kothtime,
str_kothtime_act,
str_kothwinner,
str_players,
str_map,
str_save,
str_load,
str_delete,
str_gsaved,
str_pause,
str_observer,
str_win,
str_lose,
str_WrongVersion,
str_ServerFull,
str_GameStarted,
str_udpport,
str_connecting,
str_netsearching,
str_netsearch,
str_replay_Quality,
str_net_Quality,
str_soundvol,
str_musicvol,
str_maction,
str_scrollspd,
str_mousescrl,
str_fullscreen,
str_FPS,
str_APM,
str_mrandom,
str_svld_errors_file,
str_svld_errors_open,
str_svld_errors_wdata,
str_svld_errors_wver,
str_rpls_errors_open,
str_MObjectives,
str_MServers,
str_MMap,
str_MPlayers      : shortstring;
str_npnua,
str_pnua          : array[0..cl_UpT_arrayN] of shortstring;
str_cmpd          : array[0..CMPMaxSkills] of shortstring;
str_hint_t        : array[0..3] of shortstring;
str_hint_army     : shortstring;
str_hint_energy   : shortstring;
str_hint_m        : array[0..2 ] of shortstring;
str_hint_a,
str_hint_r,
str_hint_o        : array[0.._mhkeys] of shortstring;
str_rstatus       : array[0..2] of shortstring = ('OFF','RECORD','PLAY');

{str_camp_t        : array[0..MaxMissions] of shortstring;
str_camp_o        : array[0..MaxMissions] of shortstring;
str_camp_m        : array[0..MaxMissions] of shortstring; }

str_connect,
str_svup,
str_lng,
str_mactionl,
str_exit,
str_reset         : array[false..true] of shortstring;
str_menu_s1,
str_menu_s2,
str_menu_s3       : array[0..2] of shortstring;


////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

SLpos              : array[0..2] of TALfloat;
SLori              : array[0..5] of TALfloat;

snd_svolume1       : single = 0.5;
snd_mvolume1       : single = 0.5;

MainDevice         : TALCdevice;
MainContext        : TALCcontext;

SoundSources       : array[0..sss_count-1] of TMWSoundSourceSet;

snd_music_game,
snd_music_menu     : PTSoundSet;
snd_music_current  : PTSoundSet = nil;
snd_anoncer_last   : PTSoundSet = nil;
snd_anoncer_ticks  : integer = 0;
snd_command_last   : PTSoundSet = nil;
snd_command_ticks  : integer = 0;
snd_mmap_last      : PTSoundSet = nil;
snd_mmap_ticks     : integer = 0;


snd_under_attack   : array[false..true,1..r_cnt] of PTSoundSet;
snd_build_place,
snd_building,
snd_cannot_build,
snd_constr_complete,
snd_defeat,
snd_not_enough_energy,
snd_cant_order,
snd_player_defeated,
snd_upgrade_complete,
snd_victory,
snd_unit_adv,
snd_unit_promoted
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

snd_scout_ready,
snd_scout_select,
snd_scout_move,

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

snd_uacbot_annoy,
snd_uacbot_attack,
snd_uacbot_select,
snd_uacbot_move,

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
snd_hell_eye,

snd_zimba_death,
snd_zimba_ready,
snd_zimba_pain,
snd_zimba_move,

snd_hell_invuln,
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

snd_cube,
snd_pistol,
snd_shotgun,
snd_ssg,
snd_plasma,
snd_bfg_shot,
snd_bfg_exp,
snd_healing,
snd_electro,
snd_jetpoff,
snd_jetpon,
snd_click,
snd_chat,
snd_rico,
snd_flyer_s,
snd_flyer_a,
snd_launch,
snd_CCup,
snd_bomblaunch,
snd_meat,
snd_building_explode,
snd_mine_place,
snd_transport,
snd_teleport,
snd_pexp,
snd_exp,
snd_mapmark,
snd_hell
       : PTSoundSet;


{$ELSE}

screen_redraw   : boolean = true;
consoley        : integer = 0;

{$ENDIF}













