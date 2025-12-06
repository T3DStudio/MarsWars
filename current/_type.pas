
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

TStringList = array of shortstring;
PTStringList = ^TStringList;

////////////////////////////////////////////////////////////////////////////////
//
//   GRAPHIC
//

TMWTexture = record
   surf :pSDL_Surface;
   w,h,
   hw,hh:integer;
end;
PTMWTexture = ^TMWTexture;

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
PTMWSModel = ^TMWSModel;

TDecal = record
   decal_x,
   decal_y       : integer;
end;

TEID = record
   anim_smstate: byte;
   smodel      : PTMWSModel;
   smask       : cardinal;
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
   color    : cardinal;
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
   aura     : cardinal;
   alpha    : byte;
end;
PTVisSpr = ^TVisSpr;

 TIntList = array of integer;
PTIntList = ^TIntList;

TThemeAnim = record
   depth,
   xo,yo,
   sh,
   anext,
   atime:integer
end;
 TThemeAnimL = array of TThemeAnim;
PTThemeAnimL = ^TThemeAnimL;

TAlarm = record
   al_x,
   al_y,
   al_mx,
   al_my,
   al_r,
   al_t      : integer;
   al_v      : byte;
   al_c      : cardinal;
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

TMenuMessageBoxType = (mmbt_none,mmbt_nothing,mmbt_netPortBlock,mmbt_netWaitServer,mmbt_DeleteReplay,mmbt_DeleteSave,mmbt_SaveRewrite);

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
   ip       : cardinal;
   port     : word;
   info     : shortstring;
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
   ua_reload      : integer;
   ua_reload_upgr : byte;
   ua_reload_upgrS: integer;
   {$IFDEF _FULLGAME}
   ua_mbrush_r    : integer;
   ua_mbrush_hint : byte;
   ua_btn         : pSDl_Surface;
   ua_str_name,
   ua_str_Reqs,
   ua_str_Common,
   ua_str_Descript: shortstring;
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
   m_x,m_y,
   m_vx,m_vy,
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

TWUDataTime  = array[1..MaxUnits    ] of cardinal;
TWCPDataTime = array[0..LastKeyPoint] of byte;

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
  aw_eid_target_onlyshot:boolean;
  aw_eid_target,
  aw_eid_shot,
  aw_eid_start: byte;
  aw_AnimStay : byte;
  {$ENDIF}
end;
PTUWeapon = ^TUnitArms;

TUID = record
   uid_square,
   uid_MaxHits1,
   uid_MaxHitsh,
   uid_MaxHitsq     : longint;
   uid_BaseSpeed,
   uid_r,
   uid_missileR,
   uid_BaseSightR,
   uid_upgr_SightStep,
   uid_EnergyReq,
   uid_EnergyGen,
   uid_ProdTimeSec,
   uid_ProdTimeTick,
   uid_ProdHitStep,
   uid_PainC,
   uid_PainCUpgrStep,
   uid_zfall,
   uid_TransportSize,
   uid_TransportMax,
   uid_BaseRegen,
   uid_LimitUse,
   uid_LevelBonusDamage,
   uid_LevelBonusArmor
                    : integer;

   uid_ZombieHits   : integer;
   uid_ZombieUID    : byte;

   uid_upgr_SightR,
   uid_upgr_Armor,
   uid_upgr_Regen,
   uid_DeathMissile,
   uid_DeathMissile_dmod,
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
   uid_req_upgr     : byte;

   uid_CanAttack    : boolean;
   uid_arms_BonusAntiFlyRange,
   uid_arms_BonusAntiGroundRange,
   uid_arms_BonusAntiBuildingRange,
   uid_arms_BonusAntiUnitRange
                    : integer;
   uid_arms         : array[0..LastUnitArms] of TUnitArms;

   uid_hits_li2si   : single;

   uid_ability1,
   uid_ability2,
   uid_ability3
                    : byte;
   uid_ability_ishkeep,
   uid_ability_isradar,
   uid_ability_isteleport,
   uid_ability_isCanLiftUp
                    : boolean;

   uid_client_WReload,
   uid_client_WCastTarget,
   uid_NoOrderWhenCast,
   uid_HaveRallyPoint,
   uid_HaveAbility,
   uid_OutUnitsTeleBuff,
   uid_SlowTurn,
   uid_SplashResist,
   uid_isbuilding,
   uid_ismech,
   uid_islight,
   uid_isdetector,
   uid_isbuilder,
   uid_issmith,
   uid_isbarrack,
   uid_issolid,
   uid_isfly
                    : boolean;
   uid_FastDeathHits: integer;

   uid_prod_Buildings,
   uid_prod_Units,
   uid_prod_Upgrades,
   ups_TransportUIDs: TSoB;
   {$IFDEF _FULLGAME}
   uid_MiniMapR,
   uid_AnimStepFoot,
   uid_AnimStepDeath,
   uid_AnimStepWalk,
   uid_FogcR        : integer;
   uid_BTNBig,
   uid_BTNSmall     : TMWTexture;
   {$IFDEF UNITDATA}
   un_btn2          : TMWTexture;
   {$ENDIF}
   uid_SpriteModel  : array[0..LastUnitLevel] of pTMWSModel;

   uid_str_name,
   uid_str_BaseDescript,
   uid_str_FullDescript,
   uid_str_NameHK,
   uid_str_CostLimit,
   uid_str_DefaultAttr,
   uid_str_RebuildHint,
   uid_str_ArmsCommon,
   uid_str_Reqs,
   uid_str_Prod     : shortstring;
   uid_str_Arms     : array[0..LastUnitArms] of shortstring;

   uid_eid_BuildHellType
                    : boolean;
   uid_eid_bcrater
                    : byte;
   uid_eid_bcrater_y: integer;

   uid_eid_SummonSpr: array[0..LastUnitLevel] of PTMWTexture;
   uid_eid_Summon,
   uid_eid_DeathSlow,
   uid_eid_DeathFast,
   uid_eid_Pain
                    : array[0..LastUnitLevel] of byte;

   uid_snd_Foot,
   uid_snd_Summon,
   uid_snd_DeathSlow,
   uid_snd_DeathFast,
   uid_snd_Pain,

   uid_snd_ready, //command sounds
   uid_snd_move,
   uid_snd_attack,
   uid_snd_annoy,
   uid_snd_select   : PTSoundSet;
   {$ENDIF}
