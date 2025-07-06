
const
vid_BitsPerPixel        = 32;

procedure InitRX2Y;
var r,x:integer;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _RX2Y[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
end;

procedure WindowToggleFullscreen;
const sdl_windows_flags_f : array[false..true] of cardinal = (0, SDL_WINDOW_FULLSCREEN);
begin
   SDL_SetWindowFullscreen(vid_SDLWindow,sdl_windows_flags_f[vid_fullscreen]);
end;

procedure MakeScreenShot;
var      s: shortstring;
tmpSDLSurf: pSDL_Surface;
begin
   s:=str_screenshot+str_NowDateTime+str_screenshotExt+#0;

   tmpSDLSurf := SDL_CreateRGBSurface(0, vid_vw, vid_vh, vid_BitsPerPixel, 0,0,0,0);
   if(tmpSDLSurf=nil)then
   begin
      writeSDLError('MakeScreenShot -> SDL_CreateRGBSurface');
      exit;
   end;

   SDL_RenderReadPixels(vid_SDLRenderer, nil, tmpSDLSurf^.format^.format, tmpSDLSurf^.pixels, tmpSDLSurf^.pitch);
   IMG_SavePNG(tmpSDLSurf,@s[1]);
   SDL_FreeSurface(tmpSDLSurf);
end;


procedure gfx_InitColors;
begin
   c_none   :=0;
   c_dred   :=gfx_MakeTMWColor(190,  0,  0);
   c_red    :=gfx_MakeTMWColor(255,  0,  0);
   c_orange :=gfx_MakeTMWColor(255,140,  0);
   c_dorange:=gfx_MakeTMWColor(230, 96,  0);
   c_brown  :=gfx_MakeTMWColor(140, 90, 10);
   c_yellow :=gfx_MakeTMWColor(255,255,  0);
   c_dyellow:=gfx_MakeTMWColor(220,220,  0);
   c_lime   :=gfx_MakeTMWColor(0  ,255,  0);
   c_aqua   :=gfx_MakeTMWColor(0  ,255,255);
   c_purple :=gfx_MakeTMWColor(255,0  ,255);
   c_lpurple:=gfx_MakeTMWColor(160,113,255);
   c_dpurple:=gfx_MakeTMWColor(128,0  ,255);
   c_green  :=gfx_MakeTMWColor(0  ,150,0  );
   c_dblue  :=gfx_MakeTMWColor(100,100,192);
   c_blue   :=gfx_MakeTMWColor(50 ,50 ,255);
   c_white  :=gfx_MakeTMWColor(255,255,255);
   c_gray   :=gfx_MakeTMWColor(120,120,120);
   c_ltgray :=gfx_MakeTMWColor(200,200,200);
   c_dgray  :=gfx_MakeTMWColor(70 ,70 ,70 );
   c_black  :=gfx_MakeTMWColor(0  ,0  ,0  );
   c_lava   :=gfx_MakeTMWColor(222,80 ,0  );

   ui_color_max    [false]:=c_dorange;
   ui_color_max    [true ]:=c_ltgray;
   ui_color_cenergy[false]:=c_white;
   ui_color_cenergy[true ]:=c_red;
   ui_color_limit  [false]:=c_white;
   ui_color_limit  [true ]:=c_red;

   ui_color_blink2 [false]:=c_black;
   ui_color_blink2 [true ]:=c_yellow;

   ui_color_blink1 [false]:=c_black;
   ui_color_blink1 [true ]:=c_gray;

   draw_set_color(c_white);
   draw_set_alpha(255);
end;

function gfx_SDLSurfaceCreate(tw,th:integer):pSDL_Surface;
begin
   gfx_SDLSurfaceCreate:=sdl_createRGBSurface(0,tw,th,vid_BitsPerPixel,0,0,0,0);
   if(gfx_SDLSurfaceCreate=nil)then
   begin
      WriteSDLError('gfx_SDLSurfaceCreate');
      HALT;
   end;
end;

procedure gfx_SDLSurfaceFree(sf:PSDL_Surface);
begin
   if(sf<>nil)then sdl_FreeSurface(sf);
end;

{
procedure SDL_SETpixel(srf:PSDL_SURFACE;x,y:integer;color:cardinal);
var bpp:byte;
begin
   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;

   move( (@(color))^, (srf^.pixels+(y*srf^.pitch)+x*bpp)^, bpp);
end;}

function SDL_SurfaceGetPixel(srf:pSDL_SURFACE;x,y:integer):TMWColor;
begin
   SDL_SurfaceGetPixel:=0;

   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   move( (srf^.pixels+(y*srf^.pitch)+x*srf^.format^.BytesPerPixel)^, SDL_SurfaceGetPixel, srf^.format^.BytesPerPixel);
end;

{function cardinalBytes(c:cardinal):shortstring;
begin
   cardinalBytes:=b2s((c and $FF000000)shr 24)+','+b2s((c and $00FF0000)shr 16)+','+b2s((c and $0000FF00)shr 8)+','+b2s(c and $000000FF);
end; }

{function gfx_SDLTextureGetColor(sdltexture:pSDL_Texture):TMWColor;
var
rC,gC,bC,
rR,gR,bR,
rM,gM,bM:byte;
color   :cardinal;
x,y     :integer;
begin
   //SDL_QueryTexture(sdltexture,,);
   {or x:=0 to surface^.w-1 do
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
   gfx_SDLSurfaceGetColor,rR,gR,bR,255);}
end; }

////////////////////////////////////////////////////////////////////////////////
//
//     TMWTexture Basics
//

function gfx_MWTextureLoadSDLSurfaceFromFile(fn:shortstring):pSDL_Surface;
begin
   gfx_MWTextureLoadSDLSurfaceFromFile:=nil;
   if(not FileExists(fn))then exit;
   if(length(fn)=255)then exit;

   fn:=fn+#0;

   gfx_MWTextureLoadSDLSurfaceFromFile:=IMG_Load(@fn[1]);
   if(gfx_MWTextureLoadSDLSurfaceFromFile=nil)then writeSDLError('gfx_MWTextureLoadSDLSurfaceFromFile');
end;

function gfx_MWTextureMakeRenderTarget(tw,th:integer):pTMWTexture;
begin
   new(gfx_MWTextureMakeRenderTarget);
   with gfx_MWTextureMakeRenderTarget^ do
   begin
      sdlsurface:=nil;
      sdltexture:=SDL_CreateTexture(vid_SDLRenderer,SDL_PIXELFORMAT_RGBA8888,SDL_TEXTUREACCESS_TARGET,tw,th);
      if(sdltexture=nil)then writeSDLError('gfx_MWTextureMakeRenderTarget');

      w :=tw;
      h :=th;
      hw:=tw div 2;
      hh:=th div 2;
   end;
end;

function gfx_MWTextureMakeSDLSurface(tw,th:integer):pTMWTexture;
begin
   new(gfx_MWTextureMakeSDLSurface);
   with gfx_MWTextureMakeSDLSurface^ do
   begin
      sdlsurface:=gfx_SDLSurfaceCreate(tw,tw);
      sdltexture:=nil;

      w :=tw;
      h :=th;
      hw:=tw div 2;
      hh:=th div 2;
   end;
end;

procedure gfx_MWTextureInit(pMWT:PTMWTexture);
begin
   if(pMWT<>nil)and(pMWT<>ptex_dummy)then
     with pMWT^ do
     begin
        sdlsurface:=nil;
        sdltexture:=nil;
        w :=1;
        h :=1;
        hw:=0;
        hh:=0;
     end;
