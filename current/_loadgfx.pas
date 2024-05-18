
procedure InitRX2Y;
var r,x:integer;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _RX2Y[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
end;

procedure MakeScreenshot;
var i:integer;
    s:shortstring;
begin
   i:=0;
   repeat
      i+=1;
      s:=str_screenshot+i2s(i)+'.bmp';
   until not FileExists(s);
   s:=s+#0;
   sdl_saveBMP(r_screen,@s[1]);
end;

procedure gfx_InitColors;
begin
   c_dred    :=rgba2c(190,  0,  0,255);
   c_red     :=rgba2c(255,  0,  0,255);
   c_ared    :=rgba2c(255,  0,  0,82 );
   c_orange  :=rgba2c(255,140,  0,255);
   c_dorange :=rgba2c(230, 96,  0,255);
   c_brown   :=rgba2c(140, 90, 10,255);
   c_yellow  :=rgba2c(255,255,  0,255);
   c_dyellow :=rgba2c(220,220,  0,255);
   c_lime    :=rgba2c(0  ,255,  0,255);
   c_alime   :=rgba2c(0  ,255,  0,42 );
   c_aaqua   :=rgba2c(0  ,255,255,42 );
   c_aqua    :=rgba2c(0  ,255,255,255);
   c_purple  :=rgba2c(255,0  ,255,255);
   c_green   :=rgba2c(0  ,150,0  ,255);
   c_agreen  :=rgba2c(0  ,150,0  ,42 );
   c_dblue   :=rgba2c(100,100,192,255);
   c_blue    :=rgba2c(50 ,50 ,255,255);
   c_ablue   :=rgba2c(50 ,50 ,255,24 );
   c_white   :=rgba2c(255,255,255,255);
   c_awhite  :=rgba2c(255,255,255,40 );
   c_gray    :=rgba2c(120,120,120,255);
   c_ltgray  :=rgba2c(200,200,200,255);
   c_dgray   :=rgba2c(70 ,70 ,70 ,255);
   c_agray   :=rgba2c(80 ,80 ,80 ,128);
   c_black   :=rgba2c(0  ,0  ,0  ,255);
   c_ablack  :=rgba2c(0  ,0  ,0  ,128);
   c_lava    :=rgba2c(222,80 ,0  ,255);

   ui_max_color[false]:=c_dorange;
   ui_max_color[true ]:=c_ltgray;
   ui_cenergy  [false]:=c_white;
   ui_cenergy  [true ]:=c_red;
   ui_limit    [false]:=c_white;
   ui_limit    [true ]:=c_red;

   ui_blink_color2 [false]:=c_black;
   ui_blink_color2 [true ]:=c_yellow;

   ui_blink_color1 [false]:=c_black;
   ui_blink_color1 [true ]:=c_gray;
end;

function gfx_SDLSurfaceCreate(tw,th:integer):pSDL_Surface;
var ts1,ts2:pSDL_Surface;
begin
   gfx_SDLSurfaceCreate:=nil;
   ts1:=sdl_createRGBSurface(0,tw,th,vid_bpp,0,0,0,0);
   if(ts1=nil)then
   begin
      WriteSDLError;
      HALT;
   end
   else
   begin
      ts2:=sdl_displayformat(ts1);
      SDL_FreeSurface(ts1);
      if(ts2=nil)then
      begin
         WriteSDLError;
         HALT;
      end;
      gfx_SDLSurfaceCreate:=ts2;
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

function gfx_SDLSurfaceLoadFromFile(fn:shortstring):pSDL_SURFACE;
var tmp:pSDL_SURFACE;
begin
   gfx_SDLSurfaceLoadFromFile:=r_empty;
   if(not FileExists(fn))then exit;

   fn:=fn+#0;

   tmp:=img_load(@fn[1]);
   if(tmp<>nil)then
   begin
      gfx_SDLSurfaceLoadFromFile:=sdl_displayformat(tmp);
      sdl_freesurface(tmp);
   end;
end;

function gfx_SDLSurfaceLoad(fn:shortstring;trns,log:boolean):pSDL_SURFACE;
const fextn = 2;
      fexts : array[0..fextn] of shortstring = ('.png','.jpg','.bmp');
var i:integer;
begin
   for i:=0 to fextn do
   begin
      gfx_SDLSurfaceLoad:=gfx_SDLSurfaceLoadFromFile(str_f_grp+fn+fexts[i]);
      if(gfx_SDLSurfaceLoad<>r_empty)then
      begin
         if(trns)then SDL_SetColorKey(gfx_SDLSurfaceLoad,SDL_SRCCOLORKEY+SDL_RLEACCEL, sdl_getpixel(gfx_SDLSurfaceLoad,0,0));
         break;
      end
      else
        if(i=fextn)and(log)then WriteLog(str_f_grp+fn);
   end;
end;

procedure gfx_SDLSurfaceFree(sf:PSDL_Surface);
begin
   if(sf<>nil)and(sf<>r_empty)then
   begin
      sdl_FreeSurface(sf);
      sf:=nil;
   end;
end;

procedure gfx_MWTextureLoad(mws:PTMWTexture;fn:shortstring;firstload,log:boolean);
begin
   with mws^ do
   begin
      if(not firstload)then gfx_SDLSurfaceFree(sdlSurface);
      sdlSurface:=gfx_SDLSurfaceLoad(fn,true,log);
      w :=sdlSurface^.w;
      h :=sdlSurface^.h;
      hw:=sdlSurface^.w div 2;
      hh:=sdlSurface^.h div 2;
   end;
end;

procedure gfx_MWSModelLoad(mwsm:PTMWSModel;name:shortstring;_mkind:byte;firstload:boolean);
var t:TMWTexture;
procedure calcSelectionRect(ip:pinteger;vl:integer);
begin
   if(ip^=0)
   then ip^:=vl
   else ip^:=(ip^+vl) div 2;
end;
begin
   with mwsm^ do
   begin
      if(firstload=false)then
       while(sm_listn>0)do
       begin
          gfx_SDLSurfaceFree(sm_list[sm_listn-1].sdlSurface);
          sm_listn-=1;
       end;

      sm_sel_hw:=0;
      sm_sel_hh:=0;
      sm_listn :=0;
      setlength(sm_list,sm_listn);

      gfx_MWTextureLoad(@t,name,firstload,false);
      if(t.sdlSurface<>r_empty)then
      begin
         sm_listn+=1;
         setlength(sm_list,sm_listn);
         sm_list[sm_listn-1]:=t;
         calcSelectionRect(@sm_sel_hw,t.hw);
         calcSelectionRect(@sm_sel_hh,t.hh);
      end;

      while true do
      begin
         gfx_MWTextureLoad(@t,name+i2s(sm_listn),firstload,false);
         if(t.sdlSurface=r_empty)then break;

         sm_listn+=1;
         setlength(sm_list,sm_listn);
         sm_list[sm_listn-1]:=t;
         calcSelectionRect(@sm_sel_hw,t.hw);
         calcSelectionRect(@sm_sel_hh,t.hh);
      end;
      sm_listi   :=sm_listn-1;
      sm_type:=_mkind;
   end;
end;

procedure gfx_MakeLiquidTemplate(surf,ts:pSDL_Surface;xs,ys,d,r:integer;animst,animstyle:byte;itb:boolean);
var x,y,dir,i,e,p,rand:integer;
begin
   boxColor(surf,0,0,d,d,c_purple);

   x:=xs;
   while (x<d) do
   begin
      y:=ys;
      while (y<d) do
      begin
         draw_surf(surf,x,y,ts);
         y+=ts^.h;
      end;
      x+=ts^.w;
   end;

   if(animstyle>1)then exit;

   if(animstyle=0)then
   begin
      if(animst=0)
      then e:=12
      else e:=d div 32;
      rand:=0;
      dir :=0;
      i   :=r+e;
      while(dir<=360)do
      begin
         case animst of
         0:   p:=e+random(e);
         else p:=e+((dir*i+rand) mod e);
         end;
         x:=r+trunc(i*cos(dir*degtorad));
         y:=r+trunc(i*sin(dir*degtorad));
         filledcircleColor(surf,x,y,p,c_purple);
         dir+=max2i(1,(trunc(p*180/(pi*r)) div 3)*4 );
         rand+=13;
      end;
   end;

   dir:=0;
   case animstyle of
   0: i:=r div 12;
   1: i:=-5;
   end;

   while(dir<=360)do
   begin
      p:=r-i;
      dir+=3;
      x:=r+trunc(d*cos(dir*degtorad));
      y:=r+trunc(d*sin(dir*degtorad));
      filledcircleColor(surf,x,y,p,c_purple);
   end;
   if(itb)then filledcircleColor(surf,r,r,r-(r div 6)-10,c_purple);
end;

procedure gfx_MakeLiquid;
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
      theme_liquid_animm:=fr_fpsd2;
   end
   else
   begin
      ts                :=theme_spr_liquids[theme_map_lqt].sdlSurface;
      theme_liquid_animt:=theme_anm_liquids[theme_map_lqt];
      theme_liquid_color:=theme_clr_liquids[theme_map_lqt];
      theme_liquid_animm:=theme_ant_liquids[theme_map_lqt];
   end;

   case theme_liquid_animt of
   0: begin
         wsp:=(ts^.w div 4)*((map_seed   mod 3)-1);
         hsp:=(ts^.h div 4)*((g_random_i mod 3)-1);
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
        gfx_SDLSurfaceFree(sdlSurface);
        sdlSurface:=gfx_SDLSurfaceCreate(w,w);
        hw:=w div 2;
        hh:=hw;

        gfx_MakeLiquidTemplate(sdlSurface,ts,-ts^.w-(a*wsp),-ts^.h-(a*hsp),w,hh,theme_liquid_animt,0,false);

        if(theme_liquid_animt=1)then
         case a of
         1,3 : boxColor(sdlSurface,0,0,w,w,rgba2c(0,0,0,30));
         2   : boxColor(sdlSurface,0,0,w,w,rgba2c(0,0,0,60));
         end;

        SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,0,0));
     end;
