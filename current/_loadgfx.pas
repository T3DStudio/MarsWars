
procedure InitRX2Y;
var r,x:integer;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _RX2Y[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
end;

procedure gfx_MakeScreenshot;
var i:integer;
    s:shortstring;
begin
   i:=0;
   repeat
      i+=1;
      s:=str_screenshot+i2s(i)+'.bmp';
   until not FileExists(s);
   s:=s+#0;
   sdl_saveBMP(vid_screen,@s[1]);
end;

function gfx_ShadowColor(c:cardinal):cardinal;
begin
   gfx_ShadowColor:=128 +
   (((c and $FF000000) shr 25) shl 24) +
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 );
end;

function gfx_rgba2c(r,g,b,a:byte):cardinal;
begin
   gfx_rgba2c:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

procedure gfx_InitColors;
begin
   c_dred    :=gfx_rgba2c(190,  0,  0,255);
   c_red     :=gfx_rgba2c(255,  0,  0,255);
   c_ared    :=gfx_rgba2c(255,  0,  0,82 );
   c_orange  :=gfx_rgba2c(255,140,  0,255);
   c_dorange :=gfx_rgba2c(230, 96,  0,255);
   c_brown   :=gfx_rgba2c(140, 90, 10,255);
   c_yellow  :=gfx_rgba2c(255,255,  0,255);
   c_dyellow :=gfx_rgba2c(220,220,  0,255);
   c_lime    :=gfx_rgba2c(0  ,255,  0,255);
   c_alime   :=gfx_rgba2c(0  ,255,  0,42 );
   c_aaqua   :=gfx_rgba2c(0  ,255,255,42 );
   c_aqua    :=gfx_rgba2c(0  ,255,255,255);
   c_purple  :=gfx_rgba2c(255,0  ,255,255);
   c_violet  :=gfx_rgba2c(147,100,255,255);
   c_green   :=gfx_rgba2c(0  ,150,0  ,255);
   c_agreen  :=gfx_rgba2c(0  ,150,0  ,42 );
   c_dblue   :=gfx_rgba2c(100,100,192,255);
   c_blue    :=gfx_rgba2c(50 ,50 ,255,255);
   c_ablue   :=gfx_rgba2c(50 ,50 ,255,24 );
   c_white   :=gfx_rgba2c(255,255,255,255);
   c_awhite  :=gfx_rgba2c(255,255,255,40 );
   c_gray    :=gfx_rgba2c(120,120,120,255);
   c_ltgray  :=gfx_rgba2c(200,200,200,255);
   c_dgray   :=gfx_rgba2c(70 ,70 ,70 ,255);
   c_agray   :=gfx_rgba2c(80 ,80 ,80 ,128);
   c_black   :=gfx_rgba2c(0  ,0  ,0  ,255);
   c_ablack  :=gfx_rgba2c(0  ,0  ,0  ,128);
   c_lava    :=gfx_rgba2c(222,80 ,0  ,255);

   ui_max_color    [false]:=c_dorange;
   ui_max_color    [true ]:=c_gray;
   ui_cenergy[false]:=c_white;
   ui_cenergy[true ]:=c_red;
   ui_limit  [false]:=c_white;
   ui_limit  [true ]:=c_red;

   ui_blink_color2 [false]:=c_black;
   ui_blink_color2 [true ]:=c_yellow;

   ui_blink_color1 [false]:=c_black;
   ui_blink_color1 [true ]:=c_gray;
end;

function gfx_CreateSDLSurface(tw,th:integer):pSDL_Surface;
var ts1,ts2:pSDL_Surface;
begin
   gfx_CreateSDLSurface:=nil;
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
      gfx_CreateSDLSurface:=ts2;
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

function gfx_LoadSDLSurfaceEXT(fn:shortstring):pSDL_SURFACE;
var tmp:pSDL_SURFACE;
begin
   gfx_LoadSDLSurfaceEXT:=spr_empty;
   if(not FileExists(fn))then exit;

   fn:=fn+#0;

   tmp:=img_load(@fn[1]);
   if(tmp<>nil)then
   begin
      gfx_LoadSDLSurfaceEXT:=sdl_displayformat(tmp);
      sdl_freesurface(tmp);
   end;
end;

function gfx_LoadSDLSurface(fn:shortstring;transparent,log:boolean):pSDL_SURFACE;
const fextn = 2;
      fexts : array[0..fextn] of shortstring = ('.png','.jpg','.bmp');
var i:integer;
begin
   for i:=0 to fextn do
   begin
      gfx_LoadSDLSurface:=gfx_LoadSDLSurfaceEXT(str_f_grp+fn+fexts[i]);
      if(gfx_LoadSDLSurface<>spr_empty)then
      begin
         if(transparent)then SDL_SetColorKey(gfx_LoadSDLSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL, sdl_getpixel(gfx_LoadSDLSurface,0,0));
         break;
      end
      else
        if(i=fextn)and(log)then WriteLog(str_f_grp+fn);
   end;
end;

procedure gfx_FreeSDLSurface(sf:PSDL_Surface);
begin
   if(sf<>nil)and(sf<>spr_empty)then
   begin
      sdl_FreeSurface(sf);
      sf:=nil;
   end;
end;

procedure gfx_LoadMWTexture(mws:PTMWTexture;fn:shortstring;log:boolean);
begin
   with mws^ do
   begin
      surf:=gfx_LoadSDLSurface(fn,true,log);
      w :=surf^.w;
      h :=surf^.h;
      hw:=surf^.w div 2;
      hh:=surf^.h div 2;
   end;
end;

