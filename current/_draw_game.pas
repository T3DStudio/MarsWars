

////////////////////////////////////////////////////////////////////////////////
//
//  SpriteList
//

const TVisSprSize =  SizeOf(TVisSpr);

var slatemp : PTVisSpr;

function SpriteListAdd:PTVisSpr;
begin
   SpriteListAdd:=nil;
   if(vid_vsls<vid_mvs)and(_menu=false)then
   begin
      vid_vsls+=1;
      SpriteListAdd:=vid_vsl[vid_vsls];
      FillChar(SpriteListAdd^,TVisSprSize,0);
      with vid_vsl[vid_vsls]^ do
      begin
         alpha:=255;
      end;
   end;
end;

procedure SpriteListAddUnit(ax,ay,adepth,ashadowz:integer;ashadowc,aaura:cardinal;aspr:PTMWTexture;aalpha:byte);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
    with slatemp^ do
    begin
       x      := ax-vid_cam_x;
       y      := ay-vid_cam_y;
       depth  := adepth;
       shadowz:= ashadowz;
       shadowc:= ashadowc;
       sprite := aspr;
       aura   := aaura;
       alpha  := aalpha;
    end;
end;
procedure SpriteListAddDoodad(ax,ay,adepth,ashadowz:integer;aspr:PTMWTexture;aalpha:byte;axo,ayo:integer);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
    with slatemp^ do
    begin
       x      := ax-vid_cam_x;
       y      := ay-vid_cam_y;
       depth  := adepth;
       shadowz:= ashadowz;
       shadowc:= c_ablack;
       sprite := aspr;
       alpha  := aalpha;
       xo     := axo;
       yo     := ayo;
    end;
end;
procedure SpriteListAddMarker(ax,ay:integer;aspr:PTMWTexture);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
    with slatemp^ do
    begin
       x      := ax-vid_cam_x;
       y      := ay-vid_cam_y;
       depth  :=  sd_marker;
       shadowz:= -32000;
       sprite := aspr;
       alpha  := 255;
       yo     := -aspr^.hh;
    end;
end;
procedure SpriteListAddEffect(ax,ay,adepth:integer;aaura:cardinal;aspr:PTMWTexture;aalpha:byte);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
    with slatemp^ do
    begin
       x      := ax-vid_cam_x;
       y      := ay-vid_cam_y;
       depth  := adepth;
       shadowz:= -32000;
       sprite := aspr;
       aura   := aaura;
       alpha  := aalpha;
    end;
end;

procedure SpriteListSort;
var i,u:word;
    dt :PTVisSpr;
begin
   if(vid_vsls>1)then
    for i:=1 to vid_vsls do
     for u:=1 to (vid_vsls-1) do
      if(vid_vsl[u]^.depth<vid_vsl[u+1]^.depth)then
      begin
        dt:=vid_vsl[u];
        vid_vsl[u]:=vid_vsl[u+1];
        vid_vsl[u+1]:=dt;
      end;
end;

procedure D_SpriteList(tar:pSDL_Surface;lx,ly:integer);
var sx,sy:integer;
begin
   SpriteListSort;
   while(vid_vsls>0)do
    with vid_vsl[vid_vsls]^ do
    begin
       vid_vsls-=1;

       x-=sprite^.hw;
       y-=sprite^.hh;

       x+=lx+xo;
       y+=ly+yo;

       if(shadowz>-fly_hz)then
       begin
          sx:=sprite^.hw;
          sy:=sprite^.h-(sprite^.h shr 3);
          filledellipseColor(tar,x+sx,y+sy+shadowz,sx,sprite^.hh shr 1,shadowc);
       end;
       if(alpha>0)then
        if(alpha=255)
        then _draw_surf(tar,x,y,sprite^.surf)
        else
        begin
           SDL_SetAlpha(sprite^.surf,SDL_SRCALPHA or SDL_RLEACCEL,alpha);
           _draw_surf(tar,x,y,sprite^.surf);
           SDL_SetAlpha(sprite^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);
        end;

       if(aura>0)then
       begin
          x-=6;
          y-=6;
          sx:=sprite^.hw+6;
          sy:=sprite^.hh+6;
          filledellipseColor(tar,x+sx,y+sy,sx,sy,aura);
       end;
    end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  UnitsInfo