end;
procedure gfx_MWTextureFree(pMWT:PTMWTexture);
begin
   if(pMWT<>nil)and(pMWT<>ptex_dummy)then
   begin
      with pMWT^ do
      begin
         if(sdlsurface<>nil)then sdl_FreeSurface(sdlsurface);
         if(sdltexture<>nil)then sdl_DestroyTexture(sdltexture);
         sdlsurface:=nil;
         sdltexture:=nil;
      end;
      dispose(pMWT);
   end;
end;

function gfx_MWTextureLoad(fn:shortstring;transparent00:boolean;
                                          log          :boolean=true;
                                          letsdlsurface:boolean=false):PTMWTexture;
const fextn = 2;
      fexts : array[0..fextn] of shortstring = ('.png','.jpg','.bmp');
var      i:integer;
tsdlsurface:pSDL_Surface;
tsdltexture:pSDL_Texture;
begin
   gfx_MWTextureLoad:=ptex_dummy;

   tsdlsurface:=nil;
   tsdltexture:=nil;
   for i:=0 to fextn do
   begin
      tsdlsurface:=gfx_MWTextureLoadSDLSurfaceFromFile(str_f_grp+fn+fexts[i]);
      if(tsdlsurface<>nil)then
      begin
         if(transparent00)then SDL_SetColorKey(tsdlsurface,1,SDL_SurfaceGetPixel(tsdlsurface,0,0));
         tsdltexture:=SDL_CreateTextureFromSurface(vid_SDLRenderer,tsdlsurface);
         if(transparent00)
         then SDL_SetTextureBlendMode(tsdltexture,SDL_BLENDMODE_BLEND)
         else SDL_SetTextureBlendMode(tsdltexture,SDL_BLENDMODE_NONE );
         if(tsdltexture=nil)
         then sdl_FreeSurface(tsdlsurface)
         else break;
      end;
   end;

    if(tsdltexture=nil)then
    begin
       if(log)then WriteLog('gfx_MWTextureLoad: '+str_f_grp+fn);
    end
    else
    begin
       new(gfx_MWTextureLoad);
       with gfx_MWTextureLoad^ do
       begin
          w :=tsdlsurface^.w;
          h :=tsdlsurface^.h;
          hw:=tsdlsurface^.w div 2;
          hh:=tsdlsurface^.h div 2;
          if(not letsdlsurface)then
          begin
             sdl_FreeSurface(tsdlsurface);
             tsdlsurface:=nil;
          end;
          sdlsurface:=tsdlsurface;
          sdltexture:=tsdltexture;
       end;
    end;
end;

function gfx_MWSModelLoad(name:shortstring;asmtype:TMWSModelType;log:boolean=false):PTMWSModel;
var tmwtex:pTMWTexture;
procedure calcSelectionRect(ip:pinteger;vl:integer);
begin
   if(ip^=0)
   then ip^:=vl
   else ip^:=(ip^+vl) div 2;
end;
begin
   new(gfx_MWSModelLoad);
   with gfx_MWSModelLoad^ do
   begin
      sm_sel_hw:=0;
      sm_sel_hh:=0;
      sm_listn :=0;
      setlength(sm_list,sm_listn);

      //tmwtex
      tmwtex:=gfx_MWTextureLoad(name,true,false);
      if(tmwtex<>ptex_dummy)then
      begin
         sm_listn+=1;
         setlength(sm_list,sm_listn);
         sm_list[sm_listn-1]:=ptex_dummy;
         calcSelectionRect(@sm_sel_hw,tmwtex^.hw);
         calcSelectionRect(@sm_sel_hh,tmwtex^.hh);
      end;

      while true do
      begin
         tmwtex:=gfx_MWTextureLoad(name+i2s(sm_listn),true,log);
         if(tmwtex=ptex_dummy)then break;

         sm_listn+=1;
         setlength(sm_list,sm_listn);
         sm_list[sm_listn-1]:=tmwtex;
         calcSelectionRect(@sm_sel_hw,tmwtex^.hw);
         calcSelectionRect(@sm_sel_hh,tmwtex^.hh);
      end;
      sm_listi:=sm_listn-1;
      sm_type :=asmtype;

      if(sm_listn=0)then WriteLog('gfx_MWSModelLoad: '+name);
   end;
end;

function gfx_MWTextureLoadUIButtonFromFile(fn:shortstring):pTMWTexture;
var
tmpMWTexture: pTMWTexture;
begin
   new(gfx_MWTextureLoadUIButtonFromFile);
   with gfx_MWTextureLoadUIButtonFromFile^ do
   begin
      sdlsurface:=gfx_SDLSurfaceCreate(ui_pButtonWi,ui_pButtonWi);
      sdltexture:=nil;
      w :=ui_pButtonWi ;h :=w;
      hw:=ui_pButtonWih;hh:=hw;
   end;

   tmpMWTexture:=gfx_MWTextureLoad(fn,true,true,true);
   with tmpMWTexture^ do
   begin
      if(sdlsurface= nil)then sdlsurface:=gfx_SDLSurfaceCreate(ui_pButtonWi,ui_pButtonWi);
      if(sdltexture<>nil)then sdl_DestroyTexture(sdltexture);

      if(sdlsurface^.h>ui_pButtonWi)
      then draw_sdlsurface(gfx_MWTextureLoadUIButtonFromFile^.sdlsurface,ui_pButtonWih-(sdlsurface^.w div 2),0                                  ,sdlsurface)
      else draw_sdlsurface(gfx_MWTextureLoadUIButtonFromFile^.sdlsurface,ui_pButtonWih-(sdlsurface^.w div 2),ui_pButtonWih-(sdlsurface^.h div 2),sdlsurface);
      gfx_SDLSurfaceFree(sdlsurface);
      sdlsurface:=nil;
   end;
   gfx_MWTextureFree(tmpMWTexture);

   with gfx_MWTextureLoadUIButtonFromFile^ do
   begin
      sdltexture:=SDL_CreateTextureFromSurface(vid_SDLRenderer,sdlsurface);
      SDL_SetTextureBlendMode(sdltexture,SDL_BLENDMODE_NONE );
   end;
end;

procedure gfx_FillSurfaceBySurface(sTar,sTile:pSDL_Surface;animStepX,animStepY:integer);
var tx,ty:integer;
begin
   if(sTar =nil)
   or(sTile=nil)then exit;
   animStepX:=-abs(animStepX mod sTile^.w);
   animStepY:=-abs(animStepY mod sTile^.h);
   tx:=animStepX;
   while tx<sTar^.w do
   begin
      ty:=animStepy;
      while ty<sTar^.h do
      begin
         draw_sdlsurface(sTar,tx,ty,sTile);
         ty+=sTile^.h;
      end;
      tx+=sTile^.w;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  Tile Sets
//

procedure gfx_UpdateSDLTexture(MWTexture:pTMWTexture);
begin
   with MWTexture^ do
   begin
      if(sdltexture<>nil)then
      begin
         SDL_DestroyTexture(sdltexture);
         sdltexture:=nil;
      end;
      sdltexture:=SDL_CreateTextureFromSurface(vid_SDLRenderer,sdlsurface);
      if(sdltexture=nil)then writeLog('gfx_UpdateSDLTexture -> SDL_CreateTextureFromSurface');
   end;
end;