procedure gfx_LoadMWSModel(mwsm:PTMWSModel;name:shortstring;_mkind:byte);
var t:TMWTexture;
procedure AddSelRect(ip:pinteger;vl:integer);
begin
   if(ip^=0)
   then ip^:=vl
   else ip^:=(ip^+vl) div 2;
end;
begin
   with mwsm^ do
   begin
      sm_SelectionHW:=0;
      sm_SelectionHH:=0;
      sm_spritesNum :=0;
      setlength(sm_spritesL,sm_spritesNum);

      gfx_LoadMWTexture(@t,name,false);
      if(t.surf<>spr_empty)then
      begin
         sm_spritesNum+=1;
         setlength(sm_spritesL,sm_spritesNum);
         sm_spritesL[sm_spritesNum-1]:=t;
         AddSelRect(@sm_SelectionHW,t.hw);
         AddSelRect(@sm_SelectionHH,t.hh);
      end;

      while true do
      begin
         gfx_LoadMWTexture(@t,name+i2s(sm_spritesNum),false);
         if(t.surf=spr_empty)then break;

         sm_spritesNum+=1;
         setlength(sm_spritesL,sm_spritesNum);
         sm_spritesL[sm_spritesNum-1]:=t;
         AddSelRect(@sm_SelectionHW,t.hw);
         AddSelRect(@sm_SelectionHH,t.hh);
      end;
      sm_spritesLast   :=sm_spritesNum-1;
      sm_kind:=_mkind;
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
         draw_sdlsurface(surf,x,y,ts);
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
   0: i:=r div 17;
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

procedure gfx_MapMakeLiquid;
var
ts : psdl_surface;
a,i,
wsp,
hsp: integer;
begin
   if(theme_map_pLiquid=theme_map_Liquid)and(theme_map_pLiquid>0)then exit;
   theme_map_pLiquid:=theme_map_Liquid;

   if(theme_map_Liquid<0)or(theme_map_Liquid>=theme_spr_liquidn)then
   begin
      ts                :=theme_DefSprite;
      theme_liquid_animt:=0;
      theme_liquid_color:=c_gray;
      theme_liquid_animm:=fr_fpsh;
   end
   else
   begin
      ts                :=theme_spr_liquids[theme_map_Liquid].surf;
      theme_liquid_animt:=theme_anm_liquids[theme_map_Liquid];
      theme_liquid_color:=theme_clr_liquids[theme_map_Liquid];
      theme_liquid_animm:=theme_ant_liquids[theme_map_Liquid];
   end;

   case theme_liquid_animt of
   0: begin
         wsp:=(ts^.w div 4)*((map_seed mod 3)-1);
         hsp:=(ts^.h div 4)*((abs(g_random_i) mod 3)-1);
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
        gfx_FreeSDLSurface(surf);
        surf:=gfx_CreateSDLSurface(w,w);
        hw:=w div 2;
        hh:=hw;

        gfx_MakeLiquidTemplate(surf,ts,-ts^.w-(a*wsp),-ts^.h-(a*hsp),w,hh,theme_liquid_animt,0,false);

        if(theme_liquid_animt=1)then
         case a of
         1,3 : boxColor(surf,0,0,w,w,gfx_rgba2c(0,0,0,30));
         2   : boxColor(surf,0,0,w,w,gfx_rgba2c(0,0,0,60));
         end;

        SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
     end;
end;

procedure gfx_MapMakeLiquidBack;
var ts:psdl_surface;
    i :byte;
begin
   if(theme_map_pLiquidBack=theme_map_LiquidBack)and(theme_map_LiquidBack>0)then exit;
   theme_map_pLiquidBack:=theme_map_LiquidBack;

   if(theme_map_LiquidBack<0)or(theme_map_LiquidBack>=theme_spr_terrainn)
   then ts := theme_DefSprite
   else ts := theme_spr_terrains[theme_map_LiquidBack].surf;

   for i:=1 to LiquidRs do
    with spr_liquidb[i] do
    begin
       w:=DID_R[i]*2+30;
       h:=w;
       gfx_FreeSDLSurface(surf);
       surf:=gfx_CreateSDLSurface(w,w);
       hw:=w div 2;
       hh:=hw;
       gfx_MakeLiquidTemplate(surf,ts,0,0,w,hw,0,theme_liquid_style,true);
       boxColor(surf,0,0,w,w,gfx_rgba2c(0,0,0,50));
       SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
    end;
end;

procedure gfx_MapMakeCrater;
var ts:psdl_surface;
    i :integer;
begin
   if(theme_map_pCrater=theme_map_Crater)and(theme_map_pCrater>0)then exit;
   theme_map_pCrater:=theme_map_Crater;

   if(theme_map_Crater<0)or(theme_map_Crater>=theme_spr_terrainn)
   then ts := theme_DefSprite
   else ts := theme_spr_terrains[theme_map_Crater].surf;

   for i:=1 to crater_ri do
    with spr_crater[i] do
    begin
       w:=crater_r[i]*2;
       h:=w;
       gfx_FreeSDLSurface(surf);
       surf:=gfx_CreateSDLSurface(w,w);
       hw:=crater_r[i];
       hh:=hw;
       gfx_MakeLiquidTemplate(surf,ts,0,0,w,hw,0,theme_crater_style,false);
       boxColor(surf,0,0,w,w,gfx_rgba2c(0,0,0,70));
       if(theme_crater_style<2)then
       SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
    end;
end;

