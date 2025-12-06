
////////////////////////////////////////////////////////////////////////////////
//
//  MAIN
//

procedure lng_eng;
var t:shortstring;
    i:byte;
begin
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
   str_Caption_NetSVSearch       := 'Searching for LAN servers...';

   str_menu_Campaings            := 'TUTORIAL CAMPAIGNS';
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
   str_SG_MouseScroll            := 'Mouse scroll';
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
   str_SG_HealthBars             := 'Health bars';
   str_SG_HealthBarsL[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_SG_HealthBarsL[1]         := tc_aqua  +'always'  +tc_default;
   str_SG_HealthBarsL[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;
   str_SG_PlayersColor           := 'Players color';
   str_SG_PlayersColorL[0]       := tc_white +'default'+tc_default;
   str_SG_PlayersColorL[1]       := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[2]       := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[3]       := tc_white +'own '   +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[4]       := tc_purple+'teams'  +tc_default;
   str_SG_PlayersColorL[5]       := tc_white +'own '   +tc_purple+'teams'+tc_default;

   str_SV_ResolutionW            := 'Resolution (width)';
   str_SV_ResolutionH            := 'Resolution (height)';
   str_SV_ResolutionApply        := 'Apply resolution';
   str_SV_Windowed               := 'Windowed';
   str_SV_MenuScale              := 'Menu scaling';
   str_SV_MenuScaleSmooth        := 'Smooth scaled menu';
   str_SV_ShowFPS                := 'Show FPS';

   str_SS_MusicVolume            := 'Music volume';
   str_SS_SoundVolume            := 'Sound volume';
   str_SS_NextTrack              := 'Play next track';
   str_SS_ReloadMusic            := 'Load new playlist';
   str_SS_MusicListSize          := 'Music playlist size';

   str_GO_AISlots                := 'Fill empty slots';
   str_GO_FixedStarts            := 'Fixed player starts';
   str_GO_DefeatedObs            := 'Observer mode after lose';
   str_GO_Random                 := 'Random skirmish';

   str_map                       := 'Map';
   str_map_Seed                  := 'Seed';
   str_map_Size                  := 'Size';
   str_map_Obstacles             := 'Obstacles';
   str_map_Symmetry              := 'Symmetric';
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
   for i:=0 to mc_Last do
   str_replay_ScenarioL[i]:=RemoveSpecChars(str_map_ScenarioL[i]);
   str_map_Generators            := 'Generators';
   str_map_GeneratorsL[mapg_no ] := 'no';
   str_map_GeneratorsL[mapg_5  ] := '5 min';
   str_map_GeneratorsL[mapg_10 ] := '10 min';
   str_map_GeneratorsL[mapg_15 ] := '15 min';
   str_map_GeneratorsL[mapg_20 ] := '20 min';
   str_map_GeneratorsL[mapg_inf] := 'infinity';

   str_objective_Scirmish        := '-Destroy all enemy players';
   str_objective_RoyalBattle     := '-Stay alive';
   str_objective_KotH            := '-Keep central area';
   str_objective_KeyPoints       := '-Capture all key points';

   str_FileError_NExists         := 'File not exists!';
   str_FileError_Open            := 'Can`t open file!';
   str_FileError_WData           := 'Wrong file data!';
   str_FileError_WVer            := 'Wrong version!';

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
   str_PT_Ping                   := 'PING&';
   str_PT_Obs                    := 'OBS.';

   str_race[r_random]            := tc_default+'RANDOM'+tc_default;
   str_race[r_hell  ]            := tc_orange +'HELL'  +tc_default;
   str_race[r_uac   ]            := tc_lime   +'UAC'   +tc_default;
   str_observer                  := 'OBSERVER';

   str_Players                   := 'Players';
   str_all                       := 'All';

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
   str_gmsg_GameStarted          := 'Game started!';
   str_gmsg_PlayerConnected      := ' has connected';
   str_gmsg_PlayerLeave          := ' left the game';
   str_gmsg_PlayerTimeOut        := ' was kicked due to a timeout';
   str_gmsg_PlayerDefeat         := ' was terminated!';
   str_gmsg_PlayerSurrender      := ' surrenders!';
   str_gmsg_PlayerPaused         := ' paused the game';
   str_gmsg_PlayerResumed        := ' resumed the game';
   str_gmsg_PortBlocked          := 'UDP Port is blocked!';
   str_gmsg_WrongVersion         := 'Wrong version!';
   str_gmsg_ServerFull           := 'Server full!';
   str_gmsg_RecordStart          := 'Start recording: ';
   str_gmsg_RecordError          := 'Recording error: ';
   str_gmsg_RecordStop           := 'Stop recording: ';

   str_warn_AbilityBadPlace      := 'Invalid landing/teleporting location';
   str_warn_prod_BadPlace        := 'Invalid building location';
   str_warn_prod_BadOrder        := 'Invalid production order';
   str_warn_prod_AllBusy         := 'All production is busy';
   str_warn_Req_Energy           := 'Need more energy';
   str_warn_Req_Common           := 'Check requirements';
   str_warn_unit_Levelup         := 'Unit promoted';
   str_warn_unit_complete        := 'Unit ready';
   str_warn_unit_attacked        := 'Unit is under attack';
   str_warn_unit_resurrected     := 'Unit was resurrected';
   str_warn_upgrade_InProgress   := 'Already in progress';
   str_warn_upgrade_complete     := 'Upgrade complete';
   str_warn_building_complete    := 'Construction complete';
   str_warn_base_attacked        := 'Base is under attack';
   str_warn_allies_attacked      := 'Our allies is under attack';
   str_warn_MaxLimitReached      := 'Maximum army limit reached';
   str_warn_NeedBuilder          := 'Need builder';
   str_warn_NeedProdUnit         := 'Need production unit';
   str_warn_MaxCountReached      := 'Maximum reached';
   str_warn_mapMark              := ' set a mark on the map';
   str_warn_kpoint_captured      := 'The Key point was captured';
   str_warn_kpoint_lost          := 'The Key point was lost';
   str_warn_koth_control         := ' team starts controlling the center';
   str_warn_ngen_captured        := 'The Neutral Generator was captured';
   str_warn_ngen_lost            := 'The Neutral Generator was lost';
   str_warn_ngen_exh             := 'The Neutral Generator was exhausted';
   str_warn_Invalid_Target       := 'Invalid target';
   str_warn_Invalid_Order        := 'Invalid order';
   str_warn_AbilityReload        := 'The ability is on cooldown!' ;

   str_ui_time                   := 'Time: ';
   str_ui_menu                   := 'Menu';
   str_ui_UnitGroups             := 'Unit groups: ';
   str_ui_KothTime               := 'Center capture time left: ';
   str_ui_KotHTime_act           := 'Time left until center area is active: ';
   str_ui_KotHWinner             := ' is King of the Hill!';
   str_ui_ChatAll                := 'ALL:';
   str_ui_ChatAllies             := 'ALLIES:';
   str_ui_Tab[tab_Buildings]     := 'Buildings';
   str_ui_Tab[tab_Units    ]     := 'Units';
   str_ui_Tab[tab_Upgrades ]     := 'Researches';
   str_ui_Tab[tab_Controls ]     := 'Controls';
   str_ui_LimitArmy              := tc_orange+'Army limit'  +tc_white+': ';
   str_ui_LimitBuildings         := tc_red   +'Units'       +tc_white+': ';
   str_ui_LimitUnits             := tc_gray  +'Buildings'   +tc_white+': ';
   str_ui_EnergyLevel            := tc_aqua  +'Energy level'+tc_white+': ';
   str_ui_objectives             := 'Objectives:';

   str_hint_requirements         := 'Requirements: ';
   str_hint_req                  := 'Req.: ';
   str_hint_reload               := 'Base reloading time: ';
   str_hint_uprod                := tc_lime+'Produced by: '   +tc_default;
   str_hint_bprod                := tc_lime+'Constructed by: '+tc_default;
   str_hint_Ability              := 'Special ability: ';
   str_hint_TransformTo          := 'transformation to ';
   str_hint_UpgradesLvl          := 'Upgrades: ';
   str_hint_Demons               := 'demons&zombies';
   str_hint_Except               := 'except';
   str_hint_SplashResist         := 'Immune to splash damage';
   str_hint_TargetLimit          := 'target limit';
   str_hint_builder              := 'Builder';
   str_hint_barrack              := 'Unit production';
   str_hint_smith                := 'Researches and upgrades facility';
   str_hint_IncEnergyLevel       := 'Increase energy level';
   str_hint_CanRebuildTo         := 'Can be rebuilt into ';
   str_hint_UnitArming           := 'Arming: ';
   str_hint_Abilities            := 'Abilities: ';
   str_hint_hits                 := 'Hits: ';
   str_hint_SightR               := 'sight range';
   str_hint_BaseSightR           := 'Base '+str_hint_SightR+': ';

   str_attr_alive                := tc_lime  +'alive'       ;
   str_attr_dead                 := tc_dgray +'dead'        ;
   str_attr_unit                 := tc_gray  +'unit'        ;
   str_attr_building             := tc_red   +'building'    ;
   str_attr_mech                 := tc_blue  +'mechanical'  ;
   str_attr_bio                  := tc_orange+'biological'  ;
   str_attr_light                := tc_yellow+'light'       ;
   str_attr_heavy                := tc_green +'heavy'       ;
   str_attr_fly                  := tc_white +'flying'      ;
   str_attr_ground               := tc_lime  +'ground'      ;
   str_attr_floater              := tc_aqua  +'floater'     ;
   str_attr_level                := tc_white +'level'       ;
   str_attr_invuln               := tc_lime  +'invulnerable';
   str_attr_stuned               := tc_yellow+'stuned'      ;
   str_attr_detector             := tc_purple+'detector'    ;
   str_attr_transport            := tc_gray  +'transport'   ;

   str_uarm_melee                := 'melee attack';
   str_uarm_ranged               := 'ranged attack';
   str_uarm_zombie               := '+zombification';
   str_uarm_ressurect            := 'resurrection';
   str_uarm_heal                 := 'heal/repair';
   str_uarm_spawn                := 'spawn';
   str_uarm_suicide              := 'suicide';
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

   str_Camp_Difficulty           := 'Difficulty';
   str_Camp_DifficultyL[0]       := tc_aqua  +'I`m too young to die'+tc_default; // It's my first RTS
   str_Camp_DifficultyL[1]       := tc_lime  +'Hey, not too rough'  +tc_default;
   str_Camp_DifficultyL[2]       := tc_yellow+'Hurt me plenty'      +tc_default;
   str_Camp_DifficultyL[3]       := tc_orange+'Ultra-Violence'      +tc_default;
   str_Camp_DifficultyL[4]       := tc_red   +'Nightmare'           +tc_default;

   str_net_Ready                 := 'READY';
   str_net_Disconnect            := 'DISCONNECT';
   str_net_UDPPort               := 'UDP port';
   str_net_ServerStart           := 'Start server';
   str_net_ServerStop            := 'Stop server';
   str_net_Connect               := 'Connect';
   str_net_Quality               := 'Units update rate';
   str_net_Address               := 'Address';
   str_net_LANSearch             := 'Search for LAN servers';
   str_net_ServerLANVis          := 'LAN Advertise';
   str_net_ConnectedToDed        := '- connected to dedicated server -';

   str_SetAbilityBaseHint(uab_Teleport           ,'Teleportation'           ,'');
   str_SetAbilityBaseHint(uab_Recall             ,'Recall'                  ,'');
   str_SetAbilityBaseHint(uab_UACScan            ,'Scan'                    ,'');
   str_SetAbilityBaseHint(uab_UACStrike          ,'Missile strike'          ,'');
   str_SetAbilityBaseHint(uab_HEyeBlink          ,'Blink of the Eye'        ,'');
   str_SetAbilityBaseHint(uab_HEyeVision         ,'Hell Vision'             ,'');
   str_SetAbilityBaseHint(uab_HTowerBlink        ,'Planar Jump'             ,'');
   str_SetAbilityBaseHint(uab_HKeepShift         ,'Dimension Shift'         ,'');
   str_SetAbilityBaseHint(uab_HKeepAura          ,'Decay Aura'              ,'');
   str_SetAbilityBaseHint(uab_SphereInvuln       ,'Invulnerability Sphere'  ,'');
   str_SetAbilityBaseHint(uab_SpawnLost          ,'Spawn Lost Soul'         ,'');
   str_SetAbilityBaseHint(uab_SpawnLostTo        ,'Spawn Lost Soul to point','');
   str_SetAbilityBaseHint(uab_UACCCLand          ,'Land/Take-off'           ,'');
   str_SetAbilityBaseHint(uab_UACCCLandTo        ,'Land/Take-off to point'  ,'');
   str_SetAbilityBaseHint(uab_Unload             ,'Unload'                  ,'');
   str_SetAbilityBaseHint(uab_UnloadTo           ,'Unload to point'         ,'');
   t:='Transform to ';
   str_SetAbilityBaseHint(uab_ToHAKeep           ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHSymbol2         ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHSymbol3         ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHSymbol4         ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHACommandCenter  ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHTower           ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHTotem           ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUACommandCenter  ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUGenerator2      ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUGenerator3      ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUGenerator4      ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUAGTurret        ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUAATurret        ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUACDron          ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUGTurretTo       ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUATurretTo       ,t                         ,'');
   t:='Advanced ';
   str_SetAbilityBaseHint(uab_ToHGate            ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHPool            ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToHBarracks        ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUBarracks        ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUFactory         ,t                         ,'');
   str_SetAbilityBaseHint(uab_ToUWeaponFactory   ,t                         ,'');


   str_SetUnitBaseHint(UID_HKeep          ,'Hell Keep'                   ,'');
   str_SetUnitBaseHint(UID_HAKeep         ,'Great Hell Keep'             ,'');
   str_SetUnitBaseHint(UID_HGate          ,'Demon`s Gate'                ,'');
   str_SetUnitBaseHint(UID_HSymbol1       ,'Unholy Symbol level 1'       ,'');
   str_SetUnitBaseHint(UID_HSymbol2       ,'Unholy Symbol level 2'       ,'');
   str_SetUnitBaseHint(UID_HSymbol3       ,'Unholy Symbol level 3'       ,'');
   str_SetUnitBaseHint(UID_HSymbol4       ,'Unholy Symbol level 4'       ,'');
   str_SetUnitBaseHint(UID_HPools         ,'Infernal Pools'              ,'');
   str_SetUnitBaseHint(UID_HTeleport      ,'Teleport'                    ,'');
   str_SetUnitBaseHint(UID_HPentagram     ,'Pentagram of Death'          ,'');
   str_SetUnitBaseHint(UID_HMonastery     ,'Monastery of Despair'        ,'');
   str_SetUnitBaseHint(UID_HFortress      ,'Castle of Damned'            ,'');
   str_SetUnitBaseHint(UID_HTower         ,'Guard Tower'                 ,'Basic defensive structure'        );
   str_SetUnitBaseHint(UID_HTotem         ,'Totem of Horror'             ,'Advanced defensive structure'     );
   str_SetUnitBaseHint(UID_HAltar         ,'Altar of Pain'               ,'');
   str_SetUnitBaseHint(UID_HCommandCenter ,'Hell Command Center'         ,'Corrupted Command Center'         );
   str_SetUnitBaseHint(UID_HACommandCenter,'Advanced Hell Command Center','Corrupted Advanced Command Center');
   str_SetUnitBaseHint(UID_HBarracks      ,'Zombie Barracks'             ,'Corrupted Barracks'               );
   str_SetUnitBaseHint(UID_HEye           ,'Evil Eye'                    ,'Detection structure.');

   str_SetUnitBaseHint(UID_LostSoul       ,'Lost Soul'                   ,'');
   str_SetUnitBaseHint(UID_Phantom        ,'Phantom'                     ,'');
   str_SetUnitBaseHint(UID_Imp            ,'Imp'                         ,'');
   str_SetUnitBaseHint(UID_Demon          ,'Pinky Demon'                 ,'');
   str_SetUnitBaseHint(UID_Cacodemon      ,'Cacodemon'                   ,'');
   str_SetUnitBaseHint(UID_Knight         ,'Hell Knight'                 ,'');
   str_SetUnitBaseHint(UID_Baron          ,'Baron of Hell'               ,'');
   str_SetUnitBaseHint(UID_Cyberdemon     ,'Cyberdemon'                  ,'');
   str_SetUnitBaseHint(UID_Mastermind     ,'Spider Mastermind'           ,'');
   str_SetUnitBaseHint(UID_Pain           ,'Pain Elemental'              ,'');
   str_SetUnitBaseHint(UID_Revenant       ,'Revenant'                    ,'');
   str_SetUnitBaseHint(UID_Mancubus       ,'Mancubus'                    ,'');
   str_SetUnitBaseHint(UID_Arachnotron    ,'Arachnotron'                 ,'');
   str_SetUnitBaseHint(UID_Archvile       ,'Arch-Vile'                   ,'');
   str_SetUnitBaseHint(UID_ZMedic         ,'Zombie Medic'                ,'');
   str_SetUnitBaseHint(UID_ZEngineer      ,'Zombie Engineer'             ,'');
   str_SetUnitBaseHint(UID_ZSergant       ,'Zombie Shotguner'            ,'');
   str_SetUnitBaseHint(UID_ZSSergant      ,'Zombie SuperShotguner'       ,'');
   str_SetUnitBaseHint(UID_ZCommando      ,'Zombie Commando'             ,'');
   str_SetUnitBaseHint(UID_ZAntiaircrafter,'Zombie Antiaircrafter'       ,'');
   str_SetUnitBaseHint(UID_ZSiegeMarine   ,'Zombie Siege Marine'         ,'');
   str_SetUnitBaseHint(UID_ZFPlasmagunner ,'Zombie Plasmaguner'          ,'');
   str_SetUnitBaseHint(UID_ZBFGMarine     ,'Zombie BFG Marine'           ,'');


   str_SetUpgrBaseHint(upgr_hell_DistDamage1 ,'Hell Firepower'                ,'Increase the damage of ranged attacks for T1 units and defensive structures');
   str_SetUpgrBaseHint(upgr_hell_UnitArmor   ,'Combat Flesh'                  ,'Increase the armor of all Hell units'                                   );
   str_SetUpgrBaseHint(upgr_hell_BuildArmor  ,'Stone Walls'                   ,'Increase the armor of all Hell buildings'                               );
   str_SetUpgrBaseHint(upgr_hell_MeleeDamage ,'Claws and Teeth'               ,'Increase the damage of melee attacks'                                   );
   str_SetUpgrBaseHint(upgr_hell_Regeneration,'Flesh Regeneration'            ,'Health regeneration for all Hell units'                                 );
   str_SetUpgrBaseHint(upgr_hell_PainFactor  ,'Pain Threshold'                ,'Hell units can take more hits before being stunned by pain'             );
   str_SetUpgrBaseHint(upgr_hell_TowerR      ,'Demonic Spirits'               ,'Increase the range of defensive structures'                             );
   str_SetUpgrBaseHint(upgr_hell_HKeepShift  ,'Hell Keep Blink Charge'        ,'Charge for Hell Keep`s ability'                                         );
   str_SetUpgrBaseHint(upgr_hell_DecayAura   ,'Decay Aura'                    ,'Hell Keep start damage all enemies around. Decay Aura damage ignores unit armor');
   str_SetUpgrBaseHint(upgr_hell_BuilderR    ,'Hell Keep Range Upgrade'       ,'Increase Hell Keep`s range of vision'                                   );
   str_SetUpgrBaseHint(upgr_hell_Spectre     ,'Specters'                      ,'Pinky Demon becomes invisible'                                  );
   str_SetUpgrBaseHint(upgr_hell_UnitSightR  ,'Hell Sight'                    ,'Increase the sight range of all Hell units'                     );
   str_SetUpgrBaseHint(upgr_hell_Phantoms    ,'Phantoms'                      ,'Pain Elemental spawns Phantoms instead of Lost Soul'            );
   str_SetUpgrBaseHint(upgr_hell_DistDamage2 ,'Demon`s Weapons'               ,'Increase the damage of ranged attacks for T2 units and defensive structures'  );
   str_SetUpgrBaseHint(upgr_hell_TeleportCD  ,'Teleport Upgrade'              ,'Reduced cooldown on Teleport ability'                           );
   str_SetUpgrBaseHint(upgr_hell_Recall      ,'Recall'                        ,'The Teleport can recall units'                                  );
   str_SetUpgrBaseHint(upgr_hell_EvilEyeR    ,'Evil Eye Upgrade'              ,'Increase the sight range of Evil Eye'                           );
   str_SetUpgrBaseHint(upgr_hell_TotemInvis  ,'Totem of Horror Invisibility'  ,'Totem of Horror becomes invisible'                              );
   str_SetUpgrBaseHint(upgr_hell_BuildRestore,'Building Restoration'          ,'Health regeneration for all Hell buildings'                     );
   str_SetUpgrBaseHint(upgr_hell_TowerBlink  ,'Tower Teleportation Charge'    ,'Charges for ability of Guard Tower and Totem of Horror');
   str_SetUpgrBaseHint(upgr_hell_Resurrect   ,'Resurrection'                  ,'ArchVile`s ability'                    );


   str_SetUnitBaseHint(UID_UCommandCenter   ,'Command Center'                ,''      );
   str_SetUnitBaseHint(UID_UACommandCenter  ,'Advanced Command Center'       ,''      );
   str_SetUnitBaseHint(UID_UBarracks        ,'Barracks'                      ,''      );
   str_SetUnitBaseHint(UID_UFactory         ,'Vehicle Factory'               ,''      );
   str_SetUnitBaseHint(UID_UGenerator1      ,'Generator level 1'             ,''      );
   str_SetUnitBaseHint(UID_UGenerator2      ,'Generator level 2'             ,''      );
   str_SetUnitBaseHint(UID_UGenerator3      ,'Generator level 3'             ,''      );
   str_SetUnitBaseHint(UID_UGenerator4      ,'Generator level 4'             ,''      );
   str_SetUnitBaseHint(UID_UWeaponFactory   ,'Weapon Factory'                ,''      );
   str_SetUnitBaseHint(UID_UGTurret         ,'Anti-ground Turret'            ,'Anti-ground defensive structure');
   str_SetUnitBaseHint(UID_UATurret         ,'Anti-air Turret'               ,'Anti-air defensive structure'   );
   str_SetUnitBaseHint(UID_UTechCenter      ,'Science Facility'              ,'');
   str_SetUnitBaseHint(UID_UComputerStation ,'Computer Station'              ,'');
   str_SetUnitBaseHint(UID_URadar           ,'Radar'                         ,'Reveals map. Reload time of the ability is '+tc_aqua+i2s(radar_reload_sec)+tc_default+' sec');
   str_SetUnitBaseHint(UID_URMStation       ,'Rocket Launcher Station'       ,'');
   str_SetUnitBaseHint(UID_UMine            ,'Mine'                          ,'');

   str_SetUnitBaseHint(UID_Sergant          ,'Shotguner'                     ,'');
   str_SetUnitBaseHint(UID_SSergant         ,'SuperShotguner'                ,'');
   str_SetUnitBaseHint(UID_Commando         ,'Commando'                      ,'');
   str_SetUnitBaseHint(UID_Antiaircrafter   ,'Antiaircrafter'                ,'');
   str_SetUnitBaseHint(UID_SiegeMarine      ,'Siege Marine'                  ,'');
   str_SetUnitBaseHint(UID_FPlasmagunner    ,'Plasmaguner'                   ,'');
   str_SetUnitBaseHint(UID_BFGMarine        ,'BFG Marine'                    ,'');
   str_SetUnitBaseHint(UID_Engineer         ,'Engineer'                      ,'');
   str_SetUnitBaseHint(UID_Medic            ,'Medic'                         ,'');
   str_SetUnitBaseHint(UID_UTransport       ,'Dropship'                      ,'');
   str_SetUnitBaseHint(UID_UACDron          ,'Drone'                         ,'');
   str_SetUnitBaseHint(UID_Terminator       ,'Terminator'                    ,'');
   str_SetUnitBaseHint(UID_Tank             ,'Tank'                          ,'');
   str_SetUnitBaseHint(UID_Flyer            ,'Fighter'                       ,'');
   str_SetUnitBaseHint(UID_APC              ,'Ground APC'                    ,'');


   str_SetUpgrBaseHint(upgr_uac_DistDamage   ,'Weapons Upgrade'                  ,'Increase the damage of ranged attacks for all UAC units and defensive structures');
   str_SetUpgrBaseHint(upgr_uac_BioArmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barrack`s units'                     );
   str_SetUpgrBaseHint(upgr_uac_BuildArmor   ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings'                       );
   str_SetUpgrBaseHint(upgr_uac_RepairTools  ,'Advanced Tools'                   ,'Increase repair/healing efficiency of Engineers/Medics'        );
   str_SetUpgrBaseHint(upgr_uac_BioSpeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barrack`s units'            );
   str_SetUpgrBaseHint(upgr_uac_ssgup        ,'Expansive bullets'                ,'Attacks of Shotguner, SuperShotguner and Terminator are more likely to cause a pain state' );
   str_SetUpgrBaseHint(upgr_uac_TowerR       ,'Spotlights'                       ,'Increase the range of defensive structures'                    );
   str_SetUpgrBaseHint(upgr_uac_CCFly        ,'Command Center Flight Engines'    ,'Command Center gains ability to fly'                           );
   str_SetUpgrBaseHint(upgr_uac_CCAttack     ,'Command Center Turret'            ,'Plasma turret for Command Center'                              );
   str_SetUpgrBaseHint(upgr_uac_BuilderR     ,'Command Center Range Upgrade'     ,'Increase Command Center`s range of vision'                           );
   str_SetUpgrBaseHint(upgr_uac_DronTurret   ,'Drone Transformation Protocol'    ,'Drone can rebuild to Anti-ground turret'    );
   str_SetUpgrBaseHint(upgr_uac_UnitSightR   ,'Light Amplification Visors'       ,'Increase the sight range of all UAC units'  );
   str_SetUpgrBaseHint(upgr_uac_CommandoInvis,'Stealth Technology'               ,'Commando becomes invisible'                 );
   str_SetUpgrBaseHint(upgr_uac_AASplash     ,'Fragmentation Missiles'           ,'Anti-air missiles do extra damage around the target'     );
   str_SetUpgrBaseHint(upgr_uac_MechSpeed    ,'Advanced Engines'                 ,'Increase the movement speed of all Factory`s units'      );
   str_SetUpgrBaseHint(upgr_uac_MechArmor    ,'Mech Combat Armor Upgrade'        ,'Increase the armor of all Factory`s units'               );
   str_SetUpgrBaseHint(upgr_uac_TerAAWeapon  ,'Anti-air Weapon'                  ,'Anti-air weapon for Terminator'                          );
   str_SetUpgrBaseHint(upgr_uac_Transport    ,'Dropship Upgrade'                 ,'Increase the capacity of Dropship'                       );
   str_SetUpgrBaseHint(upgr_uac_RadarR       ,'Radar Upgrade'                    ,'Increase radar scanning radius'             );
   str_SetUpgrBaseHint(upgr_uac_TurretPlasma ,'Anti-ground Plasmagun'            ,'Anti-['+str_attr_mech+tc_default+'] weapon for Anti-ground turret'  );
   str_SetUpgrBaseHint(upgr_uac_TurretArmor  ,'Additional Armoring'              ,'Additional armor for Turrets'               );


   str_MakeActionHint(iAct_Control_USelBase,'Select all builders');
   str_MakeActionHint(iAct_Control_USelArmy,'Select all battle units');

   t:='attack enemies';
   str_MakeActionHint(iAct_Control_UAMove     ,'Move, '  +t);
   str_MakeActionHint(iAct_Control_UAStop     ,'Stop, '  +t);
   str_MakeActionHint(iAct_Control_UAPatrol   ,'Patrol, '+t);
   t:='ignore enemies';
   str_MakeActionHint(iAct_Control_UMove      ,'Move, '  +t);
   str_MakeActionHint(iAct_Control_UStop      ,'Stop, '  +t);
   str_MakeActionHint(iAct_Control_UPatrol    ,'Patrol, '+t);

   str_MakeActionHint(iAct_Control_UProdCncl  ,'Cancel production');
   str_MakeActionHint(iAct_Control_UDestroy   ,'Destroy');
   str_MakeActionHint(iAct_Control_USelArmy   ,'Select all battle units');

   str_MakeActionHint(iAct_InGamePause        ,'Pause');
   str_MakeActionHint(iAct_InGameMenu         ,'Menu' );

   str_MakeActionHint(iAct_Replay_Fast        ,'Faster game speed');
   str_MakeActionHint(iAct_Replay_Pause       ,'Pause');
   str_MakeActionHint(iAct_Replay_Back2       ,'Rewind 2 seconds');
   str_MakeActionHint(iAct_Replay_Back10      ,'Rewind 10 seconds');
   str_MakeActionHint(iAct_Replay_Back60      ,'Rewind 60 seconds');
   str_MakeActionHint(iAct_Replay_Forward2    ,'Fast forward 2 seconds');
   str_MakeActionHint(iAct_Replay_Forward10   ,'Fast forward 10 seconds');
   str_MakeActionHint(iAct_Replay_Forward60   ,'Fast forward 60 seconds');
   str_MakeActionHint(iAct_Replay_POV         ,'Player-recorder POV');
   str_MakeActionHint(iAct_Replay_Log         ,'List of game messages');
   str_MakeActionHint(iAct_Replay_Fog         ,'Fog of war');
   str_MakeActionHint(iAct_Replay_PlayerAll   ,'All players');
   str_MakeActionHint(iAct_Replay_Player0     ,'Player #1');
   str_MakeActionHint(iAct_Replay_Player1     ,'Player #2');
   str_MakeActionHint(iAct_Replay_Player2     ,'Player #3');
   str_MakeActionHint(iAct_Replay_Player3     ,'Player #4');
   str_MakeActionHint(iAct_Replay_Player4     ,'Player #5');
   str_MakeActionHint(iAct_Replay_Player5     ,'Player #6');
   str_MakeActionHint(iAct_Replay_Player6     ,'Player #7');
   str_MakeActionHint(iAct_Replay_Player7     ,'Player #8');

   str_action_hint[iAct_Observer_Fog      ]:= str_action_hint[iAct_Replay_Fog      ];
   str_action_hint[iAct_Observer_PlayerAll]:= str_action_hint[iAct_Replay_PlayerAll];
   str_action_hint[iAct_Observer_Player0  ]:= str_action_hint[iAct_Replay_Player0  ];
   str_action_hint[iAct_Observer_Player1  ]:= str_action_hint[iAct_Replay_Player1  ];
   str_action_hint[iAct_Observer_Player2  ]:= str_action_hint[iAct_Replay_Player2  ];
   str_action_hint[iAct_Observer_Player3  ]:= str_action_hint[iAct_Replay_Player3  ];
   str_action_hint[iAct_Observer_Player4  ]:= str_action_hint[iAct_Replay_Player4  ];
   str_action_hint[iAct_Observer_Player5  ]:= str_action_hint[iAct_Replay_Player5  ];
   str_action_hint[iAct_Observer_Player6  ]:= str_action_hint[iAct_Replay_Player6  ];
   str_action_hint[iAct_Observer_Player7  ]:= str_action_hint[iAct_Replay_Player7  ];

   //_mkHStrACT(12,'Alarm mark'       );

   FillChar(str_menu_hint,sizeOf(str_menu_hint),0);

   for i in byte do str_menu_hint[i]:=b2s(i);

   {for i in [6,7,106,8,9,10,12,13,18,20,22,23,27,26,29,31,38,39,40,42,44,53,56,62,74,76,79,82,86,89] do
   str_menu_hint[i]:='LMB';

   for i in [14,116,117,16,30,51,52,63,77,78,84,91,193,194,92,97] do
   str_menu_hint[i]:='LMB/RMB';

   for i in [87,90,11,83] do
   str_menu_hint[i]:='LMB: select for edition';

   str_menu_hint[50]:='LMB: select for edition; RMB: set random value';
   str_menu_hint[60]:='LMB: change AI player skill; RMB: jump to position';
   str_menu_hint[61]:='LMB: add/remove AI player';
   str_menu_hint[80]:='LMB: make random scirmish settings, RMB: make&run game'; }

   /////////////////////////////////////////////////////////////////////////////

   str_cmp_unk       := 'UNKNOWN';
   str_cmp_Date      := tc_gray+'Date: '    +tc_default;
   str_cmp_Location  := tc_gray+'Location: '+tc_default;
   str_cmp_Area      := tc_gray+'Area: '    +tc_default;

   str_camp_MissionName[0 ] := 'Hell#1: And Hell Followed (Tutorial)';
   str_camp_MissionName[1 ] := 'Hell#2: Invasion to the Phobos';
   str_camp_MissionName[2 ] := 'Hell#3: The Military Industry';
   str_camp_MissionName[3 ] := 'Hell#4: the Deimos Anomaly';
   str_camp_MissionName[4 ] := 'Hell#5: Nuclear Moon';
   str_camp_MissionName[5 ] := 'Hell#6: Fear';
   str_camp_MissionName[6 ] := 'Hell#7: Ghosts of Mars';
   str_camp_MissionName[7 ] := 'Hell#8: ';
   str_camp_MissionName[8 ] := 'Hell#9: Hell on Mars';
   str_camp_MissionName[9 ] := 'Hell#10: Hell On Earth';
   str_camp_MissionName[10] := 'Hell#11: Industrial Zone';
   str_camp_MissionName[11] := 'Hell#12: Cosmodrome';

   str_camp_MissionName[12] := 'UAC#1: Command Center';
   str_camp_MissionName[13] := 'UAC#2: Super Generators';
   str_camp_MissionName[14] := 'UAC#3: Phobos Anomaly';
   str_camp_MissionName[15] := 'UAC#4: Deimos Anomaly 2';
   str_camp_MissionName[16] := 'UAC#5: Lab';
   str_camp_MissionName[17] := 'UAC#6: Fortress of Mystery';
   str_camp_MissionName[18] := 'UAC#7: City of the Damned';
   str_camp_MissionName[19] := 'UAC#8: Slough of Despair';
   str_camp_MissionName[20] := 'UAC#9: Mt. Erebus';
   str_camp_MissionName[21] := 'UAC#10: Dead Zone';
   str_camp_MissionName[22] := 'UAC#11:    ';
   str_camp_MissionName[23] := 'UAC#12: Battle For Mars';

   str_camp_map [0 ] := str_cmp_map(str_cmp_unk ,'HELL WORLD','Portal valley');
   str_camp_map [1 ] := str_cmp_map('15.11.2145','PHOBOS'    ,'Hall crater'   );
   str_camp_map [2 ] := str_cmp_map('16.11.2145','PHOBOS'    ,'Drunlo crater' );
   str_camp_map [3 ] := str_cmp_map('15.11.2145','DEIMOS'    ,'Anomaly Zone'  );
   str_camp_map [4 ] := str_cmp_map('16.11.2145','DEIMOS'    ,'Swift crater'  );
   str_camp_map [5 ] := str_cmp_map('16.11.2145','DEIMOS'    ,'Voltaire Area' );
   str_camp_map [6 ] := str_cmp_map('16.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [7 ] := str_cmp_map('16.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [8 ] := str_cmp_map('16.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [9 ] := str_cmp_map('25.11.2145','EARTH'     ,'Unknown');
   str_camp_map [10] := str_cmp_map('26.11.2145','EARTH'     ,'Unknown');
   str_camp_map [11] := str_cmp_map('27.11.2145','EARTH'     ,'Unknown');

   str_camp_map [12] := str_cmp_map('16.11.2145','PHOBOS'    ,'Todd crater'  );
   str_camp_map [13] := str_cmp_map('16.11.2145','PHOBOS'    ,'Roche crater' );
   str_camp_map [14] := str_cmp_map('17.11.2145','PHOBOS'    ,'Anomaly Zone' );
   str_camp_map [15] := str_cmp_map('17.11.2145','DEIMOS'    ,'Anomaly Zone' );
   str_camp_map [16] := str_cmp_map('18.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_map [17] := str_cmp_map('18.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_map [18] := str_cmp_map('20.11.2145','HELL'      ,'Portal valley');
   str_camp_map [19] := str_cmp_map('21.11.2145','HELL'      ,'Unknown'      );
   str_camp_map [20] := str_cmp_map('22.11.2145','HELL'      ,'Unknown'      );
   str_camp_map [21] := str_cmp_map('21.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [22] := str_cmp_map('21.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [23] := str_cmp_map('22.11.2145','MARS'      ,'Hellas Area');

   for i:=0 to LastMission do
   begin
      setlength(str_camp_infol[i],0);
      str_camp_infon[i]:=0;
   end;

   ////   HELL #1 / Tutorial

   cmp_AddPlot(0,false,
'This planet looks terrifying: fire everywhere, molten lava, and eerie creatures. It is located far among thousands of other worlds belonging to a powerful galactic Empire. Everything here remained unchanged for many centuries after the conquest...');
   cmp_AddPlot(0,false,
'until suddenly the old teleporter, built by some ancient civilization, was activated. Technologically advanced aliens arrived from the portal, immediately starting to explore the new territory.');

   cmp_AddPlot(0,true ,
'You are one of the higher demons, whose calling is to lead the demonic army into battle. You were recently promoted to your current rank and have not yet had the chance to prove yourself.');
   cmp_AddPlot(0,false,
'Your first task is to study the aliens, infiltrate their world, and subjugate it to the will of the Empire.');

   cmp_AddPlot(0,true,
'The invaders have built a large camp near the Portal, and we don`t even have a small outpost in this region. It is necessary to quickly build a base, summon the army, and crush the violators!');

   cmp_AddPlot(0,true ,'- Reach 2000 energy level');
   cmp_AddPlot(0,false,'- Build 4 Demon`s Gates'  );
   cmp_AddPlot(0,false,'- Summon 30 Hell warriors');
   cmp_AddPlot(0,false,'- Do not lose Hell Keeps' );
   cmp_AddPlot(0,false,'- Destroy all intruder creatures');


  {


   str_camp_obj [2 ] := '- Destroy Military Base';

   str_camp_obj [3 ] := '- Destroy all human bases and armies'+tc_nl3+'-Cyberdemon must survive'+tc_nl3+'-Protect portal';
   str_camp_obj [4 ] := '- Destroy Nuclear Plant'+tc_nl3+'-Cyberdemon must survive';
   str_camp_obj [5 ] := '- Destroy Science Center'+tc_nl3+'-Cyberdemon must survive';

   str_camp_obj [6 ] := '- Destroy all human bases and armies';
   str_camp_obj [7 ] := '???';
   str_camp_obj [8 ] := '- Kill all humans!';
   str_camp_obj [9 ] := '- Protect Hell Fortess'+tc_nl3+'-Destroy all human towns and armies';
   str_camp_obj [10] := '- Destroy all industrial buildings'+tc_nl3+'-Destroy all command centers';
   str_camp_obj [11] := '- Destroy all military bases';

   str_camp_obj [12] := '- Find, protect and reapir'+tc_nl3+'Command Center'+tc_nl3+'-At least one engineer must survive';
   str_camp_obj [13] := '- Find and repair 5 Super Generators';
   str_camp_obj [14] := '- Destroy all bases and armies of hell'+tc_nl3+'around portal until the arrival of'+tc_nl3+'enemy reinforcements(for 20 minutes)';

   str_camp_obj [15] := '- Destroy all bases and armies of hell'+tc_nl3+'-Protect portal';
   str_camp_obj [16] := '- Repair and protect Science Center'+tc_nl3+'-Destroy all bases and armies of hell';
   str_camp_obj [17] := '- Destroy fortess of hell';

   str_camp_obj [18] := '- Destroy all altars of hell'+tc_nl3+'-Protect portal';
   str_camp_obj [19] := '- Reach the opposite side of the area';
   str_camp_obj [20] := '- Find and kill the Spiderdemon';

   str_camp_obj [21] := '- Cleanse the Quarry';
   str_camp_obj [22] := '';
   str_camp_obj [23] := '- Destroy all bases and armies of hell';  }


   str_makeHints;
end;

procedure lng_rus;
var t: shortstring;
    i: byte;
begin
  str_ps_AI                     := 'ИИ';

  str_Caption_Map               := 'КАРТА';
  str_Caption_Players           := 'ИГРОКИ';
  str_Caption_Multiplayer       := 'СЕТЕВАЯ ИГРА';
  str_Caption_GOptions          := 'ПАРАМЕТРЫ ИГРЫ';
  str_Caption_Objectives        := 'ЗАДАЧИ';

  str_menu_Campaings            := 'КАМПАНИИ И ОБУЧЕНИЕ';
  str_menu_Scirmish             := 'СХВАТКА';
  str_menu_Playback             := 'ПРОСМОТР ЗАПИСИ';
  str_menu_SaveLoad             := 'СОХРАНИТЬ/ЗАГРУЗИТЬ';
  str_menu_LoadGame             := 'ЗАГРУЗИТЬ ИГРУ';
  str_menu_Replays              := 'ЗАПИСИ';
  str_menu_Settings             := 'НАСТРОЙКИ';

  str_menu_Start                := 'НАЧАТЬ';
  str_menu_Surrender            := 'СДАТЬСЯ';
  str_menu_Abort                := 'ПРЕРВАТЬ МИССИЮ';
  str_menu_PlaybackStop         := 'ПРЕРВАТЬ';
  str_menu_Exit                 := 'ВЫХОД';
  str_menu_Back                 := 'НАЗАД';

  str_menu_Pause                := 'Пауза';

  str_S_Game      := 'ИГРА';
  str_S_Replay    := 'ЗАПИСЬ ИГРЫ';
  str_S_Video     := 'ГРАФИКА';
  str_S_Sound     := 'ЗВУК';

  str_SR_RecordGames    := 'Записывать игры';
  str_SR_ReplayPrefix   := 'Префикс записи';
  str_SR_Quality        := 'Размер/качество';

  str_FileInfo          := 'ИНФОРМАЦИЯ';
  str_FileSave          := 'Сохранить';
  str_FileLoad          := 'Загрузить';
  str_FileDelete        := 'Удалить';

  str_map               := 'Карта';
  str_map_Seed          := 'Номер';
  str_map_Size          := 'Размер';
  str_map_Obstacles     := 'Преграды';
  str_map_Symmetry      := 'Симметрия';
  str_map_Random        := 'Случайная карта';

  str_map_Scenario              := 'Сценарий';
  str_map_ScenarioL[mc_ffa3     ]:= tc_lime  +'Схватка(3)'       +tc_default;
  str_map_ScenarioL[mc_ffa4     ]:= tc_lime  +'Схватка(4)'       +tc_default;
  str_map_ScenarioL[mc_ffa5     ]:= tc_lime  +'Схватка(5)'       +tc_default;
  str_map_ScenarioL[mc_ffa6     ]:= tc_lime  +'Схватка(6)'       +tc_default;
  str_map_ScenarioL[mc_ffa7     ]:= tc_lime  +'Схватка(7)'       +tc_default;
  str_map_ScenarioL[mc_ffa8     ]:= tc_lime  +'Схватка(8)'       +tc_default;
  str_map_ScenarioL[mc_1x1      ]:= tc_yellow+'1x1'              +tc_default;
  str_map_ScenarioL[mc_2x2      ]:= tc_yellow+'2x2'              +tc_default;
  str_map_ScenarioL[mc_3x3      ]:= tc_yellow+'3x3'              +tc_default;
  str_map_ScenarioL[mc_4x4      ]:= tc_yellow+'4x4'              +tc_default;
  str_map_ScenarioL[mc_2x2x2    ]:= tc_orange+'2x2x2'            +tc_default;
  str_map_ScenarioL[mc_2x2x2x2  ]:= tc_orange+'2x2x2x2'          +tc_default;
  str_map_ScenarioL[mc_KeyPoints]:= tc_aqua  +'Захват точек'     +tc_default;
  str_map_ScenarioL[mc_KotH     ]:= tc_aqua  +'Царь горы'        +tc_default;
  str_map_ScenarioL[mc_royale   ]:= tc_red   +'Королевская битва'+tc_default;

  str_map_Generators            := 'Генераторы';
  str_map_GeneratorsL[0]        := 'свои';
  str_map_GeneratorsL[1]        := '5 мин.';
  str_map_GeneratorsL[2]        := '10 мин.';
  str_map_GeneratorsL[3]        := '15 мин.';
  str_map_GeneratorsL[4]        := '20 мин.';
  str_map_GeneratorsL[5]        := 'вечные';

  str_Players           := 'Игроки';

  str_SS_MusicVolume          := 'Громкость музыки';
  str_SS_SoundVolume          := 'Громкость звуков';
  str_SG_PlayerName           := 'Имя игрока';
  str_SG_RightClickAct        := 'Действие на правый клик';
  str_SG_RightClickActL[true ]:= tc_lime+'движение'+tc_default;
  str_SG_RightClickActL[false]:= tc_lime+'движение'   +tc_default+'+'+tc_red+'атака'+tc_default;
  str_SG_ScrollSpeed          := 'Скорость движения камеры';
  str_SG_MouseScroll          := 'Перемещение камеры курсором';
  str_SG_Language       := 'Язык интерфейса';

  str_SV_ResolutionApply:= 'Применить разрешение';
  str_SV_ResolutionW    := 'Разрешение (ширина)';
  str_SV_ResolutionH    := 'Разрешение (высота)';
  str_SV_Windowed       := 'В окне:';

  str_race[r_random]    := tc_white+'ЛЮБАЯ'  +tc_default;
  str_observer          := 'ЗРИТЕЛЬ';
  str_gstat_GamePaused             := 'Пауза';
  str_gstat_Win               := 'ПОБЕДА!';
  str_gstat_Lose              := 'ПОРАЖЕНИЕ!';
  str_gstat_Unknown         := 'Неизвестный статус!';
  str_gmsg_GameSaved            := 'Игра сохранена';
  str_gstat_ReplayEnd            := 'Конец записи!';
  str_gstat_ReplayError          := 'Ошибка при чтении файла!';

  str_FileError_NExists  := 'Файл не существует!';
  str_FileError_Open  := 'Неполучилось открыть файл!';
  str_FileError_WData := 'Неправильные данные файла!';
  str_FileError_WVer  := 'Неправильная версия файла!';
  str_ui_time              := 'Время: ';
  str_ui_menu              := 'Меню';
  str_gmsg_PlayerDefeat        := ' уничтожен!';
  str_FilePlay              := 'Проиграть';

  str_Camp_Difficulty            := 'Сложность';
  str_gstat_WaitForServer            := 'Ожидание сервера...';

  str_Caption_Server            := 'СЕРВЕР';
  str_Caption_Client            := 'КЛИЕНТ';
  str_menu_Chat         := 'ЧАТ(ВСЕ ИГРОКИ)';
  str_ui_ChatAll          := 'ВСЕ:';
  str_ui_ChatAllies       := 'СОЮЗНИКИ:';
  str_GO_Random           := 'Случайная схватка';

  str_gmsg_PlayerLeave             := ' покинул игру';
  str_gmsg_PlayerSurrender  := ' сдается!';
  str_GO_AISlots           := 'Заполнить пустые слоты';



  str_hint_requirements      := 'Требования: ';
  str_hint_req               := 'Треб.: ';
  str_ui_UnitGroups            := 'Отряды: ';
  str_all               := 'Все';
  str_hint_uprod             := tc_lime+'Создается в: '+tc_default;
  str_hint_bprod             := tc_lime+'Чем может быть построен: '     +tc_default;
  str_SG_ColoredShadow  := 'Цветные тени';
  str_ui_KothTime          := 'Время до захвата центра: ';
  str_ui_KotHTime_act      := 'Время до активации центральной зоны: ';
  str_ui_KotHWinner        := ' - Царь Горы!';
  str_GO_DefeatedObs     := 'Наблюдатель после поражения';
  str_SV_MenuScale        := 'Растягивание меню';
  str_SV_MenuScaleSmooth       := 'Гладкое растянутое меню';
  str_SV_ShowFPS               := 'Показать FPS';
  str_SG_ShowAPM               := 'Показать APM';
  str_hint_Ability           := 'Специальная способность: ';
  str_hint_TransformTo    := 'превращение в ';
  str_hint_UpgradesLvl       := 'Улучшения: ';
  str_hint_Demons            := 'демоны и зомби';
  str_hint_Except            := 'кроме';
  str_hint_SplashResist      := 'Невосприимчив к взрывной волне';
  str_hint_TargetLimit       := 'лимит цели';
  str_SS_NextTrack         := 'Следующий трек';
  str_SS_ReloadMusic       := 'Загрузить новый плейлист';
  str_gmsg_PlayerPaused      := 'игрок приостановил игру';
  str_gmsg_PlayerResumed     := 'игрок возобновил игру';
  str_SS_MusicListSize     := 'Размер плейлиста';
  str_gmsg_RecordStart    := 'Начало записи: ';
  str_gmsg_RecordStop     := 'Остановка записи: ';
  str_PT_Player          := 'ИГРОК';
  str_PT_State           := 'СТАТУС';
  str_PT_Race            := 'РАСА';
  str_PT_Team            := 'КЛАН';
  str_PT_Color           := 'ЦВЕТ';
  str_PT_Ping            := 'ПИНГ+';

  str_hint_builder           := 'Строитель';
  str_hint_barrack           := 'Производит юнитов';
  str_hint_smith             := 'Исследует улучшения и апгрейды';
  str_hint_IncEnergyLevel    := 'Увеличивает уровень энергии';
  str_hint_CanRebuildTo      := 'Можно перестроить в ';
  str_hint_UnitArming        := 'Вооружение/Способности: ';
  str_hint_hits              := 'Здоровье: ';
  str_hint_BaseSightR            := 'Базовый радиус обзора: ';

  str_uarm_melee      := 'ближний бой';
  str_uarm_ranged     := 'дальний бой';
  str_uarm_zombie     := '+зомбификация';
  str_uarm_ressurect  := 'воскрешение';
  str_uarm_heal       := 'лечение/ремонт';
  str_uarm_spawn      := 'порождение';
  str_uarm_suicide    := 'самоубийство';
  str_uarm_targets    := 'цели: ';
  str_uarm_BaseImpact     := 'воздействие';

  str_warn_AbilityBadPlace         := 'Нельзя переместиться или приземлиться здесь';
  str_warn_prod_BadPlace        := 'Нельзя строить здесь';
  str_warn_Req_Energy       := 'Необходимо больше энергии';
  str_warn_prod_BadOrder         := 'Невоможно произвести это';
  str_warn_Req_Common        := 'Проверьте требования';
  str_warn_Invalid_Order      := 'Невозвможно выполнить приказ';
  str_warn_unit_Levelup     := 'Юнит улучшен';
  str_warn_upgrade_complete  := 'Исследование завершено';
  str_warn_building_complete := 'Постройка завершена';
  str_warn_unit_complete     := 'Юнит готов';
  str_warn_unit_attacked     := 'Юнит атакован';
  str_warn_base_attacked     := 'База атакована';
  str_warn_allies_attacked   := 'Наши союзники атакованы';
  str_warn_MaxLimitReached  := 'Достигнут максимальный размер армии';
  str_warn_NeedBuilder:= 'Необходим строитель';
  str_warn_prod_AllBusy   := 'Все производства заняты';
  str_warn_NeedProdUnit      := 'Негде производить это';
  str_warn_MaxCountReached    := 'Достигнут максимум';
  str_warn_mapMark           := ' поставил отметку на карте';
  str_warn_kpoint_captured   := 'Ключевая точка захвачена!';
  str_warn_kpoint_lost       := 'Ключевая точка потеряна!';
  str_warn_koth_control      := ' команда контролирует центр!';
  str_warn_ngen_captured     := 'Нейтральный генератор захвачен!';
  str_warn_ngen_lost         := 'Нейтральный генератор потерян!';
  str_warn_ngen_exh          := 'Нейтральный генератор истощился!';
  str_warn_Invalid_Target    := 'Не подходящая цель!';

  str_attr_alive        := tc_lime  +'живой'         ;
  str_attr_dead         := tc_dgray +'мертвый'       ;
  str_attr_unit         := tc_gray  +'юнит'          ;
  str_attr_building     := tc_red   +'здание'        ;
  str_attr_mech         := tc_blue  +'механический'  ;
  str_attr_bio          := tc_orange+'биологический' ;
  str_attr_light        := tc_yellow+'легкий'        ;
  str_attr_heavy        := tc_green +'тяжелый'       ;
  str_attr_fly          := tc_white +'летающий'      ;
  str_attr_ground       := tc_lime  +'наземный'      ;
  str_attr_floater      := tc_aqua  +'парящий'       ;
  str_attr_level        := tc_white +'уровень '      ;
  str_attr_invuln       := tc_lime  +'неуязвимый'    ;
  str_attr_stuned       := tc_yellow+'оглушен'       ;
  str_attr_detector     := tc_purple+'детектор'      ;
  str_attr_transport    := tc_gray  +'транспорт'     ;

  str_SG_ControlPanelPos             := 'Положение игровой панели';
  str_SG_ControlPanelPosL[cpp_left  ]:= tc_lime  +'слева' +tc_default;
  str_SG_ControlPanelPosL[cpp_right ]:= tc_orange+'справа'+tc_default;
  str_SG_ControlPanelPosL[cpp_top   ]:= tc_yellow+'вверху'+tc_default;
  str_SG_ControlPanelPosL[cpp_bottom]:= tc_aqua  +'внизу' +tc_default;

  str_SG_HealthBars             := 'Полоски здоровья';
  str_SG_HealthBarsL[0]         := tc_lime  +'выбранные'+tc_default+'+'+tc_red+'поврежденные'+tc_default;
  str_SG_HealthBarsL[1]         := tc_aqua  +'всегда'   +tc_default;
  str_SG_HealthBarsL[2]         := tc_orange+'только '  +tc_lime+'выбранные'+tc_default;

  str_SG_PlayersColor            := 'Цвета игроков';
  str_SG_PlayersColorL[0]        := tc_white +'по умолчанию'+tc_default;
  str_SG_PlayersColorL[1]        := tc_lime  +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_SG_PlayersColorL[2]        := tc_white +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_SG_PlayersColorL[3]        := tc_white +'свои '+tc_aqua  +'союзники '+tc_red+'враги'+tc_default;
  str_SG_PlayersColorL[4]        := tc_purple+'команды'+tc_default;
  str_SG_PlayersColorL[5]        := tc_white +'свои '+tc_purple+'команды'+tc_default;

  str_GO_FixedStarts            := 'Фиксированные старты';

  str_net_Ready             := 'Готов: ';
  str_net_UDPPort           := 'UDP порт';
  str_net_ServerStart       := 'Включить сервер';
  str_net_ServerStop        := 'Выключить сервер';
  str_net_Connect           := 'Подключится';
  str_net_Disconnect        := 'Отключится';
  str_net_Quality           := 'Обновление юнитов';
  str_net_Address           := 'Адрес';
  str_net_LANSearch         := 'Поиск серверов в LAN';

  str_gmsg_PortBlocked       := 'Порт занят!';
  str_gmsg_WrongVersion              := 'Другая версия!';
  str_gmsg_ServerFull             := 'Нет мест!';
  str_gmsg_GameStarted              := 'Игра началась!';

  str_ui_Tab[0]         := 'Здания';
  str_ui_Tab[1]         := 'Юниты';
  str_ui_Tab[2]         := 'Исследования';
  str_ui_Tab[3]         := 'Запись';

  str_ui_LimitArmy         := 'Армия: ';
  str_ui_EnergyLevel       := 'Энергия: ';

 { str_ability_name[uab_Teleport        ]:='Призыв';
  str_ability_name[uab_UACScan         ]:='Сканирование';
  str_ability_name[uab_HTowerBlink     ]:='Скачок';
  str_ability_name[uab_UACStrike       ]:='Ракетный удар';
  str_ability_name[uab_HKeepShift      ]:='Перемещение';
  str_ability_name[uab_RebuildInPoint  ]:='';
  str_ability_name[uab_SphereInvuln]:='Неуязвимость';
  str_ability_name[uab_SpawnLost       ]:='Выпустить Lost Soul';
  str_ability_name[uab_HEyeVision      ]:='Адское зрение';
  str_ability_name[uab_UACCCLand           ]:='Двигатели для полета';
  str_ability_name[uab_ToUACDron       ]:='Разобрать в Дрона';
  str_ability_name[uab_Unload          ]:='Выгрузить';  }
  str_warn_AbilityReload:='Способность перезаряжается!';

  str_SetUnitBaseHint(UID_HKeep           ,'Адская Крепость'            ,'');
  str_SetUnitBaseHint(UID_HAKeep          ,'Великая Адская Крепость'    ,'');
  str_SetUnitBaseHint(UID_HGate           ,'Врата Демонов'              ,'');
  str_SetUnitBaseHint(UID_HSymbol1        ,'Нечестивый Символ 1 уровня' ,'');
  str_SetUnitBaseHint(UID_HSymbol2        ,'Нечестивый Символ 2 уровня' ,'');
  str_SetUnitBaseHint(UID_HSymbol3        ,'Нечестивый Символ 3 уровня' ,'');
  str_SetUnitBaseHint(UID_HSymbol4        ,'Нечестивый Символ 4 уровня' ,'');
  str_SetUnitBaseHint(UID_HPools          ,'Инфернальные Омуты'         ,'');
  str_SetUnitBaseHint(UID_HTeleport       ,'Телепорт'                   ,'');
  str_SetUnitBaseHint(UID_HPentagram      ,'Пентаграмма Смерти'         ,'');
  str_SetUnitBaseHint(UID_HMonastery      ,'Монастырь Отчаяния'         ,'');
  str_SetUnitBaseHint(UID_HFortress       ,'Замок Проклятых'            ,'');
  str_SetUnitBaseHint(UID_HTower          ,'Сторожевая Башня'           ,'Базовое защитное сооружение'          );
  str_SetUnitBaseHint(UID_HTotem          ,'Тотем Ужаса'                ,'Продвинутое защитное сооружение'      );
  str_SetUnitBaseHint(UID_HAltar          ,'Алтарь Боли'                ,'');
  str_SetUnitBaseHint(UID_HCommandCenter  ,'Проклятый Командный Центр'  ,''          );
  str_SetUnitBaseHint(UID_HACommandCenter ,'Продвинутый Проклятый Командный Центр','');
  str_SetUnitBaseHint(UID_HBarracks       ,'Казармы Зомби'              ,''          );
  str_SetUnitBaseHint(UID_HEye        ,'Гнездо Ока Зла'             ,'Обнаружение невидимых войск.');

  str_SetUnitBaseHint(UID_ZMedic          ,'Зомби Медик'                ,'');
  str_SetUnitBaseHint(UID_ZEngineer       ,'Зомби Инженер'              ,'');
  str_SetUnitBaseHint(UID_ZSergant        ,'Зомби Сержант'              ,'');
  str_SetUnitBaseHint(UID_ZSSergant       ,'Зомби Старший Сержант'      ,'');
  str_SetUnitBaseHint(UID_ZCommando       ,'Зомби Коммандо'             ,'');
  str_SetUnitBaseHint(UID_ZAntiaircrafter ,'Зомби Зенитчик'             ,'');
  str_SetUnitBaseHint(UID_ZSiegeMarine    ,'Зомби Артиллерист'          ,'');
  str_SetUnitBaseHint(UID_ZFPlasmagunner  ,'Зомби Плазмаганнер'         ,'');
  str_SetUnitBaseHint(UID_ZBFGMarine      ,'Зомби Солдат с BFG'         ,'');

  str_SetUpgrBaseHint(upgr_hell_DistDamage1  ,'Адская Огневая Мощь'           ,'Увеличение урона от дальних атак всех Т1 юнитов и защитных сооружений');
  str_SetUpgrBaseHint(upgr_hell_UnitArmor    ,'Боевая Плоть'                  ,'Увеличение защиты всех адских юнитов'                                 );
  str_SetUpgrBaseHint(upgr_hell_BuildArmor    ,'Каменные Стены'                ,'Увеличение защиты всех адских зданий'                                 );
  str_SetUpgrBaseHint(upgr_hell_MeleeDamage   ,'Когти и зубы'                  ,'Увеличение урона от ближних атак'                                     );
  str_SetUpgrBaseHint(upgr_hell_Regeneration     ,'Регенерация Плоти'             ,'Восстановление здоровья всех адских юнитов'                           );
  str_SetUpgrBaseHint(upgr_hell_PainFactor     ,'Болевой Порог'                 ,'Адские юниты реже испытывают болевой паралич'                         );
  str_SetUpgrBaseHint(upgr_hell_TowerR    ,'Демоническое Чутье'            ,'Увеличение радиуса обзора и атаки для защитных сооружений'            );
  str_SetUpgrBaseHint(upgr_hell_HKeepShift,'Телепортация Адской Крепости'  ,'Заряд для способности Адской Крепости'                                );
  str_SetUpgrBaseHint(upgr_hell_DecayAura     ,'Аура Разложения'               ,'Адская крепость наносит урон всем вражеских не-зданиям вокруг. Урон игнорирует броню юнитов');
  str_SetUpgrBaseHint(upgr_hell_BuilderR    ,'Увеличение Области Обзора Адской Крепости',''                                       );

  str_SetUpgrBaseHint(upgr_hell_Spectre   ,'Призраки'                      ,'Pinky Demon становиться невидимым'                                         );
  str_SetUpgrBaseHint(upgr_hell_UnitSightR    ,'Адское Зрение'                 ,'Увеличение области обзора и атаки всех адских юнитов'                      );
  str_SetUpgrBaseHint(upgr_hell_Phantoms  ,'Фантомы'                       ,'Pain Elemental создает Фантомов вместо Lost Soul'                          );
  str_SetUpgrBaseHint(upgr_hell_DistDamage2  ,'Демоническое Оружие'           ,'Увеличение урона от дальних атак всех Т2 юнитов и защитных сооружений'     );
  str_SetUpgrBaseHint(upgr_hell_TeleportCD  ,'Улучшение Телепорта'           ,'Уменьшение времени перезарядки Телепорта'                              );
  str_SetUpgrBaseHint(upgr_hell_Recall ,'Призыв'                        ,'Юнитов можно перемещать обратно в Телепорт'                            );
  str_SetUpgrBaseHint(upgr_hell_EvilEyeR      ,'Улучшение Ока Зла'             ,'Увеличение области обзора Ока Зла'                           );
  str_SetUpgrBaseHint(upgr_hell_TotemInvis   ,'Невидимость Тотема Ужаса'      ,''                               );
  str_SetUpgrBaseHint(upgr_hell_BuildRestore    ,'Восстановление Зданий'         ,'Восстановление здоровья всех адских зданий'                   );
  str_SetUpgrBaseHint(upgr_hell_TowerBlink    ,'Короткая Телепортация'         ,'Заряды для способности Сторожевой Башни и Тотема Ужаса');
  str_SetUpgrBaseHint(upgr_hell_Resurrect ,'Воскрешение'                   ,'Способность ArchVile'                    );


  str_SetUnitBaseHint(UID_UCommandCenter  ,'Командный Центр'            ,'');
  str_SetUnitBaseHint(UID_UACommandCenter ,'Продвинутый Командный Центр','');
  str_SetUnitBaseHint(UID_UBarracks       ,'Казармы'                    ,'');
  str_SetUnitBaseHint(UID_UFactory        ,'Фабрика'                    ,'');
  str_SetUnitBaseHint(UID_UGenerator1     ,'Генератор 1 уровня'         ,'');
  str_SetUnitBaseHint(UID_UGenerator2     ,'Генератор 2 уровня'         ,'');
  str_SetUnitBaseHint(UID_UGenerator3     ,'Генератор 3 уровня'         ,'');
  str_SetUnitBaseHint(UID_UGenerator4     ,'Генератор 4 уровня'         ,'');
  str_SetUnitBaseHint(UID_UWeaponFactory  ,'Завод Вооружений'           ,'');
  str_SetUnitBaseHint(UID_UGTurret        ,'Анти-наземная Турель'       ,'Анти-наземное защитное сооружение' );
  str_SetUnitBaseHint(UID_UATurret        ,'Анти-воздушная Турель'      ,'Анти-воздушное защитное сооружение');
  str_SetUnitBaseHint(UID_UTechCenter     ,'Научный Центр'              ,'');
  str_SetUnitBaseHint(UID_UComputerStation,'Компьютерная Станция'       ,'');
  str_SetUnitBaseHint(UID_URadar          ,'Радар'                      ,'');
  str_SetUnitBaseHint(UID_URMStation      ,'Станция Ракетного Залпа'    ,'');
  str_SetUnitBaseHint(UID_UMine           ,'Мина'                       ,'');

  str_SetUnitBaseHint(UID_Sergant         ,'Сержант'                ,'');
  str_SetUnitBaseHint(UID_SSergant        ,'Старший Сержант'        ,'');
  str_SetUnitBaseHint(UID_Commando        ,'Коммандо'               ,'');
  str_SetUnitBaseHint(UID_Antiaircrafter  ,'Зенитчик'               ,'');
  str_SetUnitBaseHint(UID_SiegeMarine     ,'Артиллерист'            ,'');
  str_SetUnitBaseHint(UID_FPlasmagunner   ,'Плазмаганнер'           ,'');
  str_SetUnitBaseHint(UID_BFGMarine       ,'Солдат с BFG'           ,'');
  str_SetUnitBaseHint(UID_Engineer        ,'Инженер'                ,'');
  str_SetUnitBaseHint(UID_Medic           ,'Медик'                  ,'');
  str_SetUnitBaseHint(UID_UACDron         ,'Дрон'                   ,'');
  str_SetUnitBaseHint(UID_UTransport      ,'Десантный корабль'      ,'');
  str_SetUnitBaseHint(UID_Terminator      ,'Терминатор'             ,'');
  str_SetUnitBaseHint(UID_Tank            ,'Танк'                   ,'');
  str_SetUnitBaseHint(UID_Flyer           ,'Истребитель'            ,'');
  str_SetUnitBaseHint(UID_APC             ,'БТР'                    ,'');


  str_SetUpgrBaseHint(upgr_uac_DistDamage     ,'Улучшение Воружений'               ,'Увеличение урона от дальних атак всех юнитов и защитных сооружений');
  str_SetUpgrBaseHint(upgr_uac_BioArmor     ,'Улучшение Пехотной Брони'          ,'Увеличение защиты всех юнитов из Казарм'                     );
  str_SetUpgrBaseHint(upgr_uac_BuildArmor     ,'Бетонные Стены'                    ,'Увеличение защиты всех зданий'                               );
  str_SetUpgrBaseHint(upgr_uac_RepairTools      ,'Продвинутые Инструменты'           ,'Увеличение эффективности ремонта Инженера и лечения Медика'  );
  str_SetUpgrBaseHint(upgr_uac_BioSpeed     ,'Легковесная Броня'                 ,'Увеличение скорости передвижения всех юнитов из Казарм'      );
  str_SetUpgrBaseHint(upgr_uac_ssgup      ,'Разрывные Пули'                    ,'Атака Сержанта, Старшего Сержанта и Терминатора чаще вызывают pain state' );
  str_SetUpgrBaseHint(upgr_uac_TowerR     ,'Прожекторы'                        ,'Увеличение радиуса обзора и атаки для защитных сооружений'      );
  str_SetUpgrBaseHint(upgr_uac_CCFly      ,'Летные Двигатели Командного Центра','Командный Центр может летать'                                   );
  str_SetUpgrBaseHint(upgr_uac_CCAttack     ,'Турель Командного Центра'          ,'Командный Центр может атаковать'                                );
  str_SetUpgrBaseHint(upgr_uac_BuilderR     ,'Увеличение Области Обзора Командного Центра',''                           );

  str_SetUpgrBaseHint(upgr_uac_DronTurret  ,'Протокол Трансформации Дрона'      ,'Дрон может превратиться в Анти-наземную Турель'    );
  str_SetUpgrBaseHint(upgr_uac_UnitSightR     ,'Улучшенные Визоры'                 ,'Увеличение области обзора и атаки всех юнитов'  );
  str_SetUpgrBaseHint(upgr_uac_CommandoInvis   ,'Стелс-Технологии'                  ,'Коммандо становиться невидимым'                 );
  str_SetUpgrBaseHint(upgr_uac_AASplash      ,'Осколочные Снаряды'                ,'Антивоздушные снаряды наносят урон по области'  );
  str_SetUpgrBaseHint(upgr_uac_MechSpeed    ,'Улучшеные Двигатели'               ,'Увеличение скорости передвижения юнитов из Фабрики'      );
  str_SetUpgrBaseHint(upgr_uac_MechArmor    ,'Улучшение Технической Брони'       ,'Увеличение защиты всех юнитов из Фабрики'                );
  str_SetUpgrBaseHint(upgr_uac_TerAAWeapon    ,'Анти-воздушное Орудие'             ,'Анти-воздушное оружие для Терминатора'                   );
  str_SetUpgrBaseHint(upgr_uac_Transport  ,'Улучшение Транспорта'              ,'Увеличение вместимости Десантного Корабля'               );
  str_SetUpgrBaseHint(upgr_uac_RadarR    ,'Улучшение Радара'                  ,'Увеличение области обзора Радара'            );
  str_SetUpgrBaseHint(upgr_uac_TurretPlasma     ,'Анти-наземное Плазменное Орудие'   ,'Анти-['+str_attr_mech+'] орудие для Анти-наземной Турели');
  str_SetUpgrBaseHint(upgr_uac_TurretArmor     ,'Дополнительное Бронирование'       ,'Дополнительная защита для турелей'              );

  {str_sability := 'Специальная способность';
  str_spability:= 'Специальная способность в точке';

  str_use_sability :='Используйте приказ "'+str_sability +'"!';
  str_use_spability:='Используйте приказ "'+str_spability+'"!'; }

  {//_mkHStrACT(0 ,str_sability );
  //_mkHStrACT(1 ,str_spability);
  _mkHStrACT(2 ,'Перестроить/Улучшить');
  t:='атаковать врагов';
  _mkHStrACT(3 ,'Двигаться, '       +t);
  _mkHStrACT(4 ,'Стоять, '          +t);
  _mkHStrACT(5 ,'Патрулировать, '   +t);
  t:='игнорировать врагов';
  _mkHStrACT(6 ,'Двигаться, '       +t);
  _mkHStrACT(7 ,'Стоять, '          +t);
  _mkHStrACT(8 ,'Патрулировать, '   +t);
  _mkHStrACT(9 ,'Отмена производства' );
  _mkHStrACT(10,'Выбрать всех боевых незанятых юнитов');
  _mkHStrACT(11,'Уничтожить'          );
  _mkHStrACT(12,'Поставить метку'     );
  _mkHStrACT(13,str_SG_RightClickAct           );

  _mkHStrRPL(0 ,'Включить/выключить ускоренный просмотр',false);
  _mkHStrRPL(1 ,'Левый клик: назад на 2 секунды ('                                 +tc_lime+'W'+tc_default+')'+tc_nl1+
                'Правый клик: назад на 10 секунд ('  +tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                'Средний клик: назад на 1 минуту ('  +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  _mkHStrRPL(2 ,'Левый клик: пропустить 2 секунды ('                               +tc_lime+'E'+tc_default+')'+tc_nl1+
                'Правый клик: пропустить 10 секунд ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'E'+tc_default+')'+tc_nl1+
                'Средний клик: пропустить 1 минуту ('+tc_lime+'Alt' +tc_default+'+'+tc_lime+'E'+tc_default+')',true  );
  _mkHStrRPL(3 ,'Пауза'                   ,false);
  _mkHStrRPL(4 ,'Камера игрока'           ,false);
  _mkHStrRPL(5 ,'Список игровых сообщений',false);
  _mkHStrRPL(6 ,'Туман войны'             ,false);
  _mkHStrRPL(8 ,'Все игроки'              ,false);
  _mkHStrRPL(9 ,'Игрок #1',false);
  _mkHStrRPL(10,'Игрок #2',false);
  _mkHStrRPL(11,'Игрок #3',false);
  _mkHStrRPL(12,'Игрок #4',false);
  _mkHStrRPL(13,'Игрок #5',false);
  _mkHStrRPL(14,'Игрок #6',false);

  _mkHStrOBS(0 ,'Туман войны',false);
  _mkHStrOBS(2 ,'Все игроки' ,false);
  _mkHStrOBS(3 ,'Игрок #1'   ,false);
  _mkHStrOBS(4 ,'Игрок #2'   ,false);
  _mkHStrOBS(5 ,'Игрок #3'   ,false);
  _mkHStrOBS(6 ,'Игрок #4'   ,false);
  _mkHStrOBS(7 ,'Игрок #5'   ,false);
  _mkHStrOBS(8 ,'Игрок #6'   ,false);   }


  FillChar(str_menu_hint,sizeOf(str_menu_hint),0);

  //for i in byte do str_menu_hint[i]:=b2s(i);

  /////////////////////////////////////////////////////////////////////////////


  str_cmp_unk       := 'НЕИЗВЕСТНО';
  str_cmp_Date      := tc_gray+'Дата: ' +tc_default;
  str_cmp_Location  := tc_gray+'Место: '+tc_default;
  str_cmp_Area      := tc_gray+'Район: '+tc_default;

  for i:=0 to LastMission do
  begin
     setlength(str_camp_infol[i],0);
     str_camp_infon[i]:=0;
  end;


  cmp_AddPlot(0,false,
'Эта планета выглядит устрашающе: повсюду огонь, раскаленная лава и жуткие существа. Она находится далеко среди тысяч других миров, принадлежащих могущественной галактической империи. Здесь все оставалось неизменным долгие столетия после завоевания...');
  cmp_AddPlot(0,false,
'пока вдруг не заработал старый телепортатор, построенный какой-то древней цивилизацией. Из портала прибыли технически развитые пришельцы, сразу занявшиеся изучением новой местности.');

  cmp_AddPlot(0,true ,
'Вы - один из высших демонов, чье призвание - вести в бой демоническое воинство. Вы не так давно были повышены до своего нынешнего ранга и еще не успели проявить себя.');
  cmp_AddPlot(0,false,
'Ваше первое задание - изучить пришельцев, проникнуть в их мир и подчинить его власти Империи.');

  cmp_AddPlot(0,true,
'Захватчики построили крупный лагерь около Портала, а у нас в этом регионе нет даже небольшого форпоста. Необходимо быстро построить базу, призвать армию и сокрушить нарушителей!');

  cmp_AddPlot(0,true ,'- Достичь уровня энергии 2000');
  cmp_AddPlot(0,false,'- Построить 4 Врат Демонов'  );
  cmp_AddPlot(0,false,'- Призвать 30 адских монстров');
  cmp_AddPlot(0,false,'- Адская Крепость должна уцелеть' );
  cmp_AddPlot(0,false,'- Уничтожить вторгшихся захватчиков');

  {str_camp_MissionName[0]         := 'Hell #1: Вторжение на Фобос';
  str_camp_MissionName[1]         := 'Hell #2: Военная база';
  str_camp_MissionName[2]         := 'Hell #3: Вторжение на Деймос';
  str_camp_MissionName[3]         := 'Hell #4: Пентаграмма смерти';
  str_camp_MissionName[4]         := 'Hell #7: Каньон';
  str_camp_MissionName[5]         := 'Hell #8: Ад на Марсе';
  str_camp_MissionName[6]         := 'Hell #5: Ад на Земле';
  str_camp_MissionName[7]         := 'Hell #6: Космодром';

  str_camp_obj[0]         := '-Уничтожь все людские базы и армии'+tc_nl2+'-Защити портал';
  str_camp_obj[1]         := '-Уничтожь военную базу';
  str_camp_obj[2]         := '-Уничтожь все людские базы и армии'+tc_nl2+'-Защити портал';
  str_camp_obj[3]         := '-Защити алтари в течении 20 минут';
  str_camp_obj[4]         := '-Уничтожь все людские базы и армии';
  str_camp_obj[5]         := '-Уничтожь все людские базы и армии';
  str_camp_obj[6]         := '-Уничтожь все людские базы и армии';
  str_camp_obj[7]         := '-Уничтожь космодром'+tc_nl2+'-Ни один людской транспорт не должен'+tc_nl2+'уйти';

  str_camp_map[0]         := tc_lime+'Дата:'+tc_default+tc_nl3+'15.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ФОБОС' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Аномалия';
  str_camp_map[1]         := tc_lime+'Дата:'+tc_default+tc_nl3+'16.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ФОБОС' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Кратер Халл';
  str_camp_map[2]         := tc_lime+'Дата:'+tc_default+tc_nl3+'15.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ДЕЙМОС'+tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Аномалия';
  str_camp_map[3]         := tc_lime+'Дата:'+tc_default+tc_nl3+'16.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ДЕЙМОС'+tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Кратер Свифт';
  str_camp_map[4]         := tc_lime+'Дата:'+tc_default+tc_nl3+'18.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'МАРС'  +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Равнина Хеллас';
  str_camp_map[5]         := tc_lime+'Дата:'+tc_default+tc_nl3+'19.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'МАРС'  +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Равнина Хеллас';
  str_camp_map[6]         := tc_lime+'Дата:'+tc_default+tc_nl3+'18.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ЗЕМЛЯ' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Неизвестно';
  str_camp_map[7]         := tc_lime+'Дата:'+tc_default+tc_nl3+'19.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ЗЕМЛЯ' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Неизвестно';  }

  str_makeHints;
end;

{
procedure WriteUnitDescriptions;
const fname = '_strings.txt';
var
f  :text;
u,a:byte;
procedure upgrLine(upid:byte;info:shortstring);
begin
   if(upid>0)then
     with g_upids[upid] do
       writeln(f,'- ',upgr_str_Name,' - ',info,';');
end;
begin
   assign(f,fname);
   rewrite(f);

   for u:=0 to 255 do
    with g_uids[u] do
     if(length(uid_str_Name)>0)and(uid_r>0)then
     begin
        writeln(f,uid_str_name);
        writeln(f);

        writeln(f,'Hotkey: ',RemoveSpecChars(str_ProductionHotKey(uid_uibtn)));
        writeln(f,'Categories/Attributes: ',RemoveSpecChars(str_UnitAttributes(nil,u)));
        writeln(f,'Max hits: ',uid_MaxHits1);

        if(uid_BaseRegen>0)then
        writeln(f,'Base regeneration: ',uid_BaseRegen);

        writeln(f,'Limit used: ', limit2s(uid_LimitUse,ul1));
        writeln(f,'Size: ',uid_r);
        if(uid_BaseSpeed>0)then
        writeln(f,'Base movement speed: ' , uid_BaseSpeed);
        writeln(f,'Base vision range: ', uid_BaseSightR);
        writeln(f,'Build time: ' , uid_ProdTimeSec);
        writeln(f,'Energy required: ' , uid_EnergyReq);
        if(uid_PainC>0)then
        writeln(f,'PainState base threshold: ' , uid_PainC);
        if(not uid_isfly)and(not uid_isbuilding)then
        writeln(f,'Places in transport: ',uid_TransportSize );
        if(uid_TransportMax>0)then
        writeln(f,'Base transport capacity: ',uid_TransportMax );

        if(uid_ZombieUID>0)then
        if(uid_ZombieHits>0)or(uid_FastDeathHits<0)then
        begin
        writeln(f,'Zombie: ',g_uids[uid_ZombieUID].uid_str_name );
        writeln(f,'Zombification hits: ',uid_ZombieHits);
        end;

        writeln(f,RemoveSpecChars(uid_str_Reqs));

        if(uid_CanAttack)then
        begin
           writeln(f,str_hint_UnitArming);

           if(length(uid_str_ArmsCommon)>0)then
             writeln(f,uid_str_ArmsCommon);

           for a:=0 to LastUnitArms do
             if(length(uid_str_Arms[a])>0)then writeln(f,uid_str_Arms[a],';');
        end;


        writeln(f,'Upgrades:');
        upgrLine(uid_upgr_SightR,'vision range '+i2sSign(uid_upgr_SightStep));
        if(not uid_isbuilding)then
        upgrLine(upgr_race_unit_srange[uid_race],'vision range '+i2sSign(upgr_race_srange_unit_bonus[uid_race]));

        if(uid_isbuilding)
        then upgrLine(uid_upgr_Armor,'armor '+i2sSign(UpgradeBuildArmorBonus))
        else upgrLine(uid_upgr_Armor,'armor '+i2sSign(UpgradeUnitArmorBonus ));

        if(uid_isbuilding)
        then upgrLine(upgr_race_armor_build[uid_race],'armor '+i2sSign(UpgradeBuildArmorBonus))
        else
          if(uid_ismech)
          then upgrLine(upgr_race_armor_mech[uid_race],'armor '+i2sSign(UpgradeUnitArmorBonus))
          else upgrLine(upgr_race_armor_bio [uid_race],'armor '+i2sSign(UpgradeUnitArmorBonus));

        upgrLine(uid_upgr_Regen,'hits regeneration '+i2sSign(BaseArmorBonus1));
        if(uid_isbuilding)
        then upgrLine(upgr_race_regen_build[uid_race],'hits regeneration '+i2sSign(BaseArmorBonus1))
        else
          if(uid_ismech)
          then upgrLine(upgr_race_regen_mech[uid_race],'hits regeneration '+i2sSign(BaseArmorBonus1))
          else upgrLine(upgr_race_regen_bio [uid_race],'hits regeneration '+i2sSign(BaseArmorBonus1));

        if(uid_isbuilding)
        then
        else
          if(uid_ismech)
          then upgrLine(upgr_race_mspeed_mech[uid_race],'movement speed '+i2sSign(2))
          else upgrLine(upgr_race_mspeed_bio [uid_race],'movement speed '+i2sSign(2));

        if(not uid_isbuilding)and(uid_PainC>0)and(uid_race=r_hell)then
        upgrLine(upgr_hell_PainFactor,'PainState threshold '+i2sSign(uid_PainCUpgrStep));

        writeln(f);

        writeln(f,RemoveSpecChars(str_MakeUnitDefaultDescription(u,uid_str_BaseDescript,true)));

        writeln(f);
        {
        Max count	Unlimited
        }
        writeln(f,'---------------------------');
        writeln(f);
     end;

   writeln(f);

   for u:=0 to 255 do
    with g_upids[u] do
     if(length(upgr_str_Name)>0)then
     begin
        writeln(f,RemoveSpecChars(str_makeUpgrCostHint(u,255)));
        //writeln(f,RemoveSpecChars(upgr_txt_Hint));
        writeln(f);
     end;
   writeln(f);
{
s1:=str_makeUpgrCostHint(uid,upgr[uid]+1);
hs1:=@s1;
hs4:=@g_upids[uid].upgr_txt_Hint;
}

   close(f);
end;   }

procedure SwitchLanguage;
begin
  if(ui_language)
  then lng_rus
  else lng_eng;
end;



