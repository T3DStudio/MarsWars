
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

function cardinalBytes(c:cardinal):shortstring;
begin
   cardinalBytes:=b2s((c and $FF000000)shr 24)+','+b2s((c and $00FF0000)shr 16)+','+b2s((c and $0000FF00)shr 8)+','+b2s(c and $000000FF);
end;

function gfx_SDLSurfaceGetColor(surface:pSDL_Surface):cardinal;
var
rC,gC,bC,
rR,gR,bR,
rM,gM,bM:byte;
color   :cardinal;
x,y     :integer;
begin
   for x:=0 to surface^.w-1 do
   for y:=0 to surface^.h-1 do
   begin
      color:=SDL_GETpixel(surface,x,y);

      rC:=(color and $00FF0000) shr 16;
      gC:=(color and $0000FF00) shr 8;
      bC:=(color and $000000FF);


      if(x=0)and(y=0)then
      begin
         rR:=rC;
         gR:=gC;
         bR:=bC;
         rM:=rC;
         gM:=gC;
         bM:=bC;
      end
      else
      begin
         if(rC>rM)then rM:=rC;
         if(gC>gM)then gM:=gC;
         if(bC>bM)then bM:=bC;
         rR:=(rR+rC+rM)div 3;
         gR:=(gR+gC+gM)div 3;
         bR:=(bR+bC+bM)div 3;
      end;
   end;
   gfx_SDLSurfaceGetColor:=rgba2c(rR,gR,bR,255);
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
   if(sf<>nil)and(sf<>r_empty)then sdl_FreeSurface(sf);
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

procedure gfx_FillSurfaceBySurface(sTar,sTile:pSDL_Surface;animStepX,animStepY:integer);
var tx,ty:integer;
begin
   if(sTar =r_empty)
   or(sTile=r_empty)then exit;
   animStepX:=-abs(animStepX mod sTile^.w);
   animStepY:=-abs(animStepY mod sTile^.h);
   tx:=animStepX;
   while tx<sTar^.w do
   begin
      ty:=animStepy;
      while ty<sTar^.h do
      begin
         draw_surf(sTar,tx,ty,sTile);
         ty+=sTile^.h;
      end;
      tx+=sTile^.w;
   end;
end;

procedure gfx_MakeTileSet(baseSurface:pSDL_Surface;tileSetTarget,tileSetTemplate:pTMWTileSet;animStepX,animStepY:integer;colorMask,TransColor:cardinal);
var
tw,
thw,
tileX      : integer;
b00,b10,b20,
b01,    b21,
b02,b12,b22: boolean;
begin
   tw :=tileSetTemplate^[0].w;
   thw:=tileSetTemplate^[0].hw;

   // full tiled
   with tileSetTarget^[0] do
   begin
      gfx_SDLSurfaceFree(sdlSurface);
      sdlSurface:=gfx_SDLSurfaceCreate(tw,tw);
      boxColor(sdlSurface,0,0,tw,tw,TransColor);
      SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(sdlSurface,0,0));
      gfx_FillSurfaceBySurface(sdlSurface,baseSurface,animStepX,animStepY);
      if(colorMask>0)then boxColor(sdlSurface,0,0,tw,tw,colorMask);
      w :=tw; h :=w;
      hw:=thw;hh:=hw;
   end;

   for b00:=false to true do
   for b10:=false to true do
   for b20:=false to true do
   for b01:=false to true do
   for b21:=false to true do
   for b02:=false to true do
   for b12:=false to true do
   for b22:=false to true do
   begin
      tileX:=0;

      if(b00)then tileX+=1  ;
      if(b10)then tileX+=2  ;
      if(b20)then tileX+=4  ;
      if(b01)then tileX+=8  ;
      if(b21)then tileX+=16 ;
      if(b02)then tileX+=32 ;
      if(b12)then tileX+=64 ;
      if(b22)then tileX+=128;

      if(tileX=0)then continue;

      with tileSetTarget^[tileX] do
      begin
         gfx_SDLSurfaceFree(sdlSurface);
         sdlSurface:=gfx_SDLSurfaceCreate(tw,tw);
         gfx_FillSurfaceBySurface(sdlSurface,baseSurface,animStepX,animStepY);
         draw_surf(sdlSurface,0,0,tileSetTemplate^[tileX].sdlSurface);
         if(colorMask>0)then boxColor(sdlSurface,0,0,tw,tw,colorMask);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(sdlSurface,thw,thw));
         w :=tw ;h := w;
         hw:=thw;hh:=hw;
      end;
   end;
