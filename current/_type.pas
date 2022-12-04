
type

integer  = Smallint;
pinteger = ^integer;

TSob  = set of byte;
PTSob = ^TSob;


{$IFDEF _FULLGAME}
TSoc = set of char;

string6 = string[6];

////////////////////////////////////////////////////////////////////////////////
//
//   GRAPHIC
//

TColor = record
   r,g,b,a:byte;
   c      :cardinal;
end;
PTColor = ^TColor;

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
PTVisPrim = ^TVisPrim;
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

TMIDEffects = record
   ms_smodel       : PTMWSModel;
   ms_eid_fly_st   : integer;
   ms_eid_fly,
   ms_eid_decal    : byte;
   ms_eid_death,
   ms_eid_death_cnt,
   ms_eid_death_r,
   ms_snd_death_ch : array[false..true] of byte;
   ms_snd_death    : array[false..true] of PTSoundSet;
end;

{$ENDIF}

TUWeapon = record
  aw_type,
  aw_tarprior,
  aw_fakeshots,
  aw_rupgr,
  aw_rupgr_l,
  aw_dupgr,
  aw_ruid,
  aw_oid   : byte;
  aw_uids  : TSob;
  aw_tarf,
  aw_reqf  : cardinal;
  aw_x,
  aw_y,
  aw_dupgr_s,
  aw_max_range,
  aw_min_range,
  aw_count: integer;
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
  {$ENDIF}
end;

TUID = record
   _hmhits,
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
   _painc_upgr,
   _zfall,
   _apcs,
   _apcm,
   _base_armor,
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
   _replace_uid,
   _replace_ruid,
   _replace_rpuid,
   _zombie_uid,
   _death_missile,
   _urace,
   _ucl,
   _ruid1,
   _ruid1n,
   _ruid2,
   _ruid2n,
   _ruid3,
   _ruid3n,
   _rupgr,
   _rupgrn      : byte;

   _shots2advanced
                : byte;

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
   _isbuilder,
   _issmith,
   _isbarrack,
   _issolid,
   _ukfly,
   _buildonobs,
   _splashresist: boolean;
   _fastdeath_hits
                : integer;

   ups_builder,
   ups_units,
   ups_upgrades,
   ups_apc      : TSoB;
   {$IFDEF _FULLGAME}
   _animw,
   _animd,
   _fr          : integer;
   un_btn,
   un_sbtn      : TMWTexture;
   un_smodel    : array[0..MaxUnitLevel] of PTMWSModel;

   un_txt_name,
   un_txt_descr,
   un_txt_uihint: shortstring;

   un_build_amode,
   un_eid_bcrater
                : byte;
   un_eid_bcrater_y,
   un_foot_anim : integer;

   un_eid_summon,
   un_eid_death,
   un_eid_fdeath,
   un_eid_pain
                : byte;

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
   _up_race  : byte;
   _up_renerg,
   _up_renerg_xpl, // energy * per level
   _up_renerg_apl, // energy + per level
   _up_time,
   _up_time_xpl,
   _up_time_apl,
   _up_max   : integer;
   _up_mfrg  : boolean;

   {$IFDEF _FULLGAME}
   _up_btn   : TMWTexture;
   _up_name,
   _up_descr,
   _up_hint  : shortstring;
   {$ENDIF}
end;

TAIAlarm = record
   aia_enemy_base :boolean;
   aia_enemy_count,
   aia_x,
   aia_y    : integer;
   aia_zone : word;
end;

TLogMes = record
   mtype,
   uidt,
   uid  :byte;
   str  :shortstring;
   x,y  :integer;
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
   armylimit,
   cenergy,
   menergy : integer;

   ready   : boolean;

   o_id    : byte;
