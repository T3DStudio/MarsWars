
var

GameCycle         : boolean = false;
sys_EVENT         : pSDL_EVENT;

////////////////////////////////////////////////////////////////////////////////
//
//  GAME
//

g_tick            : cardinal = 0;
g_started         : boolean  = false;
g_status          : byte     = 0;

g_FixedPositions  : boolean  = false;
g_AISlots         : byte     = player_default_ai_level;
g_DefeatedObs     : boolean  = true;

g_royal_r         : integer  = 0;

g_PlayersMain     : TPList;
g_PlayersTemp     : array[0..LastPlayer ] of TPlayerTempData;
g_units           : array[0..MaxUnits   ] of TUnit;
g_punits          : array[0..MaxUnits   ] of PTUnit;

g_missiles        : array[0..MaxMissiles] of TMissile;

g_cycle_order     : integer = 0;
g_cycle_regen     : integer = 0;

g_uids            : array[byte] of TUID;
g_upgrs           : array[byte] of TUpgrade;
g_mids            : array[byte] of TMID;
g_DamageMods      : array[byte] of TDamageMod;
g_aids            : array[byte] of TUnitAbility;

g_random_i        : word    = 0;
g_random_p        : byte    = 0;

g_LobbyTimer      : integer = 0;
                  // [team,alarmN]
ai_TeamAlarms     : array[0..LastPlayer,0..ai_LastAlarm] of TAIAlarm;


////////////////////////////////////////////////////////////////////////////////
//
//  MAP
//

map_scenario      : byte     = mc_ffa8;
map_generators    : byte     = 0;
map_seed          : cardinal = 1;
map_Size1         : integer  = 5000;
map_Sizeh         : integer  = 2500;
map_SizeKPCR      : integer  = 100;
map_ObstaclesS    : byte     = 1;
map_ObstaclesGap  : integer  = 40;
map_PStartsGap    : integer  = base_r1;
map_Symmetry      : byte     = 0;

map_SymmetryDir   : integer  = 0;
map_MaxPlayers    : byte     = MaxPlayers;
map_PlayerStartX,
map_PlayerStartY  : array[0..LastPlayer] of integer;
map_ObstaclesL    : array[0..MaxObstacles] of TObstacle;
map_ObstaclesN    : integer = 0;
map_ObstaclesGrid : array[0..MapObstaclesGridN,0..MapObstaclesGridN] of TObstacleCell;
map_KeyPointsN    : byte = 0;
map_KeyPointsL    : array[0..LastKeyPoint] of TKeyPoint;

////////////////////////////////////////////////////////////////////////////////
//
//  OTHER BASE
//

UnitStepTicks     : byte = 10;

LastCreatedUnit   : integer = 0;
LastCreatedUnitP  : PTUnit;

net_status        : byte = 0;
net_ServerPort    : word = 10666;
net_TimerBase     : byte = 0;
net_svLanAdv      : boolean = true;
net_svLanAdv_timer: integer = 0;
net_TimerPing     : integer = 0;
net_wudata_t      : TWUDataTime;
net_kpoints_kpi   : byte = 0;
net_socket        : PUDPSocket;
net_buffer        : PUDPPacket;
net_bufpos        : integer = 0;

rpls_file         : file;
rpls_u            : integer = 0;
rpls_Quality      : byte = 0;
rpls_wudata_t     : TWUDataTime;
rpls_kpoints_kpi  : byte = 0;

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

{$IFDEF DEBUG0}
test_InstaProd    : boolean = true;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//
//   CLIENT GAME VARS
//

{$IFDEF _FULLGAME}

ServerSide        : boolean = true; // only server side code

g_type            : byte     = 0; // 0 = none, 1 = scirmish, 2 - campaing

g_eids            : array[byte] of TEID;
g_effects         : array[1..vid_MaxScreenSprites] of TEffect;
g_unitsVis        : array[0..MaxUnits] of TUnitVis;

missiles_UIDsBioEff         // units that trigger "bio" effect of missiles
                  : TSoB;

CircleRX2Y        : array[0..fog_MaxR,0..fog_MaxR] of integer;

TestMode          : byte = 0;
sys_uncappedFPS   : boolean = false;

LocalPlayer       : byte = 1; // 'this' player
PlayerName        : shortstring = 'DoomPlayer';
PlayerReady       : boolean = false;


////////////////////////////////////////////////////////////////////////////////
//
//  VIDEO
//

vid_screen          : pSDL_SURFACE;
vid_windowed        : boolean = true;
vid_draw            : boolean = true;
vid_RECT            : pSDL_RECT;

vid_ScreenSpritesL  : array[1..vid_MaxScreenSprites] of PTVisSpr;
vid_ScreenSpritesS  : word = 0;
vid_PrimitivesL     : array of TVisPrim;
vid_PrimitivesS     : word = 0;

vid_vw              : integer = 800;
vid_vh              : integer = 600;

