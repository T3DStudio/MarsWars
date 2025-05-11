
var

GameCycle         : boolean = false;
sys_EVENT         : pSDL_EVENT;

////////////////////////////////////////////////////////////////////////////////
//
//  GAME
//

ServerSide        : boolean = true; // only server side code

UnitMoveStepTicks : byte = 8;
LastCreatedUnit   : integer = 0;
LastCreatedUnitP  : PTUnit;
PlayerClient      : byte = 0; // 'this' player
PlayerLobby       : byte = 0; // Player who can change game settings

G_Started         : boolean  = false;
g_status          : byte     = 0;
g_mode            : byte     = 0;
g_fixed_positions : boolean  = false;
g_generators      : byte     = 0;
g_ai_slots        : byte     = {$IFDEF _FULLGAME}player_default_ai_level{$ELSE}0{$ENDIF};
g_deadobservers   : boolean  = true;

g_step            : cardinal = 0;
g_player_astatus  : byte     = 0;
g_player_rstatus  : byte     = 0;
g_cl_units        : integer  = 0;
g_slot_state      : array[0..LastPlayer] of byte;

g_royal_r         : integer  = 0;
g_cpoints         : array[1..MaxCPoints] of TCTPoint;

g_players         : TPList;
g_units           : array[0..MaxUnits   ] of TUnit;
g_punits          : array[0..MaxUnits   ] of PTUnit;
g_missiles        : array[1..MaxMissiles] of TMissile;

g_uids            : array[byte] of TUID;
g_upids           : array[byte] of TUPID;
g_mids            : array[byte] of TMID;
g_dmods           : array[byte] of TDamageMod;
g_uability        : array[byte] of TUnitAbility;

g_cycle_order     : integer = 0;
g_cycle_regen     : integer = 0;

g_random_i        : word = 0;
g_random_p        : byte = 0;

g_preset_cur      : byte = 0;  // rename to map_* ?????
g_preset_n        : byte = 0;
g_presets         : array of TGamePreset;

map_seed          : cardinal = 0;
map_psize         : integer  = 0; // pixel size
map_phsize        : integer  = 0; // pixel half size
map_FreeCenterR   : integer  = 0;
map_csize         : integer  = 0; // cell size
map_chsize        : integer  = 0; // cell half size
map_type          : byte     = 0;
map_symmetry      : byte     = 0;
map_symmetryDir   : integer  = 0;
map_PlayerStartX,
map_PlayerStartY  : array[0..LastPlayer] of integer;
map_grid          : array[0..MaxMapSizeCelln-1,0..MaxMapSizeCelln-1] of TMapTerrainGridCell;
map_gridZone_n    : word = 0;
map_gridDomain_n  : word = 0;
map_gridDomainMX  : array of array of TMapGridPFDomainData;
{$IFDEF DTEST}
map_gridDomain_color: array of TMWColor;
{$ENDIF}

map_gcx,
map_gcy,
map_gcsx,
map_gcsy          : integer;

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
rpls_Quality      : byte = 0;
rpls_log_n        : word = 0;
rpls_wudata_t     : TWUDataTime;
rpls_cpoints_t    : TWCPDataTime;

fr_FPSSecond,
fr_FPSSecondD,
fr_FPSSecondU,
fr_FPSSecondN,
fr_FPSSecondC,
fr_FrameCount,
fr_LastTocks,
fr_BaseTicks      : cardinal;

// weapon target bits
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

str_outLogLastDate: shortstring = '';

{$IFDEF _FULLGAME}

debug_Sx,
debug_Sy,
debug_Sgx,
debug_Sgy,
debug_Svx,
debug_Svy,
debug_Dx,
debug_Dy,
debug_Dgx,
debug_Dgy,
debug_Dvx,
debug_Dvy         : integer;
debug_d1,
debug_d2,
debug_zone        : word;
debug_array_n     : integer;
debug_array_x,
debug_array_y     : array of integer;


map_grid_graph    : array[0..MaxMapSizeCelln-1,0..MaxMapSizeCelln-1] of TMapTerrainGridCellAnim;

_RX2Y             : array[0..MFogM,0..MFogM] of integer;

test_mode         : byte = 0;
test_fastprod     : boolean = false;
sys_uncappedFPS   : boolean = false;
sys_fog           : boolean = false;

vid_SDLWindow     : pSDL_Window;
vid_SDLRenderer   : pSDL_Renderer;

