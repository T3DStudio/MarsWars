
function b2s (i:byte    ):shortstring;begin str(i,b2s);end;
function w2s (i:word    ):shortstring;begin str(i,w2s);end;
function c2s (i:cardinal):shortstring;begin str(i,c2s);end;
function i2s (i:integer ):shortstring;begin str(i,i2s);end;
//function si2s(i:single  ):shortstring;begin str(i,si2s);end;
function s2b (str:shortstring):byte    ;var t:integer;begin val(str,s2b,t);end;
function s2w (str:shortstring):word    ;var t:integer;begin val(str,s2w,t);end;
function s2i (str:shortstring):integer ;var t:integer;begin val(str,s2i,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c,t);end;

function max2(x1,x2   :integer):integer;begin if(x1>x2)then max2:=x1 else max2:=x2;end;
function max3(x1,x2,x3:integer):integer;begin max3:=max2(max2(x1,x2),x3);end;
function min2(x1,x2   :integer):integer;begin if(x1<x2)then min2:=x1 else min2:=x2;end;
function min3(x1,x2,x3:integer):integer;begin min3:=min2(min2(x1,x2),x3);end;

function mm3(mnx,x,mxx:integer):integer;begin mm3:=min2(mxx,max2(x,mnx)); end;

procedure _unit_damage(pu:PTUnit;dam,p:integer;pl:byte);  forward;

function _str_mx(x:byte):shortstring;
begin
   if(x=0)
   then _str_mx:='-'
   else _str_mx:='x'+i2s(x);
end;