vid_ShowFPS         : boolean = true;

////////////////////////////////////////////////////////////////////////////////
//
//  UI
//

UIPlayer          : byte = 1;

ui_InGameChat     : byte = 0;

ui_update_mmap    : integer = 0;

ui_blink_timer1   : integer = 0;
ui_blink_timer2   : integer = 0;

ui_blink1_colorb,
ui_blink2_colorb  : boolean;
ui_blink1_color_BG,
ui_blink1_color_BY,
ui_blink2_color_BG,
ui_blink2_color_BY: TMWColor;
ui_blink3         : byte;
ui_mm_ScanBlink   : boolean = false;

ui_panel_race     : byte = r_random;

ui_UIPanelTemplate,
ui_UIPanel,
ui_minimap,
ui_mminimap,
ui_bminimap       : pSDL_SURFACE;

ui_cam_w          : integer = 800;
ui_cam_hw         : integer = 400;
ui_cam_h          : integer = 600;
ui_cam_hh         : integer = 300;
ui_vmb_x0         : integer = 6;
ui_vmb_y0         : integer = 6;
ui_vmb_x1         : integer = 794;
ui_vmb_y1         : integer = 594;
ui_mwa            : integer = 0;
ui_mha            : integer = 0;

ui_cam_x          : integer = 0;
ui_cam_y          : integer = 0;
ui_cam_cx         : integer = 0;
ui_cam_cy         : integer = 0;
ui_cam_fx         : integer = 0;
ui_cam_fy         : integer = 0;
ui_cam_mmx,
ui_cam_mmy        : integer;

ui_CamSpeed       : integer = 25;
ui_HealthBars     : byte = 0;
ui_PlayersColor   : byte = 0;
ui_ShowAPM        : boolean = false;
ui_MouseScroll    : boolean = false;
ui_ColoredShadow  : boolean = true;
ui_ControlPanelPos: byte = 0;

ui_UIPanelX         : integer = 0;
ui_UIPanelY         : integer = 0;
ui_UIPanelW         : integer = 0;
ui_UIPanelH         : integer = 0;
ui_UIPortX0,
ui_UIPortY0,
ui_UIPortX1,
ui_UIPortY1       : integer;

ui_fog_fgrid,
ui_fog_pgrid      : array of array of boolean;
ui_fog_gridw      : integer = 0;
ui_fog_gridh      : integer = 0;
ui_fog            : boolean = true;
//ui_fog_surf       : pSDL_Surface;
ui_fog_Tiles      : TFogTileSet;
ui_fog_sx         : integer = 0;
ui_fog_sy         : integer = 0;
ui_fog_ex         : integer = 0;
ui_fog_ey         : integer = 0;

ui_language       : boolean = false;
ui_tab_Auto       : boolean = true;

ui_CommandercPU   : PTUnit = nil;
ui_CommandercD    : integer = 0;
ui_CommandercW    : byte = 0;
ui_CommanderpPU   : PTUnit = nil;
ui_UnitSelSound   : boolean = false;
ui_UnitSelSoundA  : integer = 0;
ui_tab            : byte = 0;
ui_alarms         : array[0..ui_max_alarms] of TAlarm;
ui_panel_uids     : array[0..r_count,0..2,0..ui_ButtonsNum] of byte;
ui_panel_CTabIActs: array[TTabControlContent,0..ui_ButtonsNum] of byte;
ui_panel_PTabIActs: array[0..ui_ButtonsNum] of byte;

ui_mc_x,                                                 //
ui_mc_y,                                                 // mouse click effect
ui_mc_a           : integer;                             //
ui_mc_c           : TMWColor;                            //

ui_uprod_max,
ui_uprod_cur,
ui_uprod_first,
ui_pprod_max,
ui_pprod_cur      : integer;
ui_units_inapc,
ui_uprod_uid_max,
ui_uprod_uid_time,
ui_pprod_upg_max,
ui_pprod_upg_time     : array[byte] of integer;
ui_pprod_first    : integer;
ui_bprod_possible : TSoB;
ui_bprod_uid_count,
ui_bprod_ucl_count,
ui_bprod_ucl_time : array[byte] of integer;
ui_bprod_first,
ui_bprod_cur      : integer;
ui_uid_reload     : array[byte] of integer;
ui_bucl_reload    : array[byte] of integer;
ui_uibtn_rpoint   : integer = 0;   // ui rally point
ui_uibtn_move     : integer = 0;   // ui move buttons
ui_uibtn_attack   : integer = 0;   // ui attack buttons
ui_uibtn_apatrol  : integer = 0;   // ui apatrol button
ui_uibtn_ProdCncl : integer = 0;   // ui prod cancel button

