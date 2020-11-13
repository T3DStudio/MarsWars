
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

function _loadsrf(fn:string):pSDL_SURFACE;
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

function loadIMG(fn:string;trns,log:boolean):pSDL_SURFACE;
begin
   loadIMG:=_loadsrf(str_folder_gr+fn+'.png');

   if(loadIMG=r_empty)then loadIMG:=_loadsrf(str_folder_gr+fn+'.jpg');
   if(loadIMG=r_empty)then loadIMG:=_loadsrf(str_folder_gr+fn+'.bmp');
   if(loadIMG=r_empty)and(log)then WriteLog(str_folder_gr+fn);

   if(trns)and(loadIMG<>r_empty)then SDL_SetColorKey(loadIMG,SDL_SRCCOLORKEY+SDL_RLEACCEL, sdl_getpixel(loadIMG,0,0));
end;

procedure _FreeSF(sf:PSDL_Surface);
begin
   if(sf<>nil)and(sf<>r_empty)then
   begin
      sdl_FreeSurface(sf);
      sf:=nil;
   end;
end;

procedure MakeLiquid;
var ts:psdl_surface;
x,y,l,p,ir,lr,ld:integer;
fn:string;
begin
   if(map_plqt=map_lqt)and(map_plqt<255)then exit;
   map_plqt:=map_lqt;

   map_mm_liqc:=c_gray;
   if(map_lqt=0)then map_mm_liqc:=c_dblue;
   if(map_lqt=1)then map_mm_liqc:=c_green;
   if(map_lqt=2)then map_mm_liqc:=c_brown;
   if(map_lqt=3)then map_mm_liqc:=c_dred;
   if(map_lqt=4)then map_mm_liqc:=c_lava;

   fn:='liquid_'+b2s(map_lqt);
   ts:=loadIMG(fn,false,false);

   for ir:=1 to 4 do
   begin
      lr:=DID_R[ir];
      ld:=lr*2;

      for l :=1 to LiquidAnim do
       with spr_liquid[l,ir-1] do
       begin
          if(surf<>nil) then
          begin
             sdl_freesurface(surf);
             surf:=nil;
          end;
          surf:=_createSurf(ld,ld);

          x:=-l*(ts^.w div 4);
          while (x<ld) do
          begin
             y:=-l*(ts^.h div 4);
             while (y<ld) do
             begin
                _draw_surf(surf,x,y,ts);
                inc(y,ts^.h);
             end;
             inc(x,ts^.w);
          end;

          x:=0;
          y:=1200 div ld;
          while (x<360) do
          begin
             p:=5+random(lr div 10);
             inc(x,y);
             filledcircleColor(
             surf,
             lr+trunc(lr*1.05*cos(x*degtorad)),
             lr+trunc(lr*1.05*sin(x*degtorad)),
             p,c_black);
          end;

          x:=0;
          while (x<360) do
          begin
             p:=lr-5;
             inc(x,3);
             y:=trunc(ld*sin(x*degtorad));
             inc(y,lr+5);
             filledcircleColor(surf,
             lr+trunc(ld*cos(x*degtorad)),
             y,
             p,c_black);
          end;

          SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));

          hw:=lr;
          hh:=lr;
       end;
   end;
   sdl_freesurface(ts);
end;

procedure MakeCrater;
var x,y,i,crater_d,
    p,e:integer;
    clr:cardinal;
    fn :shortstring;
    ts :pSDL_Surface;
begin
   if(map_pcrt=map_crt)and(map_pcrt<255)then exit;
   map_pcrt:=map_crt;

   if(map_hell)
   then clr:=rgba2c(80 ,0,0,128)
   else clr:=rgba2c(0  ,0,0,128);

   fn:='ter'+b2s(map_crt);
   ts:=loadIMG(fn,false,false);

   for i:=1 to crater_ri do
   with spr_crater[i] do
   begin
      crater_d:=crater_r[i]*2;
      if(surf<>nil) then
      begin
         sdl_freesurface(surf);
         surf:=nil;
      end;
      surf:=_createSurf(crater_d,crater_d);

      x:=0;
      while (x<crater_d) do
      begin
         y:=0;
         while (y<crater_d) do
         begin
            _draw_surf(surf,x,y,ts);
            inc(y,ts^.h);
         end;
         inc(x,ts^.w);
      end;

      boxColor(surf,0,0,crater_d,crater_d,clr);

      x:=0;
      e:=crater_r[i] div 11;
      while (x<360) do
      begin
         p:=e+random(e);
         inc(x,15);
         filledcircleColor(surf,
         crater_r[i]+trunc(crater_r[i]*1.05*cos(x*degtorad)),
         crater_r[i]+trunc(crater_r[i]*1.05*sin(x*degtorad)),p,c_purple);
      end;

      x:=0;
      while (x<360) do
      begin
         p:=crater_r[i]-5;
         inc(x,3);
         filledcircleColor(surf,
         crater_r[i]+trunc(crater_d*cos(x*degtorad)),
         crater_r[i]+trunc(crater_d*sin(x*degtorad)),
         p,c_purple);
      end;

      SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));

      hw:=crater_r[i];
      hh:=crater_r[i];
   end;

   sdl_freesurface(ts);