o_a0,
o_x0,o_y0,
o_x1,o_y1  :integer;

   ucl_e,                                        // existed class
   ucl_eb,                                       // existed class bld=true and hits>0
   ucl_s,                                        // selected
   ucl_x   : array[false..true,byte] of integer; // first unit class

   uid_e,
   uid_eb,
   uid_s,
   uid_x   : array[byte] of integer;

   ucl_c,                                        // count buildings/units
   ucl_l,                                        // limit buildings/units
   ucl_cs  : array[false..true] of integer;      // count selected buildings/units

   uprodm,                                       // current max unit productions
   uprodl,                                       // current limit in production
   uproda  : integer;                            // current productions
   uprodc  : array[byte] of integer;
   uprodu  : array[byte] of integer;

   upprodm,
   upproda : integer;
   upprodu,
   upgr    : array[byte] of byte;

   a_upgrs,
   a_units : array[byte] of integer;


   ai_max_ulimit,
   ai_max_energy,
   ai_max_mains,
   ai_max_unitps,
   ai_max_upgrps,
   ai_max_tech0,
   ai_max_tech1,
   ai_max_detect,
   ai_max_spec1,
   ai_max_spec2,
   ai_max_towers,
   ai_min_towers,
   ai_max_blimit,
   ai_max_specialist,
   ai_attack_limit,
   ai_attack_pause,
   ai_scout_u_cur,
   ai_scout_u_cur_w,
   ai_scout_u_new,
   ai_scout_u_new_w,
   ai_detection_pause
           : integer;
   ai_max_upgrlvl
           : byte;
   ai_hptargets
           : TSoB;
   ai_skill: byte;
   ai_flags: cardinal;
   ai_alarms
           : array[0..MaxPlayers] of TAIAlarm;


   s_builders,
   s_barracks,
   s_smiths,
   n_builders,
   n_barracks,
   n_smiths: integer;

   PNU     : byte;
   n_u,
   ttl     : word;
   nip     : cardinal;
   nport   : word;

   prod_error_cndt: cardinal;
   prod_error_x,
   prod_error_y,
   prod_error_utp,
   prod_error_uid : byte;

   net_logsend_pause
           : integer;
   log_l   : array[0..MaxPlayerLog] of TLogMes;
   log_i,
   log_n,
   log_n_cl
           : cardinal;
end;
PTPlayer = ^TPlayer;
TPList = array[0..MaxPlayers] of TPLayer;

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

   inapc,
   painc,
   pains,
   apcm,
   apcc     : integer;

   buff     : array[0..MaxUnitBuffs] of integer;
   vsni,
   vsnt     : array[0..MaxPlayers] of integer;

   StayWaitForNextTarget:byte;
   ukfly,
   isbuildarea,
   ukfloater,
   bld,
   solid,
   sel      : boolean;

   aiu_armyaround_ally,
   aiu_armyaround_enemy,
   aiu_need_detect,
   aiu_attack_timer,
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
   lvlstr_w,
   lvlstr_r,
   lvlstr_b,
   lvlstr_l,
   lvlstr_a,
   lvlstr_s : string6;
   {$ENDIF}

   player   : PTPlayer;
   uid      : PTUID;
end;
PTUnit = ^TUnit;
PPTUnit = ^PTUnit;

TMissile = record
   x,y,
   vx,vy,
   damage,
   vstep,hvstep,vsteps,
   tar,
   splashr,
   dir,
   ystep,
   mtars,
   ntars    : integer;
   player,
   homing,
   mid      : byte;
   fake,
   mfe,mfs  : boolean;
   {$IFDEF _FULLGAME}
   ms_eid_bio_death: boolean;
   {$ENDIF}
end;

TCTPoint = record
   cpx ,cpy ,cpsolidr,cpCapturer,cpnobuildr,
   cpmx,cpmy,cpmr,
   cpenergy,
   cpCaptureTime,
   cpTimer      : integer;
   cplifetime   : cardinal;
   cpTimerOwnerTeam,
   cpTimerOwnerPlayer,
   cpOwnerPlayer,
   cpOwnerTeam     : byte;
   cpzone       : word;
   cpunitst_pstate,
   cpUnitsTeam,
   cpunitsp_pstate,
   cpUnitsPlayer     : array[0..MaxPlayers] of integer;
end;

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