ui_DrawEdges      : boolean = false;
ui_umark_u        : integer = 0;
ui_umark_t        : byte = 0;
ui_max_color,                                       // unit max count color
ui_cenergy,                                         // energy limit colors
ui_limit,                                           // unit limit colors
ui_blink_color2,
ui_blink_color1   : array[false..true] of TMWColor;

ui_group_d        : array[0..MaxUnitGroups] of TUnitGroup;
ui_group_f1       : TUnitGroup;
ui_group_f2       : TUnitGroup;
ui_groupX         : integer = 0;  // order icons screen X
ui_groupY         : integer = 0;  // order icons screen Y

ui_UIPortXC       : integer = 0;
ui_PovPlayerY     : integer = 0;
ui_timerX         : integer = 0;
ui_timerY         : integer = 0;
ui_MouseHintX     : integer = 0;
ui_MouseHintY     : integer = 0;
ui_MouseHintL     : TUIStringList;

ui_ReplayBarW     : integer = 0;
ui_ReplayBarH     : integer = font_w2;
ui_ReplayBarX     : integer = 0;
ui_ReplayBarY     : integer = 0;
ui_GameStatusX    : integer = 0;
ui_GameStatusY    : integer = 0;
ui_EnergyX        : integer = 0;
ui_EnergyY        : integer = 0;
ui_HellPowerY     : integer = 0;
ui_UACLootY       : integer = 0;
ui_ArmyX          : integer = 0;
ui_ArmyY0         : integer = 0;
ui_ArmyY1         : integer = 0;
ui_ArmyY2         : integer = 0;
ui_FPSX           : integer = 0;
ui_FPSY           : integer = 0;
ui_APMx           : integer = 0;
ui_APMy           : integer = 0;
ui_RECx           : integer = 0;
ui_RECy           : integer = 0;

ui_objectivesx    : integer = 0;
ui_objectivesy    : integer = 0;


ui_logx           : integer = 0;  // LOG screen X
ui_logy           : integer = 0;  // LOG screen Y
ui_log_LineLen    : byte = 0;
ui_log_ListSize   : integer = 0;
ui_log_lines      : array of shortstring;
ui_log_type       : array of byte;
ui_log_color      : array of TMWColor;
ui_log_n          : integer = 0;
ui_log_LastTimer  : integer = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  MENU
//

menu_SurfaceSC,
menu_Surface      : pSDL_SURFACE;

menu_sc_x,
menu_sc_y         : integer;
menu_sc_cx        : single;

MainMenu          : boolean = true;

menu_DarkBack     : boolean = false;
menu_Page         : byte = 0;
menu_SettingsPage : byte = mi_settings_Game;
menu_HelpPage     : byte = mi_help_Credits;
menu_HelpUID      : byte = UID_HKeep;
menu_HelpScroll   : integer = 0;
menu_HelpIList    : PTUIStringList = nil;
menu_ItemActs     : byte = 0;
menu_ItemTarget   : byte = 0;
menu_ItemTargetP  : byte = 0; // previous
menu_ItemSelected : byte = 0;
menu_items        : array[byte] of TMenuItem;
menu_update       : boolean = true;
menu_redraw       : boolean = true;
menu_redraw_pause : integer = 0;
menu_msg_type     : TMenuMessageBoxType;
menu_msg_Caption,
menu_msg_Body     : shortstring;

menu_hint_pos     : array[byte] of byte;

menu_ResolutionWi,
menu_ResolutionHi : integer;

menu_mseed        : shortstring = '1';
menu_ServerPort   : shortstring = '10666';
menu_ClientAddress: shortstring = '127.0.0.1:10666';

menu_scale        : boolean = true;
menu_ScaleSmooth  : boolean = false;

menu_ChatListH    : integer = 0;
menu_ChatScroll   : integer = 0;


////////////////////////////////////////////////////////////////////////////////
//
//  MAP VISUAL
//

map_MiniMap_cx    : single;
map_MiniMap_CamW,
map_MiniMap_CamH  : integer;

map_fog_ex,
map_fog_ey        : integer;

map_terrain       : pSDL_SURFACE;

map_ter_w,
map_ter_h         : integer;

map_ter_decaln    : integer = 0;
map_ter_decalL    : array of TDecal;

map_ObstaclesVis  : array[0..MaxObstacles] of TObstacleVis;
map_KeyPointsVis  : array[0..LastKeyPoint] of TKeyPointVis;


////////////////////////////////////////////////////////////////////////////////
//
//  CAMPAINGS
//

camp_diff     : byte = 1;
camp_data     : TCampaignData;
camp_size     : integer = 0;
camp_scroll   : integer = 0;
camp_list     : TStringArray;
camp_sel      : integer = 0;

camp_mis_sel  : integer = 0;
camp_mis_scroll:integer = 0;
camp_mis_list : array of TStringArray;
camp_mis_size : array of integer;

////////////////////////////////////////////////////////////////////////////////
//
//  NET
//

