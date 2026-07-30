
type

////////////////////////////////////////////////////////////////////////////////
//
//   COMMON
//

TSob  = set of byte;
PTSob = ^TSob;

string4 = string[4];

{$IFDEF _FULLGAME}
TSoc = set of char;

string6 = string[6];

TStringArray = array of shortstring;
PTStringArray = ^TStringArray;

TUIStringList = record
   slist_l: TStringArray;
   slist_n: integer;
   slist_w: byte;
end;
PTUIStringList = ^TUIStringList;




////////////////////////////////////////////////////////////////////////////////
//
//   GRAPHIC
//

TMWColor = cardinal;
PTMWColor = ^TMWColor;

TPlayersColorScheme  = array[0..LastPlayer] of TMWColor;
PTPlayersColorScheme = ^TPlayersColorScheme;

TMWTexture = record
   surf :pSDL_Surface;
   w,h,
   hw,hh:integer;
end;
PTMWTexture = ^TMWTexture;

TFogTileSet = array[0..fog_TileSetSize] of pSDL_Surface;

TUSpriteList  = array of TMWTexture;
PTUSpriteList = ^TUSpriteList;

TMWSModel = record
   sm_spritesL   : TUSpriteList;
   sm_SelectionHW,
   sm_SelectionHH,
   sm_spritesLast,
   sm_spritesNum : integer;
   sm_kind       : byte;
end;
 PTMWSModel =  ^TMWSModel;
PPTMWSModel = ^PTMWSModel;

TDecal = record
   decal_x,
   decal_y       : integer;
end;

TEID = record
   anim_smstate: byte;
   smodel      : PTMWSModel;
   smask       : TMWColor;
end;

TEffect = record
   eid      : byte;
   x,y,z,d,
   anim_i,
   anim_last_i,
   anim_step,
   anim_last_i_t
            : integer;
end;

TVisPrim = record
   kind     : byte;
   sprite   : PTMWTexture;
   cx,cy,
   x0,y0,
   x1,y1    : integer;
   bcolor,
   color    : TMWColor;
   text_lt,
   text_lt2,
   text_rt,
   text_rd,
   text_ld  : string6;
end;

TVisSpr = record
   sprite   : PTMWTexture;
   x,y,xo,yo,
   depth,
   shadowz  : integer;
   shadowc,
   aura     : TMWColor;
   alpha    : byte;
end;
PTVisSpr = ^TVisSpr;

 TIntList = array of integer;
pTIntList = ^TIntList;

TThemeObstacleAnim = record
   toa_depth,
   toa_xo,
   toa_yo,
   toa_shadow,
   toa_anext,
   toa_atime:integer
end;
 TThemeObstacleAnimL = array of TThemeObstacleAnim;
//PTThemeObstacleAnimL = ^TThemeObstacleAnimL;

TThemeCircleStyle = (tcs_default=0,tcs_smooth,tcs_square);
TThemeAnimStyle   = (tas_liquid =0,tas_magma ,tas_noanim);

TLiquidTextureArray = array[1..LiquidAnimCount] of TMWTexture;
PTLiquidTextureArray = ^TLiquidTextureArray;

TAlarm = record
   al_x,
   al_y,
   al_mx,
   al_my,
   al_r,
   al_t      : integer;
   al_v      : byte;
   al_c      : TMWColor;
end;

TObstacleVis = record
   ov_animNext,
   ov_animTime,
   ov_SpriteDepth,
   ov_ShadowZ,
   ov_OffsetX,
   ov_OffsetY,
   ov_mmx,
   ov_mmy,
   ov_mmrO,
   ov_mmrI    : integer;
   ov_mmc     : TMWColor;
   ov_SpriteFront: PTMWTexture;
end;

TKeyPointVis = record
   kpmmx,
   kpmmy,
   kpmmr        : integer;
end;

TUnitVis = record
   wanim    : boolean;

   animw,
   mmx,mmy,
   fx,fy,fsr,
   anim,animf,
   shadowz
            : integer;
   lvlstr_w,  // weapon upgrades
   lvlstr_r,  // reload
   lvlstr_b,  // buffs
   lvlstr_l,  // level
   lvlstr_a,  // armor
   lvlstr_s   // other upgrs
            : string6;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SOUNDS
