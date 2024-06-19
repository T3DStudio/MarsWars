

////////////////////////////////////////////////////////////////////////////////
//
//  SpriteList
//

const TVisSprSize =  SizeOf(TVSprite);

var slatemp : PTVSprite;

function SpriteListAdd:PTVSprite;
begin
   SpriteListAdd:=nil;
   if(vid_Sprites_n<vid_MaxScreenSprites)and(not menu_state)then
   begin
      setlength(vid_Sprites_List,vid_Sprites_n+1);
      new(vid_Sprites_List[vid_Sprites_n]);
      SpriteListAdd:=vid_Sprites_List[vid_Sprites_n];
      FillChar(SpriteListAdd^,TVisSprSize,0);
      with SpriteListAdd^ do alpha:=255;
      vid_Sprites_n+=1;
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
var i,j:word;
    dum:PTVSprite;
begin
   if(vid_Sprites_n>1)then
    for i:=0 to vid_Sprites_n-2 do
     for j:=0 to (vid_Sprites_n-i-2) do
      if(vid_Sprites_List[j]^.depth<vid_Sprites_List[j+1]^.depth)then
      begin
         dum:=vid_Sprites_List[j];
         vid_Sprites_List[j  ]:=vid_Sprites_List[j+1];
         vid_Sprites_List[j+1]:=dum;
      end;
end;

procedure D_SpriteList(tar:pSDL_Surface;lx,ly:integer);
var sx,sy:integer;
begin
   SpriteListSort;
   while(vid_Sprites_n>0)do
   begin
      vid_Sprites_n-=1;
      with vid_Sprites_List[vid_Sprites_n]^ do
      begin
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
          then draw_surf(tar,x,y,sprite^.sdlSurface)
          else
          begin
             SDL_SetAlpha(sprite^.sdlSurface,SDL_SRCALPHA or SDL_RLEACCEL,alpha);
             draw_surf(tar,x,y,sprite^.sdlSurface);
             SDL_SetAlpha(sprite^.sdlSurface,SDL_SRCALPHA or SDL_RLEACCEL,255);
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
      dispose(vid_Sprites_List[vid_Sprites_n]);
   end;
   setlength(vid_Sprites_List,0);
end;


////////////////////////////////////////////////////////////////////////////////
//
//  UnitsInfo
//

const TVisPrimSize =  SizeOf(TUIItem);

procedure UnitsInfoNew;
begin
   vid_UIItem_n+=1;
   setlength(vid_UIItem_list,vid_UIItem_n);
   FillChar(vid_UIItem_list[vid_UIItem_n-1],TVisPrimSize,0);
end;