net_cl_svip       : cardinal = 0;
net_cl_svport     : word = 10666;
net_cl_svttl      : integer = 0;
net_cl_Hoster     : byte = 0;
net_cl_Quality    : byte = 4;
net_cl_log_n      : cardinal = 0;
net_chat_str      : shortstring = '';

net_SvList        : boolean = false;
net_SvList_listi  : array of TServerInfo;
net_SvList_lists  : TStringArray;
net_SvList_scroll : integer = 0;
net_SvList_Size   : integer = 0;
net_SvList_sel    : integer = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  SAVE LOAD
//

svld_str_info1    : shortstring = '';
svld_str_info2    : shortstring = '';
svld_str_fname    : shortstring = '';
svld_items        : array of TSaveLoadItem;
svld_itemn        : integer = 0;
svld_list         : TStringArray;
svld_list_sel     : integer = 0;
svld_list_scroll  : integer = 0;
svld_list_size    : integer = 0;
svld_file_size    : cardinal = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  RECORDS
//

rpls_Record       : boolean = true;
rpls_RecordTryPause:integer = 0;
rpls_fstate       : byte = 0;         // file status (none,write,read)
rpls_pstate       : byte = rpls_none; // player/recorder status
rpls_pnu          : integer = 0;      // quality
rpls_NamePrefix   : shortstring = 'LastReplay';
rpls_str_path     : shortstring = '';
rpls_str_info1    : shortstring = '';
rpls_str_info2    : shortstring = '';
rpls_list         : TStringArray;
rpls_list_sel     : integer = 0;
rpls_list_scroll  : integer = 0;
rpls_list_size    : integer = 0;
rpls_ReadPosN     : cardinal = 0;
rpls_ReadPosL     : array of TReplayPos;
rpls_ForwardSkip  : integer = 0;
rpls_FastSkip     : boolean = false;
rpls_vidx         : byte = 0;
rpls_vidy         : byte = 0;
rpls_player       : byte = 0;
rpls_GameStatus   : byte = 0;
rpls_showlog      : boolean = false;
rpls_POVRecorder  : boolean = false;
rpls_Ticks        : cardinal = 0;
rpls_head_items   : array of TSaveLoadItem;
rpls_head_itemn   : integer = 0;
rpls_file_head_size
                  : cardinal = 0;
rpls_file_size    : cardinal = 0;
rpls_file_Pos     : cardinal = 0;
rpls_file_LastErr : word = 0;
rpls_file_LastErrS: shortstring = '';
rpls_log_c        : cardinal = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  INPUT
//

mouse_select_xs0,
mouse_select_ys0,
mouse_map_x,
mouse_map_y,
mouse_x,
mouse_y           : integer;
m_brushc          : TMWColor;
m_brushx,
m_brushy,
m_brush           : integer;
m_uifocus         : TMouseFocus;
m_btnN            : integer;
m_DragCamMove     : boolean = false;
m_RightClickAct   : boolean = true;
m_mmap_move       : boolean = false;

m_UnitTargetN     : integer = 0;
m_UnitTargetP     : PTUnit = nil;


input_actions     : array[byte] of TInputKey;

k_LastChar_t      : integer;
k_LastChar        : char;
k_KeyboardString  : shortstring = '';

////////////////////////////////////////////////////////////////////////////////
//
//  COLORS
//

c_dred,
c_awhite,
c_red,
c_ared,
c_orange,
c_dorange,
c_aorange,
c_brown,
c_yellow,
c_dyellow,
c_lime,
c_alime,
c_green,
c_ablue,
c_blue,
c_aqua,
c_aaqua,
c_white,
c_agray,
c_ltgray,
c_gray,
c_dgray,
c_ablack,
c_mablack,
c_purple,
c_violet,
c_black           : TMWColor;

PlayerColorsDefault,
PlayerColorsCurrent,
PlayerColorsShadow : array[0..LastPlayer] of TMWColor;
PlayerColorDefaultCurrent: TMWColor = 0;
PlayerColorDefaultShadow : TMWColor = 0;

////////////////////////////////////////////////////////////////////////////////
//
//  THEMES
//

theme_n              : integer = 0;
theme_i              : integer = 0;

theme_liquid_animStyle: TThemeAnimStyle;
theme_liquid_animTime : byte;
theme_liquid_color    : TMWColor = 0;

theme_liquid_style,
theme_crater_style   : TThemeCircleStyle;

theme_map_Terrain    : integer = 0;
theme_map_pTerrain   : integer = -1;
theme_map_Crater     : integer = 0;
theme_map_pCrater    : integer = -1;
theme_map_LiquidFront: integer = 0;
theme_map_pLiquidFront:integer = -1;
theme_map_LiquidBack : integer = 0;
theme_map_pLiquidBack: integer = -1;
theme_map_RBattleFront: integer = 0;
theme_map_pRBattleFront:integer = -1;