end;

procedure gfx_MakeTileSetTemplate(transColor,templateColor:cardinal;tw:integer;tileSet:pTMWTileSet;edgeStyle:byte;rstep:integer;random_i:byte);
var
b00,b10,b20,
b01,    b21,
b02,b12,b22: boolean;
sTemplate  : pSDL_Surface;
tileX,
ix,iy,
tr ,tr2,thw,
tw0,tw1,tw2: integer;
brushx,
brushy     : array[0..2] of integer;
brushr     : array[0..2] of array[0..2] of integer;
function CheckNearestBrush(tx,ty,bnxSkip,bnySkip:integer):boolean;
var ix,iy:byte;
begin
   CheckNearestBrush:=false;
   if(0<=tx)and(0<=ty)and(tx<=tw)and(ty<=tw)then
   begin
      for ix:=0 to 2 do
      for iy:=0 to 2 do
       if not((ix=bnxSkip)and(iy=bnySkip))then
        if(brushr[ix,iy]>0)then
         if(point_dist_int(brushx[ix],brushy[iy],tx,ty)<=brushr[ix,iy])then
         begin
            CheckNearestBrush:=true;
            break;
         end;
   end
   else CheckNearestBrush:=true;
end;
procedure DrawBrush(ix,iy:byte;bx,by,br:integer);
var
edgeRMax,
edgeR,
tx,ty  : integer;
dirStart,
dir,
dirStep: single;
begin
   case edgeStyle of
tes_fog   : filledcircleColor(sTemplate,bx,by,br,templateColor);
tes_nature: begin
            filledcircleColor(sTemplate,bx,by,br,templateColor);
            dirStep :=8;
            edgeRMax:=round((pi*br*dirStep)/180);
            if(edgeRMax>1)then
            begin
               dirStart:=point_dir(bx,by,thw,thw);
               dir     :=dirStart;
               while(true)do
               begin
                  edgeR:=(random_table[random_i] mod edgeRMax)+2;
                  tx:=bx+round(br*cos(dir*degtorad));
                  ty:=by-round(br*sin(dir*degtorad));
                  if(CheckNearestBrush(tx,ty,ix,iy))
                  then break
                  else filledcircleColor(sTemplate,tx,ty,edgeR,transColor);
                  dir+=dirStep;
                  random_i+=1;
               end;
               dir:=dirStart;
               while(true)do
               begin
                  edgeR:=(random_table[random_i] mod edgeRMax)+2;
                  dir-=dirStep;
                  tx:=bx+round(br*cos(dir*degtorad));
                  ty:=by-round(br*sin(dir*degtorad));
                  if(CheckNearestBrush(tx,ty,ix,iy))
                  then break
                  else filledcircleColor(sTemplate,tx,ty,edgeR,transColor);
                  random_i+=1;
               end;
            end;
            end;
tes_tech  : boxColor(sTemplate,bx-br,by-br,bx+br,by+br,templateColor);
   end;
