

function b2s (i:byte    ):shortstring;begin str(i,b2s);end;
function w2s (i:word    ):shortstring;begin str(i,w2s);end;
function c2s (i:cardinal):shortstring;begin str(i,c2s);end;
function i2s (i:integer ):shortstring;begin str(i,i2s);end;
function si2s(i:single  ):shortstring;begin str(i,si2s);end;
function s2b (str:shortstring):byte;    var t:integer;begin val(str,s2b,t);end;
function s2w (str:shortstring):word;    var t:integer;begin val(str,s2w,t);end;
function s2i (str:shortstring):integer; var t:integer;begin val(str,s2i,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c,t);end;

function _gen(x:integer):integer;
begin
   _gen:=map_seed2*5+167;
   map_seed2:=_gen;
   _gen:=abs(_gen mod x);
   inc(map_seed2,17);
end;

function _genx(x,m:integer;newn:boolean):integer;
begin
   _genx:=(x*5)+integer(map_seed)+map_seed2;
   _genx:=abs(_genx mod m);
   if(newn)then inc(map_seed2,67);
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
   dx:=abs(dx-dx1);
   dy:=abs(dy-dy1);
   dist:=trunc(sqrt(sqr(dx)+sqr(dy)));
end;

function sign(x:integer):shortint;
begin
   sign:=0;
   if(x>0)then sign:= 1;
   if(x<0)then sign:=-1;
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
   then res:=trunc((vy/vx)*45)
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

function dir_turn(d1,d2,spd:integer):integer;
var d:integer;
begin
   d:=dir_diff(d2,d1);

   if abs(d)<=spd
   then dir_turn:=d2
   else dir_turn:=(360+d1+(spd*sign(d))) mod 360;
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
        inc(c,1);
        if(ready)or(p=HPlayer)then inc(r,1);
     end;
   _plsReady:=(r=c)and(c>0);
end;

procedure WriteError(erstr:shortstring);
var f:Text;
begin
   writeln(erstr);
   {$I-}
   Assign(f,outlogfn);
   if FileExists(outlogfn) then Append(f) else Rewrite(f);
   if(IOResult<>0)then exit;
   writeln(f,erstr);
   SDL_ClearError;
   Close(f);
   {$I+}
end;

function _ai_name(ain:byte):shortstring;
begin
   _ai_name:=str_ps_comp+' '+chr(20-ain)+b2s(ain)+#25;
end;

function _plst(p:integer):char;
begin
   if(p=HPlayer)
   then _plst:=str_ps_h
   else
    with _players[p] do
     if(state=ps_play)then
     begin
        if(g_started=false)
        then _plst:=b2pm[ready,2]
        else _plst:=str_ps_c[ps_play];
        if(ttl>=vid_fps)then _plst:=str_ps_t;
     end
     else _plst:=str_ps_c[state];
end;

function _hi2S(h,mh:integer;s:single):shortint;
begin
  if(h>=mh)
  then _hI2S:=127
  else
   case h of
0           : _hI2S:=0;
dead_hits   : _hI2S:=-127;
   else
     if(h<=ndead_hits)
     then _hI2S:=-128
     else
       if(dead_hits<h)and(h<0)then
       begin
          if(abs(h)<_d2shi)
          then _hI2S:=-1
          else _hI2S:=h div _d2shi;
       end
       else
       begin
          s:=(h/s);
          if(s<1)
          then h:=1
          else h:=trunc(s);
          if(h>_mms)
          then _hI2S:=_mms
          else _hI2S:=h;
       end;
   end;
end;

procedure SetBBit(pb:pbyte;nb:byte;nozero:boolean);
var i:byte;
begin
   i:=(1 shl nb);
   if(nozero)
   then pb^:=pb^ or i
   else
     if((pb^ and i)>0)then pb^:=pb^ xor i;
end;