procedure gfx_TileSet_Render(baseSurface:pSDL_Surface;tileSetTarget,tileSetTemplate:pTMWTileSet;animStepX,animStepY:integer;maskColor,transColor:TMWColor);
var
tw,
thw,
tileX      : integer;
b00,b10,b20,
b01,    b21,
b02,b12,b22: boolean;
begin
   tw :=tileSetTemplate^[0]^.w;
   thw:=tileSetTemplate^[0]^.hw;

   // full tiled
   with tileSetTarget^[0]^ do
   begin
      SDLSurf_boxColor(sdlSurface,0,0,tw,tw,transColor);
      SDL_SetColorKey(sdlSurface,1,SDL_SurfaceGetPixel(sdlSurface,0,0));
      gfx_FillSurfaceBySurface(sdlSurface,baseSurface,animStepX,animStepY);
      if(maskColor>0)then SDLSurf_boxColor(sdlSurface,0,0,tw,tw,maskColor);
      gfx_UpdateSDLTexture(tileSetTarget^[0]);
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

      with tileSetTarget^[tileX]^ do
      begin
         gfx_FillSurfaceBySurface(sdlSurface,baseSurface,animStepX,animStepY);
         draw_sdlsurface(sdlSurface,0,0,tileSetTemplate^[tileX]^.sdlSurface);
         if(maskColor>0)then SDLSurf_boxColor(sdlSurface,0,0,tw,tw,maskColor);
         SDL_SetColorKey(sdlSurface,1,SDL_SurfaceGetPixel(sdlSurface,thw,thw));
         gfx_UpdateSDLTexture(tileSetTarget^[tileX]);
         w :=tw ;h := w;
         hw:=thw;hh:=hw;
      end;
   end;
end;

function gfx_TileSet_Make(tw:integer):pTMWTileSet;
var i:integer;
begin
   new(gfx_TileSet_Make);
   for i:=0 to MaxTileSet do gfx_TileSet_Make^[i]:=gfx_MWTextureMakeSDLSurface(tw,tw);
end;
procedure gfx_TileSet_Free(ptmwts:pTMWTileSet);
var i:integer;
begin
   for i:=0 to MaxTileSet do
     gfx_MWTextureFree(ptmwts^[i]);
   dispose(ptmwts);
end;

function gfx_TileSetTemplate_Make(transColor,templateColor:TMWColor;tw:integer;edgeStyle:TThemeEdgeTerrainStyle;rstep:integer;random_i:byte):pTMWTileSet;
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
procedure DrawBrush(ix,iy,bx,by,br:integer);
var
edgeRMax,
edgeR,
tx,ty  : integer;
dirStart,
dir,
dirStep: single;
begin
   case edgeStyle of
tes_fog   : SDLSurf_filledCircleColor(sTemplate,bx,by,br,templateColor);
tes_nature: begin
            SDLSurf_filledcircleColor(sTemplate,bx,by,br,templateColor);
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
                  else SDLSurf_filledcircleColor(sTemplate,tx,ty,edgeR,transColor);
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
                  else SDLSurf_filledcircleColor(sTemplate,tx,ty,edgeR,transColor);
                  random_i+=1;
               end;
            end;
            end;
tes_tech  : SDLSurf_boxColor(sTemplate,bx-br,by-br,bx+br,by+br,templateColor);
   end;
end;
begin
   thw:=tw div 2;
   tr :=round(thw*1.45)+rstep;
   if(edgeStyle<>tes_tech)
   then tr2:=round(thw*2.15 )+rstep
   else tr2:=tr;
   tw0:=  -thw;
   tw1:=   thw;
   tw2:=tw+thw;
   brushx[0]:=tw0;
   brushx[1]:=tw1;
   brushx[2]:=tw2;
   brushy[0]:=tw0;
   brushy[1]:=tw1;
   brushy[2]:=tw2;
   sTemplate:=gfx_SDLSurfaceCreate(tw,tw);

   new(gfx_TileSetTemplate_Make);
   for ix:=0 to MaxTileSet do
   new(gfx_TileSetTemplate_Make^[ix]);

  // full tiled
   with gfx_TileSetTemplate_Make^[0]^ do
   begin
      sdlSurface:=nil;
      sdltexture:=nil;
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
      SDLSurf_boxColor(sTemplate,0,0,tw,tw,transColor);
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

      with gfx_TileSetTemplate_Make^[tileX]^ do
      begin
         sdltexture:=nil;
         sdlSurface:=gfx_SDLSurfaceCreate(tw,tw);
         SDLSurf_boxColor(sdlSurface,0,0,tw,tw,templateColor);
         SDL_SetColorKey(sdlSurface,1,SDL_SurfaceGetPixel(sdlSurface,0,0));
         draw_sdlsurface(sdlSurface,0,0,sTemplate);
         w :=tw ;h := w;
         hw:=thw;hh:=hw;
      end;
   end;
   gfx_SDLSurfaceFree(sTemplate);
end;

procedure gfx_TileSet_MakeFog;
var x,y:integer;
tmp_TileTemplate: pTMWTileSet;
tmp_fog_Texture : pSDL_Surface;
begin
   tmp_TileTemplate:=gfx_TileSetTemplate_Make(c_white,c_black,fog_CellW,tes_fog,0,0);
   // fog 'texture'
   tmp_fog_Texture:=gfx_SDLSurfaceCreate(fog_CellW,fog_CellW);
   SDLSurf_boxColor(tmp_fog_Texture,0,0,fog_CellW,fog_CellW,c_white);
   for x:=0 to fog_CellW-1 do
   for y:=0 to fog_CellW-1 do
     if((x+y)mod 4)>0 then
       SDLSurf_boxColor(tmp_fog_Texture,x,y,x,y,c_black);
   // fog tileset
   gfx_TileSet_Render(tmp_fog_Texture,ui_fog_tileset,tmp_TileTemplate,0,0,0,c_white);
   gfx_TileSet_Free(tmp_TileTemplate);
   gfx_SDLSurfaceFree(tmp_fog_Texture);
end;

procedure gfx_MakeBaseTile(targetTex,baseTex:pTMWTexture;sw:integer;yPress:boolean;animStepX,animStepY:integer);
var
tmpTex :pSDl_Surface;
nsw,nsh:integer;
begin
   nsw:=0;
   while(nsw<sw)do nsw+=baseTex^.w;

   nsh:=0;
   while(nsh<sw)do nsh+=baseTex^.h;

   if(yPress)then nsh+=baseTex^.h;

   tmpTex:=gfx_SDLSurfaceCreate(nsw,nsh);

   gfx_FillSurfaceBySurface(tmpTex,baseTex^.sdlsurface,animStepX,animStepY);
   SDL_UpperBlitScaled(tmpTex,nil,targetTex^.sdlsurface,nil);

   gfx_SDLSurfaceFree(tmpTex);

   with targetTex^ do
   begin
      if(sdltexture<>nil)then sdl_DestroyTexture(sdltexture);
      sdltexture:=SDL_CreateTextureFromSurface(vid_SDLRenderer,sdlsurface);
      if(sdltexture=nil)then writeLog('gfx_MakeBaseTile -> SDL_CreateTextureFromSurface');
   end;
end;