vid_SDLRendererName: shortstring = '';
vid_SDLRendererNameConfig
                   : shortstring = '';
vid_SDLRenderersN : integer = 0;
vid_SDLRendererI  : integer = -1;

vid_SDLRect       : pSDL_RECT;

vid_SDLDisplayModeN: integer = 0;
vid_SDLDisplayModes: array of TSDL_DisplayMode;
vid_SDLDisplayModeC: TSDL_DisplayMode;

vid_blink1_colorb,
vid_blink2_colorb : boolean;
vid_blink1_color_BG,
vid_blink1_color_BY,
vid_blink2_color_BG,
vid_blink2_color_BY : TMWColor;
vid_blink3          : byte;

vid_TileTemplate_crater_tech,
vid_TileTemplate_crater_nature: pTMWTileSet;
vid_TileTemplate_liquid       : array[0..theme_anim_step_n-1] of pTMWTileSet;

vid_vw            : integer = vid_minw;       // window size
vid_vhw           : integer = vid_minw div 2;
vid_vh            : integer = vid_minh;
vid_vhh           : integer = vid_minh div 2;
vid_cam_w         : integer = vid_minw;       // in-game cam view
vid_cam_hw        : integer = vid_minw div 2;
vid_cam_h         : integer = vid_minh;
vid_cam_hh        : integer = vid_minh div 2;
vid_cam_x         : integer = 0;
vid_cam_y         : integer = 0;
vid_mmvx,
vid_mmvy          : integer;
vid_vmb_x0        : integer = 6;              // cam scroll by mouse screen edges
vid_vmb_y0        : integer = 6;
vid_vmb_x1        : integer = vid_minw-6;
vid_vmb_y1        : integer = vid_minh-6;

vid_Sprites_l     : array[0..vid_MaxScreenSprites-1] of pTVSprite;       // vid base
vid_Sprites_n     : word = 0;
vid_UIItem_l      : array[0..vid_MaxScreenSprites-1] of TUIItem;
vid_UIItem_n      : word = 0;
vid_blink_timer1  : integer = 0;
vid_blink_timer2  : integer = 0;
vid_PanelUpdTimer : byte = 0;
vid_PanelUpdNow   : boolean = false;

vid_CamSpeed      : integer = 25;             // options
vid_UnitHealthBars: TUIUnitHBarsOption  = low(TUIUnitHBarsOption);
vid_PlayersColorSchema
                  : TPlayersColorSchema = low(TPlayersColorSchema);
vid_APM           : boolean = false;
vid_FPS           : boolean = false;
vid_CamMSEScroll  : boolean = false;
vid_ColoredShadow : boolean = true;
vid_PannelPos     : TVidPannelPos = low(TVidPannelPos);
vid_MiniMapPos    : boolean = false;

vid_minimap_scan_blink
                  : boolean = false;

UIPlayer          : byte = 0;
ingame_chat       : byte = 0;
vid_fullscreen    : boolean = false;
r_draw            : boolean = true;

menu_state        : boolean = true;
menu_page1        : byte = mp_main;
menu_page2        : byte = 0;
menu_settings_page: byte = mi_settings_game;
menu_remake       : boolean = false;
menu_redraw       : boolean = false;
menu_item         : integer;
menu_items        : array[byte] of TMenuItem;
menu_tex_cx       : single = 1;
menu_tex_x,
menu_tex_y,
menu_tex_w,
menu_tex_h,
menu_vid_vw,
menu_vid_vh,
menu_list_n,
menu_list_pselected,
menu_list_selected,
menu_list_current,
menu_list_x,
menu_list_y,
menu_list_item_h,
menu_list_item_hh,
menu_list_w       : integer;
menu_list_fontS   : single = 1;
menu_list_items   : array of TMenuListItem;
menu_list_aleft   : boolean = false;

PlayerName        : shortstring = str_defaultPlayerName;
PlayerColorSchemeFFA,
PlayerColorSchemeTEAM,
PlayerColorNormal,
PlayerColorShadow : TPlayerColorArray;


font_Base         : PTFont;



draw_color        : TMWColor;
draw_color_r,
draw_color_g,
draw_color_b,
draw_color_a      : byte;
draw_font         : PTFont;
draw_font_size    : single = 0;
draw_font_w1,
draw_font_wi,
draw_font_wh,
draw_font_wq,
draw_font_w1h,
draw_font_wq3,
draw_font_h1,
draw_font_hi,
draw_font_hh,
draw_font_hq,
draw_font_lhq,
draw_font_lhh

                  : integer;

