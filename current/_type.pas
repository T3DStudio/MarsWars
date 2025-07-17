
type
TSob  = set of byte;
PTSob = ^TSob;


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
   surf:pSDL_Surface;
   w,h,
   hw,hh:integer;
end;
PTMWTexture = ^TMWTexture;

TUSpriteList  = array of TMWTexture;
PTUSpriteList = ^TUSpriteList;

TMWSModel = record
   sl       : TUSpriteList;
   sel_hw,
   sel_hh,
   sk,
   sn       : integer;
   mkind    : byte;
end;
PTMWSModel = ^TMWSModel;

TDecal = record
   x,y      : integer;
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
//PTVisPrim = ^TVisPrim;

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

TReplayPos = record
   rp_fpos : int64;
   rp_gtick: cardinal;
end;

{$ENDIF}

TDamageMod = array[0..MaxDamageModFactors] of record
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
TWCPDataTime = array[1..MaxCPoints] of byte;

TUWeapon = record
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
PTUWeapon = ^TUWeapon;

TUID = record
   _square,
   _hmhits,
   _hhmhits,
   _mhits       : longint;
   _speed,
   _r,_missile_r,
   _srange,
   _renergy,
   _genergy,
   _btime,
   _bstep,
   _tprod,
   _painc,
   _painc_upgr_step,
   _zfall,
   _transportS,
   _transportM,
   //_base_armor,
   _baseregen,
   _zombie_hits,
   _upgr_srange_step,
   _limituse,
   _level_damage,
   _level_armor
                : integer;

   _upgr_srange,
   _upgr_armor,
   _upgr_regen,
   _rebuild_uid,
   //_rebuild_level,
   _rebuild_ruid,
   _rebuild_rupgr,
   _rebuild_rupgrl,
   _zombie_uid,
   _death_missile,
   _death_missile_dmod,
   _death_uid,
   _death_uidn,
   _urace,
   _ucl,
   _ruid1,
   _ruid1n,
   _ruid2,
   _ruid2n,
   _ruid3,
   _ruid3n,
   _rupgr,
   _rupgrl      : byte;

   _shots2advanced
                : byte;

   _a_BonusAntiFlyRange,
   _a_BonusAntiGroundRange,
   _a_BonusAntiBuildingRange,
   _a_BonusAntiUnitRange
                : integer;
   _a_weap      : array[0..MaxUnitWeapons] of TUWeapon;

   _shcf        : single;

   _ability_no_obstacles
                : boolean;
   _ability,
   _ability_rupgr,
   _ability_rupgrl,
   _ability_ruid,
   _attack      : byte;
   _barrack_teleport,
   _slowturn,
   _ukbuilding,
   _ukmech,
   _uklight,
   _detector,
   _isbuilder,
   _issmith,
   _isbarrack,
   _issolid,
   _ukfly,
   _splashresist: boolean;
   _fastdeath_hits
                : integer;

   ups_builder,
   ups_units,
   ups_upgrades,
   ups_transport      : TSoB;
   {$IFDEF _FULLGAME}
   _animw,
   _animd,
   _fr          : integer;
   un_btn,
   un_sbtn      : TMWTexture;
   {$IFDEF UNITDATA}
   un_btn2      : TMWTexture;
   {$ENDIF}
   un_smodel    : array[0..MaxUnitLevel] of PTMWSModel;

   un_txt_name,
   un_txt_udescr,
   un_txt_fdescr,
   un_txt_uihint1,
   un_txt_uihint2,
   un_txt_uihint3,
   un_txt_uihint4,
   un_txt_uihintS
                : shortstring;

   un_build_amode,
   un_eid_bcrater
                : byte;
   un_eid_bcrater_y,
   un_foot_anim : integer;

   un_eid_summon_spr
                : array[0..MaxUnitLevel] of PTMWTexture;
   un_eid_summon,
   un_eid_death,
   un_eid_fdeath,
   un_eid_pain
                : array[0..MaxUnitLevel] of byte;

   un_eid_snd_foot,
   un_eid_snd_summon,
   un_eid_snd_death,
   un_eid_snd_fdeath,
   un_eid_snd_pain,

   un_snd_ready, //command sounds
   un_snd_move,
   un_snd_attack,
   un_snd_annoy,
   un_snd_select
                : PTSoundSet;
   {$ENDIF}
end;
PTUID = ^TUID;
TUPID = record  // upgrade
   _up_ruid,
   _up_rupgr,
   _up_btni,
   _up_race     : byte;
   _up_renerg,
   _up_renerg_xpl, // energy * per level
   _up_renerg_apl, // energy + per level
   _up_time,
   _up_time_xpl,
   _up_time_apl,
   _up_max      : integer;
   _up_mfrg     : boolean;

   {$IFDEF _FULLGAME}
   _up_btn      : TMWTexture;
   _up_name,
   _up_descr,
   _up_hint     : shortstring;
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
           : array[0..MaxPlayers] of TAIAlarm;
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

   PNU     : byte;
   n_u,
   ttl     : word;
   nip     : cardinal;
   nport   : word;

   prod_error_cndt: cardinal;
   prod_error_utp,
   prod_error_uid : byte;
   prod_error_x,
   prod_error_y   : integer;

   net_logsend_pause
           : integer;
   log_l   : array[0..MaxPlayerLog] of TLogMes;
   log_i,
   log_n,
   log_n_cl
           : cardinal;

   log_EnergyCheck
           : integer;
end;
PTPlayer = ^TPlayer;
TPList = array[0..MaxPlayers] of TPLayer;

TUnitVisionData = array[0..MaxPlayers] of integer;

TUnit = record
   hits     : longint;
   vx,vy,
   x,y,
   zfall,
   srange,
   speed,dir,rld,vstp,
   unum     : integer;
   pfzone   : word;

   level,
   cycle_order,
   group,
   playeri,
   uidi     : byte;

   uprod_r,
   pprod_r,
   pprod_e  : array[0..MaxUnitLevel] of integer;
   uprod_u,
   pprod_u  : array[0..MaxUnitLevel] of byte;

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

   transport,
   pains,
   transportM,
   transportC
            : integer;

   buff     : array[0..MaxUnitBuffs] of integer;

   vsni,
   vsnt     : TUnitVisionData;

   StayWaitForNewTarget:byte;
   ukfly,
   ukfloater,
   iscomplete,
   solid,
   sel      : boolean;

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

TCTPoint = record
   cpx ,cpy ,
   cpsolidr,cpCaptureR,cpNoBuildR,
   cp_ToCenterD,
   cpmx,cpmy,cpmr,
   cpenergy,
   cpCaptureTime,
   cpTimer      : integer;
   cplifetime   : cardinal;
   cpTimerOwnerTeam,
   cpTimerOwnerPlayer,
   cpOwnerPlayer,
   cpOwnerTeam  : byte;
   cpzone       : word;
   cpunitst_pstate,
   cpUnitsTeam,
   cpunitsp_pstate,
   cpUnitsPlayer     : array[0..MaxPlayers] of longint;
end;
PTCTPoint = ^TCTPoint;

TDoodad = record
   x,y,r :integer;
   t     :byte;

   {$IFDEF _FULLGAME}
   animn,animt,
   depth,shadowz,ox,oy,
   mmx,mmy,mmr :integer;
   mmc         :cardinal;
   sprite,
   back_sprite :PTMWTexture;
   {$ENDIF}
end;
PTDoodad = ^TDoodad;
TDCell = record
   n:integer;
   l:array of PTDoodad;
end;