procedure _units_au(p:byte;g:TSob;max:integer;new:boolean);  // allowed units
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(a_units,SizeOf(a_units),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _uids[i] do a_units[i]:=min2(_max,max);
   end;
end;
procedure _upgrs_au(p:byte;g:TSob;lvl:integer;new:boolean);  // allowed upgrades
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(a_upgrs,SizeOf(a_upgrs),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _upids[i] do a_upgrs[i]:=min2(_up_max,lvl);
   end;
end;

procedure _upgrs_ss(p:byte;g:TSob;lvl:integer;new:boolean);  // current upgrades
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(upgr,SizeOf(upgr),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _upids[i] do upgr[i]:=min3(a_upgrs[i],_up_max,lvl);
   end;
end;

procedure CalcPLNU;
var p:byte;
begin
   G_plstat:=0;
   G_nunits:=0;
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(army>0)and(state>ps_none)then
     begin
        G_plstat:=G_plstat or (1 shl p);
        G_nunits+=MaxPlayerUnits;
     end;
end;

function cf(c,f:pcardinal):boolean;
begin cf:=(c^ and f^)>0;end;

function sign(x:integer):integer;
begin
   sign:=0;
   if(x>0)then sign:= 1;
   if(x<0)then sign:=-1;
end;

function dist2(dx,dy,dx1,dy1:integer):integer;
begin
   dx := abs(dx1-dx);
   dy := abs(dy1-dy);
   if (dx<dy)
   then dist2:=(123*dy+51*dx) shr 7
   else dist2:=(123*dx+51*dy) shr 7;
end;

function dist(dx,dy,dx1,dy1:integer):integer;
begin
   dx  :=abs(dx-dx1);
   dy  :=abs(dy-dy1);
   dist:=trunc(sqrt(sqr(dx)+sqr(dy)));
end;

function p_dir(x0,y0,x1,y1:integer):integer;
var vx,vy,avx,avy:integer;
    res:single;
begin
   p_dir:=270;
   vx:=x1-x0;
   vy:=y1-y0;

   if(vx=0)and(vy=0)then exit;

   avx:=abs(vx);
   avy:=abs(vy);

   if(avx>avy)
   then res:=   trunc((vy/vx)*45)
   else res:=90-trunc((vx/vy)*45);

   if(vy<0)then
   begin
      if(res<0)then res:=res+360 else
      if(res>0)then res:=res+180;
   end
   else
     if(res<0)then res:=res+180;

   if(vx<0)and(res=0)then res:=180;

   p_dir:=trunc(360-res);
end;

function dir_diff(dir1,dir2:integer):integer;
begin
   dir_diff:=((( (dir1-dir2) mod 360) + 540) mod 360) - 180;
end;

function _DIR360(d:integer):integer;
begin
   _DIR360:=d mod 360;
   if(_DIR360<0)then _DIR360:=_DIR360+360;
end;

function dir_turn(d1,d2,spd:integer):integer;
var d:integer;
begin
   d:=dir_diff(d2,d1);

   if abs(d)<=spd
   then dir_turn:=d2
   else dir_turn:=d1+(spd*sign(d));
   dir_turn:=_DIR360(dir_turn);
end;



function _IsUnitRange(u:integer;ppu:PPTUnit):boolean;
begin
   _IsUnitRange:=false;
   if(0<u)and(u<=MaxUnits)then
   begin
      _IsUnitRange:=true;
      if(ppu<>nil)then ppu^:=@_units[u];
   end;
end;

procedure _AddToInt(bt:pinteger;val:integer);
begin
   if(bt^<val)then bt^:=val;
end;

function _random(m:integer):integer;
const a = 4;
      t : array[byte] of byte = (
   //   0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
      0  ,   8, 109, 220, 222, 241, 149, 107,  75, 248, 254, 140,  16,  66,  74,   21,
      211,  47,  80, 242, 154,  27, 205, 128, 161,  89,  77,  36,  95, 110,  85,   48,
      212, 140, 211, 249,  22,  79, 200,  50,  28, 188,  52, 140, 202, 120,  68,  145,
      62 ,  70, 184, 190,  91, 197, 152, 224, 149, 104,  25, 178, 252, 182, 202,  182,
      141, 197,   4,  81, 181, 242, 145,  42,  39, 227, 156, 198, 225, 193, 219,   93,
      122, 175, 249,   0, 175, 143,  70, 239,  46, 246, 163,  53, 163, 109, 168,  135,
      2  , 235,  25,  92,  20, 145, 138,  77,  69, 166,  78, 176, 173, 212, 166,  113,
      94 , 161,  41,  50, 239,  49, 111, 164,  70,  60,   2,  37, 171,  75, 136,  156,
      11 ,  56,  42, 146, 138, 229,  73, 146,  77,  61,  98, 196, 135, 106,  63,  197,
      195,  86,  96, 203, 113, 101, 170, 247, 181, 113,  80, 250, 108,   7, 255,  237,
      129, 226,  79, 107, 112, 166, 103, 241,  24, 223, 239, 120, 198,  58,  60,   82,
      128,   3, 184,  66, 143, 224, 145, 224,  81, 206, 163,  45,  63,  90, 168,  114,
      59 ,  33, 159,  95,  28, 139, 123,  98, 125, 196,  15,  70, 194, 253,  54,   14,
      109, 226,  71,  17, 161,  93, 186,  87, 244, 138,  20,  52, 123, 251,  26,   36,
      17 ,  46,  52, 231, 232,  76,  31, 221,  84,  37, 216, 165, 212, 106, 197,  242,
      98 ,  43,  39, 175, 254, 145, 190,  84, 118, 222, 187, 136, 120, 163, 236,  249
      );
begin
   map_rpos+=1;
   map_iseed:=map_iseed*a+t[map_rpos];
   if(m=0)
   then _random:=0
   else _random:=abs(integer(map_iseed) mod m);
end;

function _randomx(x,m:integer):integer;
begin
   map_iseed+=word(x);
   _randomx:=_random(m);
end;

function _randomr(r:integer):integer;
begin
   _randomr:=_random(r)-_random(r);
end;

procedure WriteSDLError;
var f:Text;
begin
   Assign(f,outlogfn);
   if FileExists(outlogfn) then Append(f) else Rewrite(f);
   writeln(f,sdl_GetError);
   SDL_ClearError;
   Close(f);
end;

function _uid_cndt(pl:PTPlayer;uid:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then _uid_cndt:=_uid_cndt or ni;end;
begin
   _uid_cndt:=0;
   with pl^ do
   with _uids[uid] do
   begin
      setr(ureq_unitlimit ,(army+uproda)>=MaxPlayerUnits  );
      setr(ureq_ruid      ,(_ruid >0)and(uid_eb[_ruid ]=0));
      setr(ureq_rupid     ,(_rupgr>0)and(upgr  [_rupgr]=0));
      setr(ureq_energy    , cenerg<_renerg                );
      setr(ureq_time      , _btime<=0                     );
      setr(ureq_addon     ,(_addon)and(G_addon=false)     );
      setr(ureq_max       ,(uid_e[uid]+uprodu[uid])>=min2(_max,a_units[uid]));

      case _isbuilding of
      true : begin
             setr(ureq_builders ,n_builders<=0);
             setr(ureq_bld_r    ,build_cd   >0);
             end;
      false: setr(ureq_barracks ,n_barracks<=0);
      end;
   end;
end;
function _upid_cndt(pl:PTPlayer;up:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then _upid_cndt:=_upid_cndt or ni;end;
begin
   _upid_cndt:=0;
   with pl^ do
   with _upids[up] do
   begin
      setr(ureq_ruid   ,(_up_ruid >0)and(uid_eb[_up_ruid ]=0)  );
      setr(ureq_rupid  ,(_up_rupgr>0)and(upgr  [_up_rupgr]=0)  );
      setr(ureq_energy , cenerg<_up_renerg                     );
      setr(ureq_time   , _up_time<=0                           );
      setr(ureq_addon  ,(_up_addon)and(G_addon=false)          );
      setr(ureq_max    ,(integer(upgr[up]+pprodu[up])>=min2(_up_max,a_upgrs[up])));
      setr(ureq_product,(_up_mfrg=false)and(pprodu[up]>0)      );
      setr(ureq_smiths , n_smiths<=0                           );
   end;
end;

function _plsReady:boolean;
var p,c,r:byte;
begin
   c:=0;
   r:=0;

   for p:=1 to MaxPlayers do
    with _players[p] do
     if(state=ps_play)then
     begin
        c+=1;
        if(ready)or(p=HPlayer)then r+=1;
     end;
   _plsReady:=(r=c)and(c>0);
end;

function _hi2S(h,mh:integer;s:single):shortint;
begin
   if(h>=mh        )then _hI2S:=127  else
   if(h =0         )then _hI2S:=0    else
   if(h =dead_hits )then _hI2S:=-127 else
   if(h<=ndead_hits)then _hI2S:=-128 else
   if(dead_hits<h)and(h<0)
                    then _hI2S:=mm3(-126,h div _d2shi,-1)
   else                  _hI2S:=mm3(1,trunc(h/s),_mms);
end;

function ai_name(ain:byte):shortstring;
begin
   if(ain=0)
   then ai_name:=str_ps_none
   else ai_name:=str_ps_comp+' '{$IFDEF _FULLGAME}+chr(22-ain){$ENDIF}+b2s(ain){$IFDEF _FULLGAME}+#25{$ENDIF};
end;


function PickPlayerTeam(gm,p:byte):byte;
begin
   if(p=0)
   then PickPlayerTeam:=0
   else
     case gm of
     gm_aslt,
     gm_2fort: case p of
               1..3: PickPlayerTeam:=1;
               4..6: PickPlayerTeam:=2;
               end;
     gm_3fort: case p of
               1,2 : PickPlayerTeam:=1;
               3,4 : PickPlayerTeam:=2;
               5,6 : PickPlayerTeam:=3;
               end;
     gm_inv  : PickPlayerTeam:=1;
     else      PickPlayerTeam:=_players[p].team;
     end;
end;

function _PlyerStatus(p:integer):char;
begin
   with _players[p] do
   begin
      _PlyerStatus:=str_ps_c[state];
      if(state=ps_play)then
      begin
         if(g_started=false)
         then _PlyerStatus:=b2pm[ready,2]
         else _PlyerStatus:=str_ps_c[ps_play];
         if(ttl>=fr_fps)then _PlyerStatus:=str_ps_t;
         {$IFDEF _FULLGAME}
         if(net_cl_svpl=p)then
         begin
            _PlyerStatus:=str_ps_sv;
            if(net_cl_svttl>=fr_fps)then _PlyerStatus:=str_ps_t;
         end;
         {$ENDIF}
      end;
      if(p=HPlayer)then _PlyerStatus:=str_ps_h;
   end;
end;

function _UnitHaveRPoint(uid:byte):boolean;
begin
   with _uids[uid] do
   _UnitHaveRPoint:=(_isbarrack)or(_ability in [uab_teleport,uab_uac__unit_adv]);
end;

function _uvision(uteam:byte;tu:PTUnit;noinvis:boolean):boolean;
begin
   {$IFDEF _FULLGAME}
   if(_rpls_rst>=rpl_rhead)and(HPlayer=0)
   then _uvision:=true
   else
   {$ENDIF}
    with tu^ do
     if(buff[ub_invis]<=0)or(hits<=0)or(noinvis)
     then _uvision:=(vsnt[uteam]>0)
     else _uvision:=(vsnt[uteam]>0)and(vsni[uteam]>0);
end;

{$IFDEF _FULLGAME}

procedure _bnext(pb:pbyte;fwrd:boolean;pset:PTSoB);
begin
   if(pset^=[])then exit;
   repeat
     if(fwrd)
     then pb^+=1
     else pb^-=1
   until pb^ in pset^
end;

procedure WriteLog(mess:shortstring);
var f:Text;
begin
   Assign(f,outlogfn);
   if FileExists(outlogfn) then Append(f) else Rewrite(f);
   writeln(f,mess);
   Close(f);
end;

function _fog_pgrid(x,y:integer):boolean;
var cx,cy:integer;
begin
   cx:=x div fog_cw;
   cy:=y div fog_cw;
   _fog_pgrid:=false;
   if(0<=cx)and(cx<=fog_vfwm)
  and(0<=cy)and(cy<=fog_vfhm)then _fog_pgrid:=(fog_pgrid[cx,cy]>0);
end;

function _rectvis(x,y,hw,hh,sh:integer):boolean;
begin
   _rectvis:=((vid_vx-hw           )<x)and(x<(vid_vx+vid_sw+hw))
          and((vid_vy-hh-max2(0,sh))<y)and(y<(vid_vy+vid_sh+hh));
end;
function _nhp(x,y:integer):boolean;
begin
   _nhp:=(vid_vx<x)and(x<(vid_vx+vid_sw))
      and(vid_vy<y)and(y<(vid_vy+vid_sh));
end;

function _nhp3(x,y:integer;player:PTPlayer):boolean;
begin
   _nhp3:=false;
   x-=vid_vx;
   y-=vid_vy;
   if(0<x)and(x<vid_sw)and
     (0<y)and(y<vid_sh)then
   begin
      if(player<>nil)then
       if (player^.team=_players[HPlayer].team)
       or((_rpls_rst>=rpl_rhead)and(player^.pnum=0))then
       begin
          _nhp3:=true;
          exit;
       end;

      if(_fog=false)or(_fog_pgrid(x,y))then _nhp3:=true;
   end;
end;

procedure _scrollInt(i:pinteger;s,min,max:integer);
begin
   i^+=s;
   if(i^>max)then i^:=max;
   if(i^<min)then i^:=min;
end;

function p_color(player:byte):cardinal;
begin
   p_color:=0;
   if(player<=MaxPlayers)then
    case vid_plcolors of
   1,
   2: if(player=HPlayer)then
        if(vid_plcolors=1)
        then p_color:=c_lime
        else p_color:=c_white
      else
        if(PickPlayerTeam(g_mode,HPlayer)=PickPlayerTeam(g_mode,player))
        then p_color:=c_yellow
        else p_color:=c_red;
   3: p_color:=PlayerColor[PickPlayerTeam(g_mode,player)];
   4: if(player=HPlayer)
      then p_color:=c_white
      else p_color:=PlayerColor[PickPlayerTeam(g_mode,player)];
    else
      p_color:=PlayerColor[player];
    end;
end;

procedure _view_bounds;
begin
   vid_vx:=mm3(0,vid_vx,map_mw-vid_sw);
   vid_vy:=mm3(0,vid_vy,map_mw-vid_sh);

   vid_mmvx:=round(vid_vx*map_mmcx);
   vid_mmvy:=round(vid_vy*map_mmcx);
   vid_fsx :=vid_vx div fog_cw;
   vid_fsy :=vid_vy div fog_cw;
   vid_fex :=vid_fsx+fog_vfw;
   vid_fey :=vid_fsy+fog_vfh;
end;

procedure _moveHumView(mx,my:integer);
begin
   vid_vx:=mx-(vid_sw shr 1);
   vid_vy:=my-(vid_sh shr 1);
   _view_bounds;
end;

function _S2hi(sh:shortint;mh:integer;s:single):integer;
begin
   case sh of
127     : _S2hi:=mh;
1..126  : _S2hi:=mm3(1,trunc(sh*s),mh-1);
0       : _S2hi:=0;
-126..-1: _S2hi:=mm3(dead_hits+1,sh*_d2shi,-1);
-127    : _S2hi:=dead_hits;
-128    : _S2hi:=ndead_hits;
   end;
end;

procedure _addUIBuildRs(tx,ty,tr:integer);
begin
   if(ui_builders_n>ui_builder_srs)then exit;

   ui_builders_x[ui_builders_n]:=tx;
   ui_builders_y[ui_builders_n]:=ty;
   ui_builders_r[ui_builders_n]:=tr;

   ui_builders_n+=1;
end;

{$ELSE}

function _plsOut:boolean;
var i,c,r:byte;
begin
   c:=0;
   r:=0;
   for i:=1 to MaxPlayers do
    with _Players[i] do
     if (state=PS_Play) then
     begin
        c+=1;
        if(ttl=ClientTTL)then r+=1;
     end;
   _plsOut:=(r=c)and(c>0);
end;

{$ENDIF}