theme_decalL,
theme_obstacle0L,
theme_obstacle1L,
theme_obstacle2L,
theme_craterL,
theme_liquidFrontL,
theme_liquidBackL,
theme_terrainL          : TIntList;
theme_decalN,
theme_obstacle0N,
theme_obstacle1N,
theme_obstacle2N,
theme_craterN,
theme_liquidFrontN,
theme_liquidBackN,
theme_terrainN          : integer;

theme_spr_decalL,
theme_spr_obstaclesL,
theme_spr_liquidL,
theme_spr_terrainL      : TUSpriteList;
theme_spr_decalN,
theme_spr_obstaclesN,
theme_spr_liquidN,
theme_spr_terrainN      : integer;

theme_obstacles_Anims   : TThemeObstacleAnimL;

theme_liquids_AnimStyle : array of TThemeAnimStyle;
theme_liquids_AnimTime  : array of byte;
theme_liquids_MMColor   : array of TMWColor;


////////////////////////////////////////////////////////////////////////////////
//
//  SPRITES
//


theme_DefSprite,

spr_empty         : pSDL_SURFACE;
font_1            : array[char] of TMWTexture;

spr_liquidBack    : TMWTexture;
spr_liquidFront   : TLiquidTextureArray;
spr_fireblueBack  : TMWTexture;
spr_fireblueFront : TLiquidTextureArray;
spr_crater        : array[1..crater_ri      ] of TMWTexture;


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
spr_ZShotgunner,
spr_ZSSGunner,
spr_ZCommando,
spr_ZAntiaircrafter,
spr_ZSiege,
spr_ZPlasmagunner,
spr_ZBFG,

spr_Engineer,
spr_Medic,
spr_Shotgunner,
spr_SSGunner,
spr_Commando,
spr_Antiaircrafter,
spr_Siege,
spr_Plasmagunner,
spr_BFG,
spr_Transport,
spr_Terminator,
spr_Tank,
spr_Flyer,
spr_ATransport,
spr_UACDron,

spr_HKeep,
spr_HAKeep,
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
spr_HFTower,
spr_HSTower,
spr_HTeleport,
spr_HMonastery,
spr_HTotem,
spr_HAltar,
spr_HFortress,
spr_HPentagram,
spr_HCommandCenter,
spr_HACommandCenter,
spr_HBarracks1,
spr_HBarracks2,
spr_HBarracks3,
spr_HBarracks4,
spr_HEye,
spr_HEyeNest,

spr_UCommandCenter,
spr_UACommandCenter,
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
spr_UAcademy,
spr_UHPowerConductor,

spr_UTechCenter,
spr_UPTurret,
spr_URTurret,
spr_UNuclearPlant,
spr_URocketL,

spr_portal,
spr_starport,
spr_ubase0,
spr_ubase1,
spr_ubase2,
spr_ubase3,
spr_ubase4,
spr_ubase5,
spr_ubuild0,
spr_ubuild1,
spr_ubuild2,
spr_ubuild3,

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
spr_u_p9,

spr_db_h0,
spr_db_h1,
spr_db_u0,
spr_db_u1,

spr_blood            : TMWSModel;
spr_pdmodel          : PTMWSModel; // default empty model

spr_RallyPoint       : array[1..r_count] of TMWTexture;
spr_b4_a,
spr_b7_a,
spr_b9_a,
spr_ptur,
spr_buff_Scan,
spr_buff_Decay,
spr_buff_SphereInvuln,
spr_buff_SphereInvis,
spr_buff_SphereDArmor,
spr_buff_SphereDDamage,
spr_buff_SphereTurbo,
spr_buff_HellVision,
spr_buff_Stun,
spr_buff_Heroic      : TMWTexture;


