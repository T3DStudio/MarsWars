
procedure _InitFogR;
var r,x:byte;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _fcx[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
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
   sdl_saveBMP(r_screen,@s[1]);
end;


function rgba2c(r,g,b,a:byte):cardinal;
begin
   rgba2c:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;


procedure _GfxColors;
begin
   c_dred    :=rgba2c(190,  0,  0,255);
   c_red     :=rgba2c(255,  0,  0,255);
   c_ared    :=rgba2c(255,  0,  0,42 );
   c_orange  :=rgba2c(255,140,  0,255);
   c_dorange :=rgba2c(230, 96,  0,255);
   c_brown   :=rgba2c(140, 90, 10,255);
   c_yellow  :=rgba2c(255,255,  0,255);
   c_dyellow :=rgba2c(220,220,  0,255);
   c_lime    :=rgba2c(0  ,255,  0,255);
   c_aqua    :=rgba2c(0  ,255,255,255);
   c_purple  :=rgba2c(255,0  ,255,255);
   c_green   :=rgba2c(0  ,150,0  ,255);
   c_dblue   :=rgba2c(100,100,192,255);
   c_blue    :=rgba2c(50 ,50 ,255,255);
   c_ablue   :=rgba2c(50 ,50 ,255,24 );
   c_white   :=rgba2c(255,255,255,255);
   c_awhite  :=rgba2c(255,255,255,40 );
   c_gray    :=rgba2c(120,120,120,255);
   c_dgray   :=rgba2c(70 ,70 ,70 ,255);
   c_agray   :=rgba2c(80 ,80 ,80 ,128);
   c_black   :=rgba2c(0  ,0  ,0  ,255);
   c_ablack  :=rgba2c(0  ,0  ,0  ,128);
   c_lava    :=rgba2c(222,80 ,0  ,255);

   ui_muc    [false]:=c_dorange;
   ui_muc    [true ]:=c_gray;

   ui_rad_rld[false]:=c_aqua;
   ui_rad_rld[true ]:=c_yellow;
end;

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

procedure SDL_SETpixel(srf:PSDL_SURFACE;x,y:integer;color:cardinal);
var bpp:byte;
begin
   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;

   move( (@(color))^, (srf^.pixels+(y*srf^.pitch)+x*bpp)^, bpp);
end;

function SDL_GETpixel(srf:PSDL_SURFACE;x,y:integer):cardinal;
var bpp:byte;
begin
   SDL_GETpixel:=0;

   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;

   move( (srf^.pixels+(y*srf^.pitch)+x*bpp)^, (@SDL_GETpixel)^, bpp);
end;

function _loadsrf(fn:shortstring):pSDL_SURFACE;
var tmp:pSDL_SURFACE;
begin
   _loadsrf:=r_empty;
   if(not FileExists(fn))then exit;

   fn:=fn+#0;

   tmp:=img_load(@fn[1]);
   if(tmp<>nil)then
   begin
      _loadsrf:=sdl_displayformat(tmp);
      sdl_freesurface(tmp);
   end;
end;

function loadIMG(fn:shortstring;trns,log:boolean):pSDL_SURFACE;
const fextn = 2;
      fexts : array[0..fextn] of shortstring = ('.png','.jpg','.bmp');
var i:integer;
begin
   for i:=0 to fextn do
   begin
      loadIMG:=_loadsrf(str_f_grp+fn+fexts[i]);
      if(loadIMG<>r_empty)then
      begin
         if(trns)then SDL_SetColorKey(loadIMG,SDL_SRCCOLORKEY+SDL_RLEACCEL, sdl_getpixel(loadIMG,0,0));
         break;
      end
      else
        if(i=fextn)and(log)then WriteLog(str_f_grp+fn);
   end;
end;

procedure _FreeSF(sf:PSDL_Surface);
begin
   if(sf<>nil)and(sf<>r_empty)then
   begin
      sdl_FreeSurface(sf);
      sf:=nil;
   end;
end;

function _lstr(fn:shortstring):TMWSprite;
begin
   with _lstr do
   begin
      surf:=LoadIMG(fn,true,true);
      w :=surf^.w;
      h :=surf^.h;
      hw:=surf^.w div 2;
      hh:=surf^.h div 2;
   end;
end;

procedure _MakeLiquidTemplate(surf,ts:pSDL_Surface;xs,ys,d,r:integer;animst,rrs:byte;itb:boolean);
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

   if(rrs>1)then exit;

   if(rrs=0)then
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
   case rrs of
   0: i:=r div 10;
   1: i:=-5;
   end;

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

procedure MakeLiquid;
var ts : psdl_surface;
a,i,
wsp,hsp: integer;
begin
   if(theme_map_plqt=theme_map_lqt)and(theme_map_plqt>0)then exit;
   theme_map_plqt:=theme_map_lqt;

   if(theme_map_lqt<0)or(theme_map_lqt>=theme_spr_liquidn)then
   begin
      ts                :=r_dterrain;
      theme_liquid_animt:=0;
      theme_liquid_color:=c_gray;
      theme_liquid_animm:=fr_hfps;
   end
   else
   begin
      ts                :=theme_spr_liquids[theme_map_lqt].surf;
      theme_liquid_animt:=theme_anm_liquids[theme_map_lqt];
      theme_liquid_color:=theme_clr_liquids[theme_map_lqt];
      theme_liquid_animm:=theme_ant_liquids[theme_map_lqt];
   end;

   case theme_liquid_animt of
   0: begin
         wsp:=(ts^.w div 4)*((map_seed  mod 3)-1);
         hsp:=(ts^.h div 4)*((abs(map_seed2) mod 3)-1);
         if(wsp=0)and(hsp=0)then wsp:=(ts^.w div 4);
      end;
   else
      wsp:=0;
      hsp:=0;
   end;

   for i:=1 to LiquidRs do
    for a:=1 to LiquidAnim do
     with spr_liquid[a,i] do
     begin
        w:=DID_R[i]*2+10;
        h:=w;
        _FreeSF(surf);
        surf:=_createSurf(w,w);
        hw:=w div 2;
        hh:=hw;

        _MakeLiquidTemplate(surf,ts,-ts^.w-(a*wsp),-ts^.h-(a*hsp),w,hh,theme_liquid_animt,0,false);

        if(theme_liquid_animt=1)then
         case a of
         1,3 : boxColor(surf,0,0,w,w,rgba2c(0,0,0,30));
         2   : boxColor(surf,0,0,w,w,rgba2c(0,0,0,60));
         end;

        SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
     end;
end;

procedure MakeLiquidBack;
var ts :psdl_surface;
    i  :byte;
begin
   if(theme_map_pblqt=theme_map_blqt)and(theme_map_blqt>0)then exit;
   theme_map_pblqt:=theme_map_blqt;

   if(theme_map_blqt<0)or(theme_map_blqt>=theme_spr_terrainn)
   then ts := r_dterrain
   else ts := theme_spr_terrains[theme_map_blqt].surf;

   for i:=1 to LiquidRs do
    with spr_liquidb[i] do
    begin
       w:=DID_R[i]*2+30;
       h:=w;
       _FreeSF(surf);
       surf:=_createSurf(w,w);
       hw:=w div 2;
       hh:=hw;
       _MakeLiquidTemplate(surf,ts,0,0,w,hw,0,theme_liquid_style,true);
       boxColor(surf,0,0,w,w,rgba2c(0,0,0,50));
       SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
    end;
end;

procedure MakeCrater;
var ts : psdl_surface;
    i  : integer;
begin
   if(theme_map_pcrt=theme_map_crt)and(theme_map_pcrt>0)then exit;
   theme_map_pcrt:=theme_map_crt;

   if(theme_map_crt<0)or(theme_map_crt>=theme_spr_terrainn)
   then ts := r_dterrain
   else ts := theme_spr_terrains[theme_map_crt].surf;

   for i:=1 to crater_ri do
    with spr_crater[i] do
    begin
       w:=crater_r[i]*2;
       h:=w;
       _FreeSF(surf);
       surf:=_createSurf(w,w);
       hw:=crater_r[i];
       hh:=hw;
       _MakeLiquidTemplate(surf,ts,0,0,w,hw,0,theme_crater_style,false);
       boxColor(surf,0,0,w,w,rgba2c(0,0,0,70));
       if(theme_crater_style<2)then
       SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
    end;
end;

procedure MakeTerrain;
var x,y,w,h:integer;
    ter_s  :pSDL_Surface;
begin
   if(theme_map_ptrt=theme_map_trt)and(theme_map_ptrt>0)then exit;
   theme_map_ptrt:=theme_map_trt;

   if(vid_terrain<>nil) then
   begin
      sdl_freesurface(vid_terrain);
      vid_terrain:=nil;
   end;

   if(theme_map_trt<0)or(theme_map_trt>=theme_spr_terrainn)then
   begin
      ter_w:=1;
      ter_h:=1;
      vid_terrain:=r_dterrain;
      SDl_FillRect(vid_terrain,nil,c_black);
   end
   else
   begin
      ter_s:=theme_spr_terrains[theme_map_trt].surf;

      ter_w:=ter_s^.w;
      ter_h:=ter_s^.h;
      w:=vid_sw+(ter_w shl 1);
      h:=vid_sh+(ter_h shl 1);
      vid_terrain:=_createSurf(w,h);
      x:=0;
      while (x<w) do
      begin
         y:=0;
         while (y<w) do
         begin
            _draw_surf(vid_terrain,x,y,ter_s);
            inc(y,ter_s^.h);
         end;
         inc(x,ter_s^.w);
      end;
   end;
end;



function LoadBtn(fn:shortstring;bw:integer):pSDL_Surface;
var ts:pSDl_Surface;
   hwb:integer;
begin
   hwb:=bw div 2;
   ts:=loadIMG(fn,false,true);
   LoadBtn:=_createSurf(bw-1,bw-1);
   if(ts^.h>bw)
   then _draw_surf(LoadBtn,hwb-(ts^.w div 2),0,ts)
   else _draw_surf(LoadBtn,hwb-(ts^.w div 2),hwb-(ts^.h div 2),ts);
   _FreeSF(ts);
end;

function LoadBtnFS(ts:pSDl_Surface;bw:integer):pSDL_Surface;
var tst:pSDL_Surface;
   coff:single;
    hwb:integer;
begin
   hwb:=bw div 2;

   if(ts^.w<=bw)or(ts^.h<=bw)
   then coff:=1
   else
    if(ts^.w<ts^.h)
    then coff:=bw/ts^.w
    else coff:=bw/ts^.h;

   tst:=ROTOZOOMSURFACE(ts, 0, coff, 0);
   LoadBtnFS:=_createSurf(bw-1,bw-1);
   if(tst^.h>bw)
   then _draw_surf(LoadBtnFS,hwb-(tst^.w div 2),2,tst)
   else _draw_surf(LoadBtnFS,hwb-(tst^.w div 2),hwb-(tst^.h div 2),tst);
   rectangleColor(LoadBtnFS,0,0,LoadBtnFS^.w-1,LoadBtnFS^.h-1,c_black);
   rectangleColor(LoadBtnFS,1,1,LoadBtnFS^.w-2,LoadBtnFS^.h-2,c_black);
   SDL_FreeSurface(tst);
end;


procedure LoadFont;
var i:byte;
    c:char;
  ccc:cardinal;
 fspr:pSDL_Surface;
begin
   ccc:=(1 shl 24)-1;
   fspr:=loadIMG('font',false,true);
   for i:=0 to 255 do
   begin
      c:=chr(i);
      font_ca[c]:=_createSurf(font_w,font_w);
      SDL_FillRect(font_ca[c],nil,0);
      SDL_SetColorKey(font_ca[c],SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);

      _rect^.x:=ord(i)*font_w;
      _rect^.y:=0;
      _rect^.w:=font_w;
      _rect^.h:=font_w;
      SDL_BLITSURFACE(fspr,_rect,font_ca[c],nil);
   end;
   _FreeSF(fspr);
end;

{$include _themes.pas}

procedure _LoadGraphics;
var x:integer;
begin
   r_empty   :=_createSurf(1,1);
   r_minimap :=_createSurf(vid_panelw-1,vid_panelw-1);
   r_bminimap:=_createSurf(vid_panelw-1,vid_panelw-1);

   for x:=1 to vid_mvs do new(vid_vsl[x]);

   pspr_dummy:=@spr_dummy;
   spr_dummy.hh  :=1;
   spr_dummy.hw  :=1;
   spr_dummy.surf:=r_empty;

   LoadFont;

   fog_surf := _createSurf(fog_cr*2,fog_cr*2);
   boxColor(fog_surf,0,0,fog_surf^.w,fog_surf^.h,c_purple);
   filledcircleColor(fog_surf,fog_cr,fog_cr,fog_cr,c_black);
   SDL_SetColorKey(fog_surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(fog_surf,0,0));

   spr_mback:= loadIMG('mback'   ,false,true);

   r_menu:=_createSurf(max2(vid_minw,spr_mback^.w), max2(vid_minh,spr_mback^.h));

   mv_x:=(vid_vw-r_menu^.w) div 2;
   mv_y:=(vid_vh-r_menu^.h) div 2;


   spr_b_action   := LoadBtn('b_action' ,vid_bw);
   spr_b_delete   := LoadBtn('b_destroy',vid_bw);
   spr_b_attack   := LoadBtn('b_attack' ,vid_bw);
   spr_b_move     := LoadBtn('b_move'   ,vid_bw);
   spr_b_patrol   := LoadBtn('b_patrol' ,vid_bw);
   spr_b_apatrol  := LoadBtn('b_apatrol',vid_bw);
   spr_b_stop     := LoadBtn('b_stop'   ,vid_bw);
   spr_b_hold     := LoadBtn('b_hold'   ,vid_bw);
   spr_b_selall   := LoadBtn('b_selall' ,vid_bw);
   spr_b_cancel   := LoadBtn('b_cancle' ,vid_bw);
   spr_b_rfast    := LoadBtn('b_rfast'  ,vid_bw);
   spr_b_rskip    := LoadBtn('b_rskip'  ,vid_bw);
   spr_b_rfog     := LoadBtn('b_fog'    ,vid_bw);
   spr_b_rlog     := LoadBtn('b_log'    ,vid_bw);
   spr_b_rstop    := LoadBtn('b_rstop'  ,vid_bw);
   spr_b_rvis     := LoadBtn('b_rvis'   ,vid_bw);
   spr_b_rclck    := LoadBtn('b_rclick' ,vid_bw);

   for x:=0 to 2 do spr_tabs[x]:=LoadBtn('tabs'+b2s(x),vid_tbw);
   spr_tabs[3]:=LoadBtnFS(spr_b_action,vid_tbw);

   for x:=0 to ui_ubtns do
   begin
   spr_b_up[r_hell,x]:=LoadBtn('b_h_up'+b2s(x),vid_bw);
   spr_b_up[r_uac ,x]:=LoadBtn('b_u_up'+b2s(x),vid_bw);
   end;

   spr_cursor     := loadIMG('cursor'   ,true ,true);

   spr_c_earth    := LoadIMG('M_EARTH'  ,false,true);
   spr_c_mars     := LoadIMG('M_MARS'   ,false,true);
   spr_c_hell     := LoadIMG('M_HELL'   ,false,true);
   spr_c_phobos   := LoadIMG('M_PHOBOS' ,false,true);
   spr_c_deimos   := LoadIMG('M_DEIMOS' ,false,true);

   spr_u_portal   := _lstr('u_portal' );
   spr_db_h0      := _lstr('db_h0'    );
   spr_db_h1      := _lstr('db_h1'    );
   spr_db_u0      := _lstr('db_u0'    );
   spr_db_u1      := _lstr('db_u1'    );
   spr_HAltar     := _lstr('h_altar'  );
   spr_HTotem     := _lstr('h_b7'     );
   spr_HMonastery := _lstr('h_b6'     );
   spr_HFortress  := _lstr('h_fortess');
   spr_HBar       := _lstr('h_hbarrak');
   spr_HEye       := _lstr('heye'     );
   spr_mine       := _lstr('u_mine'   );
   spr_toxin      := _lstr('toxin'    );
   spr_gear       := _lstr('gear'     );

   spr_mp[r_hell] := _lstr('h_mp'     );
   spr_mp[r_uac ] := _lstr('u_mp'     );

   for x:=0 to 3  do spr_eff_bfg    [x]:=_lstr('ef_bfg_'  +b2s(x));
   for x:=0 to 5  do spr_eff_eb     [x]:=_lstr('ef_eb'    +b2s(x));
   for x:=0 to 8  do spr_eff_ebb    [x]:=_lstr('ef_ebb'   +b2s(x));
   for x:=0 to 5  do spr_eff_tel    [x]:=_lstr('ef_tel_'  +b2s(x));
   for x:=0 to 2  do spr_eff_exp    [x]:=_lstr('ef_exp_'  +b2s(x));
   for x:=0 to 4  do spr_eff_exp2   [x]:=_lstr('exp2_'    +b2s(x));
   for x:=0 to 7  do spr_eff_g      [x]:=_lstr('g_'       +b2s(x));
   for x:=0 to 3  do spr_h_p0       [x]:=_lstr('h_p0_'    +b2s(x));
   for x:=0 to 3  do spr_h_p1       [x]:=_lstr('h_p1_'    +b2s(x));
   for x:=0 to 3  do spr_h_p2       [x]:=_lstr('h_p2_'    +b2s(x));
   for x:=0 to 7  do spr_h_p3       [x]:=_lstr('h_p3_'    +b2s(x));
   for x:=0 to 10 do spr_h_p4       [x]:=_lstr('h_p4_'    +b2s(x));
   for x:=0 to 7  do spr_h_p5       [x]:=_lstr('h_p5_'    +b2s(x));
   for x:=0 to 7  do spr_h_p6       [x]:=_lstr('h_p6_'    +b2s(x));
   for x:=0 to 5  do spr_h_p7       [x]:=_lstr('h_p7_'    +b2s(x));
   for x:=0 to 5  do spr_u_p0       [x]:=_lstr('u_p0_'    +b2s(x));
   for x:=0 to 3  do spr_u_p1       [x]:=_lstr('u_p1_'    +b2s(x));
   for x:=0 to 5  do spr_u_p2       [x]:=_lstr('u_p2_'    +b2s(x));
   for x:=0 to 3  do spr_u_p3       [x]:=_lstr('u_p3_'    +b2s(x));
   for x:=0 to 2  do spr_blood      [x]:=_lstr('blood'    +b2s(x));
   for x:=0 to 28 do spr_lostsoul   [x]:=_lstr('h_u0_'    +b2s(x));
   for x:=0 to 52 do spr_imp        [x]:=_lstr('h_u1_'    +b2s(x));
   for x:=0 to 53 do spr_demon      [x]:=_lstr('h_u2_'    +b2s(x));
   for x:=0 to 29 do spr_cacodemon  [x]:=_lstr('h_u3_'    +b2s(x));
   for x:=0 to 52 do spr_baron      [x]:=_lstr('h_u4_'    +b2s(x));
   for x:=0 to 52 do spr_knight     [x]:=_lstr('h_u4k_'   +b2s(x));
   for x:=0 to 56 do spr_cyberdemon [x]:=_lstr('h_u5_'    +b2s(x));
   for x:=0 to 81 do spr_mastermind [x]:=_lstr('h_u6_'    +b2s(x));
   for x:=0 to 37 do spr_pain       [x]:=_lstr('h_u7_'    +b2s(x));
   for x:=0 to 76 do spr_revenant   [x]:=_lstr('h_u8_'    +b2s(x));
   for x:=0 to 78 do spr_mancubus   [x]:=_lstr('h_u9_'    +b2s(x));
   for x:=0 to 69 do spr_arachnotron[x]:=_lstr('h_u10_'   +b2s(x));
   for x:=0 to 85 do spr_archvile   [x]:=_lstr('h_u11_'   +b2s(x));
   for x:=0 to 52 do spr_ZFormer    [x]:=_lstr('h_z0_'    +b2s(x));
   for x:=0 to 31 do spr_ZEngineer  [x]:=_lstr('h_z0s_'   +b2s(x));
   for x:=0 to 52 do spr_ZSergant   [x]:=_lstr('h_z1_'    +b2s(x));
   for x:=0 to 52 do spr_ZSSergant  [x]:=_lstr('h_z1s_'   +b2s(x));
   for x:=0 to 59 do spr_ZCommando  [x]:=_lstr('h_z2_'    +b2s(x));
   for x:=0 to 52 do spr_ZBomber    [x]:=_lstr('h_z3_'    +b2s(x));
   for x:=0 to 15 do spr_ZFMajor    [x]:=_lstr('h_z4j_'   +b2s(x));
   for x:=0 to 52 do spr_ZMajor     [x]:=_lstr('h_z4_'    +b2s(x));
   for x:=0 to 52 do spr_ZBFG       [x]:=_lstr('h_z5_'    +b2s(x));
   for x:=0 to 44 do spr_engineer   [x]:=_lstr('u_u1_'    +b2s(x));
   for x:=0 to 52 do spr_medic      [x]:=_lstr('u_u0_'    +b2s(x));
   for x:=0 to 44 do spr_sergant    [x]:=_lstr('u_u2_'    +b2s(x));
   for x:=0 to 44 do spr_ssergant   [x]:=_lstr('u_u2s_'   +b2s(x));
   for x:=0 to 52 do spr_commando   [x]:=_lstr('u_u3_'    +b2s(x));
   for x:=0 to 44 do spr_bomber     [x]:=_lstr('u_u4_'    +b2s(x));
   for x:=0 to 15 do spr_fmajor     [x]:=_lstr('u_u5j_'   +b2s(x));
   for x:=0 to 44 do spr_major      [x]:=_lstr('u_u5_'    +b2s(x));
   for x:=0 to 44 do spr_BFG        [x]:=_lstr('u_u6_'    +b2s(x));
   for x:=0 to 15 do spr_FAPC       [x]:=_lstr('u_u8_'    +b2s(x));
   for x:=0 to 15 do spr_APC        [x]:=_lstr('uac_tank_'+b2s(x));
   for x:=0 to 55 do spr_Terminator [x]:=_lstr('u_u9_'    +b2s(x));
   for x:=0 to 23 do spr_Tank       [x]:=_lstr('u_u10_'   +b2s(x));
   for x:=0 to 15 do spr_Flyer      [x]:=_lstr('u_u11_'   +b2s(x));
   for x:=0 to 15 do spr_tur        [x]:=_lstr('ut_'      +b2s(x));
   for x:=0 to 7  do spr_rtur       [x]:=_lstr('u_rt_'    +b2s(x));
   for x:=0 to 7  do spr_trans      [x]:=_lstr('transport'+b2s(x));
   for x:=0 to 1  do spr_sport      [x]:=_lstr('sport'    +b2s(x));
   for x:=0 to 5  do spr_ubase      [x]:=_lstr('u_base'   +b2s(x));
   for x:=0 to 3 do
   begin
      spr_HKeep           [x]:=_lstr('h_b0_'  +b2s(x));
      spr_HGate           [x]:=_lstr('h_b1_'  +b2s(x));
      spr_HSymbol         [x]:=_lstr('h_b2_'  +b2s(x));
      spr_HPools          [x]:=_lstr('h_b3_'  +b2s(x));
      spr_HAPools         [x]:=_lstr('h_b3_'  +b2s(x)+'a');
      spr_HTower          [x]:=_lstr('h_b4_'  +b2s(x));
      spr_HTeleport       [x]:=_lstr('h_b5_'  +b2s(x));
      spr_HCC             [x]:=_lstr('h_hcc_' +b2s(x));
      spr_HMUnit          [x]:=_lstr('h_hbar_'+b2s(x));
      spr_HMUnita         [x]:=_lstr('h_hbar_'+b2s(x)+'a');

      spr_UCommandCenter  [x]:=_lstr('u_b0_'  +b2s(x));
      spr_UMilitaryUnit   [x]:=_lstr('u_b1_'  +b2s(x));
      spr_UAMilitaryUnit  [x]:=_lstr('u_b1_'  +b2s(x)+'a');
      spr_UGenerator      [x]:=_lstr('u_b2_'  +b2s(x));
      spr_UWeaponFactory  [x]:=_lstr('u_b3_'  +b2s(x));
      spr_UAWeaponFactory [x]:=_lstr('u_b3_'  +b2s(x)+'a');
      spr_UTurret         [x]:=_lstr('u_b4_'  +b2s(x));
      spr_URadar          [x]:=_lstr('u_b5_'  +b2s(x));
      spr_UVehicleFactory [x]:=_lstr('u_b6_'  +b2s(x));
      spr_UPTurret        [x]:=_lstr('u_b7_'  +b2s(x));
      spr_URocketL        [x]:=_lstr('u_b8_'  +b2s(x));
      spr_URTurret        [x]:=_lstr('u_b9_'  +b2s(x));
      spr_UNuclearPlant   [x]:=_lstr('u_b10_' +b2s(x));

      spr_cbuild          [x]:=_lstr('build'  +b2s(x));

      if(x=0)
      then spr_HAGate     [x]:=spr_HGate[x]
      else spr_HAGate     [x]:=_lstr('h_b1_'  +b2s(x-1)+'a');
   end;

   {for x:=0 to ui_ubtns do
   begin
      spr_b_b    [r_hell     ,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,true ,x]])^.surf,vid_BW );
      spr_ui_oico[r_hell,true,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,true ,x]])^.surf,vid_oiw);

      spr_b_b    [r_uac      ,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,true ,x]])^.surf,vid_BW );
      spr_ui_oico[r_uac ,true,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,true ,x]])^.surf,vid_oiw);
   end;

   _draw_surf(spr_b_b[r_uac ,4 ],vid_hBW-spr_tur [6].hw,0,spr_tur [4].surf);
   _draw_surf(spr_b_b[r_uac ,7 ],vid_hBW-spr_tur [7].hw,0,spr_tur [0].surf);
   _draw_surf(spr_b_b[r_uac ,10],vid_hBW-spr_rtur[7].hw,0,spr_rtur[6].surf);

   for x:=0 to _uts do
   begin
      with _ulst[cl2uid[r_hell,false,x]] do dir:=315;
      spr_b_u    [r_hell      ,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,false,x]])^.surf,vid_BW );
      spr_ui_oico[r_hell,false,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,false,x]])^.surf,vid_oiw);
      if(cl2uid[r_hell,false,x]=UID_Baron)then
      begin
         spr_b_knight  :=spr_b_u    [r_hell      ,x];
         spr_iob_knight:=spr_ui_oico[r_hell,false,x];
         with _ulst[UID_Baron] do buff[ub_advanced]:=1;
         spr_b_baron   :=LoadBtnFS(_unit_spr(@_ulst[UID_Baron])^.surf,vid_BW );
         spr_iob_baron :=LoadBtnFS(_unit_spr(@_ulst[UID_Baron])^.surf,vid_oiw);
         with _ulst[UID_Baron] do buff[ub_advanced]:=0;
      end;

      with _ulst[cl2uid[r_uac ,false,x]] do dir:=225;
      spr_b_u    [r_uac       ,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,false,x]])^.surf,vid_BW);
      spr_ui_oico[r_uac ,false,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,false,x]])^.surf,vid_oiw);
   end; }

   InitThemes;
