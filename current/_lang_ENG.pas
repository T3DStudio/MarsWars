

procedure lng_eng;
var
t1:shortstring;
i :byte;
begin
   //   ACTIONS
   for i:=0 to 255 do
     input_actions[i].ik_str_HK:=str_ActionHotKey(i);

   str_ps_AI                     := 'AI';
   str_ps_Host                   := 'HOST';
   str_ps_Hum                    := 'HUM';

   str_Caption_Map               := 'MAP';
   str_Caption_Players           := 'PLAYERS';
   str_Caption_Multiplayer       := 'MULTIPLAYER';
   str_Caption_GOptions          := 'GAME OPTIONS';
   str_Caption_Server            := 'SERVER';
   str_Caption_Client            := 'CLIENT';
   str_Caption_Objectives        := 'OBJECTIVES';
   str_Caption_NetSvList         := 'SERVER LIST';

   str_menu_Campaings            := 'TUTORIALS&CAMPAIGNS';
   str_menu_Scirmish             := 'SKIRMISH';
   str_menu_Playback             := 'REPLAY PLAYBACK';
   str_menu_SaveLoad             := 'SAVE/LOAD';
   str_menu_LoadGame             := 'LOAD GAME';
   str_menu_Replays              := 'REPLAYS';
   str_menu_Settings             := 'SETTINGS';
   str_menu_Help                 := 'HELP';

   str_menu_Start                := 'START';
   str_menu_Cancel               := 'CANCEL';
   str_menu_Surrender            := 'SURRENDER';
   str_menu_Abort                := 'ABORT MISSION';
   str_menu_PlaybackStop         := 'STOP PLAYBACK';
   str_menu_Exit                 := 'EXIT';
   str_menu_Back                 := 'BACK';

   str_menu_Chat                 := 'chat(all players)';
   str_menu_Pause                := 'Pause';
   str_menu_InGameTime           := 'In-game timer: ';

   str_or                        := 'or';
   str_and                       := 'and';
   str_YesNoG[true ]             := 'YES';
   str_YesNoG[false]             := 'NO';
   str_YesNoC[true ]             := tc_lime+str_YesNoG[true ]+tc_default;
   str_YesNoC[false]             := tc_red +str_YesNoG[false]+tc_default;

   str_lobby_PlayerReady[false]  := ' is '+tc_red +'not ready';
   str_lobby_PlayerReady[true ]  := ' is '+tc_lime+'ready';
   str_lobby_ReadyToStart        := 'Game is ready to start!';
   str_lobby_BreakStarting       := 'Game is not ready!';
   str_lobby_GameStartIn         := 'Game starts in ';
   str_lobby_GameResetIn         := 'Reset in the lobby in ';

   str_menuMsg_HintImg           := '- press any key to close -';
   str_menuMsg_HintDefault       := '- press any key to close the message -';
   str_menuMsg_HintClient        := '- press any key to disconnect -';

   str_S_Game                    := 'GAME';
   str_S_Replay                  := 'RECORDING';
   str_S_Video                   := 'VIDEO';
   str_S_Sound                   := 'SOUND';

   str_SR_RecordGames            := 'Record games';
   str_SR_Quality                := 'File size/quality';
   str_SR_ReplayPrefix           := 'Replay prefix';

   str_SG_ShowAPM                := 'Show APM';
   str_SG_ColoredShadow          := 'Colored shadows';
   str_SG_ScrollSpeed            := 'Scroll speed';
   str_SG_MouseScroll            := 'Screen edge scrolling';
   str_SG_PlayerName             := 'Player name';
   str_SG_Language               := 'UI language';
   str_SG_LanguageL[true ]       := 'RUS';
   str_SG_LanguageL[false]       := 'ENG';
   str_SG_RightClickAct          := 'Right-click action';
   str_SG_RightClickActL[true ]  := tc_lime  +'move'  +tc_default;
   str_SG_RightClickActL[false]  := tc_lime  +'move'  +tc_default+'+'+tc_red+'attack'+tc_default;
   str_SG_ControlPanelPos        := 'Control panel position';
   str_SG_ControlPanelPosL[cpp_left  ]:= tc_lime  +'left'  +tc_default;
   str_SG_ControlPanelPosL[cpp_right ]:= tc_orange+'right' +tc_default;
   str_SG_ControlPanelPosL[cpp_top   ]:= tc_yellow+'top'   +tc_default;
   str_SG_ControlPanelPosL[cpp_bottom]:= tc_aqua  +'bottom'+tc_default;
   str_SG_ControlPanelAuto       := 'Control panel auto-switching';
   str_SG_ShowPlayerScrns        := 'Other player screens on the minimap';
   str_SG_HealthBars             := 'Health bars';
   str_SG_HealthBarsL[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_SG_HealthBarsL[1]         := tc_aqua  +'always'  +tc_default;
   str_SG_HealthBarsL[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;
   str_SG_PlayersColor           := 'Override player colors';
   str_SG_PlayersColorL[0]       := str_YesNoG[false];
   str_SG_PlayersColorL[1]       := tc_lime  +'own ' +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[2]       := tc_white +'own ' +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[3]       := tc_white +'own ' +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[4]       := tc_purple+'teams'+tc_default;
   str_SG_PlayersColorL[5]       := tc_white +'own ' +tc_purple+'teams'+tc_default;

   str_SV_ResolutionW            := 'Resolution (width)';
   str_SV_ResolutionH            := 'Resolution (height)';
   str_SV_ResolutionApply        := 'Apply resolution';
   str_SV_Windowed               := 'Windowed';
   str_SV_MenuScale              := 'Menu scaling';
   str_SV_ShowFPS                := 'Show FPS';

   str_SS_MusicVolume            := 'Music volume';
   str_SS_SoundVolume            := 'Sound volume';
   str_SS_NextTrack              := 'Play next track';
   str_SS_ReloadMusic            := 'Load new playlist';
   str_SS_RenewMusicList         := 'Renew playlist on start';
   str_SS_MusicListSize          := 'Music playlist size';
   str_SS_Playlist               := 'Current game playlist';

   str_GO_AISlots                := 'Fill empty slots';
   str_GO_FixedStarts            := 'Fixed player starts';
   str_GO_NewObservers           := 'New observers after game start';
   str_GO_Random                 := 'Random skirmish';

   str_map                       := 'Map';
   str_map_Seed                  := 'Seed';
   str_map_Size                  := 'Size';
   str_map_Random                := 'Random map';
   str_map_Scenario              := 'Scenario';
   str_map_ScenarioL[mc_ffa3     ]:= tc_lime  +'FFA(3)'      +tc_default;
   str_map_ScenarioL[mc_ffa4     ]:= tc_lime  +'FFA(4)'      +tc_default;
   str_map_ScenarioL[mc_ffa5     ]:= tc_lime  +'FFA(5)'      +tc_default;
   str_map_ScenarioL[mc_ffa6     ]:= tc_lime  +'FFA(6)'      +tc_default;
   str_map_ScenarioL[mc_ffa7     ]:= tc_lime  +'FFA(7)'      +tc_default;
   str_map_ScenarioL[mc_ffa8     ]:= tc_lime  +'FFA(8)'      +tc_default;
   str_map_ScenarioL[mc_1x1      ]:= tc_yellow+'1x1'         +tc_default;
   str_map_ScenarioL[mc_2x2      ]:= tc_yellow+'2x2'         +tc_default;
   str_map_ScenarioL[mc_3x3      ]:= tc_yellow+'3x3'         +tc_default;
   str_map_ScenarioL[mc_4x4      ]:= tc_yellow+'4x4'         +tc_default;
   str_map_ScenarioL[mc_2x2x2    ]:= tc_orange+'2x2x2'       +tc_default;
   str_map_ScenarioL[mc_2x2x2x2  ]:= tc_orange+'2x2x2x2'     +tc_default;
   str_map_ScenarioL[mc_KeyPoints]:= tc_aqua  +'Key points'  +tc_default;
   str_map_ScenarioL[mc_KotH     ]:= tc_aqua  +'KotH'        +tc_default;
   str_map_ScenarioL[mc_royale   ]:= tc_red   +'Royal Battle'+tc_default;

   str_map_Generators            := 'Gener. time';
   str_map_GeneratorsL[mapg_5  ] := '5 min';
   str_map_GeneratorsL[mapg_10 ] := '10 min';
   str_map_GeneratorsL[mapg_15 ] := '15 min';
   str_map_GeneratorsL[mapg_20 ] := '20 min';
   str_map_GeneratorsL[mapg_inf] := 'infinity';

   str_map_Symmetry              := 'Symmetry';
   str_map_SymmertyL[maps_none ] := 'no';
   str_map_SymmertyL[maps_point] := 'point';
   str_map_SymmertyL[maps_lineV] := 'line |';
   str_map_SymmertyL[maps_lineh] := 'line -';
   str_map_SymmertyL[maps_lineL] := 'line \';
   str_map_SymmertyL[maps_lineR] := 'line /';

   str_map_Template               := 'Template';
   str_map_TemplateL[mapt_lake   ]:= tc_red   +'lake';
   str_map_TemplateL[mapt_island ]:= tc_orange+'island';
   str_map_TemplateL[mapt_temple ]:= tc_yellow+'temple';
   str_map_TemplateL[mapt_cave   ]:= tc_blue  +'cave';
   str_map_TemplateL[mapt_steppe ]:= tc_gray  +'steppe';
   str_map_TemplateL[mapt_canyon ]:= tc_lime  +'canyon';

   str_objective_Scirmish        := '-Destroy all enemy players';
   str_objective_RoyalBattle     := '-Stay alive';
   str_objective_KotH            := '-Keep central area';
   str_objective_KeyPoints       := '-Capture all key points';

   str_FileError_NExists         := 'File not exists!';
   str_FileError_Open            := 'Can`t open file!';
   str_FileError_WData           := 'Wrong file data!';
   str_FileError_WVer            := 'Wrong version!';
   for i:=0 to mc_Last do
   str_fileinfo_ScenarioL[i]:=str_RemoveSpecChars(str_map_ScenarioL[i]);

   str_ReplayQualityL[0]         := tc_aqua  +'x1 '+tc_default+'/'+tc_red   +' x1';
   str_ReplayQualityL[1]         := tc_aqua  +'x2 '+tc_default+'/'+tc_red   +' x2';
   str_ReplayQualityL[2]         := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_ReplayQualityL[3]         := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_ReplayQualityL[4]         := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_ReplayQualityL[5]         := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_ReplayQualityL[6]         := tc_orange+'x7 '+tc_default+'/'+tc_lime  +' x7';
   str_ReplayQualityL[7]         := tc_orange+'x8 '+tc_default+'/'+tc_lime  +' x8';
   str_ReplayQualityL[8]         := tc_red   +'x9 '+tc_default+'/'+tc_aqua  +' x9';
   str_ReplayQualityL[9]         := tc_red   +'x10'+tc_default+'/'+tc_aqua  +' x10';

   str_NetQualityL[0]            := tc_red   +'x1';
   str_NetQualityL[1]            := tc_red   +'x2';
   str_NetQualityL[2]            := tc_orange+'x3';
   str_NetQualityL[3]            := tc_orange+'x4';
   str_NetQualityL[4]            := tc_yellow+'x5';
   str_NetQualityL[5]            := tc_yellow+'x6';
   str_NetQualityL[6]            := tc_lime  +'x7';
   str_NetQualityL[7]            := tc_lime  +'x8';
   str_NetQualityL[8]            := tc_aqua  +'x9 ';
   str_NetQualityL[9]            := tc_aqua  +'x10';

   str_PT_Player                 := 'PLAYER';
   str_PT_State                  := 'STATUS';
   str_PT_Race                   := 'RACE';
   str_PT_Team                   := 'TEAM';
   str_PT_Color                  := 'COLOR';
   str_PT_Ping                   := 'PING';
   str_PT_Obs                    := 'OBS.';

   str_race[r_random]            := tc_default+'RANDOM'+tc_default;
   str_race[r_hell  ]            := tc_orange +'HELL'  +tc_default;
   str_race[r_uac   ]            := tc_lime   +'UAC'   +tc_default;
   str_observer                  := 'OBSERVER';

   str_Players                   := 'Players';
   str_all                       := 'All';

   str_themes[0]                 :=tc_lime  +'UAC BASE';
   str_themes[1]                 :=tc_aqua  +'ICE CAVE';
   str_themes[2]                 :=tc_yellow+'HELL CAVES';
   str_themes[3]                 :=tc_red   +'HELL CITY';
   str_themes[4]                 :=tc_blue  +'EARTH CITY';
   str_themes[5]                 :=tc_white +'EARTH MOON';
   str_themes[6]                 :=tc_orange+'PHOBOS';
   str_themes[7]                 :=tc_gray  +'DEIMOS';

   str_FileInfo                  := 'FILE INFO';
   str_FileSave                  := 'Save';
   str_FileLoad                  := 'Load';
   str_FilePlay                  := 'Play';
   str_FileDelete                := 'Delete';
   str_FileReWrite               := 'Rewrite';

   str_gstat_Lobby               := 'LOBBY';
   str_gstat_WonByTeam           := 'Won by a team #';
   str_gstat_Started             := 'Started';
   str_gstat_Win                 := 'VICTORY!';
   str_gstat_Lose                := 'DEFEAT!';
   str_gstat_GamePaused          := 'Paused by ';
   str_gstat_ReplayEnd           := 'Replay ended!';
   str_gstat_ReplayError         := 'Read file error!';
   str_gstat_ReplayPaused        := 'Playback paused';
   str_gstat_WaitForServer       := 'Awaiting server...';
   str_gstat_WaitForPlayers      := 'Awaiting players...';
   str_gstat_Unknown             := 'Unknown status!';

   str_gmsg_GameSaved            := 'Game saved';
   str_gmsg_GameLoaded           := 'Game loaded';
   str_gmsg_NoNewObservers       := 'New observers after game start is not allowed';
   str_gmsg_PlayerConnected      := ' has connected';
   str_gmsg_PlayerLeave          := ' left the game';
   str_gmsg_PlayerTimeOut        := ' was kicked due to a timeout';
   str_gmsg_PlayerDefeat         := ' was terminated';
   str_gmsg_PlayerSurrender      := ' surrenders';
   str_gmsg_PlayerPaused         := ' paused the game';
   str_gmsg_PlayerResumed        := ' resumed the game';
   str_gmsg_PlayerRevealed       := ' is revealed';
   str_gmsg_PlayerNoRevealed     := ' is no longer revealed';
   str_gmsg_PortBlocked          := 'UDP Port is blocked!';
   str_gmsg_WrongVersion         := 'Wrong version!';
   str_gmsg_ServerFull           := 'Server is full!';
   str_gmsg_RecordStart          := 'Start recording: ';
   str_gmsg_RecordError          := 'Recording error: ';
   str_gmsg_RecordStop           := 'Stop recording: ';

   str_warn_AbilityBadPlace      := 'Invalid landing/teleporting location';
   str_warn_prod_BadPlace        := 'Invalid building location';
   str_warn_prod_CD              := 'The construction system is rebooting';
   str_warn_prod_BadOrder        := 'Invalid production order';
   str_warn_prod_AllBusy         := 'All production is busy';
   str_warn_prod_Unavailable     := 'Unavailable for production';
   str_warn_Req_Energy           := 'Need more free energy';
   str_warn_Req_HellPower        := 'Need more "Hell Power"';
   str_warn_Req_UACLoot          := 'Need more "UAC Loot"';
   str_warn_Req_Common           := 'Check requirements';
   str_warn_unit_MaxLevel        := 'Maximum level reached';
   str_warn_unit_Levelup         := 'Unit promoted';
   str_warn_unit_complete        := 'Unit ready';
   str_warn_unit_attacked        := 'Unit is under attack';
   str_warn_unit_resurrected     := 'Unit was resurrected';
   str_warn_unit_captured        := 'Unit captured';
   str_warn_unit_lost            := 'Unit lost';
   str_warn_upgrade_InProgress   := 'Already in progress';
   str_warn_upgrade_complete     := 'Upgrade complete';
   str_warn_building_complete    := 'Construction complete';
   str_warn_base_attacked        := 'Base is under attack';
   str_warn_allies_attacked      := 'Our allies is under attack';
   str_warn_MaxLimitReached      := 'Maximum army limit reached';
   str_warn_NeedBuilder          := 'Need builder';
   str_warn_NeedProdUnit         := 'Need production unit';
   str_warn_MaxCountReached      := 'Maximum reached';
   str_warn_MaxBuildersReached   := 'Maximum number of builders has been reached';
   str_warn_MarkLook             := ': look here!';
   str_warn_MarkAttack           := ': attack here!';
   str_warn_kpoint_Captured      := ' was captured Key Point #';
   str_warn_kpoint_CaptureStart  := ' captures Key Point #';
   str_warn_koth_CaptureStart    := ' starts controlling the center';
   str_warn_koth_Alarm           := 'the center timer alarm: ';
   str_warn_ngen_captured        := 'Generator was captured';
   str_warn_ngen_alarm           := 'Generator alarm!';
   str_warn_ngen_lost            := 'Generator was lost';
   str_warn_ngen_exh             := 'Generator was exhausted';
   str_warn_Invalid_Target       := 'Invalid target';
   str_warn_Invalid_Order        := 'Invalid order';
   str_warn_AbilityReload        := 'Ability is on cooldown';
   str_warn_AbilityCasting       := 'Unit is in ability-casting state';
   str_warn_AbilityReqUACNear    := 'Need an allied unit of UAC nearby';
   str_warn_AbilityReqHelNear    := 'Need an allied unit of Hell nearby';
   str_warn_AbilityTar2Close     := 'Target is too close';
   str_warn_UACStrike            := ' launched a tactical missile';
   str_warn_UACScan              := 'Our units have been scanned by ';

   str_ui_time                   := 'Time: ';
   str_ui_menu                   := 'Menu';
   str_ui_UnitGroups             := 'Unit groups:';
   str_ui_KothTime               := 'Center capture time left: ';
   str_ui_KotHTime_act           := 'Time left until center area is active: ';
   str_ui_KotHWinner             := ' - King of the Hill!';
   str_ui_ChatAll                := 'ALL';
   str_ui_ChatAllies             := 'ALLIES';
   str_ui_Tab[tab_Buildings]     := 'Buildings';
   str_ui_Tab[tab_Units    ]     := 'Units';
   str_ui_Tab[tab_Upgrades ]     := 'Upgrades';
   str_ui_Tab[tab_Controls ]     := 'Controls';
   str_ui_LimitArmy              := tc_orange+'Army limit'  +tc_white;
   str_ui_LimitBuildings         := tc_red   +'Units'       +tc_white;
   str_ui_LimitUnits             := tc_gray  +'Buildings'   +tc_white;
   str_ui_EnergyLevel            := tc_aqua  +'Energy level'+tc_white;
   str_ui_HellPower              := tc_yellow+'Hell power'  +tc_white;
   str_ui_UACLoot                := tc_lime  +'UAC Loot'    +tc_white;
   str_ui_objectives             := 'Objectives';
   str_ui_SelectTarget           := 'Select target for ';
   str_ui_SelectBPlace           := 'Choose a location to build ';
   str_ui_BuildHint              := 'Hold "'+input_actions[iAct_Control].ik_str_HK+'" to disable position pushing from obstacles.';
   str_ui_BuildTip               := 'TIP: build buildings close to each other - units will not get stuck between them.';
   str_ui_RightClickCancel       := 'Press "'+input_actions[iAct_mrb].ik_str_HK+'" to cancel.';

   str_hint_upgrade              := 'upgrade';
   str_hint_sec                  := 'sec.';
   str_hint_requirements         := 'Requirements: ';
   str_hint_req                  := 'Req.: ';
   str_hint_uprod                := tc_lime+'Produced by: '   +tc_default;
   str_hint_bprod                := tc_lime+'Constructed by: '+tc_default;
   str_hint_UpgradesLvl          := 'Upgrades: ';
   str_hint_Demons               := 'demons&zombies';
   str_hint_Zombies              := 'zombies';
   str_hint_Except               := 'except';
   str_hint_SplashResist         := 'Immune to splash damage';
   str_hint_TargetLimit          := 'target limit';
   str_hint_builder              := 'Builder';
   str_hint_barrack              := 'Unit production';
   str_hint_forge                := 'Upgrades facility';
   str_hint_IncEnergyLevel       := 'Increase energy level: ';
   str_hint_UnitArming           := 'Arming: ';
   str_hint_Abilities            := 'Abilities: ';
   str_hint_SightR               := 'sight range';
   str_hint_MaxQuantity          := 'Maximum quantity: ';

   str_attr_alive                := tc_lime  +'ALIVE'+tc_default;
   str_attr_dead                 := tc_dgray +'DEAD'+tc_default;
   str_attr_unit                 := tc_gray  +'UNIT'+tc_default;
   str_attr_building             := tc_red   +'BUILDING'+tc_default;
   str_attr_mech                 := tc_blue  +'MECHANICAL'+tc_default;
   str_attr_bio                  := tc_orange+'BIOLOGICAL'+tc_default;
   str_attr_light                := tc_yellow+'LIGHT'+tc_default;
   str_attr_heavy                := tc_green +'HEAVY'+tc_default;
   str_attr_fly                  := tc_aqua  +'FLYING'+tc_default;
   str_attr_ground               := tc_lime  +'GROUND'+tc_default;
   str_attr_level                := tc_white +'LEVEL'+tc_default;
   str_attr_SSoul                := tc_blue  +'SOUL SPHERE'+tc_default;
   str_attr_SInvuln              := tc_white +'INVULNERABILITY SPHERE'+tc_default;
   str_attr_SInvis               := tc_purple+'INVISIBILITY SPHERE'+tc_default;
   str_attr_SRDamage             := tc_gray  +'DAMAGE RESISTANCE SPHERE'+tc_default;
   str_attr_SDDamage             := tc_red   +'DOUBLE DAMAGE SPHERE'+tc_default;
   str_attr_STurbo               := tc_orange+'TURBO SPHERE'+tc_default;
   str_attr_HVision              := tc_green +'HELL VISION'+tc_default;
   str_attr_Scaned               := tc_lime  +'SCANED'+tc_default;
   str_attr_Decay                := tc_red   +'DECAY AURA'+tc_default;
   str_attr_stuned               := tc_yellow+'STUNED'+tc_default;
   str_attr_detector             := tc_purple+'DETECTOR'+tc_default;
   str_attr_heroic               := tc_red   +'HEROIC'+tc_default;

   str_uarm_melee                := 'melee attack';
   str_uarm_ranged               := 'ranged attack';
   str_uarm_zombie               := '+zombification';
   str_uarm_ressurect            := 'resurrection';
   str_uarm_heal                 := 'heal/repair';
   str_uarm_spawn                := 'spawn';
   str_uarm_targets              := 'targets: ';
   str_uarm_BaseImpact           := 'base impact';
   str_uarm_MinRange             := 'min. range: ';
   str_uarm_MaxRange             := 'max. range: ';
   str_uarm_BonusAFlyR           := 'bonus anti-fly range: ';
   str_uarm_BonusAGroundR        := 'bonus anti-ground range: ';
   str_uarm_BonusAUnitR          := 'bonus anti-unit range: ';
   str_uarm_BonusABuildingR      := 'bonus anti-building range: ';
   str_uarm_SplashDamageR        := 'splash damage radius: ';
   str_uarm_Upgrade              := 'upgrade: ';
   str_uarm_Factor               := ', factor: ';
   str_uarm_ShotsPerSec          := ' hits per sec.';

   str_ability_passive           := 'Passive ability';
   str_ability_active            := 'Active ability';
   str_ability_notarget          := 'Self-targeted';
   str_ability_point             := 'Ground-targeted';
   str_ability_UnitAny           := 'Any-unit-targeted';
   str_ability_UnitOwn           := 'Own-unit-targeted';
   str_ability_UnitAlly          := 'Own&ally-unit-targeted';
   str_ability_UnitEnemy         := 'Enemy-unit-targeted';
   str_ability_reload            := 'Base reloading time: ';
   str_ability_ReloadFactors     := 'Reload time reduction factors: ';
   str_ability_rldDecByLevel     := 'unit level';

   str_net_Ready                 := 'READY';
   str_net_Disconnect            := 'DISCONNECT';
   str_net_UDPPort               := 'UDP port';
   str_net_ServerStart           := 'Start server';
   str_net_ServerStop            := 'Stop server';
   str_net_Connect               := 'Connect';
   str_net_Quality               := 'Units update rate';
   str_net_Address               := 'Address';
   str_net_ServerList            := 'Server list';
   str_net_ServerListAdd         := 'Add';
   str_net_ServerLANAdv          := 'LAN Advertise';
   str_net_ConnectedToDed        := '- connected to dedicated server -';

   str_help_Credits              := 'Credits';
   str_help_GameControls         := 'Game Controls';
   str_help_GameHotKeys          := 'Game Hotkeys';
   str_help_GameUI               := 'Game UI';
   str_help_GameMechanics        := 'Game Mechanics';
   str_help_UnitsInfo            := 'Units Info';
   str_help_BalanceTable         := 'Units Balance';
   str_help_UpgradesInfo         := 'Upgrades Info';
   str_help_Other                := 'Other';

   str_help_ImgUI                := 'im. #1 UI';
   str_help_ImgUUpgrade          := 'im. #2 Unit upgrades';
   str_help_ImgGenerators        := 'im. #3 Generators';
   str_help_ImgKeyPoints         := 'im. #4 Key Points';
   str_help_ImgKotH              := 'im. #5 KotH area';

   str_doc_HotKey                := 'Hot key: ';
   str_doc_Attributes            := 'Attributes: ';
   str_doc_ReqEnergy             := 'Energy required: ';
   str_doc_ReqHellPower          := 'Hell Power required: ';
   str_doc_ReqUACLoot            := 'UAC Loot required: ';
   str_doc_ProdTime              := 'Build time: ';
   str_doc_Limit                 := 'Limit used: ';
   str_doc_MaxHits               := 'Max hits: ';
   str_doc_FastDeath             := 'Always fast death: ';
   str_doc_Hits                  := 'Hits: ';
   str_doc_LifeTime              := 'Lifetime: ';
   str_doc_BaseRegen             := 'Base regeneration: ';
   str_doc_BaseSightR            := 'Base '+str_hint_SightR+': ';
   str_doc_Size                  := 'Size: ';
   str_doc_BaseMSpeed            := 'Base speed: ';
   str_doc_Role                  := 'Unit function: ';
   str_doc_Description           := 'Description: ';
   str_doc_PainC                 := 'PainState base threshold: ';
   str_doc_TransportSize         := 'Places in transport: ';
   str_doc_TransportCpst         := 'Base transport capacity: ';
   str_doc_UpgrLevels            := 'Max level: ';
   str_doc_UpgrAffectedUIDs      := 'Affected units: ';
   str_doc_LevelUpTime           := 'Time in combat to level up: ';
   str_doc_LevelArmorBonus       := 'Bonus to armor per level: ';
   str_doc_LevelDamageBonus      := 'Bonus to impact per level: ';
   str_doc_LevelPainSBonus       := 'Bonus to PainState threshold per level: ';
   str_doc_LevelRegenBonus       := 'Bonus to regeneration per level: ';
   str_doc_BountyHellPower       := 'Hell Power bounty: ';
   str_doc_BountyUACLoot         := 'UAC Loot bounty: ';
   str_doc_ZombieUID             := 'Zombie: ';
   str_doc_ZombieHits            := 'Zombie hits threshold: ';
   str_doc_DeathUnit             := 'Spawn unit at death: ';
   str_doc_UpgrArmor             := 'Armor: ';
   str_doc_UpgrRegen             := 'Regeneration: ';
   str_doc_UpgrSpeed             := 'Move speed: ';
   str_doc_UpgrPainS             := 'Painstate threshold: ';
   str_doc_UpgrSightR            := 'Sight range: ';
   str_doc_UpgrTransport         := 'Transport capacity: ';
   str_doc_BalanceGood           := tc_lime+'Good against'   +tc_default+':';
   str_doc_BalanceBad            := tc_red +'Bad against'    +tc_default+':';
   str_doc_BalanceUseless        := tc_gray+'Useless against'+tc_default+':';
   str_doc_LMB                   := tc_lime+'LMB'+tc_white;
   str_doc_RMB                   := tc_red +'RMB'+tc_white;
   str_doc_MWH                   := tc_yellow+'MWheel'+tc_white;
   str_doc_NoteUnitBalance       := 'Note: this data is calculated for "ideal" conditions with fully upgraded units without any buff or debuff effects and no micro-control.';
   str_doc_NoteMaxBuilders       := 'Note: each player cannot have more than '+i2s(PlayerMaxBuilders)+' builders';

   /////////////////////////////////////////////////////////////////////////////
   //  ABILITIES

   t1:='The ability`s cooldown is multiplied by the target`s limit.';
   str_SetAbilityBaseHint(uab_Teleport           ,'Teleportation'            ,'Transfers units directed at it to the specified allied unit-beacon. '+t1);
   str_SetAbilityBaseHint(uab_Recall             ,'Recall'                   ,'Transfers target unit to the Teleport. '+t1);
   str_SetAbilityBaseHint(uab_UACScan            ,'Scan'                     ,'Reveals units (including invisible ones) in the target area for '+i2s(detection_time_sec)+' seconds');
   with g_mids[MID_Blizzard] do
   str_SetAbilityBaseHint(uab_UACStrike          ,'Missile strike'           ,'Strikes a taktical rocket missile that deal '+tc_red+i2s(mid_base_damage)+tc_default+' damage(explode size: '+i2s(mid_size)+','+str_uarm_SplashDamageR+i2s(mid_base_SplashR)+')'+str_uarm_Factor+str_DamageMod(dm_RSMShot)+'. Note: launching a missile reveals the building to all players for '+i2s(UACStrike_Revealing_sec)+' seconds');
   str_SetAbilityBaseHint(uab_HEyeSpawn          ,'Spawn '                   ,'Spawns the Evil Eye at target point. There must be at least one Hell unit allied with you around the point target');
   str_SetAbilityBaseHint(uab_HEyeVision         ,'Hell Vision'              ,'Gives allied target ability to detect invisible units for '+i2s(detection_time_sec)+' seconds');
   str_SetAbilityBaseHint(uab_HTowerBlink        ,'Planar Jump'              ,'Short-range teleportation');
   str_SetAbilityBaseHint(uab_HKeepShift         ,'Dimension Shift'          ,'The building teleport itself to target location. Required upgrade canceled after teleportation');
   str_SetAbilityBaseHint(uab_HKeepAura          ,'Decay Aura'               ,'Deals damage('+tc_red+i2s(DecayAuraDamage)+tc_default+' hits 2 times per sec.) to all non-building enemy units around. Damage ignores units armor.');
   str_SetAbilityBaseHint(uab_SpawnLost          ,'Spawn Lost Soul'          ,'');
   str_SetAbilityBaseHint(uab_SpawnLostTo        ,'Spawn Lost Soul to point' ,'');
   str_SetAbilityBaseHint(uab_SphereSoul         ,'Soul Sphere'              ,'Restores '+i2s(soul_maxHeal)+' health to the target over '+i2s(soul_time_sec)+' seconds');
   str_SetAbilityBaseHint(uab_SphereInvis        ,'Invisibility Sphere'      ,'Makes target invisible for '+i2s(invis_time_sec)+' seconds');
   str_SetAbilityBaseHint(uab_SphereInvuln       ,'Invulnerability Sphere'   ,'Makes target invulnerable for '+i2s(invuln_time_sec)+' seconds');
   str_SetAbilityBaseHint(uab_SphereRDamage      ,'Damage Resistance Sphere' ,'Halves damage to the target for '+i2s(rdamage_time_sec)+' seconds.');
   str_SetAbilityBaseHint(uab_SphereDDamage      ,'Double Damage Sphere'     ,'Doubles the target`s damage for '+i2s(ddamage_time_sec)+' seconds.');
   str_SetAbilityBaseHint(uab_SphereTurbo        ,'Turbo Sphere'             ,'Speeds up all target parameters by 2 times for '+i2s(dturbo_time_sec)+' seconds.');
   str_SetAbilityBaseHint(uab_UACGeneral         ,'UAC General Rank'         ,'Valid targets: non-heroic allied UAC units. Makes the target a "heroic", which increases the damage it deal by 1.5 times and reduces the damage it take by a third. There can be a maximum of '+b2s(UACGeneralsMax)+' "heroic" units in your army.');
   str_SetAbilityBaseHint(uab_Bribe              ,'Bribe'                    ,'Valid targets: non-heroic enemy UAC units. Turns the target to your side. There must be at least one UAC unit allied with you around the target');
   str_SetAbilityBaseHint(uab_Hack               ,'System Hack'              ,'Valid targets: completed enemy UAC buildings. Turns the target to your side. There must be at least one UAC unit allied with you around the target');
   str_SetAbilityBaseHint(uab_UACCCLand          ,'Land/Take-off'            ,'');
   str_SetAbilityBaseHint(uab_UACCCLandTo        ,'Land/Take-off to point'   ,'');
   str_SetAbilityBaseHint(uab_HellCCLand         ,'Land/Take-off'            ,'');
   str_SetAbilityBaseHint(uab_HellCCLandTo       ,'Land/Take-off to point'   ,'');
   str_SetAbilityBaseHint(uab_Unload             ,'Unload'                   ,'');
   str_SetAbilityBaseHint(uab_UnloadTo           ,'Unload to point'          ,'');
   str_SetAbilityBaseHint(uab_HSpecter           ,'Specter'                  ,'Permanent invisibility');
   str_SetAbilityBaseHint(uab_HStealth           ,'Stealth Technology'       ,'Permanent invisibility');
   str_SetAbilityBaseHint(uab_HHTShroud          ,'Shroud of Horror'         ,'Permanent invisibility');
   str_SetAbilityBaseHint(uab_HT2TNoCD           ,'Portal link'              ,'If the destination is another Teleport, the teleportation occurs without cooldown');
   str_SetAbilityBaseHint(uab_UAASplash          ,'Ainti-air Fragmentation Missiles',
                                                                              'Anti-air missiles do extra damage around the target');

   t1:='Transform to ';
   str_SetAbilityBaseHint(uab_ToHAKeep           ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHACommandCenter  ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUACommandCenter  ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUAGTurret        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUAATurret        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUGTurretTo       ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUATurretTo       ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUACDron          ,t1                         ,'');

   t1:='Advanced ';
   str_SetAbilityBaseHint(uab_ToHGate            ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHPools           ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHBarracks        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUBarracks        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUFactory         ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUWeaponFactory   ,t1                         ,'');
   str_SetAbilityBaseHint(uab_LvlUpURadar        ,t1+'"Radar"'               ,'Upgrades the Radar to lower its ability reload time');
   str_SetAbilityBaseHint(uab_LvlUpURMStation    ,t1+'"Rocket Launcher Station"','Upgrades the Rocket Launcher Station to lower its ability reload time');


   /////////////////////////////////////////////////////////////////////////////
   //  UNITS

   str_SetUnitBaseHint(UID_HKeep             ,'Hell Keep'                        ,'');
   str_SetUnitBaseHint(UID_HAKeep            ,'Great Hell Keep'                  ,'');
   str_SetUnitBaseHint(UID_HGate             ,'Demon`s Gate'                     ,'');
   str_SetUnitBaseHint(UID_HPools            ,'Infernal Pools'                   ,'');
   str_SetUnitBaseHint(UID_HPentagram        ,'Pentagram of Death'               ,'');
   str_SetUnitBaseHint(UID_HMonastery        ,'Monastery of Despair'             ,'');
   str_SetUnitBaseHint(UID_HFortress         ,'Castle of Damned'                 ,'');
   str_SetUnitBaseHint(UID_HFTower           ,'Fire Tower'                       ,'Basic defensive structure'        );
   str_SetUnitBaseHint(UID_HTotem            ,'Totem of Horror'                  ,'Advanced defensive structure'     );
   str_SetUnitBaseHint(UID_HEyeNest          ,'Evil Eye Nest'                    ,'Detection and scouting structure.');
   str_SetUnitBaseHint(UID_HEye              ,'Evil Eye'                         ,'Detection and scouting structure.');
   str_SetUnitBaseHint(UID_HTeleport         ,'Teleport'                         ,'');
   str_SetUnitBaseHint(UID_HAltar            ,'Altar of Pain'                    ,'Uses "'+str_ui_HellPower+'" to perform special abilities. Generates "'+str_ui_HellPower+'". '+str_hint_MaxQuantity+i2s(scirmish_MaxHAltar));
   str_SetUnitBaseHint(UID_HCommandCenter    ,'Hell Command Center'              ,'Corrupted Command Center'         );
   str_SetUnitBaseHint(UID_HACommandCenter   ,'Advanced Hell Command Center'     ,'Corrupted Advanced Command Center');
   str_SetUnitBaseHint(UID_HBarracks         ,'Zombie Barracks'                  ,'Corrupted Barracks'               );
   str_SetUnitBaseHint(UID_HMarker           ,'Hell Beacon'                      ,''               );

   str_SetUnitBaseHint(UID_LostSoul          ,'Lost Soul'                        ,str_hint_MaxQuantity+i2s(scirmish_MaxLost));
   str_SetUnitBaseHint(UID_Phantom           ,'Phantom'                          ,str_hint_MaxQuantity+i2s(scirmish_MaxLost));
   str_SetUnitBaseHint(UID_Imp               ,'Imp'                              ,'');
   str_SetUnitBaseHint(UID_Demon             ,'Pinky Demon'                      ,'');
   str_SetUnitBaseHint(UID_Cacodemon         ,'Cacodemon'                        ,'');
   str_SetUnitBaseHint(UID_Knight            ,'Hell Knight'                      ,'');
   str_SetUnitBaseHint(UID_Baron             ,'Baron of Hell'                    ,'');
   str_SetUnitBaseHint(UID_Cyberdemon        ,'Cyberdemon'                       ,'');
   str_SetUnitBaseHint(UID_Mastermind        ,'Spider Mastermind'                ,'');
   str_SetUnitBaseHint(UID_Pain              ,'Pain Elemental'                   ,'');
   str_SetUnitBaseHint(UID_Revenant          ,'Revenant'                         ,'');
   str_SetUnitBaseHint(UID_Mancubus          ,'Mancubus'                         ,'');
   str_SetUnitBaseHint(UID_Arachnotron       ,'Arachnotron'                      ,'');
   str_SetUnitBaseHint(UID_Archvile          ,'Arch-Vile'                        ,'');
   str_SetUnitBaseHint(UID_ZMedic            ,'Zombie Medic'                     ,'');
   str_SetUnitBaseHint(UID_ZEngineer         ,'Zombie Engineer'                  ,'');
   str_SetUnitBaseHint(UID_ZSergant          ,'Zombie Shotguner'                 ,'');
   str_SetUnitBaseHint(UID_ZSSergant         ,'Zombie SuperShotguner'            ,'');
   str_SetUnitBaseHint(UID_ZCommando         ,'Zombie Commando'                  ,'');
   str_SetUnitBaseHint(UID_ZAntiaircrafter   ,'Zombie Antiaircrafter'            ,'');
   str_SetUnitBaseHint(UID_ZSiegeMarine      ,'Zombie Siege Marine'              ,'');
   str_SetUnitBaseHint(UID_ZFPlasmagunner    ,'Zombie Plasmaguner'               ,'');
   str_SetUnitBaseHint(UID_ZBFGMarine        ,'Zombie BFG Marine'                ,'');

   str_SetUnitBaseHint(UID_UCommandCenter    ,'Command Center'                   ,''      );
   str_SetUnitBaseHint(UID_UACommandCenter   ,'Advanced Command Center'          ,''      );
   str_SetUnitBaseHint(UID_UBarracks         ,'Barracks'                         ,''      );
   str_SetUnitBaseHint(UID_UFactory          ,'Vehicle Factory'                  ,''      );
   str_SetUnitBaseHint(UID_UWeaponFactory    ,'Weapon Factory'                   ,''      );
   str_SetUnitBaseHint(UID_UGTurret          ,'Anti-ground Turret'               ,'Anti-ground defensive structure');
   str_SetUnitBaseHint(UID_UATurret          ,'Anti-air Turret'                  ,'Anti-air defensive structure'   );
   str_SetUnitBaseHint(UID_UScienceCenter    ,'Science Facility'                 ,'');
   str_SetUnitBaseHint(UID_UComputerStation  ,'Computer Station'                 ,'');
   str_SetUnitBaseHint(UID_URadar            ,'Radar'                            ,'Reveals the map and detects invisible enemy units');
   str_SetUnitBaseHint(UID_UAcademy          ,'UAC Academy'                      ,'Uses "'+str_ui_UACLoot+'" to perform special abilities');
   str_SetUnitBaseHint(UID_UHPowerConductor  ,'Hell Power Conductor'             ,'Uses "'+str_ui_HellPower+'" to perform special abilities');
   str_SetUnitBaseHint(UID_URMStation        ,'Rocket Launcher Station'          ,'Delivers a powerful missile strike');

   str_SetUnitBaseHint(UID_Sergant           ,'Shotguner'                        ,'');
   str_SetUnitBaseHint(UID_SSergant          ,'SuperShotguner'                   ,'');
   str_SetUnitBaseHint(UID_Commando          ,'Commando'                         ,'');
   str_SetUnitBaseHint(UID_Antiaircrafter    ,'Antiaircrafter'                   ,'');
   str_SetUnitBaseHint(UID_SiegeMarine       ,'Siege Marine'                     ,'');
   str_SetUnitBaseHint(UID_FPlasmagunner     ,'Plasmaguner'                      ,'');
   str_SetUnitBaseHint(UID_BFGMarine         ,'BFG Marine'                       ,'');
   str_SetUnitBaseHint(UID_Engineer          ,'Engineer'                         ,'');
   str_SetUnitBaseHint(UID_Medic             ,'Medic'                            ,'');
   str_SetUnitBaseHint(UID_UTransport        ,'Dropship'                         ,'');
   str_SetUnitBaseHint(UID_UACDron           ,'Drone'                            ,'');
   str_SetUnitBaseHint(UID_Terminator        ,'Terminator'                       ,'');
   str_SetUnitBaseHint(UID_Tank              ,'Tank'                             ,'');
   str_SetUnitBaseHint(UID_Flyer             ,'Fighter'                          ,'');

   str_SetUnitBalanceHint([0..255],'','','',true);
   str_SetUnitBalanceHint([UID_BFGMarine,UID_ZBFGMarine],'due to big splash damage - good against big groups of ['+str_attr_bio+'] units','','',false);
   for i:=1 to 255 do
     with g_uids[i] do
       if(uid_r>0)and(uid_PainState_Base>0)then
         str_SetUnitBalanceHint([i],'','due to "pain state" effect, this unit can be bad againt frequent attacks','',false);

   /////////////////////////////////////////////////////////////////////////////
   //  UPGRADES


   str_SetUpgrBaseHint(upgr_hell_DistDamage1 ,'Hell Firepower'                   ,'Increases the damage of ranged attacks for '+str_UnitsNamesList(UIDsArmsImpactUpgr(upgr_hell_DistDamage1)));
   str_SetUpgrBaseHint(upgr_hell_UnitArmor   ,'Combat Flesh'                     ,'Increases the armor of all Hell units'                                   );
   str_SetUpgrBaseHint(upgr_hell_BuildArmor  ,'Stone Walls'                      ,'Increases the armor of all Hell buildings'                               );
   str_SetUpgrBaseHint(upgr_hell_MeleeDamage ,'Claws and Teeth'                  ,'Increases the damage of melee attacks'                                   );
   str_SetUpgrBaseHint(upgr_hell_Regeneration,'Flesh Regeneration'               ,'Health regeneration for all Hell units'                                  );
   str_SetUpgrBaseHint(upgr_hell_PainFactor  ,'Pain Threshold'                   ,'Hell units can take more hits before being stunned by pain'              );
   str_SetUpgrBaseHint(upgr_hell_ADetection  ,'Evil Eye Magic'                   ,'Unlocks "'+g_aids[uab_HEyeSpawn].ua_str_name+'" and "'+g_aids[uab_HEyeVision].ua_str_name+'" abilities for '+g_uids[UID_HEyeNest].uid_str_name);
   t1:=str_UnitsNamesList([UID_HKeep,UID_HAKeep]);
   str_SetUpgrBaseHint(upgr_hell_HKeepShift  ,g_aids[uab_HKeepShift].ua_str_name ,'Charge of "'+g_aids[uab_HKeepShift].ua_str_name+'" ability for '+t1     );
   str_SetUpgrBaseHint(upgr_hell_DecayAura   ,g_aids[uab_HKeepAura ].ua_str_name ,'Unlocks "'+g_aids[uab_HKeepAura].ua_str_name+'" ability for '+t1);
   str_SetUpgrBaseHint(upgr_hell_BuilderR    ,'Builder Range Upgrade'            ,'Increases range of sight for '+t1                                );
   str_SetUpgrBaseHint(upgr_hell_Spectre     ,g_aids[uab_HSpecter].ua_str_name   ,'Pinky Demon becomes invisible'                                   );
   str_SetUpgrBaseHint(upgr_hell_UnitSightR  ,'Hell Sight'                       ,'Increases the sight range of all Hell units'                     );
   str_SetUpgrBaseHint(upgr_hell_Phantoms    ,'Phantoms'                         ,'Pain Elemental spawns Phantoms instead of Lost Soul'             );
   str_SetUpgrBaseHint(upgr_hell_DistDamage2 ,'Demon`s Weapons'                  ,'Increases the damage of ranged attacks for '+str_UnitsNamesList(UIDsArmsImpactUpgr(upgr_hell_DistDamage2)));
   str_SetUpgrBaseHint(upgr_hell_TeleportCD  ,'Teleport Upgrade'                 ,'Reduces the cooldown of the Teleport ability'                    );
   str_SetUpgrBaseHint(upgr_hell_T2TNoCD     ,g_aids[uab_HT2TNoCD ].ua_str_name  ,g_aids[uab_HT2TNoCD ].ua_str_Descript                             );
   str_SetUpgrBaseHint(upgr_hell_EvilEyeR    ,'Evil Eye Upgrade'                 ,'Increases the sight range of Evil Eye'                           );
   str_SetUpgrBaseHint(upgr_hell_TotemInvis  ,g_aids[uab_HHTShroud].ua_str_name  ,'Totem of Horror becomes invisible'                               );
   str_SetUpgrBaseHint(upgr_hell_BuildRestore,'Building Restoration'             ,'Health regeneration upgrade for all Hell buildings'              );
   t1:=str_UnitsNamesList([UID_HFTower,UID_HTotem]);
   str_SetUpgrBaseHint(upgr_hell_TowerR      ,'Demonic Spirits'                  ,'Increases the range for '+t1                             );
   str_SetUpgrBaseHint(upgr_hell_TowerBlink  ,g_aids[uab_HTowerBlink].ua_str_name,'Unlocks "'+g_aids[uab_HTowerBlink].ua_str_name+'" ability for '+t1);
   str_SetUpgrBaseHint(upgr_hell_Resurrect   ,'Resurrection'                     ,'Unlocks ArchVile`s resurrection weapon'                    );
   str_SetUpgrBaseHint(upgr_hell_FTowerAMech ,'Cacodemon`s Nest '                ,'Anti-['+str_attr_mech+'] weapon for '+g_uids[UID_HFTower].uid_str_name);


   str_SetUpgrBaseHint(upgr_uac_DistDamage   ,'Weapons Upgrade'                  ,'Increases the damage of ranged attacks for all UAC units and defensive structures');
   str_SetUpgrBaseHint(upgr_uac_BioArmor     ,'Infantry Combat Armor Upgrade'    ,'Increases the armor of all Barrack`s units'                     );
   str_SetUpgrBaseHint(upgr_uac_BuildArmor   ,'Concrete Walls'                   ,'Increases the armor of all UAC buildings'                       );
   str_SetUpgrBaseHint(upgr_uac_RepairTools  ,'Advanced Tools'                   ,'Increases repair/healing efficiency for '+str_UnitsNamesList([UID_Medic,UID_Engineer]) );
   str_SetUpgrBaseHint(upgr_uac_BioSpeed     ,'Lightweight Armor'                ,'Increases the movement speed of all Barrack`s units'            );
   str_SetUpgrBaseHint(upgr_uac_SSMWeapon    ,'Surface to Surface Missiles'      ,'Anti-ground weapon for '+g_uids[UID_Antiaircrafter].uid_str_name);
   str_SetUpgrBaseHint(upgr_uac_ADetection   ,g_aids[uab_UACScan].ua_str_name    ,'Unlocks "'+g_aids[uab_UACScan].ua_str_name+'" ability for '+g_uids[UID_URadar].uid_str_name);
   t1:=str_UnitsNamesList([UID_UCommandCenter,UID_UACommandCenter]);
   str_SetUpgrBaseHint(upgr_uac_CCFly        ,'Flight Engines'                   ,t1+' gains ability to fly'                           );
   str_SetUpgrBaseHint(upgr_uac_CCAttack     ,'Built-in Plasma Turret'           ,'Plasma turret for '+t1                              );
   str_SetUpgrBaseHint(upgr_uac_BuilderR     ,'Builder Range Upgrade'            ,'Increases range of sight for '+t1                    );
   str_SetUpgrBaseHint(upgr_uac_DronTurret   ,'Drone Transformation Protocol'    ,'Drone can rebuild to '+str_UnitsNamesList([UID_UATurret,UID_UGTurret])+'; turrets can transform to Drone'    );
   str_SetUpgrBaseHint(upgr_uac_UnitSightR   ,'Light Amplification Visors'       ,'Increases the sight range of all UAC units'  );
   str_SetUpgrBaseHint(upgr_uac_CommandoInvis,g_aids[uab_HStealth ].ua_str_name  ,'Commando becomes invisible'                  );
   str_SetUpgrBaseHint(upgr_uac_AASplash     ,g_aids[uab_UAASplash].ua_str_name  ,g_aids[uab_UAASplash].ua_str_Descript         );
   str_SetUpgrBaseHint(upgr_uac_MechSpeed    ,'Advanced Fuel'                    ,'Increases the movement speed of all Factory`s units'      );
   str_SetUpgrBaseHint(upgr_uac_MechArmor    ,'Mech Combat Armor Upgrade'        ,'Increases the armor of all Factory`s units'               );
   str_SetUpgrBaseHint(upgr_uac_TerAAWeapon  ,'Anti-air Weapon'                  ,'Anti-air weapon for Terminator'                          );
   str_SetUpgrBaseHint(upgr_uac_Transport    ,'Dropship Upgrade'                 ,'Increases the capacity of Dropship'                       );
   str_SetUpgrBaseHint(upgr_uac_RadarR       ,'Radar Upgrade'                    ,'Increases radar scanning radius and range of sight'             );
   str_SetUpgrBaseHint(upgr_uac_TurretPlasma ,'Anti-ground Plasmagun'            ,'Anti-['+str_attr_mech+'] weapon for '+g_uids[UID_UGTurret].uid_str_name  );
   t1:=str_UnitsNamesList([UID_UATurret,UID_UGTurret]);
   str_SetUpgrBaseHint(upgr_uac_TowerR       ,'Spotlights'                       ,'Increases the range for '+t1                    );
   str_SetUpgrBaseHint(upgr_uac_TurretArmor  ,'Additional Armoring'              ,'Additional armor for '+t1 );

   /////////////////////////////////////////////////////////////////////////////
   //  GAME ACT HINTS

   t1:='attack enemies';
   str_SetActionBaseHint(iAct_Control_UAMove     ,'Attack/Move, '+t1);
   str_SetActionBaseHint(iAct_Control_UAStop     ,'Stop, '       +t1);
   str_SetActionBaseHint(iAct_Control_UAPatrol   ,'Patrol, '     +t1);
   t1:='ignore enemies';
   str_SetActionBaseHint(iAct_Control_UMove      ,'Move, '       +t1);
   str_SetActionBaseHint(iAct_Control_UStop      ,'Stop, '       +t1);
   str_SetActionBaseHint(iAct_Control_UPatrol    ,'Patrol, '     +t1);

   str_SetActionBaseHint(iAct_Control_UProdCncl  ,'Cancel production');
   str_SetActionBaseHint(iAct_Control_UDestroy   ,'Self-destruction');

   str_SetActionBaseHint(iAct_Control_USelBase   ,'Select all builders');
   str_SetActionBaseHint(iAct_Control_USelArmy   ,'Select all not busy battle units; "not busy battle units" criterias:'+tc_nl1+
                                                  '- alive, completed, can attack, can move, NOT ['+str_attr_building+'];'+tc_nl1+
                                                  '- no "Patrol" or "Stop, '+t1+'" orders;'+tc_nl1+
                                                  '- no order to use an ability;'+tc_nl1+
                                                  '- no order to teleport or transport;'+tc_nl1);

   str_SetActionBaseHint(iAct_Control_MarkLook   ,'Map mark: look here');
   str_SetActionBaseHint(iAct_Control_MarkAttack ,'Map mark: attack here');


   str_SetActionBaseHint(iAct_InGamePause        ,'Pause');
   str_SetActionBaseHint(iAct_InGameMenu         ,'Menu' );

   str_SetActionBaseHint(iAct_Replay_Fast        ,'Faster game speed');
   str_SetActionBaseHint(iAct_Replay_Pause       ,'Pause');
   str_SetActionBaseHint(iAct_Replay_Back2       ,'Rewind 2 seconds');
   str_SetActionBaseHint(iAct_Replay_Back10      ,'Rewind 10 seconds');
   str_SetActionBaseHint(iAct_Replay_Back60      ,'Rewind 60 seconds');
   str_SetActionBaseHint(iAct_Replay_Forward2    ,'Fast forward 2 seconds');
   str_SetActionBaseHint(iAct_Replay_Forward10   ,'Fast forward 10 seconds');
   str_SetActionBaseHint(iAct_Replay_Forward60   ,'Fast forward 60 seconds');
   str_SetActionBaseHint(iAct_Replay_POV         ,'Player-recorder POV');
   str_SetActionBaseHint(iAct_Replay_Log         ,'List of game messages');
   str_SetActionBaseHint(iAct_Replay_Fog         ,'Fog of war' );
   str_SetActionBaseHint(iAct_Replay_PlayerAll   ,'All players');
   str_SetActionBaseHint(iAct_Replay_Player0     ,'Player #1');
   str_SetActionBaseHint(iAct_Replay_Player1     ,'Player #2');
   str_SetActionBaseHint(iAct_Replay_Player2     ,'Player #3');
   str_SetActionBaseHint(iAct_Replay_Player3     ,'Player #4');
   str_SetActionBaseHint(iAct_Replay_Player4     ,'Player #5');
   str_SetActionBaseHint(iAct_Replay_Player5     ,'Player #6');
   str_SetActionBaseHint(iAct_Replay_Player6     ,'Player #7');
   str_SetActionBaseHint(iAct_Replay_Player7     ,'Player #8');

   str_SetActionBaseHint(iAct_Observer_Fog       ,'Fog of war' );
   str_SetActionBaseHint(iAct_Observer_POV       ,'Player POV' );
   str_SetActionBaseHint(iAct_Observer_PlayerAll ,'All players');
   str_SetActionBaseHint(iAct_Observer_Player0   ,'Player #1');
   str_SetActionBaseHint(iAct_Observer_Player1   ,'Player #2');
   str_SetActionBaseHint(iAct_Observer_Player2   ,'Player #3');
   str_SetActionBaseHint(iAct_Observer_Player3   ,'Player #4');
   str_SetActionBaseHint(iAct_Observer_Player4   ,'Player #5');
   str_SetActionBaseHint(iAct_Observer_Player5   ,'Player #6');
   str_SetActionBaseHint(iAct_Observer_Player6   ,'Player #7');
   str_SetActionBaseHint(iAct_Observer_Player7   ,'Player #8');


   /////////////////////////////////////////////////////////////////////////////
   //  MENU HINTS

   FillChar(str_menu_hint,sizeOf(str_menu_hint),0);
   FillChar(menu_hint_pos,sizeOf(menu_hint_pos),0);

   for i in [1..255] do menu_set_hint(i,i,'');

   menu_set_hint(mi_SaveLoad_fname,mi_SaveLoad_list,'');

   for i in [mi_Players_Panel  ..mi_Players_Obs7       ]-
            [mi_Players_Ready]                           do menu_set_hint(i,mi_Players_Panel ,'');
   for i in [mi_Map_Panel      ..mi_Map_Random         ] do menu_set_hint(i,mi_Map_Panel     ,'');
   for i in [mi_Game_Panel     ..mi_Game_Random        ] do menu_set_hint(i,mi_Game_Panel    ,'');
   for i in [mi_MP_Panel       ..mi_MP_ChatLine        ]-
            [mi_MP_Disconnect]                           do menu_set_hint(i,mi_MP_Panel      ,'');

   for i in [mi_SG_PlayerName  ..mi_SG_ShowPlayerScrns ] do menu_set_hint(i,mi_SG_PlayerName ,'');
   for i in [mi_SR_RecordGames ..mi_SR_RecordQuality   ] do menu_set_hint(i,mi_SR_RecordGames,'');
   for i in [mi_SV_ResolutionW ..mi_SV_MenuScaling     ] do menu_set_hint(i,mi_SV_ResolutionW,'');
   for i in [mi_SS_SoundVolume ..mi_SS_RenewPlaylist   ] do menu_set_hint(i,mi_SS_SoundVolume,'');
   for i in [mi_help_Credits   ..mi_help_Other         ] do menu_set_hint(i,mi_help_Credits  ,'');

   // PLAYERS
   for i in [mi_Players_AIskil0..mi_Players_AIskil7    ] do menu_set_hint(i,mi_Players_Panel,': change AI skill'     );
   for i in [mi_Players_Slot0  ..mi_Players_Slot7      ] do menu_set_hint(i,mi_Players_Panel,': jump to this slot'   );
   for i in [mi_Players_State0 ..mi_Players_State7     ] do menu_set_hint(i,mi_Players_Panel,': add/remove AI Player');

   // MAP
   menu_set_hint(mi_Map_Generators,mi_Map_Panel,': generators life time');
   menu_set_hint(mi_Map_Seed      ,mi_Map_Panel,': select for edition/make random value');

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs  CREDITS
   str_StringListClear(@str_doc_Credits);
   DocHelp_AddCredits(tc_orange+str_gcaption+tc_default+' - is a real-time strategy game based on Doom 2 universe. Current version is '+str_version+'.');
   DocHelp_AddCredits(tc_docbr);
   DocHelp_AddCredits('Project leader and developer: '+tc_red+'Andrey TGA Goryainov'+tc_default+'.');
   DocHelp_AddCredits(tc_docbr);
   DocHelp_AddCredits('Sources: www.github.com/T3DStudio/MarsWars');
   DocHelp_AddCredits('Web site: www.t3dstudio.ru');
   DocHelp_AddCredits(tc_docbr);
   DocHelp_AddCredits('Software used:'+tc_default+tc_doccpt);
   DocHelp_AddCredits('- Free Pascal 3.2.2 (www.freepascal.org);');
   DocHelp_AddCredits('- Lazarus IDE 4.2 (www.lazarus-ide.org);');
   DocHelp_AddCredits('- Simple DirectMedia Layer (SDL) Version 1.2 (www.libsdl.org);');
   DocHelp_AddCredits('- Ultimate Doom Builder (www.github.com/UltimateDoomBuilder/UltimateDoomBuilder);');
   DocHelp_AddCredits('- NASTY tool by jmickle66666666 (www.doomworld.com/forum/topic/98689-nasty-nota-sourceport-thank-you-alpha-4);');
   DocHelp_AddCredits('- Game Maker 8.0 by Mark Overmas.');
   DocHelp_AddCredits(tc_docbr);
   DocHelp_AddCredits('Thanks to:'+tc_default+tc_doccpt);
   DocHelp_AddCredits('- ID Software for "DooM" game;');
   DocHelp_AddCredits('- Daniel Tormentor667 Gimmer for Doom 2 repository (www.realm667.com);');
   DocHelp_AddCredits('- 3D Realms for "Duke Nukem 3D" game;');
   DocHelp_AddCredits('- Monolith Productions for "BLOOD" game;');
   DocHelp_AddCredits('- cybermind aka Mistranger for "DoomWars" game;');
   DocHelp_AddCredits('- Doom Hacker for "Doom: The Battle For Mars" game;');
   DocHelp_AddCredits('- Bertie Butts for main menu background image.');
   DocHelp_AddCredits(tc_docbr);
   DocHelp_AddCredits('Unit voices:'+tc_default+tc_doccpt);
   DocHelp_AddCredits('- Jake Crusher - Shotgunner, Super Shotgunner;');
   DocHelp_AddCredits('- cybermind aka Mistranger - Commando;');
   DocHelp_AddCredits('- Swoy45 - Siedge Marine, Transport;');
   DocHelp_AddCredits('- Kyran Jackson - Plasmaguner;');
   DocHelp_AddCredits('- Demonologist - Hell announcer;');
   DocHelp_AddCredits('- b-o - Combat Medic;');
   DocHelp_AddCredits('- Diabol - UAC Fighter;');
   DocHelp_AddCredits('- Mr.Basik - Antiaircrafter;');
   DocHelp_AddCredits('- DinkyDyeAussie - UAC Tank.');
   DocHelp_AddCredits(tc_docbr);
   DocHelp_AddCredits('Used music:'+tc_default+tc_doccpt);
   DocHelp_AddCreditsMusic;
   DocHelp_AddCredits(tc_docbr);

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs  GAME Controls
   str_StringListClear(@str_doc_BaseControls);

   DocHelp_AddBaseControls(tc_orange+'BASIC GAME CONTROLS'+tc_default+tc_doccpt);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls('The majority of your control during the game is through using your mouse. The mouse performs the following actions:');
   DocHelp_AddBaseControls(tc_docbr+'- SELECTION: the "'+input_actions[iAct_mlb].ik_str_HK+'" is used to select units, buildings, command buttons and points of action (locations where orders are carried out).');
   DocHelp_AddBaseControls(tc_docbr+'- AUTO COMMANDS: when you have a unit or group selected, the "'+input_actions[iAct_mrb].ik_str_HK+'" can be used to issue intelligent commands that will automatically be carried out.');
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_orange+'CAMERA MOVEMENT'+tc_default+tc_doccpt);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls('Possible ways to move the game camera include:');
   DocHelp_AddBaseControls(tc_docbr+'- using keyboard arrow keys;');
   DocHelp_AddBaseControls(tc_docbr+'- clicking and holding the "'+input_actions[iAct_mmb].ik_str_HK+'";');
   DocHelp_AddBaseControls(tc_docbr+'- moving the cursor to the edges of the screen (this option can be enabled or disabled in the game settings).');
   DocHelp_AddBaseControls(tc_docbr+'The speed of camera movement can be adjusted in the game settings.');
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_orange+'BASE CONSTRUCTION'+tc_default+tc_doccpt);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls('You must have at least one builder to build a base. Switch the control panel to "'+str_ui_Tab[tab_Buildings]+'" tab and click on the building icon to select the type of building you need(or press the associated hotkey).');
   DocHelp_AddBaseControls('If the requirements for the selected building type are not met, the game will display an error message; otherwise, the game will draw the building`s sprite and a circle around the mouse cursor.');
   DocHelp_AddBaseControls('The radius of the circle is the radius of the building. If the circle is red - the building needs more space, if it is blue - the build place is too far away from the nearest builder, if it is green - the building can be built here.');
   DocHelp_AddBaseControls('To deselect a building type, press "'+input_actions[iAct_mrb].ik_str_HK+'".');
   DocHelp_AddBaseControls(str_ui_BuildHint);
   DocHelp_AddBaseControls('To cancel the construction of a building, select it and issue the "'+str_action_hint[iAct_Control_UProdCncl]+'" or "'+str_action_hint[iAct_Control_UDestroy]+'" order.');
   DocHelp_AddBaseControls(str_doc_NoteMaxBuilders+'.');
   DocHelp_AddBaseControls(tc_docbr+'NOTE: losing your buildings affect your construction system into short cooldown effect.');
   DocHelp_AddBaseControls(tc_docbr+str_ui_BuildTip);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_orange+'UNIT PRODUCTION'+tc_default+tc_doccpt);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls('Any unit may be built if the player has at least one building capable of producing that type of unit, and the unit`s other requirements are met. Switch the control panel to "'+str_ui_Tab[tab_Units]+'" tab and click on the unit icon(or press the associated hotkey).');
   DocHelp_AddBaseControls('If the requirements for the selected unit type are not met, the game will display an error message.');
   DocHelp_AddBaseControls('If no unit production building is selected - the game sends the production order to nearest unbusy production building, otherwise it sends the order to nearest unbusy selected production buildings.');
   DocHelp_AddBaseControls('It is impossible to create a unit production queue.');
   DocHelp_AddBaseControls('To cancel unit production process, click "'+input_actions[iAct_mrb].ik_str_HK+'" on the unit icon or select production buildings and issue then "'+str_action_hint[iAct_Control_UProdCncl]+'" order.');
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls(tc_orange+'UPGRADES PRODUCTION'+tc_default+tc_doccpt);
   DocHelp_AddBaseControls(tc_docbr);
   DocHelp_AddBaseControls('Go to the "'+str_ui_Tab[tab_Upgrades]+'" tab in the Control Panel and click the upgrade icon. If the requirements for the selected upgrade type are not met, the game will display an error message.');
   DocHelp_AddBaseControls('If no upgrade production facility is selected - the game sends the production order to any nearest unbusy production facility, otherwise it sends the order to nearest unbusy selected production facilities.');
   DocHelp_AddBaseControls('It is impossible to create an upgrade production queue.');
   DocHelp_AddBaseControls('To cancel upgrade production process, click "'+input_actions[iAct_mrb].ik_str_HK+'" on the upgrade icon or select production buildings and issue then "'+str_action_hint[iAct_Control_UProdCncl]+'" order.');
   DocHelp_AddBaseControls(tc_docbr);

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs  GAME HOTKEYS
   str_StringListClear(@str_doc_HotKeys);

   DocHelp_AddHotKeyAction([],tc_orange+'COMMON HOTKEYS'+tc_default+tc_doccpt);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_InGameChat        ],'in-game chat(common)');
   DocHelp_AddHotKeyAction([iAct_InGameChatAll     ],'in-game chat(to all players)'   );
   DocHelp_AddHotKeyAction([iAct_InGameChatAllies  ],'in-game chat(to allied players)');
   DocHelp_AddHotKeyAction([iAct_InGamePause       ],'toggle pause(multiplayer)');
   DocHelp_AddHotKeyAction([iAct_InGameMenu        ],'toggle menu');
   DocHelp_AddHotKeyAction([iAct_Tab               ],'switch control panel tab' );
   DocHelp_AddHotKeyAction([iAct_ScreenShot        ],'make *'+fileExt_Scrshot+' screenshot');
   DocHelp_AddHotKeyAction([iAct_ToggleWindowed    ],'toggle "'+str_SV_Windowed+'" option' );
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_orange+'GAME HOTKEYS'+tc_default+tc_doccpt);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_LastEvent         ],'move camera to last event location');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_USetGroup1..
                            iAct_USetGroup9]        ,'assign currently selected units to the numbered control group'    );
   DocHelp_AddHotKeyAction([iAct_USetGroup0        ],'unassign currently selected units from any numbered control group');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_UAddGroup1..
                            iAct_UAddGroup9        ],'add currently selected units to the numbered control group');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_USelGroup1..
                            iAct_USelGroup9        ],'select units from the numbered control group; double tap - move camera to nearest unit from the group');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_UASlGroup1..
                            iAct_UASlGroup9        ],'add to selection units from the numbered control group');
   DocHelp_AddHotKeyAction([],tc_docbr);

   DocHelp_AddHotKeyAction([iAct_Control_UAbility1..
                            iAct_Control_UAbility3 ],'abilities of selected units');

   DocHelp_AddHotKeyAction([iAct_Control_UMove ,iAct_Control_UStop ,iAct_Control_UPatrol,
                            iAct_Control_UAMove,iAct_Control_UAStop,iAct_Control_UAPatrol]
                                                    ,'basic orders of selected units');
   DocHelp_AddHotKeyAction([iAct_Control_UProdCncl ],'cancel production in selected buildings');
   DocHelp_AddHotKeyAction([iAct_Control_UDestroy  ],'kill selected units');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_Control_USelBase  ],'select all builders; double tap - move camera to nearest builder');
   DocHelp_AddHotKeyAction([iAct_Control_USelArmy  ],'select all not busy battle units; double tap - move camera to nearest unit');

   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_Control_MarkLook  ],'set map mark(multiplayer): "look here"'  );
   DocHelp_AddHotKeyAction([iAct_Control_MarkAttack],'set map mark(multiplayer): "attack here"');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_Control_ToggleRec ],'toggle "'+str_SR_RecordGames+'" option');
   DocHelp_AddHotKeyAction([iAct_TogglePlayersColor],'toggle "'+str_SG_PlayersColor+'" option');
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_SProd1..
                            iAct_SProd24           ],'production hotkeys');

   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_orange+'REPLAY PLAYBACK HOTKEYS'+tc_default+tc_doccpt);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([iAct_Replay_Fast       ],'toggle uncapped FPS(faster game speed)' );
   DocHelp_AddHotKeyAction([iAct_Replay_Pause      ],'pause playback'    );
   DocHelp_AddHotKeyAction([iAct_Replay_Back60     ],'rewind 60 seconds' );
   DocHelp_AddHotKeyAction([iAct_Replay_Back10     ],'rewind 10 seconds' );
   DocHelp_AddHotKeyAction([iAct_Replay_Back2      ],'rewind 2 seconds'  );
   DocHelp_AddHotKeyAction([iAct_Replay_Forward2   ],'fast forward 2 seconds' );
   DocHelp_AddHotKeyAction([iAct_Replay_Forward10  ],'fast forward 10 seconds');
   DocHelp_AddHotKeyAction([iAct_Replay_Forward60  ],'fast forward 60 seconds');
   DocHelp_AddHotKeyAction([iAct_Replay_POV        ],'toggle player-recorder POV'  );
   DocHelp_AddHotKeyAction([iAct_Replay_Log        ],'toggle list of game messages');
   DocHelp_AddHotKeyAction([iAct_Replay_Fog        ],'toggle fog of war' );
   DocHelp_AddHotKeyAction([iAct_Replay_PlayerAll  ],'set all players vision');
   DocHelp_AddHotKeyAction([iAct_Replay_Player0..
                            iAct_Replay_Player7    ],'set player vision');

   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_orange+'OBSERVER MODE HOTKEYS'+tc_default+tc_doccpt);
   DocHelp_AddHotKeyAction([],tc_docbr);

   DocHelp_AddHotKeyAction([iAct_Observer_Fog      ],'toggle fog of war' );
   DocHelp_AddHotKeyAction([iAct_Observer_POV      ],'toggle player POV' );
   DocHelp_AddHotKeyAction([iAct_Observer_PlayerAll],'set all players vision');
   DocHelp_AddHotKeyAction([iAct_Observer_Player0..
                            iAct_Observer_Player7  ],'set player vision');

   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_docbr);
   DocHelp_AddHotKeyAction([],tc_orange+'TEST MODE HOTKEYS'+tc_default+tc_doccpt);
   DocHelp_AddHotKeyAction([],tc_docbr);

   {$IFDEF TESTMODE}
   DocHelp_AddHotKeyAction([iAct_test_FastTime     ],'toggle uncapped FPS(faster game speed)');
   DocHelp_AddHotKeyAction([iAct_test_InstaProd    ],'toggle instant production');
   DocHelp_AddHotKeyAction([iAct_test_ToggleAI     ],'toggle AI control for current player');
   DocHelp_AddHotKeyAction([iAct_test_iddqd        ],'toggle invulnerability for current player');
   DocHelp_AddHotKeyAction([iAct_test_FogToggle    ],'toggle fog of war'   );
   DocHelp_AddHotKeyAction([iAct_test_DrawToggle   ],'toggle screen redraw');
   DocHelp_AddHotKeyAction([iAct_test_NullUpgrades ],'cancel all upgrades for current player');
   DocHelp_AddHotKeyAction([iAct_test_BePlayer0..
                            iAct_test_BePlayer7    ],'set current player');
   DocHelp_AddHotKeyAction([iAct_test_AddHellPower ],'add '+i2s(testmode_HellPower)+' '+str_ui_HellPower+' to current player');
   DocHelp_AddHotKeyAction([iAct_test_AddUACLoot   ],'add '+i2s(testmode_UACLoot  )+' '+str_ui_UACLoot  +' to current player');
   DocHelp_AddHotKeyAction([],tc_docbr);
   {
   iAct_test_debug0       = 227;
   iAct_test_debug1       = 228;
   }
   {$ENDIF}

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs  GAME UI
   str_StringListClear(@str_doc_GameUI);
   DocHelp_AddGamUI(tc_orange+'COMMON'+tc_default+tc_doccpt);
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI('See "'+str_help_ImgUI+'":');
   DocHelp_AddGamUI(tc_docbr+'1) game timer;');
   DocHelp_AddGamUI(tc_docbr+'2) objectives and information, specific to current scenario;');
   DocHelp_AddGamUI(tc_docbr+'3) player resources;');
   DocHelp_AddGamUI(tc_docbr+'4) army limit;');
   DocHelp_AddGamUI(tc_docbr+'5) FPS&APM counters;');
   DocHelp_AddGamUI(tc_docbr+'6) numbered control groups;');
   DocHelp_AddGamUI(tc_docbr+'7) minimap;');
   DocHelp_AddGamUI(tc_docbr+'8) control panel; the position of the control panel can be changed in the game settings;');
   DocHelp_AddGamUI(tc_docbr+'9) last game messages.');
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI(tc_orange+'UNIT UPGRADE INDICATORS'+tc_default+tc_doccpt);
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI('See "'+str_help_ImgUUpgrade+'":');
   DocHelp_AddGamUI(tc_docbr+'- '+tc_red+'red'+tc_default+' numbers - summ of attack upgrades;');
   DocHelp_AddGamUI(tc_docbr+'- '+tc_lime+'green'+tc_default+' numbers - summ of armor upgrades;');
   DocHelp_AddGamUI(tc_docbr+'- '+tc_yellow+'yellow'+tc_default+' numbers - summ of other upgrades.');
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI(tc_orange+'CONTROL PANEL'+tc_default+tc_doccpt);
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI('Minimap marks:'+tc_doccpt);
   DocHelp_AddGamUI(tc_docbr+'- pulsating red rectangle - base is under attack;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating red circle - unit is under attack;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating lime circle - unit ready;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating lime rectangle - construction complete;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating blue circle - unit promoted;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating yellow rectangle - upgrade complete;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating aqua circle - generator event;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating dark-yellow circle - key point event;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating light-gray circle - "look here" mark;');
   DocHelp_AddGamUI(tc_docbr+'- pulsating light-red circle - "attack here" mark;');
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI(tc_docbr+'Tabs:'+tc_doccpt);
   DocHelp_AddGamUI(tc_docbr+'"'+str_ui_Tab[tab_Buildings]+'" - available buildings;');
   DocHelp_AddGamUI(tc_docbr+'"'+str_ui_Tab[tab_Units    ]+'" - available units;');
   DocHelp_AddGamUI(tc_docbr+'"'+str_ui_Tab[tab_Upgrades ]+'" - available upgrades;');
   DocHelp_AddGamUI(tc_docbr+'"'+str_ui_Tab[tab_Controls ]+'" - abilities and basic orders of selected units; some game controls;');
   DocHelp_AddGamUI(tc_docbr);
   DocHelp_AddGamUI(tc_docbr+'Description of numbers on icons:'+tc_doccpt);
   DocHelp_AddGamUI(tc_docbr+tc_lime  +'green' +tc_default+' - number of selected units of this type;');
   DocHelp_AddGamUI(tc_docbr+tc_yellow+'yellow'+tc_default+' - number of production processes of this type;');
   DocHelp_AddGamUI(tc_docbr+tc_orange+'orange'+tc_default+' or '
                            +tc_gray  +'gray'  +tc_default+' - total number of that type of building/unit or upgrade level;');
   DocHelp_AddGamUI(tc_docbr+tc_purple+'purple'+tc_default+' - number of units of that type in selected transport(s);');
   DocHelp_AddGamUI(tc_docbr+tc_white +'white' +tc_default+' - time remaining until completion of production;');
   DocHelp_AddGamUI(tc_docbr+tc_aqua  +'aqua'  +tc_default+' - remaining time until ability cooldown;');

   // unit upgrades

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs  GAME Mechanics
   str_StringListClear(@str_doc_BaseMechanics);

   DocHelp_AddBaseMchanics(tc_orange+'MAP SCENARIOS'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('* '+str_map_ScenarioL[mc_ffa3   ]+'-'+str_map_ScenarioL[mc_ffa8]+' - several free-for-all scenarios for different numbers of players; players team numbers can be changed.');
   DocHelp_AddBaseMchanics(tc_docbr+'* '+str_map_ScenarioL[mc_1x1    ]+' - a classic 1x1 scenario;');
   DocHelp_AddBaseMchanics(tc_docbr+'* '+str_map_ScenarioL[mc_2x2    ]+','
                                        +str_map_ScenarioL[mc_3x3    ]+','
                                        +str_map_ScenarioL[mc_4x4    ]+','
                                        +str_map_ScenarioL[mc_2x2x2  ]+','
                                        +str_map_ScenarioL[mc_2x2x2x2]+' - various team skirmish; players team numbers cannot be changed;');
   DocHelp_AddBaseMchanics(tc_docbr+str_ui_objectives+':');
   DocHelp_AddBaseMchanics(tc_docbr+str_objective_Scirmish);
   DocHelp_AddBaseMchanics(tc_docbr+'* '+str_map_ScenarioL[mc_KeyPoints]+' - a tactical scenario in which players must capture '+i2s(keyPoint_mcN)+' moving key points(see "'+str_help_ImgKeyPoints+'"). To capture a point, a player must have at least one unit inside it. Capturing a key point takes '+i2s(keyPoint_CTime_Def_Sec)+' seconds.');
   DocHelp_AddBaseMchanics(tc_docbr+'After capturing it, there is no requirement to keep units inside it.');
   DocHelp_AddBaseMchanics(tc_docbr+str_ui_objectives+':');
   DocHelp_AddBaseMchanics(tc_docbr+str_objective_KeyPoints);
   DocHelp_AddBaseMchanics(tc_docbr+'* '+str_map_ScenarioL[mc_KotH     ]+' (King of the Hill) - a tactical scenario in which players must hold the central area of the map(see "'+str_help_ImgKotH+'") for '+i2s(keyPoint_CTime_KotH_Sec)+' seconds. There is a '+i2s(keyPoint_KotH_pause_sec)+'-seconds cooldown before capturing the central area.');
   DocHelp_AddBaseMchanics(tc_docbr+str_ui_objectives+':');
   DocHelp_AddBaseMchanics(tc_docbr+str_objective_KotH);
   DocHelp_AddBaseMchanics(tc_docbr+'* '+str_map_ScenarioL[mc_royale   ]+' - a variant of free-for-all scenario, where the death circle gradually narrows the available space on the map.');
   DocHelp_AddBaseMchanics(tc_docbr+str_ui_objectives+':');
   DocHelp_AddBaseMchanics(tc_docbr+str_objective_RoyalBattle);
   DocHelp_AddBaseMchanics(tc_docbr+str_or);
   DocHelp_AddBaseMchanics(tc_docbr+str_objective_Scirmish);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'NEUTRAL GENERATORS'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('Neutral generators (see "'+str_help_ImgGenerators+'") - special objects on the game map that, when captured, increase "'+str_ui_EnergyLevel+'". There are 2 types of neutral generators:');
   DocHelp_AddBaseMchanics(tc_docbr+'- "Starter" generator - appears at players base in "Scirmish" game. Required at least '+limit2s(map_generators_LimitS,ul1)+' unit limit to be captured. Increase "'+str_ui_EnergyLevel+'" by '+i2s(map_generators_EnergyS)+'.');
   DocHelp_AddBaseMchanics(tc_docbr+'- "Normal" generator - appears at any map locations. Required at least '+limit2s(map_generators_LimitO,ul1)+' unit limit to be captured. Increase "'+str_ui_EnergyLevel+'" by '+i2s(map_generators_EnergyO)+'.');
   DocHelp_AddBaseMchanics(tc_docbr+'Both types of neutral generators requires holding units inside it, otherwise generator become back to neutral state.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'RESOURCES'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('There are 3 types of resources in the game:');
   DocHelp_AddBaseMchanics(tc_docbr+'- The main resource of the game is the "'+str_ui_EnergyLevel+'". Almost all production (building construction, unit creation, or upgrade research) in the game consumes this resource.');
   DocHelp_AddBaseMchanics('In the user interface, it is displayed as two numbers: the level of free energy and the '+tc_aqua+'maximum energy level'+tc_default+'.');
   DocHelp_AddBaseMchanics('When a player starts any production that requires this resource, the game reduces the free energy level by the production cost and restores this amount after the production is completed.');
   DocHelp_AddBaseMchanics('The energy level can be increased by specific buildings, as well as special objects on the game map that need to be captured and held.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr+'There are also 2 additional types of resources used for special technologies and abilities:');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_ui_HellPower+' - when playing as the Hell faction, this resource is automatically replenished by the "Altar of Pain" building.');
   DocHelp_AddBaseMchanics('The replenishment rate increases with each additional "Altar of Pain", but constructing more than '+i2s(scirmish_MaxHAltar)+' "Altars of Pain" does not provide any further benefit. When playing as UAC, the resource is generated from destroyed enemy units and Hell structures.');
   DocHelp_AddBaseMchanics(str_hint_MaxQuantity+i2s(HellPower_Max)+'. ');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_ui_UACLoot+' - this resource is acquired by both factions through the destruction of enemy UAC units and buildings. '+str_hint_MaxQuantity+i2s(UACLoot_Max)+'.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'ARMY LIMIT'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('Each units and buildings in the game takes at least 1 limit point. Maximum limit points per each player is '+tc_red+'125'+tc_default+'!');
   DocHelp_AddBaseMchanics('Dead units still exist in the game and takes limit.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'UNIT ATTRIBUTES'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('- '+str_attr_alive   +' or '+str_attr_dead    +';');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_unit    +' or '+str_attr_building+';');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_mech    +' or '+str_attr_bio     +';');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_light   +' or '+str_attr_heavy   +';');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_fly     +' or '+str_attr_ground  +';');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_level   +'2..4 - unit level if it is higher than 1.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'UNIT EFFECTS'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('- '+str_attr_stuned  +' - unit is stuned and can`t attack or move;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_detector+' - unit can see invisible enemy units;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_heroic  +' - unit is a hero; it deals 1.5 times more damage and takes a third less damage;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_Scaned  +' - unit was scanned by UAC Radar;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_Decay   +' - unit is under "Decay Aura" effect; it slowly lose health;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_HVision +' - unit is under "Hell Vision" effect; it can see invisible enemy units;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_SSoul   +' - unit is under "Soul Sphere" effect; it`s regaining it health;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_SInvuln +' - unit is under "Invulnerability Sphere" effect; it is immune to any damage;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_SInvis  +' - unit is under "Invisibility Sphere" effect; it invisibile;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_SRDamage+' - unit is under "Damage Resistance Sphere" effect; it takes half damage and resist to "pain state" effect;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_SDDamage+' - unit is under "Double Damage Sphere" effect; it deals double damage;');
   DocHelp_AddBaseMchanics(tc_docbr+'- '+str_attr_STurbo  +' - unit is under "Turbo Sphere" effect; its movement, attack, regeneration, production, construction and reloading speeds are doubled.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'PAIN STATE'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('Some units have "Pain State" - it is a 1-second stun state after a certain number of damage hits. During the "Pain State" unit can`t attack or move. "Pain State" is accompanied by a special sound and unit animation.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'VETERAN SYSTEM'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('All combat units gain combat experience and increase their level. All units spawn at level 1 and can be upgraded to level 4. With each new level, the unit increases its damage, armor, and pain threshold.');
   DocHelp_AddBaseMchanics('The time in combat required to reach the next level varies for each type of unit(see "'+str_help_UnitsInfo+'" section).');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'DAMAGE CALCULATION SEQUENCE'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('1) The game takes the attacking unit`s base damage and adds bonuses from upgrades and veteran level;');
   DocHelp_AddBaseMchanics(tc_docbr+'2) Special effects of the attacking unit that affect its damage amount are applied ("'+str_attr_Heroic+'" attribute and "'+str_attr_SDDamage+'" effect);');
   DocHelp_AddBaseMchanics(tc_docbr+'3) A damage modifier for the attacking unit is applied to the resulting value;');
   DocHelp_AddBaseMchanics(tc_docbr+'4) Special effects reducing the received damage by the target unit are applied ("'+str_attr_Heroic+'" attribute and "'+str_attr_SRDamage+'" effect);');
   DocHelp_AddBaseMchanics(tc_docbr+'5) The armor of the target unit is calculated (bonuses from upgrades and its veteran level are summed up) and subtracted from the inflicted damage; if the damage drops below 1, it is raised to 1;');
   DocHelp_AddBaseMchanics(tc_docbr+'6) The target unit receives the final calculated damage.');
   DocHelp_AddBaseMchanics(tc_docbr+'Special cases:');
   DocHelp_AddBaseMchanics(tc_docbr+'- If the unit is a building under construction, steps 4 and 5 are skipped;');
   DocHelp_AddBaseMchanics(tc_docbr+'- Damage dealt by the "Decay Aura" effect also ignores points 4 and 5;');
   DocHelp_AddBaseMchanics(tc_docbr+'- Units with '+str_attr_building+' or '+str_attr_mech+' attribute are immune to splash damage.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_orange+'OTHER'+tc_default+tc_doccpt);
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics('If a player loses all his builders - all his units revealed on the map.');
   DocHelp_AddBaseMchanics(tc_docbr);
   DocHelp_AddBaseMchanics(tc_docbr+'Unit hits regeneration period is 1 second.');

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs  OTHER
   str_StringListClear(@str_doc_Other);

   DocHelp_AddOther(tc_orange+'DEDICATED SERVER'+tc_default+tc_doccpt);
   DocHelp_AddOther(tc_docbr);
   DocHelp_AddOther(tc_docbr+'Dedicated server - a special version of the game that does not load any game resources and immediately starts working as a server. To start a dedicated server, run it with the following parameters:');
   DocHelp_AddOther(tc_docbr);
   DocHelp_AddOther(tc_doccnt+'MarsWars_ded.exe [X] [Y]');
   DocHelp_AddOther(tc_docbr);
   DocHelp_AddOther('where X - UDP port (optional argument, default value - '+w2s(net_DefaultPort)+'); Y - LAN Advertise (optional argument, default value - 1 (true)).');
   DocHelp_AddOther(tc_docbr+'Any connected player can change the game settings in a dedicated server`s lobby.');
   DocHelp_AddOther(tc_docbr+'The game will start automatically as soon as all players mark the "ready" option. The server will return to the lobby one minute after the game ends or immediately after all players leave the server.');
   DocHelp_AddOther(tc_docbr);
   DocHelp_AddOther(tc_docbr);
   DocHelp_AddOther(tc_orange+'AI BOT SKILL LEVELS'+tc_default+tc_doccpt);
   DocHelp_AddOther(tc_docbr);
   DocHelp_AddOther(tc_docbr+'AI1 - the easiest bot; AI9 - the the hardest.');
   DocHelp_AddOther(tc_docbr+'AI1-5 - bot operates under the same conditions as a player-human; there are no unfair advantages and it does not ignore the fog of war; the difference is various size of army, super weapon or "magic" using, some micro-control abilities and build-order.');
   DocHelp_AddOther(tc_docbr+'AI3+ - there is a chance of an early attack by a small group of units.');
   DocHelp_AddOther(tc_docbr+'AI4+ - there is a chance of an super early attack by a first unit.');
   DocHelp_AddOther(tc_docbr+'AI6 - AI5 + building construction speed is doubled.');
   DocHelp_AddOther(tc_docbr+'AI7 - AI6 + upgrades production speed is doubled.');
   DocHelp_AddOther(tc_docbr+'AI8 - AI7 + unit production speed is doubled.');
   DocHelp_AddOther(tc_docbr+'AI9 - AI8 + bot can see enemy units or buildings, ignoring fog of war.');

   /////////////////////////////////////////////////////////////////////////////
   //  CAMPAING STRINGS

   str_Camp_Difficulty           := 'Difficulty';
   str_Camp_DifficultyL[0]       := tc_aqua  +'I`m too young to die'+tc_default; // This is my first strategy
   str_Camp_DifficultyL[1]       := tc_lime  +'Hey, not too rough'  +tc_default; //
   str_Camp_DifficultyL[2]       := tc_yellow+'Hurt me plenty'      +tc_default;
   str_Camp_DifficultyL[3]       := tc_orange+'Ultra-Violence'      +tc_default;
   str_Camp_DifficultyL[4]       := tc_red   +'Nightmare'           +tc_default;

   str_Camp_Campaign             := 'Campaign';
   str_Camp_Mission              := 'Mission';
   str_Camp_Info                 := 'Information';
   str_Camp_Location             := 'Location';
   str_Camp_NewUnits             := 'New units available: ';

   str_Camp_HE_CoB               := 'Clan of Bites';
   str_Camp_HE_ToE               := 'Tribe of Evil';
   str_Camp_HE_HN                := 'Hell Knights';


   str_camp_clear;

   str_camp_Add('Ascension');
   //str_camp_Add('Hell March');
   //str_camp_Add('Payback time');
   //str_camp_Add('Corporate wars');

   t1:=    'Hell Empire'
   +tc_nl1+'unknown planet'
   +tc_nl1+'unknown location'
   +tc_nl1+'unknown date';

   //////////     HELL VS HELL    1
   //
   str_camp_MisAdd(0,'Mt. Erebus');

   str_camp_MissTextAdd(0,0,'On a distant, unknown planet of the Hell Empire, there exists a long-standing tradition of "ascension":');
   str_camp_MissTextAdd(0,0,'once every few dozen cycles, the leaders of savage demonic tribes, eager to ascend to a higher position in the Empire, gather for a journey to a sacred place - the "Slough of Despair".');
   str_camp_MissTextAdd(0,0,'The journey there is long and arduous - you must overcome canyons, caves, steppes, lakes, and - most importantly - your rivals! Only one will survive, only one will ascend to the rank of "General of Hell"!');
   str_camp_MissTextAdd(0,0,tc_docbr);
   str_camp_MissTextAdd(0,0,'You are one of the ascension candidates. Your journey begins in a cave at the foot of the Mount Erebus. The first obstacle lies ahead - your rival`s outpost! Build a camp, summon your warriors, and crush the enemy!');

   str_camp_MissObjSet (0,0,'- Don`t lose the Hell Keep'
                    +tc_nl1+'- Capture 1 generator'
                    +tc_nl1+'- Build 10 Demon`s Gates'
                    +tc_nl1+'- Summon 30 Imps'
                    +tc_nl1+'- Destroy the '+str_Camp_HE_CoB,
                            t1);

   //////////     HELL VS HELL    2
   //
   str_camp_MisAdd(0,'Valley of Fear');

   str_camp_MissTextAdd(0,1,'It was a glorious victory! You enslave some Pinky Demons to strengthen your army, stole Fire Tower technology to defend your base and capture Hell Pools for upgrades!');
   str_camp_MissTextAdd(0,1,tc_docbr);
   str_camp_MissTextAdd(0,1,'But there is no time to celebrate - an earthquake has occurred, and the ground behind you has begun to fill with lava. Your next challenge is to cross the Valley of Fear faster than the lava flow.');
   str_camp_MissTextAdd(0,1,tc_docbr);
   str_camp_MissTextAdd(0,1,'There are two more opponents in this area - destroy them as well, adding their forces to yours.');
   str_camp_MissTextAdd(0,1,tc_docbr);
   str_camp_MissTextAdd(0,1,tc_docbr);
   str_camp_MissTextAdd(0,1,'MISSION TIPS:');
   str_camp_MissTextAdd(0,1,'* Hell Keep teleportation ability is not available for you yet, so your only option is to build new Hell Keeps toward the bottom-right corner of the map.');
   str_camp_MissTextAdd(0,1,'* Each of your units has "self-destruction" ability - use it to free builder limit;');
   str_camp_MissTextAdd(0,1,'* Your opponents have different army compositions and you should choose your army composition wisely for greater effectiveness. ');

   str_camp_MissObjSet (0,1,'- At least 1 Hell Keep must survive'
                    +tc_nl1+'- Destroy the '+str_Camp_HE_ToE
                    +tc_nl1+'- Destroy the '+str_Camp_HE_HN,
                            t1);

   ////////////////////////////////////////

   str_makeAllHints;
end;