spr_camp_mars,
spr_camp_hell,
spr_camp_earth,
spr_camp_phobos,
spr_camp_deimos ,
spr_uibtn_mmark,
spr_uibtn_ReplayFast,
spr_uibtn_ReplayForw1,
spr_uibtn_ReplayForw2,
spr_uibtn_ReplayForw3,
spr_uibtn_ReplayBack1,
spr_uibtn_ReplayBack2,
spr_uibtn_ReplayBack3,
spr_uibtn_ReplayFog,
spr_uibtn_ReplayLog,
spr_uibtn_ReplayPause,
spr_uibtn_ReplayPOV,
spr_uibtn_AbilitySInvuln,
spr_uibtn_AbilitySInvis,
spr_uibtn_AbilitySSoul,
spr_uibtn_AbilitySDDamage,
spr_uibtn_AbilitySRDamage,
spr_uibtn_AbilitySTurbo,
spr_uibtn_AbilityPretEquip,
spr_uibtn_AbilityBribe,
spr_uibtn_AbilityHack,
spr_uibtn_AbilityUACStrike,
spr_uibtn_AbilityUACScan,
spr_uibtn_AbilityBlink,
spr_uibtn_AbilitySpawnLost,
spr_uibtn_AbilitySpawnLostTo,
spr_uibtn_AbilityHVision,
spr_uibtn_AbilityUnload,
spr_uibtn_AbilityUnloadTo,
spr_uibtn_AbilityCCLand,
spr_uibtn_AbilityCCLandTo,
spr_uibtn_Attack,
spr_uibtn_Move,
spr_uibtn_Patrol,
spr_uibtn_APatrol,
spr_uibtn_Stop,
spr_uibtn_Hold,
spr_uibtn_F1,
spr_uibtn_F2,
spr_uibtn_ProdCancel,
spr_uibtn_Delete,
spr_MenuBackgroundL,
spr_MenuBackgroundD,
spr_cursor,
spr_cursorSubR,
spr_cursorSubG,
spr_cursorSubA,
spr_CursorHint_Edit  : pSDL_Surface;
spr_CursorHint_MLB,
spr_CursorHint_MRB,
spr_CursorHint_MMB   : array[boolean ] of pSDL_Surface;
spr_cursor_move      : array[0..8] of pSDL_Surface;
spr_cursor_movex,
spr_cursor_movey     : array[0..8] of integer;
spr_RaceRank,
spr_uipanel_EmptyBTN : array[1..r_count] of pSDL_Surface;
spr_uibtn_Upgrades   : array[1..r_count,0..spr_upgrade_icons] of TMWTexture;
spr_uibtn_Tabs       : array[0..3] of pSDL_Surface;
spr_kp_koth,
spr_kp_out,
spr_kp_outG          : TMWTexture;
spr_kp_gen           : array[0..1] of TMWTexture;

spr_cursorWh,
spr_cursorHh         : integer;

//spr_ui_oico        : array[1..r_count,false..true,byte] of pSDL_Surface;


////////////////////////////////////////////////////////////////////////////////
//
//  TEXT
//

str_doc_BaseControls,
str_doc_BaseMechanics,
str_doc_HotKeys,
str_doc_Other,
str_doc_Credits
                    : TUIStringList;

str_themes          : array of shortstring;

str_race            : array[0..r_count  ] of shortstring;
str_map_ScenarioL,
str_fileinfo_ScenarioL: array[0..mc_Last] of shortstring;

str_ps_AI,
str_ps_Hum,
str_ps_Host         : string4;

str_lobby_PlayerReady: array[false..true] of shortstring;

str_lobby_GameResetIn,
str_lobby_GameStartIn,
str_lobby_ReadyToStart,
str_lobby_BreakStarting,

str_help_Credits,
str_help_GameControls,
str_help_GameHotKeys,
str_help_GameUI,
str_help_GameMechanics,
str_help_UnitsInfo,
str_help_BalanceTable,
str_help_Other,

str_doc_HotKey,
str_doc_Attributes,
str_doc_ReqEnergy,
str_doc_ReqHellPower,
str_doc_ReqUACLoot,
str_doc_ProdTime,
str_doc_Limit,
str_doc_MaxHits,
str_doc_BaseRegen,
str_doc_BaseSightR,
str_doc_Size,
str_doc_BaseMSpeed,
str_doc_Role,
str_doc_Description,
str_doc_PainC,
str_doc_TransportSize,
str_doc_TransportCpst,
str_doc_LevelArmorBonus,
str_doc_LevelDamageBonus,
str_doc_LevelPainSBonus,
str_doc_BountyHellPower,
str_doc_BountyUACLoot,
str_doc_ZombieUID,
str_doc_ZombieHits,
str_doc_DeathUnit,
str_doc_LMB,
str_doc_RMB,
str_doc_MWH,
str_doc_UpgrArmor,
str_doc_UpgrRegen,
str_doc_UpgrSpeed,
str_doc_UpgrPainS,
str_doc_UpgrSightR,
str_doc_UpgrTransport,
str_doc_BalanceGood,
str_doc_BalanceBad,
str_doc_BalanceUseless,
str_doc_unitBalanceNote,

str_menu_Campaings,
str_menu_Scirmish,
str_menu_Playback,
str_menu_SaveLoad,
str_menu_LoadGame,
str_menu_Replays,
str_menu_Settings,
str_menu_Help,

str_menu_Start,
str_menu_Cancel,
str_menu_Surrender,
str_menu_Abort,
str_menu_PlaybackStop,
str_menu_Exit,
str_menu_Back,
str_menu_Pause,
str_menu_Chat,

str_menuMsg_HintDefault,
str_menuMsg_HintClient,

str_S_Game,
str_S_Replay,
str_S_Video,
str_S_Sound,

str_SG_ControlPanelPos,
str_SG_ColoredShadow,
str_SG_HealthBars,
str_SG_PlayersColor,
str_SG_PlayerName,
str_SG_Language,
str_SG_RightClickAct,
str_SG_ScrollSpeed,
str_SG_MouseScroll,
str_SG_ShowAPM,
str_SG_ControlPanelAuto,