//

const TVisPrimSize =  SizeOf(TVisPrim);

procedure UnitsInfoNew;
begin
   vid_prims+=1;
   setlength(vid_prim,vid_prims);
   FillChar(vid_prim[vid_prims-1],TVisPrimSize,0);
end;

procedure UnitsInfoAddLine(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind :=uinfo_line;
      x0   :=ax0;
      y0   :=ay0;
      x1   :=ax1;
      y1   :=ay1;
      color:=acolor;
   end;
end;
procedure UnitsInfoAddRect(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind :=uinfo_rect;
      x0   :=ax0;
      y0   :=ay0;
      x1   :=ax1;
      y1   :=ay1;
      color:=acolor;
   end;
end;
procedure UnitsInfoAddRectText(ax0,ay0,ax1,ay1:integer;acolor:cardinal;slt,slt2,srt,srd,sld:string6);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind :=uinfo_rect;
      x0   :=ax0;
      y0   :=ay0;
      x1   :=ax1;
      y1   :=ay1;
      color:=acolor;
      text_lt :=slt;
      text_lt2:=slt2;
      text_rt :=srt;
      text_rd :=srd;
      text_ld :=sld;
   end;
end;
procedure UnitsInfoAddBox(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind :=uinfo_box;
      x0   :=ax0;
      y0   :=ay0;
      x1   :=ax1;
      y1   :=ay1;
      color:=acolor;
   end;
end;
procedure UnitsInfoAddCircle(ax0,ay0,ar:integer;acolor:cardinal);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind :=uinfo_circle;
      x0   :=ax0;
      y0   :=ay0;
      x1   :=ar;
      color:=acolor;
   end;
end;
procedure UnitsInfoAddText(ax0,ay0:integer;text:string6;acolor:cardinal);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind   :=uinfo_text;
      x0     :=ax0;
      y0     :=ay0;
      text_lt:=text;
      color  :=acolor;
   end;
end;
procedure UnitsInfoAddUSprite(ax0,ay0:integer;acolor:cardinal;aspr:PTMWTexture;slt,slt2,srt,srd,sld:string6);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind    :=uinfo_rect;
      x0      :=ax0-aspr^.hw;
      y0      :=ay0-aspr^.hh;
      x1      :=x0+aspr^.w;
      y1      :=y0+aspr^.h;
      sprite  :=aspr;
      color   :=acolor;
      text_lt :=slt;
      text_lt2:=slt2;
      text_rt :=srt;
      text_rd :=srd;
      text_ld :=sld;
   end;
end;
procedure UnitsInfoAddSprite(ax0,ay0:integer;aspr:PTMWTexture);
begin
   UnitsInfoNew;
   with vid_prim[vid_prims-1] do
   begin
      kind   :=uinfo_sprite;
      x0     :=ax0-aspr^.hw;
      y0     :=ay0-aspr^.hh;
      sprite :=aspr;
   end;
end;

procedure UnitsInfoProgressbar(ax0,ay0,ax1,ay1:integer;per:single;acolor:cardinal);
var vx:integer;
begin
   if(per<0)then per:=0;
   if(per>1)then per:=1;

   if(per=0)
   then UnitsInfoAddBox(ax0,ay0,ax1,ay1,c_black)
   else
     if(per=1)
     then UnitsInfoAddBox(ax0,ay0,ax1,ay1,acolor)
     else
     begin
        vx:=trunc((ax1-ax0)*per);

        UnitsInfoAddBox(ax0   ,ay0,ax0+vx,ay1,acolor );
        UnitsInfoAddBox(ax0+vx,ay0,ax1   ,ay1,c_black);
     end;
end;

procedure UnitsInfoAddBuff(ax,ay:integer;pspr:PTMWTexture);
begin
   ay-=pspr^.hh;
   UnitsInfoAddSprite(ax,ay,pspr);
end;

function i2s6(i:integer):string6;
begin
   if(i>0)
   then i2s6:=i2s(i)
   else i2s6:='';
end;

procedure UnitsInfoAddUnit(pu:PTUnit;usmodel:PTMWSModel);
const buff_sprite_w = 18;
var srect,
choosen,
pain,
      hbar :boolean;
    acolor :cardinal;
   buffx,
   buffy   :integer;
begin
   with pu^   do
   with uid^  do
   with usmodel^ do
   begin
      acolor:=PlayerGetColor(playeri);

      choosen:=((ui_uhint=unum)or(ui_umark_u=unum))and(r_blink1_colorb);

      srect :=((sel)and(playeri=HPlayer))
            or(ks_alt>0)
            or(choosen);

      hbar  :=false;
      if(srect)
      then hbar:=true
      else
        case vid_uhbars of
      0: if(hits<_mhits)then hbar:=true;
      1: hbar:=true;
        end;

      if(srect)then
      begin
         if(playeri=HPlayer)
         then UnitsInfoAddRectText(vx-sel_hw,vy-sel_hh,vx+sel_hw,vy+sel_hh,acolor,i2s6(group),'',lvlstr_b,i2s6(apcm),i2s6(apcc))
         else UnitsInfoAddRectText(vx-sel_hw,vy-sel_hh,vx+sel_hw,vy+sel_hh,acolor,lvlstr_w   ,'',lvlstr_b,lvlstr_a  ,lvlstr_s  );
         UnitsInfoAddText(vx,vy-sel_hh-font_w,lvlstr_l,c_white);
      end;
      if(hbar )then UnitsInfoProgressbar(vx-sel_hw,vy-sel_hh-4,vx+sel_hw,vy-sel_hh,hits/_mhits,acolor);

      if(rld>0)and(playeri=HPlayer)then UnitsInfoAddText(vx,vy-sel_hh+font_w,lvlstr_r,c_aqua);

      if(speed<=0)or(not bld)then
       if(0<m_brush)and(m_brush<=255)then UnitsInfoAddCircle(x,y,_r,r_blink2_color_BY);

      if(srect)and(_ukbuilding)and(UIUnitDrawRange(pu))then UnitsInfoAddCircle(x,y,srange,r_blink2_color_BG);

      //ub_Scaned
      case r_blink3 of
      0: if(buff[ub_Scaned]>0)then UnitsInfoAddBuff(vx,vy,@spr_scan );
      1: if(buff[ub_Decay ]>0)then UnitsInfoAddBuff(vx,vy,@spr_decay);
      2:;
      end;

      pain:=(buff[ub_Pain]>0)and(_ukmech and not _ukbuilding);
      buffx:=0;
      if(buff[ub_HVision]>0)then buffx+=1;
      if(buff[ub_Invuln ]>0)then buffx+=1;
      if(pain              )then buffx+=1;

      if(buffx=0)then exit;

      buffx-=1;
      buffx:=vx-((buffx*buff_sprite_w) div 2);

      if(_ukbuilding)
      then buffy:=vy
      else buffy:=vy-sel_hh-font_w;

      if(buff[ub_HVision]>0)then begin UnitsInfoAddBuff(buffx,buffy,@spr_hvision);buffx+=buff_sprite_w;end;
      if(buff[ub_Invuln ]>0)then begin UnitsInfoAddBuff(buffx,buffy,@spr_invuln );buffx+=buff_sprite_w;end;
      if(pain              )then begin UnitsInfoAddBuff(buffx,buffy,@spr_stun   );buffx+=buff_sprite_w;end;
   end;
end;

procedure D_UnitsInfo(tar:pSDL_Surface;lx,ly:integer);
var t:integer;
begin
   case g_mode of
gm_royale: circleColor(tar,lx+map_hmw-vid_cam_x,ly+map_hmw-vid_cam_y,g_royal_r,ui_max_color[(g_royal_r mod 2)=0]);
   end;


   while(vid_prims>0)do
    with vid_prim[vid_prims-1] do
    begin
       vid_prims-=1;

       x0+=lx-vid_cam_x;
       y0+=ly-vid_cam_y;
       if(kind=uinfo_rect)
       or(kind=uinfo_box)
       or(kind=uinfo_line)then
       begin
          x1+=lx-vid_cam_x;
          y1+=ly-vid_cam_y;
          if(kind<>uinfo_line)then
          begin
          if(x0>x1)then begin t:=x0;x0:=x1;x1:=t;end;
          if(y0>y1)then begin t:=y0;y0:=y1;y1:=t;end;
          end;
       end;

       if(sprite<>nil)then
        with sprite^ do _draw_surf(tar,x0,y0,surf);

       if(kind=uinfo_sprite)then continue;

       if(color>0)then
        case kind of
uinfo_line   : lineColor     (tar,x0,y0,x1,y1,color);
uinfo_rect   : rectangleColor(tar,x0,y0,x1,y1,color);
uinfo_box    : boxColor      (tar,x0,y0,x1,y1,color);
uinfo_circle : circleColor   (tar,x0,y0,x1,   color);
uinfo_text   : begin
               _draw_text(tar,x0,y0-font_hw,text_lt,ta_middle,255,color);
               continue;
               end;
        else
        end;

       if(length(text_lt )>0)then _draw_text(tar,x0+1,y0+1       ,text_lt ,ta_left ,255,c_white);
       if(length(text_lt2)>0)then _draw_text(tar,x0+1,y0+font_w+4,text_lt2,ta_left ,255,c_white);
       if(length(text_rt )>0)then _draw_text(tar,x1-1,y0+1       ,text_rt ,ta_right,255,c_white);
       if(length(text_rd )>0)then _draw_text(tar,x1-1,y1-1-font_w,text_rd ,ta_right,255,c_white);
       if(length(text_ld )>0)then _draw_text(tar,x0+1,y1-1-font_w,text_ld ,ta_left ,255,c_white);
    end;
   setlength(vid_prim,vid_prims);
end;

////////////////////////////////////////////////////////////////////////////////
//
//  Terrain
//

procedure D_terrain(tar:pSDL_Surface;lx,ly:integer);
var i,t,
  ix,iy,s:integer;
    vx,vy:integer;
    spr  :PTMWTexture;
begin
   _draw_surf(tar,
   lx-vid_cam_x mod ter_w,
   ly-vid_cam_y mod ter_h,
   vid_terrain);

   vx:=vid_cam_x-vid_ab;
   vy:=vid_cam_y-vid_ab;

   if(theme_decaln>0)then
    for i:=1 to _tdecaln do
     with _tdecals[i-1] do
     begin
        ix:=x-vx+vid_mwa;
        iy:=y-vy+vid_mha;

        s:=abs(i+(iy div vid_mha)+(ix div vid_mwa)) mod theme_decaln;

        t:=theme_decals[s];
        if(t<0)
        then spr:=@spr_crater[-t]
        else spr:=@theme_spr_decals[t];

        ix:=ix mod vid_mwa;
        iy:=iy mod vid_mha;

        if(ix<0)then ix:=vid_mwa+ix;
        if(iy<0)then iy:=vid_mha+iy;

        ix+=lx-vid_ab;
        iy+=ly-vid_ab;

        with spr^ do _draw_surf(tar,ix-hw,iy-hh,spr^.surf);
     end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  CPoints
//

procedure cpoints_sprites(draw:boolean);
var t,i:integer;
color:cardinal;
begin
   if(not draw)then exit;

   for t:=1 to MaxCPoints do
    with g_cpoints[t] do
     if(cpCapturer>0)then
     begin
        if(not RectInCam(cpx,cpy,cpCapturer,cpCapturer,0))then continue;

        color:=GetCPColor(t);

        if(t=1)and(g_mode=gm_koth)
        then UnitsInfoAddCircle(cpx,cpy,cpCapturer,color)
        else
          if(cpenergy<=0)
          then SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,ShadowColor(color),@spr_cp_out,255)
          else
          begin
             SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,0                 ,@spr_cp_out,255);
             SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,ShadowColor(color),@spr_cp_gen,255);
          end;

        if(cpTimer   >0)then UnitsInfoAddText(cpx,cpy+10,ir2s(cpCaptureTime-cpTimer),color  );

        if(PointInScreenP(cpx,cpy,nil))then
         if(cplifetime>0)then UnitsInfoAddText(cpx,cpy   ,cr2s(cplifetime           ),c_white);

       // for i:=0 to MaxPlayers do
       //  UnitsInfoAddText(cpx,cpy+(i+2)*10,i2s(cpunitsp_pstate[i])+' '+i2s(cpunitst_pstate[i]),c_white);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//