//

TMWSoundSource = record
   snd_src_source   :TALuint;
   snd_src_volumevar:psingle;
end;
PTMWSoundSource   = ^TMWSoundSource;
TMWSoundSourceSet = record
   snd_srcset_l: array of TMWSoundSource;
   snd_srcset_n: integer;
end;
PTMWSoundSourceSet = ^TMWSoundSourceSet;

TMWSound = record
   oal_sound: TALuint;
   oal_fname: shortstring;
end;
PTMWSound = ^TMWSound;

TSoundSet = record
   snd_sset_l: array of PTMWSound;
   snd_sset_n,
   snd_sset_c: integer;
end;
PTSoundSet = ^TSoundSet;
PPTSoundSet = ^PTSoundSet;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

TMouseFocus = (mf_map=0,mf_MiniMap,mf_Tabs,mf_CtrlPanel,mf_MenuPause);

TTabControlContent = (tcc_none=0,tcc_controls,tcc_observer,tcc_replay);

TInputKeyType = (ikt_keyboard=0,ikt_mouseb,ikt_mousew);

TTabBTNClickType = (pct_Left=0,pct_Right,pct_DLeft);

TActAState = (as_off=0,as_disabled,as_enabled);
TActKState = (ks_none=0,ks_pressed,ks_released,ks_both,ks_hold);

TInputKey = record
   ik_type   : TInputKeyType;
   ik_value  : cardinal;
   ik_timer_twice,
   ik_timer_pressed
             : integer;
   ik_astate : TActAState;
   ik_kstate : TActKState;
   ik_depend : byte;
   ik_str_HK : shortstring;
end;

TReplayPos = record
   rp_fpos   : int64;
   rp_gtick  : cardinal;
end;

TMenuItem = record
   mi_x0,
   mi_y0,
   mi_x1,
   mi_y1,
   mi_xc,
   mi_yc   : integer;
   mi_charw: byte;
   mi_state: TActAState;
end;

TMenuMessageBoxType = (mmbt_none,mmbt_nothing,mmbt_netPortBlock,mmbt_netWaitServer,mmbt_DeleteReplay,mmbt_DeleteSave,mmbt_DeleteServer,mmbt_SaveRewrite);

TSaveLoadItem = record
   data_p:pointer;
   data_s:cardinal;
end;

TUnitGroup = record
   ugroup_n,
   ugroup_d,
   ugroup_x,
   ugroup_y   : integer;
   ugroup_uids: array[boolean] of TSoB;
end;
pTUnitGroup = ^TUnitGroup;

TServerInfo = record
   si_manual  : boolean;
   si_ping,
   si_ip      : cardinal;
   si_ttl,
   si_port    : word;
   si_info,
   si_line    : shortstring;
end;

TCampaignData = record
   cd_byte1:byte;
end;

TAPMData = record
   apm_history_l: array[0..apm_period_ticks] of word;
   apm_history_p,
   apm_cur      : word;
end;