procedure UnitsInfoAddLine(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   UnitsInfoNew;
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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
   with vid_UIItem_list[vid_UIItem_n-1] do
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

function i2s6(i:integer;null:boolean):string6;
begin
   if(i>0)
   then i2s6:=i2s(i)
   else
     if(null)
     then i2s6:='0'
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

      srect :=((isselected)and(playeri=UIPlayer))
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
         if(playeri=UIPlayer)
         then UnitsInfoAddRectText(vx-sm_sel_hw,vy-sm_sel_hh,vx+sm_sel_hw,vy+sm_sel_hh,acolor,i2s6(group,false),'',lvlstr_b,i2s6(transportM,false),i2s6(transportC,false))
         else UnitsInfoAddRectText(vx-sm_sel_hw,vy-sm_sel_hh,vx+sm_sel_hw,vy+sm_sel_hh,acolor,lvlstr_w         ,'',lvlstr_b,lvlstr_a        ,lvlstr_s        );
         UnitsInfoAddText(vx,vy-sm_sel_hh-font_w,lvlstr_l,c_white);
      end;
      if(hbar )then UnitsInfoProgressbar(vx-sm_sel_hw,vy-sm_sel_hh-4,vx+sm_sel_hw,vy-sm_sel_hh,hits/_mhits,acolor);

      if(reload>0)and(playeri=UIPlayer)then UnitsInfoAddText(vx,vy-sm_sel_hh+font_w,lvlstr_r,c_aqua);

      if(speed<=0)or(not iscomplete)then
        case m_brush of
1..255,
mb_psability   : UnitsInfoAddCircle(x,y,_r,r_blink2_color_BY);
        end;


      if(srect)and(_ukbuilding)and(UIUnitDrawRangeConditionals(pu))then UnitsInfoAddCircle(x,y,srange,r_blink2_color_BG);

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
      else buffy:=vy-sm_sel_hh-font_w;

      if(buff[ub_HVision]>0)then begin UnitsInfoAddBuff(buffx,buffy,@spr_hvision);buffx+=buff_sprite_w;end;
      if(buff[ub_Invuln ]>0)then begin UnitsInfoAddBuff(buffx,buffy,@spr_invuln );buffx+=buff_sprite_w;end;
      if(pain              )then begin UnitsInfoAddBuff(buffx,buffy,@spr_stun   );buffx+=buff_sprite_w;end;
   end;
end;

procedure D_UnitsInfo(tar:pSDL_Surface;lx,ly:integer);
var t:integer;
begin
   case g_mode of
gm_royale: circleColor(tar,lx+map_hsize-vid_cam_x,ly+map_hsize-vid_cam_y,g_royal_r,ui_max_color[r_blink2_colorb]);
   end;


   while(vid_UIItem_n>0)do
    with vid_UIItem_list[vid_UIItem_n-1] do
    begin
       vid_UIItem_n-=1;

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
        with sprite^ do draw_surf(tar,x0,y0,sdlSurface);

       if(kind=uinfo_sprite)then continue;

       if(color>0)then
        case kind of
uinfo_line   : lineColor     (tar,x0,y0,x1,y1,color);
uinfo_rect   : rectangleColor(tar,x0,y0,x1,y1,color);
uinfo_box    : boxColor      (tar,x0,y0,x1,y1,color);
uinfo_circle : circleColor   (tar,x0,y0,x1,   color);
uinfo_text   : begin
               draw_text(tar,x0,y0-font_hw,text_lt,ta_middle,255,color);
               continue;
               end;
        else
        end;

       if(length(text_lt )>0)then draw_text(tar,x0+1,y0+1       ,text_lt ,ta_left ,255,c_white);
       if(length(text_lt2)>0)then draw_text(tar,x0+1,y0+font_w+4,text_lt2,ta_left ,255,c_white);
       if(length(text_rt )>0)then draw_text(tar,x1-1,y0+1       ,text_rt ,ta_right,255,c_white);
       if(length(text_rd )>0)then draw_text(tar,x1-1,y1-1-font_w,text_rd ,ta_right,255,c_white);
       if(length(text_ld )>0)then draw_text(tar,x0+1,y1-1-font_w,text_ld ,ta_left ,255,c_white);
    end;
   setlength(vid_UIItem_list,vid_UIItem_n);
end;

////////////////////////////////////////////////////////////////////////////////
//
//  Terrain
//

procedure D_terrain(tar:pSDL_Surface;lx,ly:integer);
var
ssx,ssy,sty,
sx0,sy0,
cx,cy,
mx,my,
anim
:integer;
begin

   ssx:=lx-(vid_cam_x mod MapCellW);
   sty:=ly-(vid_cam_y mod MapCellW);
   sx0:=vid_cam_x div MapCellW;
   sy0:=vid_cam_y div MapCellW;

   for cx:=0 to vid_map_vfw do
   begin
      ssy:=sty;
      for cy:=0 to vid_map_vfh do
      begin
         mx:=sx0+cx;
         my:=sy0+cy;
         if (0<=mx)and(mx<MaxMapSizeCelln)
         and(0<=my)and(my<MaxMapSizeCelln)then
         begin
            case map_grid[mx,my].tgc_solidlevel of
mgsl_free    : draw_surf(tar,ssx,ssy,theme_tile_terrain);
mgsl_nobuild : begin
               draw_surf(tar,ssx,ssy,theme_tile_terrain);
               boxColor(tar,ssx+20,ssy+20,ssx+MapCellW-20,ssy+MapCellW-20,c_green );
               end;
mgsl_liquid  : begin
               anim:=0;
               if(theme_cur_liquid_tasPeriod>0)and(theme_cur_liquid_tas<>tas_ice)
               then anim:=(G_Step div theme_cur_liquid_tasPeriod) mod theme_anim_step_n;
               draw_surf(tar,ssx,ssy,theme_tileset_liquid[anim][0].sdlSurface);   //
               end;
mgsl_rocks   : boxColor(tar,ssx,ssy,ssx+MapCellW,ssy+MapCellW,c_gray  );
            end;

            with map_grid[mx,my] do
            begin
               draw_text(tar,ssx+10,ssy+10,w2s(tgc_parea),ta_left,255,c_white);
               draw_text(tar,ssx+10,ssy+30,w2s(tgc_sarea),ta_left,255,c_ltgray);
            end;
         end;

         hlineColor(tar,vid_mapx,vid_mapx+vid_cam_w,ssy,c_gray);
         ssy+=MapCellW;
      end;
      vlineColor(tar,ssx,vid_mapy,vid_mapy+vid_cam_h,c_gray);
      ssx+=MapCellW;
   end;

   {mx:=debug_x*MapCellW;
   my:=debug_y*MapCellW;
   mgcell2NearestXY(mouse_map_x,mouse_map_y,mx,my,mx+MapCellW,my+MapCellW,@mx,@my,0);

   ssx:=mx-vid_cam_x+lx;
   ssy:=my-vid_cam_y+ly;

   circleColor(tar,ssx,ssy,5,c_yellow);

   draw_text(tar,ssx+MapCellhW,ssy+MapCellhW,i2s(point_dist_int(mouse_map_x,mouse_map_y,mx,my)),ta_middle,255,c_white);
   }
end;


////////////////////////////////////////////////////////////////////////////////
//
//  CPoints
//

procedure cpoints_sprites(draw:boolean);
const marks     = 15;
      mark_step = round(360/marks);
var t,i:integer;
   ddir:single;
  color:cardinal;
begin
   if(not draw)then exit;

   for t:=1 to MaxCPoints do
    with g_cpoints[t] do
     if(cpCaptureR>0)then
     begin
        if(not RectInCam(cpx,cpy,cpCaptureR,cpCaptureR,0))then continue;

        color:=GetCPColor(t);

        if(t=1)and(g_mode=gm_koth)then
        begin
           for i:=1 to marks do
           begin
              ddir:=(i*mark_step)*degtorad;
              SpriteListAddEffect(
              cpx+round(cpCaptureR*cos(ddir)),
              cpy+round(cpCaptureR*sin(ddir)),
              sd_ground+cpy,ShadowColor(color),@spr_cp_koth,255);
           end;
        end
        else
          if(cpenergy<=0)
          then SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,ShadowColor(color),@spr_cp_out,255)
          else
          begin
             SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,0                 ,@spr_cp_out,255);
             SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,ShadowColor(color),@spr_cp_gen,255);
          end;

        if(ui_MapPointInRevealedInScreen(cpx,cpy))then
        begin
           if(cpTimer   >0)then UnitsInfoAddText(cpx,cpy+10,ir2s(cpCaptureTime-cpTimer),color  );
           if(cplifetime>0)then UnitsInfoAddText(cpx,cpy   ,cr2s(cplifetime           ),c_white);
        end;

       // for i:=0 to MaxPlayers do
       //  UnitsInfoAddText(cpx,cpy+(i+2)*10,i2s(cpunitsp_pstate[i])+' '+i2s(cpunitst_pstate[i]),c_white);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//


