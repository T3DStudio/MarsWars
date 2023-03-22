
procedure InitRX2Y;
var r,x:integer;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _RX2Y[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
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

function _createSurf(tw,th:integer):pSDL_Surface;
var ts1,ts2:pSDL_Surface;
begin
   _createSurf:=nil;
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

procedure _lstr(mws:PTMWTexture;fn:shortstring;firstload,log:boolean);
begin
   with mws^ do
   begin
      if(firstload=false)then _FreeSF(surf);
      surf:=LoadIMG(fn,true,log);
      w :=surf^.w;
      h :=surf^.h;
      hw:=surf^.w div 2;
      hh:=surf^.h div 2;
   end;
end;

procedure _LoadMWSModel(mwsm:PTMWSModel;name:shortstring;_mkind:byte;firstload:boolean);
var t:TMWTexture;
procedure _addSelRect(ip:pinteger;vl:integer);
begin
   if(ip^=0)
   then ip^:=vl
   else ip^:=(ip^+vl) div 2;
end;
begin
   with mwsm^ do
   begin
      if(firstload=false)then
       while(sn>0)do
       begin
          _FreeSF(sl[sn-1].surf);
          sn-=1;
       end;

      sel_hw:=0;
      sel_hh:=0;
      sn :=0;
      setlength(sl,sn);

      _lstr(@t,name,firstload,false);
      if(t.surf<>r_empty)then
      begin
         sn+=1;
         setlength(sl,sn);
         sl[sn-1]:=t;
         _addSelRect(@sel_hw,t.hw);
         _addSelRect(@sel_hh,t.hh);
      end;

      while true do
      begin
         _lstr(@t,name+i2s(sn),firstload,false);
         if(t.surf=r_empty)then break;

         sn+=1;
         setlength(sl,sn);
         sl[sn-1]:=t;
         _addSelRect(@sel_hw,t.hw);
         _addSelRect(@sel_hh,t.hh);
      end;
      sk   :=sn-1;
      mkind:=_mkind;
   end;
end;

procedure _MakeLiquidTemplate(surf,ts:pSDL_Surface;xs,ys,d,r:integer;animst,animstyle:byte;itb:boolean);
var x,y,dir,i,e,p,rand:integer;
begin
   boxColor(surf,0,0,d,d,c_purple);

   x:=xs;
   while (x<d) do
   begin
      y:=ys;
      while (y<d) do
      begin
         _draw_surf(surf,x,y,ts);
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
         dir+=max2(1,(trunc(p*180/(pi*r)) div 3)*4 );
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
      theme_liquid_animm:=fr_fpsd2;
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
         wsp:=(ts^.w div 4)*((map_seed mod 3)-1);
         hsp:=(ts^.h div 4)*((abs(map_iseed) mod 3)-1);
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
      w:=vid_cam_w+(ter_w shl 1);
      h:=vid_cam_h+(ter_h shl 1);
      vid_terrain:=_createSurf(w,h);
      x:=0;
      while (x<w) do
      begin
         y:=0;
         while (y<w) do
         begin
            _draw_surf(vid_terrain,x,y,ter_s);
            y+=ter_s^.h;
         end;
         x+=ter_s^.w;
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
      with font_ca[c] do
      begin
         surf:=_createSurf(font_w,font_w);
         SDL_FillRect(surf,nil,0);
         SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,ccc);
      end;

      r_RECT^.x:=ord(i)*font_w;
      r_RECT^.y:=0;
      r_RECT^.w:=font_w;
      r_RECT^.h:=font_w;
      SDL_BLITSURFACE(fspr,r_RECT,font_ca[c].surf,nil);
   end;
   _FreeSF(fspr);
end;

{$include _themes.pas}