end;


procedure Map_tdmake;
var i,ix,iy,rn:integer;
begin
   MaxTDecsS:=(vid_sw*vid_sh) div 10000;
   setlength(_TDecs,MaxTDecsS);

   vid_mwa:= vid_sw+vid_ab*2;
   vid_mha:= vid_sh+vid_ab*2;

   ix:=longint(map_seed) mod vid_mwa;
   iy:=(map_seed2*5+ix)  mod vid_mha;
   rn:=ix*iy;
   for i:=1 to MaxTDecsS do
    with _TDecs[i-1] do
    begin
       inc(rn,17);
       ix:=_genx(ix+rn       ,vid_mwa,false);
       iy:=_genx(iy+sqr(ix*i),vid_mha,false);
       x :=ix;
       y :=iy;
    end;
end;

procedure _vidvars;
begin
   vid_vmb_x1   := vid_vw-vid_vmb_x0;
   vid_vmb_y1   := vid_vh-vid_vmb_y0;

   ui_textx     := vid_mapx+4;
   ui_texty     := vid_mapy+4;
   ui_hinty     := vid_mapy+vid_sh-60;
   ui_chaty     := ui_hinty-10;
   ui_oicox     := vid_mapx+vid_sw-4;

   ui_uiuphx    := vid_mapx+(vid_sw div 2);

   ui_ingamecl:=(vid_sw-font_w) div font_w;
   if(spr_mback<>nil)then
   begin
      mv_x:=(vid_vw-spr_mback^.w) div 2;
      mv_y:=(vid_vh-spr_mback^.h) div 2;
   end;
   fog_vfw      :=(vid_sw div fog_cw)+2;
   fog_vfh      :=(vid_sh div fog_cw)+2;

   map_mmvw     := round(vid_sw*map_mmcx);
   map_mmvh     := round(vid_sh*map_mmcx);
   _view_bounds;

   Map_tdmake;
