
type

integer  = Smallint;
pinteger = ^integer;

TSob  = set of byte;

{$IFDEF _FULLGAME}
TSoc  = set of char;

TBa = array[0..0] of byte;
TWa = array[0..0] of word;
TCa = array[0..0] of cardinal;

PTSob = ^TSob;
string6 = string[6];
{$ENDIF}

TDoodad = record
   x,y,
   r,
   t
   {$IFNDEF _FULLGAME}
   :integer;
   {$ELSE}
   ,shd,anim,
   mmx,mmy,mmr,
   dpth,a:integer;
   mmc   :cardinal;
   xas   :boolean;
   {$ENDIF}
end;
PTDoodad = ^TDoodad;
TDCell = record
   n:integer;
   l:array of integer;
end;

TOID = record
   rtaru   : TSob;
   rtar    : word;
   rupgr,
   ruid,
   rmana   : byte;
   toall,
   r2attack,
   cattack,
   cauto,
   rspd,
   rulimit,
   rnbld   : boolean;
   {$IFDEF _FULLGAME}
   _oidi,
   _obtnx,
   _obtny  : byte;
   _omarc  : cardinal;
   _obtn   : pSDL_Surface;
   _okey1,
   _okey2,
   _okey3  : cardinal;
   _oname,
   _odesc,
   _okeyc,
   _ohint,
   _okhnb  : shortstring;
   {$ENDIF}
end;

TUWeapon = record
  aw_type,
  aw_req,
  aw_rupgr,
  aw_ruid,
  aw_order,
  aw_mid   : byte;
  aw_taru  : TSob;
  aw_tar   : word;
  aw_rng,
  aw_mdmg,
  aw_rlds,
  aw_rldt  : integer;
  {$IFDEF _FULLGAME}
  aw_rlda  : integer;
  aw_snd   : pMIX_CHUNK;
  {$ENDIF}
end;

TUID = record
   _r,_srng,
   _mspeed,
   _mhits,
   _bldstep,
   _ctime,
   _zfall
   :integer;

   _urace,
   _ruid,
   _rupgr,
   _max,
   _uf,
   _generg,_renerg,
   _painc,
   _apcm,_apcs
            :byte;

   _apcuids,
   _orders  :TSob;

   _shcf    :single;

   _a_weap  :array[0..MaxAttacks] of TUWeapon;

   _itattack:byte;
   _fastturn,
   _fdeath,
   _itbuilder,
   _itbarea,
   _itwarea,
   _itbuild,
   _itmech,
   _itbarrack,
   _itsmith,
   _solid   :boolean;

   {$IFDEF _FULLGAME}
   _ueffsnds : array[false..true,0.._ueffs_ctypen-1,0..MaxUIDSnds-1] of pMIX_CHUNK;
   _ueffsndn : array[false..true,0.._ueffs_ctypen-1] of byte;
   _ueffeid1 : array[false..true,0.._ueffs_ctypen-1] of byte;
   _ueffeid2 : array[false..true,0.._ueffs_ctypen-1] of byte;
   _ueffeids : array[false..true,0.._ueffs_ctypen-1] of pMIX_CHUNK;
   _com_snds : array[0..MaxUIDSnds-1] of pMIX_CHUNK;
   _com_sndn : byte;
   _foota,
   _anims,
   _btnx,
   _btny,
   _mmr    : byte;
   _sdpth,
   _fr     :integer;
   _ubtn   :pSDL_Surface;
   _ukey1,
   _ukey2  :cardinal;
   _uname,
   _udesc,
   _ukeyc,
   _uhint  :shortstring;
   {$ENDIF}
end;
PTUID = ^TUID;

TUnit = record
   x,y,
   vx,vy,
   hits,
   speed,
   mdir,tdir,
   a_rld,
   a_tar,
   inapc,
   up_r,un_r,
   srng,
   zfall,
   {$IFDEF _FULLGAME}
   anim,
   fx,fy,fsr,
   mmx,mmy,
   shadow,
   foota,
   {$ENDIF}
   unum : integer;

   a_rng: array[0..MaxAttacks] of integer;

   mv_x ,mv_y ,
   un_rx,un_ry,un_rtar: integer;

   uo_x ,
   uo_y ,
   uo_tar: array[0..MaxOrderList] of integer;
   uo_id : array[0..MaxOrderList] of byte;

   ca_x,
   ca_y  : shortint;
   ca_tar: integer;
   ca_id : byte;

   uo_n,
   up_t,un_t,
   player,
   vstp,
   uid,
   uclord,
   pains,
   apcc,
   order,
   uf,
   a_weap,
   aorder
   : byte;

   aattack,
   itbarea,
   itwarea,
   sel,
   bld  : boolean;

   buff : array[0.._ubuffs] of integer;
   vsni,
   vsnt : array[0..MaxPlayers] of integer;

   puid : PTUID;