g_eids            : array[byte] of TEID;
g_effects         : array[1..vid_MaxScreenSprites] of TEffect;

ms_eid_bio_death_uids
                  : TSoB;

map_mm_cx         : single;
map_mm_CamW,
map_mm_CamH       : integer;
map_mm_gridW      : single;


campain_skill     : byte = 3;
campain_seed      : cardinal = 0;
campain_mission   : byte = 255;
campain_mmap      : array[0..MaxMissions] of pTMWTexture;

log_LastMesTimer  : integer = 0;

net_cl_svip       : cardinal = 0;
net_cl_svport     : word = 10666;
net_cl_svttl      : integer = 0;
net_cl_svaddr     : shortstring = '127.0.0.1:10666';
net_status_str    : shortstring = '';
net_sv_pstr       : shortstring = '10666';
net_chat_str      : shortstring = '';
net_chat_tar      : byte = 255;
net_Quality       : byte = 4;

net_svsearch      : boolean = false;
net_svsearch_listi: array of TServerInfo;
net_svsearch_lists: TArrayOfsString;
net_svsearch_listn: integer = 0;
net_svsearch_scroll: integer = 0;
net_svsearch_sel  : integer = 0;


svld_str_info1    : shortstring = '';
svld_str_info2    : shortstring = '';
svld_str_info3    : shortstring = '';
svld_str_fname    : shortstring = '';
svld_items        : array of TSaveLoadItem;
svld_itemn        : integer = 0;
svld_list         : TArrayOfsString;
svld_list_size    : integer = 0;
svld_list_sel     : integer = 0;
svld_list_scroll  : integer = 0;
svld_file_size    : cardinal = 0;

rpls_Recording    : boolean = false;
rpls_StartRecordPause
                  : byte = 0;
rpls_fstate       : byte = rpls_state_none;  // file status (none,write,read)
rpls_rstate       : byte = rpls_state_none;
rpls_pnu          : integer = 0;
rpls_str_prefix   : shortstring = 'LastReplay';
rpls_str_path     : shortstring = '';
rpls_str_info1    : shortstring = '';
rpls_str_info2    : shortstring = '';
rpls_str_info3    : shortstring = '';
rpls_str_infoS    : shortstring = '';
rpls_head_itemn   : integer = 0;
rpls_head_items   : array of TSaveLoadItem;
rpls_list         : array of shortstring;
rpls_list_size    : integer = 0;
rpls_list_sel     : integer = 0;
rpls_list_scroll  : integer = 0;
rpls_ReadPosN     : int64 = 0;
rpls_ReadPosL     : array of TReplayPos;
rpls_ForwardStep  : integer = 1;
rpls_vidx         : byte = 0;
rpls_vidy         : byte = 0;
rpls_POVPlayer    : byte = 0;
rpls_showlog      : boolean = false;
rpls_POVCam       : boolean = false;
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
m_brushc          : TMWColor;
mbrush_x,
mbrush_y,
m_brush           : integer;
m_panelBtn_x,
m_panelBtn_y              : integer;
m_vmove           : boolean = false;
m_action          : boolean = true;
m_mmap_move       : boolean = false;

m_Last            : cardinal = 0;
m_TwiceLeft,
m_TwiceLast       : boolean;
mt_Last,
mt_TwiceLast      : integer;


// UID

ui_ControlBar_x   : integer = 0;
ui_ControlBar_y   : integer = 0;
ui_ControlBar_w   : integer = 0;
ui_ControlBar_h   : integer = 0;
ui_MiniMap_x      : integer = 0;
ui_MiniMap_y      : integer = 0;
ui_MapView_x      : integer = 0;
ui_MapView_y      : integer = 0;
ui_MapView_cw     : integer = 0;
ui_MapView_ch     : integer = 0;

ui_FogView_grid,
ui_FogView_pgrid  : array[0..fog_vfwm,0..fog_vfhm] of boolean;
ui_FogView_cw     : integer = 0;
ui_FogView_ch     : integer = 0;
ui_FogView_sx     : integer = 0;
ui_FogView_sy     : integer = 0;
ui_FogView_ex     : integer = 0;
ui_FogView_ey     : integer = 0;

ui_fog_tileset    : pTMWTileSet;

ui_language       : boolean = false;

