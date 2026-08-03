
procedure InitRX2Y;
var r,x:integer;
begin
   for r:=0 to fog_MaxR do
     for x:=0 to r do
       CircleRX2Y[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
end;

procedure gfx_MakeScreenshot;
var i:integer;
    s:shortstring;
begin
   i:=0;
   repeat
      i+=1;
      s:=folder_screenshots+str_ScreenShotPrefix+i2s(i)+fileExt_Scrshot;
   until not FileExists(s);
   if(not MainMenu)then
     GameLog_Chat(255,LocalPlayer,s);
   s:=s+#0;
   sdl_saveBMP(vid_screen,@s[1]);
end;

function gfx_ShadowColor(c:TMWColor):TMWColor;
begin
   gfx_ShadowColor:=128 +
   (((c and $FF000000) shr 25) shl 24) +
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 );
end;

function gfx_TMWColor(r,g,b,a:byte):TMWColor;
begin
   gfx_TMWColor:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

procedure gfx_InitColors;
begin
   c_dred    :=gfx_TMWColor(190,  0,  0,255);
   c_red     :=gfx_TMWColor(255,  0,  0,255);
   c_ared    :=gfx_TMWColor(255,  0,  0,82 );
   c_ltred   :=gfx_TMWColor(255,100,100,255);
   c_orange  :=gfx_TMWColor(255,140,  0,255);
   c_dorange :=gfx_TMWColor(230, 96,  0,255);
   c_aorange :=gfx_TMWColor(255,140,  0,82 );
   c_brown   :=gfx_TMWColor(140,90 , 10,255);
   c_yellow  :=gfx_TMWColor(255,255,  0,255);
   c_dyellow :=gfx_TMWColor(220,220,  0,255);
   c_lime    :=gfx_TMWColor(0  ,255,  0,255);
   c_alime   :=gfx_TMWColor(0  ,255,  0,42 );
   c_aaqua   :=gfx_TMWColor(0  ,255,255,42 );
   c_aqua    :=gfx_TMWColor(0  ,255,255,255);
   c_purple  :=gfx_TMWColor(255,0  ,255,255);
   c_violet  :=gfx_TMWColor(147,100,255,255);
   c_green   :=gfx_TMWColor(0  ,150,0  ,255);
   c_ablue   :=gfx_TMWColor(0  ,0  ,255,82);
   c_blue    :=gfx_TMWColor(50 ,50 ,255,255);
   c_ltblue  :=gfx_TMWColor(150,150,255,255);
   c_white   :=gfx_TMWColor(255,255,255,255);
   c_awhite  :=gfx_TMWColor(255,255,255,40 );
   c_gray    :=gfx_TMWColor(120,120,120,255);
   c_ltgray  :=gfx_TMWColor(200,200,200,255);
   c_dgray   :=gfx_TMWColor(70 ,70 ,70 ,255);
   c_agray   :=gfx_TMWColor(80 ,80 ,80 ,128);
   c_black   :=gfx_TMWColor(0  ,0  ,0  ,255);
   c_menuback:=gfx_TMWColor(0  ,0  ,1  ,255);
   c_ablack  :=gfx_TMWColor(0  ,0  ,0  ,128);
   c_iblack  :=gfx_TMWColor(0  ,0  ,0  ,210);
   c_mablack :=gfx_TMWColor(0  ,0  ,0  ,96 );

   ui_max_color[false]:=c_orange;
   ui_max_color[true ]:=c_gray;
   ui_cenergy  [false]:=c_white;
   ui_cenergy  [true ]:=c_red;

   ui_blink_color2[false]:=c_black;
   ui_blink_color2[true ]:=c_yellow;

   ui_blink_color1[false]:=c_black;
   ui_blink_color1[true ]:=c_gray;
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

procedure SDL_SETpixel(srf:PSDL_SURFACE;x,y:integer;color:TMWColor);
var bpp:byte;
begin
   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;

   move( (@(color))^, (srf^.pixels+(y*srf^.pitch)+x*bpp)^, bpp);
end;

function SDL_GETpixel(srf:PSDL_SURFACE;x,y:integer):TMWColor;
var bpp:byte;
begin
   SDL_GETpixel:=0;

   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;

   move( (srf^.pixels+(y*srf^.pitch)+x*bpp)^, (@SDL_GETpixel)^, bpp);
end;

procedure gfx_SetTransparent(tar:pSDL_Surface;x:integer=0;y:integer=0);
begin
   SDL_SetColorKey(tar,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(tar,x,y));
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
      gfx_LoadSDLSurface:=gfx_LoadSDLSurfaceEXT(folder_graphic+fn+fexts[i]);
      if(gfx_LoadSDLSurface<>spr_empty)then
      begin
         if(transparent)then gfx_SetTransparent(gfx_LoadSDLSurface);
         break;
      end
      else
        if(i=fextn)and(log)then WriteLog(folder_graphic+fn);
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

procedure gfx_LoadMWSModel(pMWSModel:PTMWSModel;name:shortstring;mkind:byte);
var t:TMWTexture;
procedure AddSelRect(ip:pinteger;vl:integer);
begin
   if(ip^=0)
   then ip^:=vl
   else ip^:=(ip^+vl) div 2;
end;
begin
   with pMWSModel^ do
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
      sm_spritesLast:=sm_spritesNum-1;
      sm_kind:=mkind;
   end;
end;

procedure gfx_MakeLiquidTemplate(pTarget,pTemplate:pSDL_Surface;shiftX,shiftY,d,r:integer;animStyle:TThemeAnimStyle;style:TThemeCircleStyle;itb:boolean);
var x,y,dir,i,e,p,rand:integer;
begin
   boxColor(pTarget,0,0,d,d,c_purple);

   x:=shiftX;
   while (x<d) do
   begin
      y:=shiftY;
      while (y<d) do
      begin
         draw_sdlsurface(pTarget,x,y,pTemplate);
         y+=pTemplate^.h;
      end;
      x+=pTemplate^.w;
   end;

   if(style=tcs_square)then exit;

   if(style=tcs_default)then
   begin
      if(animStyle=tas_liquid)
      then e:=8
      else e:=d div 32;
      rand:=0;
      dir :=0;
      i   :=r+e;
      while(dir<=360)do
      begin
         case animStyle of
         tas_liquid: p:=e+random(e);
         else        p:=e+((dir*i+rand) mod e);
         end;
         x:=r+trunc(i*cos(dir*degtorad));
         y:=r+trunc(i*sin(dir*degtorad));
         filledcircleColor(pTarget,x,y,p,c_purple);
         dir+=max2i(1,(trunc(p*180/(pi*r)) div 3)*4 );
         rand+=13;
      end;
   end;

   dir:=0;
   case style of
   tcs_default: i:=r div 17;
   tcs_smooth : i:=-5;
   end;

   while(dir<=360)do
   begin
      p:=r-i;
      dir+=3;
      x:=r+trunc(d*cos(dir*degtorad));
      y:=r+trunc(d*sin(dir*degtorad));
      filledcircleColor(pTarget,x,y,p,c_purple);
   end;
   if(itb)then filledcircleColor(pTarget,r,r,r-(r div 6)-10,c_purple);
end;

