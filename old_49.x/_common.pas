
function b2s (i:byte    ):shortstring;begin str(i,b2s);end;
function w2s (i:word    ):shortstring;begin str(i,w2s);end;
function c2s (i:cardinal):shortstring;begin str(i,c2s);end;
function i2s (i:integer ):shortstring;begin str(i,i2s);end;
//function si2s(i:single  ):shortstring;begin str(i,si2s);end;
function s2b (str:shortstring):byte;var t:integer;begin val(str,s2b,t);end;
function s2w (str:shortstring):word;var t:integer;begin val(str,s2w,t);end;
function s2i (str:shortstring):integer;var t:integer;begin val(str,s2i,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c,t);end;

function max2(x1,x2   :integer):integer;begin if(x1>x2)then max2:=x1 else max2:=x2;end;
function max3(x1,x2,x3:integer):integer;begin max3:=max2(max2(x1,x2),x3);end;
function min2(x1,x2   :integer):integer;begin if(x1<x2)then min2:=x1 else min2:=x2;end;
function min3(x1,x2,x3:integer):integer;begin min3:=min2(min2(x1,x2),x3);end;

function mm3(minx,x,maxx:integer):integer;begin mm3:=min2(maxx,max2(x,minx)); end;

procedure _bc_us(gs:pcardinal;g:byte);
begin
   if(g<=_uts)then
    gs^:=gs^ xor cardinal(1 shl g);
end;

procedure _bc_ss(gs:pcardinal;g:TSob);
var i:byte;
begin
   gs^:=0;
   for i:=0 to _uts do
    if(i in g)then
     gs^:=gs^ or cardinal(1 shl i);
end;

procedure _bc_sa(gs:pcardinal;g:TSob);
var i:byte;
begin
   for i:=0 to _uts do
    if(i in g)then
     gs^:=gs^ or cardinal(1 shl i);
end;

function _bc_g(gs:cardinal;g:byte):boolean;
begin
    _bc_g:=false;
   if(g<=_uts)then _bc_g:=(gs and cardinal(1 shl g))>0;
end;

procedure _upgr_ss(upgr:Pupgrar;g:TSob;race,lvl:byte);
var i:byte;
begin
   FillChar(upgr^,SizeOf(upgrar),0);
   for i:=0 to _uts do
    if(i in g)then
     if(lvl>upgrade_cnt[race,i])
     then upgr^[i]:=upgrade_cnt[race,i]
     else upgr^[i]:=lvl;
end;

function FileExists(FName:shortstring):Boolean;
var F:File;
begin
{$I-}Assign(F,FName);
     Reset(F,1);
   if IoResult=0 then
   begin FileExists:=True; Close(F);end
   else  FileExists:=false;{$I+}
end;

function sign(x:integer):shortint;
begin
   sign:=0;
   if (x>0) then sign:=1;
   if (x<0) then sign:=-1;
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

function _randomr(r:integer):integer;
begin
   _randomr:=random(r)-random(r);
end;

procedure _addtoint(bt:pinteger;val:integer);
begin
   if(bt^<val)then bt^:=val;
end;

function _gen(x:integer):integer;
begin
   _gen:=map_seed2*5+167;
   map_seed2:=_gen;
   _gen:=abs(_gen mod x);
   map_seed2+=17;
end;

function _genx(x,m:integer;newn:boolean):integer;
begin
   _genx:=(x*5)+integer(map_seed+map_seed2);
   _genx:=abs(_genx mod m);
   if(newn)then map_seed2+=67;
end;

procedure WriteError;
var f:Text;
begin
   Assign(f,outlogfn);
   if FileExists(outlogfn) then Append(f) else Rewrite(f);
   writeln(f,sdl_GetError);
   SDL_ClearError;
   Close(f);
end;

function _bldCndt(pl,bucl:byte):boolean;
begin
   if(bucl>_uts)
   then _bldCndt:=true
   else
   with _players[pl] do
    _bldCndt:=(bld_r>0)
            or(cl2uid[race,true,bucl]=0)
            or(bldrs=0)
            or(army>=MaxPlayerUnits)
            or(_bc_g(a_build,bucl)=false)
            or((G_addon=false)and(cl2uid[race,true,bucl] in t2));

   if(_bldCndt=false)then
   with _players[pl] do
   with _ulst[cl2uid[race,true,bucl]] do
   _bldCndt:=((ruid <255)and(uid_b[ruid]=0))
           or((rupgr<255)and(upgr[rupgr]=0))
           or((menerg-cenerg)<renerg)
           or(u_e[true,bucl]>=max);