ui_UnitSelectedNU : integer = 0;
ui_UnitSelectedpU : integer = 0;
ui_UnitSelectedn  : byte = 0;
ui_tab            : TTabType = low(TTabType);
ui_panel_uids     : array[0..r_cnt,0..2,0..ui_ubtns] of byte;
ui_alarms         : array[0..ui_max_alarms] of TAlarm;
ui_dPlayer        : TPlayer;

ui_groups_d       : array[0..MaxUnitGroups] of TUnitGroup;
ui_groups_f1      : TUnitGroup;
ui_groups_f2      : TUnitGroup;

// mouse click effect
ui_mc_x,
ui_mc_y,                        // mouse click effect
ui_mc_a           : integer;
ui_mc_c           : TMWColor;

// ui panel counters
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
ui_uibtn_abilityu : PTUnit  = nil; // ui action unit
ui_uhint          : integer = 0;
ui_CursorUnit     : PTUnit;
ui_umark_u        : integer = 0;
ui_umark_t        : byte = 0;
ui_color_max,                                       // unit max count color
ui_color_cenergy,                                         // energy limit colors
ui_color_limit,                                           // unit limit colors
ui_color_blink2,
ui_color_blink1   : array[false..true] of TMWColor;

// panel text positions
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
ui_GameLogHeight  : integer = 0;

// ui log
ui_log_s          : array of shortstring;
ui_log_t          : array of byte;
ui_log_c          : array of TMWColor;
ui_log_n          : integer = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  input keys
//

input_actions        : array[byte] of TInputKey;

////////////////////////////////////////////////////////////////////////////////
//
//  Keyborad input
//

k_KeyboardString  : shortstring = '';


// hotkeys
hotkeyP1 : THotKeyTable = (SDLK_R    , SDLK_T    , SDLK_Y     ,
                           SDLK_F    , SDLK_G    , SDLK_H     ,
                           SDLK_V    , SDLK_B    , SDLK_N     ,

                           SDLK_U    , SDLK_I    , SDLK_O     ,
                           SDLK_J    , SDLK_K    , SDLK_L     ,
                           SDLK_R    , SDLK_T    , SDLK_Y     ,

                           SDLK_F    , SDLK_G    , SDLK_H     ,
                           SDLK_V    , SDLK_B    , SDLK_N     ,
                           SDLK_R    , SDLK_T    , SDLK_Y     );

hotkeyP2 : THotKeyTable = (0         , 0         , 0          ,
                           0         , 0         , 0          ,
                           0         , 0         , 0          ,

                           0         , 0         , 0          ,
                           0         , 0         , 0          ,
                           SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl ,

                           SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl ,
                           SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl ,
                           SDLK_LCtrl, SDLK_LCtrl, SDLK_LAlt  );

// Action tab hotkeys
// unit orders
hotkeyA1 : THotKeyTable = (SDLK_Q    , SDLK_W    , SDLK_E     ,
                           SDLK_A    , SDLK_S    , SDLK_D     ,
                           SDLK_Z    , SDLK_X    , SDLK_C     ,

                           SDLK_C    , SDLK_F1   , SDLK_F2    ,
                           SDLK_Delete,SDLK_F5   , SDLK_Z     ,
                           0         , 0         , 0,

                           0         , 0         , 0          ,
                           0         , 0         , 0          ,
                           0         , 0         , 0          );

hotkeyA2 : THotKeyTable = (0         , 0         , 0          ,
                           0         , 0         , 0          ,
                           0         , 0         , 0          ,

                           SDLK_LCtrl, 0         , 0          ,
                           0         , SDLK_LCtrl, 0          ,
                           0         , 0         , 0          ,

                           0,0,0,
                           0,0,0,
                           0,0,0);
// replay controls
hotkeyR1 : THotKeyTable = (SDLK_Q    , SDLK_W    , SDLK_E     ,
                           SDLK_A    , SDLK_S    , SDLK_D     ,
                           SDLK_Z    , 0         , 0          ,

                           SDLK_1    , SDLK_2    , SDLK_3     ,
                           SDLK_4    , SDLK_5    , SDLK_6     ,
                           SDLK_7    , SDLK_8    , SDLK_0     ,

                           0,0,0,
                           0,0,0,
                           0,0,0);
hotkeyR2 : THotKeyTable = (0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0);

