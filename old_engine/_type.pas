
type

integer  = Smallint;
pinteger = ^integer;

TSob = set of byte;
PTSoB = ^TSob;

upgrar = array[0.._uts] of byte;
Pupgrar = ^upgrar;

TPlayer = record
   name    : shortstring;

   army,team,
   race,state,
   bld_r,mrace,
   pnum
           : byte;

   cenerg,
   menerg  : integer;

   ready   : boolean;

   o_id    : byte;
o_x0,o_y0,
o_x1,o_y1  :integer;

   ucl_e,                                           // existed class
   ucl_eb,                                          // existed class bld=true and hits>0
   ucl_s   : array[false..true,0.._uts] of integer; // selected
   ucl_x   : array[0.._uts] of integer;             // first unit class

   uid_e,
   uid_eb,
   uid_s,
   uid_x   : array[0..255 ] of integer;

   ucl_c,                                           // count buildings/units
   ucl_cs  : array[false..true] of integer;         // count selected buildings/units

   uprodc  : array[0.._uts] of integer;
   uprodu  : array[0..255 ] of integer;
   uprodm,
   uproda  : integer;

   pprodm,
   pproda  : integer;
   upgrinp,
   upgr    : upgrar;

   a_upgr,
   a_build,
   a_units : cardinal;


   ai_pushfrmi,
   ai_pushtimei,
   ai_pushtime
           : integer;
   ai_pushuids
           : TSoB;
   ai_pushmin,
   ai_towngrd,
   ai_maxunits
           : integer;
   ai_flags: cardinal;
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
   mmx,mmy,mmr,
   fx,fy,fsr,
   vx,vy,
   x,y,
   anim,r,sr,ar,arf,anims,
   speed,dir,rld_t,trt,
   mhits,rld_a,rld_r,
   bld_s,
   hits,
   unum     : integer;

   renerg,
   _fr,
   foot,mdmg,
   generg,uf,
   _uclord,
   vstp,order,
   playeri,
   uid,max,
   shadow,
   ucl,
   ruid,rupgr
            : byte;

   uprod_r,
   pprod_r  : array[0..MaxUnitProds] of integer;
   uprod_t,
   pprod_t  : array[0..MaxUnitProds] of byte;

   alrm_b   : boolean;
   alrm_x,
   alrm_y,
   alrm_r,
   tar1,
   tar1d,
   mv_x,mv_y,
   uo_bx,uo_by,
   uo_tar,
   uo_x,
   uo_y     : integer;
   uo_id    : byte;

   inapc    : integer;
   painc,
   pains,
   apcc,
   apcm,
   apcs     : byte;

   _shcf    : single;

   buff     : array[0.._ubuffs] of integer;
   vsni,
   vsnt     : array[0..MaxPlayers] of integer;

   isbuild,
   isbuilder,
   issmith,
   isbarrack,
   mech,bld,solid,
   wanim,melee,
   sel      : boolean;

   player   : PTPlayer;
end;
PTUnit = ^TUnit;

TMissile = record
   x,y,vx,vy,dam,vst,tar,sr,dir,mtars,ntars:integer;
   player,mid,mf:byte;
end;

TCTPoint = record
   px,py,mpx,mpy,ct:integer;
   pl:byte;
end;

{$IFDEF _FULLGAME}
TSoc = set of char;

string6 = string[6];

TMWSprite = record
   surf:pSDL_Surface;
   w,h,
   hw,hh:integer;
end;
PTMWSprite = ^TMWSprite;

TUSpriteL = array of TMWSprite;
PTUSpriteL = ^TUSpriteL;

TTDec = record
   x,y:integer;
end;

TEff = record
   x,y,t,t2,tm,d,anl,ans:integer;
   e:byte;
end;

TVisSpr = record
   s     : PSDL_Surface;
   x,y,ro,
   d,sh  : integer;
   rc,msk: cardinal;
   inv   : byte;
   bar   : single;
   clu   : integer;
   cll,
   crl   : byte;
   cru   : string6;
   rct   : boolean;
end;
PTVisSpr = ^TVisSpr;

TAlarm = record
   ax,ay,at:integer;
   ab:boolean;
end;

TIntList = array of integer;
PTIntList = ^TIntList;

TThemeAnim = record
   xo,yo,
   sh,
   anext,
   atime:integer
end;
TThemeAnimL = array of TThemeAnim;
PTThemeAnimL = ^TThemeAnimL;

{$ELSE}

{$ENDIF}

TDoodad = record
   x,y,r:integer;
   t:byte;

   {$IFDEF _FULLGAME}
   animn,animt,
   dpth,shh,ox,oy,
   mmx,mmy,mmr :integer;
   spr,
   pspr        :PTMWSprite;
   mmc         :cardinal;
   {$ENDIF}
end;
PTDoodad = ^TDoodad;
TDCell = record
   n:integer;
   l:array of PTDoodad;
end;