end;
begin
   thw:=tw div 2;
   tr :=round(thw*1.45)+rstep;
   if(edgeStyle<>tes_tech)
   then tr2:=round(thw*2.2 )+rstep
   else tr2:=tr;
   tw0:=-thw;
   tw1:= thw;
   tw2:=tw+thw;
   brushx[0]:=tw0;
   brushx[1]:=tw1;
   brushx[2]:=tw2;
   brushy[0]:=tw0;
   brushy[1]:=tw1;
   brushy[2]:=tw2;
   sTemplate:=gfx_SDLSurfaceCreate(tw,tw);

   // full tiled
   with tileSet^[0] do
   begin
      gfx_SDLSurfaceFree(sdlSurface);
      sdlSurface:=r_empty;
      w :=tw; h :=w;
      hw:=thw;hh:=hw;
   end;

   for b00:=false to true do
   for b10:=false to true do
   for b20:=false to true do
   for b01:=false to true do
   for b21:=false to true do
   for b02:=false to true do
   for b12:=false to true do
   for b22:=false to true do
   begin
      boxColor(sTemplate,0,0,tw,tw,transColor);
      tileX:=0;
      FillChar(brushr,SizeOf(brushr),0);

      if(b00)then begin tileX+=1  ; brushr[0,0]:=tr; end;
      if(b10)then begin tileX+=2  ; brushr[1,0]:=tr; end;
      if(b20)then begin tileX+=4  ; brushr[2,0]:=tr; end;

      if(b01)then begin tileX+=8  ; brushr[0,1]:=tr; end;
      if(b21)then begin tileX+=16 ; brushr[2,1]:=tr; end;

      if(b02)then begin tileX+=32 ; brushr[0,2]:=tr; end;
      if(b12)then begin tileX+=64 ; brushr[1,2]:=tr; end;
      if(b22)then begin tileX+=128; brushr[2,2]:=tr; end;

      if(edgeStyle<>tes_tech)then
      begin
         if(b10)and(b01)then brushr[0,0]:=tr2;
         if(b10)and(b21)then brushr[2,0]:=tr2;
         if(b12)and(b21)then brushr[2,2]:=tr2;
         if(b12)and(b01)then brushr[0,2]:=tr2;
      end;

      if(tileX=0)then continue;

      for ix:=0 to 2 do
      for iy:=0 to 2 do
      if(brushr[ix,iy]>0)then DrawBrush(ix,iy,brushx[ix],brushy[iy],brushr[ix,iy]);

      with tileSet^[tileX] do
      begin
         gfx_SDLSurfaceFree(sdlSurface);
         sdlSurface:=gfx_SDLSurfaceCreate(tw,tw);
         boxColor(sdlSurface,0,0,tw,tw,templateColor);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(sdlSurface,0,0));
         draw_surf(sdlSurface,0,0,sTemplate);
         w :=tw ;h := w;
         hw:=thw;hh:=hw;
      end;
   end;
   gfx_SDLSurfaceFree(sTemplate);
end;

function gfx_SDLSurfaceResize(baseSurface:pSDL_Surface;neww,newh:integer):pSDL_Surface;
var ts:pSDl_Surface;
begin
   ts:=zoomSurface(baseSurface,neww/baseSurface^.w,newh/baseSurface^.h,0);
   if(ts=nil)then
   begin
      WriteSDLError;
      HALT;
   end;
   gfx_SDLSurfaceResize:=sdl_displayformat(ts);
   if(gfx_SDLSurfaceResize=nil)then
   begin
      WriteSDLError;
      HALT;
   end;
   SDL_FreeSurface(ts);
end;

function gfx_MakeBaseTile(baseSurface:pSDL_Surface;sw:integer;yPress:boolean;animStepX,animStepY:integer):pSDL_Surface;
var  ts:pSDl_Surface;
nsw,nsh:integer;
begin
   nsw:=0;
   while(nsw<sw)do nsw+=baseSurface^.w;

   nsh:=0;
   while(nsh<sw)do nsh+=baseSurface^.h;

   if(yPress)then nsh+=baseSurface^.h;

   ts:=gfx_SDLSurfaceCreate(nsw,nsh);

   gfx_FillSurfaceBySurface(ts,baseSurface,animStepX,animStepY);

   gfx_MakeBaseTile:=zoomSurface(ts,sw/ts^.w,sw/ts^.h,0);

   gfx_SDLSurfaceFree(ts);
end;

procedure gfx_MakeThemeTiles();
var
anim_seed:cardinal;
animRX,
animRY,
i,
animStepX,
animStepY: integer;
maskColor: cardinal;
upd_tiles : boolean;
function Compare(cur_id,last_id:pinteger):byte;
begin
   Compare:=0;
   if(0<=cur_id^)and(cur_id^<theme_all_terrain_n)then
     if(cur_id^=last_id^)
     then Compare:=1
     else
     begin
        Compare:=2;
        last_id^:=cur_id^;
     end;
end;
function DefaultTile(cur_id,last_id:pinteger;TargetTile:ppSDL_Surface):boolean;
begin
   DefaultTile:=false;
   if(cur_id^<>last_id^)then
   begin
      gfx_SDLSurfaceFree(TargetTile^);
      if(cur_id^<0)or(theme_all_terrain_n<=cur_id^)
      then TargetTile^:=r_empty
      else DefaultTile:=true;
      last_id^:=cur_id^;
   end;