str_SR_RecordGames,
str_SR_ReplayPrefix,
str_SR_Quality,

str_GO_AISlots,
str_GO_DefeatedObs,
str_GO_FixedStarts,
str_GO_Random,

str_SV_ResolutionW,
str_SV_ResolutionH,
str_SV_ResolutionApply,
str_SV_Windowed,
str_SV_MenuScale,
str_SV_MenuScaleSmooth,
str_SV_ShowFPS,

str_SS_NextTrack,
str_SS_MusicListSize,
str_SS_ReloadMusic,
str_SS_SoundVolume,
str_SS_MusicVolume,

str_FilePlay,
str_FileInfo,
str_FileSave,
str_FileLoad,
str_FileDelete,
str_FileReWrite,

str_FileError_NExists,
str_FileError_Open,
str_FileError_WData,
str_FileError_WVer,

str_net_ServerStart,
str_net_ServerStop,
str_net_Connect,
str_net_Disconnect,
str_net_ServerList,
str_net_ServerListAdd,

str_hint_upgrade,
str_hint_sec,
str_hint_TransformTo,
str_hint_UpgradesLvl,
str_hint_Demons,
str_hint_Except,
str_hint_UnitArming,
str_hint_Abilities,
str_hint_SplashResist,
str_hint_SightR,
str_hint_Ability,
str_hint_builder,
str_hint_barrack,
str_hint_forge,
str_hint_IncEnergyLevel,
str_hint_CanRebuildTo,
str_hint_TargetLimit,
str_hint_requirements,
str_hint_req,
str_hint_uprod,
str_hint_bprod,

str_ability_passive,
str_ability_active,
str_ability_notarget,
str_ability_point,
str_ability_UnitAny,
str_ability_UnitOwn,
str_ability_UnitAlly,
str_ability_UnitEnemy,
str_ability_reload,
str_ability_ReloadFactors,
str_ability_rldDecByLevel,

str_uarm_melee,
str_uarm_ranged,
str_uarm_zombie,
str_uarm_ressurect,
str_uarm_heal,
str_uarm_spawn,
str_uarm_targets,
str_uarm_BaseImpact,
str_uarm_MinRange,
str_uarm_MaxRange,
str_uarm_SplashDamageR,
str_uarm_BonusAFlyR,
str_uarm_BonusAGroundR,
str_uarm_BonusAUnitR,
str_uarm_BonusABuildingR,
str_uarm_Upgrade,
str_uarm_Factor,

str_gmsg_RecordStart,
str_gmsg_RecordError,
str_gmsg_RecordStop,
str_gmsg_PlayerPaused,
str_gmsg_PlayerResumed,
str_gmsg_PlayerConnected,
str_gmsg_PlayerLeave,
str_gmsg_PlayerTimeOut,
str_gmsg_PlayerSurrender,
str_gmsg_PlayerDefeat,
str_gmsg_PlayerRevealed,
str_gmsg_GameSaved,
str_gmsg_GameLoaded,
str_gmsg_WrongVersion,
str_gmsg_ServerFull,
str_gmsg_GameStarted,
str_gmsg_PortBlocked,

str_gstat_WaitForServer,
str_gstat_WaitForPlayers,
str_gstat_Unknown,
str_gstat_ReplayEnd,
str_gstat_ReplayError,
str_gstat_ReplayPaused,
str_gstat_GamePaused,
str_gstat_Lobby,
str_gstat_Started,
str_gstat_WonByTeam,
str_gstat_Win,
str_gstat_Lose,

str_attr_alive,
str_attr_dead,
str_attr_detector,
str_attr_heroic,
str_attr_stuned,
str_attr_SInvuln,
str_attr_SInvis,
str_attr_SRDamage,
str_attr_SDDamage,
str_attr_STurbo,
str_attr_HVision,
str_attr_Scaned,
str_attr_Decay,
str_attr_level,
str_attr_building,
str_attr_unit,
str_attr_mech,
str_attr_bio,
str_attr_light,
str_attr_heavy,
str_attr_fly,
str_attr_ground,

str_warn_prod_BadPlace,
str_warn_prod_BadOrder,
str_warn_Req_Energy,
str_warn_Req_HellPower,
str_warn_Req_UACLoot,
str_warn_Req_Common,
str_warn_unit_MaxLevel,
str_warn_unit_Levelup,
str_warn_unit_complete,
str_warn_unit_attacked,
str_warn_unit_resurrected,
str_warn_unit_captured,
str_warn_unit_lost,
str_warn_upgrade_complete,
str_warn_building_complete,
str_warn_base_attacked,
str_warn_allies_attacked,
str_warn_Invalid_Order,
str_warn_Invalid_Target,
str_warn_AbilityReload,
str_warn_AbilityBadPlace,
str_warn_kpoint_captured,
str_warn_kpoint_lost,
str_warn_koth_control,
str_warn_ngen_exh,
str_warn_ngen_captured,
str_warn_ngen_lost,
str_warn_MaxLimitReached,
str_warn_mapMark,
str_warn_NeedBuilder,
str_warn_prod_AllBusy,
str_warn_upgrade_InProgress,
str_warn_NeedProdUnit,
str_warn_MaxCountReached,