end;
function _untCndt(pl,bucl:byte):boolean;
begin
   if(bucl>_uts)
   then _untCndt:=true
   else
   with _players[pl] do
    _untCndt:=((army+wb)>=MaxPlayerUnits)
            or(cl2uid[race,false,bucl]=0)
            or(_bc_g(a_units,bucl)=false)
            or(u_eb[true,1]=0)
            or((G_addon=false)and(cl2uid[race,false,bucl] in t2));

   if(_untCndt=false)then
   with _players[pl] do
   with _ulst[cl2uid[race,false,bucl]] do
   _untCndt:=((ruid <255)and(uid_b[ruid]=0))
           or((rupgr<255)and(upgr[rupgr]=0))
           or((menerg-cenerg)<renerg)
           or(trt=0)
           or(u_e[false,bucl]>=max)
           or((max=1)and(wbhero>0));
end;
{function _cmp_untCndt(pl,bucl:byte):boolean;
begin
   with _players[pl] do
   with _ulst[cl2uid[race,false,bucl]] do
_cmp_untCndt:=((army+wb)>=MaxPlayerUnits)
            or(_bc_g(a_units,bucl)=false)
            or(u_e[false,bucl]>=max)
            or(trt=0)
            or((max=1)and(wbhero>0))
            or((G_addon=false)and(bucl>ut2[race]));
end; }

function _upgrreq(player,up:byte):boolean;
var ruid:byte;
begin
   if(up>MaxUpgrs)
   then _upgrreq:=true
   else
   with _players[player] do
     _upgrreq:=(upgrade_time[race,up]=0)
             or((upgrade_rupgr[race,up]<=_uts)and(upgr[upgrade_rupgr[race,up]]=0))
             or(_bc_g(a_upgr,up)=false)
             or((menerg-cenerg)<_pne_r[race,up])
             or((up>upgr_boost)and(G_addon=false));

   with _players[player] do
   if(_upgrreq=false)then
    if(upgrade_mfrg[race,up])
    then _upgrreq:=(upgr[up]+upgrinp[up])>=upgrade_cnt[race,up]
    else _upgrreq:=(upgrinp[up]>0)
                 or(upgr[up]>=upgrade_cnt[race,up]);

   with _players[player] do
   if(_upgrreq=false)and(upgrade_ruid[race,up]<255)then
   begin
      ruid:=upgrade_ruid[race,up];
      _upgrreq:=uid_b[ruid]=0;
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

function ai_name(ain:byte):string;
begin
   if(ain=0)
   then ai_name:=str_ps_none
   else ai_name:=str_ps_comp+' '{$IFDEF _FULLGAME}+chr(22-ain){$ENDIF}+b2s(ain){$IFDEF _FULLGAME}+#25{$ENDIF};
end;


procedure GModeTeams(gm:byte);
begin
   case gm of
     gm_2fort : begin
                   _players[0].team:=0;
                   _players[1].team:=1;
                   _players[2].team:=1;
                   _players[3].team:=1;
                   _players[4].team:=2;
                   _players[5].team:=2;
                   _players[6].team:=2;
                end;
     gm_3fort : begin
                   _players[0].team:=0;
                   _players[1].team:=1;
                   _players[2].team:=1;
                   _players[3].team:=2;
                   _players[4].team:=2;
                   _players[5].team:=3;
                   _players[6].team:=3;
                end;
     gm_inv   : begin
                   _players[0].team:=0;
                   _players[1].team:=1;
                   _players[2].team:=1;
                   _players[3].team:=1;
                   _players[4].team:=1;
                   _players[5].team:=1;
                   _players[6].team:=1;
                end;
   else
   end;
end;

function _plst(p:integer):char;
begin
   with _players[p] do
   begin
      _plst:=str_ps_c[state];
      if(state=ps_play)then
      begin
         if(g_started=false)
         then _plst:=b2pm[ready,2]
         else _plst:=str_ps_c[ps_play];
         if(ttl>=vid_fps)then _plst:=str_ps_t;
         {$IFDEF _FULLGAME}
         if(net_cl_svpl=p)then
         begin
            _plst:=str_ps_sv;
            if(net_cl_svttl>=vid_fps)then _plst:=str_ps_t;
         end;
         {$ENDIF}
      end;
      if(p=HPlayer)then _plst:=str_ps_h;
   end;
end;

function _PickPTeam(p:byte):byte;
begin
   if(p=0)
   then _PickPTeam:=0
   else
     case g_mode of
     gm_2fort: _PickPTeam:=((p-1) div 3)+1;
     gm_3fort: _PickPTeam:=((p-1) div 2)+1;
     gm_inv  : _PickPTeam:=1;
     else if(_players[p].observer)
          then _PickPTeam:=0
          else _PickPTeam:=_players[p].team;
     end;