// observer controls
hotkeyO1 : THotKeyTable = (SDLK_Q    , SDLK_W    , 0          ,
                           SDLK_1    , SDLK_2    , SDLK_3     ,
                           SDLK_4    , SDLK_5    , SDLK_6     ,

                           SDLK_7    , SDLK_8    , SDLK_0,
                           0,0,0,
                           0,0,0,

                           0,0,0,
                           0,0,0,
                           0,0,0);
hotkeyO2 : THotKeyTable = (0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0,
                           0,0,0);

////////////////////////////////////////////////////////////////////////////////
//
//  COLORS
//

c_dred,
c_red,
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
c_ltgray,
c_gray,
c_dgray,
c_purple,
c_lpurple,
c_dpurple,
c_none,
c_black           : TMWColor;

////////////////////////////////////////////////////////////////////////////////
//
//  THEMES
//

theme_cur                 : integer = 0;

theme_anm_decors          : TThemeDecorAnimL;

theme_tile_terrain,
theme_tile_crater,
theme_tile_liquid         : pTMWTexture;
{theme_tile_terrain        : pTMWTexture = nil;
theme_tile_crater         : pTMWTexture = nil;
theme_tile_liquid         : pTMWTexture = nil;
theme_tile_teleport       : pTMWTexture = nil; }

theme_tileset_crater      : pTMWTileSet;
theme_tileset_liquid      : array[0..theme_anim_step_n-1] of pTMWTileSet;

// CURRENT THEME SETTINGS

// previous/current
theme_last_crater_tes     : TThemeEdgeTerrainStyle = tes_none;
theme_last_liquid_tes     : TThemeEdgeTerrainStyle = tes_none;
theme_last_liquid_tas     : byte = 255;

theme_last_tile_terrain_id: integer = -1;
theme_last_tile_crater_id : integer = -1;
theme_last_tile_liquid_id : integer = -1;

// current/new
theme_cur_crater_tes      : TThemeEdgeTerrainStyle = tes_nature; // theme liquid edge style
theme_cur_liquid_tes      : TThemeEdgeTerrainStyle = tes_nature; // theme liquid edge style
theme_cur_liquid_tas      : byte = tas_liquid; // theme liquid animation style
theme_cur_liquid_tasPeriod: byte = 30;
theme_cur_liquid_mmcolor  : cardinal = 0;      // theme liquid minimap color

theme_cur_tile_terrain_id,
theme_cur_tile_crater_id,
theme_cur_tile_liquid_id  : integer;

theme_cur_decal_l,
theme_cur_decor_l,
theme_cur_1rock_l,
theme_cur_2rock_l,
theme_cur_teleport_l,
theme_cur_crater_l,
theme_cur_liquid_l,
theme_cur_terrain_l       : TIntList;
theme_cur_decal_n,
theme_cur_decor_n,
theme_cur_teleport_n,
theme_cur_1rock_n,
theme_cur_2rock_n,
theme_cur_crater_n,
theme_cur_liquid_n,
theme_cur_terrain_n       : integer;

// ALL DATA
theme_all_decal_l,
theme_all_decor_l,
theme_all_terrain_l   : TMWTextureList;
theme_all_decal_n,
theme_all_decor_n,
theme_all_terrain_n   : integer;

theme_all_terrain_mmcolor  : array of cardinal;
theme_all_terrain_tas,
theme_all_terrain_tasPeriod: array of byte;


theme_name            : array[0..theme_n-1] of shortstring;

////////////////////////////////////////////////////////////////////////////////
//
//  SPRITES
//


tex_temp,
tex_dummy         : TMWTexture;
ptex_dummy        : PTMWTexture;

tex_menu,
tex_ui_MiniMap,
tex_map_gMiniMap,   // minimap: unit & ui layer
tex_map_mMiniMap,   // minimap: menu
tex_map_bMiniMap    // minimap: terrain background
                  : PTMWTexture;

spr_dmodel        : TMWSModel;
spr_pdmodel       : PTMWSModel;

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

spr_HKeep1,
spr_HKeep2,
spr_HGate1,
spr_HGate2,
spr_HGate3,
spr_HGate4,
spr_HSymbol1,
spr_HSymbol2,
spr_HSymbol3,
spr_HSymbol4,
spr_HPools1,
spr_HPools2,
spr_HPools3,
spr_HPools4,
spr_HTower,
spr_HTeleport,
spr_HMonastery,
spr_HTotem,
spr_HAltar,
spr_HFortress,
spr_HPentagram,
spr_HCommandCenter1,
spr_HCommandCenter2,
spr_HBarracks1,
spr_HBarracks2,
spr_HBarracks3,
spr_HBarracks4,
spr_HEye,

