
type

integer  = Smallint;
pinteger = ^integer;

TSob  = set of byte;
PTSob = ^TSob;

{$IFDEF _FULLGAME}
TSoc = set of char;

string6 = string[6];

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

TVisSpr = record
   s        : PTMWTexture;
   x,y,xo,yo,
   ro,
   d,sh     : integer;
   rc,msk   : cardinal;
   inv      : byte;
   bar      : single;
   clu      : integer;
   cll,
   crl      : byte;
   cru      : string6;
   rct      : boolean;
end;
PTVisSpr = ^TVisSpr;

TAlarm = record
   ax,ay,at : integer;
   ab       : boolean;
end;

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

TMWSound = record
   sound  : pMIX_CHUNK;
   last_channel,
   ticks_length
          : integer;
end;
PTMWSound = ^TMWSound;

TSoundSet = record
   snds : array of PTMWSound;
   sndn,
   sndps: integer;
end;
PTSoundSet = ^TSoundSet;

TMID = record
   ms_smodel    : PTMWSModel;
   ms_eid_fly_st: integer;
   ms_snd_death_ch,
   ms_eid_fly,
   //ms_eid_death,
   ms_eid_decal : byte;
   ms_snd_death : PTSoundSet;
   ms_alt_death : boolean;
end;

{$ENDIF}

TUWeapon = record
  aw_type,
  aw_rupgr,
  aw_rupgr_l,
  aw_dupgr,
  aw_ruid,
  aw_oid   : byte;
  aw_uids  : TSob;
  aw_tarf,
  aw_reqf  : cardinal;
  aw_dupgr_s,
  aw_range,
  aw_count: integer;
  aw_rld   : byte;
  aw_rld_s : TSoB;
  {$IFDEF _FULLGAME}
  aw_rld_a : TSoB;
  aw_snd_target,
  aw_snd_shot,
  aw_snd_start: PTSoundSet;
  aw_eid_target,
  aw_eid_shot,
  aw_eid_start: byte;
  {$ENDIF}
end;

TUID = record
   _mhits,
   _speed,
   _r,_missile_r,
   _srange,
   _max,
   _renerg,
   _generg,
   _btime,
   _bstep,
   _tprod,
   _painc,
   _zfall,
   _apcs,
   _apcm,
   _zombie_hits
                : integer;

   _upgr_armor,
   _zombie_uid,
   _urace,
   _uf,
   _ucl,
   _ruid,
   _rupgr       : byte;

   _a_weap      : array[0..MaxUnitWeapons] of TUWeapon;

   _shcf        : single;

   _ability,
   _attack      : byte;
   _barrack_teleport,
   _slowturn,
   _isbuilding,
   _isbuilder,
   _issmith,
   _isbarrack,
   _ismech,
   _issolid,
   _addon       : boolean;
   //_fastdeath,                                   //[adv]
   _advanced    : array[false..true] of boolean; //[addon]
   _fastdeath_hits
                : array[false..true] of integer;

   ups_builder,
   ups_units,
   ups_upgrades,
   ups_apc      : TSoB;
   {$IFDEF _FULLGAME}
   _animw,_animd,
   _fr          : integer;
   un_btn,
   un_sbtn      : array[false..true] of TMWTexture;
   un_name,
   un_descr,
   un_hint      : shortstring;

   un_smodel    : array[false..true] of PTMWSModel;

   un_build_amode,
   un_eid_bcrater   :byte;
   un_eid_bcrater_y :integer;

   un_foot_anim : array[false..true] of integer;

   un_eid_ready,
   un_eid_death,
   un_eid_fdeath,
   un_eid_pain
                : array[false..true] of byte;
   un_eid_snd_foot,
   un_eid_snd_ready,
   un_eid_snd_death,
   un_eid_snd_fdeath,
   un_eid_snd_pain
                : array[false..true] of PTSoundSet;

   un_snd_ready, //command sounds
   un_snd_move,
   un_snd_attack,
   un_snd_annoy,
   un_snd_select
                : array[false..true] of PTSoundSet;
   {$ENDIF}
