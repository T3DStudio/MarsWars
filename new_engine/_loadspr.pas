
function sdl_GetPixelColor(srf:PSDL_SURFACE;x,y:integer):cardinal;
var bpp,r,g,b:byte;
begin
   sdl_GetPixelColor:=0;

   bpp:=srf^.format^.BytesPerPixel;

   if(srf^.w=0)or(srf^.h=0)then exit;

   if(x>=srf^.w)then x:=srf^.w-1;
   if(y>=srf^.h)then y:=srf^.h-1;
   if(x<0)then x:=0;
   if(y<0)then y:=0;

   case bpp of
      1:sdl_GetPixelColor:=TBa(srf^.pixels^)[(y*srf^.pitch)+x];
      2:sdl_GetPixelColor:=TWa(srf^.pixels^)[(y*srf^.pitch)+x];
      3:begin
           if(SDL_BYTEORDER = SDL_big_endian)then
           begin
              r:=TBa(srf^.pixels^)[(y*srf^.pitch)+(x*bpp)];
              g:=TBa(srf^.pixels^)[(y*srf^.pitch)+(x*bpp)+1];
              b:=TBa(srf^.pixels^)[(y*srf^.pitch)+(x*bpp)+2];
           end
           else
           begin
              b:=TBa(srf^.pixels^)[(y*srf^.pitch)+(x*bpp)];
              g:=TBa(srf^.pixels^)[(y*srf^.pitch)+(x*bpp)+1];
              r:=TBa(srf^.pixels^)[(y*srf^.pitch)+(x*bpp)+2];
           end;
           sdl_GetPixelColor:=(r shl 16)+(g shl 8)+b;
        end;
      4:sdl_GetPixelColor:=TCa(srf^.pixels^)[y*srf^.w+x];
   else
   end;
end;

function _loadsrf(fn:string;default:pSDL_Surface=nil):pSDL_SURFACE;
var tmp:pSDL_SURFACE;
begin
   if(default=nil)then default:=_dsurf;

   _loadsrf:=default;
   if(not FileExists(fn))then exit;

   fn:=fn+#0;

   tmp:=img_load(@fn[1]);
   if(tmp<>nil)then
   begin
      _loadsrf:=sdl_displayformat(tmp);
      sdl_freesurface(tmp);
   end;
end;

function loadIMG(fn:string;trns:boolean;log:boolean=true;default:pSDL_Surface=nil):pSDL_SURFACE;
var grpe:byte;
begin
   if(default=nil)then default:=_dsurf;
   for grpe:=1 to grp_extn do
   begin
      loadIMG:=_loadsrf(str_f_grp+fn+grp_exts[grpe],default);
      if(loadIMG<>default)then
      begin
         if(trns)then SDL_SetColorKey(loadIMG,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(loadIMG,0,0));
         break;
      end;
   end;
   if(log)and(loadIMG=default)then WriteError(str_f_grp+fn);
end;

{function loadIMGe(fn:string;trns:boolean):pSDL_SURFACE;
begin
   loadIMGe:=_loadsrf(str_f_grp+fn);
   if(loadIMGe<>_dsurf)and(trns)then SDL_SetColorKey(loadIMGe,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(loadIMGe,0,0));
   if(loadIMGe=_dsurf)then WriteError(str_f_grp+fn);
end;}

procedure _FreeSF(sf:PSDL_Surface);
begin
   if(sf<>nil)and(sf<>_dsurf)then
   begin
      sdl_FreeSurface(sf);
      sf:=nil;
   end;
end;

function to32(c:cardinal):cardinal;
var r,g,b:byte;
begin
   r:=(c and $00FF0000) shr 16;
   g:=(c and $0000FF00) shr 8;
   b:=(c and $000000FF);
   to32:=255+(b shl 8)+(g shl 16)+(r shl 24)
end;