spr_UCommandCenter1,
spr_UCommandCenter2,
spr_UBarracks1,
spr_UBarracks2,
spr_UBarracks3,
spr_UBarracks4,
spr_UFactory1,
spr_UFactory2,
spr_UFactory3,
spr_UFactory4,
spr_UGenerator1,
spr_UGenerator2,
spr_UGenerator3,
spr_UGenerator4,
spr_UWeaponFactory1,
spr_UWeaponFactory2,
spr_UWeaponFactory3,
spr_UWeaponFactory4,
spr_UTurret,
spr_URadar,
spr_UTechCenter,
spr_UPTurret,
spr_URTurret,
spr_UCompStation,
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

spr_blood         : pTMWSModel;


spr_b4_a,
spr_b7_a,
spr_b9_a,
spr_ptur,
spr_scan,
spr_decay,
spr_invuln,
spr_hvision,
spr_stun,

spr_cp_koth,
spr_cp_out,
spr_cp_gen,

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
spr_b_attack,
spr_b_move,
spr_b_patrol,
spr_b_apatrol,
spr_b_stop,
spr_b_hold,
spr_b_selall,
spr_b_cancel,
spr_b_delete,
spr_mlogo,
spr_mback,
spr_cursor        : pTMWTexture;

spr_b_up          : array[1..r_cnt,0..spr_upgrade_icons] of pTMWTexture;
spr_mp            : array[1..r_cnt] of pTMWTexture;
spr_tabs          : array[0..3] of pTMWTexture;


////////////////////////////////////////////////////////////////////////////////
//
//  TEXT
//

str_bool                : array[false..true   ] of shortstring;

str_teams               : array[0..LastPlayer ] of shortstring;
str_racel               : array[0..r_cnt      ] of shortstring;
str_emnu_GameModel      : array[0..gms_count  ] of shortstring;

str_map_typel           : array[0..gms_m_types] of shortstring;
str_map_syml            : array[0..gms_m_symm ] of shortstring;
str_map_seed,
str_map_type,
str_map_size,
str_map_sym,
str_map_random,
str_map_Proc1Zones,
str_map_Proc2Solid,
str_map_Proc3Domains,
str_map_Proc4VisGrid,

str_ptype_AI,
str_ptype_cheater      : shortstring;

str_menu_PlayerSlots    : array[0..ps_states_n-1] of shortstring;
str_menu_StartGame,
str_menu_EndGame,
str_menu_Campaings,
str_menu_Scirmish,
str_menu_SaveLoad,
str_menu_LoadGame,
str_menu_LoadReplay,
str_menu_Settings,
str_menu_AboutGame,
str_menu_ReplayPlayback,
str_menu_ReplayQuit,
str_menu_Surrender,
str_menu_LeaveGame,
str_menu_Back,
str_menu_Start,
str_menu_Exit,
str_menu_connecting,
str_menu_maction,
str_menu_settingsGame,
str_menu_settingsReplay,
str_menu_settingsNetwork,
str_menu_settingsVideo,
str_menu_settingsSound,
str_menu_DeleteFile,

str_menu_save,
str_menu_load,

str_menu_FPS,
str_menu_APM,
str_menu_language,
str_menu_ColoredShadow,
str_menu_ScrollSpeed,
str_menu_MouseScroll,
str_menu_PlayerName,
str_menu_PanelPos,
str_menu_MiniMapPos,
str_menu_unitHBar,
str_menu_PlayersColor,

str_menu_ResolutionWidth,
str_menu_ResolutionHeight,
str_menu_Apply,
str_menu_fullscreen,
str_menu_SDLRenderer,
str_menu_RestartReq,

str_menu_NextTrack,
str_menu_SoundVolume,
str_menu_MusicVolume,
str_menu_MusicReload,
str_menu_PlayListSize,

str_menu_ready,
str_menu_nready,
str_menu_server,
str_menu_serverPort,
str_menu_chat,
str_menu_client,
str_menu_clientAddress,
str_menu_clientQuality,
str_menu_LANSearchStart,
str_menu_LANSearchStop,
str_menu_LANSearching,
str_menu_clientConnect,
str_menu_clientDisconnect,
str_menu_serverStart,
str_menu_serverStop,