end;
begin
   anim_seed:=map_seed mod 6;
   case(anim_seed div 3)of
  0: animRX:=-theme_anim_tile_step;
  1: animRX:= theme_anim_tile_step;
   end;
   case(anim_seed mod 3)of
  0: animRY:=-theme_anim_tile_step;
  1: animRY:= 0;
  2: animRY:= theme_anim_tile_step;
   end;
   animStepX:=0;
   animStepY:=0;

   writeln('--------------------');

   // base terrain tile
   if(DefaultTile(@theme_cur_tile_terrain_id ,@theme_last_tile_terrain_id ,@theme_tile_terrain ))then
   begin
      theme_tile_terrain :=gfx_MakeBaseTile(theme_all_terrain_l[theme_cur_tile_terrain_id ].sdlSurface,MapCellW,true,animStepX,animStepy);
      writeln('update 1 theme_tile_terrain');
   end;

   // crater tileset
   upd_tiles:=false;
   if(DefaultTile(@theme_cur_tile_crater_id  ,@theme_last_tile_crater_id  ,@theme_tile_crater  ))then
   begin
      theme_tile_crater:=gfx_MakeBaseTile(theme_all_terrain_l[theme_cur_tile_crater_id  ].sdlSurface,MapCellW,true,animStepX,animStepy);
      boxColor(theme_tile_crater,0,0,theme_tile_crater^.w,theme_tile_crater^.h,rgba2c(0,0,0,150));
      upd_tiles:=true;
      writeln('update 2 theme_tile_crater');
   end;
   if(upd_tiles)
   or(theme_cur_crater_tes<>theme_last_crater_tes)then
   begin
      if(theme_cur_crater_tes=tes_tech)
      then gfx_MakeTileSet(theme_tile_crater,@theme_tileset_crater,@vid_TileTemplate_crater_tech  ,animStepX,animStepY,0,0)
      else gfx_MakeTileSet(theme_tile_crater,@theme_tileset_crater,@vid_TileTemplate_crater_nature,animStepX,animStepY,0,0);
      theme_last_crater_tes:=theme_cur_crater_tes;
      writeln('update 3 theme_tileset_crater');
   end;

   // liquid tileset
   upd_tiles:=false;
   if(DefaultTile(@theme_cur_tile_liquid_id  ,@theme_last_tile_liquid_id  ,@theme_tile_liquid  ))then
   begin
      theme_tile_liquid:=gfx_MakeBaseTile(theme_all_terrain_l[theme_cur_tile_liquid_id].sdlSurface,MapCellW,true,animStepX,animStepy);
      upd_tiles:=true;
      writeln('update 4 theme_tile_liquid');
   end;
   if(upd_tiles)
   or(theme_cur_liquid_tes<>theme_last_liquid_tes)
   or(theme_cur_liquid_tas<>theme_last_liquid_tas)then
   begin
      writeln('update 5 theme_tileset_liquid');
      for i:=0 to theme_anim_step_n-1 do
      begin
         maskColor:=0;
         if(theme_cur_liquid_tas=tas_magma)and(i>0)then
           maskColor:=rgba2c(0,0,0,30*i);

         if(theme_cur_liquid_tes=tes_nature)then
         begin
            if(theme_cur_liquid_tas=tas_magma)
            then gfx_MakeTileSet(theme_tile_liquid,@theme_tileset_liquid[i],@vid_TileTemplate_liquid[0],animStepX,animStepY,maskColor,0)
            else gfx_MakeTileSet(theme_tile_liquid,@theme_tileset_liquid[i],@vid_TileTemplate_liquid[i],animStepX,animStepY,maskColor,0);
         end
         else
           with theme_tileset_liquid[i][0] do
           begin
              gfx_SDLSurfaceFree(sdlSurface);
              sdlSurface:=gfx_SDLSurfaceCreate(MapCellW,MapCellW);
              gfx_FillSurfaceBySurface(sdlSurface,theme_tile_liquid,animStepX,animStepY);
              if(maskColor>0)then boxColor(sdlSurface,0,0,MapCellW,MapCellW,maskColor);
               w:=MapCellW ;h := w;
              hw:=MapCellhW;hh:=hw;
           end;
         if(theme_cur_liquid_tas=tas_liquid)then
         begin
            animStepX+=animRX;
            animStepY+=animRY;
         end;
         if(theme_cur_liquid_tas=tas_ice)then break;
      end;
      theme_last_liquid_tes:=theme_cur_liquid_tes;
      theme_last_liquid_tas:=theme_cur_liquid_tas;
   end;

   // teleport sprite
   if(DefaultTile(@theme_cur_tile_teleport_id,@theme_last_tile_teleport_id,@theme_tile_teleport))then
   begin
      theme_tile_teleport:=gfx_SDLSurfaceResize(theme_all_terrain_l[theme_cur_tile_teleport_id].sdlSurface,MapCellhW,MapCellhW);
      writeln('update 6 theme_tile_teleport');
   end;
end;