end;

function _lstr(fn:string):TUSprite;
begin
   with _lstr do
   begin
      surf:=LoadIMG(fn,true,true);
      hw:=surf^.w div 2;
      hh:=surf^.h div 2;
   end;
end;

procedure MakeTerrain;
var x,y,w,h:integer;
    fn:string;
    ter_s:pSDL_Surface;
begin
   MakeCrater;

   if(map_ptrt=map_trt)and(map_ptrt<255)then exit;
   map_ptrt:=map_trt;

   if(vid_terrain<>nil) then
   begin
      sdl_freesurface(vid_terrain);
      vid_terrain:=nil;
   end;

   fn:='ter'+b2s(map_trt);
   ter_s:=loadIMG(fn,false,false);
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

   sdl_freesurface(ter_s);
end;

function _xasurf(s:PSDL_Surface;xa,ya,trans:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:cardinal;
begin
   _xasurf:=_createSurf(s^.w,s^.h);
   for x:=1 to s^.w do
    for y:=1 to s^.h do
    begin
       if(xa)then sx:=s^.w-x else sx:=x-1;
       if(ya)then sy:=s^.h-y else sy:=y-1;
       c:=SDL_GETpixel(s,x-1,y-1);

       SDL_SETpixel(_xasurf,sx,sy,c);
    end;
   if(trans)then SDL_SetColorKey(_xasurf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(_xasurf,0,0));
end;

procedure LPTUSpriteL(l:PTUSpriteL;str:shortstring;it:pinteger);
var i:byte;
    t:TUSprite;
begin
   it^ :=0;
   for i:=1 to 255 do
   begin
      with t do
      begin
         surf:=LoadIMG(str+b2s(i),true,false);
         hw  :=surf^.w div 2;
         hh  :=surf^.h div 2;
      end;
      if(t.hw=0)then break;
      inc(it^,1);
      setlength(l^,it^);
      l^[it^-1]:=t;

      with t do
      begin
         surf:=_xasurf(l^[it^-1].surf,true,false,false);
         SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,surf^.w-1,0));
      end;
      inc(it^,1);
      setlength(l^,it^);
      l^[it^-1]:=t;
   end;
end;

procedure LoadDecors;
begin
   LPTUSpriteL(@spr_tdecs   , 'adt'   , @spr_tdecsi  );
   LPTUSpriteL(@spr_decs    , 'dec_'  , @spr_decsi   );
   LPTUSpriteL(@spr_srocks  , 'rocks' , @spr_srocksi );
   LPTUSpriteL(@spr_brocks  , 'rockb' , @spr_brocksi );

   LPTUSpriteL(@spr_tdecsh  , 'adth'  , @spr_tdecshi );
   LPTUSpriteL(@spr_decsh   , 'dech_' , @spr_decshi  );
   LPTUSpriteL(@spr_srocksh , 'rocksh', @spr_srockshi);
   LPTUSpriteL(@spr_brocksh , 'rockbh', @spr_brockshi);

   t_decsi:=spr_tdecsi+crater_ri+1;
end;

function LoadBtn(fn:string;bw:integer):pSDL_Surface;
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