function _unitBC(pl,uid:byte):boolean;
begin
   with _players[pl] do
    with (_tuids[uid]) do
     _unitBC := (not (uid in uid_a))
              or(_ctime=0)
              or((menerg-cenerg)<_renerg)
              or((uid_e[uid]+uidip[uid])>=_max)
              or(army>=MaxPlayerUnits)
              or((_ruid>0)and(uid_eb[_ruid]=0))
              or((_rupgr>0)and(upgr[_rupgr]=0));
end;
function _upgrBC(pl,uid:byte):boolean;
begin
   with _players[pl] do
    with (_tupids[uid]) do
     _upgrBC := (not (uid in upgr_a))
              or((menerg-cenerg)<_uprenerg)
              or(upgr[uid]>=_upcnt)
              or((_upruid>0)and(uid_eb[_upruid]=0))
              or((_uprupgr>0)and(upgr[_uprupgr]=0));
end;

procedure _addtoint(bt:pinteger;val:integer);
begin
   if(bt^<val)then bt^:=val;
end;

function _PickPTeam(p:byte):byte;
begin
   if(p=0)
   then _PickPTeam:=0
   else
     case g_mode of
     gm_tdm2: _PickPTeam:=((p-1) div 3)+1;
     gm_tdm3: _PickPTeam:=((p-1) div 2)+1;
     else _PickPTeam:=_players[p].team;
     end;
end;

function _intm2(x:integer;m2:boolean):integer;
begin
   _intm2:=x;
   case m2 of
   false: if((_intm2 mod 2)=0)then exit;
   true : if(abs(_intm2 mod 2)=1)then exit;
   end;
   if(_intm2<=0)
   then inc(_intm2,1)
   else dec(_intm2,1);
   if(_intm2=0)then
    if(x>=0)
    then _intm2:=2
    else _intm2:=-2;
end;

function _uvision(uteam:byte;tu:PTUnit;onlyvis:boolean=false):boolean;
begin
   if(tu^.buff[ub_invis]=0)or(tu^.hits<=0)or(onlyvis)
   then _uvision:=(tu^.vsnt[uteam]>0)
   else _uvision:=(tu^.vsnt[uteam]>0)and(tu^.vsni[uteam]>0);
end;

function GetBBit(pb:pbyte;nb:byte):boolean;
begin
   GetBBit:=(pb^ and (1 shl nb))>0;
end;

function _uchtar(tu:PTUnit;rtar:word;rtaru:TSob;player:byte):boolean;
var b:word;
begin
   _uchtar:=false;

   if not(tu^.uid in rtaru)then exit;

   b:=(rtar and at_owne);
   case b of
   %00 : ;
   at_ownp : if(player<>tu^.player)then exit;
   at_owna : if(_players[player].team<>_players[tu^.player].team)then exit;
   at_owne : if(_players[player].team= _players[tu^.player].team)then exit;
   end;

   b:=(rtar and at_hita);
   case b of
   %00 : ;
   at_hith : with tu^ do if(hits<=0)or(hits=puid^._mhits)then exit; // damaged
   at_hitd : with tu^ do if(hits> 0)then exit;
   at_hita : with tu^ do if(hits<=0)then exit;
   end;

   b:=(rtar and at_builds);
   case b of
   %00      : ;
   at_bio   : with tu^.puid^ do if(_itmech or _itbuild)then exit;
   at_mechs : with tu^.puid^ do if(_itmech =false)then exit;
   at_builds: with tu^.puid^ do if(_itbuild=false)then exit;
   end;

   if((rtar and at_bld)>0)then
    with tu^ do
     if(bld=false)then exit;

   b:=(rtar and at_adv);
   case b of
   %00      : ;
   at_noadv : with tu^ do if(buff[ub_advanced]>0)then exit;
   at_adv   : with tu^ do if(buff[ub_advanced]=0)then exit;
   end;

   b:=(rtar and at_ground);
   case b of
   %00      : ;
   at_fly   : with tu^ do if(uf=uf_ground)then exit;
   at_ground: with tu^ do if(uf>uf_ground)then exit;
   end;

   _uchtar:=true;
end;