function gfx_LoadUIButton(fn:shortstring;bw:integer):pSDL_Surface;
var ts:pSDl_Surface;
   hwb:integer;
begin
   hwb:=bw div 2;
   ts:=gfx_SDLSurfaceLoad(fn,false,true);
   gfx_LoadUIButton:=gfx_SDLSurfaceCreate(bw-1,bw-1);
   if(ts^.h>bw)
   then draw_surf(gfx_LoadUIButton,hwb-(ts^.w div 2),0                ,ts)
   else draw_surf(gfx_LoadUIButton,hwb-(ts^.w div 2),hwb-(ts^.h div 2),ts);
   gfx_SDLSurfaceFree(ts);
end;

function gfx_MakeUIButtonFromSDLSurface(ts:pSDl_Surface;bw:integer):pSDL_Surface;
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
   gfx_MakeUIButtonFromSDLSurface:=gfx_SDLSurfaceCreate(bw-1,bw-1);
   if(tst^.h>bw)
   then draw_surf(gfx_MakeUIButtonFromSDLSurface,hwb-(tst^.w div 2),2,tst)
   else draw_surf(gfx_MakeUIButtonFromSDLSurface,hwb-(tst^.w div 2),hwb-(tst^.h div 2),tst);
   rectangleColor(gfx_MakeUIButtonFromSDLSurface,0,0,gfx_MakeUIButtonFromSDLSurface^.w-1,gfx_MakeUIButtonFromSDLSurface^.h-1,c_black);
   rectangleColor(gfx_MakeUIButtonFromSDLSurface,1,1,gfx_MakeUIButtonFromSDLSurface^.w-2,gfx_MakeUIButtonFromSDLSurface^.h-2,c_black);
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
      r_RECT^.x:=ord(i)*basefont_w1;
      r_RECT^.y:=0;
      r_RECT^.w:=basefont_w1;
      r_RECT^.h:=basefont_w1;
      c:=chr(i);
      with font_1 [c] do
      begin
         sdlSurface:=gfx_SDLSurfaceCreate(basefont_w1,basefont_w1);
         SDL_FillRect(sdlSurface,nil,0);
         SDL_BLITSURFACE(fspr,r_RECT,sdlSurface,nil);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
         w :=sdlSurface^.w;h :=w;hw:=w div 2;hh:=hw;
      end;
      with font_1h[c] do
      begin
         sdlSurface:=gfx_SDLSurfaceResize(font_1[c].sdlSurface,basefont_w1h,basefont_w1h);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
         w :=sdlSurface^.w;h :=w;hw:=w div 2;hh:=hw;
      end;
      with font_2 [c] do
      begin
         sdlSurface:=gfx_SDLSurfaceResize(font_1[c].sdlSurface,basefont_w1*2,basefont_w1*2);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
         w :=sdlSurface^.w;h :=w;hw:=w div 2;hh:=hw;
      end;
      with font_3 [c] do
      begin
         sdlSurface:=gfx_SDLSurfaceResize(font_1[c].sdlSurface,basefont_w1*3,basefont_w1*3);
         SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
         w :=sdlSurface^.w;h :=w;hw:=w div 2;hh:=hw;
      end;
   end;
   gfx_SDLSurfaceFree(fspr);
end;

{$include _themes.pas}