end;
PTUID = ^TUID;
TUPID = record
   _up_ruid,
   _up_rupgr,
   _up_btni,
   _up_race  : byte;
   _up_renerg,
   _up_time,
   _up_max   : integer;
   _up_addon,
   _up_mfrg  : boolean;

   {$IFDEF _FULLGAME}
   _up_btn   : TMWTexture;
   _up_name,
   _up_descr,
   _up_hint  : shortstring;
   {$ENDIF}
end;


TPlayer = record
   name    : shortstring;

   team,
   race,mrace,
   state,
   pnum    : byte;

   build_cd,
   army,
   cenerg,
   menerg  : integer;

   ready   : boolean;

   o_id,
   o_a0    : byte;
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

   ucl_c,                                           // count buildings/units
   ucl_cs  : array[false..true] of integer;         // count selected buildings/units

   uprodm,
   uproda  : integer;
   uprodc  : array[byte] of integer;
   uprodu  : array[byte] of integer;

   pprodm,
   pproda  : integer;
   pprodu,
   upgr    : array[byte] of byte;

   a_upgrs,
   a_units : array[byte] of integer;


   {ai_pushfrmi,
   ai_pushtimei,
   ai_pushtime
           : integer;
   ai_pushuids
           : TSoB;
   ai_pushmin,
   ai_towngrd,
   ai_maxunits
           : integer;
   ai_flags: cardinal;  }
   ai_skill: byte;


   s_builders,
   s_barracks,
   s_smiths,
   n_builders,
   n_barracks,
   n_smiths: integer;

   PNU     : byte;
   n_u,
   ttl     : integer;
   nip     : cardinal;
   nport   : word;
end;
PTPlayer = ^TPlayer;
TPList = array[0..MaxPlayers] of TPLayer;

TUnit = record
   vx,vy,
   x,y,zfall,
   srange,
   speed,dir,rld,vstp,
   hits,
   unum     : integer;

   uf,
   uclord,
   order,
   playeri,
   uidi     : byte;

   uprod_r,
   pprod_r  : array[0..MaxUnitProds] of integer;
   uprod_u,
   pprod_u  : array[0..MaxUnitProds] of byte;

   a_rld,
   a_weap   : byte;
   a_tx,
   a_ty,
   a_tar,
   mv_x,mv_y,
   uo_bx,uo_by,
   uo_tar,
   uo_x,
   uo_y     : integer;
   uo_id    : byte;

   inapc,
   painc,
   pains,
   apcm,
   apcc     : integer;

   buff     : array[0..MaxUnitBuffs] of integer;
   vsni,
   vsnt     : array[0..MaxPlayers] of integer;

   bld,
   solid,
   sel      : boolean;

   {$IFDEF _FULLGAME}

   wanim    : boolean;

   mmx,mmy,mmr,
   fx,fy,fsr,
   anim,animf,
   shadow
            : integer;
   {$ENDIF}

   player   : PTPlayer;
   uid      : PTUID;
end;
PTUnit = ^TUnit;
PPTUnit = ^PTUnit;

TMissile = record
   x,y,
   vx,vy,
   dam,
   vst,
   tar,
   sr,
   dir,
   ystep,
   mtars,
   ntars    : integer;
   player,
   mid,
   mfe,mfs  : byte;
   homing   : boolean;
end;

TCTPoint = record
   px,py,
   mpx,mpy,
   ct       : integer;
   pl       : byte;
end;

TDoodad = record
   x,y,r :integer;
   t     :byte;

   {$IFDEF _FULLGAME}
   animn,animt,
   dpth,shh,ox,oy,
   mmx,mmy,mmr :integer;
   mmc         :cardinal;
   spr,
   pspr        :PTMWTexture;
   {$ENDIF}
end;
PTDoodad = ^TDoodad;
TDCell = record
   n:integer;
   l:array of PTDoodad;
end;