function _chabilt(aid,player:byte;u:integer):boolean;
var tu:PTUnit;
begin
   _chabilt:=false;

   if(aid=uo_prod)then
   begin
      if(u<-255)
      or(u=0)
      or(u>255)then exit;
   end
   else
     with _toids[aid] do
     begin
        if((rtar and at_unit)>0)then
        begin
           if(u>0)and(u<=MaxUnits)then
           begin
              tu:=@_units[u];
              if(tu^.hits<=idead_hits)then exit;

              if(_uchtar(tu,rtar,rtaru,player)=false)then exit;
           end
           else
             if((rtar and at_map)=0)then exit;
        end
        else ;
         // if(u>0)then exit;
     end;

   _chabilt:=true;
end;

function _chprodmana(uid,player:byte):boolean;
begin
   _chprodmana:=false;
   with _players[player] do
    with _tuids[uid] do
     if(race_pstyle[_itbuild,race])and(cmana<race_bsmana[_itbuild,race])then exit;
   _chprodmana:=true;
end;

function _chabil(oid,uid,pl:byte;aidtar:integer;bld:boolean;spd:integer):boolean;
begin
   _chabil:=false;

   with _toids[oid] do
   begin
      if not(oid in _tuids[uid]._orders)then exit;

      if(rspd)and(spd<=0)then exit;
      if(rnbld=false)then
       if(bld=false)then exit;
      with _players[pl] do
      begin
         if(oid=uo_prod)then
         begin
            if(-255<=aidtar)and(aidtar<0)then
            begin
               aidtar:=-aidtar;

               case _tuids[aidtar]._itbuild of
               true : if(_tuids[uid]._itbuilder=false)then exit;
               false: if(_tuids[uid]._itbarrack=false)then exit;
               end;

               if(_chprodmana(aidtar,pl)=false)then exit;

               if(_unitBC(pl,aidtar))then exit;
            end
            else
            if(0<aidtar)and(aidtar<=255)then
            begin

            end
            else exit;
         end;
         if(rulimit)and(army>=MaxPlayerUnits)then exit;
         if(rmana>0)and(cmana<rmana  )then exit;
         if(ruid >0)and(uid_e[ruid]=0)then exit;
         with _tuids[uid] do
          if(rupgr>0)then
           if(upgr[rupgr]=0)then exit;
      end;
   end;

   _chabil:=true;
end;

{$IFDEF _FULLGAME}

function _checkBldPrc(pl:byte;abuild:boolean):boolean;
begin
   with _players[pl] do
   case abuild of
   true : if(race_pstyle[true,race])        // for builds
          then _checkBldPrc:=(_bldrs>0)     // classic style
          else _checkBldPrc:=(_sbldrs>0);   // dron
   false: _checkBldPrc:=(uidsip<_brcks);    // for units
   end;
end;

function _S2hi(sh:shortint;mh:integer;s:single):integer;
begin
   case sh of
127     : _S2hi:=mh;
1..126  : begin
             _S2hi:=trunc(sh*s);
             if(_S2hi>=mh)then _S2hi:=mh-1;
             if(_S2hi<=0 )then _S2hi:=1;
          end;
0       : _S2hi:=0;
-126..-1: begin
             _S2hi:=sh*_d2shi;
             if(_S2hi>-1)then _S2hi:=-1;
             if(_S2hi<=dead_hits)then _S2hi:=dead_hits+1;
          end;
-127    : _S2hi:=dead_hits;
-128    : _S2hi:=ndead_hits;
   end;
end;

procedure _swAI(p:byte);
begin
   with _players[p] do
    if(state=PS_Comp)then
     begin
        inc(ai_skill,1);
        if(ai_skill>6)then ai_skill:=1;
        name:=_ai_name(ai_skill);
     end;
end;

function rgba2c(r,g,b,a:byte):cardinal;
begin
   rgba2c:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

procedure _screenshot;
var i:integer;
    s:shortstring;