procedure gfx_MakeThemeTiles;
var
anim_seed:cardinal;
animRX,
animRY,
i,
animStepX,
animStepY: integer;
maskColor: TMWColor;
upd_tiles: boolean;
function CheckTile(cur_id,last_id:pinteger;TargetMWTexture:pTMWTexture):boolean;
begin
   CheckTile:=false;
   if(cur_id^<>last_id^)then
   begin
      if(0<=cur_id^)and(cur_id^<theme_all_terrain_n)
      then CheckTile:=true
      else
        with TargetMWTexture^ do SDLSurf_boxColor(sdlsurface,0,0,w,h,c_black);
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

   //writeln('--------------------');

   // base terrain tile
   if(CheckTile(@theme_cur_tile_terrain_id ,@theme_last_tile_terrain_id ,theme_tile_terrain ))then
   begin
       gfx_MakeBaseTile(theme_tile_terrain,
                        theme_all_terrain_l[theme_cur_tile_terrain_id],MapCellW,true,animStepX,animStepy);
       //writeln('update 1 theme_tile_terrain');
   end;

   // crater tileset
   upd_tiles:=false;
   if(CheckTile(@theme_cur_tile_crater_id  ,@theme_last_tile_crater_id  ,theme_tile_crater  ))then
   begin
      gfx_MakeBaseTile(theme_tile_crater,
                       theme_all_terrain_l[theme_cur_tile_crater_id  ],MapCellW,true,animStepX,animStepy);
      // alpha black make texture darker

      SDLSurf_boxColor(theme_tile_crater^.sdlsurface,0,0,theme_tile_crater^.w,theme_tile_crater^.h,gfx_MakeAlphaTMWColor(150));
      upd_tiles:=true;
      //writeln('update 2 theme_tile_crater');
   end;
   if(upd_tiles)
   or(theme_cur_crater_tes<>theme_last_crater_tes)then
   begin
      if(theme_cur_crater_tes=tes_tech)
      then gfx_TileSet_Render(theme_tile_crater^.sdlsurface,theme_tileset_crater,gfx_TileTemplate_crater_tech  ,animStepX,animStepY,0,cardinal.MaxValue)
      else gfx_TileSet_Render(theme_tile_crater^.sdlsurface,theme_tileset_crater,gfx_TileTemplate_crater_nature,animStepX,animStepY,0,cardinal.MaxValue);
      theme_last_crater_tes:=theme_cur_crater_tes;
      //writeln('update 3 theme_tileset_crater');
   end;

   // liquid tileset
   upd_tiles:=false;
   if(CheckTile(@theme_cur_tile_liquid_id  ,@theme_last_tile_liquid_id  ,theme_tile_liquid  ))then
   begin
      gfx_MakeBaseTile(theme_tile_liquid,
                       theme_all_terrain_l[theme_cur_tile_liquid_id],MapCellW,true,animStepX,animStepy);
      upd_tiles:=true;
      //writeln('update 4 theme_tile_liquid');
   end;
   if(upd_tiles)
   or(theme_cur_liquid_tes<>theme_last_liquid_tes)
   or(theme_cur_liquid_tas<>theme_last_liquid_tas)then
   begin
      //writeln('update 5 theme_tileset_liquid');
      for i:=0 to theme_anim_step_n-1 do
      begin
         maskColor:=0;
         if(theme_cur_liquid_tas=tas_magma)and(i>0)then maskColor:=gfx_MakeAlphaTMWColor(255-i*30);

         if(theme_cur_liquid_tes=tes_nature)then
         begin
            if(theme_cur_liquid_tas=tas_magma)
            then gfx_TileSet_Render(theme_tile_liquid^.sdlsurface,theme_tileset_liquid[i],gfx_TileTemplate_liquid[0],animStepX,animStepY,maskColor,cardinal.MaxValue)
            else gfx_TileSet_Render(theme_tile_liquid^.sdlsurface,theme_tileset_liquid[i],gfx_TileTemplate_liquid[i],animStepX,animStepY,maskColor,cardinal.MaxValue);
         end
         else
           with theme_tileset_liquid[i]^[0]^ do
           begin
              gfx_FillSurfaceBySurface(sdlSurface,theme_tile_liquid^.sdlsurface,animStepX,animStepY);
              if(maskColor>0)then SDLSurf_boxColor(sdlSurface,0,0,MapCellW,MapCellW,maskColor);
              gfx_UpdateSDLTexture(theme_tileset_liquid[i]^[0]);
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
end;

////////////////////////////////////////////////////////////////////////////////

function gfx_LoadFont(fn:shortstring):PTFont;
var i:byte;
    c:char;
  ccc:TMWPixel;
 fspr:pTMWTexture;
begin
   fspr:=gfx_MWTextureLoad(fn,false,true,true);

   new(gfx_LoadFont);
   with gfx_LoadFont^ do
   begin
      font_w :=max2i(1,fspr^.w div 16);
      font_h :=max2i(1,fspr^.h div 16);
      font_lh:=font_h+(font_h div 4);
      font_hw:=font_w div 2;
      font_hh:=font_h div 2;
   end;

   if(fspr^.sdlsurface=nil)then
   begin
      gfx_MWTextureFree(fspr);
      exit;
   end;

   ccc :=SDL_SurfaceGetPixel(fspr^.sdlsurface,0,0);
   with gfx_LoadFont^ do
   for i:=0 to 255 do
   begin
      c:=chr(i);
      new(MWTextures[c]);
      gfx_MWTextureInit(MWTextures[c]);

      with MWTextures[c]^ do
      begin
         sdlsurface:=sdl_createRGBSurface(0,font_w,font_h,fspr^.sdlsurface^.format^.BitsPerPixel,
                                                          fspr^.sdlsurface^.format^.Rmask,
                                                          fspr^.sdlsurface^.format^.Gmask,
                                                          fspr^.sdlsurface^.format^.Bmask,
                                                          fspr^.sdlsurface^.format^.Amask);

         if(sdlsurface=nil)then
         begin
            writeLog('gfx_LoadFont -> sdl_createRGBSurface');
            continue;
         end;
         SDL_FillRect(sdlsurface,nil,ccc);

         {vid_SDLRect^.x:=i*font_w;
         vid_SDLRect^.y:=0;
         vid_SDLRect^.w:=font_w;
         vid_SDLRect^.h:=font_h;

         SDL_BLITSURFACE(fspr^.sdlsurface,vid_SDLRect,sdlsurface,nil);}
         draw_sdlsurface(sdlsurface,-(i mod 16)*font_w,-(i div 16)*font_w,fspr^.sdlsurface);

         SDL_SetColorKey(sdlsurface,1,ccc);

         sdltexture:=SDL_CreateTextureFromSurface(vid_SDLRenderer,sdlsurface);
         if(sdltexture=nil)
         then writeLog('gfx_LoadFont -> SDL_CreateTextureFromSurface')
         else SDL_SetTextureBlendMode(sdltexture,SDL_BLENDMODE_BLEND);

         sdl_FreeSurface(sdlsurface);
         sdlsurface:=nil;

         w :=font_w;
         h :=font_h;
         hw:=font_hw;
         hh:=font_hh;
      end;
   end;
   gfx_MWTextureFree(fspr);
end;


{$include _themes.pas}

procedure SaveSurfacePart(surf:pSDL_Surface;x,y,w,h:integer;fn:shortstring);
var tmp:pSDL_Surface;
begin
   tmp:=gfx_SDLSurfaceCreate(w,h);

   vid_SDLRect^.x:=x;
   vid_SDLRect^.y:=y;
   vid_SDLRect^.w:=w;
   vid_SDLRect^.h:=h;

   SDL_BLITSURFACE(surf,vid_SDLRect,tmp,nil);
   fn+=#0;
   IMG_SavePNG(tmp,@fn[1]);
   SDL_FreeSurface(tmp);
end;

function CheckFreeCol(surf:pSDL_Surface;x:integer;color:TMWColor):boolean;
var y:integer;
begin
   for y:=0 to surf^.h-1 do
     if(SDL_SurfaceGetPixel(surf,x,y)<>color)then
     begin
        CheckFreeCol:=false;
        exit;
     end;

   CheckFreeCol:=true;
end;