procedure gfx_MapMakeTerrain;
var
x,y,
w,h:integer;
ts :pSDL_Surface;
begin
   if(theme_map_pTerrain=theme_map_Terrain)and(theme_map_pTerrain>0)then exit;
   theme_map_pTerrain:=theme_map_Terrain;

   if(map_terrain<>nil) then
   begin
      sdl_freesurface(map_terrain);
      map_terrain:=nil;
   end;

   if(theme_map_Terrain<0)or(theme_map_Terrain>=theme_spr_terrainn)
   then ts:=theme_DefSprite
   else ts:=theme_spr_terrains[theme_map_Terrain].surf;

   map_ter_w:=ts^.w;
   map_ter_h:=ts^.h;
   w:=ui_cam_w+(map_ter_w*2);
   h:=ui_cam_h+(map_ter_h*2);
   map_terrain:=gfx_CreateSDLSurface(w,h);
   x:=0;
   while(x<w)do
   begin
      y:=0;
      while(y<w)do
      begin
         draw_sdlsurface(map_terrain,x,y,ts);
         y+=ts^.h;
      end;
      x+=ts^.w;
   end;
end;


function gfx_LoadButton(fn:shortstring;bw:integer):pSDL_Surface;
var ts:pSDl_Surface;
   hwb:integer;
begin
   hwb:=bw div 2;
   ts:=gfx_LoadSDLSurface(fn,false,true);
   gfx_LoadButton:=gfx_CreateSDLSurface(bw-1,bw-1);
   if(ts^.h>bw)
   then draw_sdlsurface(gfx_LoadButton,hwb-(ts^.w div 2),0,ts)
   else draw_sdlsurface(gfx_LoadButton,hwb-(ts^.w div 2),hwb-(ts^.h div 2),ts);
   gfx_FreeSDLSurface(ts);
end;

function gfx_LoadButtonFS(ts:pSDl_Surface;bw:integer;blackrect:byte=3):pSDL_Surface;
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
   gfx_LoadButtonFS:=gfx_CreateSDLSurface(bw-1,bw-1);
   if(tst^.h>bw)
   then draw_sdlsurface(gfx_LoadButtonFS,hwb-(tst^.w div 2),2,tst)
   else draw_sdlsurface(gfx_LoadButtonFS,hwb-(tst^.w div 2),hwb-(tst^.h div 2),tst);
   while(blackrect>0)do
   begin
      blackrect-=1;
      rectangleColor(gfx_LoadButtonFS,blackrect,blackrect,gfx_LoadButtonFS^.w-blackrect-1,gfx_LoadButtonFS^.h-blackrect-1,c_black);
   end;
   SDL_FreeSurface(tst);
end;

procedure gfx_LoadFont;
var i:byte;
    c:char;
  ccc:cardinal;
 fspr:pSDL_Surface;
begin
   ccc:=(1 shl 24)-1;
   fspr:=gfx_LoadSDLSurface('font',false,true);
   for i:=0 to 255 do
   begin
      c:=chr(i);
      with font_1[c] do
      begin
         surf:=gfx_CreateSDLSurface(font_w1,font_w1);
         SDL_FillRect(surf,nil,0);
         SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
      end;

      vid_RECT^.x:=ord(i)*font_w1;
      vid_RECT^.y:=0;
      vid_RECT^.w:=font_w1;
      vid_RECT^.h:=font_w1;
      SDL_BLITSURFACE(fspr,vid_RECT,font_1[c].surf,nil);
   end;
   gfx_FreeSDLSurface(fspr);
end;

{$include _themes.pas}

