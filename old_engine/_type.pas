
type

integer  = Smallint;
pinteger = ^integer;

TSob = set of byte;

TUnit = record
   mmx,mmy,mmr,
   fx,fy,fsr,
   vx,vy,
   x,y,
   anim,r,sr,ar,arf,anims,
   speed,dir,rld,trt,
   mhits,rld_a,rld_r,
   bld_s,
   hits,
   unum    : integer;

   renerg,
   _fr,
   foot,mdmg,
   generg,uf,
   _uclord,
   vstp,order,
   player,utrain,
   uid,max,shadow,
   ucl,
   ruid,rupgr     : byte;

   alrm_b  : boolean;
   alrm_x,
   alrm_y,
   alrm_r,
   tar1,
   tar1d,
   uo_tar,
   uo_x,
   uo_y    : integer;
   uo_id   : byte;

   inapc   : integer;
   painc,
   pains,
   apcc,
   apcm,
   apcs    : byte;

   _shcf   : single;

   buff    : array[0.._ubuffs] of integer;
   vsni,
   vsnt    : array[0..MaxPlayers] of integer;

   isbuild,
   mech,bld,solid,
   wanim,melee,
   sel     : boolean;
end;
PTUnit = ^TUnit;

upgrar = array[0.._uts] of byte;
Pupgrar = ^upgrar;


TPlayer = record
   name    : shortstring;

   army,team,
   race,state,
   bld_r,mrace,
   wbhero
           : byte;

   cenerg,
   menerg  : integer;

   ready   : boolean;

   o_id    : byte;
o_x0,o_y0,
o_x1,o_y1  :integer;

   u_e     : array[false..true,0.._uts] of byte;
   u_eb    : array[false..true,0.._uts] of byte;
   u_s     : array[false..true,0.._uts] of byte;
   u_c     : array[false..true] of byte;
   ubx     : array[0.._uts] of integer;
   uid_e,
   uid_b   : array[0..255 ] of byte;

   ai_pushpart,
   ai_maxarmy,
   ai_attack,
   ai_skill: byte;

   //cpupgr,
   a_upgr,
   a_build,
   a_units : cardinal;

   upgrinp,
   upgr    : upgrar;

   wb,bldrs,
   PNU     : byte;
   n_u,
   ttl     : integer;
   nip     : cardinal;
   nport   : word;
end;

TPList = array[0..MaxPlayers] of TPLayer;

TMissile = record
   x,y,vx,vy,dam,vst,tar,sr,dir,mtars,ntars:integer;
   player,mid,mf:byte;
end;

TCTPoint = record
   px,py,mpx,mpy,ct:integer;
   pl:byte;
end;

{$IFDEF _FULLGAME}

TBa = array[0..0] of byte;
TWa = array[0..0] of word;
TCa = array[0..0] of cardinal;

TSoc = set of char;

string6 = string[6];

TUSprite = record
   surf:pSDL_Surface;
   hw,hh:integer;
end;
PTUSprite = ^TUSprite;

TUSpriteL = array of TUSprite;
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


TAlarm = record
   ax,ay,at:integer;
   ab:boolean;
end;

{$ELSE}

{$ENDIF}

TDoodad = record
   x,y,r:integer;
   t:byte;

   {$IFDEF _FULLGAME}
   a,dpth,shh,
   mmx,mmy,mmr:integer;
   spr   :PTUSprite;
   mmc   :cardinal;
   {$ENDIF}
end;
PTDoodad = ^TDoodad;
TDCell = record
   n:integer;
   l:array of integer;
end;