end;
PTUID = ^TUID;
TUPID = record  // upgrade
   upgr_ruid,
   upgr_rupgr,
   upgr_btni,
   upgr_race     : byte;
   upgr_renerg,
   upgr_renerg_xpl, // energy * per level
   upgr_renerg_apl, // energy + per level
   upgr_time,
   upgr_time_xpl,
   upgr_time_apl,
   upgr_max      : integer;
   upgr_mfrg     : boolean;

   {$IFDEF _FULLGAME}
   upgr_btn      : TMWTexture;

   upgr_str_Name,
   upgr_str_NameHK,
   upgr_str_Descript,
   upgr_str_Reqs : shortstring;
   {$ENDIF}
end;

TAIAlarm = record
   aia_enemy_base
                : boolean;
   aia_enemy_limit
                : longint;
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

TPlayerGameData = record
   name            : shortstring;

   team,
   race,mrace,
   state,
   pnum            : byte;

   build_cd,
   energyl_cur,
   energyl_max     : integer;
   armylimit
                   : longint;

   isobserver,
   isrevealed,
   isdefeated,
   isready         : boolean;

   o_id,
   o_a0            : byte;
   o_x0,o_y0,
   o_x1,o_y1       : integer;

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
   units_uid_u,    // one of
   units_uid_m     // max
                   : array[byte] of integer;

                   // units by isbuilding [building]
   units_bld_e,    // existed
   units_bld_s     : array[false..true] of integer; // selected
   units_bld_l     : array[false..true] of longint; // limit

   units_all_e,
   units_all_s,
   units_builders_e,
   units_builders_ec,
   units_builders_s,
   units_unitProds_ec,// 'barracks'
   units_unitProds_s,
   units_upgrProds_ec,// 'smiths'
   units_upgrProds_s
                   : integer;

   upgrs_cur,
   upgrs_max        : array[byte] of byte;

   prod_unit_Limit : longint;                           // current limit in production
   prod_unit_Max,                                       // current max unit productions
   prod_unit_Now   : integer;                           // current productions
   prod_unit_ucl,
   prod_unit_uid   : array[byte] of integer;

   prod_upgr_Max,
   prod_upgr_Now   : integer;
   prod_upgr_upid  : array[byte] of byte;

   a_rebuild,
   a_ability       : TSoB;

   log_l           : array[0..MaxPlayerLog] of TLogMes;
   log_i,
   log_n,
   log_n_cl
                   : cardinal;

   log_EnergyCheckTime
                   : integer;


   ai_max_ulimit,
   ai_maxcount_energy,
   ai_maxcount_mains,
   ai_maxcount_unitps,
   ai_maxcount_upgrps,
   ai_maxcount_tech0,
   ai_maxcount_tech1,
   ai_maxcount_tech2,
   ai_maxlimit_detect,
   ai_maxcount_spec1,
   ai_maxcount_spec2,
   ai_maxcount_towers,
   ai_mincount_towers,
   ai_maxlimit_blimit,
   ai_max_specialist,
   ai_attack_limit,
   ai_attack_delay,
   ai_scout_u_cur,
   ai_scout_u_cur_w,
   ai_scout_u_new,
   ai_scout_u_new_w,
   ai_detection_pause  : integer;
   ai_maxcount_upgrlvl : byte;
   ai_hptargets        : TSoB;
   ai_skill            : byte;
   ai_flags            : cardinal;
   ai_alarms           : array[0..LastPlayer] of TAIAlarm;
   ai_attack_timer,
   ai_scout_timer      : integer;
   ai_ReadyForAttack   : boolean;