procedure SplitFont;
var
tfont :pSDL_Surface;
x,x0,wi,
x1,i  :integer;
bcolor:TMWColor;
mode  :byte;
begin
   tfont:=gfx_MWTextureLoadSDLSurfaceFromFile(str_f_grp+'font_test1.png');

   bcolor:=SDL_SurfaceGetPixel(tfont,0,0);

   wi:=tfont^.w-1;
   mode:=0;
   x0:=0;
   x1:=0;
   i:=192;

   for x:=0 to wi do
   begin
      case mode of
      0 : begin
             if(not CheckFreeCol(tfont,x,bcolor))then
             begin
                x0:=x;
                mode:=1;
             end;
          end;
      1 : begin
             if(CheckFreeCol(tfont,x,bcolor))or(x=wi)then
             begin
                write(i,'=',chr(i),' ');
                x1:=x;
                mode:=0;
                SaveSurfacePart(tfont,x0,0,x1-x0,tfont^.h,'temp\'+b2s(i)+'.png');
                i+=1;
             end;
          end;
      end;
   end;
   writeln;
end;

procedure dtest;
const
cw =18;
cwh=cw div 2;
var
tchars:array[byte] of pSDL_Surface;
tfont0,
tfont :pSDL_Surface;
ckey:TMWColor;
tstr:shortstring;
c:byte;
begin
  { tfont0:=gfx_MWTextureLoadSDLSurfaceFromFile(str_f_grp+'fontbase.png');
   writeln(tfont0^.w,' ',tfont0^.h);

   for c:=0 to 255 do
   begin
      tchars[c]:=gfx_SDLSurfaceCreate(cw,cw);
      draw_sdlsurface(tchars[c],-c*cw,0,tfont0);
   end; }

   //

   for c:=0 to 255 do
   begin
      tchars[c]:=gfx_MWTextureLoadSDLSurfaceFromFile('temp\'+b2s(c)+'.png');
      if(tchars[c]<>nil)then
      SDL_SetColorKey(tchars[c],1,SDL_SurfaceGetPixel(tchars[c],0,0));
   end;



   tfont:=gfx_SDLSurfaceCreate(cw*16,cw*16);

   //tfont0:=gfx_SDLSurfaceCreate(cw*16,cw*16);
   //SDLSurf_boxColor(tfont0,0,0,tfont0^.w,tfont0^.h,c_white);
   //SDL_SetSurfaceAlphaMod(tfont0,0);


   for c:=0 to 255 do
   if(tchars[c]<>nil)then draw_sdlsurface(tfont,(c mod 16)*cw+cwh-(tchars[c]^.w div 2),
                                                (c div 16)*cw+cwh-(tchars[c]^.h div 2)-2,tchars[c]);

   //draw_sdlsurface(tfont,0,0,tfont0);

   tstr:=str_f_grp+'font2.png'+#0;
   IMG_SavePNG(tfont,@tstr[1]);
end;

procedure gfx_LoadGraphics;
var x,r:integer;
begin
   // basic textures
   //SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 'best');

   new(ptex_dummy);
   gfx_MWTextureInit(@tex_dummy);
   ptex_dummy:=@tex_dummy;
   with spr_dmodel do
   begin
      sm_listi:=0;
      sm_listn:=1;
      setlength(sm_list,sm_listn);
      sm_list[sm_listi]:=ptex_dummy;
      sm_type :=smt_effect;
   end;
   spr_pdmodel:=@spr_dmodel;

   dtest;

   //font_Base:=gfx_LoadFont(str_f_FontBig);
   font_Base:=gfx_LoadFont(str_f_FontBase);
   font_Doom :=gfx_LoadFont(str_f_FontBig );

   draw_set_font(font_Base,fontSize_BaseDefault);



   draw_LoadingScreen(str_loading_gfxd,c_red);

   tex_menu        :=gfx_MWTextureMakeRenderTarget(menu_w       ,menu_h       );
   tex_ui_MiniMap0 :=gfx_MWTextureMakeRenderTarget(ui_panel_pwi,ui_panel_pwi); // minimap: ui back
   tex_ui_MiniMap1 :=gfx_MWTextureMakeRenderTarget(ui_panel_pwu,ui_panel_pwu); // minimap: ui front
   tex_map_mMiniMap:=gfx_MWTextureMakeRenderTarget(ui_panel_pwi,ui_panel_pwi); // minimap: menu
   tex_map_bMiniMap:=gfx_MWTextureMakeRenderTarget(ui_panel_pwi,ui_panel_pwi); // minimap: terrain background

   // theme tileset templates

   theme_tile_terrain:=gfx_MWTextureMakeSDLSurface(MapCellW,MapCellW);
   theme_tile_crater :=gfx_MWTextureMakeSDLSurface(MapCellW,MapCellW);
   theme_tile_liquid :=gfx_MWTextureMakeSDLSurface(MapCellW,MapCellW);

   gfx_TileTemplate_crater_tech  :=gfx_TileSetTemplate_Make(c_white,c_black,MapCellW,tes_tech  ,-2,0);
   gfx_TileTemplate_crater_nature:=gfx_TileSetTemplate_Make(c_white,c_black,MapCellW,tes_nature,10,0);
   for x:=0 to theme_anim_step_n-1 do
   gfx_TileTemplate_liquid[x]    :=gfx_TileSetTemplate_Make(c_white,c_black,MapCellW,tes_nature,-2,byte(x*5));

   theme_tileset_crater   :=gfx_TileSet_Make(MapCellW);
   for x:=0 to theme_anim_step_n-1 do
   theme_tileset_liquid[x]:=gfx_TileSet_Make(MapCellW);

   ui_fog_tileset         :=gfx_TileSet_Make(fog_CellW);

   // FOG tiles
   gfx_TileSet_MakeFog;


   // load main graphics
   draw_LoadingScreen(str_loading_gfx1,c_orange);

   spr_mlogo     :=gfx_MWTextureLoad('logo'       ,false);
   spr_mback     :=gfx_MWTextureLoad('mback'      ,false);

   spr_cursor    :=gfx_MWTextureLoad('cursor'     ,true );

   spr_b_delete  :=gfx_MWTextureLoad('b_destroy'  ,true );
   spr_b_attack  :=gfx_MWTextureLoad('b_attack'   ,true );
   spr_b_move    :=gfx_MWTextureLoad('b_move'     ,true );
   spr_b_patrol  :=gfx_MWTextureLoad('b_patrol'   ,true );
   spr_b_apatrol :=gfx_MWTextureLoad('b_apatrol'  ,true );
   spr_b_stop    :=gfx_MWTextureLoad('b_stop'     ,true );
   spr_b_hold    :=gfx_MWTextureLoad('b_hold'     ,true );

   spr_b_selall  :=gfx_MWTextureLoad('b_selall'   ,true );
   spr_b_cancel  :=gfx_MWTextureLoad('b_cancle'   ,true );
   spr_b_rfast   :=gfx_MWTextureLoad('b_rfast'    ,true );
   spr_b_rskip   :=gfx_MWTextureLoad('b_rskip'    ,true );
   spr_b_rback   :=gfx_MWTextureLoad('b_rback'    ,true );
   spr_b_rfog    :=gfx_MWTextureLoad('b_fog'      ,true );
   spr_b_rlog    :=gfx_MWTextureLoad('b_log'      ,true );
   spr_b_rstop   :=gfx_MWTextureLoad('b_rstop'    ,true );
   spr_b_rvis    :=gfx_MWTextureLoad('b_rvis'     ,true );
   spr_b_rclck   :=gfx_MWTextureLoad('b_rclick'   ,true );
   spr_b_mmark   :=gfx_MWTextureLoad('b_mmark'    ,true );

   for x:=0 to 3 do
   spr_tabs[x]   :=gfx_MWTextureLoad('tabs'+b2s(x),true );

   spr_c_earth   :=gfx_MWTextureLoad('M_EARTH'    ,false);
   spr_c_mars    :=gfx_MWTextureLoad('M_MARS'     ,false);
   spr_c_hell    :=gfx_MWTextureLoad('M_HELL'     ,false);
   spr_c_phobos  :=gfx_MWTextureLoad('M_PHOBOS'   ,false);
   spr_c_deimos  :=gfx_MWTextureLoad('M_DEIMOS'   ,false);

   spr_mp[r_hell]:=gfx_MWTextureLoad(race_dir[r_hell]+'h_mp'         ,true);
   spr_mp[r_uac ]:=gfx_MWTextureLoad(race_dir[r_uac ]+'u_mp'         ,true);
   spr_ptur      :=gfx_MWTextureLoad(race_dir[r_uac ]+'ptur'         ,true);

   spr_b4_a      :=gfx_MWTextureLoad(race_buildings[r_uac ]+'u_b4_a' ,true);
   spr_b7_a      :=gfx_MWTextureLoad(race_buildings[r_uac ]+'u_b7_a' ,true);
   spr_b9_a      :=gfx_MWTextureLoad(race_buildings[r_uac ]+'u_b9_a' ,true);

   spr_stun      :=gfx_MWTextureLoad(effects_folder+'stun'           ,true);
   spr_invuln    :=gfx_MWTextureLoad(effects_folder+'invuln'         ,true);
   spr_hvision   :=gfx_MWTextureLoad(effects_folder+'hvision'        ,true);
   spr_scan      :=gfx_MWTextureLoad(effects_folder+'scan'           ,true);
   spr_decay     :=gfx_MWTextureLoad(effects_folder+'decay'          ,true);

   spr_cp_koth   :=gfx_MWTextureLoad('cp_koth'                       ,true);
   spr_cp_out    :=gfx_MWTextureLoad('cp_out'                        ,true);
   spr_cp_gen    :=gfx_MWTextureLoad('cp_gen'                        ,true);


   spr_lostsoul       :=gfx_MWSModelLoad(race_units[r_hell]+'h_u0_'      ,smt_lost     );
   spr_phantom        :=gfx_MWSModelLoad(race_units[r_hell]+'h_u0a_'     ,smt_lost     );
   spr_imp            :=gfx_MWSModelLoad(race_units[r_hell]+'h_u1_'      ,smt_imp      );
   spr_demon          :=gfx_MWSModelLoad(race_units[r_hell]+'h_u2_'      ,smt_imp      );
   spr_cacodemon      :=gfx_MWSModelLoad(race_units[r_hell]+'h_u3_'      ,smt_caco     );
   spr_knight         :=gfx_MWSModelLoad(race_units[r_hell]+'h_u4k_'     ,smt_imp      );
   spr_baron          :=gfx_MWSModelLoad(race_units[r_hell]+'h_u4_'      ,smt_imp      );
   spr_cyberdemon     :=gfx_MWSModelLoad(race_units[r_hell]+'h_u5_'      ,smt_imp      );
   spr_mastermind     :=gfx_MWSModelLoad(race_units[r_hell]+'h_u6_'      ,smt_mmind    );
   spr_pain           :=gfx_MWSModelLoad(race_units[r_hell]+'h_u7_'      ,smt_pain     );
   spr_revenant       :=gfx_MWSModelLoad(race_units[r_hell]+'h_u8_'      ,smt_revenant );
   spr_mancubus       :=gfx_MWSModelLoad(race_units[r_hell]+'h_u9_'      ,smt_mancubus );
   spr_arachnotron    :=gfx_MWSModelLoad(race_units[r_hell]+'h_u10_'     ,smt_archno   );
   spr_archvile       :=gfx_MWSModelLoad(race_units[r_hell]+'h_u11_'     ,smt_arch     );

   spr_ZFormer        :=gfx_MWSModelLoad(race_units[r_hell]+'h_z0_'      ,smt_imp      );
   spr_ZEngineer      :=gfx_MWSModelLoad(race_units[r_hell]+'h_z0s_'     ,smt_zengineer);
   spr_ZSergant       :=gfx_MWSModelLoad(race_units[r_hell]+'h_z1_'      ,smt_imp      );
   spr_ZSSergant      :=gfx_MWSModelLoad(race_units[r_hell]+'h_z1s_'     ,smt_imp      );
   spr_ZCommando      :=gfx_MWSModelLoad(race_units[r_hell]+'h_z2_'      ,smt_zcommando);
   spr_ZAntiaircrafter:=gfx_MWSModelLoad(race_units[r_hell]+'h_zr_'      ,smt_imp      );
   spr_ZSiege         :=gfx_MWSModelLoad(race_units[r_hell]+'h_z3_'      ,smt_imp      );
   spr_ZFMajor        :=gfx_MWSModelLoad(race_units[r_hell]+'h_z4j_'     ,smt_fmajor   );
   spr_ZBFG           :=gfx_MWSModelLoad(race_units[r_hell]+'h_z5_'      ,smt_imp      );

   spr_Medic          :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u0_'      ,smt_medic    );
   spr_Engineer       :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u1_'      ,smt_marine0  );
   spr_Scout          :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u1s_'     ,smt_imp      );
   spr_Sergant        :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u2_'      ,smt_imp      );
   spr_SSergant       :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u2s_'     ,smt_imp      );
   spr_Commando       :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u3_'      ,smt_zcommando);
   spr_Antiaircrafter :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u4r_'     ,smt_imp      );
   spr_Siege          :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u4_'      ,smt_imp      );
   spr_FMajor         :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u5j_'     ,smt_fmajor   );
   spr_BFG            :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u6_'      ,smt_imp      );
   spr_FAPC           :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u8_'      ,smt_transport);
   spr_APC            :=gfx_MWSModelLoad(race_units[r_uac ]+'uac_tank_'  ,smt_apc      );
   spr_Terminator     :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u9_'      ,smt_terminat );
   spr_Tank           :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u10_'     ,smt_tank     );
   spr_Flyer          :=gfx_MWSModelLoad(race_units[r_uac ]+'u_u11_'     ,smt_flyer    );
   spr_Transport      :=gfx_MWSModelLoad(race_units[r_uac ]+'transport'  ,smt_transport);
   spr_UACBot         :=gfx_MWSModelLoad(race_units[r_uac ]+'uacd'       ,smt_flyer    );

   spr_HKeep1         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b0_'  ,smt_buiding  );
   spr_HKeep2         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b0a_' ,smt_buiding  );
   spr_HGate1         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b1a'  ,smt_buiding  );
   spr_HGate2         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b1b'  ,smt_buiding  );
   spr_HGate3         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b1c'  ,smt_buiding  );
   spr_HGate4         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b1d'  ,smt_buiding  );
   spr_HSymbol1       :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b2_'  ,smt_buiding  );
   spr_HSymbol2       :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b2a_' ,smt_buiding  );
   spr_HSymbol3       :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b2b'  ,smt_buiding  );
   spr_HSymbol4       :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b2c'  ,smt_buiding  );
   spr_HPools1        :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b3_'  ,smt_buiding  );
   spr_HPools2        :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b3a'  ,smt_buiding  );
   spr_HPools3        :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b3b'  ,smt_buiding  );
   spr_HPools4        :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b3c'  ,smt_buiding  );
   spr_HTower         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b4_'  ,smt_buiding  );
   spr_HTeleport      :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b5_'  ,smt_buiding  );
   spr_HMonastery     :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b6_'  ,smt_buiding  );
   spr_HTotem         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b7_'  ,smt_buiding  );
   spr_HAltar         :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b8_'  ,smt_buiding  );
   spr_HFortress      :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b9_'  ,smt_buiding  );
   spr_HPentagram     :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_b10_' ,smt_buiding  );
   spr_HCommandCenter1:=gfx_MWSModelLoad(race_buildings[r_hell]+'h_hcc_' ,smt_buiding  );
   spr_HCommandCenter2:=gfx_MWSModelLoad(race_buildings[r_hell]+'h_hcca_',smt_buiding  );
   spr_HBarracks1     :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_hbar_',smt_buiding  );
   spr_HBarracks2     :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_hbara',smt_buiding  );
   spr_HBarracks3     :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_hbarb',smt_buiding  );
   spr_HBarracks4     :=gfx_MWSModelLoad(race_buildings[r_hell]+'h_hbarc',smt_buiding  );
   spr_HEye           :=gfx_MWSModelLoad(race_buildings[r_hell]+'heye_'  ,smt_buiding  );

   spr_UCommandCenter1:=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b0_' ,smt_buiding  );
   spr_UCommandCenter2:=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b0a_',smt_buiding  );
   spr_UBarracks1     :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b1_' ,smt_buiding  );
   spr_UBarracks2     :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b1a' ,smt_buiding  );
   spr_UBarracks3     :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b1b' ,smt_buiding  );
   spr_UBarracks4     :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b1c' ,smt_buiding  );
   spr_UGenerator1    :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b2_' ,smt_buiding  );
   spr_UGenerator2    :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b2a_',smt_buiding  );
   spr_UGenerator3    :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b2c_',smt_buiding  );
   spr_UGenerator4    :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b2d_',smt_buiding  );
   spr_UWeaponFactory1:=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b3_' ,smt_buiding  );
   spr_UWeaponFactory2:=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b3a' ,smt_buiding  );
   spr_UWeaponFactory3:=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b3b' ,smt_buiding  );
   spr_UWeaponFactory4:=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b6_' ,smt_buiding  );
   spr_UTurret        :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b4_' ,smt_turret   );
   spr_URadar         :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b5_' ,smt_buiding  );
   spr_UTechCenter    :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b13_',smt_buiding  );
   spr_UPTurret       :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b7_' ,smt_turret   );
   spr_URocketL       :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b8_' ,smt_buiding  );
   spr_URTurret       :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b9_' ,smt_turret2  );
   spr_UCompStation   :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b10_',smt_buiding  );
   spr_UFactory1      :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b12_',smt_buiding  );
   spr_UFactory2      :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b11_',smt_buiding  );
   spr_UFactory3      :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b12a',smt_buiding  );
   spr_UFactory4      :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_b12b',smt_buiding  );
   spr_Mine           :=gfx_MWSModelLoad(race_buildings[r_uac ] +'u_mine',smt_buiding  );

   spr_db_h0          :=gfx_MWSModelLoad(race_dir[r_hell]+'db_h0'        ,smt_effect   );
   spr_db_h1          :=gfx_MWSModelLoad(race_dir[r_hell]+'db_h1'        ,smt_effect   );
   spr_db_u0          :=gfx_MWSModelLoad(race_dir[r_uac ]+'db_u0'        ,smt_effect   );
   spr_db_u1          :=gfx_MWSModelLoad(race_dir[r_uac ]+'db_u1'        ,smt_effect   );

   spr_h_p0           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p0_'   ,smt_effect   );
   spr_h_p1           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p1_'   ,smt_effect   );
   spr_h_p2           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p2_'   ,smt_missile  );
   spr_h_p3           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p3_'   ,smt_missile  );
   spr_h_p4           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p4_'   ,smt_missile  );
   spr_h_p5           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p5_'   ,smt_missile  );
   spr_h_p6           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p6_'   ,smt_effect   );
   spr_h_p7           :=gfx_MWSModelLoad(race_missiles[r_hell]+'h_p7_'   ,smt_effect   );
   spr_u_p0           :=gfx_MWSModelLoad(race_missiles[r_uac ]+'u_p0_'   ,smt_effect   );
   spr_u_p1           :=gfx_MWSModelLoad(race_missiles[r_uac ]+'u_p1_'   ,smt_effect   );
   spr_u_p1s          :=gfx_MWSModelLoad(race_missiles[r_uac ]+'u_p1_'   ,smt_effect2  );
   spr_u_p2           :=gfx_MWSModelLoad(race_missiles[r_uac ]+'u_p2_'   ,smt_effect   );
   spr_u_p3           :=gfx_MWSModelLoad(race_missiles[r_uac ]+'u_p3_'   ,smt_effect   );
   spr_u_p8           :=gfx_MWSModelLoad(race_missiles[r_uac ]+'u_p8_'   ,smt_missile  );

   spr_eff_bfg        :=gfx_MWSModelLoad(effects_folder+'ef_bfg_'        ,smt_effect   );
   spr_eff_eb         :=gfx_MWSModelLoad(effects_folder+'ef_eb'          ,smt_effect   );
   spr_eff_ebb        :=gfx_MWSModelLoad(effects_folder+'ef_ebb'         ,smt_effect   );
   spr_eff_gtel       :=gfx_MWSModelLoad(effects_folder+'ef_gt_'         ,smt_effect   );
   spr_eff_tel        :=gfx_MWSModelLoad(effects_folder+'ef_tel_'        ,smt_effect   );
   spr_eff_exp        :=gfx_MWSModelLoad(effects_folder+'ef_exp_'        ,smt_effect   );
   spr_eff_exp2       :=gfx_MWSModelLoad(effects_folder+'exp2_'          ,smt_effect   );
   spr_eff_g          :=gfx_MWSModelLoad(effects_folder+'g_'             ,smt_effect   );
   spr_blood          :=gfx_MWSModelLoad(effects_folder+'blood'          ,smt_effect   );

   for x:=0 to spr_upgrade_icons do
     for r:=1 to race_num do
       spr_b_up[r,x]:=gfx_MWTextureLoadUIButtonFromFile(race_upgrades[r]+'b_up'+b2s(x));

   for x:=0 to 255 do
     with g_uids[x] do
       uid_ui_button:=gfx_MWTextureMakeRenderTarget(ui_pButtonWi,ui_pButtonWi);

   // load game resources
   draw_LoadingScreen(str_loading_gfx2,c_yellow);

   InitThemes;

   effect_InitCLData;
end;

procedure gfx_MakeUnitIcons;
var
tmpMWTexture:pTMWTexture;
   u : byte;
coff : single;
nw,nh:integer;
begin
   draw_set_color(c_white);
   draw_set_alpha(255);
   for u:=0 to 255 do
     with g_uids[u] do
       with uid_ui_button^ do
       begin
          case _urace of
          r_hell: tmpMWTexture:=sm_uid2MWTexture(u,315,0);
          r_uac : tmpMWTexture:=sm_uid2MWTexture(u,225,0);
          end;

          if(tmpMWTexture^.w<=ui_pButtonWi)or(tmpMWTexture^.h<=ui_pButtonWi)
          then coff:=1
          else
            if(tmpMWTexture^.w<tmpMWTexture^.h)
            then coff:=ui_pButtonWi/tmpMWTexture^.w
            else coff:=ui_pButtonWi/tmpMWTexture^.h;

          nw:=round(tmpMWTexture^.w*coff);
          nh:=round(tmpMWTexture^.h*coff);

          draw_set_target(uid_ui_button);

          if(nh>ui_pButtonWi)
          then draw_mwtexture2(ui_pButtonWih-(nw div 2),ui_pButtonWb            ,tmpMWTexture,nw,nh)
          else draw_mwtexture2(ui_pButtonWih-(nw div 2),ui_pButtonWih-(nh div 2),tmpMWTexture,nw,nh);

          draw_set_target(nil);
       end;
end;

procedure gfx_ui_UpdateTextures;
var
new_sc:single;
begin
   gfx_MWTextureFree(tex_ui_ControlBar);

   ui_MiniMap_sc   :=ui_MiniMap_msc   /100;
   ui_ControlBar_sc:=ui_ControlBar_msc/100;

   ui_MiniMap_w:=round(ui_panel_pwu*ui_MiniMap_sc);

   case ui_CBarPos of
uicbp_left,
uicbp_right  : begin
                ui_ControlBar_w:=round(ui_panel_pwu*ui_ControlBar_sc);
                ui_ControlBar_h:=round(ui_panel_ph *ui_ControlBar_sc);

                if((ui_MiniMap_w+ui_ControlBar_h)>vid_vh)then
                begin
                   new_sc:=vid_vh/(ui_MiniMap_w+ui_ControlBar_h);
                   ui_MiniMap_sc   *=new_sc;
                   ui_ControlBar_sc*=new_sc;

                   ui_MiniMap_w:=round(ui_panel_pwu*ui_MiniMap_sc);
                   ui_ControlBar_w:=round(ui_panel_pwu*ui_ControlBar_sc);
                   ui_ControlBar_h:=round(ui_panel_ph *ui_ControlBar_sc);
                end;

                if(ui_CBarPos=uicbp_left)
                then ui_ControlBar_x:=0
                else ui_ControlBar_x:=vid_vw-ui_ControlBar_w;

                if(ui_CBarPos=uicbp_left)
                then ui_MiniMap_x:=0
                else ui_MiniMap_x:=vid_vw-ui_MiniMap_w;

                if(ui_MiniMapPos)then   // top
                begin
                   ui_MiniMap_y   :=0;
                   ui_ControlBar_y:=ui_MiniMap_w;
                end
                else
                begin
                   ui_MiniMap_y   :=vid_vh-ui_MiniMap_w;
                   ui_ControlBar_y:=ui_MiniMap_y-ui_ControlBar_h;
                end;

                tex_ui_ControlBar:=gfx_MWTextureMakeRenderTarget(ui_panel_pwu,ui_panel_ph);
             end;
uicbp_top,
uicbp_bottom : begin
                ui_ControlBar_w:=round(ui_panel_ph *ui_ControlBar_sc);
                ui_ControlBar_h:=round(ui_panel_pwu*ui_ControlBar_sc);

                if((ui_MiniMap_w+ui_ControlBar_w)>vid_vw)then
                begin
                   new_sc:=vid_vw/(ui_MiniMap_w+ui_ControlBar_w);
                   ui_MiniMap_sc   *=new_sc;
                   ui_ControlBar_sc*=new_sc;

                   ui_MiniMap_w:=round(ui_panel_pwu*ui_MiniMap_sc);
                   ui_ControlBar_w:=round(ui_panel_ph *ui_ControlBar_sc);
                   ui_ControlBar_h:=round(ui_panel_pwu*ui_ControlBar_sc);
                end;

                if(ui_CBarPos=uicbp_top)
                then ui_ControlBar_y:=0
                else ui_ControlBar_y:=vid_vh-ui_ControlBar_h;

                if(ui_CBarPos=uicbp_top)
                then ui_MiniMap_y:=0
                else ui_MiniMap_y:=vid_vh-ui_MiniMap_w;

                if(ui_MiniMapPos)then //left
                begin
                   ui_ControlBar_x:=ui_MiniMap_w;
                   ui_MiniMap_x   :=0;
                end
                else
                begin
                   ui_MiniMap_x   :=vid_vw-ui_MiniMap_w;
                   ui_ControlBar_x:=ui_MiniMap_x-ui_ControlBar_w;
                end;

                tex_ui_ControlBar:=gfx_MWTextureMakeRenderTarget(ui_panel_ph,ui_panel_pwu);
             end;
   end;
end;

procedure vid_UpdateFogGridSize;
begin
   ui_FogView_gridW:=(round(vid_maxw/vid_cam_minsc) div fog_CellW)+2;
   ui_FogView_gridH:=(round(vid_maxh/vid_cam_minsc) div fog_CellW)+2;
   setlength(ui_FogView_grid ,ui_FogView_gridW,ui_FogView_gridH);
   setlength(ui_FogView_pgrid,ui_FogView_gridW,ui_FogView_gridH);
end;

procedure vid_UpdateCamVars;
begin
   vid_cam_w    :=round(vid_vw/vid_cam_sc);
   vid_cam_h    :=round(vid_vh/vid_cam_sc);

   vid_cam_hw   :=vid_cam_w div 2;
   vid_cam_hh   :=vid_cam_h div 2;

   ui_FogView_cw:=min2i((vid_cam_w div fog_CellW)+2,ui_FogView_gridW-1);
   ui_FogView_ch:=min2i((vid_cam_h div fog_CellW)+2,ui_FogView_gridH-1);

   ui_MapView_cw:=(vid_cam_w div MapCellW)+1;
   ui_MapView_ch:=(vid_cam_h div MapCellW)+1;

   map_mm_CamW  := round(vid_cam_w*map_mm_cx);
   map_mm_CamH  := round(vid_cam_h*map_mm_cx);
   GameCameraBounds;
end;

procedure vid_UpdateCommonVars;
var
ui_textLDy: integer;
begin
   vid_vhw      := vid_vw div 2;
   vid_vhh      := vid_vh div 2;

   gfx_ui_UpdateTextures;

   vid_vmb_x1   := vid_vw-vid_vmb_x0;
   vid_vmb_y1   := vid_vh-vid_vmb_y0;

   vid_UpdateCamVars;

   case ui_CBarPos of
uicbp_right,
uicbp_bottom,
uicbp_top    : ui_textLUx:=basefont_wh;
uicbp_left   : ui_textLUx:=ui_ControlBar_x+basefont_wh;
   end;
   case ui_CBarPos of
uicbp_left,
uicbp_right,
uicbp_bottom : ui_textLUy:=basefont_wh;
uicbp_top    : ui_textLUy:=ui_ControlBar_y+basefont_wh;
   end;
   case ui_CBarPos of
uicbp_left,
uicbp_right,
uicbp_top    : ui_textLDy:=vid_vh-basefont_wh;
uicbp_bottom : ui_textLDy:=ui_ControlBar_y-basefont_wh;
   end;

   case ui_CBarPos of
uicbp_left,
uicbp_bottom ,
uicbp_top    : ui_fpsx:=vid_vw-basefont_wh;
uicbp_right  : if(ui_MiniMapPos)
             then ui_fpsx:=ui_MiniMap_x   -basefont_wh
             else ui_fpsx:=ui_ControlBar_x-basefont_wh;
   end;
   case ui_CBarPos of
uicbp_left,
uicbp_bottom ,
uicbp_right  : ui_fpsy:=basefont_wh;
uicbp_top    : if(ui_MiniMapPos)
             then ui_fpsy:=ui_ControlBar_y+basefont_wh
             else ui_fpsy:=ui_MiniMap_y   +basefont_wh+ui_MiniMap_w;
   end;


  { ui_hinty1    := ui_MapView_y+vid_cam_h-basefont_w1h*10;
   ui_hinty2    := ui_MapView_y+vid_cam_h-basefont_w1h*8;
   ui_hinty3    := ui_MapView_y+vid_cam_h-basefont_w1h*5;
   ui_hinty4    := ui_MapView_y+vid_cam_h-basefont_w1h*2;
   ui_chaty     := ui_hinty1-basefont_w1h;
   ui_logy      := ui_chaty-basefont_w1h;
   ui_oicox     := ui_MapView_x+vid_cam_w-basefont_wh;
   ui_uiuphx    := ui_MapView_x+(vid_cam_w div 2);
   ui_uiuphy    := ui_textLUy+basefont_w3;
   ui_uiplayery := ui_uiuphy+basefont_w1h;
   ui_GameLogHeight:=(ui_hinty1-basefont_w5) div basefont_w1h;

   ui_energx    := ui_uiuphx-150;
   ui_energy    := ui_textLUy;
   ui_armyx     := ui_uiuphx+40;
   ui_armyy     := ui_textLUy; }
  // ui_fpsx      := vid_cam_w;//-(basefont_w1*basefont_w1h);
   //ui_fpsy      := ui_textLUy;
  { ui_apmx      := ui_fpsx;
   ui_apmy      := ui_fpsy+draw_font_h2;

   ui_ingamecl  :=(vid_cam_w-basefont_w1) div basefont_w1;
   if(r_menu<>nil)then gfx_SDLSurfaceFree(r_menu);
   r_menu:=gfx_SDLSurfaceCreate(vid_vw,vid_vh);
   if(spr_mback<>nil)then vid_MakeMenuBack; }


end;