procedure D_Fog(tar:pSDL_Surface;lx,ly:integer);
var cx,cy,ssx,ssy,sty:integer;
   { b:boolean;
    cl:cardinal;
    ci:integer;
    pf:word;
    cl:cardinal; }
begin
   if(not vid_fog)then exit;

   ssx:=lx-(vid_cam_x mod fog_cw);
   sty:=ly-(vid_cam_y mod fog_cw);

   for cx:=0 to vid_fog_vfw do
   begin
      ssy:=sty;
      for cy:=0 to vid_fog_vfh do
      begin
         vid_fog_pgrid[cx,cy]:=vid_fog_grid[cx,cy];
         if(rpls_fog)then
         begin
            if(vid_fog_grid[cx,cy]=0)then _draw_surf(tar,ssx-fog_chw, ssy-fog_chw, vid_fog_surf);
            vid_fog_grid[cx,cy]:=0;
         end
         else vid_fog_grid[cx,cy]:=2;
         ssy+=fog_cw;
      end;
      ssx+=fog_cw;
   end;


 {  if(pfNodes_c>0)then
    for ci:=1 to pfNodes_c do
     with pfNodes[ci] do
     begin
        ssx:=(pos_x*pf_pathmap_w+pf_pathmap_hw)-vid_cam_x+lx;
        ssy:=(pos_y*pf_pathmap_w+pf_pathmap_hw)-vid_cam_y+ly;
        circleColor(tar,ssx,ssy,16,c_lime);
        cx:=(rootx*pf_pathmap_w+pf_pathmap_hw)-vid_cam_x+lx;
        cy:=(rooty*pf_pathmap_w+pf_pathmap_hw)-vid_cam_y+ly;
        linecolor(tar,ssx,ssy,cx,cy,c_green);
     end;

   ssx:=lx-(vid_cam_x mod pf_pathmap_w);
   sty:=ly-(vid_cam_y mod pf_pathmap_w);

   ci:=5;

   while(ssx<vid_vw)do
   begin

      if(ci=5)
      then ci:=-5
      else ci:= 5;

      ssy:=sty;
      while(ssy<vid_vh)do
      begin
         cx:= (vid_cam_x+ssx+pf_pathmap_hw-lx) div pf_pathmap_w ;
         cy:= (vid_cam_y+ssy+pf_pathmap_hw-ly) div pf_pathmap_w;
         pf:=pf_pathgrid_areas[cx , cy  ];

         if(pf=pf_solid)
         then cl:=c_red
         else cl:=c_white;

         rectangleColor(tar,ssx,ssy,ssx+pf_pathmap_w-1,ssy+pf_pathmap_w-1,cl);

         _draw_text(tar,
         ssx+pf_pathmap_hw,
         ssy+pf_pathmap_hw+ci,
         w2s(pf),
         ta_middle,255,cl);

         ssy+=pf_pathmap_w;
      end;
      ssx+=pf_pathmap_w;
   end;    }

   {if(menu_s2=ms2_camp)then
   begin
      if(ui_msks>=0)then
      begin
         if(integer(ui_msk+ui_msks)>255)
         then ui_msk:=255
         else inc(ui_msk,ui_msks);
      end
      else
      begin
         if(integer(ui_msk+ui_msks)<0)
         then ui_msk:=0
         else inc(ui_msk,ui_msks);
      end;
      if(ui_msk>0)then
      begin
         boxColor(tar,vid_panelw,0,vid_cam_w,vid_cam_h,rgba2c(255,255,255,ui_msk));
         if(vid_rtui=0)then dec(ui_msks,1);
      end;
   end;  }