procedure gfx_LoadGraphics(firstload:boolean);
var x,r:integer;
begin
   // basic surfaces
   r_empty   :=gfx_SDLSurfaceCreate(1,1);
   SDL_SetColorKey(r_empty,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(r_empty,0,0));

   r_minimap :=gfx_SDLSurfaceCreate(vid_panelwi,vid_panelwi);
   r_bminimap:=gfx_SDLSurfaceCreate(vid_panelwi,vid_panelwi);

   vid_UIItem_n :=0;
   setlength(vid_UIItem_list,vid_UIItem_n);

   with spr_dummy do
   begin
      h :=1;
      w :=1;
      hh:=1;
      hw:=1;
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

   DrawLoadingScreen(str_loading_srf,c_orange);

   // theme tileset templates
   gfx_MakeTileSetTemplate(c_white,c_black,MapCellW ,@vid_TileTemplate_crater_tech  ,tes_tech  ,8 ,0);
   gfx_MakeTileSetTemplate(c_white,c_black,MapCellW ,@vid_TileTemplate_crater_nature,tes_nature,11,0);
   for x:=0 to theme_anim_step_n-1 do
   gfx_MakeTileSetTemplate(c_white,c_black,MapCellW ,@vid_TileTemplate_liquid[x]    ,tes_nature,0 ,byte(x*5));

   // FOG tiles
   new(vid_TileTemplate_fog);
   FillChar(vid_TileTemplate_fog^,SizeOf(vid_TileTemplate_fog^),0);
   gfx_MakeTileSetTemplate(c_white,c_black,fog_CellW,vid_TileTemplate_fog,tes_fog,0,0);
   vid_fog_BaseSurf:=gfx_SDLSurfaceCreate(fog_CellW,fog_CellW);
   boxColor(vid_fog_BaseSurf,0,0,fog_CellW,fog_CellW,c_white);
   for x:=0 to fog_CellW-1 do
   for r:=0 to fog_CellW-1 do
     if((x+r)mod 4)>0 then
       pixelColor(vid_fog_BaseSurf,x,r,c_black);
   gfx_MakeTileSet(vid_fog_BaseSurf,@vid_fog_tiles,vid_TileTemplate_fog,0,0,0,c_white);
   for x:=0 to MaxTileSet do gfx_SDLSurfaceFree(vid_TileTemplate_fog^[x].sdlSurface);
   dispose(vid_TileTemplate_fog);

   // load game resouces
   DrawLoadingScreen(str_loading_gfx,c_yellow);
   spr_mlogo :=gfx_SDLSurfaceLoad('logo' ,false,firstload);
   spr_mback :=gfx_SDLSurfaceLoad('mback',false,firstload);
   spr_mback2:=gfx_SDLSurfaceResize(spr_mback,vid_vw,vid_vh);

   r_menu:=gfx_SDLSurfaceCreate(vid_vw,vid_vh);

   spr_b_action   := gfx_LoadUIButton('b_action' ,vid_bw);
   spr_b_paction  := gfx_LoadUIButton('b_paction',vid_bw);
   spr_b_delete   := gfx_LoadUIButton('b_destroy',vid_bw);
   spr_b_attack   := gfx_LoadUIButton('b_attack' ,vid_bw);
   spr_b_rebuild  := gfx_LoadUIButton('b_rebuild',vid_bw);
   spr_b_move     := gfx_LoadUIButton('b_move'   ,vid_bw);
   spr_b_patrol   := gfx_LoadUIButton('b_patrol' ,vid_bw);
   spr_b_apatrol  := gfx_LoadUIButton('b_apatrol',vid_bw);
   spr_b_stop     := gfx_LoadUIButton('b_stop'   ,vid_bw);
   spr_b_hold     := gfx_LoadUIButton('b_hold'   ,vid_bw);
   spr_b_selall   := gfx_LoadUIButton('b_selall' ,vid_bw);
   spr_b_cancel   := gfx_LoadUIButton('b_cancle' ,vid_bw);
   spr_b_rfast    := gfx_LoadUIButton('b_rfast'  ,vid_bw);
   spr_b_rskip    := gfx_LoadUIButton('b_rskip'  ,vid_bw);
   spr_b_rback    := gfx_LoadUIButton('b_rback'  ,vid_bw);
   spr_b_rfog     := gfx_LoadUIButton('b_fog'    ,vid_bw);
   spr_b_rlog     := gfx_LoadUIButton('b_log'    ,vid_bw);
   spr_b_rstop    := gfx_LoadUIButton('b_rstop'  ,vid_bw);
   spr_b_rvis     := gfx_LoadUIButton('b_rvis'   ,vid_bw);
   spr_b_rclck    := gfx_LoadUIButton('b_rclick' ,vid_bw);
   spr_b_mmark    := gfx_LoadUIButton('b_mmark'  ,vid_bw);

   for x:=0 to 3 do spr_tabs[x]:=gfx_LoadUIButton('tabs'+b2s(x),vid_tbw);

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

   gfx_MWSModelLoad(@spr_HKeep          ,race_buildings[r_hell]+'h_b0_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HAKeep         ,race_buildings[r_hell]+'h_b0a_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HGate          ,race_buildings[r_hell]+'h_b1_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HAGate         ,race_buildings[r_hell]+'h_b1a'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HSymbol        ,race_buildings[r_hell]+'h_b2_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HASymbol       ,race_buildings[r_hell]+'h_b2a_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HPools         ,race_buildings[r_hell]+'h_b3_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HAPools        ,race_buildings[r_hell]+'h_b3a'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HTower         ,race_buildings[r_hell]+'h_b4_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HTeleport      ,race_buildings[r_hell]+'h_b5_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HMonastery     ,race_buildings[r_hell]+'h_b6_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HTotem         ,race_buildings[r_hell]+'h_b7_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HAltar         ,race_buildings[r_hell]+'h_b8_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HFortress      ,race_buildings[r_hell]+'h_b9_'  ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HPentagram     ,race_buildings[r_hell]+'h_b10_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HCommandCenter ,race_buildings[r_hell]+'h_hcc_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HACommandCenter,race_buildings[r_hell]+'h_hcca_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HBarracks      ,race_buildings[r_hell]+'h_hbar_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HABarracks     ,race_buildings[r_hell]+'h_hbara',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_HEye           ,race_buildings[r_hell]+'heye_'  ,smt_buiding  ,firstload);

   gfx_MWSModelLoad(@spr_UCommandCenter ,race_buildings[r_uac ] +'u_b0_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UACommandCenter,race_buildings[r_uac ] +'u_b0a_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UBarracks      ,race_buildings[r_uac ] +'u_b1_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UABarracks     ,race_buildings[r_uac ] +'u_b1a' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UGenerator     ,race_buildings[r_uac ] +'u_b2_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UAGenerator    ,race_buildings[r_uac ] +'u_b2a_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UWeaponFactory ,race_buildings[r_uac ] +'u_b3_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UAWeaponFactory,race_buildings[r_uac ] +'u_b3a' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UTurret        ,race_buildings[r_uac ] +'u_b4_' ,smt_turret   ,firstload);
   gfx_MWSModelLoad(@spr_URadar         ,race_buildings[r_uac ] +'u_b5_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UVehicleFactory,race_buildings[r_uac ] +'u_b6_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UTechCenter    ,race_buildings[r_uac ] +'u_b13_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UPTurret       ,race_buildings[r_uac ] +'u_b7_' ,smt_turret   ,firstload);
   gfx_MWSModelLoad(@spr_URocketL       ,race_buildings[r_uac ] +'u_b8_' ,smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_URTurret       ,race_buildings[r_uac ] +'u_b9_' ,smt_turret2  ,firstload);
   gfx_MWSModelLoad(@spr_UNuclearPlant  ,race_buildings[r_uac ] +'u_b10_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UAFactory      ,race_buildings[r_uac ] +'u_b11_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_UFactory       ,race_buildings[r_uac ] +'u_b12_',smt_buiding  ,firstload);
   gfx_MWSModelLoad(@spr_Mine           ,race_buildings[r_uac ] +'u_mine',smt_buiding  ,firstload);

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

   gfx_MWSModelLoad(@spr_eff_bfg        ,effects_folder+'ef_bfg_'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_eb         ,effects_folder+'ef_eb'          ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_ebb        ,effects_folder+'ef_ebb'         ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_gtel       ,effects_folder+'ef_gt_'         ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_tel        ,effects_folder+'ef_tel_'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_exp        ,effects_folder+'ef_exp_'        ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_exp2       ,effects_folder+'exp2_'          ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_eff_g          ,effects_folder+'g_'             ,smt_effect ,firstload);
   gfx_MWSModelLoad(@spr_blood          ,effects_folder+'blood'          ,smt_effect ,firstload);

   gfx_MWTextureLoad(@spr_mp[r_hell]    ,race_dir[r_hell]+'h_mp'        ,firstload,true);
   gfx_MWTextureLoad(@spr_mp[r_uac ]    ,race_dir[r_uac ]+'u_mp'        ,firstload,true);
   gfx_MWTextureLoad(@spr_ptur          ,race_dir[r_uac ]+'ptur'        ,firstload,true);

   gfx_MWTextureLoad(@spr_b4_a          ,race_buildings[r_uac ]+'u_b4_a',firstload,true);
   gfx_MWTextureLoad(@spr_b7_a          ,race_buildings[r_uac ]+'u_b7_a',firstload,true);
   gfx_MWTextureLoad(@spr_b9_a          ,race_buildings[r_uac ]+'u_b9_a',firstload,true);

   gfx_MWTextureLoad(@spr_stun          ,effects_folder+'stun'          ,firstload,true);
   gfx_MWTextureLoad(@spr_invuln        ,effects_folder+'invuln'        ,firstload,true);
   gfx_MWTextureLoad(@spr_hvision       ,effects_folder+'hvision'       ,firstload,true);
   gfx_MWTextureLoad(@spr_scan          ,effects_folder+'scan'          ,firstload,true);
   gfx_MWTextureLoad(@spr_decay         ,effects_folder+'decay'         ,firstload,true);

   gfx_MWTextureLoad(@spr_cp_koth       ,'cp_koth'                      ,firstload,true);
   gfx_MWTextureLoad(@spr_cp_out        ,'cp_out'                       ,firstload,true);
   gfx_MWTextureLoad(@spr_cp_gen        ,'cp_gen'                       ,firstload,true);

   for x:=0 to spr_upgrade_icons do
    for r:=1 to r_cnt do
     with spr_b_up[r,x] do
     begin
        sdlSurface:= gfx_LoadUIButton(race_upgrades[r]+'b_up'+b2s(x),vid_bw);
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
         r_hell: sdlSurface:= gfx_MakeUIButtonFromSDLSurface(sm_uid2MWTexture(u,315,0)^.sdlSurface,vid_BW );
         r_uac : sdlSurface:= gfx_MakeUIButtonFromSDLSurface(sm_uid2MWTexture(u,225,0)^.sdlSurface,vid_BW );
         end;
         w   := sdlSurface^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      with un_sbtn do
      begin
         case _urace of
         r_hell: sdlSurface:= gfx_MakeUIButtonFromSDLSurface(sm_uid2MWTexture(u,315,0)^.sdlSurface,vid_oiw );
         r_uac : sdlSurface:= gfx_MakeUIButtonFromSDLSurface(sm_uid2MWTexture(u,225,0)^.sdlSurface,vid_oiw );
         end;
         w   := sdlSurface^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
   end;
end;

procedure vid_CommonVars;
begin
   vid_vmb_x1   := vid_vw-vid_vmb_x0;
   vid_vmb_y1   := vid_vh-vid_vmb_y0;

   ui_textx     := vid_mapx+basefont_wh;
   ui_texty     := vid_mapy+basefont_wh;
   ui_hinty1    := vid_mapy+vid_cam_h-draw_font_h1*10;
   ui_hinty2    := vid_mapy+vid_cam_h-draw_font_h1*8;
   ui_hinty3    := vid_mapy+vid_cam_h-draw_font_h1*5;
   ui_hinty4    := vid_mapy+vid_cam_h-draw_font_h1*2;
   ui_chaty     := ui_hinty1-basefont_w1h;
   ui_logy      := ui_chaty-basefont_w1h;
   ui_oicox     := vid_mapx+vid_cam_w-basefont_wh;
   ui_uiuphx    := vid_mapx+(vid_cam_w div 2);
   ui_uiuphy    := ui_texty+basefont_w3;
   ui_uiplayery := ui_uiuphy+basefont_w1h;
   ui_GameLogHeight:=(ui_hinty1-basefont_w5) div basefont_w1h;

   ui_energx    := ui_uiuphx-150;
   ui_energy    := ui_texty;
   ui_armyx     := ui_uiuphx+40;
   ui_armyy     := ui_texty;
   ui_fpsx      := vid_mapx+vid_cam_w-(basefont_w1*basefont_w1h);
   ui_fpsy      := ui_texty;
   ui_apmx      := ui_fpsx;
   ui_apmy      := ui_fpsy+draw_font_h2;

   ui_ingamecl  :=(vid_cam_w-basefont_w1) div basefont_w1;
   if(spr_mback<>nil)then
   begin
      if(spr_mback2<>nil)then gfx_SDLSurfaceFree(spr_mback2);
      spr_mback2:=gfx_SDLSurfaceResize(spr_mback,vid_vw,vid_vh);
   end;
   if(r_menu<>nil)then gfx_SDLSurfaceFree(r_menu);
   r_menu:=gfx_SDLSurfaceCreate(vid_vw,vid_vh);

   vid_fog_vfw  :=(vid_cam_w div fog_CellW)+1;
   vid_fog_vfh  :=(vid_cam_h div fog_CellW)+1;

   vid_map_vfw  :=(vid_cam_w div MapCellW)+1;
   vid_map_vfh  :=(vid_cam_h div MapCellW)+1;

   map_mm_CamW  := round(vid_cam_w*map_mm_cx);
   map_mm_CamH  := round(vid_cam_h*map_mm_cx);
   GameCameraBounds;
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

   vid_vhw:=vid_vw div 2;
   vid_vhh:=vid_vh div 2;

   if(vid_fullscreen)
   then r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, r_vflags + SDL_FULLSCREEN)
   else r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, r_vflags);

   if(r_screen=nil)then begin WriteSDLError; exit; end;

   vid_ScreenSurfaces;
end;