end;

procedure gfx_MakeLiquidBack;
var ts :psdl_surface;
    i  :byte;
begin
   if(theme_map_pblqt=theme_map_blqt)and(theme_map_blqt>0)then exit;
   theme_map_pblqt:=theme_map_blqt;

   if(theme_map_blqt<0)or(theme_map_blqt>=theme_spr_terrainn)
   then ts := r_dterrain
   else ts := theme_spr_terrains[theme_map_blqt].sdlSurface;

   for i:=1 to LiquidRs do
    with spr_liquidb[i] do
    begin
       w:=DID_R[i]*2+30;
       h:=w;
       gfx_SDLSurfaceFree(sdlSurface);
       sdlSurface:=gfx_SDLSurfaceCreate(w,w);
       hw:=w div 2;
       hh:=hw;
       gfx_MakeLiquidTemplate(sdlSurface,ts,0,0,w,hw,0,theme_liquid_style,true);
       boxColor(sdlSurface,0,0,w,w,rgba2c(0,0,0,50));
       SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,0,0));
    end;
end;

procedure gfx_MakeCrater;
var ts : psdl_surface;
    i  : integer;
begin
   if(theme_map_pcrt=theme_map_crt)and(theme_map_pcrt>0)then exit;
   theme_map_pcrt:=theme_map_crt;

   if(theme_map_crt<0)or(theme_map_crt>=theme_spr_terrainn)
   then ts := r_dterrain
   else ts := theme_spr_terrains[theme_map_crt].sdlSurface;

   for i:=1 to crater_ri do
    with spr_crater[i] do
    begin
       w:=crater_r[i]*2;
       h:=w;
       gfx_SDLSurfaceFree(sdlSurface);
       sdlSurface:=gfx_SDLSurfaceCreate(w,w);
       hw:=crater_r[i];
       hh:=hw;
       gfx_MakeLiquidTemplate(sdlSurface,ts,0,0,w,hw,0,theme_crater_style,false);
       boxColor(sdlSurface,0,0,w,w,rgba2c(0,0,0,70));
       if(theme_crater_style<2)then
       SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,0,0));
    end;