function _xasurf(s:PSDL_Surface;xa,ya:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:cardinal;
begin
   _xasurf:=_createSurf(s^.w,s^.h);
   for x:=1 to s^.w do
    for y:=1 to s^.h do
    begin
       if(xa)then sx:=s^.w-x else sx:=x-1;
       if(ya)then sy:=s^.h-y else sy:=y-1;
       c:=to32(sdl_GetPixelColor(s,x-1,y-1));
       pixelColor(_xasurf,sx,sy,c);
    end;
end;

procedure _xasprite(s1,s2:PTUSprite);
begin
   with s1^ do
   begin
      _FreeSF(surf);
      surf:=_xasurf(s2^.surf,true,false);
      hw  :=s2^.hw;
      hh  :=s2^.hh;
      SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(surf,s2^.surf^.w-1,0));
   end;
end;

procedure _lstr(us:PTUSprite;fn:string);
begin
   with (us^) do
   begin
      _FreeSF(surf);
      surf:=LoadIMG(fn,true);
      hw:=surf^.w div 2;
      hh:=surf^.h div 2;
   end;
end;

procedure _lsmdl(sm:PTSModel;fn:string);
begin
   with (sm^) do
   begin

   end;
end;

procedure _loadDecs;
var i:byte;
   fn:string;