begin
   i:=0;
   repeat
      inc(i,1);
      s:=str_screenshot+i2s(i)+'.bmp';
   until not FileExists(s);
   s:=s+#0;
   sdl_saveBMP(_screen,@s[1]);
end;

procedure _scrollV(i:pinteger;s,min,max:integer);
begin
   inc(i^,s);
   if(i^>max)then i^:=max;
   if(i^<min)then i^:=min;
end;

function _fog_cscr(x,y,r:integer):boolean;
begin
   _fog_cscr:=((vid_fsx-r)<=x)and(x<=(vid_fex+r))
           and((vid_fsy-r)<=y)and(y<=(vid_fey+r));
end;

function _fog_pgrid(x,y:integer):boolean;
var cx,cy:integer;
begin
   cx:=x div fog_cw;
   cy:=y div fog_cw;
   _fog_pgrid:=false;
   if(0<=cx)and(cx<=fog_vfwm)and(0<=cy)and(cy<=fog_vfhm)then _fog_pgrid:=(fog_pgrid[cx,cy]>0);
end;

function _nhp3(x,y:integer;player:byte):boolean;
begin
   _nhp3:=false;
   if(vid_vx<x)and(x<(vid_vx+vid_mw))and(vid_vy<y)and(y<(vid_vy+ui_panely))then
   begin
      if(player<=MaxPlayers)then
       if(_players[player].team=_players[HPlayer].team)then
       begin
          _nhp3:=true;
          exit;
       end;

      if(_fog_pgrid(x-vid_vx,y-vid_vy))then _nhp3:=true;
   end;
end;

procedure _view_bounds;
begin
   if((vid_vx+vid_mw   )>map_mw)then vid_vx:=map_mw-vid_mw;
   if((vid_vy+ui_panely)>map_mw)then vid_vy:=map_mw-ui_panely;
   if(vid_vx<0)then vid_vx:=0;
   if(vid_vy<0)then vid_vy:=0;

   vid_mmvx:=trunc(vid_vx*map_mmcx);
   vid_mmvy:=trunc(vid_vy*map_mmcx);
   vid_fsx :=vid_vx div fog_cw;
   vid_fsy :=vid_vy div fog_cw;
   vid_fex :=vid_fsx+fog_vfw;
   vid_fey :=vid_fsy+fog_vfh;
end;

procedure _moveHumView(mx,my:integer);
begin
   vid_vx:=mx-(vid_mw    shr 1);
   vid_vy:=my-(ui_panely shr 1);
   _view_bounds;
end;

procedure Map_tdmake;
var i,ix,iy,rn:integer;
begin
   vid_mwa:= vid_mw+vid_ab*2;
   vid_mha:= ui_panely+vid_ab*2;

   ix:=longint(map_seed) mod vid_mwa;
   iy:=(map_seed2*5+ix) mod vid_mwa;
   rn:=ix*iy;
   for i:=1 to map_ADecn do
   with map_ADecs[i-1] do
   begin
      inc(rn,17);
      ix:=_genx(ix+rn,vid_mwa,false);
      iy:=_genx(iy+sqr(ix*i),vid_mha,false);
      x :=ix;
      y :=iy;
   end;
end;

function _createSurf(tw,th:integer):pSDL_Surface;
var ts1,ts2:pSDL_Surface;
begin
   _createSurf:=nil;
   ts1:=sdl_createRGBSurface(0,tw,th,vid_bpp,0,0,0,0);
   if(ts1=nil)then
   begin
      WriteError(sdl_GetError);
      HALT;
   end
   else
   begin
      ts2:=sdl_displayformat(ts1);
      SDL_FreeSurface(ts1);
      if(ts2=nil)then
      begin
         WriteError(sdl_GetError);
         HALT;
      end;
      _createSurf:=ts2;
   end;
end;