end;

procedure gfx_MakeTerrain;
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
      ter_s:=theme_spr_terrains[theme_map_trt].sdlSurface;

      ter_w:=ter_s^.w;
      ter_h:=ter_s^.h;
      w:=vid_cam_w+(ter_w shl 1);
      h:=vid_cam_h+(ter_h shl 1);
      vid_terrain:=gfx_SDLSurfaceCreate(w,h);
      x:=0;
      while (x<w) do
      begin
         y:=0;
         while (y<w) do
         begin
            draw_surf(vid_terrain,x,y,ter_s);
            y+=ter_s^.h;
         end;
         x+=ter_s^.w;
      end;
   end;
end;

procedure gfx_MakeTileSet(baseSurface:pSDL_Surface;transColor,transCKey,templateColor:cardinal;tw:integer;tileSet:pTMWTileSet);
var tileX  : word;
b10,b01,
b21,b12    : boolean;
sTemplate  : pSDL_Surface;
tr,tr2,thw,
tw0,tw1,tw2: integer;
procedure FillSurfaceBySurface(sTar,sTile:pSDL_Surface);
var tx,ty:integer;
begin
   tx:=0;
   while tx<sTar^.w do
   begin
      ty:=0;
      while ty<sTar^.h do
      begin
         draw_surf(sTar,tx,ty,sTile);
         ty+=sTile^.h;
      end;
      tx+=sTile^.w;
   end;
end;
begin
   thw:=tw div 2;
   tr :=round(thw*1.45);
   tr2:=round(thw*2.2);
   tw0:=-thw;
   tw1:= thw;
   tw2:=tw+thw;
   sTemplate:=gfx_SDLSurfaceCreate(tw,tw);

   boxColor(sTemplate,0,0,tw,tw,templateColor);
   SDL_SetColorKey(sTemplate,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(sTemplate,0,0));

   with tileSet^[0] do
   begin
      sdlSurface:=gfx_SDLSurfaceCreate(tw,tw);
      boxColor(sdlSurface,0,0,tw,tw,transColor);
      FillSurfaceBySurface(sdlSurface,baseSurface);
      SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY,transCKey);
      w:=tw;h:=w;
      hw:=thw;hh:=hw;
   end;

   for b10:=false to true do
   for b01:=false to true do
   for b21:=false to true do
   for b12:=false to true do
   begin
      boxColor(sTemplate,0,0,tw,tw,transColor);

      tileX:=1;
      if(b10)then begin filledcircleColor(sTemplate,tw1,tw0,tr ,templateColor); tileX+=1; end;
      if(b01)then begin filledcircleColor(sTemplate,tw0,tw1,tr ,templateColor); tileX+=2; end;
      if(b21)then begin filledcircleColor(sTemplate,tw2,tw1,tr ,templateColor); tileX+=4; end;
      if(b12)then begin filledcircleColor(sTemplate,tw1,tw2,tr ,templateColor); tileX+=8; end;

      if(b10)and(b01)then filledcircleColor(sTemplate,tw0,tw0,tr2,templateColor);
      if(b21)and(b10)then filledcircleColor(sTemplate,tw2,tw0,tr2,templateColor);
      if(b01)and(b12)then filledcircleColor(sTemplate,tw0,tw2,tr2,templateColor);
      if(b21)and(b12)then filledcircleColor(sTemplate,tw2,tw2,tr2,templateColor);

      with tileSet^[tileX] do
      begin
         sdlSurface:=gfx_SDLSurfaceCreate(tw,tw);
         boxColor(sdlSurface,0,0,tw,tw,transColor);
         FillSurfaceBySurface(sdlSurface,baseSurface);
         draw_surf(sdlSurface,0,0,sTemplate);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,transCKey);
         w:=tw;h:=w;
         hw:=thw;hh:=hw;
      end;
   end;
end;

function gfx_LoadButton(fn:shortstring;bw:integer):pSDL_Surface;
var ts:pSDl_Surface;
   hwb:integer;
begin
   hwb:=bw div 2;
   ts:=gfx_SDLSurfaceLoad(fn,false,true);
   gfx_LoadButton:=gfx_SDLSurfaceCreate(bw-1,bw-1);
   if(ts^.h>bw)
   then draw_surf(gfx_LoadButton,hwb-(ts^.w div 2),0,ts)
   else draw_surf(gfx_LoadButton,hwb-(ts^.w div 2),hwb-(ts^.h div 2),ts);
   gfx_SDLSurfaceFree(ts);
end;