end;

procedure _ScreenSurfaces;
const
  ui_ex = 3;
  ui_ax = ui_ex+vid_BW+vid_hBW;
  ystop = 14;
var i,y:integer;

procedure pline(x0,y0,x1,y1:integer;color:cardinal);
begin
   if(vid_ppos<2)
   then lineColor(r_panel,x0,y0,x1,y1,color)
   else lineColor(r_panel,y0,x0,y1,x1,color);
end;
procedure prect(x0,y0,x1,y1:integer;color:cardinal);
begin
   if(vid_ppos<2)
   then rectangleColor(r_panel,x0,y0,x1,y1,color)
   else rectangleColor(r_panel,y0,x0,y1,x1,color);
end;

begin
   _FreeSF(r_uipanel );
   _FreeSF(r_panel   );
   _FreeSF(r_dterrain);

   if(vid_ppos<2)then // left-right
   begin
      vid_sw:=vid_vw-vid_panelw;
      vid_sh:=vid_vh;

      if(vid_ppos=0)
      then vid_mapx:=vid_panelw
      else vid_mapx:=0;
      vid_mapy:=0;

      if(vid_ppos=0)
      then vid_panelx:=0
      else vid_panelx:=vid_sw;
      vid_panely:=0;

      r_uipanel:=_createSurf(vid_panelw+1,vid_vh);
      r_panel  :=_createSurf(vid_panelw+1,vid_vh);

      vlineColor(r_panel,ui_h3bw       ,vid_panelw,vid_panelw+ui_h3bw,c_white);
      vlineColor(r_panel,ui_hwp        ,vid_panelw,vid_panelw+ui_h3bw,c_white);
      vlineColor(r_panel,ui_hwp+ui_h3bw,vid_panelw,vid_panelw+ui_h3bw,c_white);

      y:=vid_BW*14;
      vlineColor(r_panel,vid_BW ,vid_panelw+vid_BW,y,c_white);
      vlineColor(r_panel,vid_2BW,vid_panelw+vid_BW,y,c_white);

      ui_iy     := vid_panelw+3;
      ui_energx := (ui_hwp+ui_h3bw) div 2;
      ui_armyx  := (ui_hwp+ui_h3bw+vid_panelw) div 2;

      characterColor(r_panel,ui_ex,ui_iy,'E',c_aqua  );
      characterColor(r_panel,ui_ax,ui_iy,'A',c_orange);
   end
   else
   begin
      vid_sw:=vid_vw;
      vid_sh:=vid_vh-vid_panelw;

      vid_mapx:=0;
      if(vid_ppos=2)
      then vid_mapy:=vid_panelw-1
      else vid_mapy:=0;

      vid_panelx:=0;
      if(vid_ppos=2)
      then vid_panely:=0
      else vid_panely:=vid_sh-1;

      r_uipanel:=_createSurf(vid_sw,vid_panelw+1);
      r_panel  :=_createSurf(vid_sw,vid_panelw+1);

      y:=vid_BW*14;
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_BW ,c_white);
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_2BW,c_white);

      vlineColor(r_panel,y+vid_BW  ,0,vid_BW,c_white);
      vlineColor(r_panel,y+vid_BW*2,0,vid_BW,c_white);
      vlineColor(r_panel,y+vid_BW*3,0,vid_BW,c_white);
      hlineColor(r_panel,y+vid_BW  ,y+vid_BW*3,vid_BW  ,c_white);

      ui_iy     := 3;
      ui_energx := y+vid_BW+vid_hBW+2;
      ui_armyx  := y+vid_BW*2+vid_hBW;

      inc(y,vid_BW);
      characterColor(r_panel,y       +2,ui_iy,'E',c_aqua  );
      characterColor(r_panel,y+vid_BW+2,ui_iy,'A',c_orange);

       ui_iy := 23;
   end;

   rectangleColor(r_panel,0,0,r_panel^.w-1,r_panel^.h-1,c_white);
   pline(0,vid_panelw,vid_panelw,vid_panelw,c_white);

   pline(0,vid_panelw+ui_h3bw,r_panel^.w,vid_panelw+ui_h3bw,c_white);
   pline(0,vid_panelw+vid_BW ,r_panel^.w,vid_panelw+vid_BW ,c_white);

   for y:=0 to 3 do
   pline(y*vid_tBW,vid_panelw+ui_h3bw,y*vid_tBW,vid_panelw+vid_BW,c_white);

   i:=4;
   y:=vid_BW*i;
   while (i<=ystop) do
   begin
      pline(0,y,vid_panelw,y,c_white);
      inc(i,1);
      inc(y,vid_BW);
   end;

   _draw_surf(r_uipanel,0,0,r_panel);

   r_dterrain:=_createSurf(vid_sw,vid_sh);

   _vidvars;
end;

procedure _MakeScreen;
begin
   if (r_screen<>nil) then sdl_freesurface(r_screen);

   if(_fscr)
   then r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, _vflags + SDL_FULLSCREEN)
   else r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, _vflags);

   if(r_screen=nil)then begin WriteError; exit; end;

   _ScreenSurfaces;
end;