procedure gfx_LoadAll;
var x,r:integer;
begin
   spr_empty   :=gfx_CreateSDLSurface(1,1);
   SDL_SetColorKey(spr_empty,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(spr_empty,0,0));

   ui_minimap :=gfx_CreateSDLSurface(ui_CtrlPanelW-1,ui_CtrlPanelW-1);
   ui_mminimap:=gfx_CreateSDLSurface(ui_CtrlPanelW-1,ui_CtrlPanelW-1);
   ui_bminimap:=gfx_CreateSDLSurface(ui_CtrlPanelW-1,ui_CtrlPanelW-1);

   theme_DefSprite:=gfx_CreateSDLSurface(64,64);
   boxColor(theme_DefSprite,0,0,theme_DefSprite^.w,theme_DefSprite^.h,c_black);

   for x:=1 to vid_MaxScreenSprites do new(vid_ScreenSpritesL[x]);

   vid_PrimitivesS:=0;
   setlength(vid_PrimitivesL,vid_MaxScreenSprites);

   with spr_dummy do
   begin
      h   :=1;
      w   :=1;
      hh  :=1;
      hw  :=1;
      surf:=spr_empty;
   end;
   pspr_dummy:=@spr_dummy;

   with spr_dmodel do
   begin
      sm_spritesLast:=0;
      sm_spritesNum:=1;
      setlength(sm_spritesL,sm_spritesNum);
      sm_spritesL[sm_spritesLast]:=spr_dummy;
      sm_kind :=smt_effect;
   end;
   spr_pdmodel:=@spr_dmodel;

   gfx_LoadFont;

   ui_fog_surf := gfx_CreateSDLSurface(fog_cr*2,fog_cr*2);
   boxColor(ui_fog_surf,0,0,ui_fog_surf^.w,ui_fog_surf^.h,c_purple);
   filledcircleColor(ui_fog_surf,fog_cr,fog_cr,fog_cr,c_black);
   SDL_SetColorKey(ui_fog_surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(ui_fog_surf,0,0));
   for x:=0 to ui_fog_surf^.w-1 do
   for r:=0 to ui_fog_surf^.h-1 do
     if((x+r)mod 4)=0 then
       pixelColor(ui_fog_surf,x,r,c_purple);

   with spr_cp_out do
   begin
      hw:=gm_cptp_r-6;
      hh:=hw;
      w:=hw*2;
      h:=w;
      surf:=gfx_CreateSDLSurface(1,1);
      SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(surf,0,0));
   end;

   spr_mback:= gfx_LoadSDLSurface('mback'   ,false,true);
   spr_mlogo:= gfx_LoadSDLSurface('mlogo'   ,false,true);


   menu_Surface:=gfx_CreateSDLSurface(menu_w, menu_h);

   spr_b_action   := gfx_LoadButton('b_action' ,ui_ButtonW1);
   spr_b_paction  := gfx_LoadButton('b_paction',ui_ButtonW1);
   spr_b_delete   := gfx_LoadButton('b_destroy',ui_ButtonW1);
   spr_b_attack   := gfx_LoadButton('b_attack' ,ui_ButtonW1);
   spr_b_rebuild  := gfx_LoadButton('b_rebuild',ui_ButtonW1);
   spr_b_move     := gfx_LoadButton('b_move'   ,ui_ButtonW1);
   spr_b_patrol   := gfx_LoadButton('b_patrol' ,ui_ButtonW1);
   spr_b_apatrol  := gfx_LoadButton('b_apatrol',ui_ButtonW1);
   spr_b_stop     := gfx_LoadButton('b_stop'   ,ui_ButtonW1);
   spr_b_hold     := gfx_LoadButton('b_hold'   ,ui_ButtonW1);
   spr_b_selall   := gfx_LoadButton('b_selall' ,ui_ButtonW1);
   spr_b_cancel   := gfx_LoadButton('b_cancle' ,ui_ButtonW1);
   spr_b_rfast    := gfx_LoadButton('b_rfast'  ,ui_ButtonW1);
   spr_b_rforw1   := gfx_LoadButton('b_rforw1' ,ui_ButtonW1);
   spr_b_rforw2   := gfx_LoadButton('b_rforw2' ,ui_ButtonW1);
   spr_b_rforw3   := gfx_LoadButton('b_rforw3' ,ui_ButtonW1);
   spr_b_rback1   := gfx_LoadButton('b_rback1' ,ui_ButtonW1);
   spr_b_rback2   := gfx_LoadButton('b_rback2' ,ui_ButtonW1);
   spr_b_rback3   := gfx_LoadButton('b_rback3' ,ui_ButtonW1);
   spr_b_rfog     := gfx_LoadButton('b_fog'    ,ui_ButtonW1);
   spr_b_rlog     := gfx_LoadButton('b_log'    ,ui_ButtonW1);
   spr_b_rstop    := gfx_LoadButton('b_rstop'  ,ui_ButtonW1);
   spr_b_rvis     := gfx_LoadButton('b_rvis'   ,ui_ButtonW1);
   spr_b_mmark    := gfx_LoadButton('b_mmark'  ,ui_ButtonW1);
   spr_b_rstrike  := gfx_LoadButton('b_rstrike',ui_ButtonW1);
   spr_b_invuln   := gfx_LoadButton('b_invuln' ,ui_ButtonW1);

   for x:=0 to 3 do spr_tabs[x]:=gfx_LoadButton('tabs'+b2s(x),ui_TabButtonW-8);

   spr_cursor     := gfx_LoadSDLSurface('cursor'   ,true ,true);
   spr_CursorHint_Edit      := gfx_LoadSDLSurface('h_Edit'   ,false,true);
   spr_CursorHint_MLB[false]:= gfx_LoadSDLSurface('h_MLB0'   ,true ,true);
   spr_CursorHint_MLB[true ]:= gfx_LoadSDLSurface('h_MLB1'   ,true ,true);
   spr_CursorHint_MRB[false]:= gfx_LoadSDLSurface('h_MRB0'   ,true ,true);
   spr_CursorHint_MRB[true ]:= gfx_LoadSDLSurface('h_MRB1'   ,true ,true);
   spr_CursorHint_MMB[false]:= gfx_LoadSDLSurface('h_MMB0'   ,true ,true);
   spr_CursorHint_MMB[true ]:= gfx_LoadSDLSurface('h_MMB1'   ,true ,true);

   spr_c_earth    := gfx_LoadSDLSurface('M_EARTH'  ,false,true);
   spr_c_mars     := gfx_LoadSDLSurface('M_MARS'   ,false,true);
   spr_c_hell     := gfx_LoadSDLSurface('M_HELL'   ,false,true);
   spr_c_phobos   := gfx_LoadSDLSurface('M_PHOBOS' ,false,true);
   spr_c_deimos   := gfx_LoadSDLSurface('M_DEIMOS' ,false,true);

   gfx_LoadMWSModel(@spr_lostsoul       ,race_units[r_hell]+'h_u0_'        ,smt_lost     );
   gfx_LoadMWSModel(@spr_phantom        ,race_units[r_hell]+'h_u0a_'       ,smt_lost     );
   gfx_LoadMWSModel(@spr_imp            ,race_units[r_hell]+'h_u1_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_demon          ,race_units[r_hell]+'h_u2_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_cacodemon      ,race_units[r_hell]+'h_u3_'        ,smt_caco     );
   gfx_LoadMWSModel(@spr_knight         ,race_units[r_hell]+'h_u4k_'       ,smt_imp      );
   gfx_LoadMWSModel(@spr_baron          ,race_units[r_hell]+'h_u4_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_cyberdemon     ,race_units[r_hell]+'h_u5_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_mastermind     ,race_units[r_hell]+'h_u6_'        ,smt_mmind    );
   gfx_LoadMWSModel(@spr_pain           ,race_units[r_hell]+'h_u7_'        ,smt_pain     );
   gfx_LoadMWSModel(@spr_revenant       ,race_units[r_hell]+'h_u8_'        ,smt_revenant );
   gfx_LoadMWSModel(@spr_mancubus       ,race_units[r_hell]+'h_u9_'        ,smt_mancubus );
   gfx_LoadMWSModel(@spr_arachnotron    ,race_units[r_hell]+'h_u10_'       ,smt_archno   );
   gfx_LoadMWSModel(@spr_archvile       ,race_units[r_hell]+'h_u11_'       ,smt_arch     );

   gfx_LoadMWSModel(@spr_ZFormer        ,race_units[r_hell]+'h_z0_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZEngineer      ,race_units[r_hell]+'h_z0s_'       ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZSergant       ,race_units[r_hell]+'h_z1_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZSSergant      ,race_units[r_hell]+'h_z1s_'       ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZCommando      ,race_units[r_hell]+'h_z2_'        ,smt_zcommando);
   gfx_LoadMWSModel(@spr_ZAntiaircrafter,race_units[r_hell]+'h_zr_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZSiege         ,race_units[r_hell]+'h_z3_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZFMajor        ,race_units[r_hell]+'h_z4j_'       ,smt_fmajor   );
   gfx_LoadMWSModel(@spr_ZBFG           ,race_units[r_hell]+'h_z5_'        ,smt_imp      );

   gfx_LoadMWSModel(@spr_Medic          ,race_units[r_uac ]+'u_u0_'        ,smt_medic    );
   gfx_LoadMWSModel(@spr_Engineer       ,race_units[r_uac ]+'u_u1_'        ,smt_marine0  );
   gfx_LoadMWSModel(@spr_Scout          ,race_units[r_uac ]+'u_u1s_'       ,smt_imp      );
   gfx_LoadMWSModel(@spr_Sergant        ,race_units[r_uac ]+'u_u2_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_SSergant       ,race_units[r_uac ]+'u_u2s_'       ,smt_imp      );
   gfx_LoadMWSModel(@spr_Commando       ,race_units[r_uac ]+'u_u3_'        ,smt_zcommando);
   gfx_LoadMWSModel(@spr_Antiaircrafter ,race_units[r_uac ]+'u_u4r_'       ,smt_imp      );
   gfx_LoadMWSModel(@spr_Siege          ,race_units[r_uac ]+'u_u4_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_FMajor         ,race_units[r_uac ]+'u_u5j_'       ,smt_fmajor   );
   gfx_LoadMWSModel(@spr_BFG            ,race_units[r_uac ]+'u_u6_'        ,smt_imp      );
   gfx_LoadMWSModel(@spr_FAPC           ,race_units[r_uac ]+'u_u8_'        ,smt_transport);
   gfx_LoadMWSModel(@spr_APC            ,race_units[r_uac ]+'uac_tank_'    ,smt_apc      );
   gfx_LoadMWSModel(@spr_Terminator     ,race_units[r_uac ]+'u_u9_'        ,smt_terminat );
   gfx_LoadMWSModel(@spr_Tank           ,race_units[r_uac ]+'u_u10_'       ,smt_tank     );
   gfx_LoadMWSModel(@spr_Flyer          ,race_units[r_uac ]+'u_u11_'       ,smt_flyer    );
   gfx_LoadMWSModel(@spr_Transport      ,race_units[r_uac ]+'transport'    ,smt_transport);
   gfx_LoadMWSModel(@spr_UACBot         ,race_units[r_uac ]+'uacd'         ,smt_flyer    );


   gfx_LoadMWSModel(@spr_HKeep          ,race_buildings[r_hell]+'h_b0_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HAKeep         ,race_buildings[r_hell]+'h_b0a_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate1         ,race_buildings[r_hell]+'h_b1a'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate2         ,race_buildings[r_hell]+'h_b1b'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate3         ,race_buildings[r_hell]+'h_b1c'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate4         ,race_buildings[r_hell]+'h_b1d'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HSymbol1       ,race_buildings[r_hell]+'h_b2_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HSymbol2       ,race_buildings[r_hell]+'h_b2a'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HSymbol3       ,race_buildings[r_hell]+'h_b2b'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HSymbol4       ,race_buildings[r_hell]+'h_b2c'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools1        ,race_buildings[r_hell]+'h_b3_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools2        ,race_buildings[r_hell]+'h_b3a'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools3        ,race_buildings[r_hell]+'h_b3b'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools4        ,race_buildings[r_hell]+'h_b3c'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HTower         ,race_buildings[r_hell]+'h_b4_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HTeleport      ,race_buildings[r_hell]+'h_b5_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HMonastery     ,race_buildings[r_hell]+'h_b6_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HTotem         ,race_buildings[r_hell]+'h_b7_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HAltar         ,race_buildings[r_hell]+'h_b8_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HFortress      ,race_buildings[r_hell]+'h_b9_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPentagram     ,race_buildings[r_hell]+'h_b10_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HCommandCenter ,race_buildings[r_hell]+'h_hcc_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HACommandCenter,race_buildings[r_hell]+'h_hcca_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks1     ,race_buildings[r_hell]+'h_hbar_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks2     ,race_buildings[r_hell]+'h_hbara'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks3     ,race_buildings[r_hell]+'h_hbarb'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks4     ,race_buildings[r_hell]+'h_hbarc'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HEyeNest       ,race_buildings[r_hell]+'heyenest_',smt_buiding  );

   gfx_LoadMWSModel(@spr_UCommandCenter ,race_buildings[r_uac ] +'u_b0_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UACommandCenter,race_buildings[r_uac ] +'u_b0a_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks1     ,race_buildings[r_uac ] +'u_b1_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks2     ,race_buildings[r_uac ] +'u_b1a'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks3     ,race_buildings[r_uac ] +'u_b1b'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks4     ,race_buildings[r_uac ] +'u_b1c'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UGenerator1    ,race_buildings[r_uac ] +'u_b2_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UGenerator2    ,race_buildings[r_uac ] +'u_b2b_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UGenerator3    ,race_buildings[r_uac ] +'u_b2c_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UGenerator4    ,race_buildings[r_uac ] +'u_b2d_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory1,race_buildings[r_uac ] +'u_b3_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory2,race_buildings[r_uac ] +'u_b3a'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory3,race_buildings[r_uac ] +'u_b3b'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory4,race_buildings[r_uac ] +'u_b6_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UTurret        ,race_buildings[r_uac ] +'u_b4_'   ,smt_turret   );
   gfx_LoadMWSModel(@spr_URadar         ,race_buildings[r_uac ] +'u_b5_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UTechCenter    ,race_buildings[r_uac ] +'u_b13_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UPTurret       ,race_buildings[r_uac ] +'u_b7_'   ,smt_turret   );
   gfx_LoadMWSModel(@spr_URocketL       ,race_buildings[r_uac ] +'u_b8_'   ,smt_buiding  );
   gfx_LoadMWSModel(@spr_URTurret       ,race_buildings[r_uac ] +'u_b9_'   ,smt_turret2  );
   gfx_LoadMWSModel(@spr_UNuclearPlant  ,race_buildings[r_uac ] +'u_b10_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory1      ,race_buildings[r_uac ] +'u_b11_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory2      ,race_buildings[r_uac ] +'u_b12_'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory3      ,race_buildings[r_uac ] +'u_b12a'  ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory4      ,race_buildings[r_uac ] +'u_b12b'  ,smt_buiding  );

   gfx_LoadMWSModel(@spr_Mine           ,race_buildings[r_uac ] +'u_mine0'   ,smt_buiding);
   gfx_LoadMWSModel(@spr_portal         ,race_buildings[r_uac ] +'u_portal0' ,smt_buiding);
   gfx_LoadMWSModel(@spr_starport       ,race_buildings[r_uac ] +'u_starport',smt_buiding);
   gfx_LoadMWSModel(@spr_ubase0         ,race_buildings[r_uac ] +'u_base00'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase1         ,race_buildings[r_uac ] +'u_base10'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase2         ,race_buildings[r_uac ] +'u_base20'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase3         ,race_buildings[r_uac ] +'u_base30'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase4         ,race_buildings[r_uac ] +'u_base40'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase5         ,race_buildings[r_uac ] +'u_base50'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubuild0        ,race_buildings[r_uac ] +'build00'   ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubuild1        ,race_buildings[r_uac ] +'build10'   ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubuild2        ,race_buildings[r_uac ] +'build20'   ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubuild3        ,race_buildings[r_uac ] +'build30'   ,smt_buiding);

   gfx_LoadMWSModel(@spr_db_h0          ,race_dir[r_hell]+'db_h0'        ,smt_effect );
   gfx_LoadMWSModel(@spr_db_h1          ,race_dir[r_hell]+'db_h1'        ,smt_effect );
   gfx_LoadMWSModel(@spr_db_u0          ,race_dir[r_uac ]+'db_u0'        ,smt_effect );
   gfx_LoadMWSModel(@spr_db_u1          ,race_dir[r_uac ]+'db_u1'        ,smt_effect );

   gfx_LoadMWSModel(@spr_h_p0           ,race_missiles[r_hell]+'h_p0_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_h_p1           ,race_missiles[r_hell]+'h_p1_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_h_p2           ,race_missiles[r_hell]+'h_p2_'   ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p3           ,race_missiles[r_hell]+'h_p3_'   ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p4           ,race_missiles[r_hell]+'h_p4_'   ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p5           ,race_missiles[r_hell]+'h_p5_'   ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p6           ,race_missiles[r_hell]+'h_p6_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_h_p7           ,race_missiles[r_hell]+'h_p7_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p0           ,race_missiles[r_uac ]+'u_p0_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p1           ,race_missiles[r_uac ]+'u_p1_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p2           ,race_missiles[r_uac ]+'u_p2_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p3           ,race_missiles[r_uac ]+'u_p3_'   ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p8           ,race_missiles[r_uac ]+'u_p8_'   ,smt_missile);
   gfx_LoadMWSModel(@spr_u_p9           ,race_missiles[r_uac ]+'b'       ,smt_missile);

   spr_u_p1s:=spr_u_p1;
   with spr_u_p1s do sm_kind:=smt_effect2;

   gfx_LoadMWSModel(@spr_eff_bfg        ,effects_folder+'ef_bfg_'        ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_eb         ,effects_folder+'ef_eb'          ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_ebb        ,effects_folder+'ef_ebb'         ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_gtel       ,effects_folder+'ef_gt_'         ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_tel        ,effects_folder+'ef_tel_'        ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_exp        ,effects_folder+'ef_exp_'        ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_exp2       ,effects_folder+'exp2_'          ,smt_effect );
   gfx_LoadMWSModel(@spr_eff_g          ,effects_folder+'g_'             ,smt_effect );
   gfx_LoadMWSModel(@spr_blood          ,effects_folder+'blood'          ,smt_effect );

   gfx_LoadMWTexture(@spr_RallyPoint[r_hell],race_dir[r_hell]+'h_mp'        ,true);
   gfx_LoadMWTexture(@spr_RallyPoint[r_uac ],race_dir[r_uac ]+'u_mp'        ,true);
   gfx_LoadMWTexture(@spr_ptur              ,race_dir[r_uac ]+'ptur'        ,true);

   gfx_LoadMWTexture(@spr_b4_a              ,race_buildings[r_uac ]+'u_b4_a',true);
   gfx_LoadMWTexture(@spr_b7_a              ,race_buildings[r_uac ]+'u_b7_a',true);
   gfx_LoadMWTexture(@spr_b9_a              ,race_buildings[r_uac ]+'u_b9_a',true);

   gfx_LoadMWTexture(@spr_stun              ,effects_folder+'stun'          ,true);
   gfx_LoadMWTexture(@spr_effect_Invuln     ,effects_folder+'invuln'        ,true);
   gfx_LoadMWTexture(@spr_effect_HVision    ,effects_folder+'hvision'       ,true);
   gfx_LoadMWTexture(@spr_effect_Scan       ,effects_folder+'scan'          ,true);
   gfx_LoadMWTexture(@spr_effect_Decay      ,effects_folder+'decay'         ,true);


   gfx_LoadMWTexture(@spr_cp_koth   ,'cp_koth',true);
   gfx_LoadMWTexture(@spr_cp_gen    ,'cp_gen' ,true);

   for x:=0 to spr_upgrade_icons do
   for r:=1 to r_cnt do
   with spr_b_Upgrades[r,x] do
   begin
      surf:= gfx_LoadButton(race_upgrades[r]+'b_up'+b2s(x),ui_ButtonW1);
      w   := surf^.w;h    := w;
      hw  := w div 2;hh   := hw;
   end;

   for x:=0 to 255 do
   spr_b_ab[x]:=spr_b_action;

   initEffects;
   InitThemes;
end;

procedure gfx_MakeUnitIcons;
var u:byte;
begin
   for u:=0 to 255 do
   with g_uids[u] do
   begin
      with uid_BTNBig do
      begin
         case uid_race of
         r_hell: surf:= gfx_LoadButtonFS(uid2spr(u,315,0)^.surf,ui_ButtonW1 );
         r_uac : surf:= gfx_LoadButtonFS(uid2spr(u,225,0)^.surf,ui_ButtonW1 );
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      with uid_BTNSmall do
      begin
         case uid_race of
         r_hell: surf:= gfx_LoadButtonFS(uid2spr(u,315,0)^.surf,ui_GroupIcoW1,1 );
         r_uac : surf:= gfx_LoadButtonFS(uid2spr(u,225,0)^.surf,ui_GroupIcoW1,1 );
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      {$IFDEF UNITDATA}
      with un_btn2 do
      begin
         case _urace of
         r_hell: surf:= LoadBtnFS(_uid2spr(u,315,0)^.surf,vid_BWd,1 );
         r_uac : surf:= LoadBtnFS(_uid2spr(u,225,0)^.surf,vid_BWd,1 );
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      {$ENDIF}
   end;
end;

procedure gfx_MakeAbilityIcons;
begin
   spr_b_ab[uab_Teleport        ]:=spr_b_Upgrades[r_hell,14].surf;
   spr_b_ab[uab_UACScan         ]:=spr_b_Upgrades[r_uac ,8 ].surf;
   spr_b_ab[uab_HTowerBlink     ]:=spr_b_Upgrades[r_hell,18].surf;
   spr_b_ab[uab_UACStrike       ]:=spr_b_rstrike;
   spr_b_ab[uab_HKeepBlink      ]:=spr_b_Upgrades[r_hell,9 ].surf;
   spr_b_ab[uab_RebuildInPoint  ]:=spr_b_paction;
   spr_b_ab[uab_HInvulnerability]:=spr_b_invuln;
   spr_b_ab[uab_SpawnLost       ]:=g_uids[UID_LostSoul].uid_BTNBig.surf;
   spr_b_ab[uab_HellVision      ]:=spr_b_Upgrades[r_hell,6 ].surf;
   spr_b_ab[uab_CCFly           ]:=spr_b_Upgrades[r_uac ,9 ].surf;
   spr_b_ab[uab_ToUACDron       ]:=g_uids[UID_UACDron].uid_BTNBig.surf;
   spr_b_ab[uab_Unload          ]:=spr_b_paction;
end;

procedure map_MakeDecals;
var i,ix,iy,rn:integer;
begin
   map_ter_decaln:=(ui_cam_w*ui_cam_h) div 19000;
   setlength(map_ter_decalL,map_ter_decaln);

   ui_mwa:= ui_cam_w+vid_ab*2;
   ui_mha:= ui_cam_h+vid_ab*2;

   ix:=longint(map_seed) mod ui_mwa;
   iy:=(g_random_i*5+ix)  mod ui_mha;
   rn:=ix*iy;
   for i:=1 to map_ter_decaln do
    with map_ter_decalL[i-1] do
    begin
       rn+=17;
       ix:=g_randomx(ix+rn       ,ui_mwa);
       iy:=g_randomx(iy+sqr(ix*i),ui_mha);
       decal_x :=ix;
       decal_y :=iy;
    end;
end;

procedure vid_CommonVars;
begin
   ui_vmb_x1   := vid_vw-ui_vmb_x0;
   ui_vmb_y1   := vid_vh-ui_vmb_y0;

   ui_textx     := ui_mapx+font_wh;
   ui_texty     := ui_mapy+font_wh;
   ui_hinty1    := ui_mapy+ui_cam_h-txt_line_h1*10;
   ui_hinty2    := ui_mapy+ui_cam_h-txt_line_h1*8;
   ui_hinty3    := ui_mapy+ui_cam_h-txt_line_h1*5;
   ui_hinty4    := ui_mapy+ui_cam_h-txt_line_h1*2;
   ui_chaty     := ui_hinty1-font_w1h;
   ui_logy      := ui_chaty-font_w1h;
   ui_oicox     := ui_mapx+ui_cam_w-font_w1;
   ui_uiuphx    := ui_mapx+(ui_cam_w div 2);
   ui_uiuphy    := ui_texty+font_w3;
   ui_uiplayery := ui_uiuphy+font_w1h;
   ui_game_log_height:=(ui_hinty1-font_w5) div font_w1h;

   ui_energx    := ui_uiuphx-150;
   ui_energy    := ui_texty;
   ui_armyx     := ui_uiuphx+40;
   ui_armyy     := ui_texty;
   ui_fpsx      := ui_mapx+ui_cam_w-(font_w1*font_w1h);
   ui_fpsy      := ui_texty;
   ui_apmx      := ui_fpsx;
   ui_apmy      := ui_fpsy+txt_line_h2;

   ui_ingamecl  :=(ui_cam_w-font_w1) div font_w1;

   ui_fog_gridw :=(ui_cam_w div fog_cw)+2;
   ui_fog_gridh :=(ui_cam_h div fog_cw)+2;
   setlength(ui_fog_fgrid,ui_fog_gridw,ui_fog_gridh);
   setlength(ui_fog_pgrid,ui_fog_gridw,ui_fog_gridh);

   map_mmvw     := round(ui_cam_w*map_mmcx);
   map_mmvh     := round(ui_cam_h*map_mmcx);
   ui_Camera_Bounds;

   map_MakeDecals;
end;

procedure vid_RemakeScreenSurfaces;
var i,y:integer;
procedure pline(x0,y0,x1,y1:integer;color:cardinal);
begin
   if(ui_ControlPanelPos<2)
   then lineColor(ui_panel,x0,y0,x1,y1,color)
   else lineColor(ui_panel,y0,x0,y1,x1,color);
end;
procedure prect(x0,y0,x1,y1:integer;color:cardinal);
begin
   if(ui_ControlPanelPos<2)
   then rectangleColor(ui_panel,x0,y0,x1,y1,color)
   else rectangleColor(ui_panel,y0,x0,y1,x1,color);
end;
begin
   gfx_FreeSDLSurface(ui_uipanel );
   gfx_FreeSDLSurface(ui_panel   );

   if(ui_ControlPanelPos<2)then // left-right
   begin
      ui_cam_w:=vid_vw-ui_CtrlPanelW;
      ui_cam_h:=vid_vh;

      if(ui_ControlPanelPos=0)
      then ui_mapx:=ui_CtrlPanelW
      else ui_mapx:=0;
      ui_mapy:=0;

      if(ui_ControlPanelPos=0)
      then ui_panelx:=0
      else ui_panelx:=ui_cam_w-1;
      ui_panely:=0;

      ui_uipanel:=gfx_CreateSDLSurface(ui_CtrlPanelW+1,vid_vh);
      ui_panel  :=gfx_CreateSDLSurface(ui_CtrlPanelW+1,vid_vh);

      vlineColor(ui_panel,ui_ButtonW1,ui_CtrlPanelW+ui_ButtonW1,ui_CtrlPanelH,c_white);
      vlineColor(ui_panel,ui_ButtonW2,ui_CtrlPanelW+ui_ButtonW1,ui_CtrlPanelH,c_white);
   end
   else
   begin
      ui_cam_w:=vid_vw;
      ui_cam_h:=vid_vh-ui_CtrlPanelW;

      ui_mapx:=0;
      if(ui_ControlPanelPos=2)
      then ui_mapy:=ui_CtrlPanelW-1
      else ui_mapy:=0;

      ui_panelx:=0;
      if(ui_ControlPanelPos=2)
      then ui_panely:=0
      else ui_panely:=ui_cam_h-1;

      ui_uipanel:=gfx_CreateSDLSurface(vid_vw,ui_CtrlPanelW+1);
      ui_panel  :=gfx_CreateSDLSurface(vid_vw,ui_CtrlPanelW+1);

      hlineColor(ui_panel,ui_CtrlPanelW+ui_ButtonW1,ui_CtrlPanelH,ui_ButtonW1 ,c_white);
      hlineColor(ui_panel,ui_CtrlPanelW+ui_ButtonW1,ui_CtrlPanelH,ui_ButtonW2,c_white);
   end;

   ui_cam_hw:=ui_cam_w div 2;
   ui_cam_hh:=ui_cam_h div 2;

   rectangleColor(ui_panel,0,0,ui_panel^.w-1,ui_panel^.h-1,c_white);
   pline(0,ui_CtrlPanelW,ui_CtrlPanelW,ui_CtrlPanelW,c_white);

   //pline(0,ui_CtrlPanelW+ui_h3bw,ui_panel^.w,ui_CtrlPanelW+ui_h3bw,c_white);
   pline(0,ui_CtrlPanelW+ui_ButtonW1 ,ui_panel^.w,ui_CtrlPanelW+ui_ButtonW1 ,c_white);

   for y:=0 to 3 do
   pline(y*ui_TabButtonW,ui_CtrlPanelW,y*ui_TabButtonW,ui_CtrlPanelW+ui_ButtonW1,c_white);

   i:=4;
   y:=ui_ButtonW1*i;
   while (i<=ui_CtrlPanelBH) do
   begin
      pline(0,y,ui_CtrlPanelW,y,c_white);
      i+=1;
      y+=ui_ButtonW1;
   end;

   draw_sdlsurface(ui_uipanel,0,0,ui_panel);

   vid_CommonVars;
end;

procedure vid_MakeScreen;
begin
   if(vid_screen<>nil)then sdl_freesurface(vid_screen);

   if(vid_windowed)
   then vid_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, vid_vflags)
   else vid_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, vid_vflags + SDL_FULLSCREEN);

   if(vid_screen=nil)then begin WriteSDLError; exit; end;

   vid_RemakeScreenSurfaces;
end;