{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//
//   GAME
//

TCheckCollisionR = (cbr_no,cbr_mapSide,cbr_unit,cbr_cpoint,cbr_obstacle);
TCheckBuildArea  = (cba_inBuildArea,cba_noBuilders,cba_NoBuildArea,cba_outBuildArea);
TCheckBuildPlace = (cbp_good,cbp_noplace,cbp_out,cbp_unknown);

TUnitAbilityTargetType = (uat_none=0,uat_passive,uat_notarget,uat_point,uat_UnitAny,uat_UnitOwn,uat_UnitAlly,uat_UnitEnemy);

TUnitAbility = record
   ua_type        : TUnitAbilityTargetType;
   ua_req_upgr,
   ua_req_uid     : byte;
   ua_req_HellPower,
   ua_req_UACLoot,
   ua_reload      : integer;
   ua_rldDec_upgr : byte;
   ua_rldDec_upgrS,
   ua_rldDec_level: integer;
   ua_OrderToAll  : boolean;
   {$IFDEF _FULLGAME}
   ua_mbrush_r    : integer;
   ua_mbrush_hint : byte;
   ua_mbrush_hint_HalfProdTime
                  : boolean;
   ua_btn         : pSDl_Surface;
   ua_str_name,
   ua_str_Reqs,
   ua_str_ReqsUHint,
   ua_str_Common,
   ua_str_ReloadFactors,
   ua_str_Descript: shortstring;
   ua_HintinGame  : TUIStringList;
   {$ENDIF}
end;

TDamageMod = array[0..LastDamageModFactor] of record
  dm_Factor     : integer;  // 100 = x1
  dm_TargetFlags: cardinal;
end;

TMID = record
   mid_base_damage,
   mid_base_SplashR,
   mid_size,
   mid_speed        : integer;
   mid_noFlyCheck,
   mid_TeamDamage   : boolean;
   mid_ystep,
   mid_homing       : byte;
   mid_ImmuneUnits  : TSoB;

   {$IFDEF _FULLGAME}
   mid_SpriteModel  : PTMWSModel;
   mid_eid_FlyStep  : integer;
   mid_eid_target_eff,
   mid_eid_FlyTrace,
   mid_eid_Decal    : byte;
   mid_eid_death,
   mid_eid_DeathN,
   mid_eid_DeathR,
   mid_snd_DeathSkip: array[false..true] of byte;
   mid_snd_death    : array[false..true] of PTSoundSet;
   {$ENDIF}
end;

TMissile = record
   m_tox,m_toy,
   m_x,m_y,
   m_damage,
   m_vstep,m_hvstep,
   m_tar,
   m_dir,
   m_mtars,
   m_dtars    : integer;
   m_playeri,
   m_homing,
   m_dmod,
   m_mid      : byte;
   m_fake,
   m_mfe,
   m_mfs      : boolean;
   {$IFDEF _FULLGAME}
   m_eid_DeathType: boolean; // true = bio
   {$ENDIF}
end;

TWUDataTime = array[1..MaxUnits    ] of cardinal;

TUnitArms = record
  aw_type,
  aw_reload,
  aw_FakeShotsN  : byte;
  aw_ShotPoints  : TSoB;

  aw_object_id   : byte;
  aw_object_count: integer;

  aw_req_upgr,
  aw_req_uid     : byte;
  aw_req_flags   : cardinal;

  aw_tar_uids    : TSob;
  aw_tar_Flags   : cardinal;

  aw_impact_dmod,
  aw_impact_upgr : byte;
  aw_impact_upgrStep
                 : integer;

  aw_offset_x,
  aw_offset_y,
  aw_max_range,
  aw_min_range   : integer;

  {$IFDEF _FULLGAME}
  aw_AnimPoints  : TSoB;
  aw_snd_target,
  aw_snd_shot,
  aw_snd_start: PTSoundSet;
  aw_eid_target_onfire,
  aw_eid_target_onstart,
  aw_eid_target_onshot:boolean;
  aw_eid_target,
  aw_eid_shot,
  aw_eid_start: byte;
  aw_AnimStay : byte;
  {$ENDIF}
end;
PTUnitArm = ^TUnitArms;

TUID = record
   uid_MaxHits1,
   uid_MaxHitsh,
   uid_MaxHitsq          : longint;
   uid_r,
   uid_missileR,
   uid_req_HellPower,
   uid_req_UACLoot,
   uid_req_EnergyLevel,
   uid_bounty_HellPower,
   uid_bounty_UACLoot,
   uid_gen_EnergyLevel,
   uid_ProdTimeSec,
   uid_ProdTimeTick,
   uid_ProdHitStep,
   uid_TransportSize,
   uid_LimitUse,
   uid_LevelBonusDamage,
   uid_LevelBonusArmor,
   uid_LevelBonusPainC,
   uid_LevelBonusRegen   : integer;
   uid_LevelUpTimeTicks,
   uid_LevelUpTimeSecs   : cardinal;

   uid_zfall             : shortint;

   uid_ZombieHits        : integer;
   uid_ZombieUID         : byte;

   uid_TargetWeight,
   uid_AI_TargetWeight   : byte;
   uid_AI_GenAssaultGroup,
   uid_AI_Melee,
   uid_AI_Healer,
   uid_AI_Siedge         : boolean;
   uid_AI_NextFormUID    : byte;

   uid_DeathUID,
   uid_DeathUIDn,
   uid_race,
   uid_uibtn,
   uid_req_uid1,
   uid_req_uid1n,
   uid_req_uid2,
   uid_req_uid2n,
   uid_req_uid3,
   uid_req_uid3n,
   uid_req_upgr          : byte;

   uid_TransportMax_Base,
   uid_TransportMax_upgrV: integer;
   uid_TransportMax_upgr : byte;

   uid_PainState_Base,
   uid_PainState_upgrV   : integer;
   uid_PainState_upgr    : byte;

   uid_Regen_Base        : integer;
   uid_Regen_upgr        : byte;

   uid_Armor_upgr1,
   uid_Armor_upgr2       : byte;
   uid_Armor_upgrV       : integer;

   uid_MSpeed_Base       : integer;
   uid_MSpeed_upgrV,
   uid_MSpeed_upgr       : byte;

   uid_SightR_Base,
   uid_SightR_upgrV      : integer;
   uid_SightR_upgr       : byte;

   uid_CanAttackGround,
   uid_CanAttackAir,
   uid_CanAttack         : boolean;
   uid_arms_BonusAntiFlyRange,
   uid_arms_BonusAntiGroundRange,
   uid_arms_BonusAntiBuildingRange,
   uid_arms_BonusAntiUnitRange
                         : integer;
   uid_arms              : array[0..LastUnitArms] of TUnitArms;

   uid_hits_li2si        : single;

   uid_ability1,
   uid_ability2,
   uid_ability3
                         : byte;
   uid_ability_HKeepShift,
   uid_ability_isradar,
   uid_ability_RldReducByLvl,
   uid_ability_isteleport,
   uid_ability_isCanLiftUp
                         : boolean;

   uid_client_WReload,
   uid_NoOrderWhenCast,
   uid_FlyLevelLikeTarget,
   uid_HaveRallyPoint,
   uid_HaveAbility,
   uid_OutUnitsTeleBuff,
   uid_isbuilding,
   uid_ismech,
   uid_islight,
   uid_isdetector,
   uid_isbuilder,
   uid_isforge,
   uid_isbarrack,
   uid_issolid,
   uid_isfly
                         : boolean;
   uid_FastDeathHits     : integer;

   uid_balance_Good,
   uid_balance_Bad,
   uid_balance_Useless,

   uid_prod_Buildings,
   uid_prod_Units,
   uid_prod_Upgrades,
   ups_TransportUIDs     : TSoB;
   {$IFDEF _FULLGAME}
   uid_MiniMapR,
   uid_AnimStepFoot,
   uid_AnimStepDeath,
   uid_AnimStepWalk,
   uid_FogcR             : integer;
   uid_BTNBig,
   uid_BTNDoc,
   uid_BTNSmall          : TMWTexture;
   uid_SpriteModel       : array[0..LastUnitLevel] of pTMWSModel;

   uid_str_name,
   uid_str_BaseDescript,
   uid_str_1LineDescript,
   uid_str_HK,
   uid_str_NameHK,
   uid_str_CostLimit,
   uid_str_DefaultAttr,
   uid_str_ArmsCommon,
   uid_str_Reqs,
   uid_str_Prod,
   uid_str_balance_Good,
   uid_str_balance_Bad,
   uid_str_balance_Useless
                         : shortstring;
   uid_HintInGame,
   uid_HintDoc           : TUIStringList;

   uid_eid_BuildHellType,
   uid_eid_SprFloating
                         : boolean;
   uid_eid_bcrater
                         : byte;
   uid_eid_bcrater_y     : integer;

   uid_eid_SummonSpr     : array[0..LastUnitLevel] of PTMWTexture;
   uid_eid_Summon,
   uid_eid_DeathSlow,
   uid_eid_DeathFast     : array[0..LastUnitLevel] of byte;
   uid_eid_Pain          : byte;


   uid_snd_Foot,
   uid_snd_Summon,
   uid_snd_DeathSlow,
   uid_snd_DeathFast,
   uid_snd_Pain,

   uid_snd_ready, //command sounds
   uid_snd_move,
   uid_snd_attack,
   uid_snd_annoy,
   uid_snd_select        : PTSoundSet;
   {$ENDIF}
end;
PTUID = ^TUID;
TUpgrade = record  // upgrade
   upgr_ruid,
   upgr_rupgr,
   upgr_btni,
   upgr_race     : byte;
   upgr_renerg,
   upgr_renerg_xpl, // energy * per level
   upgr_renerg_apl, // energy + per level
   upgr_time,
   upgr_time_xpl,
   upgr_time_apl : integer;
   upgr_max      : byte;

   {$IFDEF _FULLGAME}
   upgr_btnBig   : TMWTexture;

   upgr_str_Name,
   upgr_str_NameHK,
   upgr_str_Descript,
   upgr_str_Reqs : shortstring;

   upgr_HintDoc  : TUIStringList;
   {$ENDIF}
end;

TAIAlarm = record
   aia_base     : boolean;
   aia_limit    : longint;
   aia_x,
   aia_y        : integer;
   aia_zone     : word;
end;

TLogMes = record
   lm_type,
   lm_data_t,
   lm_data_u    : byte;
   lm_string    : shortstring;
   lm_x,
   lm_y         : integer;
   lm_tick      : cardinal;
end;
PTLogMes = ^TLogMes;

TPlayerDataScore = record
   ps_name      : shortstring;
   ps_state     : byte;

   ps_units_created,
   ps_units_summoned,
   ps_units_resurected,
   ps_units_lost,
   ps_units_destroyed,

   ps_builds_created,
   ps_builds_lost,
   ps_builds_destroyed,

   ps_res_energy_max,
   ps_res_UACLoot,
   ps_res_HellPower

                : longint;
end;

TPlayerDataTemp = record
   PNU
                : byte;
   n_u,
   net_ping,
   net_ttl      : word;
   net_ip       : cardinal;
   net_port     : word;
   net_TimerLogSend
                : integer;
   net_wudata_t : TWUDataTime;
   net_kpoints_kpi
                : byte;

   o_id,
   o_a0         : byte;
   o_x0,o_y0,
   o_x1,o_y1    : integer;

   cam_x,
   cam_y,
   cam_w,
   cam_h        : integer;
end;

TPlayerDataGame = record
   name            : shortstring;

   team,
   race,mrace,
   state,
   pnum            : byte;

   build_cd,
   res_energyl_cur,
   res_energyl_max,
   res_HellPower,
   res_UACLoot

                   : integer;

   isobserver,
   isrevealed,
   isdefeated,
   isready         : boolean;

   units_uid_m     : array[byte] of integer;
   upgrs_cur,
   upgrs_max       : array[byte] of byte;

   a_ability       : TSoB;

   log_l           : array[0..MaxPlayerLog] of TLogMes;
   log_i,
   log_n,
   log_n_cl
                   : cardinal;

   log_EnergyCheckTimer
                   : integer;

   armylimit
                   : longint;

                   // units by class [building,ucl]
   units_ucl_e,    // existed
   units_ucl_c,    // completed
   units_ucl_s,    // selected
   units_ucl_u     // one of
                   : array[false..true,byte] of integer;

                   // units by uid   [uid]
   units_uid_e,    // existed
   units_uid_c,    // completed
   units_uid_s,    // selected
   units_uid_u     // one of
                   : array[byte] of integer;

                   // units by isbuilding [building]
   units_bld_e,    // existed
   units_bld_lc,
   units_bld_s     : array[false..true] of integer; // selected
   units_bld_l     : array[false..true] of longint; // limit

   units_all_e,
   units_all_c,
   units_all_s,
   units_builders_e,
   units_builders_c,  // builders
   units_builders_s,
   units_unitProds_c, // barracks
   units_unitProds_s,
   units_upgrProds_c, // forges
   units_upgrProds_s
                   : integer;

   prod_unit_Limit : longint;                           // current limit in production
   prod_unit_Max,                                       // current max unit productions
   prod_unit_Now   : integer;                           // current now in proggress
   prod_unit_ucl,
   prod_unit_uid   : array[byte] of integer;

   prod_upgr_Max,
   prod_upgr_Now   : integer;
   prod_upgr_upid  : array[byte] of byte;

   energyCur_BldOther,
   energyCur_BldGens,
   energyCur_units,
   energyCur_upgrades,
   energyCur_transforms
                   : integer;


   // operative AI data

   aip_timer_attack,
   aip_timer_detection,
   aip_timer_magic,
   aip_timer_superweapon
                       : integer;

   // settings
   aip_skill           : byte;
   aip_flags           : cardinal;

   aip_MaxEnergy,
   aip_MaxBuilders,
   aip_MaxBarracks,
   aip_MaxForges,
   aip_MaxDetectors,
   aip_MinTowers,
   aip_MaxTowers,
   aip_MaxSuper        : integer;
   aip_MaxAttackLimit,
   aip_MaxUnitLimit,
   aip_MaxUnitMinPart
                       : longint;
   aip_MaxUpgradeLevel
                       : byte;

   aip_pause_attack,
   aip_pause_detection,
   aip_pause_magic,
   aip_pause_superweapon
                       : integer;
end;
PTPlayerGameData = ^TPlayerDataGame;
TPList = array[0..LastPlayer] of TPlayerDataGame;

TUnitVisionData = array[0..LastPlayer] of integer;

TUnit = record
   hits          : longint;
   vx,vy,
   x,y,
   srange,
   speed,dir,
   rld,vstp,
   pains,
   unum          : integer;
   mapZone       : word;
   zfall         : shortint;

   level,
   cycle_order,
   group,
   playeri,
   uidi          : byte;

   uprod_r,
   pprod_r,
   pprod_e       : array[0..LastUnitLevel] of integer;
   uprod_u,
   pprod_u       : array[0..LastUnitLevel] of byte;

   transformUID  : byte;
   transformTimer: integer;

   a_exp,
   a_shots       : cardinal;
   a_rld,
   a_weap_cl,
   a_weap        : byte;
   a_tar,
   a_tar_cl,

   move_x ,move_y,
   move_px,move_py,

   uo_x,
   uo_y,
   uo_bx,
   uo_by,
   uo_tar        : integer;
   uo_id         : byte;

   rpoint_tar,
   rpoint_x,
   rpoint_y      : integer;


   transportU,
   transportM,
   transportC
                 : integer;

   buffs         : array[0..LastUnitBuff] of integer;

   TeamDetection,
   TeamVision    : TUnitVisionData;

   StayWaitForNewTarget:byte;
   isfly,
   iscomplete,
   isselected    : boolean;

   aiu_BuildAttempts:byte;
   aiu_limitaround_ally,
   aiu_limitaround_enemy
                 : longint;
   aiu_NeedDetect,
   aiu_alarm_timer,
   aiu_alarm_d,
   aiu_alarm_x,
   aiu_alarm_y
                 : integer;
   aiu_alarm_zone: word;

   player        : PTPlayerGameData;
   uid           : PTUID;
end;
PTUnit  = ^TUnit;
PPTUnit = ^PTUnit;

TKeyPointTeamData = record
   kptd_Active  : boolean;
   kptd_TimerOwnerTeam,
   kptd_TimerOwnerPlayer,
   kptd_OwnerPlayer,
   kptd_OwnerTeam
                : byte;
   kptd_VisTimer,
   kptd_Timer   : integer;
   kptd_lifeTime: cardinal;
end;
PTKeyPointTeamData = ^TKeyPointTeamData;

TKeyPoint = record
   kp_x,kp_y,
   kp_RCapture,
   kp_RNoBuild,
   kp_ToRoyalCD,
   kp_Energy,
   kp_CaptureTime : integer;
   kp_CaptureLimit: longint;
   kp_Zone        : word;
   kp_LimitTeamP,
   kp_LimitTeamC,
   kp_LimitPlayerP,
   kp_LimitPlayerC
                  : array[0..LastPlayer] of longint;
   kp_TeamData    : array[0..MaxPlayers] of TKeyPointTeamData;
end;
pTKeyPoint = ^TKeyPoint;
ppTKeyPoint = ^pTKeyPoint;

TObstacle = record
   o_x,
   o_y,
   o_rO,
   o_rM,
   o_rI  : integer;
   o_zone: word;
end;

PTObstacle = ^TObstacle;
TObstacleCell = record
   oc_n:integer;
   oc_l:array of PTObstacle;
end;