procedure gfx_MapMakeRBattleFront;
var
ts : psdl_surface;
a,
wsp,
hsp: integer;
begin
   if(theme_map_pRBattleFront=theme_map_RBattleFront)and(theme_map_RBattleFront>=0)then exit;
   theme_map_pRBattleFront:=theme_map_RBattleFront;

   if(theme_map_RBattleFront<0)or(theme_map_RBattleFront>=theme_spr_liquidN)
   then ts:=theme_DefSprite
   else ts:=theme_spr_liquidL[theme_map_RBattleFront].surf;

   wsp:=(ts^.w div 4)*((map_seed mod 3)-1);
   hsp:=(ts^.h div 4)*((abs(g_random_i) mod 3)-1);
   if(wsp=0)and(hsp=0)then wsp:=(ts^.w div 4);

   for a:=1 to LiquidAnimCount do
     with spr_fireblueFront[a] do
     begin
        w:=map_ObstacleR(2)*3;
        h:=w;
        gfx_FreeSDLSurface(surf);
        surf:=gfx_CreateSDLSurface(w,w);
        hw:=w div 2;
        hh:=hw;

        gfx_MakeLiquidTemplate(surf,ts,-ts^.w-(a*wsp),-ts^.h-(a*hsp),w,hh,tas_magma,tcs_default,false);

        case a of
        1,3 : boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,30));
        2   : boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,60));
        end;

        gfx_SetTransparent(surf);
     end;
end;

procedure gfx_MapMakeLiquidFront;
var
ts : psdl_surface;
a,
wsp,
hsp: integer;
begin
   if(theme_map_pLiquidFront=theme_map_LiquidFront)and(theme_map_pLiquidFront>=0)then exit;
   theme_map_pLiquidFront:=theme_map_LiquidFront;

   if(theme_map_LiquidFront<0)or(theme_map_LiquidFront>=theme_spr_liquidN)then
   begin
      ts                    :=theme_DefSprite;
      theme_liquid_animStyle:=tas_liquid;
      theme_liquid_color    :=c_gray;
      theme_liquid_animTime :=fr_fpsh;
   end
   else
   begin
      ts                    :=theme_spr_liquidL[theme_map_LiquidFront].surf;
      theme_liquid_animStyle:=theme_liquids_AnimStyle[theme_map_LiquidFront];
      theme_liquid_color    :=theme_liquids_MMColor  [theme_map_LiquidFront];
      theme_liquid_animTime :=theme_liquids_AnimTime[theme_map_LiquidFront];
   end;

   case theme_liquid_animStyle of
   tas_liquid: begin
                  wsp:=(ts^.w div 4)*((map_seed mod 3)-1);
                  hsp:=(ts^.h div 4)*((abs(g_random_i) mod 3)-1);
                  if(wsp=0)and(hsp=0)then wsp:=(ts^.w div 4);
               end;
   else
      wsp:=0;
      hsp:=0;
   end;

   for a:=1 to LiquidAnimCount do
     with spr_liquidFront[a] do
     begin
        w:=map_ObstacleR(1)*3;
        h:=w;
        gfx_FreeSDLSurface(surf);
        surf:=gfx_CreateSDLSurface(w,w);
        hw:=w div 2;
        hh:=hw;

        gfx_MakeLiquidTemplate(surf,ts,-ts^.w-(a*wsp),-ts^.h-(a*hsp),w,hh,theme_liquid_animStyle,tcs_default,false);

        if(theme_liquid_animStyle=tas_magma)then
         case a of
         1,3 : boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,30));
         2   : boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,60));
         end;

        gfx_SetTransparent(surf);
     end;
end;

procedure gfx_MapMakeLiquidBack;
var ts:psdl_surface;
begin
   if(theme_map_pLiquidBack=theme_map_LiquidBack)and(theme_map_LiquidBack>=0)then exit;
   theme_map_pLiquidBack:=theme_map_LiquidBack;

   if(theme_map_LiquidBack<0)or(theme_map_LiquidBack>=theme_spr_terrainN)
   then ts := theme_DefSprite
   else ts := theme_spr_terrainL[theme_map_LiquidBack].surf;

   with spr_liquidBack do
   begin
      w:=map_ObstacleR(1)*3+20;
      h:=w;
      gfx_FreeSDLSurface(surf);
      surf:=gfx_CreateSDLSurface(w,w);
      hw:=w div 2;
      hh:=hw;
      gfx_MakeLiquidTemplate(surf,ts,0,0,w,hw,tas_liquid,theme_liquid_style,true);
      boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,50));
      gfx_SetTransparent(surf);
   end;

   with spr_fireblueBack do
   begin
      w:=map_ObstacleR(2)*3+20;
      h:=w;
      gfx_FreeSDLSurface(surf);
      surf:=gfx_CreateSDLSurface(w,w);
      hw:=w div 2;
      hh:=hw;
      gfx_MakeLiquidTemplate(surf,ts,0,0,w,hw,tas_liquid,theme_liquid_style,true);
      boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,50));
      gfx_SetTransparent(surf);
   end;
end;

procedure gfx_MapMakeCrater;
var ts:psdl_surface;
    i :integer;
begin
   if(theme_map_pCrater=theme_map_Crater)and(theme_map_pCrater>=0)then exit;
   theme_map_pCrater:=theme_map_Crater;

   if(theme_map_Crater<0)or(theme_map_Crater>=theme_spr_terrainN)
   then ts := theme_DefSprite
   else ts := theme_spr_terrainL[theme_map_Crater].surf;

   for i:=1 to crater_ri do
     with spr_crater[i] do
     begin
        w:=crater_r[i]*2;
        h:=w;
        gfx_FreeSDLSurface(surf);
        surf:=gfx_CreateSDLSurface(w,w);
        hw:=crater_r[i];
        hh:=hw;
        gfx_MakeLiquidTemplate(surf,ts,0,0,w,hw,tas_liquid,theme_crater_style,false);
        boxColor(surf,0,0,w,w,gfx_TMWColor(0,0,0,70));
        if(theme_crater_style<>tcs_square)then
          gfx_SetTransparent(surf);
     end;
end;

procedure gfx_MapMakeTerrain;
var
x,y,
w,h:integer;
ts :pSDL_Surface;
begin
   if(theme_map_pTerrain=theme_map_Terrain)and(theme_map_pTerrain>=0)then exit;
   theme_map_pTerrain:=theme_map_Terrain;

   if(map_terrain<>nil) then
   begin
      sdl_freesurface(map_terrain);
      map_terrain:=nil;
   end;

   if(theme_map_Terrain<0)or(theme_map_Terrain>=theme_spr_terrainN)
   then ts:=theme_DefSprite
   else ts:=theme_spr_terrainL[theme_map_Terrain].surf;

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

function gfx_ResizeSurface(src:pSDL_Surface;coff:single):pSDL_Surface;
var tst:pSDL_Surface;
begin
   tst:=ROTOZOOMSURFACE(src,0,coff,0);
   gfx_ResizeSurface:=sdl_displayformat(tst);
   gfx_FreeSDLSurface(tst);
end;

function gfx_ButtonLoad(fn:shortstring;bw:integer;transparent:boolean=true):pSDL_Surface;
var ts:pSDl_Surface;
   hwb:integer;
begin
   hwb:=bw div 2;
   ts:=gfx_LoadSDLSurface(fn,false,true);
   gfx_ButtonLoad:=gfx_CreateSDLSurface(bw-1,bw-1);
   if(ts^.h>bw)
   then draw_sdlsurface(gfx_ButtonLoad,hwb-(ts^.w div 2),0,ts)
   else draw_sdlsurface(gfx_ButtonLoad,hwb-(ts^.w div 2),hwb-(ts^.h div 2),ts);
   gfx_FreeSDLSurface(ts);
   if(transparent)then
     gfx_SetTransparent(gfx_ButtonLoad);
end;

function gfx_ButtonMakeFromSurface(ts:pSDl_Surface;bw:integer;blackrect:byte=3;transparent:boolean=true):pSDL_Surface;
var tst:pSDL_Surface;
   coff:single;
    hwb:integer;