str_menu_Name,
str_menu_Slot,
str_menu_Race,
str_menu_Team,
str_menu_Color,

str_menu_players,
str_menu_map,
str_menu_GameOptions,
str_menu_multiplayer,
str_menu_ReplayInfo,
str_menu_SaveInfo,

str_menu_RandomScirmish,
str_menu_AISlots,
str_menu_Generators,
str_menu_DeadObservers,
str_menu_FixedStarts,
str_menu_GameMode
                        : shortstring;
str_menu_PlayersColorl  : array[TPlayersColorSchema ] of shortstring;
str_menu_unitHBarl      : array[TUIUnitHBarsOption  ] of shortstring;
str_menu_PanelPosl      : array[TVidPannelPos       ] of shortstring;
str_menu_MiniMapPosl    : array[boolean,boolean     ] of shortstring;
str_menu_Generatorsl    : array[0..gms_g_maxgens    ] of shortstring;
str_menu_NetQuality     : array[0..cl_UpT_arrayN    ] of shortstring;

str_menu_ReplayPlay,
str_menu_ReplayName,
str_menu_ReplayQuality,
str_menu_Recording,
str_menu_ReplayState     : shortstring;
str_menu_ReplayStatel    : array[0..2] of shortstring = ('OFF','RECORD','PLAY');

str_menu_mactionl,
str_menu_lang            : array[false..true] of shortstring;

str_error_FileExists,
str_error_OpenFile,
str_error_WrongData,
str_error_FileRead,
str_error_FileWrite,
str_error_WrongVersion,
str_error_ServerFull,
str_error_GameStarted,

str_msg_ReplayStart,
str_msg_ReplayFail,
str_msg_GameSaved,
str_msg_PlayerSurrender,
str_msg_PlayerLeave,
str_msg_PlayerDefeated,
str_msg_PlayerPaused,
str_msg_PlayerResumed,

str_uiWarn_NeedEnergy,
str_uiWarn_CantBuild,
str_uiWarn_CantProd,
str_uiWarn_CheckReqs,
str_uiWarn_UnitPromoted,
str_uiWarn_UpgradeComplete,
str_uiWarn_BuildingComplete,
str_uiWarn_UnitComplete,
str_uiWarn_UnitAttacked,
str_uiWarn_BaseAttacked,
str_uiWarn_AlliesAttacked,
str_uiWarn_CantExecute,
str_uiWarn_MaxLimitReached,
str_uiWarn_MapMark,
str_uiWarn_NeedMoreBuilders,
str_uiWarn_ProductionBusy,
str_uiWarn_CantRebuild,
str_uiWarn_NeedMoreProd,
str_uiWarn_MaximumReached,

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
str_attr_transport,

str_uhint_UnitLevel,
str_uhint_UnitArming,
str_uhint_hits,
str_uhint_srange,
str_uhint_builder,
str_uhint_barrack,
str_uhint_smith,
str_uhint_IncEnergyLevel,
str_uhint_CanRebuildTo,
str_uhint_ability,
str_uhint_transformation,
str_uhint_requirements,
str_uhint_uprod,
str_uhint_bprod,
str_uhint_TargetLimit,
str_uhint_req,


str_weapon_melee,
str_weapon_ranged,
str_weapon_zombie,
str_weapon_ressurect,
str_weapon_heal,
str_weapon_spawn,
str_weapon_suicide,
str_weapon_targets,
str_weapon_damage,

str_chat_all,
str_chat_allies,

str_gsunknown,
str_pause,
str_win,
str_lose,
str_waitsv,
str_repend,

str_observer,

str_demons,
str_except,
str_splashresist
                    : shortstring;

str_panelHint_all,
str_panelHint_menu  : shortstring;
str_panelHint_a,
str_panelHint_r,
str_panelHint_o     : TPanelHintTable;
str_panelHint_Tab   : array[TTabType] of shortstring;
str_panelHint_Common: array[0..2    ] of shortstring;

str_uiHint_KotHTime,
str_uiHint_KotHTimeAct,
str_uiHint_KotHWinner,
str_uiHint_Time,
str_uiHint_UGroups,
str_uiHint_Army,
str_uiHint_Energy   : shortstring;

////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

SLpos              : array[0..2] of TALfloat;
SLori              : array[0..5] of TALfloat;

snd_svolume1       : single = 0.5;
snd_mvolume1       : single = 0.5;

snd_PlayListSize   : word = 5;

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