procedure D_Fog(tar:pSDL_Surface;lx,ly:integer);
var
 cx, cy,
ssx,ssy,
    sty:integer;
  tileX:byte;
function GetFogGridVal(fx,fy:integer):boolean;
begin
   GetFogGridVal:=true;
   if (0<=fx)and(fx<=fog_vfwm)
   and(0<=fy)and(fy<=fog_vfhm)then GetFogGridVal:=not vid_fog_pgrid[fx,fy];
end;
begin
   vid_fog_pgrid:=vid_fog_grid;

   ssx:=lx-(vid_cam_x mod fog_CellW);
   sty:=ly-(vid_cam_y mod fog_CellW);

   for cx:=0 to vid_fog_vfw do
   begin
      //vlineColor(tar,ssx,vid_mapx,vid_mapx+vid_cam_w,c_gray);
      ssy:=sty;
      for cy:=0 to vid_fog_vfh do
      begin
         tileX:=TileSetGetN(GetFogGridVal(cx  ,cy-1),
                            GetFogGridVal(cx-1,cy  ),
                            GetFogGridVal(cx  ,cy  ),
                            GetFogGridVal(cx+1,cy  ),
                            GetFogGridVal(cx  ,cy+1));
         if(tileX>0)then
           draw_surf(tar,ssx,ssy,vid_fog_tiles[tileX-1].sdlSurface);

         vid_fog_grid[cx,cy]:=false;
         ssy+=fog_CellW;
      end;
      ssx+=fog_CellW;
   end;
