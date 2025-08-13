
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
   source   :TALuint;
   volumevar:psingle;
end;
PTMWSoundSource   = ^TMWSoundSource;
TMWSoundSourceSet = record
   ssl: array of TMWSoundSource;
   ssn: integer;
end;
PTMWSoundSourceSet = ^TMWSoundSourceSet;

TMWSound = record
   sound  : TALuint;
end;
PTMWSound = ^TMWSound;

TSoundSet = record
   snds : array of PTMWSound;
   sndn,
   sndps: integer;
end;
PTSoundSet = ^TSoundSet;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

TMouseFocus = (mf_map=0,mf_MiniMap,mf_Tabs,mf_CtrlPanel);

TTabControlContent = (tcc_none=0,tcc_controls,tcc_observer,tcc_replay);

TInputKeyType = (ikt_keyboard=0,ikt_mouseb,ikt_mousew);

TTabBTNClickType = (pct_Left=0,pct_Right,pct_DLeft);

TInputKey = record
   ik_type  : TInputKeyType;
   ik_value : cardinal;
   ik_timer_twice,
   ik_timer_pressed
            : integer;
   ik_depend: byte;
end;

TReplayPos = record
   rp_fpos : int64;
   rp_gtick: cardinal;
end;

TMenuItem = record
   mi_x0,
   mi_y0,
   mi_x1,
   mi_y1,
   mi_xc,
   mi_yc   :integer;
   mi_charw:byte;
   mi_state:byte;
end;

TMenuMessage = record
   mm_time     : integer;
   mm_Caption,
   mm_Message,
   mm_Hint     : shortstring;
end;
pTMenuMessage = ^TMenuMessage;

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

TDamageMod = array[0..LastDamageModFactor] of record
  dm_factor : integer;  // 100 = x1
  dm_flags  : cardinal;
end;

TMID = record
   mid_base_damage,
   mid_base_splashr,
   mid_size,
   mid_speed       : integer;
   mid_noflycheck,
   mid_teamdamage  : boolean;
   mid_ystep,
   mid_homing      : byte;
   mid_nodamage    : TSoB;

   {$IFDEF _FULLGAME}
   ms_smodel       : PTMWSModel;
   ms_eid_fly_st   : integer;
   ms_eid_target_eff,
   ms_eid_fly,
   ms_eid_decal    : byte;
   ms_eid_death,
   ms_eid_death_cnt,
   ms_eid_death_r,
   ms_snd_death_ch : array[false..true] of byte;
   ms_snd_death    : array[false..true] of PTSoundSet;
   {$ENDIF}
end;

TMissile = record
   x,y,
   vx,vy,
   damage,
   vstep,hvstep,
   tar,
   dir,
   mtars,
   dtars    : integer;
   player,
   homing,
   dmod,
   mid      : byte;
   fake,
   mfe,mfs  : boolean;
   {$IFDEF _FULLGAME}
   ms_eid_bio_death: boolean;
   {$ENDIF}
end;

TWUDataTime  = array[1..MaxUnits] of cardinal;
TWCPDataTime = array[0..LastKeyPoint] of byte;

TUnitArms = record
  aw_type,
  aw_tarprior,
  aw_fakeshots,
  aw_rupgr,
  aw_rupgr_l,
  aw_ruid,
  aw_dupgr,
  aw_oid   : byte;
  aw_uids  : TSob;
  aw_tarf,
  aw_reqf  : cardinal;
  aw_x,
  aw_y,
  aw_dupgr_s,
  aw_max_range,
  aw_min_range,
  aw_count : integer;
  aw_dmod,
  aw_rld   : byte;
  aw_rld_s : TSoB;
  {$IFDEF _FULLGAME}
  aw_rld_a : TSoB;
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
   uid_speed,
   uid_r,
   uid_missileR,
   uid_SightR,
   uid_SightRUpgrStep,
   uid_EnergyReq,
   uid_EnergyGen,
   uid_ProdTimeSec,
   uid_ProdHitStep,
   uid_ProdTick,
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
   uid_rebuild_uid,
   uid_rebuild_ruid,
   uid_rebuild_rupgr,
   uid_rebuild_rupgrl,
   uid_DeathMissile,
   uid_DeathMissile_dmod,
   uid_DeathUID,
   uid_DeathUIDn,
   uid_race,
   uid_class,
   uid_req_uid1,
   uid_req_uid1n,
   uid_req_uid2,
   uid_req_uid2n,
   uid_req_uid3,
   uid_req_uid3n,
   uid_req_upgr,
   uid_req_upgrl    : byte;

   uid_CanAttack    : boolean;
   uid_arms_BonusAntiFlyRange,
   uid_arms_BonusAntiGroundRange,
   uid_arms_BonusAntiBuildingRange,
   uid_arms_BonusAntiUnitRange
                    : integer;
   uid_arms         : array[0..LastUnitArms] of TUnitArms;

   uid_hits_li2si   : single;

   uid_ability_ReqNoObstacles
                    : boolean;
   uid_ability,
   uid_ability_ReqUpgr,
   uid_ability_ReqUpgrl,
   uid_ability_ReqUID
                    : byte;

   uid_OutUnitsTeleBuff,
   uid_SlowTurn,
   uid_ukbuilding,
   uid_ukmech,
   uid_uklight,
   uid_detector,
   uid_isbuilder,
   uid_issmith,
   uid_isbarrack,
   uid_issolid,
   uid_ukfly,
   uid_SplashResist : boolean;
   uid_FastDeathHits
                    : integer;

   uid_prod_Buildings,
   uid_prod_Units,
   uid_prod_Upgrades,
   ups_TransportUIDs: TSoB;
   {$IFDEF _FULLGAME}
   uid_AnimStepWalk,
   uid_AnimStepDeath,
   uid_AnimStepFoot,
   uid_FogcR        : integer;
   uid_BTNBig,
   uid_BTNSmall     : TMWTexture;
   {$IFDEF UNITDATA}
   un_btn2      : TMWTexture;
   {$ENDIF}
   uid_SpriteModel  : array[0..LastUnitLevel] of pTMWSModel;

   uid_txt_name,
   uid_txt_BaseDescript,
   uid_txt_FullDescript,
   uid_txt_NameCostHK,
   uid_txt_Weapons,
   uid_txt_Reqs,
   uid_txt_Prod     : shortstring;

   uid_AnimBuildMode,
   uid_eid_bcrater
                    : byte;
   uid_eid_bcrater_y: integer;

   uid_eid_SummonSpr: array[0..LastUnitLevel] of PTMWTexture;
   uid_eid_Summon,
   uid_eid_Death,
   uid_eid_DeathFast,
   uid_eid_pain
                    : array[0..LastUnitLevel] of byte;

   uid_eid_snd_foot,
   uid_eid_snd_summon,
   uid_eid_snd_death,
   uid_eid_snd_fdeath,
   uid_eid_snd_pain,

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
   upgr_txt_name,
   upgr_txt_Descript,
   upgr_txt_Hint : shortstring;
   {$ENDIF}