function gfx_MakeButtonFromSDLSurface(ts:pSDl_Surface;bw:integer):pSDL_Surface;
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
   gfx_MakeButtonFromSDLSurface:=gfx_SDLSurfaceCreate(bw-1,bw-1);
   if(tst^.h>bw)
   then draw_surf(gfx_MakeButtonFromSDLSurface,hwb-(tst^.w div 2),2,tst)
   else draw_surf(gfx_MakeButtonFromSDLSurface,hwb-(tst^.w div 2),hwb-(tst^.h div 2),tst);
   rectangleColor(gfx_MakeButtonFromSDLSurface,0,0,gfx_MakeButtonFromSDLSurface^.w-1,gfx_MakeButtonFromSDLSurface^.h-1,c_black);
   rectangleColor(gfx_MakeButtonFromSDLSurface,1,1,gfx_MakeButtonFromSDLSurface^.w-2,gfx_MakeButtonFromSDLSurface^.h-2,c_black);
   SDL_FreeSurface(tst);
end;

procedure gfx_LoadFont;
var i:byte;
    c:char;
  ccc:cardinal;
 fspr:pSDL_Surface;
begin
   ccc:=(1 shl 24)-1;
   fspr:=gfx_SDLSurfaceLoad('font',false,true);
   for i:=0 to 255 do
   begin
      c:=chr(i);
      with font_ca[c] do
      begin
         sdlSurface:=gfx_SDLSurfaceCreate(font_w,font_w);
         SDL_FillRect(sdlSurface,nil,0);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
      end;

      r_RECT^.x:=ord(i)*font_w;
      r_RECT^.y:=0;
      r_RECT^.w:=font_w;
      r_RECT^.h:=font_w;
      SDL_BLITSURFACE(fspr,r_RECT,font_ca[c].sdlSurface,nil);
   end;
   gfx_SDLSurfaceFree(fspr);
end;

{$include _themes.pas}