end;


procedure _draw_dbg;
var u,ix,iy:integer;
    c:cardinal;
begin
   //_draw_text(r_screen,750,0,i2s(mouse_map_x)+' '+i2s(mouse_map_y) , ta_right,255, c_white);
   //_draw_text(r_screen,750,0,i2s(spr_tdecsi), ta_right,255, c_white);

   //_draw_text(r_screen,750,0,b2pm[map_ffly] , ta_right,255, c_white);

  { with _players[HPlayer] do
   begin
      _draw_text(r_screen,vid_panelw,200,i2s(ai_pushtimei) , ta_left,255, c_white);
      _draw_text(r_screen,vid_panelw,210,i2s(ai_pushfrmi ) , ta_left,255, c_white);
   end;       }

   if(ks_shift>0) then
   for u:=0 to MaxPlayers do
    with _players[u] do
    begin
       ix:=170+89*u;

       c:=PlayerGetColor(u);

       _draw_text(r_screen,ix,80,b2s(ucl_cs[false]), ta_middle,255, c);

       _draw_text(r_screen,ix,90,b2s(army)+' '+b2s(ucl_c[false]) , ta_middle,255, c);

       //_draw_text(r_screen,ix,100,b2s(ai_skill)+' '+b2s(ai_maxunits)+' '+b2s(ai_flags) , ta_middle,255, c);
       _draw_text(r_screen,ix,110,b2s(cenergy  )+' '+b2s(menergy) , ta_middle,255, c);


       for iy:=0 to 8  do _draw_text(r_screen,ix,130+iy*10,b2s(ucl_e[true ,iy])+'/'+b2s(ucl_eb[true ,iy])+' '+b2s(ucl_s[true ,iy])+' '+i2s(ucl_x[true,iy]), ta_left,255, c);
       for iy:=0 to 11 do _draw_text(r_screen,ix,230+iy*10,b2s(ucl_e[false,iy])+' '+b2s(ucl_s [false,iy]), ta_left,255, c);
    end;

   if(ks_ctrl>0)then
   for u:=1 to MaxUnits do
    with _units[u] do
    with player^ do
    with uid^ do
     if(hits>dead_hits)or(u=ai_scout_u_cur)then
     begin
        ix:=x-vid_cam_x+vid_mapx;
        iy:=y-vid_cam_y+vid_mapy;

        //_draw_text(r_screen,ix,iy,i2s(anim), ta_left,255, PlayerGetColor(playeri));

        if(hits>0)then
        //if(k_shift>1)then
        begin
          // circleColor(r_screen,ix,iy,_r  ,c_gray);
          // circleColor(r_screen,ix,iy,srange,c_white);
           if(sel)then
           begin
              //lineColor(r_screen,ix,iy,vid_mapx+pf_mv_nx-vid_cam_x  ,vid_mapy+pf_mv_ny-vid_cam_y  ,c_red );
              //lineColor(r_screen,ix,iy,vid_mapx+mv_x    -vid_cam_x+1,vid_mapy+mv_y    -vid_cam_y+1,c_lime);

              //ix:=(((x-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-vid_cam_x+vid_mapx;
              //iy:=(((y-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-vid_cam_y+vid_mapy;

               //rectangleColor(r_screen,ix,iy,ix+_rx2y_r*2*ugrid_cellw+ugrid_cellw,iy+_rx2y_r*2*ugrid_cellw+ugrid_cellw,c_red);

              lineColor(r_screen,ix,iy,uo_x+vid_mapx-vid_cam_x  ,uo_y-vid_cam_y  ,c_white);

              if(aiu_alarm_d<32000)then
              lineColor(r_screen,ix,iy,aiu_alarm_x+vid_mapx-vid_cam_x  ,aiu_alarm_y+vid_mapy-vid_cam_y  ,c_red );



           end;


           _draw_text(r_screen,ix,iy   ,i2s(u)    , ta_left,255, PlayerGetColor(playeri));
           _draw_text(r_screen,ix,iy+10,i2s(hits) , ta_left,255, PlayerGetColor(playeri));
           _draw_text(r_screen,ix,iy+30,li2s(aiu_alarm_d), ta_left,255, PlayerGetColor(playeri));