procedure LoadGraphics;
var x:integer;
begin
   r_empty   :=_createSurf(1,1);
   r_minimap :=_createSurf(vid_panelw-1,vid_panelw-1);
   r_bminimap:=_createSurf(vid_panelw-1,vid_panelw-1);

   ui_muc    [false]:=c_dorange;
   ui_muc    [true ]:=c_gray;

   ui_rad_rld[false]:=c_aqua;
   ui_rad_rld[true ]:=c_yellow;

   spr_dummy.hh  :=1;
   spr_dummy.hw  :=1;
   spr_dummy.surf:=r_empty;

   LoadFont;

   fog_surf := _createSurf(fog_cr*2,fog_cr*2);
   boxColor(fog_surf,0,0,fog_surf^.w,fog_surf^.h,c_purple);
   filledcircleColor(fog_surf,fog_cr,fog_cr,fog_cr,c_black);
   SDL_SetColorKey(fog_surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,SDL_GETpixel(fog_surf,0,0));

   spr_mback:= loadIMG('mback'   ,false,true);

   r_menu:=_createSurf(spr_mback^.w,spr_mback^.h);

   mv_x:=(vid_vw-spr_mback^.w) div 2;
   mv_y:=(vid_vh-spr_mback^.h) div 2;

   spr_cursor     := loadIMG('cursor'   ,true ,true);

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

   spr_c_earth    := LoadIMG('M_EARTH'  ,false,true);
   spr_c_mars     := LoadIMG('M_MARS'   ,false,true);
   spr_c_hell     := LoadIMG('M_HELL'   ,false,true);
   spr_c_phobos   := LoadIMG('M_PHOBOS' ,false,true);
   spr_c_deimos   := LoadIMG('M_DEIMOS' ,false,true);

   for x:=0 to 2 do spr_tabs[x]:=LoadBtn('tabs'+b2s(x),vid_tbw);
   spr_tabs[3]:=LoadBtnFS(spr_b_action,vid_tbw);

   for x:=0 to MaxUpgrs do
   begin
      spr_b_up[r_hell,x]:=LoadBtn('b_h_up'+b2s(x),vid_bw);
      spr_b_up[r_uac ,x]:=LoadBtn('b_u_up'+b2s(x),vid_bw);
   end;

   spr_u_portal   := _lstr('u_portal');
   spr_db_h0      := _lstr('db_h0');
   spr_db_h1      := _lstr('db_h1');
   spr_db_u0      := _lstr('db_u0');
   spr_db_u1      := _lstr('db_u1');
   spr_HAltar     := _lstr('h_altar');
   spr_HTotem     := _lstr('h_b7');
   spr_HMonastery := _lstr('h_b6');
   spr_HFortress  := _lstr('h_fortess');
   spr_HBar       := _lstr('h_hbarrak');
   spr_HEye       := _lstr('heye');
   spr_mine       := _lstr('u_mine');
   spr_toxin      := _lstr('toxin');
   spr_gear       := _lstr('gear');

   spr_mp[r_hell] := _lstr('h_mp');
   spr_mp[r_uac ] := _lstr('u_mp');

   for x:=0 to 3  do spr_eff_bfg    [x]:=_lstr('ef_bfg_'+b2s(x));
   for x:=0 to 5  do spr_eff_eb     [x]:=_lstr('ef_eb'  +b2s(x));
   for x:=0 to 8  do spr_eff_ebb    [x]:=_lstr('ef_ebb' +b2s(x));
   for x:=0 to 5  do spr_eff_tel    [x]:=_lstr('ef_tel_'+b2s(x));
   for x:=0 to 2  do spr_eff_exp    [x]:=_lstr('ef_exp_'+b2s(x));
   for x:=0 to 4  do spr_eff_exp2   [x]:=_lstr('exp2_'  +b2s(x));
   for x:=0 to 7  do spr_eff_g      [x]:=_lstr('g_'     +b2s(x));
   for x:=0 to 3  do spr_h_p0       [x]:=_lstr('h_p0_'  +b2s(x));
   for x:=0 to 3  do spr_h_p1       [x]:=_lstr('h_p1_'  +b2s(x));
   for x:=0 to 3  do spr_h_p2       [x]:=_lstr('h_p2_'  +b2s(x));
   for x:=0 to 7  do spr_h_p3       [x]:=_lstr('h_p3_'  +b2s(x));
   for x:=0 to 10 do spr_h_p4       [x]:=_lstr('h_p4_'  +b2s(x));
   for x:=0 to 7  do spr_h_p5       [x]:=_lstr('h_p5_'  +b2s(x));
   for x:=0 to 7  do spr_h_p6       [x]:=_lstr('h_p6_'  +b2s(x));
   for x:=0 to 5  do spr_h_p7       [x]:=_lstr('h_p7_'  +b2s(x));
   for x:=0 to 5  do spr_u_p0       [x]:=_lstr('u_p0_'  +b2s(x));
   for x:=0 to 3  do spr_u_p1       [x]:=_lstr('u_p1_'  +b2s(x));
   for x:=0 to 5  do spr_u_p2       [x]:=_lstr('u_p2_'  +b2s(x));
   for x:=0 to 3  do spr_u_p3       [x]:=_lstr('u_p3_'  +b2s(x));

   for x:=0 to 2  do spr_blood      [x]:=_lstr('blood'  +b2s(x));

   for x:=0 to 28 do spr_lostsoul   [x]:=_lstr('h_u0_'  +b2s(x));
   for x:=0 to 52 do spr_imp        [x]:=_lstr('h_u1_'  +b2s(x));
   for x:=0 to 53 do spr_demon      [x]:=_lstr('h_u2_'  +b2s(x));
   for x:=0 to 29 do spr_cacodemon  [x]:=_lstr('h_u3_'  +b2s(x));
   for x:=0 to 52 do spr_baron      [x]:=_lstr('h_u4_'  +b2s(x));
   for x:=0 to 52 do spr_knight     [x]:=_lstr('h_u4k_' +b2s(x));
   for x:=0 to 56 do spr_cyberdemon [x]:=_lstr('h_u5_'  +b2s(x));
   for x:=0 to 81 do spr_mastermind [x]:=_lstr('h_u6_'  +b2s(x));
   for x:=0 to 37 do spr_pain       [x]:=_lstr('h_u7_'  +b2s(x));
   for x:=0 to 76 do spr_revenant   [x]:=_lstr('h_u8_'  +b2s(x));
   for x:=0 to 78 do spr_mancubus   [x]:=_lstr('h_u9_'  +b2s(x));
   for x:=0 to 69 do spr_arachnotron[x]:=_lstr('h_u10_' +b2s(x));
   for x:=0 to 85 do spr_archvile   [x]:=_lstr('h_u11_' +b2s(x));

   for x:=0 to 52 do spr_ZFormer    [x]:=_lstr('h_z0_'  +b2s(x));
   for x:=0 to 31 do spr_ZEngineer  [x]:=_lstr('h_z0s_' +b2s(x));
   for x:=0 to 52 do spr_ZSergant   [x]:=_lstr('h_z1_'  +b2s(x));
   for x:=0 to 52 do spr_ZSSergant  [x]:=_lstr('h_z1s_' +b2s(x));
   for x:=0 to 59 do spr_ZCommando  [x]:=_lstr('h_z2_'  +b2s(x));
   for x:=0 to 52 do spr_ZBomber    [x]:=_lstr('h_z3_'  +b2s(x));
   for x:=0 to 15 do spr_ZFMajor    [x]:=_lstr('h_z4j_' +b2s(x));
   for x:=0 to 52 do spr_ZMajor     [x]:=_lstr('h_z4_'  +b2s(x));
   for x:=0 to 52 do spr_ZBFG       [x]:=_lstr('h_z5_'  +b2s(x));

   for x:=0 to 44 do spr_engineer   [x]:=_lstr('u_u1_'  +b2s(x));
   for x:=0 to 52 do spr_medic      [x]:=_lstr('u_u0_'  +b2s(x));
   for x:=0 to 44 do spr_sergant    [x]:=_lstr('u_u2_'  +b2s(x));
   for x:=0 to 44 do spr_ssergant   [x]:=_lstr('u_u2s_' +b2s(x));
   for x:=0 to 52 do spr_commando   [x]:=_lstr('u_u3_'  +b2s(x));
   for x:=0 to 44 do spr_bomber     [x]:=_lstr('u_u4_'  +b2s(x));
   for x:=0 to 15 do spr_fmajor     [x]:=_lstr('u_u5j_' +b2s(x));
   for x:=0 to 44 do spr_major      [x]:=_lstr('u_u5_'  +b2s(x));
   for x:=0 to 44 do spr_BFG        [x]:=_lstr('u_u6_'  +b2s(x));
   for x:=0 to 15 do spr_FAPC       [x]:=_lstr('u_u8_'  +b2s(x));
   for x:=0 to 15 do spr_APC        [x]:=_lstr('uac_tank_' +b2s(x));
   for x:=0 to 55 do spr_Terminator [x]:=_lstr('u_u9_'  +b2s(x));
   for x:=0 to 23 do spr_Tank       [x]:=_lstr('u_u10_' +b2s(x));
   for x:=0 to 15 do spr_Flyer      [x]:=_lstr('u_u11_' +b2s(x));

   for x:=0 to 15 do spr_tur        [x]:=_lstr('ut_'    +b2s(x));
   for x:=0 to 7  do spr_rtur       [x]:=_lstr('u_rt_'  +b2s(x));

   for x:=0 to 7  do spr_trans      [x]:=_lstr('transport'+b2s(x));

   for x:=0 to 1  do spr_sport      [x]:=_lstr('sport'  +b2s(x));

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

   for x:=0 to 5 do spr_ubase[x]:=_lstr('u_base' +b2s(x));


   for x:=0 to _uts do
   begin
      spr_b_b[r_hell,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,true ,x]])^.surf,vid_BW);
      spr_ui_oico[r_hell,true,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,true ,x]])^.surf,vid_oiw);

      spr_b_b[r_uac ,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,true ,x]])^.surf,vid_BW);
      spr_ui_oico[r_uac ,true,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,true ,x]])^.surf,vid_oiw);
   end;

   _draw_surf(spr_b_b[r_uac ,4 ],vid_hBW-spr_tur [6].hw,0,spr_tur [4].surf);
   _draw_surf(spr_b_b[r_uac ,7 ],vid_hBW-spr_tur [7].hw,0,spr_tur [0].surf);
   _draw_surf(spr_b_b[r_uac ,10],vid_hBW-spr_rtur[7].hw,0,spr_rtur[6].surf);

   for x:=0 to _uts do
   begin
      with _ulst[cl2uid[r_hell,false,x]] do dir:=315;
      spr_b_u[r_hell,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,false,x]])^.surf,vid_BW);
      spr_ui_oico[r_hell,false,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_hell,false,x]])^.surf,vid_oiw);
      if(cl2uid[r_hell,false,x]=UID_Baron)then
      begin
         spr_b_knight  :=spr_b_u[r_hell,x];
         spr_iob_knight:=spr_ui_oico[r_hell,false,x];
         with _ulst[UID_Baron] do buff[ub_advanced]:=1;
         spr_b_baron   :=LoadBtnFS(_unit_spr(@_ulst[UID_Baron])^.surf,vid_BW );
         spr_iob_baron :=LoadBtnFS(_unit_spr(@_ulst[UID_Baron])^.surf,vid_oiw);
         with _ulst[UID_Baron] do buff[ub_advanced]:=0;
      end;

      with _ulst[cl2uid[r_uac ,false,x]] do dir:=225;
      spr_b_u[r_uac ,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,false,x]])^.surf,vid_BW);
      spr_ui_oico[r_uac ,false,x]:=LoadBtnFS(_unit_spr(@_ulst[cl2uid[r_uac ,false,x]])^.surf,vid_oiw);
   end;

   LoadDecors;