procedure gfx_LoadGraphics(firstload:boolean);
var x,r:integer;
transColor:cardinal;
begin
   r_empty   :=gfx_SDLSurfaceCreate(1,1);
   SDL_SetColorKey(r_empty,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(r_empty,0,0));

   r_minimap :=gfx_SDLSurfaceCreate(vid_panelwi,vid_panelwi);
   r_bminimap:=gfx_SDLSurfaceCreate(vid_panelwi,vid_panelwi);

   {r_sminimap:=gfx_SDLSurfaceCreate(vid_panelwi,vid_panelwi);
   boxColor(r_sminimap,0,0,vid_panelwi,vid_panelwi,c_white);
   SDL_SetColorKey(r_sminimap,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(r_sminimap,0,0));}

   for x:=1 to vid_mvs do new(vid_vsl[x]);

   vid_prims:=0;
   setlength(vid_prim,vid_prims);

   with spr_dummy do
   begin
      h   :=1;
      w   :=1;
      hh  :=1;
      hw  :=1;
      sdlSurface:=r_empty;
   end;
   pspr_dummy:=@spr_dummy;

   with spr_dmodel do
   begin
      sm_listi:=0;
      sm_listn:=1;
      setlength(sm_list,sm_listn);
      sm_list[sm_listi]:=spr_dummy;
      sm_type :=smt_effect;
   end;
   spr_pdmodel:=@spr_dmodel;

   gfx_LoadFont;

   vid_fog_surf := gfx_SDLSurfaceCreate(fog_cr*2,fog_cr*2);
   boxColor(vid_fog_surf,0,0,vid_fog_surf^.w,vid_fog_surf^.h,c_purple);
   filledcircleColor(vid_fog_surf,fog_cr,fog_cr,fog_cr,c_black);
   SDL_SetColorKey(vid_fog_surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(vid_fog_surf,0,0));

   vid_fog_BaseSurf := gfx_SDLSurfaceCreate(fog_cw,fog_cw);
   boxColor(vid_fog_BaseSurf,0,0,fog_cw,fog_cw,c_white);
   transColor:=SDL_GETpixel(vid_fog_BaseSurf,0,0);
   SDL_SetColorKey(vid_fog_BaseSurf,SDL_SRCCOLORKEY,transColor);
   for x:=1 to fog_cw do
   for r:=1 to fog_cw do
     if((x+r)mod 4)>0 then
       pixelColor(vid_fog_BaseSurf,x-1,r-1,c_black);

   gfx_MakeTileSet(vid_fog_BaseSurf,c_white,transColor,c_black,fog_cw,@vid_fog_tiles);


   spr_mback:= gfx_SDLSurfaceLoad('mback',false,firstload);

   r_menu:=gfx_SDLSurfaceCreate(max2i(vid_minw,spr_mback^.w), max2i(vid_minh,spr_mback^.h));

   menu_x:=(vid_vw-r_menu^.w) div 2;
   menu_y:=(vid_vh-r_menu^.h) div 2;

   spr_b_action   := gfx_LoadButton('b_action' ,vid_bw);
   spr_b_paction  := gfx_LoadButton('b_paction',vid_bw);
   spr_b_delete   := gfx_LoadButton('b_destroy',vid_bw);
   spr_b_attack   := gfx_LoadButton('b_attack' ,vid_bw);
   spr_b_rebuild  := gfx_LoadButton('b_rebuild',vid_bw);
   spr_b_move     := gfx_LoadButton('b_move'   ,vid_bw);
   spr_b_patrol   := gfx_LoadButton('b_patrol' ,vid_bw);
   spr_b_apatrol  := gfx_LoadButton('b_apatrol',vid_bw);
   spr_b_stop     := gfx_LoadButton('b_stop'   ,vid_bw);
   spr_b_hold     := gfx_LoadButton('b_hold'   ,vid_bw);
   spr_b_selall   := gfx_LoadButton('b_selall' ,vid_bw);
   spr_b_cancel   := gfx_LoadButton('b_cancle' ,vid_bw);
   spr_b_rfast    := gfx_LoadButton('b_rfast'  ,vid_bw);
   spr_b_rskip    := gfx_LoadButton('b_rskip'  ,vid_bw);
   spr_b_rback    := gfx_LoadButton('b_rback'  ,vid_bw);
   spr_b_rfog     := gfx_LoadButton('b_fog'    ,vid_bw);
   spr_b_rlog     := gfx_LoadButton('b_log'    ,vid_bw);
   spr_b_rstop    := gfx_LoadButton('b_rstop'  ,vid_bw);
   spr_b_rvis     := gfx_LoadButton('b_rvis'   ,vid_bw);
   spr_b_rclck    := gfx_LoadButton('b_rclick' ,vid_bw);
   spr_b_mmark    := gfx_LoadButton('b_mmark'  ,vid_bw);

   for x:=0 to 3 do spr_tabs[x]:=gfx_LoadButton('tabs'+b2s(x),vid_tbw);

   spr_cursor     := gfx_SDLSurfaceLoad('cursor'   ,true ,true);

   spr_c_earth    := gfx_SDLSurfaceLoad('M_EARTH'  ,false,true);
   spr_c_mars     := gfx_SDLSurfaceLoad('M_MARS'   ,false,true);
   spr_c_hell     := gfx_SDLSurfaceLoad('M_HELL'   ,false,true);
   spr_c_phobos   := gfx_SDLSurfaceLoad('M_PHOBOS' ,false,true);
   spr_c_deimos   := gfx_SDLSurfaceLoad('M_DEIMOS' ,false,true);

   gfx_MWSModelLoad(@spr_lostsoul       ,race_units[r_hell]+'h_u0_'      ,smt_lost     ,firstload);
   gfx_MWSModelLoad(@spr_phantom        ,race_units[r_hell]+'h_u0a_'     ,smt_lost     ,firstload);
   gfx_MWSModelLoad(@spr_imp            ,race_units[r_hell]+'h_u1_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_demon          ,race_units[r_hell]+'h_u2_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_cacodemon      ,race_units[r_hell]+'h_u3_'      ,smt_caco     ,firstload);
   gfx_MWSModelLoad(@spr_knight         ,race_units[r_hell]+'h_u4k_'     ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_baron          ,race_units[r_hell]+'h_u4_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_cyberdemon     ,race_units[r_hell]+'h_u5_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_mastermind     ,race_units[r_hell]+'h_u6_'      ,smt_mmind    ,firstload);
   gfx_MWSModelLoad(@spr_pain           ,race_units[r_hell]+'h_u7_'      ,smt_pain     ,firstload);
   gfx_MWSModelLoad(@spr_revenant       ,race_units[r_hell]+'h_u8_'      ,smt_revenant ,firstload);
   gfx_MWSModelLoad(@spr_mancubus       ,race_units[r_hell]+'h_u9_'      ,smt_mancubus ,firstload);
   gfx_MWSModelLoad(@spr_arachnotron    ,race_units[r_hell]+'h_u10_'     ,smt_archno   ,firstload);
   gfx_MWSModelLoad(@spr_archvile       ,race_units[r_hell]+'h_u11_'     ,smt_arch     ,firstload);

   gfx_MWSModelLoad(@spr_ZFormer        ,race_units[r_hell]+'h_z0_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_ZEngineer      ,race_units[r_hell]+'h_z0s_'     ,smt_zengineer,firstload);
   gfx_MWSModelLoad(@spr_ZSergant       ,race_units[r_hell]+'h_z1_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_ZSSergant      ,race_units[r_hell]+'h_z1s_'     ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_ZCommando      ,race_units[r_hell]+'h_z2_'      ,smt_zcommando,firstload);
   gfx_MWSModelLoad(@spr_ZAntiaircrafter,race_units[r_hell]+'h_zr_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_ZSiege         ,race_units[r_hell]+'h_z3_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_ZFMajor        ,race_units[r_hell]+'h_z4j_'     ,smt_fmajor   ,firstload);
   gfx_MWSModelLoad(@spr_ZBFG           ,race_units[r_hell]+'h_z5_'      ,smt_imp      ,firstload);

   gfx_MWSModelLoad(@spr_Medic          ,race_units[r_uac ]+'u_u0_'      ,smt_medic    ,firstload);
   gfx_MWSModelLoad(@spr_Engineer       ,race_units[r_uac ]+'u_u1_'      ,smt_marine0  ,firstload);
   gfx_MWSModelLoad(@spr_Scout          ,race_units[r_uac ]+'u_u1s_'     ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_Sergant        ,race_units[r_uac ]+'u_u2_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_SSergant       ,race_units[r_uac ]+'u_u2s_'     ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_Commando       ,race_units[r_uac ]+'u_u3_'      ,smt_zcommando,firstload);
   gfx_MWSModelLoad(@spr_Antiaircrafter ,race_units[r_uac ]+'u_u4r_'     ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_Siege          ,race_units[r_uac ]+'u_u4_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_FMajor         ,race_units[r_uac ]+'u_u5j_'     ,smt_fmajor   ,firstload);
   gfx_MWSModelLoad(@spr_BFG            ,race_units[r_uac ]+'u_u6_'      ,smt_imp      ,firstload);
   gfx_MWSModelLoad(@spr_FAPC           ,race_units[r_uac ]+'u_u8_'      ,smt_fapc     ,firstload);
   gfx_MWSModelLoad(@spr_APC            ,race_units[r_uac ]+'uac_tank_'  ,smt_apc      ,firstload);
   gfx_MWSModelLoad(@spr_Terminator     ,race_units[r_uac ]+'u_u9_'      ,smt_terminat ,firstload);
   gfx_MWSModelLoad(@spr_Tank           ,race_units[r_uac ]+'u_u10_'     ,smt_tank     ,firstload);
   gfx_MWSModelLoad(@spr_Flyer          ,race_units[r_uac ]+'u_u11_'     ,smt_flyer    ,firstload);
   gfx_MWSModelLoad(@spr_Transport      ,race_units[r_uac ]+'transport'  ,smt_transport,firstload);
   gfx_MWSModelLoad(@spr_UACBot         ,race_units[r_uac ]+'uacd'       ,smt_flyer    ,firstload);


   gfx_MWSModelLoad(@spr_HKeep          ,race_buildings[r_hell]+'h_b0_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HAKeep         ,race_buildings[r_hell]+'h_b0a_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HGate          ,race_buildings[r_hell]+'h_b1_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HAGate         ,race_buildings[r_hell]+'h_b1a'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HSymbol        ,race_buildings[r_hell]+'h_b2_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HASymbol       ,race_buildings[r_hell]+'h_b2a_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HPools         ,race_buildings[r_hell]+'h_b3_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HAPools        ,race_buildings[r_hell]+'h_b3a'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HTower         ,race_buildings[r_hell]+'h_b4_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HTeleport      ,race_buildings[r_hell]+'h_b5_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HMonastery     ,race_buildings[r_hell]+'h_b6_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HTotem         ,race_buildings[r_hell]+'h_b7_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HAltar         ,race_buildings[r_hell]+'h_b8_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HFortress      ,race_buildings[r_hell]+'h_b9_'  ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HPentagram     ,race_buildings[r_hell]+'h_b10_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HCommandCenter ,race_buildings[r_hell]+'h_hcc_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HACommandCenter,race_buildings[r_hell]+'h_hcca_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HBarracks      ,race_buildings[r_hell]+'h_hbar_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HABarracks     ,race_buildings[r_hell]+'h_hbara',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_HEye           ,race_buildings[r_hell]+'heye_'  ,smt_buiding,firstload);

   gfx_MWSModelLoad(@spr_UCommandCenter ,race_buildings[r_uac ] +'u_b0_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UACommandCenter,race_buildings[r_uac ] +'u_b0a_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UBarracks      ,race_buildings[r_uac ] +'u_b1_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UABarracks     ,race_buildings[r_uac ] +'u_b1a' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UGenerator     ,race_buildings[r_uac ] +'u_b2_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UAGenerator    ,race_buildings[r_uac ] +'u_b2a_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UWeaponFactory ,race_buildings[r_uac ] +'u_b3_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UAWeaponFactory,race_buildings[r_uac ] +'u_b3a' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UTurret        ,race_buildings[r_uac ] +'u_b4_' ,smt_turret ,firstload);
   gfx_MWSModelLoad(@spr_URadar         ,race_buildings[r_uac ] +'u_b5_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UVehicleFactory,race_buildings[r_uac ] +'u_b6_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UTechCenter    ,race_buildings[r_uac ] +'u_b13_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UPTurret       ,race_buildings[r_uac ] +'u_b7_' ,smt_turret ,firstload);
   gfx_MWSModelLoad(@spr_URocketL       ,race_buildings[r_uac ] +'u_b8_' ,smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_URTurret       ,race_buildings[r_uac ] +'u_b9_' ,smt_turret2,firstload);
   gfx_MWSModelLoad(@spr_UNuclearPlant  ,race_buildings[r_uac ] +'u_b10_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UAFactory      ,race_buildings[r_uac ] +'u_b11_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_UFactory       ,race_buildings[r_uac ] +'u_b12_',smt_buiding,firstload);
   gfx_MWSModelLoad(@spr_Mine           ,race_buildings[r_uac ] +'u_mine',smt_buiding,firstload);

   gfx_MWSModelLoad(@spr_db_h0          ,race_dir[r_hell]+'db_h0'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_db_h1          ,race_dir[r_hell]+'db_h1'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_db_u0          ,race_dir[r_uac ]+'db_u0'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_db_u1          ,race_dir[r_uac ]+'db_u1'        ,smt_effect ,firstload);

   gfx_MWSModelLoad(@spr_h_p0           ,race_missiles[r_hell]+'h_p0_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_h_p1           ,race_missiles[r_hell]+'h_p1_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_h_p2           ,race_missiles[r_hell]+'h_p2_'   ,smt_missile,firstload);
   gfx_MWSModelLoad(@spr_h_p3           ,race_missiles[r_hell]+'h_p3_'   ,smt_missile,firstload);
   gfx_MWSModelLoad(@spr_h_p4           ,race_missiles[r_hell]+'h_p4_'   ,smt_missile,firstload);
   gfx_MWSModelLoad(@spr_h_p5           ,race_missiles[r_hell]+'h_p5_'   ,smt_missile,firstload);
   gfx_MWSModelLoad(@spr_h_p6           ,race_missiles[r_hell]+'h_p6_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_h_p7           ,race_missiles[r_hell]+'h_p7_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_u_p0           ,race_missiles[r_uac ]+'u_p0_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_u_p1           ,race_missiles[r_uac ]+'u_p1_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_u_p2           ,race_missiles[r_uac ]+'u_p2_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_u_p3           ,race_missiles[r_uac ]+'u_p3_'   ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_u_p8           ,race_missiles[r_uac ]+'u_p8_'   ,smt_missile,firstload);

   spr_u_p1s:=spr_u_p1;
   with spr_u_p1s do sm_type:=smt_effect2;

   gfx_MWSModelLoad(@spr_eff_bfg    ,effects_folder+'ef_bfg_'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_eb     ,effects_folder+'ef_eb'          ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_ebb    ,effects_folder+'ef_ebb'         ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_gtel   ,effects_folder+'ef_gt_'         ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_tel    ,effects_folder+'ef_tel_'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_exp    ,effects_folder+'ef_exp_'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_exp2   ,effects_folder+'exp2_'          ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_g      ,effects_folder+'g_'             ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_blood      ,effects_folder+'blood'          ,smt_effect ,firstload);

   gfx_MWTextureLoad(@spr_mp[r_hell],race_dir[r_hell]+'h_mp',firstload,true);
   gfx_MWTextureLoad(@spr_mp[r_uac ],race_dir[r_uac ]+'u_mp',firstload,true);
   gfx_MWTextureLoad(@spr_ptur      ,race_dir[r_uac ]+'ptur',firstload,true);

   gfx_MWTextureLoad(@spr_b4_a      ,race_buildings[r_uac ]+'u_b4_a',firstload,true);
   gfx_MWTextureLoad(@spr_b7_a      ,race_buildings[r_uac ]+'u_b7_a',firstload,true);
   gfx_MWTextureLoad(@spr_b9_a      ,race_buildings[r_uac ]+'u_b9_a',firstload,true);

   gfx_MWTextureLoad(@spr_stun      ,effects_folder+'stun'   ,firstload,true);
   gfx_MWTextureLoad(@spr_invuln    ,effects_folder+'invuln' ,firstload,true);
   gfx_MWTextureLoad(@spr_hvision   ,effects_folder+'hvision',firstload,true);
   gfx_MWTextureLoad(@spr_scan      ,effects_folder+'scan'   ,firstload,true);
   gfx_MWTextureLoad(@spr_decay     ,effects_folder+'decay'  ,firstload,true);


   gfx_MWTextureLoad(@spr_cp_koth   ,'cp_koth',firstload,true);
   gfx_MWTextureLoad(@spr_cp_out    ,'cp_out' ,firstload,true);
   gfx_MWTextureLoad(@spr_cp_gen    ,'cp_gen' ,firstload,true);

   for x:=0 to spr_upgrade_icons do
    for r:=1 to r_cnt do
     with spr_b_up[r,x] do
     begin
        sdlSurface:= gfx_LoadButton(race_upgrades[r]+'b_up'+b2s(x),vid_bw);
        w   := sdlSurface^.w;h    := w;
        hw  := w div 2      ;hh   := hw;
     end;

   effect_InitCLData;
   InitThemes;
end;


procedure MakeUnitIcons;
var u:byte;
begin
   for u:=0 to 255 do
   with g_uids[u] do
   begin
      with un_btn do
      begin
         case _urace of
         r_hell: sdlSurface:= gfx_MakeButtonFromSDLSurface(sm_uid2MWTexture(u,315,0)^.sdlSurface,vid_BW );
         r_uac : sdlSurface:= gfx_MakeButtonFromSDLSurface(sm_uid2MWTexture(u,225,0)^.sdlSurface,vid_BW );
         end;
         w   := sdlSurface^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      with un_sbtn do
      begin
         case _urace of
         r_hell: sdlSurface:= gfx_MakeButtonFromSDLSurface(sm_uid2MWTexture(u,315,0)^.sdlSurface,vid_oiw );
         r_uac : sdlSurface:= gfx_MakeButtonFromSDLSurface(sm_uid2MWTexture(u,225,0)^.sdlSurface,vid_oiw );
         end;
         w   := sdlSurface^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
   end;
end;

procedure Map_tdmake;
var i,ix,iy,rn:integer;
begin
   _tdecaln:=(vid_cam_w*vid_cam_h) div 10000;
   setlength(_tdecals,_tdecaln);

   vid_mwa:= vid_cam_w+vid_ab*2;
   vid_mha:= vid_cam_h+vid_ab*2;

   ix:=longint(map_seed) mod vid_mwa;
   iy:=(g_random_i*5+ix) mod vid_mha;
   rn:=ix*iy;
   for i:=1 to _tdecaln do
    with _tdecals[i-1] do
    begin
       rn+=17;
       ix:=g_randomx(ix+rn       ,vid_mwa);
       iy:=g_randomx(iy+sqr(ix*i),vid_mha);
       x :=ix;
       y :=iy;
    end;
end;

procedure vid_CommonVars;
begin
   vid_vmb_x1   := vid_vw-vid_vmb_x0;
   vid_vmb_y1   := vid_vh-vid_vmb_y0;

   ui_textx     := vid_mapx+font_hw;
   ui_texty     := vid_mapy+font_hw;
   ui_hinty1    := vid_mapy+vid_cam_h-txt_line_h1*10;
   ui_hinty2    := vid_mapy+vid_cam_h-txt_line_h1*8;
   ui_hinty3    := vid_mapy+vid_cam_h-txt_line_h1*5;
   ui_hinty4    := vid_mapy+vid_cam_h-txt_line_h1*2;
   ui_chaty     := ui_hinty1-font_3hw;
   ui_logy      := ui_chaty-font_3hw;
   ui_oicox     := vid_mapx+vid_cam_w-font_hw;
   ui_uiuphx    := vid_mapx+(vid_cam_w div 2);
   ui_uiuphy    := ui_texty+font_6hw;
   ui_uiplayery := ui_uiuphy+font_3hw;
   ui_GameLogHeight:=(ui_hinty1-font_5w) div font_3hw;

   ui_energx    := ui_uiuphx-150;
   ui_energy    := ui_texty;
   ui_armyx     := ui_uiuphx+40;
   ui_armyy     := ui_texty;
   ui_fpsx      := vid_mapx+vid_cam_w-(font_w*font_3hw);
   ui_fpsy      := ui_texty;
   ui_apmx      := ui_fpsx;
   ui_apmy      := ui_fpsy+txt_line_h3;

   ui_ingamecl  :=(vid_cam_w-font_w) div font_w;
   if(spr_mback<>nil)then
   begin
      menu_x    :=(vid_vw-spr_mback^.w) div 2;
      menu_y    :=(vid_vh-spr_mback^.h) div 2;
   end;
   vid_fog_vfw  :=(vid_cam_w div fog_cw)+2;
   vid_fog_vfh  :=(vid_cam_h div fog_cw)+2;

   map_mmvw     := round(vid_cam_w*map_mmcx);
   map_mmvh     := round(vid_cam_h*map_mmcx);
   GameCameraBounds;

   Map_tdmake;
end;

procedure vid_ScreenSurfaces;
var i,y:integer;

procedure pline(x0,y0,x1,y1:integer;color:cardinal);
begin
   if(vid_PannelPos<2)
   then lineColor(r_panel,x0,y0,x1,y1,color)
   else lineColor(r_panel,y0,x0,y1,x1,color);
end;
procedure prect(x0,y0,x1,y1:integer;color:cardinal);
begin
   if(vid_PannelPos<2)
   then rectangleColor(r_panel,x0,y0,x1,y1,color)
   else rectangleColor(r_panel,y0,x0,y1,x1,color);
end;

begin
   gfx_SDLSurfaceFree(r_uipanel );
   gfx_SDLSurfaceFree(r_panel   );
   gfx_SDLSurfaceFree(r_dterrain);

   if(vid_PannelPos<2)then // left-right
   begin
      ui_menu_btnsy:=(vid_vh div vid_BW);
      if((vid_vh-(ui_menu_btnsy*vid_BW))<vid_hBW)then ui_menu_btnsy-=1;
   end
   else
   begin
      ui_menu_btnsy:=(vid_vw div vid_BW);
      if((vid_vw-(ui_menu_btnsy*vid_BW))<vid_BW)then ui_menu_btnsy-=1;
   end;

   if(vid_PannelPos<2)then // left-right
   begin
      vid_cam_w:=vid_vw-vid_panelw;
      vid_cam_h:=vid_vh;

      if(vid_PannelPos=0)
      then vid_mapx:=vid_panelw
      else vid_mapx:=0;
      vid_mapy:=0;

      if(vid_PannelPos=0)
      then vid_panelx:=0
      else vid_panelx:=vid_cam_w-1;
      vid_panely:=0;

      r_uipanel:=gfx_SDLSurfaceCreate(vid_panelw+1,vid_vh);
      r_panel  :=gfx_SDLSurfaceCreate(vid_panelw+1,vid_vh);

      y:=vid_BW*ui_menu_btnsy+vid_BW;
      vlineColor(r_panel,vid_BW ,vid_panelw+vid_BW,y,c_white);
      vlineColor(r_panel,vid_2BW,vid_panelw+vid_BW,y,c_white);
   end
   else
   begin
      vid_cam_w:=vid_vw;
      vid_cam_h:=vid_vh-vid_panelw;

      vid_mapx:=0;
      if(vid_PannelPos=2)
      then vid_mapy:=vid_panelw-1
      else vid_mapy:=0;

      vid_panelx:=0;
      if(vid_PannelPos=2)
      then vid_panely:=0
      else vid_panely:=vid_cam_h-1;

      r_uipanel:=gfx_SDLSurfaceCreate(vid_cam_w,vid_panelw+1);
      r_panel  :=gfx_SDLSurfaceCreate(vid_cam_w,vid_panelw+1);

      y:=vid_BW*ui_menu_btnsy+vid_BW;
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_BW ,c_white);
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_2BW,c_white);
   end;

   vid_cam_hw:=vid_cam_w div 2;
   vid_cam_hh:=vid_cam_h div 2;

   rectangleColor(r_panel,0,0,r_panel^.w-1,r_panel^.h-1,c_white);
   pline(0,vid_panelw,vid_panelw,vid_panelw,c_white);

   //pline(0,vid_panelw+ui_h3bw,r_panel^.w,vid_panelw+ui_h3bw,c_white);
   pline(0,vid_panelw+vid_BW ,r_panel^.w,vid_panelw+vid_BW ,c_white);

   for y:=0 to 3 do
   pline(y*vid_tBW,vid_panelw,y*vid_tBW,vid_panelw+vid_BW,c_white);

   i:=4;
   y:=vid_BW*i;
   while (i<=(ui_menu_btnsy+1)) do
   begin
      pline(0,y,vid_panelw,y,c_white);
      i+=1;
      y+=vid_BW;
   end;

   draw_surf(r_uipanel,0,0,r_panel);

   r_dterrain:=gfx_SDLSurfaceCreate(vid_cam_w,vid_cam_h);

   vid_CommonVars;
end;

procedure vid_MakeScreen;
begin
   if (r_screen<>nil) then sdl_freesurface(r_screen);

   if(vid_fullscreen)
   then r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, r_vflags + SDL_FULLSCREEN)
   else r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, r_vflags);

   if(r_screen=nil)then begin WriteSDLError; exit; end;

   vid_ScreenSurfaces;
end;