//           _draw_text(r_screen,ix,iy+40,i2s(_level_armor), ta_left,255, PlayerGetColor(playeri));


           //_draw_text(r_screen,ix,iy+20,b2pm[bld], ta_left,255, PlayerGetColor(playeri));

        end;

        {if(hits>0)and(transport=0)then
        if(playeri=HPlayer)then
        begin
           if(isbuild)then
           begin
              if(alrm_x>0)then
               lineColor(r_screen,ix,iy,alrm_x-vid_cam_x,alrm_y-vid_cam_y,c_blue);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop])
           end
           else
           begin
              if(alrm_x>0)then
               lineColor(r_screen,ix,iy,alrm_x-vid_cam_x,alrm_y-vid_cam_y,c_red);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop])
           end;
           if(uo_x>0)then
            lineColor(r_screen,ix,iy,uo_x-vid_cam_x,uo_y-vid_cam_y,c_white);
        end;

        _draw_text(r_screen,ix,iy,i2s(alrm_r)+#13+b2pm[alrm_b]+#12+i2s(player^.pnum), ta_left,255, PlayerGetColor(playeri));}

        if(transport>0)then continue;

        if(hits>0){and(uidi=UID_URMStation)}then
        begin
           //_draw_text(r_screen,ix,iy,i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop]), ta_left,255, plcolor[player]);

           //if(tar1>0)then lineColor(r_screen,ix,iy,_units[tar1].x-vid_cam_x,_units[tar1].y-vid_cam_y,c_white);
            //lineColor(r_screen,ix+10,iy+10,uo_x-vid_cam_x,uo_y-vid_cam_y,c_white);  and(player=HPlayer)
        end;

         //_draw_text(r_screen,imap_mwcx,iy,b2s(painc)+' '+b2s(pains), ta_left,255, plcolor[player]);
         //if(sel)then            i2s(vsnt[_players[player].team])+#13+i2s(vsni[_players[player].team])
         //if(alrm_r<=0)then
         //

        {if(hits>0)then                      +' '+i2s(utrain)
         if(k_shift>2)
         then lineColor(r_screen,ix,iy,uo_x-vid_cam_x,uo_y-vid_cam_y,c_black)
         else
           if(alrm_x<>0)then


        _draw_text(r_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_left,255, plcolor[player]);// }

        //if(sel)then  circleColor(r_screen,ix,iy,r+5,plcolor[player]);
     end;

   if(ks_ctrl>0)then
   for u:=1 to MaxMissiles do
   with _missiles[u] do
   if(vstep>0)then
   begin
      ix:=vx-vid_cam_x+vid_mapx;
      iy:=vy-vid_cam_y+vid_mapy;

      circleColor(r_screen,ix,iy,5,c_lime);
      _draw_text(r_screen,ix,iy,i2s(dir), ta_left,255, c_white);
   end;

   {for u:=0 to 255 do
    if(ordx[u]>0)then
    begin
       ix:=ordx[u]-vid_cam_x;
       iy:=ordy[u]-vid_cam_y;

       _draw_text(r_screen,ix,iy,i2s(u), ta_left,255, c_white);
    end; }
end;


procedure _drawMWSModel(mwsm:PTMWSModel);
var i,x:integer;
begin
   x:=0;
   with mwsm^ do
   begin
      for i:=1 to sn do
       with sl[i-1] do
       begin
          _draw_surf(r_screen,x,0,surf);
          x+=w;
       end;
      _draw_text(r_screen,0,48,i2s(sn), ta_left,255, c_white);
   end;
end;