end;

{$IFDEF _FULLGAME}

function _createSurf(tw,th:integer):pSDL_Surface;
var ts1,ts2:pSDL_Surface;
begin
   _createSurf:=nil;
   ts1:=sdl_createRGBSurface(0,tw,th,vid_bpp,0,0,0,0);
   if(ts1=nil)then
   begin
      WriteError;
      HALT;
   end
   else
   begin
      ts2:=sdl_displayformat(ts1);
      SDL_FreeSurface(ts1);
      if(ts2=nil)then
      begin
         WriteError;
         HALT;
      end;
      _createSurf:=ts2;
   end;
end;

procedure _draw_surf(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   _rect^.x:=x;
   _rect^.y:=y;
   _rect^.w:=sur^.w;
   _rect^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,_rect);
end;

procedure WriteLog(mess:shortstring);
var f:Text;
begin
   Assign(f,outlogfn);
   if FileExists(outlogfn) then Append(f) else Rewrite(f);
   writeln(f,mess);
   Close(f);
end;

function _uvision(uteam:byte;tu:PTUnit;onlyvis:boolean):boolean;
begin
   if(_rpls_rst>=rpl_rhead)and(HPlayer=0)
   then _uvision:=true
   else
    with tu^ do
     if(buff[ub_invis]=0)or(hits<=0)or(onlyvis)
     then _uvision:=(vsnt[uteam]>0)
     else _uvision:=(vsnt[uteam]>0)and(vsni[uteam]>0);
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
   if((vid_vx+vid_panel)<x)and(x<(vid_vx+vid_mw))and
     ((vid_vy          )<y)and(y<(vid_vy+vid_mh))then
   begin
      if(player<=MaxPlayers)then
       if(_players[player].team=_players[HPlayer].team)or((_rpls_rst>=rpl_rhead)and(player=0))then
       begin
          _nhp3:=true;
          exit;
       end;

      if(_fog=false)or(_fog_pgrid(x-vid_vx-vid_panel,y-vid_vy))then _nhp3:=true;
   end;
end;

function _nhp(x,y:integer):boolean;
begin
   _nhp:=((vid_vx+vid_panel)<x)and(x<(vid_vx+vid_mw))and
         ((vid_vy          )<y)and(y<(vid_vy+vid_mh));
end;

procedure _scrollV(i:pinteger;s,min,max:integer);
begin
   i^+=s;
   if(i^>max)then i^:=max;
   if(i^<min)then i^:=min;
end;

procedure _screenshot;
var i:integer;
    s:shortstring;
begin
   i:=0;
   repeat
      i+=1;
      s:=str_screenshot+i2s(i)+'.bmp';
   until not FileExists(s);
   s:=s+#0;
   sdl_saveBMP(_screen,@s[1]);
end;

function rgba2c(r,g,b,a:byte):cardinal;
begin
   rgba2c:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

procedure _view_bounds;
begin
   if (vid_vx<-vid_panel) then vid_vx:=-vid_panel;
   if (vid_vy<0) then vid_vy:=0;
   if ((vid_vx+vid_mw)>map_mw) then vid_vx:=map_mw-vid_mw;
   if ((vid_vy+vid_mh)>map_mw) then vid_vy:=map_mw-vid_mh;

   vid_mmvx:=trunc((vid_vx+vid_panel)*map_mmcx);
   vid_mmvy:=trunc(vid_vy*map_mmcx);
   vid_fsx :=(vid_vx+vid_panel) div fog_cw;
   vid_fsy :=vid_vy div fog_cw;
   vid_fex :=vid_fsx+fog_vfw;
   vid_fey :=vid_fsy+fog_vfh;
end;

procedure _moveHumView(mx,my:integer);
begin
   vid_vx:=mx-((vid_mw+vid_panel) shr 1);
   vid_vy:=my-( vid_mh            shr 1);
   _view_bounds;
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

procedure _addUIBldrs(tx,ty,tr:integer);
var i:byte;
begin
   for i:=0 to _uts do
    if(ui_bldrs_x[i]=0)then
    begin
       ui_bldrs_x[i]:=tx;
       ui_bldrs_y[i]:=ty;
       ui_bldrs_r[i]:=tr;
       break;
    end;
end;