procedure _DrawPanel(s:pSDL_Surface);
var x,c:integer;
begin
   x:=ui_mmwidth+vid_BW*15;
   c:=vid_BW+ui_p_uplnh;
   while (c<=ui_mmwidth) do
   begin
      hlineColor(s,ui_mmwidth,x,c,c_gray);
      inc(c,vid_BW);
   end;

   x:=ui_mmwidth;
   c:=0;
   while (x<=vid_mw) do
   begin
      if(c>0)and(c<=15)then
       if(c in [1])
       then vlineColor(s,x,ui_p_uplnh,ui_mmwidth,c_white)
       else
         if(c in [1+ui_p_lsecw,1+ui_p_lsecw+ui_p_rsecw,15])
         then vlineColor(s,x,1,ui_mmwidth,c_white)
         else
           if(c in [1,3,5,7,8,9,12])
           then vlineColor(s,x,ui_p_uplnh,ui_mmwidth,c_dgray)
           else vlineColor(s,x,1,ui_mmwidth,c_gray);
      inc(x,vid_BW);
      inc(c,1);
   end;

   hlineColor(s,0         ,vid_mw,0          ,c_white);
   hlineColor(s,ui_mmwidth,vid_mw,ui_p_uplnh,c_white);
   vlineColor(s,ui_mmwidth,0     ,ui_mmwidth,c_white);
end;

procedure _UIChatVars;
begin
   ui_chatx:=0;
   ui_chaty1:=ui_panely-60;
   ui_chaty2:=ui_chaty1-font_w-2;
   txt_line_h2:=font_w*2;
   txt_line_h3:=font_w+2;
   ui_chaty3:=ui_panely-txt_line_h2*3;
   ui_rpabily:=ui_chaty3-50;

   if(font_w>0)then vid_ingamecl:=(vid_mw-font_w) div font_w;
   ui_dBW:=vid_BW-font_w-1;
end;

procedure _MakePanel;
begin
   if(ui_panel <>nil)then SDL_FreeSurface(ui_panel);
   if(ui_panelb<>nil)then SDL_FreeSurface(ui_panelb);
   ui_panely :=vid_mh-ui_mmwidth;
   ui_panelby:=ui_panely+ui_p_uplnh;
   ui_panel  :=_createSurf(vid_mw,ui_mmwidth);
   ui_panelb :=_createSurf(vid_mw,ui_mmwidth);
   _DrawPanel(ui_panel );
   _DrawPanel(ui_panelb);
   _UIChatVars;
   fog_vfw   :=(vid_mw div fog_cw)+1;
   fog_vfh   :=((vid_mh-ui_mmwidth) div fog_cw)+1;
end;

procedure calcVRV;
begin
   vid_vmb_x1   := vid_mw-vid_vmb_x0;
   vid_vmb_y1   := vid_mh-vid_vmb_y0;
   mv_x         := (vid_mw-_menu_surf^.w) div 2;
   mv_y         := (vid_mh-_menu_surf^.h) div 2;
   ui_xpws      := vid_mw div 2;

   map_mmvw    := trunc(vid_mw*map_mmcx);
   map_mmvh    := trunc(ui_panely*map_mmcx);

   _view_bounds;

   map_ADecn:=(vid_mw*vid_mh) div 11000;
   setlength(map_ADecs,map_ADecn);
   Map_tdmake;
end;

procedure _MakeScreen;
begin
   if(_screen<>nil)then SDL_FreeSurface(_screen);

   if(_fscr)
   then _screen:=SDL_SetVideoMode( vid_mw, vid_mh, vid_bpp, _vflags + SDL_FULLSCREEN)
   else _screen:=SDL_SetVideoMode( vid_mw, vid_mh, vid_bpp, _vflags);

   if(_screen=nil)then
   begin
      WriteError(sdl_GetError);
      HALT;
   end;

   _MakePanel;
end;

{$ELSE}

function _plsOut:boolean;
var i,c,r:byte;
begin
   c:=0;
   r:=0;
   for i:=1 to MaxPlayers do
    with _Players[i] do
     if(state=PS_Play)then
     begin
        inc(c,1);
        if(ttl>=ServerTTL)then inc(r,1);
     end;
   _plsOut:=(r=c)and(c>0);
end;

{$ENDIF}