str_map,
str_map_Scenario,
str_map_Generators,
str_map_Seed,
str_map_Size,
str_map_Obstacles,
str_map_Symmetry,
str_map_Random,

str_ui_UnitGroups,
str_ui_ChatAll,
str_ui_ChatAllies,
str_ui_menu,
str_ui_time,
str_ui_KothTime,
str_ui_KotHTime_act,
str_ui_KotHWinner,
str_ui_LimitArmy,
str_ui_LimitBuildings,
str_ui_LimitUnits,
str_ui_EnergyLevel,
str_ui_HellPower,
str_ui_UACLoot,
str_ui_objectives,
str_ui_SelectTarget,

str_objective_Scirmish,
str_objective_RoyalBattle,
str_objective_KotH,
str_objective_KeyPoints,

str_Camp_Difficulty,
str_Camp_Campaign,
str_Camp_Mission,

str_all,
str_Players,
str_observer,

str_net_Ready,
str_net_UDPPort,
str_net_ServerLANAdv,
str_net_ConnectedToDed,
str_net_Quality,
str_net_Address,

str_PT_Player,
str_PT_State,
str_PT_Race,
str_PT_Team,
str_PT_Color,
str_PT_Ping,
str_PT_Obs,

str_Caption_Server,
str_Caption_Client,
str_Caption_GOptions,
str_Caption_Objectives,
str_Caption_Multiplayer,
str_Caption_NetSvList,
str_Caption_Map,
str_Caption_Players      : shortstring;

str_NetQualityL,
str_ReplayQualityL       : array[0..net_MaxQuality] of shortstring;
str_Camp_DifficultyL     : array[0..camp_Maxdiff  ] of shortstring;
str_ui_Tab               : array[0..3] of shortstring;

str_map_GeneratorsL      : array[0..mapg_Last ] of shortstring;
str_map_SymmertyL        : array[0..maps_Last ] of shortstring;
str_SG_PlayersColorL     : array[0..ui_MaxPlayersColor] of shortstring;
str_SG_HealthBarsL       : array[0..2] of shortstring;
str_SG_ControlPanelPosL  : array[0..3] of shortstring;

str_action_hint,
str_menu_hint            : array[byte] of shortstring;

str_and                  : shortstring;
str_YesNoC,
str_YesNoG,
str_SG_LanguageL,
str_SG_RightClickActL    : array[false..true] of shortstring;

str_rstatus              : array[0..2] of shortstring = ('OFF','RECORD','PLAY');

////////////////////////////////////////////////////////////////////////////////
//
//  SOUND
//

SLpos              : array[0..2] of TALfloat;
SLori              : array[0..5] of TALfloat;

snd_SoundVolume    : byte = 50;
snd_MusicVolume    : byte = 50;
snd_svolume1       : single = 0.5;
snd_mvolume1       : single = 0.5;
snd_musicListSize  : byte = 5;

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


snd_under_attack   : array[false..true,1..r_count] of PTSoundSet;
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
snd_unit_promoted,
snd_rally_point
                   : array[1..r_count] of PTSoundSet;

snd_RadarScan,
snd_PowerUp,

snd_uac_cc,
snd_uac_barracks,
snd_uac_generator,
snd_uac_forge,
snd_uac_ctower,
snd_uac_radar,
snd_uac_rtower,
snd_uac_factory,
snd_uac_tech,
snd_uac_rls,
snd_uac_nucl,
snd_uac_suply,
snd_uac_rescc,
snd_uac_academy,

snd_uac_hdeath,

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

snd_IconOfSinCube,
snd_shot_pistol,
snd_shot_shotgun,
snd_shot_ssg,
snd_shot_plasma,
snd_shot_bfg,
snd_explode_bfg,
snd_Healing,
snd_repairing,
snd_JetPackOn,
snd_click,
snd_chat,
snd_rico,
snd_shot_flyer,
snd_explode_flyer,
snd_shot_rocket,
snd_CCenterLiftUp,
snd_bomblaunch,
snd_Gibs,
snd_explode_building,
snd_Transport,
snd_Teleport,
snd_explode_plasma,
snd_explode,
snd_mapmark,
snd_KeyPointControl,
snd_KeyPointCapture,
snd_KeyPointLost,
snd_SwitchOn,
snd_SwitchOff,
snd_Stink,
snd_hell
              : PTSoundSet;


{$ELSE}

menu_update       : boolean = true;
console_y         : integer = 0;

{$ENDIF}