end;


procedure _draw_dbg;
var u,ix,iy:integer;
    c:cardinal;
begin
   //draw_text(r_screen,750,0,i2s(mouse_map_x)+' '+i2s(mouse_map_y) , ta_right,255, c_white);
   //draw_text(r_screen,750,0,i2s(spr_tdecsi), ta_right,255, c_white);

   //draw_text(r_screen,750,0,b2pm[map_ffly] , ta_right,255, c_white);

  { with g_players[PlayerClient] do
   begin
      draw_text(r_screen,vid_panelw,200,i2s(ai_pushtimei) , ta_left,255, c_white);
      draw_text(r_screen,vid_panelw,210,i2s(ai_pushfrmi ) , ta_left,255, c_white);
   end;       }

   {ix:=-vid_cam_x+vid_mapx;
   iy:=-vid_cam_y+vid_mapy;

   if(debug_r0<>NOTSET)then
   begin
   circleColor(r_screen,debug_x0+ix,debug_y0+iy,5,c_lime);
   rectangleColor(r_screen,ix+debug_x0,iy+debug_y0,ix+debug_x0+debug_a0,iy+debug_y0+debug_b0,c_lime);
   end;
   if(debug_r1<>NOTSET)then
   begin
   circleColor(r_screen,debug_x1-vid_cam_x+vid_mapx,debug_y1-vid_cam_y+vid_mapy,7,c_blue);
   rectangleColor(r_screen,ix+debug_x1,iy+debug_y1,ix+debug_x1+debug_a1,iy+debug_y1+debug_b1,c_blue);
   end;}

   if(ks_shift>0) then
   for u:=0 to MaxPlayers do
    with g_players[u] do
    begin
       ix:=170+89*u;

       c:=PlayerGetColor(u);

       draw_text(r_screen,ix,80,b2s(ucl_cs[false]), ta_middle,255, c);

       draw_text(r_screen,ix,90,b2s(army)+' '+b2s(ucl_c[false]) , ta_middle,255, c);

       //draw_text(r_screen,ix,100,b2s(ai_skill)+' '+b2s(ai_maxunits)+' '+b2s(ai_flags) , ta_middle,255, c);
       draw_text(r_screen,ix,110,b2s(cenergy  )+' '+b2s(menergy) , ta_middle,255, c);


       for iy:=0 to 8  do draw_text(r_screen,ix,130+iy*10,b2s(ucl_e[true ,iy])+'/'+b2s(ucl_eb[true ,iy])+' '+b2s(ucl_s[true ,iy])+' '+i2s(ucl_x[true,iy]), ta_left,255, c);
       for iy:=0 to 11 do draw_text(r_screen,ix,230+iy*10,b2s(ucl_e[false,iy])+' '+b2s(ucl_s [false,iy]), ta_left,255, c);
    end;

   if(ks_ctrl>0)then
   for u:=1 to MaxUnits do
    with g_units[u] do
    with player^ do
    with uid^ do
     if(hits>dead_hits)or(u=ai_scout_u_cur)then
     begin
        ix:=x-vid_cam_x+vid_mapx;
        iy:=y-vid_cam_y+vid_mapy;

        //draw_text(r_screen,ix,iy,i2s(anim), ta_left,255, PlayerGetColor(playeri));

        if(hits>0)then
        //if(k_shift>1)then
        begin
           circleColor(r_screen,ix,iy,_r  ,c_gray);
           circleColor(r_screen,ix,iy,srange,c_white);
           if(isselected)then
           begin
              //lineColor(r_screen,ix,iy,vid_mapx+pf_mv_nx-vid_cam_x  ,vid_mapy+pf_mv_ny-vid_cam_y  ,c_red );
              //lineColor(r_screen,ix,iy,vid_mapx+mv_x    -vid_cam_x+1,vid_mapy+mv_y    -vid_cam_y+1,c_lime);

              //ix:=(((x-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-vid_cam_x+vid_mapx;
              //iy:=(((y-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-vid_cam_y+vid_mapy;

               //rectangleColor(r_screen,ix,iy,ix+_rx2y_r*2*ugrid_cellw+ugrid_cellw,iy+_rx2y_r*2*ugrid_cellw+ugrid_cellw,c_red);

              lineColor(r_screen,ix+1,iy+1,ua_x+vid_mapx-vid_cam_x,ua_y-vid_cam_y,c_white);

              if(aiu_alarm_d<32000)then
              lineColor(r_screen,ix,iy,aiu_alarm_x+vid_mapx-vid_cam_x  ,aiu_alarm_y+vid_mapy-vid_cam_y  ,c_red );
           end;

           draw_text(r_screen,ix,iy   ,i2s(u)           , ta_left,255, PlayerGetColor(playeri));
           draw_text(r_screen,ix,iy+10,i2s(hits)        , ta_left,255, PlayerGetColor(playeri));
           draw_text(r_screen,ix,iy+20,b2s(ua_id)       , ta_left,255, PlayerGetColor(playeri));
           draw_text(r_screen,ix,iy+30,li2s(aiu_alarm_d), ta_left,255, PlayerGetColor(playeri));
           //draw_text(r_screen,ix,iy+40,li2s(_level_armor), ta_left,255, PlayerGetColor(playeri));

