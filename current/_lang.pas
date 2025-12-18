
////////////////////////////////////////////////////////////////////////////////
//
//  MAIN
//

procedure DocHelp_AddHotKeyAction(iActSet:TSoB;descr:shortstring;gapStr:shortstring=': ');
var i:byte;
   hk:shortstring;
begin
   if(iActSet=[])
   then str_AddToStrList(@str_doc_HotKeys,ui_DocLineLen1,false,false,descr)
   else
   begin
      hk:='';
      for i in iActSet do
        STRADD(@hk,str_ActionHotKey(i),sep_space);
      str_AddToStrList(@str_doc_HotKeys,ui_DocLineLen2,false,false,hk+gapStr+descr);
   end;
end;

procedure lng_eng;
var
t1:shortstring;
i :byte;
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
   str_replay_ScenarioL[i]:=str_RemoveSpecChars(str_map_ScenarioL[i]);
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
   str_ui_Tab[tab_Upgrades ]     := 'Upgrades&Researches';
   str_ui_Tab[tab_Controls ]     := 'Controls';
   str_ui_LimitArmy              := tc_orange+'Army limit'  +tc_white+': ';
   str_ui_LimitBuildings         := tc_red   +'Units'       +tc_white+': ';
   str_ui_LimitUnits             := tc_gray  +'Buildings'   +tc_white+': ';
   str_ui_EnergyLevel            := tc_aqua  +'Energy level'+tc_white+': ';
   str_ui_objectives             := 'Objectives:';

   str_hint_upgrade              := 'upgrade';
   str_hint_sec                  := 'sec.';
   str_hint_requirements         := 'Requirements: ';
   str_hint_req                  := 'Req.: ';
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
   str_hint_SightR               := 'sight range';

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
   //str_uarm_suicide              := 'suicide';
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

   str_help_Basics               := 'Basics';
   str_help_HotKeys              := 'Hot keys';
   str_help_UnitsInfo            := 'Units Info';
   str_help_BalanceTable         := 'Balance Table';

   str_doc_HotKey                := 'Hot key: ';
   str_doc_Attributes            := 'Categories/Attributes: ';
   str_doc_ProdEnergy            := 'Energy required: ';
   str_doc_ProdTime              := 'Build time: ';
   str_doc_Limit                 := 'Limit used: ';
   str_doc_MaxHits               := 'Max hits: ';
   str_doc_BaseRegen             := 'Base regeneration: ';
   str_doc_BaseSightR            := 'Base '+str_hint_SightR+': ';
   str_doc_Size                  := 'Size: ';
   str_doc_BaseMSpeed            := 'Base speed: ';
   str_doc_Role                  := 'Unit function: ';
   str_doc_Description           := 'Description: ';
   str_doc_PainC                 := 'PainState base threshold: ';
   str_doc_TransportSize         := 'Places in transport: ';
   str_doc_TransportCpst         := 'Base transport capacity: ';
   str_doc_LevelArmorBonus       := 'Bonus to armor per level: ';
   str_doc_LevelDamageBonus      := 'Bonus to impact per level: ';
   str_doc_ZombieUID             := 'Zombie: ';
   str_doc_ZombieHits            := 'Zombie hits threshold: ';
   str_doc_DeathUnit             := 'Spawn unit at death: ';
   str_doc_UpgrArmor             := 'Armor: ';
   str_doc_UpgrRegen             := 'Regeneration: ';
   str_doc_UpgrSpeed             := 'Move speed: ';
   str_doc_UpgrPainS             := 'Painstate threshold: ';
   str_doc_UpgrSightR            := 'Sight range: ';
   str_doc_UpgrTransport         := 'Transport capacity: ';
   str_doc_LMB                   := tc_lime+'LMB'+tc_white;
   str_doc_RMB                   := tc_red +'RMB'+tc_white;
   str_doc_MWH                   := tc_yellow+'MWheel'+tc_white;

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
   t1:='Transform to ';
   str_SetAbilityBaseHint(uab_ToHAKeep           ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHSymbol2         ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHSymbol3         ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHSymbol4         ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHACommandCenter  ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHTower           ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHTotem           ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUACommandCenter  ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUGenerator2      ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUGenerator3      ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUGenerator4      ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUAGTurret        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUAATurret        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUACDron          ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUGTurretTo       ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUATurretTo       ,t1                         ,'');
   t1:='Advanced ';
   str_SetAbilityBaseHint(uab_ToHGate            ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHPool            ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToHBarracks        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUBarracks        ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUFactory         ,t1                         ,'');
   str_SetAbilityBaseHint(uab_ToUWeaponFactory   ,t1                         ,'');


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
   str_SetUnitBaseHint(UID_URadar           ,'Radar'                         ,'Reveals the map area');
   str_SetUnitBaseHint(UID_URMStation       ,'Rocket Launcher Station'       ,'');

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


   str_SetUpgrBaseHint(upgr_uac_DistDamage   ,'Weapons Upgrade'                  ,'Increase the damage of ranged attacks for all UAC units and defensive structures');
   str_SetUpgrBaseHint(upgr_uac_BioArmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barrack`s units'                     );
   str_SetUpgrBaseHint(upgr_uac_BuildArmor   ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings'                       );
   str_SetUpgrBaseHint(upgr_uac_RepairTools  ,'Advanced Tools'                   ,'Increase repair/healing efficiency of Engineers/Medics'        );
   str_SetUpgrBaseHint(upgr_uac_BioSpeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barrack`s units'            );
   str_SetUpgrBaseHint(upgr_uac_SSMWeapon    ,'Surface to Surface Missiles'      ,'Anti-ground weapon for Antiaircrafter');
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

   /////////////////////////////////////////////////////////////////////////////
   //  GAME ACT HINTS

   str_SetActionBaseHint(iAct_Control_USelBase   ,'Select all builders');
   str_SetActionBaseHint(iAct_Control_USelArmy   ,'Select all not busy battle units;');

   t1:='attack enemies';
   str_SetActionBaseHint(iAct_Control_UAMove     ,'Move, '  +t1);
   str_SetActionBaseHint(iAct_Control_UAStop     ,'Stop, '  +t1);
   str_SetActionBaseHint(iAct_Control_UAPatrol   ,'Patrol, '+t1);
   t1:='ignore enemies';
   str_SetActionBaseHint(iAct_Control_UMove      ,'Move, '  +t1);
   str_SetActionBaseHint(iAct_Control_UStop      ,'Stop, '  +t1);
   str_SetActionBaseHint(iAct_Control_UPatrol    ,'Patrol, '+t1);

   str_SetActionBaseHint(iAct_Control_UProdCncl  ,'Cancel production');
   str_SetActionBaseHint(iAct_Control_UDestroy   ,'Destroy');
   str_SetActionBaseHint(iAct_Control_USelArmy   ,'Select all battle units');

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
   str_SetActionBaseHint(iAct_Replay_Fog         ,'Fog of war');
   str_SetActionBaseHint(iAct_Replay_PlayerAll   ,'All players');
   str_SetActionBaseHint(iAct_Replay_Player0     ,'Player #1');
   str_SetActionBaseHint(iAct_Replay_Player1     ,'Player #2');
   str_SetActionBaseHint(iAct_Replay_Player2     ,'Player #3');
   str_SetActionBaseHint(iAct_Replay_Player3     ,'Player #4');
   str_SetActionBaseHint(iAct_Replay_Player4     ,'Player #5');
   str_SetActionBaseHint(iAct_Replay_Player5     ,'Player #6');
   str_SetActionBaseHint(iAct_Replay_Player6     ,'Player #7');
   str_SetActionBaseHint(iAct_Replay_Player7     ,'Player #8');

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

   /////////////////////////////////////////////////////////////////////////////
   //  MENU HINTS

   FillChar(str_menu_hint,sizeOf(str_menu_hint),0);
   FillChar(menu_hint_pos,sizeOf(menu_hint_pos),0);

   for i:=1 to 255 do menu_set_hint(i,i,'');

   menu_set_hint(mi_SaveLoad_fname,mi_SaveLoad_list,'');

   for i in [mi_Players_Panel    ..mi_Players_Obs7     ] do menu_set_hint(i,mi_Players_Panel    ,'');
   for i in [mi_Map_Panel        ..mi_Map_Random       ] do menu_set_hint(i,mi_Map_Panel        ,'');
   for i in [mi_Game_Panel       ..mi_Game_Random      ] do menu_set_hint(i,mi_Game_Panel       ,'');
   for i in [mi_MP_Panel         ..mi_MP_ChatLine      ] do menu_set_hint(i,mi_MP_Panel         ,'');

   for i in [mi_SG_ColoredShadows..mi_SG_PlayersColor  ] do menu_set_hint(i,mi_SG_ColoredShadows,'');
   for i in [mi_SR_RecordGames   ..mi_SR_RecordQuality ] do menu_set_hint(i,mi_SR_RecordGames   ,'');
   for i in [mi_SV_ResolutionW   ..mi_SV_SmoothScaled  ] do menu_set_hint(i,mi_SV_ResolutionW   ,'');
   for i in [mi_SS_SoundVolume   ..mi_SS_ReloadPlaylist] do menu_set_hint(i,mi_SS_SoundVolume   ,'');

   // PLAYERS
   for i:=mi_Players_AIskil0 to mi_Players_AIskil7 do menu_set_hint(i,mi_Players_Panel,': change AI skill');
   for i:=mi_Players_Slot0   to mi_Players_Slot7   do menu_set_hint(i,mi_Players_Panel,': jump to this slot');
   for i:=mi_Players_State0  to mi_Players_State7  do menu_set_hint(i,mi_Players_Panel,': add/remove AI Player');

   // MAP
   menu_set_hint(mi_Map_Generators,mi_Map_Panel,': generators life time');
   menu_set_hint(mi_Map_Seed      ,mi_Map_Panel,': select for edition/make random value');
   menu_set_hint(mi_Map_Obstacles ,mi_Map_Panel,': obstacles density');

   /////////////////////////////////////////////////////////////////////////////
   //  Help docs

   str_StringListClear(@str_doc_Basics1);
   str_StringListClear(@str_doc_HotKeys);

   DocHelp_AddHotKeyAction([],'COMMON HOTKEYS');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_InGameChat       ],'in-game chat(common)');
   DocHelp_AddHotKeyAction([iAct_InGameChatAll    ],'in-game chat(to all players)');
   DocHelp_AddHotKeyAction([iAct_InGameChatAll    ],'in-game chat(to allied players)');
   DocHelp_AddHotKeyAction([iAct_InGamePause      ],'toggle pause(only multiplayer game)');
   DocHelp_AddHotKeyAction([iAct_InGameMenu       ],'toggle menu');

   DocHelp_AddHotKeyAction([iAct_Tab              ],'switch control panel tab' );
   DocHelp_AddHotKeyAction([iAct_ScreenShot       ],'make *.bmp screenshot'    );
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([],'GAME HOTKEYS');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_LastEvent        ],'move camera to last event place');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_USetGroup1..
                            iAct_USetGroup9]       ,'assign currently selected units to the numbered control group');
   DocHelp_AddHotKeyAction([iAct_USetGroup0       ],'unassign currently selected units from any numbered control group');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_UAddGroup1..
                            iAct_UAddGroup9       ],'add currently selected units to the numbered control group');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_USelGroup1..
                            iAct_USelGroup9       ],'select units from the numbered control group; double tap - move camera to nearest unit from the group');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_UASlGroup1..
                            iAct_UASlGroup9       ],'add to selection units from the numbered control group');
   DocHelp_AddHotKeyAction([],' ');

   DocHelp_AddHotKeyAction([iAct_Control_UAbility1..
                            iAct_Control_UAbility3],'abilities of selected units');

   DocHelp_AddHotKeyAction([iAct_Control_UMove,iAct_Control_UStop,iAct_Control_UPatrol,
                            iAct_Control_UAMove,iAct_Control_UAStop,iAct_Control_UAPatrol]
                                                   ,'basic orders of selected units');
   DocHelp_AddHotKeyAction([iAct_Control_UProdCncl],'cancel production in selected buildings');
   DocHelp_AddHotKeyAction([iAct_Control_UDestroy ],'kill selected units');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_Control_USelBase ],'select all builders; double tap - move camera to nearest builder');
   DocHelp_AddHotKeyAction([iAct_Control_USelArmy ],'select all not busy battle units; double tap - move camera to nearest unit');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_SProd1..
                            iAct_SProd24          ],'production hotkeys');

   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([],'REPLAY PLAYBACK CONTROLS');
   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([iAct_Replay_Fast      ],'toggle uncapped FPS(faster game speed)' );
   DocHelp_AddHotKeyAction([iAct_Replay_Pause     ],'pause playback'    );
   DocHelp_AddHotKeyAction([iAct_Replay_Back60    ],'rewind 60 seconds' );
   DocHelp_AddHotKeyAction([iAct_Replay_Back10    ],'rewind 10 seconds' );
   DocHelp_AddHotKeyAction([iAct_Replay_Back2     ],'rewind 2 seconds'  );
   DocHelp_AddHotKeyAction([iAct_Replay_Forward2  ],'fast forward 2 seconds' );
   DocHelp_AddHotKeyAction([iAct_Replay_Forward10 ],'fast forward 10 seconds');
   DocHelp_AddHotKeyAction([iAct_Replay_Forward60 ],'fast forward 60 seconds');
   DocHelp_AddHotKeyAction([iAct_Replay_POV       ],'toggle player-recorder POV'  );
   DocHelp_AddHotKeyAction([iAct_Replay_Log       ],'toggle list of game messages');
   DocHelp_AddHotKeyAction([iAct_Replay_Fog       ],'toggle fog of war' );
   DocHelp_AddHotKeyAction([iAct_Replay_PlayerAll ],'set all players vision');
   DocHelp_AddHotKeyAction([iAct_Replay_Player0..
                            iAct_Replay_Player7   ],'set player vision');

   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([],'OBSERVER MODE CONTROLS');
   DocHelp_AddHotKeyAction([],' ');

   DocHelp_AddHotKeyAction([iAct_Observer_Fog      ],'toggle fog of war' );
   DocHelp_AddHotKeyAction([iAct_Observer_PlayerAll],'set all players vision');
   DocHelp_AddHotKeyAction([iAct_Observer_Player0..
                            iAct_Observer_Player7  ],'set player vision');

   DocHelp_AddHotKeyAction([],' ');
   DocHelp_AddHotKeyAction([],'TEST MODE CONTROLS');
   DocHelp_AddHotKeyAction([],' ');

   DocHelp_AddHotKeyAction([iAct_test_FastTime     ],'toggle uncapped FPS(faster game speed)');
   DocHelp_AddHotKeyAction([iAct_test_InstaProd    ],'toggle instant production');
   DocHelp_AddHotKeyAction([iAct_test_ToggleAI     ],'toggle AI control for current player');
   DocHelp_AddHotKeyAction([iAct_test_iddqd        ],'toggle invulnerability for current player');
   DocHelp_AddHotKeyAction([iAct_test_FogToggle    ],'toggle fog of war'   );
   DocHelp_AddHotKeyAction([iAct_test_DrawToggle   ],'toggle screen redraw');
   DocHelp_AddHotKeyAction([iAct_test_NullUpgrades ],'cancel all upgrades for current player');
   DocHelp_AddHotKeyAction([iAct_test_BePlayer0..
                            iAct_test_BePlayer7    ],'set current player');
   {
   input_SetAction(iAct_test_debug0       ,ikt_keyboard,0           ,SDLK_KP8         );
   input_SetAction(iAct_test_debug1       ,ikt_keyboard,0           ,SDLK_KP9         );
   }


   //str_doc_HotKeys


   {
   Game Basics: UI

   Game minimap:
   Minimap indicator types:
   - Green pulse circle – unit ready;
   - Green pulse square – construction complete;
   - Yellow pulse square - upgrade complete;
   - Aqua pulse circle - unit promoted;
   - Red pulse circle – unit is under attack;
   - Red pulse square – base is under attack.

   Tabs:
   - Buildings – available buildings;
   - Units – available units;
   - Upgrades/researches – available upgrades/researches;
   - Controls – unit abilities, basic orders and other game controls.

   Numbers on icons:
   Green – total number of selected units/buildings;
   Yellow – number of productions;
   Orange or gray - total number of that type of building/unit or research level;
   Purple - number of units of that type in selected transport(s);
   White - time left to finish production;
   Aqua – ability recharge time;





   Dedicated server
   Dedicated server - a special version of the game that does not load any game resources and
   immediately starts working as a server. To start a dedicated server, run it with the following
   parameters:
   MarsWars_ded.exe [X]
   where Х - UDP port (optional argument, default value - 10666).
   Any connected player can change the game settings in a dedicated server's lobby.
The game will start automatically as soon as all players mark the 'ready' option. The server will return to the lobby one minute after the game ends or immediately after all players leave the server.


   }

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

   {str_camp_MissionMap [0 ] := str_camp_SetMapInfo(str_cmp_unk ,'HELL WORLD','Portal valley');
   str_camp_MissionMap [1 ] := str_camp_SetMapInfo('15.11.2145','PHOBOS'    ,'Hall crater'  );
   str_camp_MissionMap [2 ] := str_camp_SetMapInfo('16.11.2145','PHOBOS'    ,'Drunlo crater');
   str_camp_MissionMap [3 ] := str_camp_SetMapInfo('15.11.2145','DEIMOS'    ,'Anomaly Zone' );
   str_camp_MissionMap [4 ] := str_camp_SetMapInfo('16.11.2145','DEIMOS'    ,'Swift crater' );
   str_camp_MissionMap [5 ] := str_camp_SetMapInfo('16.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_MissionMap [6 ] := str_camp_SetMapInfo('16.11.2145','MARS'      ,'Hellas Area'  );
   str_camp_MissionMap [7 ] := str_camp_SetMapInfo('16.11.2145','MARS'      ,'Hellas Area'  );
   str_camp_MissionMap [8 ] := str_camp_SetMapInfo('16.11.2145','MARS'      ,'Hellas Area'  );
   str_camp_MissionMap [9 ] := str_camp_SetMapInfo('25.11.2145','EARTH'     ,'Unknown');
   str_camp_MissionMap [10] := str_camp_SetMapInfo('26.11.2145','EARTH'     ,'Unknown');
   str_camp_MissionMap [11] := str_camp_SetMapInfo('27.11.2145','EARTH'     ,'Unknown');

   str_camp_MissionMap [12] := str_camp_SetMapInfo('16.11.2145','PHOBOS'    ,'Todd crater'  );
   str_camp_MissionMap [13] := str_camp_SetMapInfo('16.11.2145','PHOBOS'    ,'Roche crater' );
   str_camp_MissionMap [14] := str_camp_SetMapInfo('17.11.2145','PHOBOS'    ,'Anomaly Zone' );
   str_camp_MissionMap [15] := str_camp_SetMapInfo('17.11.2145','DEIMOS'    ,'Anomaly Zone' );
   str_camp_MissionMap [16] := str_camp_SetMapInfo('18.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_MissionMap [17] := str_camp_SetMapInfo('18.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_MissionMap [18] := str_camp_SetMapInfo('20.11.2145','HELL'      ,'Portal valley');
   str_camp_MissionMap [19] := str_camp_SetMapInfo('21.11.2145','HELL'      ,'Unknown'      );
   str_camp_MissionMap [20] := str_camp_SetMapInfo('22.11.2145','HELL'      ,'Unknown'      );
   str_camp_MissionMap [21] := str_camp_SetMapInfo('21.11.2145','MARS'      ,'Hellas Area');
   str_camp_MissionMap [22] := str_camp_SetMapInfo('21.11.2145','MARS'      ,'Hellas Area');
   str_camp_MissionMap [23] := str_camp_SetMapInfo('22.11.2145','MARS'      ,'Hellas Area');  }

   {for i:=0 to LastMission do
   begin
      setlength(str_camp_MissionInfo[i],0);
      str_camp_infon[i]:=0;
   end; }

   ////   HELL #1 / Tutorial

   str_camp_SetMissionPlot(0,false,
'This planet looks terrifying: fire everywhere, molten lava, and eerie creatures. It is located far among thousands of other worlds belonging to a powerful galactic Empire. Everything here remained unchanged for many centuries after the conquest...');
   str_camp_SetMissionPlot(0,false,
'until suddenly the old teleporter, built by some ancient civilization, was activated. Technologically advanced aliens arrived from the portal, immediately starting to explore the new territory.');

   str_camp_SetMissionPlot(0,true ,
'You are one of the higher demons, whose calling is to lead the demonic army into battle. You were recently promoted to your current rank and have not yet had the chance to prove yourself.');
   str_camp_SetMissionPlot(0,false,
'Your first task is to study the aliens, infiltrate their world, and subjugate it to the will of the Empire.');

   str_camp_SetMissionPlot(0,true,
'The invaders have built a large camp near the Portal, and we don`t even have a small outpost in this region. It is necessary to quickly build a base, summon the army, and crush the violators!');

   str_camp_SetMissionPlot(0,true ,'- Reach 2000 energy level');
   str_camp_SetMissionPlot(0,false,'- Build 4 Demon`s Gates'  );
   str_camp_SetMissionPlot(0,false,'- Summon 30 Hell warriors');
   str_camp_SetMissionPlot(0,false,'- Do not lose Hell Keeps' );
   str_camp_SetMissionPlot(0,false,'- Destroy all intruder creatures');


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


   str_makeAllHints;
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
  //str_hint_hits              := 'Здоровье: ';
  //str_hint_BaseSightR            := 'Базовый радиус обзора: ';

  str_uarm_melee      := 'ближний бой';
  str_uarm_ranged     := 'дальний бой';
  str_uarm_zombie     := '+зомбификация';
  str_uarm_ressurect  := 'воскрешение';
  str_uarm_heal       := 'лечение/ремонт';
  str_uarm_spawn      := 'порождение';
  //str_uarm_suicide    := 'самоубийство';
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

  str_SetUpgrBaseHint(upgr_uac_DistDamage     ,'Улучшение Воружений'               ,'Увеличение урона от дальних атак всех юнитов и защитных сооружений');
  str_SetUpgrBaseHint(upgr_uac_BioArmor     ,'Улучшение Пехотной Брони'          ,'Увеличение защиты всех юнитов из Казарм'                     );
  str_SetUpgrBaseHint(upgr_uac_BuildArmor     ,'Бетонные Стены'                    ,'Увеличение защиты всех зданий'                               );
  str_SetUpgrBaseHint(upgr_uac_RepairTools      ,'Продвинутые Инструменты'           ,'Увеличение эффективности ремонта Инженера и лечения Медика'  );
  str_SetUpgrBaseHint(upgr_uac_BioSpeed     ,'Легковесная Броня'                 ,'Увеличение скорости передвижения всех юнитов из Казарм'      );
  str_SetUpgrBaseHint(upgr_uac_SSMWeapon      ,'Разрывные Пули'                    ,'Атака Сержанта, Старшего Сержанта и Терминатора чаще вызывают pain state' );
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

  {for i:=0 to LastMission do
  begin
     setlength(str_camp_MissionInfo[i],0);
     str_camp_infon[i]:=0;
  end;    }


  str_camp_SetMissionPlot(0,false,
'Эта планета выглядит устрашающе: повсюду огонь, раскаленная лава и жуткие существа. Она находится далеко среди тысяч других миров, принадлежащих могущественной галактической империи. Здесь все оставалось неизменным долгие столетия после завоевания...');
  str_camp_SetMissionPlot(0,false,
'пока вдруг не заработал старый телепортатор, построенный какой-то древней цивилизацией. Из портала прибыли технически развитые пришельцы, сразу занявшиеся изучением новой местности.');

  str_camp_SetMissionPlot(0,true ,
'Вы - один из высших демонов, чье призвание - вести в бой демоническое воинство. Вы не так давно были повышены до своего нынешнего ранга и еще не успели проявить себя.');
  str_camp_SetMissionPlot(0,false,
'Ваше первое задание - изучить пришельцев, проникнуть в их мир и подчинить его власти Империи.');

  str_camp_SetMissionPlot(0,true,
'Захватчики построили крупный лагерь около Портала, а у нас в этом регионе нет даже небольшого форпоста. Необходимо быстро построить базу, призвать армию и сокрушить нарушителей!');

  str_camp_SetMissionPlot(0,true ,'- Достичь уровня энергии 2000');
  str_camp_SetMissionPlot(0,false,'- Построить 4 Врат Демонов'  );
  str_camp_SetMissionPlot(0,false,'- Призвать 30 адских монстров');
  str_camp_SetMissionPlot(0,false,'- Адская Крепость должна уцелеть' );
  str_camp_SetMissionPlot(0,false,'- Уничтожить вторгшихся захватчиков');

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

  str_camp_MissionMap[0]         := tc_lime+'Дата:'+tc_default+tc_nl3+'15.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ФОБОС' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Аномалия';
  str_camp_MissionMap[1]         := tc_lime+'Дата:'+tc_default+tc_nl3+'16.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ФОБОС' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Кратер Халл';
  str_camp_MissionMap[2]         := tc_lime+'Дата:'+tc_default+tc_nl3+'15.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ДЕЙМОС'+tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Аномалия';
  str_camp_MissionMap[3]         := tc_lime+'Дата:'+tc_default+tc_nl3+'16.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ДЕЙМОС'+tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Кратер Свифт';
  str_camp_MissionMap[4]         := tc_lime+'Дата:'+tc_default+tc_nl3+'18.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'МАРС'  +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Равнина Хеллас';
  str_camp_MissionMap[5]         := tc_lime+'Дата:'+tc_default+tc_nl3+'19.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'МАРС'  +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Равнина Хеллас';
  str_camp_MissionMap[6]         := tc_lime+'Дата:'+tc_default+tc_nl3+'18.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ЗЕМЛЯ' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Неизвестно';
  str_camp_MissionMap[7]         := tc_lime+'Дата:'+tc_default+tc_nl3+'19.11.2145'+tc_nl3+tc_lime+'Место:'+tc_default+tc_nl3+'ЗЕМЛЯ' +tc_nl3+tc_lime+'Район:'+tc_default+tc_nl3+'Неизвестно';  }

  str_makeAllHints;
end;

procedure SwitchLanguage;
begin
  if(ui_language)
  then lng_rus
  else lng_eng;
end;