end;



procedure Map_tdmake;
var i,ix,iy,rn:integer;
begin
   MaxTDecsS:=(vid_sw*vid_sh) div 11000;
   setlength(_TDecs,MaxTDecsS);

   vid_mwa:= vid_sw+vid_ab*2;
   vid_mha:= vid_sh+vid_ab*2;

   ix:=longint(map_seed) mod vid_mwa;
   iy:=(map_seed2*5+ix) mod vid_mwa;
   rn:=ix*iy;
   for i:=1 to MaxTDecsS do
   with _TDecs[i-1] do
   begin
      inc(rn,17);
      ix:=_genx(ix+rn,vid_mwa,false);
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

   ui_uiuphx   := vid_mapx+(vid_sw div 2);

   ui_ingamecl:=(vid_sw-font_w) div font_w;
   if(spr_mback<>nil)then
   begin
      mv_x:=(vid_vw-spr_mback^.w) div 2;
      mv_y:=(vid_vh-spr_mback^.h) div 2;
   end;
   fog_vfw   :=(vid_sw div fog_cw)+2;
   fog_vfh   :=(vid_sh div fog_cw)+2;

   map_mmvw    := round(vid_sw*map_mmcx);
   map_mmvh    := round(vid_sh*map_mmcx);
   _view_bounds;

   Map_tdmake;