//           draw_text(r_screen,ix,iy+40,i2s(_level_armor), ta_left,255, PlayerGetColor(playeri));


           //draw_text(r_screen,ix,iy+20,b2pm[iscomplete], ta_left,255, PlayerGetColor(playeri));

        end;

        {if(hits>0)and(transport=0)then
        if(playeri=PlayerClient)then
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

        draw_text(r_screen,ix,iy,i2s(alrm_r)+#13+b2pm[alrm_b]+#12+i2s(player^.pnum), ta_left,255, PlayerGetColor(playeri));}

        if(transport>0)then continue;

        if(hits>0){and(uidi=UID_URMStation)}then
        begin
           //draw_text(r_screen,ix,iy,i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop]), ta_left,255, plcolor[player]);

           //if(tar1>0)then lineColor(r_screen,ix,iy,g_units[tar1].x-vid_cam_x,g_units[tar1].y-vid_cam_y,c_white);
            //lineColor(r_screen,ix+10,iy+10,uo_x-vid_cam_x,uo_y-vid_cam_y,c_white);  and(player=PlayerClient)
        end;

         //draw_text(r_screen,imap_mwcx,iy,b2s(painc)+' '+b2s(pains), ta_left,255, plcolor[player]);
         //if(isselected)then            i2s(vsnt[g_players[player].team])+#13+i2s(vsni[g_players[player].team])
         //if(alrm_r<=0)then
         //

        {if(hits>0)then                      +' '+i2s(utrain)
         if(k_shift>2)
         then lineColor(r_screen,ix,iy,uo_x-vid_cam_x,uo_y-vid_cam_y,c_black)
         else
           if(alrm_x<>0)then


        draw_text(r_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_left,255, plcolor[player]);// }

        //if(isselected)then  circleColor(r_screen,ix,iy,r+5,plcolor[player]);
     end;

   if(ks_ctrl>0)then
   for u:=1 to MaxMissiles do
   with g_missiles[u] do
   if(vstep>0)then
   begin
      ix:=vx-vid_cam_x+vid_mapx;
      iy:=vy-vid_cam_y+vid_mapy;

      circleColor(r_screen,ix,iy,5,c_lime);
      draw_text(r_screen,ix,iy,i2s(dir), ta_left,255, c_white);
   end;

   {for u:=0 to 255 do
    if(ordx[u]>0)then
    begin
       ix:=ordx[u]-vid_cam_x;
       iy:=ordy[u]-vid_cam_y;

       draw_text(r_screen,ix,iy,i2s(u), ta_left,255, c_white);
    end; }
end;


procedure _drawMWSModel(mwsm:PTMWSModel);
var i,x:integer;
begin
   x:=0;
   with mwsm^ do
   begin
      for i:=1 to sm_listn do
       with sm_list[i-1] do
       begin
          draw_surf(r_screen,x,0,sdlSurface);
          x+=w;
       end;
      draw_text(r_screen,0,48,i2s(sm_listn), ta_left,255, c_white);
   end;
end;