begin
   if(ts=spr_empty)then
   begin
      gfx_ButtonMakeFromSurface:=ts;
      exit;
   end;

   hwb:=bw div 2;

   if(ts^.w<=bw)or(ts^.h<=bw)
   then coff:=1
   else
    if(ts^.w<ts^.h)
    then coff:=bw/ts^.w
    else coff:=bw/ts^.h;

   tst:=gfx_ResizeSurface(ts,coff);
   gfx_ButtonMakeFromSurface:=gfx_CreateSDLSurface(bw-1,bw-1);
   if(tst^.h>bw)
   then draw_sdlsurface(gfx_ButtonMakeFromSurface,hwb-(tst^.w div 2),2,tst)
   else draw_sdlsurface(gfx_ButtonMakeFromSurface,hwb-(tst^.w div 2),hwb-(tst^.h div 2),tst);
   while(blackrect>0)do
   begin
      blackrect-=1;
      rectangleColor(gfx_ButtonMakeFromSurface,blackrect,blackrect,gfx_ButtonMakeFromSurface^.w-blackrect-1,gfx_ButtonMakeFromSurface^.h-blackrect-1,c_black);
   end;
   SDL_FreeSurface(tst);
   if(transparent)then
     gfx_SetTransparent(gfx_ButtonMakeFromSurface);
end;

function gfx_ResizeSurfaceCMask(src:pSDL_Surface;newSize:integer;applyMask:TMWColor):pSDL_Surface;
begin
   if(src=spr_empty)
   then gfx_ResizeSurfaceCMask:=src
   else
   begin
      if(src^.w<src^.h)
      then gfx_ResizeSurfaceCMask:=gfx_ResizeSurface(src,newSize/src^.h)
      else gfx_ResizeSurfaceCMask:=gfx_ResizeSurface(src,newSize/src^.w);
      if(applyMask>0)then boxColor(gfx_ResizeSurfaceCMask,0,0,gfx_ResizeSurfaceCMask^.w,
                                                              gfx_ResizeSurfaceCMask^.h,applyMask);
   end;
end;

procedure gfx_MakeFogTileSet;
var
x,y:integer;
fsurf:pSDL_Surface;
b10,
b01,b11,b21,
b12  :boolean;
begin
   //   ui_fog_Tiles
   fsurf := gfx_CreateSDLSurface(fog_cr*2,fog_cr*2);
   boxColor(fsurf,0,0,fsurf^.w,fsurf^.h,c_purple);
   filledcircleColor(fsurf,fog_cr,fog_cr,fog_cr,c_black);
   gfx_SetTransparent(fsurf);
   for x:=0 to fsurf^.w-1 do
   for y:=0 to fsurf^.h-1 do
     if((x+y)mod 4)=0 then
       pixelColor(fsurf,x,y,c_purple);

   for b10:=false to true do
   for b01:=false to true do
   for b11:=false to true do
   for b21:=false to true do
   for b12:=false to true do
   begin
      x:=TileSetGetN(b10,b01,b11,b21,b12);
      if(0<=x)and(x<=fog_TileSetSize)then
      begin
         ui_fog_Tiles[x]:=gfx_CreateSDLSurface(fog_cw,fog_cw);
         boxColor(ui_fog_Tiles[x],0,0,fog_cw,fog_cw,c_purple);
         gfx_SetTransparent(ui_fog_Tiles[x]);

         if(b10)then draw_sdlsurface(ui_fog_Tiles[x],       -fog_ds,-fog_cw-fog_ds,fsurf);
         if(b01)then draw_sdlsurface(ui_fog_Tiles[x],-fog_cw-fog_ds,       -fog_ds,fsurf);
         if(b11)then draw_sdlsurface(ui_fog_Tiles[x],       -fog_ds,       -fog_ds,fsurf);
         if(b21)then draw_sdlsurface(ui_fog_Tiles[x], fog_cw-fog_ds,       -fog_ds,fsurf);
         if(b12)then draw_sdlsurface(ui_fog_Tiles[x],       -fog_ds, fog_cw-fog_ds,fsurf);
      end;
   end;

   gfx_FreeSDLSurface(fsurf);
end;

procedure gfx_LoadFont(fname:shortstring);
var i:byte;
    c:char;
  ccc:TMWColor;
 fspr:pSDL_Surface;