procedure _LoadGraphics(firstload:boolean);
var x,r:integer;
begin
   r_empty   :=_createSurf(1,1);
   SDL_SetColorKey(r_empty,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(r_empty,0,0));

   r_minimap :=_createSurf(vid_panelw-1,vid_panelw-1);
   r_bminimap:=_createSurf(vid_panelw-1,vid_panelw-1);

   for x:=1 to vid_mvs do new(vid_vsl[x]);

   vid_prims:=0;
   setlength(vid_prim,vid_prims);

   with spr_dummy do
   begin
      h   :=1;
      w   :=1;
      hh  :=1;
      hw  :=1;
      surf:=r_empty;
   end;
   pspr_dummy:=@spr_dummy;

   with spr_dmodel do
   begin
      sk:=0;
      sn:=1;
      setlength(sl,sn);
      sl[sk]:=spr_dummy;
      mkind :=smt_effect;
   end;
   spr_pdmodel:=@spr_dmodel;

   LoadFont;

   vid_fog_surf := _createSurf(fog_cr*2,fog_cr*2);
   boxColor(vid_fog_surf,0,0,vid_fog_surf^.w,vid_fog_surf^.h,c_purple);
   filledcircleColor(vid_fog_surf,fog_cr,fog_cr,fog_cr,c_black);
   SDL_SetColorKey(vid_fog_surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(vid_fog_surf,0,0));

   spr_mback:= loadIMG('mback'   ,false,true);

   r_menu:=_createSurf(max2(vid_minw,spr_mback^.w), max2(vid_minh,spr_mback^.h));

   mv_x:=(vid_vw-r_menu^.w) div 2;
   mv_y:=(vid_vh-r_menu^.h) div 2;


   spr_b_action   := LoadBtn('b_action' ,vid_bw);
   spr_b_paction  := LoadBtn('b_paction',vid_bw);
   spr_b_delete   := LoadBtn('b_destroy',vid_bw);
   spr_b_attack   := LoadBtn('b_attack' ,vid_bw);
   spr_b_rebuild  := LoadBtn('b_rebuild',vid_bw);
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
   spr_b_mmark    := LoadBtn('b_mmark'  ,vid_bw);

   for x:=0 to 3 do spr_tabs[x]:=LoadBtn('tabs'+b2s(x),vid_tbw);

   spr_cursor     := loadIMG('cursor'   ,true ,true);

   spr_c_earth    := LoadIMG('M_EARTH'  ,false,true);
   spr_c_mars     := LoadIMG('M_MARS'   ,false,true);
   spr_c_hell     := LoadIMG('M_HELL'   ,false,true);
   spr_c_phobos   := LoadIMG('M_PHOBOS' ,false,true);
   spr_c_deimos   := LoadIMG('M_DEIMOS' ,false,true);

   _LoadMWSModel(@spr_lostsoul       ,race_units[r_hell]+'h_u0_'      ,smt_lost     ,firstload);
   _LoadMWSModel(@spr_phantom        ,race_units[r_hell]+'h_u0a_'     ,smt_lost     ,firstload);
   _LoadMWSModel(@spr_imp            ,race_units[r_hell]+'h_u1_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_demon          ,race_units[r_hell]+'h_u2_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_cacodemon      ,race_units[r_hell]+'h_u3_'      ,smt_caco     ,firstload);
   _LoadMWSModel(@spr_knight         ,race_units[r_hell]+'h_u4k_'     ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_baron          ,race_units[r_hell]+'h_u4_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_cyberdemon     ,race_units[r_hell]+'h_u5_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_mastermind     ,race_units[r_hell]+'h_u6_'      ,smt_mmind    ,firstload);
   _LoadMWSModel(@spr_pain           ,race_units[r_hell]+'h_u7_'      ,smt_pain     ,firstload);
   _LoadMWSModel(@spr_revenant       ,race_units[r_hell]+'h_u8_'      ,smt_revenant ,firstload);
   _LoadMWSModel(@spr_mancubus       ,race_units[r_hell]+'h_u9_'      ,smt_mancubus ,firstload);
   _LoadMWSModel(@spr_arachnotron    ,race_units[r_hell]+'h_u10_'     ,smt_archno   ,firstload);
   _LoadMWSModel(@spr_archvile       ,race_units[r_hell]+'h_u11_'     ,smt_arch     ,firstload);

   _LoadMWSModel(@spr_ZFormer        ,race_units[r_hell]+'h_z0_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_ZEngineer      ,race_units[r_hell]+'h_z0s_'     ,smt_zengineer,firstload);
   _LoadMWSModel(@spr_ZSergant       ,race_units[r_hell]+'h_z1_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_ZSSergant      ,race_units[r_hell]+'h_z1s_'     ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_ZCommando      ,race_units[r_hell]+'h_z2_'      ,smt_zcommando,firstload);
   _LoadMWSModel(@spr_ZAntiaircrafter,race_units[r_hell]+'h_zr_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_ZSiege         ,race_units[r_hell]+'h_z3_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_ZFMajor        ,race_units[r_hell]+'h_z4j_'     ,smt_fmajor   ,firstload);
   _LoadMWSModel(@spr_ZBFG           ,race_units[r_hell]+'h_z5_'      ,smt_imp      ,firstload);

   _LoadMWSModel(@spr_Medic          ,race_units[r_uac ]+'u_u0_'      ,smt_medic    ,firstload);
   _LoadMWSModel(@spr_Engineer       ,race_units[r_uac ]+'u_u1_'      ,smt_marine0  ,firstload);
   _LoadMWSModel(@spr_Scout          ,race_units[r_uac ]+'u_u1s_'     ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_Sergant        ,race_units[r_uac ]+'u_u2_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_SSergant       ,race_units[r_uac ]+'u_u2s_'     ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_Commando       ,race_units[r_uac ]+'u_u3_'      ,smt_zcommando,firstload);
   _LoadMWSModel(@spr_Antiaircrafter ,race_units[r_uac ]+'u_u4r_'     ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_Siege          ,race_units[r_uac ]+'u_u4_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_FMajor         ,race_units[r_uac ]+'u_u5j_'     ,smt_fmajor   ,firstload);
   _LoadMWSModel(@spr_BFG            ,race_units[r_uac ]+'u_u6_'      ,smt_imp      ,firstload);
   _LoadMWSModel(@spr_FAPC           ,race_units[r_uac ]+'u_u8_'      ,smt_fapc     ,firstload);
   _LoadMWSModel(@spr_APC            ,race_units[r_uac ]+'uac_tank_'  ,smt_apc      ,firstload);
   _LoadMWSModel(@spr_Terminator     ,race_units[r_uac ]+'u_u9_'      ,smt_terminat ,firstload);
   _LoadMWSModel(@spr_Tank           ,race_units[r_uac ]+'u_u10_'     ,smt_tank     ,firstload);
   _LoadMWSModel(@spr_Flyer          ,race_units[r_uac ]+'u_u11_'     ,smt_flyer    ,firstload);
   _LoadMWSModel(@spr_Transport      ,race_units[r_uac ]+'transport'  ,smt_transport,firstload);
   _LoadMWSModel(@spr_UACBot         ,race_units[r_uac ]+'uacd'       ,smt_flyer    ,firstload);


   _LoadMWSModel(@spr_HKeep          ,race_buildings[r_hell]+'h_b0_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HAKeep         ,race_buildings[r_hell]+'h_b0a_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HGate          ,race_buildings[r_hell]+'h_b1_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HAGate         ,race_buildings[r_hell]+'h_b1a'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HSymbol        ,race_buildings[r_hell]+'h_b2_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HASymbol       ,race_buildings[r_hell]+'h_b2a_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HPools         ,race_buildings[r_hell]+'h_b3_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HAPools        ,race_buildings[r_hell]+'h_b3a'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HTower         ,race_buildings[r_hell]+'h_b4_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HTeleport      ,race_buildings[r_hell]+'h_b5_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HMonastery     ,race_buildings[r_hell]+'h_b6_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HTotem         ,race_buildings[r_hell]+'h_b7_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HAltar         ,race_buildings[r_hell]+'h_b8_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HFortress      ,race_buildings[r_hell]+'h_b9_'  ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HPentagram     ,race_buildings[r_hell]+'h_b10_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HCommandCenter ,race_buildings[r_hell]+'h_hcc_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_HACommandCenter,race_buildings[r_hell]+'h_hcca_',smt_buiding,firstload);
   _LoadMWSModel(@spr_HBarracks      ,race_buildings[r_hell]+'h_hbar_',smt_buiding,firstload);
   _LoadMWSModel(@spr_HABarracks     ,race_buildings[r_hell]+'h_hbara',smt_buiding,firstload);
   _LoadMWSModel(@spr_HEye           ,race_buildings[r_hell]+'heye_'  ,smt_buiding,firstload);

   _LoadMWSModel(@spr_UCommandCenter ,race_buildings[r_uac ] +'u_b0_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UACommandCenter,race_buildings[r_uac ] +'u_b0a_',smt_buiding,firstload);
   _LoadMWSModel(@spr_UBarracks      ,race_buildings[r_uac ] +'u_b1_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UABarracks     ,race_buildings[r_uac ] +'u_b1a' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UGenerator     ,race_buildings[r_uac ] +'u_b2_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UAGenerator    ,race_buildings[r_uac ] +'u_b2a_',smt_buiding,firstload);
   _LoadMWSModel(@spr_UWeaponFactory ,race_buildings[r_uac ] +'u_b3_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UAWeaponFactory,race_buildings[r_uac ] +'u_b3a' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UTurret        ,race_buildings[r_uac ] +'u_b4_' ,smt_turret ,firstload);
   _LoadMWSModel(@spr_URadar         ,race_buildings[r_uac ] +'u_b5_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UVehicleFactory,race_buildings[r_uac ] +'u_b6_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_UTechCenter    ,race_buildings[r_uac ] +'u_b13_',smt_buiding,firstload);
   _LoadMWSModel(@spr_UPTurret       ,race_buildings[r_uac ] +'u_b7_' ,smt_turret ,firstload);
   _LoadMWSModel(@spr_URocketL       ,race_buildings[r_uac ] +'u_b8_' ,smt_buiding,firstload);
   _LoadMWSModel(@spr_URTurret       ,race_buildings[r_uac ] +'u_b9_' ,smt_turret2,firstload);
   _LoadMWSModel(@spr_UNuclearPlant  ,race_buildings[r_uac ] +'u_b10_',smt_buiding,firstload);
   _LoadMWSModel(@spr_UAFactory      ,race_buildings[r_uac ] +'u_b11_',smt_buiding,firstload);
   _LoadMWSModel(@spr_UFactory       ,race_buildings[r_uac ] +'u_b12_',smt_buiding,firstload);
   _LoadMWSModel(@spr_Mine           ,race_buildings[r_uac ] +'u_mine',smt_buiding,firstload);

   _LoadMWSModel(@spr_db_h0          ,race_dir[r_hell]+'db_h0'        ,smt_effect ,firstload);
   _LoadMWSModel(@spr_db_h1          ,race_dir[r_hell]+'db_h1'        ,smt_effect ,firstload);
   _LoadMWSModel(@spr_db_u0          ,race_dir[r_uac ]+'db_u0'        ,smt_effect ,firstload);
   _LoadMWSModel(@spr_db_u1          ,race_dir[r_uac ]+'db_u1'        ,smt_effect ,firstload);

   _LoadMWSModel(@spr_h_p0           ,race_missiles[r_hell]+'h_p0_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_h_p1           ,race_missiles[r_hell]+'h_p1_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_h_p2           ,race_missiles[r_hell]+'h_p2_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_h_p3           ,race_missiles[r_hell]+'h_p3_'   ,smt_missile,firstload);
   _LoadMWSModel(@spr_h_p4           ,race_missiles[r_hell]+'h_p4_'   ,smt_missile,firstload);
   _LoadMWSModel(@spr_h_p5           ,race_missiles[r_hell]+'h_p5_'   ,smt_missile,firstload);
   _LoadMWSModel(@spr_h_p6           ,race_missiles[r_hell]+'h_p6_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_h_p7           ,race_missiles[r_hell]+'h_p7_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_u_p0           ,race_missiles[r_uac ]+'u_p0_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_u_p1           ,race_missiles[r_uac ]+'u_p1_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_u_p2           ,race_missiles[r_uac ]+'u_p2_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_u_p3           ,race_missiles[r_uac ]+'u_p3_'   ,smt_effect ,firstload);
   _LoadMWSModel(@spr_u_p8           ,race_missiles[r_uac ]+'u_p8_'   ,smt_missile,firstload);

   spr_u_p1s:=spr_u_p1;
   with spr_u_p1s do mkind:=smt_effect2;

   _LoadMWSModel(@spr_eff_bfg        ,effects_folder+'ef_bfg_'        ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_eb         ,effects_folder+'ef_eb'          ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_ebb        ,effects_folder+'ef_ebb'         ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_gtel       ,effects_folder+'ef_gt_'         ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_tel        ,effects_folder+'ef_tel_'        ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_exp        ,effects_folder+'ef_exp_'        ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_exp2       ,effects_folder+'exp2_'          ,smt_effect ,firstload);
   _LoadMWSModel(@spr_eff_g          ,effects_folder+'g_'             ,smt_effect ,firstload);
   _LoadMWSModel(@spr_blood          ,effects_folder+'blood'          ,smt_effect ,firstload);

   _lstr(@spr_mp[r_hell],race_dir[r_hell]+'h_mp',firstload,true);
   _lstr(@spr_mp[r_uac ],race_dir[r_uac ]+'u_mp',firstload,true);
   _lstr(@spr_ptur      ,race_dir[r_uac ]+'ptur',firstload,true);

   _lstr(@spr_b4_a      ,race_buildings[r_uac ]+'u_b4_a',firstload,true);
   _lstr(@spr_b7_a      ,race_buildings[r_uac ]+'u_b7_a',firstload,true);
   _lstr(@spr_b9_a      ,race_buildings[r_uac ]+'u_b9_a',firstload,true);

   _lstr(@spr_stun      ,effects_folder+'stun'   ,firstload,true);
   _lstr(@spr_invuln    ,effects_folder+'invuln' ,firstload,true);
   _lstr(@spr_hvision   ,effects_folder+'hvision',firstload,true);
   _lstr(@spr_scan      ,effects_folder+'scan'   ,firstload,true);
   _lstr(@spr_decay     ,effects_folder+'decay'  ,firstload,true);

   _lstr(@spr_cp_out    ,'cp_out',firstload,true);
   _lstr(@spr_cp_gen    ,'cp_gen',firstload,true);

   for x:=0 to spr_upgrade_icons do
   for r:=1 to r_cnt do
   with spr_b_up[r,x] do
   begin
      surf:= LoadBtn(race_upgrades[r]+'b_up'+b2s(x),vid_bw);
      w   := surf^.w;h    := w;
      hw  := w div 2;hh   := hw;
   end;

   initEffects;
   InitThemes;
end;


procedure MakeUnitIcons;
var u:byte;
begin
   for u:=0 to 255 do
   with _uids[u] do
   begin
      with un_btn do
      begin
         case _urace of
         r_hell: surf:= LoadBtnFS(_uid2spr(u,315,0)^.surf,vid_BW );
         r_uac : surf:= LoadBtnFS(_uid2spr(u,225,0)^.surf,vid_BW );
         end;
         w   := surf^.w;h := w;
         hw  := w div 2;hh:= hw;
      end;
      with un_sbtn do
      begin
         case _urace of
         r_hell: surf:= LoadBtnFS(_uid2spr(u,315,0)^.surf,vid_oiw );
         r_uac : surf:= LoadBtnFS(_uid2spr(u,225,0)^.surf,vid_oiw );
         end;
         w   := surf^.w;h := w;
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
   iy:=(map_iseed*5+ix)  mod vid_mha;
   rn:=ix*iy;
   for i:=1 to _tdecaln do
    with _tdecals[i-1] do
    begin
       rn+=17;
       ix:=_randomx(ix+rn       ,vid_mwa);
       iy:=_randomx(iy+sqr(ix*i),vid_mha);
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
   ui_hinty1    := vid_mapy+vid_cam_h-(font_w+3)*6;
   ui_hinty2    := vid_mapy+vid_cam_h-(font_w+3)*2;
   ui_chaty     := ui_hinty1-14;
   ui_logy      := ui_chaty-12;
   ui_oicox     := vid_mapx+vid_cam_w-4;
   ui_uiuphx    := vid_mapx+(vid_cam_w div 2);
   ui_uiuphy    := ui_texty+font_6hw;
   ui_uiplayery := ui_uiuphy+font_3hw;
   ui_game_log_height:=(ui_hinty1-60) div 12;

   ui_energx    := ui_uiuphx-150;
   ui_energy    := ui_texty;
   ui_armyx     := ui_uiuphx+40;
   ui_armyy     := ui_texty;
   ui_fpsx      := vid_mapx+vid_cam_w-(font_w*12);
   ui_fpsy      := ui_texty;
   ui_apmx      := ui_fpsx;
   ui_apmy      := ui_fpsy+font_w+txt_line_h;


   ui_menu_btnsy:= max2(12,(vid_vh div vid_BW)-1);
   ui_ingamecl  :=(vid_cam_w-font_w) div font_w;
   if(spr_mback<>nil)then
   begin
      mv_x      :=(vid_vw-spr_mback^.w) div 2;
      mv_y      :=(vid_vh-spr_mback^.h) div 2;
   end;
   vid_fog_vfw  :=(vid_cam_w div fog_cw)+2;
   vid_fog_vfh  :=(vid_cam_h div fog_cw)+2;

   map_mmvw     := round(vid_cam_w*map_mmcx);
   map_mmvh     := round(vid_cam_h*map_mmcx);
   CamBounds;

   Map_tdmake;
end;

procedure _ScreenSurfaces;
const
  ystop = 16;
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
      vid_cam_w:=vid_vw-vid_panelw;
      vid_cam_h:=vid_vh;

      if(vid_ppos=0)
      then vid_mapx:=vid_panelw
      else vid_mapx:=0;
      vid_mapy:=0;

      if(vid_ppos=0)
      then vid_panelx:=0
      else vid_panelx:=vid_cam_w;
      vid_panely:=0;

      r_uipanel:=_createSurf(vid_panelw+1,vid_vh);
      r_panel  :=_createSurf(vid_panelw+1,vid_vh);

      y:=vid_BW*ystop;
      vlineColor(r_panel,vid_BW ,vid_panelw+vid_BW,y,c_white);
      vlineColor(r_panel,vid_2BW,vid_panelw+vid_BW,y,c_white);
   end
   else
   begin
      vid_cam_w:=vid_vw;
      vid_cam_h:=vid_vh-vid_panelw;

      vid_mapx:=0;
      if(vid_ppos=2)
      then vid_mapy:=vid_panelw-1
      else vid_mapy:=0;

      vid_panelx:=0;
      if(vid_ppos=2)
      then vid_panely:=0
      else vid_panely:=vid_cam_h-1;

      r_uipanel:=_createSurf(vid_cam_w,vid_panelw+1);
      r_panel  :=_createSurf(vid_cam_w,vid_panelw+1);

      y:=vid_BW*ystop;
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_BW ,c_white);
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_2BW,c_white);
   end;

   rectangleColor(r_panel,0,0,r_panel^.w-1,r_panel^.h-1,c_white);
   pline(0,vid_panelw,vid_panelw,vid_panelw,c_white);

   //pline(0,vid_panelw+ui_h3bw,r_panel^.w,vid_panelw+ui_h3bw,c_white);
   pline(0,vid_panelw+vid_BW ,r_panel^.w,vid_panelw+vid_BW ,c_white);

   for y:=0 to 3 do
   pline(y*vid_tBW,vid_panelw,y*vid_tBW,vid_panelw+vid_BW,c_white);

   i:=4;
   y:=vid_BW*i;
   while (i<=ystop) do
   begin
      pline(0,y,vid_panelw,y,c_white);
      i+=1;
      y+=vid_BW;
   end;

   _draw_surf(r_uipanel,0,0,r_panel);

   r_dterrain:=_createSurf(vid_cam_w,vid_cam_h);

   _vidvars;
end;

procedure _MakeScreen;
begin
   if (r_screen<>nil) then sdl_freesurface(r_screen);

   if(vid_fullscreen)
   then r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, r_vflags + SDL_FULLSCREEN)
   else r_screen:=SDL_SetVideoMode( vid_vw, vid_vh, vid_bpp, r_vflags);

   if(r_screen=nil)then begin WriteSDLError; exit; end;

   _ScreenSurfaces;
end;