end;
PTUnit = ^TUnit;

TPlayer = record
   name    : shortstring;

   cenerg,
   menerg,
   cmana,
   mmana,
   team,
   race,mrace,
   state,
   _lsuc
           : byte;

   rghtatt,
   ready   : boolean;

   o_id    : byte;
   army,
   sarmy,
   o_x0,
   o_y0,
   o_x1,
   o_y1,
   _bldrs,    // builders
   _sbldrs,   // selected builders
   _brcks,    // barracks
   _sbrcks,   // selected barracks
   _smths,    // smiths
   _ssmths
           : integer;

   uid_e   : array[byte] of integer;  // exists
   uid_eb  : array[byte] of integer;  // exists with bld=true
   uid_s   : array[byte] of integer;  // selected
   uid_u0  : array[byte] of integer;  // first unit
   uid_b   : integer;                 // buildings
   uid_u   : integer;                 // units
   uid_sb  : integer;                 // selected buildings
   uid_su  : integer;                 // selected units

   uidsip  : integer;                 // units in progress count (barracks)
   uidip   : array[byte] of integer;  // units in progress count each uid
   uid_a   : TSob;                    // allowed units and buildings

   upgr_a  : TSob;
   upgrsip : integer;                 // upgrades in progress count (smiths)
   upgrip  : array[byte] of integer;  // upgrades in progress count each upid
   upgr    : array[byte] of byte;

   ai_skill: byte;

   PNU     : byte;

   n_u,
   ttl     : integer;
   color,
   nip     : cardinal;
   nport   : word;

   chatm   : array[0..MaxNetChat] of shortstring;
   chats,
   chatc   : byte;
end;
TPList = array[0..MaxPlayers] of TPlayer;

TUPID = record
   _upcnt,
   _uprenerg,
   _uprupgr,
   _upruid  :byte;
   _uptime  :integer;

   {$IFDEF _FULLGAME}
   _upname,
   _updesc,
   _uphint,
   _upkeyc  :shortstring;
   _urace,
   _btnx,
   _btny    :byte;
   _ukey1,
   _ukey2   :cardinal;
   {$ENDIF}
end;

TMissile = record
   x,y,
   vx,vy,
   step,
   dam,vst,
   tar,sr,
   dir,mtars :integer;
   player,
   mid,mf,
   pora,pains:byte;
   homing    :boolean;
   depuids   :TSoB;
   {$IFDEF _FULLGAME}
   _meeff,
   _meeffn,
   _mteff,
   _mtefff,
   _mesndc:byte;
   _mesnd :pMIX_CHUNK;
   {$ENDIF}
end;

{$IFDEF _FULLGAME}

TEff = record
   x,y,t,t2,tm,d:integer;
   e:byte;
end;

TADec = record
   x,y:integer;
end;

TVisSpr = record
   vss     : PSDL_Surface;
   vsx,
   vsy,
   vsyo,
   vsco,   // circle outline
   vsd,    // depth
   vssh    // shadow
           : integer;
   vsrc,   // select rect color
   vsmsk   // aura
           : cardinal;
   vsinv   // alpha
           : byte;
   vsbar   // helthbar
           : single;
   vsclu   // left up
           : integer;
   vscll,  // left lower
   vscrl   // right lower
           : byte;
   vscru   // right up
           : string6;
   vsrct   // select rectangle
           : boolean;
end;
PTVisSpr = ^TVisSpr;

TUSprite = record
   surf : pSDL_Surface;
   hw,
   hh   : integer;
end;
PTUSprite = ^TUSprite;

TMapTheme = record
   _adecn,
   _tdecn,
   _liqdn,
   _terrn,
   _brckn,
   _srckn
         :byte;

   _adecs,
   _tdecs,
   _liqds,
   _terrs,
   _brcks,
   _srcks
         :array of byte;

   _name: shortstring;
end;
{$ENDIF}