begin
   ccc:=(1 shl 24)-1;
   fspr:=gfx_LoadSDLSurface(fname,false,true);
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
var
x,r:integer;
tst:pSDL_Surface;
begin
   spr_empty  :=gfx_CreateSDLSurface(1,1);
   gfx_SetTransparent(spr_empty);

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
      sm_spritesNum :=1;
      setlength(sm_spritesL,sm_spritesNum);
      sm_spritesL[sm_spritesLast]:=spr_dummy;
      sm_kind :=smt_effect;
   end;
   spr_pdmodel:=@spr_dmodel;

   gfx_LoadFont('font');

   gfx_MakeFogTileSet;

   with spr_kp_out do
   begin
      hw:=keyPoint_DefR-6;
      hh:=hw;
      w :=hw*2;
      h :=w;
      surf:=gfx_CreateSDLSurface(1,1);
      gfx_SetTransparent(surf);
   end;
   with spr_kp_outG do
   begin
      hw:=keyPoint_GenR-6;
      hh:=hw;
      w :=hw*2;
      h :=w;
      surf:=gfx_CreateSDLSurface(1,1);
      gfx_SetTransparent(surf);
   end;

   // menu surfaces
   spr_MenuBackgroundL:=gfx_LoadSDLSurface('mback',false,true);
   spr_MenuBackgroundD:=gfx_CreateSDLSurface(spr_MenuBackgroundL^.w,spr_MenuBackgroundL^.h);
   tst:= gfx_LoadSDLSurface('mlogo',false,true);
   draw_sdlsurface(spr_MenuBackgroundD,0,0,spr_MenuBackgroundL);
   with spr_MenuBackgroundD^ do
   begin
   boxColor(spr_MenuBackgroundD,0,0,w,h,c_mablack);
   draw_sdlsurface(spr_MenuBackgroundD,(w div 2)-(tst^.w div 2),0,tst);
   draw_text(spr_MenuBackgroundD,w      ,h,str_version  ,ta_RB,255,c_white);
   draw_text(spr_MenuBackgroundD,w div 2,h,str_copyright,ta_MB,255,c_white);
   end;
   with spr_MenuBackgroundL^ do
   begin
   draw_sdlsurface(spr_MenuBackgroundL,(w div 2)-(tst^.w div 2),0,tst);
   draw_text(spr_MenuBackgroundL,w      ,h,str_version  ,ta_RB,255,c_white);
   draw_text(spr_MenuBackgroundL,w div 2,h,str_copyright,ta_MB,255,c_white);
   end;
   gfx_FreeSDLSurface(tst);

   menu_Background:=gfx_CreateSDLSurface(spr_MenuBackgroundL^.w,spr_MenuBackgroundL^.h);
   menu_Surface   :=gfx_CreateSDLSurface(menu_w, menu_h);
   boxColor(menu_Surface,0,0,menu_w,menu_h,c_menuback);
   SDL_SetColorKey(menu_Surface,SDL_SRCCOLORKEY,sdl_getpixel(menu_Surface,0,0));

   spr_uibtn_Delete            := gfx_ButtonLoad(folder_ui+'b_destroy'         ,ui_ButtonW1);
   spr_uibtn_Attack            := gfx_ButtonLoad(folder_ui+'b_attack'          ,ui_ButtonW1);
   spr_uibtn_Move              := gfx_ButtonLoad(folder_ui+'b_move'            ,ui_ButtonW1);
   spr_uibtn_Patrol            := gfx_ButtonLoad(folder_ui+'b_patrol'          ,ui_ButtonW1);
   spr_uibtn_APatrol           := gfx_ButtonLoad(folder_ui+'b_apatrol'         ,ui_ButtonW1);
   spr_uibtn_Stop              := gfx_ButtonLoad(folder_ui+'b_stop'            ,ui_ButtonW1);
   spr_uibtn_Hold              := gfx_ButtonLoad(folder_ui+'b_hold'            ,ui_ButtonW1);
   spr_uibtn_F1                := gfx_ButtonLoad(folder_ui+'b_F1'              ,ui_ButtonW1);
   spr_uibtn_F2                := gfx_ButtonLoad(folder_ui+'b_F2'              ,ui_ButtonW1);
   spr_uibtn_ProdCancel        := gfx_ButtonLoad(folder_ui+'b_cancle'          ,ui_ButtonW1);
   spr_uibtn_ReplayFast        := gfx_ButtonLoad(folder_ui+'b_rfast'           ,ui_ButtonW1);
   spr_uibtn_ReplayForw1       := gfx_ButtonLoad(folder_ui+'b_rforw1'          ,ui_ButtonW1);
   spr_uibtn_ReplayForw2       := gfx_ButtonLoad(folder_ui+'b_rforw2'          ,ui_ButtonW1);
   spr_uibtn_ReplayForw3       := gfx_ButtonLoad(folder_ui+'b_rforw3'          ,ui_ButtonW1);
   spr_uibtn_ReplayBack1       := gfx_ButtonLoad(folder_ui+'b_rback1'          ,ui_ButtonW1);
   spr_uibtn_ReplayBack2       := gfx_ButtonLoad(folder_ui+'b_rback2'          ,ui_ButtonW1);
   spr_uibtn_ReplayBack3       := gfx_ButtonLoad(folder_ui+'b_rback3'          ,ui_ButtonW1);
   spr_uibtn_ReplayFog         := gfx_ButtonLoad(folder_ui+'b_fog'             ,ui_ButtonW1);
   spr_uibtn_ReplayLog         := gfx_ButtonLoad(folder_ui+'b_log'             ,ui_ButtonW1);
   spr_uibtn_ReplayPause       := gfx_ButtonLoad(folder_ui+'b_rstop'           ,ui_ButtonW1);
   spr_uibtn_ReplayPOV         := gfx_ButtonLoad(folder_ui+'b_rvis'            ,ui_ButtonW1);
   spr_uibtn_markLook          := gfx_ButtonLoad(folder_ui+'b_markLook'        ,ui_ButtonW1);
   spr_uibtn_markAttack        := gfx_ButtonLoad(folder_ui+'b_markAttack'      ,ui_ButtonW1);
   spr_uibtn_AbilityUACGeneral := gfx_ButtonLoad(folder_ui+'b_UACGeneral'      ,ui_ButtonW1);
   spr_uibtn_AbilityBribe      := gfx_ButtonLoad(folder_ui+'b_Bribe'           ,ui_ButtonW1);
   spr_uibtn_AbilityHack       := gfx_ButtonLoad(folder_ui+'b_Hack'            ,ui_ButtonW1);
   spr_uibtn_AbilityUACStrike  := gfx_ButtonLoad(folder_ui+'b_rstrike'         ,ui_ButtonW1);
   spr_uibtn_AbilitySpawnLost  := gfx_ButtonLoad(folder_ui+'b_SpawnLost'       ,ui_ButtonW1);
   spr_uibtn_AbilitySpawnLostTo:= gfx_ButtonLoad(folder_ui+'b_SpawnLostTo'     ,ui_ButtonW1);
   spr_uibtn_AbilityRecall     := gfx_ButtonLoad(folder_ui+'b_recall'          ,ui_ButtonW1);
   spr_uibtn_AbilityUnload     := gfx_ButtonLoad(folder_ui+'b_unload'          ,ui_ButtonW1);
   spr_uibtn_AbilityUnloadTo   := gfx_ButtonLoad(folder_ui+'b_unloadto'        ,ui_ButtonW1);
   spr_uibtn_AbilityCCLand     := gfx_ButtonLoad(folder_ui+'b_CCland'          ,ui_ButtonW1);
   spr_uibtn_AbilityCCLandTo   := gfx_ButtonLoad(folder_ui+'b_CClandTo'        ,ui_ButtonW1);
   spr_uibtn_AbilitySInvuln    := gfx_ButtonLoad(folder_ui+'b_SInvulnerability',ui_ButtonW1);
   spr_uibtn_AbilitySInvis     := gfx_ButtonLoad(folder_ui+'b_SInvisibility'   ,ui_ButtonW1);
   spr_uibtn_AbilitySSoul      := gfx_ButtonLoad(folder_ui+'b_SSoul'           ,ui_ButtonW1);
   spr_uibtn_AbilitySDDamage   := gfx_ButtonLoad(folder_ui+'b_SDoubleDamage'   ,ui_ButtonW1);
   spr_uibtn_AbilitySRDamage   := gfx_ButtonLoad(folder_ui+'b_SResistDamage'   ,ui_ButtonW1);
   spr_uibtn_AbilitySTurbo     := gfx_ButtonLoad(folder_ui+'b_STurbo'          ,ui_ButtonW1);

   spr_uibtn_Tabs[0]           := gfx_ButtonLoad(folder_ui+'b_F1'              ,ui_TabButtonW-2,false);
   spr_uibtn_Tabs[1]           := gfx_ButtonLoad(folder_ui+'b_F2'              ,ui_TabButtonW-2,false);
   spr_uibtn_Tabs[2]           := gfx_ButtonLoad(folder_ui+'tab_upgrades'      ,ui_TabButtonW-2,false);
   spr_uibtn_Tabs[3]           := gfx_ButtonLoad(folder_ui+'tab_controls'      ,ui_TabButtonW-2,false);

   spr_doc_ui                  := gfx_LoadSDLSurface('doc_ui'        ,false,true);
   spr_doc_Upgrades            := gfx_LoadSDLSurface('doc_upgrades'  ,false,true);
   spr_doc_Generators          := gfx_LoadSDLSurface('doc_Generators',false,true);
   spr_doc_KeyPoint            := gfx_LoadSDLSurface('doc_KeyPoint'  ,false,true);
   spr_doc_koth                := gfx_LoadSDLSurface('doc_koth'      ,false,true);

   for r:=1 to r_count do
   begin
      spr_RaceRank[r]:=gfx_LoadSDLSurface(folder_RaceUI[r]+'rank',true,true);
      spr_uipanel_EmptyBTN[r]:=gfx_ResizeSurfaceCMask(gfx_LoadSDLSurface(folder_RaceUI[r]+'EmptyBTN',false,true),ui_ButtonW1-2,gfx_TMWColor(0,0,0,160));
   end;

   spr_cursor               := gfx_LoadSDLSurface('cursor'   ,true ,true);
   spr_CursorHint_Edit      := gfx_LoadSDLSurface('h_Edit'   ,false,true);
   spr_CursorHint_MLB[false]:= gfx_LoadSDLSurface('h_MLB0'   ,true ,true);
   spr_CursorHint_MLB[true ]:= gfx_LoadSDLSurface('h_MLB1'   ,true ,true);
   spr_CursorHint_MRB[false]:= gfx_LoadSDLSurface('h_MRB0'   ,true ,true);
   spr_CursorHint_MRB[true ]:= gfx_LoadSDLSurface('h_MRB1'   ,true ,true);
   spr_CursorHint_MMB[false]:= gfx_LoadSDLSurface('h_MMB0'   ,true ,true);
   spr_CursorHint_MMB[true ]:= gfx_LoadSDLSurface('h_MMB1'   ,true ,true);
   for x:=0 to 8 do
   spr_cursor_move[x]       := gfx_LoadSDLSurface('cursor_move_'+i2s(x),true ,true);
   spr_cursor_movex[0]:=spr_cursor_move[0]^.w div 2;
   spr_cursor_movey[0]:=spr_cursor_move[0]^.h div 2;
   spr_cursor_movex[1]:=spr_cursor_move[1]^.w;
   spr_cursor_movey[1]:=spr_cursor_move[1]^.h div 2;
   spr_cursor_movex[2]:=spr_cursor_move[2]^.w;
   spr_cursor_movey[2]:=0;
   spr_cursor_movex[3]:=spr_cursor_move[3]^.w div 2;
   spr_cursor_movey[3]:=0;
   spr_cursor_movex[4]:=0;
   spr_cursor_movey[4]:=0;
   spr_cursor_movex[5]:=0;
   spr_cursor_movey[5]:=spr_cursor_move[5]^.h div 2;
   spr_cursor_movex[6]:=0;
   spr_cursor_movey[6]:=spr_cursor_move[6]^.h;
   spr_cursor_movex[7]:=spr_cursor_move[7]^.w div 2;
   spr_cursor_movey[7]:=spr_cursor_move[7]^.h;
   spr_cursor_movex[8]:=spr_cursor_move[8]^.w;
   spr_cursor_movey[8]:=spr_cursor_move[8]^.h;

   tst                      := gfx_LoadSDLSurface('cursor_sub',true ,true);
   spr_cursorSubR           := gfx_CreateSDLSurface(tst^.w,tst^.h);
   draw_sdlsurface(spr_cursorSubR,0,0,tst);
   boxColor(spr_cursorSubR,0,0,tst^.w,tst^.h,gfx_TMWColor(255,0  ,0  ,200));
   gfx_SetTransparent(spr_cursorSubR);

   spr_cursorSubG           := gfx_CreateSDLSurface(tst^.w,tst^.h);
   draw_sdlsurface(spr_cursorSubG,0,0,tst);
   boxColor(spr_cursorSubG,0,0,tst^.w,tst^.h,gfx_TMWColor(0  ,255,0  ,200));
   gfx_SetTransparent(spr_cursorSubG);

   spr_cursorSubA           := gfx_CreateSDLSurface(tst^.w,tst^.h);
   draw_sdlsurface(spr_cursorSubA,0,0,tst);
   boxColor(spr_cursorSubA,0,0,tst^.w,tst^.h,gfx_TMWColor(0  ,255,255,200));
   gfx_SetTransparent(spr_cursorSubA);
   gfx_FreeSDLSurface(tst);

   spr_cursorWh             := (spr_cursor^.w div 2)-(spr_cursorSubR^.w div 2);
   spr_cursorHh             := (spr_cursor^.h div 2)-(spr_cursorSubR^.h div 2);

   gfx_LoadMWSModel(@spr_lostsoul           ,folder_RaceUnits[r_hell]+'h_u0_'          ,smt_lost     );
   gfx_LoadMWSModel(@spr_phantom            ,folder_RaceUnits[r_hell]+'h_u0a_'         ,smt_lost     );
   gfx_LoadMWSModel(@spr_imp                ,folder_RaceUnits[r_hell]+'h_u1_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_demon              ,folder_RaceUnits[r_hell]+'h_u2_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_cacodemon          ,folder_RaceUnits[r_hell]+'h_u3_'          ,smt_caco     );
   gfx_LoadMWSModel(@spr_knight             ,folder_RaceUnits[r_hell]+'h_u4k_'         ,smt_imp      );
   gfx_LoadMWSModel(@spr_baron              ,folder_RaceUnits[r_hell]+'h_u4_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_cyberdemon         ,folder_RaceUnits[r_hell]+'h_u5_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_mastermind         ,folder_RaceUnits[r_hell]+'h_u6_'          ,smt_mmind    );
   gfx_LoadMWSModel(@spr_pain               ,folder_RaceUnits[r_hell]+'h_u7_'          ,smt_pain     );
   gfx_LoadMWSModel(@spr_revenant           ,folder_RaceUnits[r_hell]+'h_u8_'          ,smt_revenant );
   gfx_LoadMWSModel(@spr_mancubus           ,folder_RaceUnits[r_hell]+'h_u9_'          ,smt_mancubus );
   gfx_LoadMWSModel(@spr_arachnotron        ,folder_RaceUnits[r_hell]+'h_u10_'         ,smt_archno   );
   gfx_LoadMWSModel(@spr_archvile           ,folder_RaceUnits[r_hell]+'h_u11_'         ,smt_arch     );

   gfx_LoadMWSModel(@spr_ZFormer            ,folder_RaceUnits[r_hell]+'h_z0_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZEngineer          ,folder_RaceUnits[r_hell]+'h_z0s_'         ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZShotgunner        ,folder_RaceUnits[r_hell]+'h_z1_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZSSGunner          ,folder_RaceUnits[r_hell]+'h_z1s_'         ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZCommando          ,folder_RaceUnits[r_hell]+'h_z2_'          ,smt_zcommando);
   gfx_LoadMWSModel(@spr_ZAntiaircrafter    ,folder_RaceUnits[r_hell]+'h_zr_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZSiege             ,folder_RaceUnits[r_hell]+'h_z3_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_ZPlasmagunner      ,folder_RaceUnits[r_hell]+'h_z4j_'         ,smt_fplasmag );
   gfx_LoadMWSModel(@spr_ZBFG               ,folder_RaceUnits[r_hell]+'h_z5_'          ,smt_imp      );

   gfx_LoadMWSModel(@spr_Medic              ,folder_RaceUnits[r_uac ]+'u_u0_'          ,smt_medic    );
   gfx_LoadMWSModel(@spr_Engineer           ,folder_RaceUnits[r_uac ]+'u_u1_'          ,smt_marine0  );
   gfx_LoadMWSModel(@spr_Shotgunner         ,folder_RaceUnits[r_uac ]+'u_u2_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_SSGunner           ,folder_RaceUnits[r_uac ]+'u_u2s_'         ,smt_imp      );
   gfx_LoadMWSModel(@spr_Commando           ,folder_RaceUnits[r_uac ]+'u_u3_'          ,smt_zcommando);
   gfx_LoadMWSModel(@spr_Antiaircrafter     ,folder_RaceUnits[r_uac ]+'u_u4r_'         ,smt_imp      );
   gfx_LoadMWSModel(@spr_Siege              ,folder_RaceUnits[r_uac ]+'u_u4_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_Plasmagunner       ,folder_RaceUnits[r_uac ]+'u_u5j_'         ,smt_fplasmag );
   gfx_LoadMWSModel(@spr_BFG                ,folder_RaceUnits[r_uac ]+'u_u6_'          ,smt_imp      );
   gfx_LoadMWSModel(@spr_Transport          ,folder_RaceUnits[r_uac ]+'u_u8_'          ,smt_transport);
   gfx_LoadMWSModel(@spr_Terminator         ,folder_RaceUnits[r_uac ]+'u_u9_'          ,smt_terminat );
   gfx_LoadMWSModel(@spr_Tank               ,folder_RaceUnits[r_uac ]+'u_u10_'         ,smt_tank     );
   gfx_LoadMWSModel(@spr_Flyer              ,folder_RaceUnits[r_uac ]+'u_u11_'         ,smt_flyer    );
   gfx_LoadMWSModel(@spr_ATransport         ,folder_RaceUnits[r_uac ]+'transport'      ,smt_transport);
   gfx_LoadMWSModel(@spr_UACDron            ,folder_RaceUnits[r_uac ]+'uacd'           ,smt_flyer    );


   gfx_LoadMWSModel(@spr_HKeep              ,folder_RaceBuildings[r_hell]+'h_b0_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HAKeep             ,folder_RaceBuildings[r_hell]+'h_b0a_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate1             ,folder_RaceBuildings[r_hell]+'h_b1a'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate2             ,folder_RaceBuildings[r_hell]+'h_b1b'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate3             ,folder_RaceBuildings[r_hell]+'h_b1c'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HGate4             ,folder_RaceBuildings[r_hell]+'h_b1d'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools1            ,folder_RaceBuildings[r_hell]+'h_b3_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools2            ,folder_RaceBuildings[r_hell]+'h_b3a'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools3            ,folder_RaceBuildings[r_hell]+'h_b3b'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPools4            ,folder_RaceBuildings[r_hell]+'h_b3c'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HFTower            ,folder_RaceBuildings[r_hell]+'h_b4_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HTeleport          ,folder_RaceBuildings[r_hell]+'h_b5_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HMonastery         ,folder_RaceBuildings[r_hell]+'h_b6_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HTotem             ,folder_RaceBuildings[r_hell]+'h_b7_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HAltar             ,folder_RaceBuildings[r_hell]+'h_b8_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HFortress          ,folder_RaceBuildings[r_hell]+'h_b9_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HPentagram         ,folder_RaceBuildings[r_hell]+'h_b10_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HCommandCenter     ,folder_RaceBuildings[r_hell]+'h_hcc_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HACommandCenter    ,folder_RaceBuildings[r_hell]+'h_hcca_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks1         ,folder_RaceBuildings[r_hell]+'h_hbar_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks2         ,folder_RaceBuildings[r_hell]+'h_hbara'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks3         ,folder_RaceBuildings[r_hell]+'h_hbarb'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HBarracks4         ,folder_RaceBuildings[r_hell]+'h_hbarc'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HEye               ,folder_RaceBuildings[r_hell]+'heye_'      ,smt_buiding  );
   gfx_LoadMWSModel(@spr_HEyeNest           ,folder_RaceBuildings[r_hell]+'heyenest_'  ,smt_buiding  );

   gfx_LoadMWSModel(@spr_UCommandCenter     ,folder_RaceBuildings[r_uac ] +'u_b0_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UACommandCenter    ,folder_RaceBuildings[r_uac ] +'u_b0a_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks1         ,folder_RaceBuildings[r_uac ] +'u_b1_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks2         ,folder_RaceBuildings[r_uac ] +'u_b1a'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks3         ,folder_RaceBuildings[r_uac ] +'u_b1b'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UBarracks4         ,folder_RaceBuildings[r_uac ] +'u_b1c'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory1    ,folder_RaceBuildings[r_uac ] +'u_b3_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory2    ,folder_RaceBuildings[r_uac ] +'u_b3a'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory3    ,folder_RaceBuildings[r_uac ] +'u_b3b'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UWeaponFactory4    ,folder_RaceBuildings[r_uac ] +'u_b6_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UTurret            ,folder_RaceBuildings[r_uac ] +'u_b4_'     ,smt_turret   );
   gfx_LoadMWSModel(@spr_URadar             ,folder_RaceBuildings[r_uac ] +'u_b5_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UTechCenter        ,folder_RaceBuildings[r_uac ] +'u_b13_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UPTurret           ,folder_RaceBuildings[r_uac ] +'u_b7_'     ,smt_turret   );
   gfx_LoadMWSModel(@spr_URocketL           ,folder_RaceBuildings[r_uac ] +'u_b8_'     ,smt_buiding  );
   gfx_LoadMWSModel(@spr_URTurret           ,folder_RaceBuildings[r_uac ] +'u_b9_'     ,smt_turret2  );
   gfx_LoadMWSModel(@spr_UNuclearPlant      ,folder_RaceBuildings[r_uac ] +'u_b10_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory1          ,folder_RaceBuildings[r_uac ] +'u_b11_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory2          ,folder_RaceBuildings[r_uac ] +'u_b12_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory3          ,folder_RaceBuildings[r_uac ] +'u_b12a'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UFactory4          ,folder_RaceBuildings[r_uac ] +'u_b12b'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UAcademy           ,folder_RaceBuildings[r_uac ] +'u_b15_'    ,smt_buiding  );
   gfx_LoadMWSModel(@spr_UHPowerConductor   ,folder_RaceBuildings[r_uac ] +'u_b14_'    ,smt_buiding  );


   gfx_LoadMWSModel(@spr_portal             ,folder_RaceBuildings[r_uac ] +'u_portal0' ,smt_buiding);
   gfx_LoadMWSModel(@spr_starport           ,folder_RaceBuildings[r_uac ] +'u_starport',smt_buiding);
   gfx_LoadMWSModel(@spr_ubase0             ,folder_RaceBuildings[r_uac ] +'u_base00'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase1             ,folder_RaceBuildings[r_uac ] +'u_base10'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase2             ,folder_RaceBuildings[r_uac ] +'u_base20'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase3             ,folder_RaceBuildings[r_uac ] +'u_base30'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase4             ,folder_RaceBuildings[r_uac ] +'u_base40'  ,smt_buiding);
   gfx_LoadMWSModel(@spr_ubase5             ,folder_RaceBuildings[r_uac ] +'u_base50'  ,smt_buiding);

   gfx_LoadMWSModel(@spr_db_h0              ,folder_Race[r_hell]+'db_h0'               ,smt_effect );
   gfx_LoadMWSModel(@spr_db_h1              ,folder_Race[r_hell]+'db_h1'               ,smt_effect );
   gfx_LoadMWSModel(@spr_db_u0              ,folder_Race[r_uac ]+'db_u0'               ,smt_effect );
   gfx_LoadMWSModel(@spr_db_u1              ,folder_Race[r_uac ]+'db_u1'               ,smt_effect );

   gfx_LoadMWSModel(@spr_h_p0               ,folder_RaceMissiles[r_hell]+'h_p0_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_h_p1               ,folder_RaceMissiles[r_hell]+'h_p1_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_h_p2               ,folder_RaceMissiles[r_hell]+'h_p2_'       ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p3               ,folder_RaceMissiles[r_hell]+'h_p3_'       ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p4               ,folder_RaceMissiles[r_hell]+'h_p4_'       ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p5               ,folder_RaceMissiles[r_hell]+'h_p5_'       ,smt_missile);
   gfx_LoadMWSModel(@spr_h_p6               ,folder_RaceMissiles[r_hell]+'h_p6_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_h_p7               ,folder_RaceMissiles[r_hell]+'h_p7_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p0               ,folder_RaceMissiles[r_uac ]+'u_p0_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p1               ,folder_RaceMissiles[r_uac ]+'u_p1_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p2               ,folder_RaceMissiles[r_uac ]+'u_p2_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p3               ,folder_RaceMissiles[r_uac ]+'u_p3_'       ,smt_effect );
   gfx_LoadMWSModel(@spr_u_p8               ,folder_RaceMissiles[r_uac ]+'u_p8_'       ,smt_missile);
   gfx_LoadMWSModel(@spr_u_p9               ,folder_RaceMissiles[r_uac ]+'b'           ,smt_missile);

   gfx_LoadMWSModel(@spr_eff_bfg            ,folder_effects+'ef_bfg_'                  ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_eb             ,folder_effects+'ef_eb'                    ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_ebb            ,folder_effects+'ef_ebb'                   ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_gtel           ,folder_effects+'ef_gt_'                   ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_tel            ,folder_effects+'ef_tel_'                  ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_exp1           ,folder_effects+'ef_exp1_'                 ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_exp2           ,folder_effects+'ef_exp2_'                 ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_exp3           ,folder_effects+'ef_exp3_'                 ,smt_effect);
   gfx_LoadMWSModel(@spr_eff_g              ,folder_effects+'ef_g_'                    ,smt_effect);
   gfx_LoadMWSModel(@spr_blood              ,folder_effects+'ef_blood'                 ,smt_effect);

   gfx_LoadMWTexture(@spr_RallyPoint[r_hell],folder_Race[r_hell]+'h_mp'                ,true);
   gfx_LoadMWTexture(@spr_RallyPoint[r_uac ],folder_Race[r_uac ]+'u_mp'                ,true);
   gfx_LoadMWTexture(@spr_ptur              ,folder_Race[r_uac ]+'ptur'                ,true);

   gfx_LoadMWTexture(@spr_b4_a              ,folder_RaceBuildings[r_uac ]+'u_b4_a'     ,true);
   gfx_LoadMWTexture(@spr_b7_a              ,folder_RaceBuildings[r_uac ]+'u_b7_a'     ,true);
   gfx_LoadMWTexture(@spr_b9_a              ,folder_RaceBuildings[r_uac ]+'u_b9_a'     ,true);

   gfx_LoadMWTexture(@spr_buff_SphereInvuln ,folder_effects+'buff_SphereInvuln'        ,true);
   gfx_LoadMWTexture(@spr_buff_SphereInvis  ,folder_effects+'buff_SphereInvis'         ,true);
   gfx_LoadMWTexture(@spr_buff_SphereDArmor ,folder_effects+'buff_SphereDArmor'        ,true);
   gfx_LoadMWTexture(@spr_buff_SphereDDamage,folder_effects+'buff_SphereDDamage'       ,true);
   gfx_LoadMWTexture(@spr_buff_SphereTurbo  ,folder_effects+'buff_SphereTurbo'         ,true);
   gfx_LoadMWTexture(@spr_buff_SphereSoul   ,folder_effects+'buff_SphereSoul'          ,true);
   gfx_LoadMWTexture(@spr_buff_HellVision   ,folder_effects+'buff_HellVision'          ,true);
   gfx_LoadMWTexture(@spr_buff_Scan         ,folder_effects+'buff_scan'                ,true);
   gfx_LoadMWTexture(@spr_buff_Decay        ,folder_effects+'buff_decay'               ,true);
   gfx_LoadMWTexture(@spr_buff_Heroic       ,folder_effects+'buff_heroic'              ,true);

   gfx_LoadMWTexture(@spr_kp_koth           ,'kp_koth'                                 ,true);
   gfx_LoadMWTexture(@spr_kp_key[0]         ,'kp_key0'                                 ,true);
   gfx_LoadMWTexture(@spr_kp_key[1]         ,'kp_key1'                                 ,true);
   gfx_LoadMWTexture(@spr_kp_genT[0]        ,'kp_gen0'                                 ,true);
   gfx_LoadMWTexture(@spr_kp_genT[1]        ,'kp_gen1'                                 ,true);


   spr_u_p1s:=spr_u_p1;
   with spr_u_p1s do sm_kind:=smt_effect2;

   for x:=0 to spr_upgrade_icons do
   for r:=1 to r_count do
     with spr_uibtn_UpgradesBig[r,x] do
     begin
        surf:= gfx_ButtonLoad(folder_RaceUpgrades[r]+'b_up'+b2s(x),ui_ButtonW1);
        w   := surf^.w;h := w;
        hw  := w div 2;hh:= hw;
     end;

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
         r_hell: surf:= gfx_ButtonMakeFromSurface(gfx_uid2spr(u,315,0)^.surf,ui_ButtonW1 );
         r_uac : surf:= gfx_ButtonMakeFromSurface(gfx_uid2spr(u,225,0)^.surf,ui_ButtonW1 );
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      with uid_BTNSmall do
      begin
         case uid_race of
         r_hell: surf:= gfx_ButtonMakeFromSurface(gfx_uid2spr(u,315,0)^.surf,ui_GroupIcoW1,1,false);
         r_uac : surf:= gfx_ButtonMakeFromSurface(gfx_uid2spr(u,225,0)^.surf,ui_GroupIcoW1,1,false);
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      with uid_BTNDoc do
      begin
         case uid_race of
         r_hell: surf:= gfx_ButtonMakeFromSurface(gfx_uid2spr(u,315,0)^.surf,ui_ButtonWh,1 );
         r_uac : surf:= gfx_ButtonMakeFromSurface(gfx_uid2spr(u,225,0)^.surf,ui_ButtonWh,1 );
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
   end;
end;

procedure vid_CommonVars;
var
ui_UIPanelY1:integer;
begin
   ui_UIPanelY1  := ui_UIPanelY+ui_UIPanelH;

   ui_vmb_x1     := vid_vw-ui_vmb_x0;
   ui_vmb_y1     := vid_vh-ui_vmb_y0;
   ui_UIPortXC   := ui_UIPortX0+ui_cam_hw;

   // timer
   ui_timerX     := ui_UIPortX0+font_wh;
   ui_timerY     := ui_UIPortY0+font_wh;

   // game status, POV player
   ui_PovPlayerY := ui_UIPortY0+txt_line_h1*5;
   ui_GameStatusX:= vid_vw div 2;
   ui_GameStatusY:= ui_PovPlayerY+txt_line_h3;

   // Objectives
   ui_objectivesx:= ui_timerX;
   ui_objectivesy:= ui_timerY+txt_line_h3;

   // mouse hint position
   case ui_ControlPanelPos of
   cpp_left  : begin
               ui_MouseHintX:=ui_UIPanelW+font_w1;
               ui_MouseHintY:=ui_UIPanelW;
               end;
   cpp_right : begin
               ui_MouseHintX:=vid_vw-ui_UIPanelW-font_w1h-ui_HintLineLenUnit*font_w1;
               ui_MouseHintY:=ui_UIPanelW;
               end;
   cpp_top   : begin
               ui_MouseHintX:=ui_UIPanelX+ui_UIPanelH;
               ui_MouseHintY:=ui_UIPanelY1+txt_line_h2*4;
               end;
   cpp_bottom: begin
               ui_MouseHintX:=ui_UIPanelX+ui_UIPanelH;
               ui_MouseHintY:=ui_UIPanelY-font_w5;
               end;
   end;

   // last events list & chat
   case ui_ControlPanelPos of
   cpp_left  : begin
                  ui_logx:=ui_UIPanelX+ui_UIPanelW+font_wh;
                  ui_logy:=vid_vh-ui_ReplayBarH-txt_line_h1;
                  ui_log_LineLen:=byte(min2c(MaxChatStringLength,(vid_vw-font_w1-ui_UIPanelW) div font_w1));
               end;
   cpp_right : begin
                  ui_logx:=font_wh;
                  ui_logy:=vid_vh-ui_ReplayBarH-txt_line_h1;
                  ui_log_LineLen:=byte(min2c(MaxChatStringLength,(vid_vw-font_w1-ui_UIPanelW) div font_w1));
               end;
   cpp_top   : begin
                  ui_logx:=font_wh;
                  ui_logy:=vid_vh-ui_ReplayBarH-txt_line_h1;
                  ui_log_LineLen:=byte(min2c(MaxChatStringLength,(vid_vw-font_w1) div font_w1));
               end;
   cpp_bottom: begin
                  ui_logx:=font_wh;
                  ui_logy:=ui_UIPortY1-ui_ReplayBarH-txt_line_h1;
                  ui_log_LineLen:=byte(min2c(MaxChatStringLength,(vid_vw-font_w1) div font_w1));
               end;
   end;
   ui_log_ListSize:=((ui_UIPortY1-ui_UIPortY0)-ui_CtrlPanelW-ui_ReplayBarH-txt_line_h1) div txt_line_h2;

   // FPS  APM REC-status
   ui_FPSX      := ui_UIPortX1-(font_w1*font_w1h);
   if(ui_ControlPanelPos=cpp_top)
   then ui_FPSY := font_wh
   else ui_FPSY := ui_timerY;

   ui_APMx      := ui_FPSX;
   ui_APMy      := ui_FPSY+txt_line_h2;
   ui_RECy      := ui_APMy+txt_line_h2;

   // hotkey groups icons
   case ui_ControlPanelPos of
   cpp_top,
   cpp_bottom,
   cpp_left  : begin
               ui_groupX:=vid_vw-font_w1;
               ui_groupY:=ui_RECy+txt_line_h2;
               end;
   cpp_right : begin
               ui_groupX:=ui_UIPanelX-font_w1;
               ui_groupY:=ui_RECy+txt_line_h2;
               end;
   end;
   ui_RECx      := ui_groupX;

   // Replay progress bar
   ui_ReplayBarY := ui_UIPortY1;
   if(ui_ControlPanelPos=cpp_bottom)
   then ui_ReplayBarW:=ui_UIPanelW
   else ui_ReplayBarW:=vid_vw;
   case ui_ControlPanelPos of
   cpp_left  : begin
               if((ui_UIPanelY1+ui_ReplayBarH)<vid_vh)
               then ui_ReplayBarX:=0
               else
               begin
                  ui_ReplayBarX:=ui_UIPanelW;
                  ui_ReplayBarW-=ui_UIpanelW;
               end;
               end;
   cpp_right : begin
               ui_ReplayBarX:=0;
               if((ui_UIPanelY1+ui_ReplayBarH)>=vid_vh)
               then ui_ReplayBarW-=ui_UIpanelW;
               end;
   cpp_top   : ui_ReplayBarX:=0;
   cpp_bottom: ui_ReplayBarX:=ui_UIPanelX;
   end;
   ui_ReplayBarWh:=ui_ReplayBarW div 2;

   // OTHER

   ui_EnergyX   := ui_UIPortXC-font_w2*2;
   ui_EnergyY   := ui_timerY;
   ui_HellPowerY:= ui_EnergyY+txt_line_h2;
   ui_UACLootY  := ui_HellPowerY+txt_line_h2; ;
   ui_ArmyX     := ui_EnergyX+font_w1h;
   ui_ArmyY0    := ui_timerY;
   ui_ArmyY1    := ui_ArmyY0+txt_line_h2;
   ui_ArmyY2    := ui_ArmyY1+txt_line_h2;

   ui_fog_gridw :=(ui_cam_w div fog_cw)+2;
   ui_fog_gridh :=(ui_cam_h div fog_cw)+2;
   setlength(ui_fog_fgrid,ui_fog_gridw,ui_fog_gridh);
   setlength(ui_fog_pgrid,ui_fog_gridw,ui_fog_gridh);

   map_MiniMap_CamW     := round(ui_cam_w*map_MiniMap_cx);
   map_MiniMap_CamH     := round(ui_cam_h*map_MiniMap_cx);
   ui_Camera_Bounds;
end;

procedure vid_RemakeScreenSurfaces;
var i,y,
ui_UIPanelWh:integer;
procedure pline(x0,y0,x1,y1:integer;color:TMWColor);
begin
   if(ui_ControlPanelPos<2)
   then lineColor(ui_UIPanelTemplate,x0,y0,x1,y1,color)
   else lineColor(ui_UIPanelTemplate,y0,x0,y1,x1,color);
end;
procedure prect(x0,y0,x1,y1:integer;color:TMWColor);
begin
   if(ui_ControlPanelPos<2)
   then rectangleColor(ui_UIPanelTemplate,x0,y0,x1,y1,color)
   else rectangleColor(ui_UIPanelTemplate,y0,x0,y1,x1,color);
end;
begin
   gfx_FreeSDLSurface(ui_UIPanel);
   gfx_FreeSDLSurface(ui_UIPanelTemplate);

   ui_panel_race:=255;

   case ui_ControlPanelPos of
   cpp_left  : ui_UIPortX0:=ui_CtrlPanelW;
   cpp_right,
   cpp_top,
   cpp_bottom: ui_UIPortX0:=0;
   end;
   case ui_ControlPanelPos of
   cpp_right : ui_UIPortX1:=vid_vw-ui_CtrlPanelW;
   cpp_left,
   cpp_top,
   cpp_bottom: ui_UIPortX1:=vid_vw;
   end;
   case ui_ControlPanelPos of
   cpp_left,
   cpp_right,
   cpp_bottom: ui_UIPortY0:=0;
   cpp_top   : ui_UIPortY0:=ui_CtrlPanelW;
   end;
   case ui_ControlPanelPos of
   cpp_left,
   cpp_right,
   cpp_top   : ui_UIPortY1:=vid_vh;
   cpp_bottom: ui_UIPortY1:=vid_vh-ui_CtrlPanelW;
   end;

   ui_cam_w :=vid_vw;
   ui_cam_h :=vid_vh;
   ui_cam_hw:=ui_cam_w div 2;
   ui_cam_hh:=ui_cam_h div 2;

   if(ui_ControlPanelPos<2)then // left-right, vertical
   begin
      ui_UIPanelW :=ui_CtrlPanelWb;
      ui_UIPanelH :=ui_CtrlPanelH;
      ui_UIPanelWh:=ui_UIPanelW div 2;

      if(ui_ControlPanelPos=0)
      then ui_UIPanelX:=0
      else ui_UIPanelX:=ui_UIPortX1-1;
      ui_UIPanelY:=0;

      ui_UIPanel        :=gfx_CreateSDLSurface(ui_UIPanelW,ui_UIPanelH);
      ui_UIPanelTemplate:=gfx_CreateSDLSurface(ui_UIPanelW,ui_UIPanelH);

      vlineColor(ui_UIPanelTemplate,ui_ButtonW1,ui_UIPanelW+ui_ButtonW1,ui_UIPanelH,c_white);
      vlineColor(ui_UIPanelTemplate,ui_ButtonW2,ui_UIPanelW+ui_ButtonW1,ui_UIPanelH,c_white);
   end
   else
   begin
      ui_UIPanelW :=ui_CtrlPanelH;
      ui_UIPanelH :=ui_CtrlPanelWb;
      ui_UIPanelWh:=ui_UIPanelW div 2;

      if((ui_cam_w-ui_UIPanelW)<ui_UIPanelWh)
      then ui_UIPanelX:=0
      else ui_UIPanelX:=ui_cam_hw-ui_UIPanelWh;

      if(ui_ControlPanelPos=2)
      then ui_UIPanelY:=0
      else ui_UIPanelY:=ui_UIPortY1-1;

      ui_UIPanel        :=gfx_CreateSDLSurface(ui_UIPanelW,ui_UIPanelH);
      ui_UIPanelTemplate:=gfx_CreateSDLSurface(ui_UIPanelW,ui_UIPanelH);

      hlineColor(ui_UIPanelTemplate,ui_UIPanelH+ui_ButtonW1,ui_UIPanelW,ui_ButtonW1,c_white);
      hlineColor(ui_UIPanelTemplate,ui_UIPanelH+ui_ButtonW1,ui_UIPanelW,ui_ButtonW2,c_white);
   end;

   rectangleColor(ui_UIPanelTemplate,0,0,ui_UIPanelTemplate^.w-1,ui_UIPanelTemplate^.h-1,c_white);
   pline(0,ui_CtrlPanelW,ui_CtrlPanelW,ui_CtrlPanelW,c_white);

   pline(0,ui_CtrlPanelW+ui_ButtonW1 ,ui_UIPanelTemplate^.w,ui_CtrlPanelW+ui_ButtonW1 ,c_white);

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

   draw_sdlsurface(ui_UIPanel,0,0,ui_UIPanelTemplate);

   vid_CommonVars;
end;

procedure vid_MakeScreen;
const windowed2flags: array[false..true] of cardinal = (vid_sdlvflags + SDL_FULLSCREEN,vid_sdlvflags);
begin
   if(vid_screen<>nil)then sdl_freesurface(vid_screen);

   vid_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, windowed2flags[vid_windowed]);

   if(vid_screen=nil)then
   begin
      WriteSDLError;
      halt;
   end;

   vid_RemakeScreenSurfaces;
end;