end;

TAPMCounter = record
   APM_Time,
   APM_Current,
   APM_New       : cardinal;
   APM_Str       : shortstring;
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
   mtype,
   argt,
   argx         : byte;
   str          : shortstring;
   xi,yi        : integer;
   tick         : cardinal;
end;
PTLogMes = ^TLogMes;

TPlayer = record
   name    : shortstring;

   team,
   race,mrace,
   state,
   pnum    : byte;

   build_cd,
   army,
   cenergy,
   menergy : integer;
   armylimit
           : longint;

   observer,
   revealed,
   defeated,
   ready   : boolean;

   o_id    : byte;
o_a0,
o_x0,o_y0,
o_x1,o_y1  : integer;

   ucl_e,                                        // existed class
   ucl_eb,                                       // existed class bld=true and hits>0
   ucl_s,                                        // selected
   ucl_x   : array[false..true,byte] of integer; // first unit class

   uid_e,
   uid_eb,
   uid_s,
   uid_x   : array[byte] of integer;

   ucl_c,                                        // count buildings/units
   ucl_cs  : array[false..true] of integer;      // count selected buildings/units
   ucl_l   : array[false..true] of longint;      // limit buildings/units

   uprodl  : longint;                            // current limit in production
   uprodm,                                       // current max unit productions
   uproda  : integer;                            // current productions
   uprodc  : array[byte] of integer;
   uprodu  : array[byte] of integer;

   upprodm,
   upproda : integer;
   upprodu,
   upgr    : array[byte] of byte;

   a_rebuild,
   a_ability: TSoB;

   a_upgrs,
   a_units : array[byte] of integer;


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
   ai_detection_pause
           : integer;
   ai_maxcount_upgrlvl
           : byte;
   ai_hptargets
           : TSoB;
   ai_skill: byte;
   ai_flags: cardinal;
   ai_alarms
           : array[0..LastPlayer] of TAIAlarm;
   ai_attack_timer,
   ai_scout_timer
           : integer;
   ai_ReadyForAttack
           : boolean;


   s_all,
   e_builders,
   s_builders,
   s_barracks,
   s_smiths,
   n_builders,
   n_barracks,
   n_smiths
           : integer;

   prod_error_cndt: cardinal;
   prod_error_utp,
   prod_error_uid : byte;
   prod_error_x,
   prod_error_y   : integer;

   log_l   : array[0..MaxPlayerLog] of TLogMes;
   log_i,
   log_n,
   log_n_cl
           : cardinal;

   log_EnergyCheck
           : integer;
end;
PTPlayer = ^TPlayer;
TPList = array[0..LastPlayer] of TPLayer;

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
   pfzone   : word;

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

   mv_x,mv_y,
   mp_x,mp_y,

   uo_bx,uo_by,
   uo_tar,
   uo_x,uo_y
            : integer;
   uo_id    : byte;

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
   mmx,mmy,mmr,
   fx,fy,fsr,
   anim,animf,
   shadow
            : integer;
   lvlstr_w,  // weapon upgrades
   lvlstr_r,  // reload
   lvlstr_b,  // buffs
   lvlstr_l,  // level
   lvlstr_a,  // armor
   lvlstr_s   // other upgrs
            : string6;
   {$ENDIF}

   player   : PTPlayer;
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