procedure Map_tdmake;
var i,ix,iy,rn:integer;
begin
   vid_mwa:= vid_mw+vid_ab*2+vid_panel;
   vid_mha:= vid_mh+vid_ab*2;

   ix:=longint(map_seed) mod vid_mwa;
   iy:=(map_seed2*5+ix) mod vid_mwa;
   rn:=ix*iy;
   for i:=1 to MaxTDecsS do
   with _TDecs[i-1] do
   begin
      rn+=17;
      ix:=_genx(ix+rn,vid_mwa,false);
      iy:=_genx(iy+sqr(ix*i),vid_mha,false);
      x :=ix;
      y :=iy;
   end;
end;

procedure calcVRV;
begin
   vid_vmb_x1   := vid_mw-vid_vmb_x0;
   vid_vmb_y1   := vid_mh-vid_vmb_y0;
   vid_mwa      := vid_mw+vid_ab;
   vid_mha      := vid_mh+vid_ab*2;
   vid_uiuphx   := vid_panel+((vid_mw-vid_panel) div 2);
   if(spr_mback<>nil)then
   begin
      mv_x:=(vid_mw-spr_mback^.w) div 2;
      mv_y:=(vid_mh-spr_mback^.h) div 2;
   end;
   fog_vfw   :=((vid_mw-vid_panel) div fog_cw)+1;
   fog_vfh   :=(vid_mh div fog_cw)+1;

   map_mmvw    := trunc((vid_mw-vid_panel)*map_mmcx);
   map_mmvh    := trunc( vid_mh*map_mmcx);
   _view_bounds;

   MaxTDecsS:=(vid_mw*vid_mh) div 11000;
   setlength(_TDecs,MaxTDecsS);

   Map_tdmake;
end;

procedure _makeScrSurf;
const
  ui_ex              = 4;
  ui_ax              = ui_ex+ui_hwp+1;
  ystop              = vid_BW*14;
var y:integer;
begin
   if(_uipanel<>nil)then sdl_freesurface(_uipanel);
   _uipanel:=_createSurf(vid_panel+1,vid_mh);

   if(spr_panel<>nil)then sdl_freesurface(spr_panel);
   spr_panel:=_createSurf(vid_panel+1,vid_mh);

   hlineColor(spr_panel,0,spr_panel^.w,0        ,c_white);
   hlineColor(spr_panel,0,spr_panel^.w,vid_panel,c_white);
   hlineColor(spr_panel,0,spr_panel^.w,vid_panel+ui_h3bw,c_white);
   hlineColor(spr_panel,0,spr_panel^.w,vid_panel+vid_BW ,c_white);

   vlineColor(spr_panel,0        ,0,vid_mh,c_white);
   vlineColor(spr_panel,vid_panel,0,vid_mh,c_white);

   vlineColor(spr_panel,ui_h3bw       ,vid_panel,vid_panel+ui_h3bw,c_white);
   vlineColor(spr_panel,ui_hwp        ,vid_panel,vid_panel+ui_h3bw,c_white);
   vlineColor(spr_panel,ui_hwp+ui_h3bw,vid_panel,vid_panel+ui_h3bw,c_white);

   for y:=0 to 3 do vlineColor(spr_panel,y*vid_tBW,vid_panel+ui_h3bw,vid_panel+vid_BW,c_white);

   vlineColor(spr_panel,vid_BW ,vid_panel+vid_BW,ystop,c_white);
   vlineColor(spr_panel,vid_2BW,vid_panel+vid_BW,ystop,c_white);

   characterColor(spr_panel,ui_ex-1,ui_iy,'E',c_aqua  );
   characterColor(spr_panel,ui_ax-2,ui_iy,'A',c_orange);

   y:=ui_bottomsy;
   while (y<=ystop) do
   begin
      hlineColor(spr_panel,0,vid_panel,y,c_white);
      y+=vid_BW;
   end;
end;

procedure _MakeScreen;
begin
   if (_screen<>nil) then sdl_freesurface(_screen);

   if(_fscr)
   then _screen:=SDL_SetVideoMode( vid_mw, vid_mh, vid_bpp, _vflags + SDL_FULLSCREEN)
   else _screen:=SDL_SetVideoMode( vid_mw, vid_mh, vid_bpp, _vflags);
   vid_ingamecl:=(vid_mw-vid_panel-font_w) div font_w;

   if(_screen=nil)then begin WriteError; exit; end;
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
        if (ttl=ClientTTL) then r+=1;
     end;
   _plsOut:=(r=c)and(c>0);
end;

function _uvision(uteam:byte;tu:PTUnit;onlyvis:boolean):boolean;
begin
   with tu^ do
    if(buff[ub_invis]=0)or(hits<=0)or(onlyvis)
    then _uvision:=(vsnt[uteam]>0)
    else _uvision:=(vsnt[uteam]>0)and(vsni[uteam]>0);
end;

{$ENDIF}