end;
PTPlayerGameData = ^TPlayerGameData;
TPList = array[0..LastPlayer] of TPlayerGameData;

TPlayerNetData = record
   PNU     : byte;
   n_u,
   net_ping,
   net_ttl : word;
   net_ip  : cardinal;
   net_port: word;
   net_logsend_pause
           : integer;
end;

TUnitVisionData = array[0..LastPlayer] of integer;

TUnit = record
   hits     : longint;
   vx,vy,
   x,y,
   zfall,
   srange,
   speed,dir,
   rld,vstp,
   unum     : integer;
   mapZone  : word;

   level,
   cycle_order,
   group,
   playeri,
   uidi     : byte;

   uprod_r,
   pprod_r,
   pprod_e  : array[0..LastUnitLevel] of integer;
   uprod_u,
   pprod_u  : array[0..LastUnitLevel] of byte;

   a_exp,
   a_exp_next,
   a_shots  : cardinal;
   a_rld,
   a_weap_cl,
   a_weap   : byte;
   a_tx,a_ty,
   a_tar,
   a_tar_cl,

   move_x ,move_y,
   move_px,move_py,

   uo_x,
   uo_y,
   uo_bx,
   uo_by,
   uo_tar
            : integer;
   uo_id    : byte;

   rpoint_tar,
   rpoint_x,
   rpoint_y : integer;

   pains,
   transportU,
   transportM,
   transportC
            : integer;

   buffs    : array[0..LastUnitBuff] of integer;

   TeamDetection,
   TeamVision     : TUnitVisionData;

   StayWaitForNewTarget:byte;
   ukfly,
   ukfloater,
   solid,
   iscomplete,
   isselected      : boolean;

   aiu_FiledSquareNear,
   aiu_limitaround_ally,
   aiu_limitaround_enemy,
   aiu_need_detect
            : longint;
   aiu_alarm_timer,
   aiu_alarm_d,
   aiu_alarm_x,
   aiu_alarm_y
            : integer;

   {$IFDEF _FULLGAME}
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
   {$ENDIF}

   player   : PTPlayerGameData;
   uid      : PTUID;
end;
PTUnit = ^TUnit;
PPTUnit = ^PTUnit;

TKeyPoint = record
   kpx ,kpy ,
   kpSolidr,kpCaptureR,kpNoBuildR,
   kpToCenterD,
   kpmmx,kpmmy,kpmmr,
   kpEnergy,
   kpCaptureTime,
   kpTimer      : integer;
   kplifetime   : cardinal;
   kpTimerOwnerTeam,
   kpTimerOwnerPlayer,
   kpOwnerPlayer,
   kpOwnerTeam  : byte;
   kpzone       : word;
   kpunitst_pstate,
   kpUnitsTeam,
   kpunitsp_pstate,
   kpUnitsPlayer     : array[0..LastPlayer] of longint;
end;
pTKeyPoint = ^TKeyPoint;

TObstacle = record
   o_x,
   o_y,
   o_r    : integer;
   o_type : byte;

   {$IFDEF _FULLGAME}
   o_animn,
   o_animt,
   o_SpriteDepth,
   o_ShadowZ,
   o_OffsetX,
   o_OffsetY,
   o_mmx,
   o_mmy,
   o_mmr  : integer;
   o_mmc  : cardinal;
   o_FrontSprite,
   o_BackSprite : PTMWTexture;
   {$ENDIF}
end;
PTObstacle = ^TObstacle;
TObstacleCell = record
   oc_n:integer;
   oc_l:array of PTObstacle;
end;