end;

procedure _ScreenSurfaces;
const
  ui_ex = 3;
  ui_ax = ui_ex+vid_BW;
  ystop = 14;
var i,y:integer;
begin
   if(r_uipanel<>nil)then sdl_freesurface(r_uipanel);
   if(r_panel  <>nil)then sdl_freesurface(r_panel  );

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

      vlineColor(r_panel,0             ,0         ,vid_vh            ,c_white);
      vlineColor(r_panel,vid_panelw    ,0         ,vid_vh            ,c_white);

      hlineColor(r_panel,0,r_panel^.w,0                 ,c_white);
      hlineColor(r_panel,0,r_panel^.w,vid_panelw        ,c_white);
      hlineColor(r_panel,0,r_panel^.w,vid_panelw+ui_h3bw,c_white);
      hlineColor(r_panel,0,r_panel^.w,vid_panelw+vid_BW ,c_white);

      vlineColor(r_panel,ui_h3bw       ,vid_panelw,vid_panelw+ui_h3bw,c_white);
      vlineColor(r_panel,ui_hwp        ,vid_panelw,vid_panelw+ui_h3bw,c_white);
      vlineColor(r_panel,ui_hwp+ui_h3bw,vid_panelw,vid_panelw+ui_h3bw,c_white);

      for y:=0 to 3 do
       vlineColor(r_panel,y*vid_tBW,vid_panelw+ui_h3bw,vid_panelw+vid_BW,c_white);

      y:=vid_BW*14;
      vlineColor(r_panel,vid_BW ,vid_panelw+vid_BW,y,c_white);
      vlineColor(r_panel,vid_2BW,vid_panelw+vid_BW,y,c_white);

      ui_iy     := vid_panelw+3;
      ui_energx := (ui_hwp+ui_h3bw) div 2;
      ui_armyx  := (ui_hwp+ui_h3bw+vid_panelw) div 2;

      characterColor(r_panel,ui_ex,ui_iy,'E',c_aqua  );
      characterColor(r_panel,ui_ax,ui_iy,'A',c_orange);

      i:=4;
      y:=vid_BW*i;
      while (i<=ystop) do
      begin
         hlineColor(r_panel,0,vid_panelw,y,c_white);
         inc(i,1);
         inc(y,vid_BW);
      end;
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
      else vid_panely:=vid_sh;

      r_uipanel:=_createSurf(vid_sw,vid_panelw+1);
      r_panel  :=_createSurf(vid_sw,vid_panelw+1);

      hlineColor(r_panel,0         ,vid_vw            ,0             ,c_white);
      hlineColor(r_panel,0         ,vid_vw            ,vid_panelw    ,c_white);

      vlineColor(r_panel,0                 ,0,r_panel^.w,c_white);
      vlineColor(r_panel,vid_panelw        ,0,r_panel^.w,c_white);

      vlineColor(r_panel,vid_panelw+ui_h3bw,0,r_panel^.w,c_white);
      vlineColor(r_panel,vid_panelw+vid_BW ,0,r_panel^.w,c_white);

      for y:=0 to 3 do
      hlineColor(r_panel,vid_panelw+ui_h3bw,vid_panelw+vid_BW,y*vid_tBW,c_white);

      y:=vid_BW*14;
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_BW ,c_white);
      hlineColor(r_panel,vid_panelw+vid_BW,y,vid_2BW,c_white);

      //vlineColor(r_panel,y+ui_h3bw       ,0,ui_h3bw,c_white);
      //vlineColor(r_panel,y+ui_hwp        ,0,ui_h3bw,c_white);
      //vlineColor(r_panel,y+ui_hwp+ui_h3bw,0,ui_h3bw,c_white);
      vlineColor(r_panel,y+vid_BW  ,0,vid_BW,c_white);
      vlineColor(r_panel,y+vid_BW*2,0,vid_BW,c_white);
      vlineColor(r_panel,y+vid_BW*3,0,vid_BW,c_white);
      hlineColor(r_panel,y+vid_BW  ,y+vid_BW*3,vid_BW  ,c_white);

      ui_iy     := 3;
      ui_energx := y+vid_BW+vid_hBW+2;
      ui_armyx  := y+vid_BW*2+vid_hBW;

      inc(y,vid_BW);
      characterColor(r_panel,y+ui_ex-1,ui_iy,'E',c_aqua  );
      characterColor(r_panel,y+ui_ax+1,ui_iy,'A',c_orange);

      ui_iy := 23;

      i:=4;
      y:=vid_BW*i;
      while (i<=ystop) do
      begin
         vlineColor(r_panel,y,0,vid_panelw,c_white);
         inc(i,1);
         inc(y,vid_BW);
      end;
   end;

   _draw_surf(r_uipanel,0,0,r_panel);

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


