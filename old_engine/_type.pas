
type

integer  = Smallint;
pinteger = ^integer;

TSob = set of byte;
{$IFDEF _FULLGAME}
TSoc = set of char;

string6 = string[6];

TMWSprite = record
   surf:pSDL_Surface;
   w,h,
   hw,hh:integer;
end;
PTMWSprite = ^TMWSprite;

TUSpriteList  = array of TMWSprite;
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
   s        : PTMWSprite;
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

{$ENDIF}

TUWeapon = record
  aw_type,
  aw_rupgr,
  aw_ruid,
  aw_oid   : byte;
  aw_uids  : TSob;
  aw_tarf,
  aw_reqf  : cardinal;
  aw_range,
  aw_damage,
  aw_count,
  aw_rld   : byte;
  aw_rld_s : TSoB;
  {$IFDEF _FULLGAME}
  aw_rld_a : TSoB;
  aw_snd   : PTSoundSet;
  {$ENDIF}
end;

TUID = record
   _mhits,
   _speed,
   _r ,
   _srange,
   _arange,
   _max,
   _renerg,
   _generg,
   _btime,
   _bstep,
   _tprod,
   _painc,
   _apcs,
   _apcm,
   _animw,_animd,_animf
                : integer;
   _zombieid,
   _urace,
   _uf,
   _ucl,
   _ruid,
   _rupgr       : byte;

   _a_weap      : array[0..MaxUnitWeapons] of TUWeapon;

   _shcf        : single;

   _ability,
   _attack      : byte;
   _slowturn,
   _isbuilding,
   _isbuilder,
   _issmith,
   _isbarrack,
   _ismech,
   _issolid,
   _addon       : boolean;
   _fastdeath,                                   //[adv]
   _advanced    : array[false..true] of boolean; //[addon]

   ups_builder,
   ups_units,
   ups_upgrades,
   ups_apc      : TSoB;
   {$IFDEF _FULLGAME}
   _fr          : integer;
   un_btn,
   un_sbtn      : array[false..true] of TMWSprite;
   un_name,
   un_descr,
   un_hint      : shortstring;

   un_smodel    : array[false..true] of PTMWSModel;

   un_build_amode,
   un_eid_bcrater   :byte;
   un_eid_bcrater_y :integer;

   un_eid_ready,
   un_eid_death,
   un_eid_fdeath,
   un_eid_pain
               : array[false..true] of byte;
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
TUpgrade = record
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
   _up_btn   : TMWSprite;
   _up_name,
   _up_descr,
   _up_hint  : shortstring;
   {$ENDIF}
end;


TPlayer = record
   name    : shortstring;

   team,
   race,mrace,
   bld_r,state,
   pnum    : byte;

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
   x,y,
   srange,
   arange,
   speed,dir,rld,
   hits,
   unum     : integer;

   uf,
   uclord,
   vstp,order,
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
   a_tard,
   mv_x,mv_y,
   uo_bx,uo_by,
   uo_tar,
   uo_x,
   uo_y     : integer;
   uo_id    : byte;

   inapc,
   pains,
   apcm,
   apcc     : integer;

   buff     : array[0..MaxUnitBuffs] of integer;
   vsni,
   vsnt     : array[0..MaxPlayers] of integer;

   bld,
   solid,
   wanim,
   sel      : boolean;

   {$IFDEF _FULLGAME}
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

TMID = record

end;

TMissile = record
   x,y,
   vx,vy,
   dam,
   vst,
   tar,
   sr,
   dir,
   mtars,
   ntars    : integer;
   player,
   mid,mf   : byte;
end;

TCTPoint = record
   px,py,
   mpx,mpy,
   ct       : integer;
   pl       : byte;
end;

TDoodad = record
   x,y,r:integer;
   t:byte;

   {$IFDEF _FULLGAME}
   animn,animt,
   dpth,shh,ox,oy,
   mmx,mmy,mmr :integer;
   mmc         :cardinal;
   spr,
   pspr        :PTMWSprite;
   {$ENDIF}
end;
PTDoodad = ^TDoodad;
TDCell = record
   n:integer;
   l:array of PTDoodad;
end;