begin
   spr_ADecs[0,false]:=spr_Dummy;
   spr_ADecs[0,true ]:=spr_Dummy;

   for i:=1 to CraterMR do
   begin
      with spr_ADecs[i,false] do begin hw:=CraterR[i];hh:=CraterR[i];end;
      with spr_ADecs[i,true ] do begin hw:=CraterR[i];hh:=CraterR[i];end;
   end;

   for i:=0 to 255 do
   begin
      if(i>CraterMR)then
      begin
         fn:=str_f_mapg+str_f_adec+b2s(i);
         with spr_ADecs[i,false] do
         begin
            surf:=loadIMG(fn,true,false,spr_font[#10]);
            hw  :=surf^.w div 2;
            hh  :=surf^.h div 2;
         end;
         _xasprite(@spr_ADecs[i,true],@spr_ADecs[i,false]);
      end;

      fn:=str_f_mapg+str_f_ter+b2s(i);
      spr_Terrains[i]:=loadIMG(fn,false,false,spr_font[#10]);

      fn:=str_f_mapg+str_f_liq+b2s(i);
      spr_Liquids[i]:=loadIMG(fn,false,false,spr_font[#10]);

      fn:=str_f_mapg+str_f_dothr+b2s(i);
      with spr_TDecs[i,false] do
      begin
         surf:=loadIMG(fn,true,false,spr_font[#10]);
         hw  :=surf^.w div 2;
         hh  :=surf^.h div 2;
      end;
      _xasprite(@spr_TDecs[i,true],@spr_TDecs[i,false]);

      fn:=str_f_mapg+str_f_drckb+b2s(i);
      with spr_BRocks[i,false] do
      begin
         surf:=loadIMG(fn,true,false,spr_font[#10]);
         hw  :=surf^.w div 2;
         hh  :=surf^.h div 2;
      end;
      _xasprite(@spr_BRocks[i,true],@spr_BRocks[i,false]);

      fn:=str_f_mapg+str_f_drcks+b2s(i);
      with spr_SRocks[i,false] do
      begin
         surf:=loadIMG(fn,true,false,spr_font[#10]);
         hw  :=surf^.w div 2;
         hh  :=surf^.h div 2;
      end;
      _xasprite(@spr_SRocks[i,true],@spr_SRocks[i,false]);
   end;
end;

procedure _MakeLiquidTemplate(surf,ts:pSDL_Surface;xs,ys,d,r:integer;animst:byte;rrs,itb:boolean);
var x,y,dir,i,e,p:integer;
begin
   boxColor(surf,0,0,d,d,c_purple);

   x:=xs;
   while (x<d) do
   begin
      y:=ys;
      while (y<d) do
      begin
         _draw_surf(surf,x,y,ts);
         inc(y,ts^.h);
      end;
      inc(x,ts^.w);
   end;

   if(rrs=false)then
   begin
      case animst of
      0:   e:=d div 22;
      else e:=d div 32;
      end;
      dir:=0;
      i:=r+e;
      while(dir<=360)do
      begin
         case animst of
         0:   p:=e+random(e);
         else p:=e+_genx(dir+i,e,false);
         end;
         x:=r+trunc(i*cos(dir*degtorad));
         y:=r+trunc(i*sin(dir*degtorad));
         filledcircleColor(surf,x,y,p,c_purple);
         inc(dir,8);
      end;
   end;

   dir:=0;
   if(rrs=false)
   then i:=r div 10
   else i:=-5;
   while(dir<=360)do
   begin
      p:=r-i;
      inc(dir,3);
      x:=r+trunc(d*cos(dir*degtorad));
      y:=r+trunc(d*sin(dir*degtorad));
      filledcircleColor(surf,x,y,p,c_purple);
   end;
   if(itb)then filledcircleColor(surf,r,r,r-(r div 6)-5,c_purple);
end;

procedure MakeLiquidBack;
var ri:byte;
    d :integer;
begin
   if(map_pblqt=anb_Terrain[map_trt])and(map_pblqt<255)then exit;
   map_pblqt:=anb_Terrain[map_trt];

   for ri:=1 to LiquidMR do
   begin
      with spr_liquidb[ri] do
      begin
         d   :=DID_R[ri]*2+30;
         _FreeSF(surf);
         surf:=_createSurf(d,d);
         hw:=d div 2;
         hh:=hw;
         _MakeLiquidTemplate(surf,spr_Terrains[map_pblqt],0,0,d,(d div 2),0,ans_Terrain[map_trt],true);
         SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(surf,0,0));
      end;
   end;
end;

procedure MakeLiquid;
var ts : psdl_surface;
d,a,ri,
wsp,hsp: integer;
begin
   if(map_plqt=map_lqt)and(map_plqt<255)then exit;
   map_plqt:=map_lqt;

   ts :=spr_Liquids[map_lqt];

   case anm_Liquids[map_lqt] of
   0: begin
         wsp:=(ts^.w div 4)*((map_seed  mod 3)-1);
         hsp:=(ts^.h div 4)*((abs(map_seed2) mod 3)-1);
         if(wsp=0)and(hsp=0)then wsp:=(ts^.w div 4);
      end;
   else
      wsp:=0;
      hsp:=0;
   end;

   for ri:=1 to LiquidMR do
    for a:=1 to LiquidAnim do
     with spr_liquid[ri,a] do
     begin
        d:=DID_R[ri]*2+10;
        _FreeSF(surf);
        surf:=_createSurf(d,d);
        hw:=d div 2;
        hh:=hw;

        _MakeLiquidTemplate(surf,ts,-ts^.w-(a*wsp),-ts^.h-(a*hsp),d,hh,anm_Liquids[map_lqt],false,false);

        if(anm_Liquids[map_lqt]=1)then
         case a of
         1,3 : boxColor(surf,0,0,d,d,rgba2c(0,0,0,30));
         2   : boxColor(surf,0,0,d,d,rgba2c(0,0,0,60));
         end;

        SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(surf,0,0));
     end;
end;

procedure MakeCrater;
var x,y,p,e,a,i,ri:integer;
begin
   for i:=1 to CraterMR do
    with spr_ADecs[i,false] do
    begin
       _FreeSF(surf);
       surf:=_createSurf(CraterD[i],CraterD[i]);

       _draw_surf(surf,0,0,ter_surf);
       boxColor(surf,0,0,surf^.w,surf^.h,c_aablack);

       a :=0;
       e :=CraterD[i] div 22;
       ri:=CraterR[i]+e;
       while(a<360)do
       begin
          p:=e+random(e);
          inc(a,14);
          x:=CraterR[i]+trunc(ri*cos(a*degtorad));
          y:=CraterR[i]+trunc(ri*sin(a*degtorad));
          filledcircleColor(surf,x,y,p,c_purple);
       end;

       a:=0;
       while (a<360) do
       begin
          p:=CraterR[i]-(CraterR[i] div 10);
          inc(a,3);
          x:=CraterR[i]+trunc(CraterD[i]*cos(a*degtorad));
          y:=CraterR[i]+trunc(CraterD[i]*sin(a*degtorad));
          filledcircleColor(surf,x,y,p,c_purple);
       end;

       SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(surf,0,0));
    end;

   for i:=1 to CraterMR do _xasprite(@spr_ADecs[i,true],@spr_ADecs[i,false]);
end;

procedure MakeTerrain;
var x,y,
    w,h : integer;
begin
   if(map_ptrt=map_trt)and(map_ptrt<255)then exit;
   if(ter_surf<>nil) then
   begin
      sdl_freesurface(ter_surf);
      ter_surf:=nil;
   end;
   map_ptrt:=map_trt;

   ter_w:=spr_Terrains[map_trt]^.w;
   ter_h:=spr_Terrains[map_trt]^.h;
   w:=vid_mw+(ter_w shl 1);
   h:=ui_panely+(ter_h shl 1);
   ter_surf:=_createSurf(w,h);
   x:=0;

   while(x<w)do
   begin
      y:=0;
      while(y<w)do
      begin
         _draw_surf(ter_surf,x,y,spr_Terrains[map_trt]);
         inc(y,ter_h);
      end;
      inc(x,ter_w);
   end;

   MakeCrater;
end;

function LoadBtn(fn:string;log:boolean=true):pSDL_Surface;
var ts:pSDl_Surface;
begin
   ts:=loadIMG(fn,false,log);
   LoadBtn:=_createSurf(vid_BW-1,vid_BW-1);
   if(ts^.h>vid_BW)
   then _draw_surf(LoadBtn,vid_hBW-(ts^.w div 2),0,ts)
   else _draw_surf(LoadBtn,vid_hBW-(ts^.w div 2),vid_hBW-(ts^.h div 2),ts);
   _FreeSF(ts);
end;

function LoadBtnFS(ts:pSDl_Surface):pSDL_Surface;
var tst:pSDL_Surface;
   coff:single;
begin
   if(ts^.w<=vid_BW)or(ts^.h<=vid_BW)
   then coff:=1
   else
    if(ts^.w<ts^.h)
    then coff:=vid_BW/ts^.w
    else coff:=vid_BW/ts^.h;

   tst:=ROTOZOOMSURFACE(ts, 0, coff, 0);
   LoadBtnFS:=_createSurf(vid_BW-1,vid_BW-1);
   if(tst^.h>vid_BW)
   then _draw_surf(LoadBtnFS,vid_hBW-(tst^.w div 2),2,tst)
   else _draw_surf(LoadBtnFS,vid_hBW-(tst^.w div 2),vid_hBW-(tst^.h div 2),tst);
   rectangleColor(LoadBtnFS,0,0,LoadBtnFS^.w-1,LoadBtnFS^.h-1,c_black);
   rectangleColor(LoadBtnFS,1,1,LoadBtnFS^.w-2,LoadBtnFS^.h-2,c_black);
   SDL_FreeSurface(tst);
end;

procedure _MakeTabsBTN;
var xx:integer;
begin
   xx:=vid_hBW-2;
   spr_uitab[0]:=_createSurf(vid_BW-1,vid_BW-1);
   _draw_surf(spr_uitab[0],-xx,-xx,_tuids[UID_UCommandCenter]._ubtn);
   _draw_surf(spr_uitab[0], xx,-xx,_tuids[UID_UMilitaryUnit ]._ubtn);
   _draw_surf(spr_uitab[0],-xx, xx,_tuids[UID_HKeep]._ubtn);
   _draw_surf(spr_uitab[0], xx, xx,_tuids[UID_HGate]._ubtn);

   xx:=vid_hBW div 2;
   spr_uitab[1]:=_createSurf(vid_BW-1,vid_BW-1);
   _draw_surf(spr_uitab[1],0,-3      ,_tuids[UID_Terminator]._ubtn);
   _draw_surf(spr_uitab[1],0,vid_hBW ,_tuids[UID_Revenant]._ubtn);

   spr_uitab[2]:=_createSurf(vid_BW-1,vid_BW-1);
end;

procedure _MakeUnitBtn;
var u:byte;
  spr:PTUSprite;
begin
   for u:=0 to 255 do
   begin
      with _units[0] do
      begin
         hits:=100;
         uid :=u;
         bld :=true;
         tdir:=270;
         puid:=@_tuids[uid];
      end;
      ui_uasprites[u]:=_unit_spr(@_units[0],false);

      case _tuids[u]._urace of
      r_hell: _units[0].tdir:=225;
      r_uac : _units[0].tdir:=315;
      end;

      spr:=_unit_spr(@_units[0],false);

      _tuids[u]._ubtn:=LoadBtnFS(spr^.surf);
   end;

   _draw_surf(_tuids[UID_UTurret ]._ubtn,vid_hBW-spr_tur [0].hw, 2,spr_tur [0].surf);
   _draw_surf(_tuids[UID_UPTurret]._ubtn,vid_hBW-spr_tur [0].hw, 2,spr_tur [0].surf);
   _draw_surf(_tuids[UID_URTurret]._ubtn,vid_hBW-spr_rtur[0].hw,-2,spr_rtur[0].surf);
end;

procedure _loadFont;
var ts: pSDL_Surface;
    i : byte;
    c : char;
begin
   ts:=loadIMG('font',true);
   font_w :=ts^.h;
   font_iw:=font_w-1;
   font_hw:=font_w div 2;
   spr_font[#0]:=_dsurf;
   for i:=1 to 255 do
   begin
      c:=chr(i);
      spr_font[c]:=_createSurf(font_w,font_w);
      SDL_SetColorKey(spr_font[c],SDL_SRCCOLORKEY+SDL_RLEACCEL,(1 shl 24)-1);
      _rect^.x:=i*font_w;
      _rect^.y:=0;
      _rect^.w:=font_w;
      _rect^.h:=font_w;
      SDL_BLITSURFACE(ts,_rect,spr_font[c],nil);
   end;
   _UIChatVars;
end;

procedure _loadGfx;
var x : integer;
begin
   _dsurf      := _createSurf(2,2);
   _menu_surf  := _createSurf(vid_minw  ,vid_minh  );
   ui_tminimap := _createSurf(ui_mmwidth,ui_mmwidth);
   ui_uminimap := _createSurf(ui_mmwidth,ui_mmwidth);
   boxColor(ui_uminimap,0,0,ui_uminimap^.w,ui_uminimap^.h,c_black);
   SDL_SetColorKey(ui_uminimap,SDL_SRCCOLORKEY,sdl_GetPixelColor(ui_uminimap,0,0));

   spr_dummy.hh  := 1;
   spr_dummy.hw  := 1;
   spr_dummy.surf:= _dsurf;
   spr_pDummy    := @spr_Dummy;

   for x:=1 to vid_mvs do new(vid_vsl[x]);

   _loadFont;

   spr_mback      := loadIMG('mback'   ,false);
   rectangleColor(spr_mback,ui_mmmpx-1,ui_mmmpy-1,ui_mmmpx+ui_mmwidth,ui_mmmpy+ui_mmwidth,c_white);

   spr_cursor     := loadIMG('cursor'  ,true );
   spr_msl        := loadIMG('msl'     ,false);
   spr_mbackmlt   := loadIMG('mbackmlt',false);

   spr_btnsel     := _createSurf(vid_BW-1,vid_BW-1);
   boxColor(spr_btnsel,0,0,vid_BW,vid_BW,c_black);
   SDL_SetColorKey(spr_btnsel,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(spr_btnsel,vid_hBW,vid_hBW));
   rectangleColor(spr_btnsel,0,0,vid_BW-2,vid_BW-2,c_lime);
   rectangleColor(spr_btnsel,1,1,vid_BW-3,vid_BW-3,c_green);

   spr_btnaut     := _createSurf(vid_BW-1,vid_BW-1);
   boxColor(spr_btnaut,0,0,vid_BW,vid_BW,c_black);
   SDL_SetColorKey(spr_btnaut,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_GetPixelColor(spr_btnaut,vid_hBW,vid_hBW));
   rectangleColor(spr_btnaut,0,0,vid_BW-2,vid_BW-2,c_yellow);
   rectangleColor(spr_btnaut,1,1,vid_BW-3,vid_BW-3,c_dyellow);

   spr_b_cancle   := LoadBtn('b_cancle' );
   spr_b_delete   := LoadBtn('b_destroy');
   spr_b_attack   := LoadBtn('b_attack' );
   spr_b_patrol   := LoadBtn('b_patrol' );
   spr_b_move     := LoadBtn('b_move'   );
   spr_b_stop     := LoadBtn('b_stop'   );
   spr_b_hold     := LoadBtn('b_hold'   );
   spr_b_selall   := LoadBtn('b_selall' );
   spr_b_unload   := LoadBtn('b_unload' );
   spr_b_upload   := LoadBtn('b_upload' );
   spr_rspeed     := LoadBtn('b_rfast'  );
   spr_rskip      := LoadBtn('b_rskip'  );
   spr_rpause     := LoadBtn('b_rstop'  );
   spr_rfog       := LoadBtn('b_rfog'   );
   spr_rlog       := LoadBtn('b_rlog'   );
   spr_rvis       := LoadBtn('b_rvis'   );

   spr_b_upgrs[x]:=_dsurf;
   for x:=1 to 255 do spr_b_upgrs[x]:=LoadBtn('b_up'+b2s(x),false);

   for x:=1 to race_n do _lstr(@spr_detect[x],str_f_race[x]+'detect');

   fog_surf[false]:= _createSurf(fog_cw,fog_cw);
   boxColor(fog_surf[false],0,0,fog_cw,fog_cw,c_black);
   SDL_SetAlpha(fog_surf[false],SDL_SRCALPHA or SDL_RLEACCEL,128);

   fog_surf[true]:= _createSurf(fog_cr*2,fog_cr*2);
   boxColor(fog_surf[true],0,0,fog_surf[true]^.w,fog_surf[true]^.h,c_purple);
   filledcircleColor(fog_surf[true],fog_cr,fog_cr,fog_cr,c_black);
   SDL_SetColorKey(fog_surf[true],SDL_SRCCOLORKEY or SDL_RLEACCEL,sdl_GetPixelColor(fog_surf[true],0,0));

   _lstr(@spr_db_h0      ,str_f_race[r_hell]+'db_h0'      );
   _lstr(@spr_db_h1      ,str_f_race[r_hell]+'db_h1'      );
   _lstr(@spr_HAltar     ,str_f_race[r_hell]+'h_altar'    );
   _lstr(@spr_HTotem     ,str_f_race[r_hell]+'h_b7'       );
   _lstr(@spr_HMonastery ,str_f_race[r_hell]+'h_b6'       );
   _lstr(@spr_HFortress  ,str_f_race[r_hell]+'h_fortess'  );
   _lstr(@spr_HBar       ,str_f_race[r_hell]+'h_hbarrak'  );
   _lstr(@spr_mp[r_hell] ,str_f_race[r_hell]+'h_mp'       );
   _lstr(@spr_mp[r_uac ] ,str_f_race[r_uac ]+'u_mp'       );
   _lstr(@spr_db_u0      ,str_f_race[r_uac ]+'db_u0'      );
   _lstr(@spr_db_u1      ,str_f_race[r_uac ]+'db_u1'      );
   _lstr(@spr_mine       ,str_f_race[r_uac ]+'u_mine'     );
   _lstr(@spr_toxin      ,str_f_race[r_uac ]+'toxin'      );
   _lstr(@spr_gear       ,str_f_race[r_uac ]+'gear'       );

   for x:=0 to 28 do _lstr(@spr_lostsoul   [x],str_f_race[r_hell]+'h_u0_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_imp        [x],str_f_race[r_hell]+'h_u1_' +b2s(x));
   for x:=0 to 53 do _lstr(@spr_demon      [x],str_f_race[r_hell]+'h_u2_' +b2s(x));
   for x:=0 to 29 do _lstr(@spr_cacodemon  [x],str_f_race[r_hell]+'h_u3_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_baron      [x],str_f_race[r_hell]+'h_u4_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_knight     [x],str_f_race[r_hell]+'h_u4k_'+b2s(x));
   for x:=0 to 56 do _lstr(@spr_cyberdemon [x],str_f_race[r_hell]+'h_u5_' +b2s(x));
   for x:=0 to 81 do _lstr(@spr_mastermind [x],str_f_race[r_hell]+'h_u6_' +b2s(x));
   for x:=0 to 37 do _lstr(@spr_pain       [x],str_f_race[r_hell]+'h_u7_' +b2s(x));
   for x:=0 to 76 do _lstr(@spr_revenant   [x],str_f_race[r_hell]+'h_u8_' +b2s(x));
   for x:=0 to 78 do _lstr(@spr_mancubus   [x],str_f_race[r_hell]+'h_u9_' +b2s(x));
   for x:=0 to 69 do _lstr(@spr_arachnotron[x],str_f_race[r_hell]+'h_u10_'+b2s(x));
   for x:=0 to 85 do _lstr(@spr_archvile   [x],str_f_race[r_hell]+'h_u11_'+b2s(x));

   for x:=0 to 52 do _lstr(@spr_ZFormer    [x],str_f_race[r_hell]+'h_z0_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_ZSergant   [x],str_f_race[r_hell]+'h_z1_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_ZSSergant  [x],str_f_race[r_hell]+'h_z1s_'+b2s(x));
   for x:=0 to 59 do _lstr(@spr_ZCommando  [x],str_f_race[r_hell]+'h_z2_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_ZBomber    [x],str_f_race[r_hell]+'h_z3_' +b2s(x));
   for x:=0 to 15 do _lstr(@spr_ZFMajor    [x],str_f_race[r_hell]+'h_z4j_'+b2s(x));
   for x:=0 to 52 do _lstr(@spr_ZMajor     [x],str_f_race[r_hell]+'h_z4_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_ZBFG       [x],str_f_race[r_hell]+'h_z5_' +b2s(x));

   for x:=0 to 15 do _lstr(@spr_drone      [x],str_f_race[r_uac ]+'uacd'  +b2s(x));
   for x:=0 to 44 do _lstr(@spr_scout      [x],str_f_race[r_uac ]+'u_u1_' +b2s(x));
   for x:=0 to 52 do _lstr(@spr_medic      [x],str_f_race[r_uac ]+'u_u0_' +b2s(x));
   for x:=0 to 44 do _lstr(@spr_sergant    [x],str_f_race[r_uac ]+'u_u2_' +b2s(x));
   for x:=0 to 44 do _lstr(@spr_ssergant   [x],str_f_race[r_uac ]+'u_u2s_'+b2s(x));
   for x:=0 to 52 do _lstr(@spr_commando   [x],str_f_race[r_uac ]+'u_u3_' +b2s(x));
   for x:=0 to 44 do _lstr(@spr_bomber     [x],str_f_race[r_uac ]+'u_u4_' +b2s(x));
   for x:=0 to 15 do _lstr(@spr_fmajor     [x],str_f_race[r_uac ]+'u_u5j_'+b2s(x));
   for x:=0 to 44 do _lstr(@spr_major      [x],str_f_race[r_uac ]+'u_u5_' +b2s(x));
   for x:=0 to 44 do _lstr(@spr_BFG        [x],str_f_race[r_uac ]+'u_u6_' +b2s(x));
   for x:=0 to 15 do _lstr(@spr_FAPC       [x],str_f_race[r_uac ]+'u_u8_' +b2s(x));
   for x:=0 to 15 do _lstr(@spr_APC        [x],str_f_race[r_uac ]+'uac_tank_' +b2s(x));
   for x:=0 to 55 do _lstr(@spr_Terminator [x],str_f_race[r_uac ]+'u_u9_' +b2s(x));
   for x:=0 to 23 do _lstr(@spr_Tank       [x],str_f_race[r_uac ]+'u_u10_'+b2s(x));
   for x:=0 to 15 do _lstr(@spr_Flyer      [x],str_f_race[r_uac ]+'u_u11_'+b2s(x));

   for x:=0 to 15 do _lstr(@spr_tur        [x],str_f_race[r_uac ]+'ut_'   +b2s(x));
   for x:=0 to 7  do _lstr(@spr_rtur       [x],str_f_race[r_uac ]+'u_rt_' +b2s(x));

   for x:=0 to 3 do
   begin
      _lstr(@spr_HKeep           [x],str_f_race[r_hell]+'h_b0_' +b2s(x));
      _lstr(@spr_HGate           [x],str_f_race[r_hell]+'h_b1_' +b2s(x));
      _lstr(@spr_HSymbol         [x],str_f_race[r_hell]+'h_b2_' +b2s(x));
      _lstr(@spr_HPools          [x],str_f_race[r_hell]+'h_b3_' +b2s(x));
      _lstr(@spr_HTower          [x],str_f_race[r_hell]+'h_b4_' +b2s(x));
      _lstr(@spr_HTeleport       [x],str_f_race[r_hell]+'h_b5_' +b2s(x));

      _lstr(@spr_UCommandCenter  [x],str_f_race[r_uac ]+'u_b0_' +b2s(x));
      _lstr(@spr_UMilitaryUnit   [x],str_f_race[r_uac ]+'u_b1_' +b2s(x));
      _lstr(@spr_UGenerator      [x],str_f_race[r_uac ]+'u_b2_' +b2s(x));
      _lstr(@spr_UWeaponFactory  [x],str_f_race[r_uac ]+'u_b3_' +b2s(x));
      _lstr(@spr_UTurret         [x],str_f_race[r_uac ]+'u_b4_' +b2s(x));
      _lstr(@spr_URadar          [x],str_f_race[r_uac ]+'u_b5_' +b2s(x));
      _lstr(@spr_UVehicleFactory [x],str_f_race[r_uac ]+'u_b6_' +b2s(x));
      _lstr(@spr_UPTurret        [x],str_f_race[r_uac ]+'u_b7_' +b2s(x));
      _lstr(@spr_URocketL        [x],str_f_race[r_uac ]+'u_b8_' +b2s(x));
      _lstr(@spr_URTurret        [x],str_f_race[r_uac ]+'u_b9_' +b2s(x));
   end;

   for x:=0 to 5 do _lstr(@spr_eff_eb   [x],'ef_eb'  +b2s(x));
   for x:=0 to 8 do _lstr(@spr_eff_ebb  [x],'ef_ebb' +b2s(x));
   for x:=0 to 5 do _lstr(@spr_eff_tel  [x],'ef_tel_'+b2s(x));
   for x:=0 to 2 do _lstr(@spr_eff_exp  [x],'ef_exp_'+b2s(x));
   for x:=0 to 4 do _lstr(@spr_eff_exp2 [x],'exp2_'  +b2s(x));
   for x:=0 to 7 do _lstr(@spr_eff_g    [x],'g_'     +b2s(x));
   for x:=0 to 2 do _lstr(@spr_blood    [x],'blood'  +b2s(x));

   for x:=0 to 3  do _lstr(@spr_h_p0    [x],str_f_race[r_hell]+'h_p0_'  +b2s(x));
   for x:=0 to 3  do _lstr(@spr_h_p1    [x],str_f_race[r_hell]+'h_p1_'  +b2s(x));
   for x:=0 to 3  do _lstr(@spr_h_p2    [x],str_f_race[r_hell]+'h_p2_'  +b2s(x));
   for x:=0 to 7  do _lstr(@spr_h_p3    [x],str_f_race[r_hell]+'h_p3_'  +b2s(x));
   for x:=0 to 10 do _lstr(@spr_h_p4    [x],str_f_race[r_hell]+'h_p4_'  +b2s(x));
   for x:=0 to 7  do _lstr(@spr_h_p5    [x],str_f_race[r_hell]+'h_p5_'  +b2s(x));
   for x:=0 to 7  do _lstr(@spr_h_p6    [x],str_f_race[r_hell]+'h_p6_'  +b2s(x));
   for x:=0 to 5  do _lstr(@spr_h_p7    [x],str_f_race[r_hell]+'h_p7_'  +b2s(x));

   for x:=0 to 5  do _lstr(@spr_u_p0    [x],str_f_race[r_uac ]+'u_p0_'  +b2s(x));
   for x:=0 to 3  do _lstr(@spr_u_p1    [x],str_f_race[r_uac ]+'u_p1_'  +b2s(x));
   for x:=0 to 5  do _lstr(@spr_u_p2    [x],str_f_race[r_uac ]+'u_p2_'  +b2s(x));
   for x:=0 to 7  do _lstr(@spr_u_p3    [x],str_f_race[r_uac ]+'u_p3_'  +b2s(x));
   for x:=0 to 3  do _lstr(@spr_eff_bfg [x],str_f_race[r_uac ]+'ef_bfg_'+b2s(x));

   spr_b_ralpos  := _createSurf(vid_BW-1,vid_BW-1);
   _draw_surf(spr_b_ralpos,vid_hBW-20,vid_hBW-(spr_mp[r_hell].hh),spr_mp[r_hell].surf);
   _draw_surf(spr_b_ralpos,vid_hBW+4 ,vid_hBW-(spr_mp[r_uac ].hh),spr_mp[r_uac ].surf);

   _loadMapThemes;
   _loadDecs;
end;




