function rgba2c(r,g,b,a:byte):cardinal;
begin
   rgba2c:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

function ShadowColor(c:cardinal):cardinal;
begin
   ShadowColor:=128 +
   (((c and $FF000000) shr 25) shl 24) +
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 );
end;

procedure draw_mwtexture(tar:pSDL_Surface;x,y:integer;sur:PTMWTexture);
begin
   with sur^ do
   begin
      r_RECT^.x:=x;
      r_RECT^.y:=y;
      r_RECT^.w:=sur^.w;
      r_RECT^.h:=sur^.h;
      SDL_BLITSURFACE(sdlSurface,nil,tar,r_RECT);
   end;
end;

procedure draw_surf(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   r_RECT^.x:=x;
   r_RECT^.y:=y;
   r_RECT^.w:=sur^.w;
   r_RECT^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,r_RECT);
end;


procedure draw_text(sur:pSDL_Surface;x,y:integer;str:shortstring;alignment,MaxLineChars:byte;BaseColor:cardinal);
var strLen,
    i,
    chars :byte;
    ix    :integer;
    charc :char;
 color    :cardinal;
begin
   if(BaseColor=0)then exit;
   strLen:=length(str);
   if(strLen=0)then exit;

   if(alignment=ta_middle)
   or(alignment=ta_right )then
   begin
      chars:=0;
      for i:=1 to strLen do
       if not(str[i] in [tc_player0..tc_player6,tc_purple..tc_default])then chars+=1;

      case alignment of
      ta_middle: ix:=x-((chars*font_w) shr 1);
      ta_right : ix:=x- (chars*font_w);
      end;
   end
   else ix:=x;

   if(alignment=ta_chat)and(strLen>MaxLineChars)
   then i:=strLen-MaxLineChars
   else i:=1;

   chars:=0;
   color:=BaseColor;
   for i:=i to strLen do
   begin
      charc:=str[i];

      case charc of
      tc_player0..
      tc_player6  : begin color:=PlayerGetColor(ord(charc));if(i<strLen)then continue;end;
      tc_nl1..
      tc_nl3      : ;
      tc_purple   : begin color:=c_purple ;if(i<strLen)then continue;end;
      tc_red      : begin color:=c_red    ;if(i<strLen)then continue;end;
      tc_orange   : begin color:=c_orange ;if(i<strLen)then continue;end;
      tc_yellow   : begin color:=c_yellow ;if(i<strLen)then continue;end;
      tc_lime     : begin color:=c_lime   ;if(i<strLen)then continue;end;
      tc_aqua     : begin color:=c_aqua   ;if(i<strLen)then continue;end;
      tc_blue     : begin color:=c_blue   ;if(i<strLen)then continue;end;
      tc_gray     : begin color:=c_gray   ;if(i<strLen)then continue;end;
      tc_dgray    : begin color:=c_dgray  ;if(i<strLen)then continue;end;
      tc_white    : begin color:=c_white  ;if(i<strLen)then continue;end;
      tc_green    : begin color:=c_green  ;if(i<strLen)then continue;end;
      tc_default  : begin color:=BaseColor;if(i<strLen)then continue;end;
      else
         case charc of
         char_detect  : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_purple );
         char_advanced: boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_white  );
         ',',';','[',']','{','}'
                      : boxColor(sur,ix,y,ix+font_iw,y+font_iw,BaseColor);
         else           boxColor(sur,ix,y,ix+font_iw,y+font_iw,color    );
         end;

         draw_mwtexture(sur,ix,y,@font_1[charc]);

         chars+= 1;
         ix   += font_w;
      end;

      if(alignment=ta_left)then
       if(chars>=MaxLineChars)
       or(charc  =tc_nl1)
       or(charc  =tc_nl2)
       or(charc  =tc_nl3)
       or(i      =strLen)then
       begin
          if(chars>=MaxLineChars)then charc:=tc_nl1;
          if(i<strLen)then chars:=0;

          ix:=x;
          case charc of
          tc_nl1 : y+=txt_line_h1;
          tc_nl2 : y+=txt_line_h2;
          else     y+=txt_line_h3;
          end;
       end;
   end;
end;

procedure DrawLoadingScreen(CaptionString:shortstring;color:cardinal);
begin
   SDL_FillRect(r_screen,nil,0);
   draw_text(r_screen,vid_vw div 2,vid_vh div 2,CaptionString,ta_middle,255,color);
   //stringColor(r_screen,(vid_vw div 2)-(length(CaptionString^)*font_w div 2), vid_vh div 2,@(CaptionString^[1]),color);
   SDL_FLIP(r_screen);
end;

function TileSetGetN(b10,b01,b11,b21,b12:boolean):byte;
begin
   if(b11)
   then TileSetGetN:=1
   else
   begin
      TileSetGetN:=1;
      if(b10)then TileSetGetN+=1;
      if(b01)then TileSetGetN+=2;
      if(b21)then TileSetGetN+=4;
      if(b12)then TileSetGetN+=8;
      if(TileSetGetN=1)then TileSetGetN:=0;
   end;
end;

procedure map_MinimapBackDraw();
begin
   {for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t in sd)then
      if(mmr>0)
      then FilledcircleColor(r_bminimap,mmx,mmy,mmr,mmc)
      else pixelColor       (r_bminimap,mmx,mmy,    mmc);  }
end;

procedure map_MinimapBackground;
var
gx ,gy :integer;
mmx,mmy:single;
begin
   sdl_FillRect(r_bminimap,nil,0);

   mmx:=0;
   for gx:=0 to map_LastCell do
   begin
      mmy:=0;
      for gy:=0 to map_LastCell do
      begin
         case map_grid[gx,gy].tgc_solidlevel of
mgsl_nobuild : boxColor(r_bminimap,trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW),c_green );
mgsl_liquid  : boxColor(r_bminimap,trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW),theme_cur_liquid_mmcolor);
mgsl_rocks   : boxColor(r_bminimap,trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW),c_gray  );
         end;

         mmy+=map_mm_gridW;
      end;
      mmx+=map_mm_gridW;
   end;
end;

procedure map_MinimapSpot(tar:pSDL_Surface;x,y,r:integer;sym:char;color:cardinal);
begin
   circleColor   (tar,x  ,y  ,r  ,color);
   characterColor(tar,x-3,y-3,sym,color);
end;

procedure map_MinimapPlayerStarts(UnknownStarts:boolean);
var i    :byte;
    x,y,r:integer;
begin
   for i:=0 to MaxPlayers do
   begin
      if(g_mode in [gm_invasion,gm_koth])and(i=0)then continue;

      x:=round(map_PlayerStartX[i]*map_mm_cx);
      y:=round(map_PlayerStartY[i]*map_mm_cx);
      r:=trunc(base_1r*map_mm_cx);

      // clear
      filledcircleColor(r_minimap,x,y,r ,c_black);
            circleColor(r_minimap,x,y,r ,c_black);
         characterColor(r_minimap,x,y,#8,c_black);

      if(UnknownStarts)
      then map_MinimapSpot(r_minimap,x,y,r,'?',c_white)
      else
        if (g_slot_state[i]<>ps_closed  )
        and(g_slot_state[i]<>ps_observer)
        then
          if(g_players[i].state>ps_none)or(g_ai_slots>0)
          then map_MinimapSpot(r_minimap,x,y,r,b2s(i)[1],PlayerGetColor(i))
          else map_MinimapSpot(r_minimap,x,y,r,'+'      ,c_white);
   end;

   {x:=round(map_symmetryX0*map_mm_cx);
   y:=round(map_symmetryY0*map_mm_cx);
   lineColor(r_minimap,
   x,y,
   round(map_symmetryX1*map_mm_cx),
   round(map_symmetryY1*map_mm_cx),
   c_lime);

   lineColor(r_minimap,
   x,y,
   x-(round(map_symmetryX1*map_mm_cx)-x),
   y-(round(map_symmetryY1*map_mm_cx)-y),
   c_lime); }
end;

procedure map_MinimapCPoints;
var i  :byte;
begin
   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCaptureR>0)then
      if((i=0)and(g_mode=gm_koth))or(cpenergy<=0)
      then map_MinimapSpot(r_minimap,cpmx,cpmy,cpmr,char_cp ,c_purple)
      else map_MinimapSpot(r_minimap,cpmx,cpmy,cpmr,char_gen,c_white );
end;

procedure map_RedrawMenuMinimap(full:boolean);
begin
   if(full)then
   begin
      sdl_FillRect(r_minimap,nil,0);
      map_MinimapBackground;
      draw_surf(r_minimap,0,0,r_bminimap);
   end;
   map_MinimapPlayerStarts(not g_fixed_positions);
   map_MinimapCPoints;
   draw_surf(spr_mback,ui_menu_map_mx0,ui_menu_map_my0,r_minimap);
   rectangleColor(spr_mback,ui_menu_map_mx0,ui_menu_map_my0,ui_menu_map_mx0+r_minimap^.w,ui_menu_map_my0+r_minimap^.h,c_ltgray);
   menu_redraw:=menu_redraw or menu_state;
end;

procedure d_timer(tar:pSDL_Surface;x,y:integer;time:cardinal;ta:byte;str:shortstring;color:cardinal);
var
m,s,h   :cardinal;
hs,ms,ss:shortstring;
begin
   s:=time div fr_fps1;
   m:=s div 60;
   s:=s mod 60;
   h:=m div 60;
   m:=m mod 60;
   if(h>0)then
   begin
      if(h<10)then hs:='0'+c2s(h) else hs:=c2s(h);
      str:=hs+':';
   end;
   if(m<10)then ms:='0'+c2s(m) else ms:=c2s(m);
   if(s<10)then ss:='0'+c2s(s) else ss:=c2s(s);
   str:=str+ms+':'+ss;
   draw_text(tar,x,y,str,ta,255,color);
end;

function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;
var i,ni,mx,my:integer;
begin
   {
   new  false - not required new alarm point
        true  - required
   return - true if alarm created
   }
   ui_AddMarker:=false;

   ax:=mm3i(1,ax,map_size);
   ay:=mm3i(1,ay,map_size);

   mx:=trunc(ax*map_mm_cx);
   my:=trunc(ay*map_mm_cx);

   if(not new)then
    for i:=0 to ui_max_alarms do
     with ui_alarms[i] do
      if(al_t>0)and(al_v=av)then
       if(point_dist_rint(al_mx,al_my,mx,my)<=ui_alarm_time)then
       begin
          al_x :=(al_x +ax) div 2;
          al_y :=(al_y +ay) div 2;
          al_mx:=(al_mx+mx) div 2;
          al_my:=(al_my+my) div 2;
          al_t :=ui_alarm_time;
          exit;
       end;

   ni:=0;
   for i:=0 to ui_max_alarms do
    if(ui_alarms[i].al_t<ui_alarms[ni].al_t)
    then ni:=i;

   with ui_alarms[ni] do
    if(al_t<=0)or(not new)then
    begin
       al_x :=ax;
       al_y :=ay;
       al_mx:=mx;
       al_my:=my;
       al_v :=av;
       al_t :=ui_alarm_time;
       case al_v of
aummat_attacked_u,
aummat_attacked_b : al_c:=c_red;
aummat_created_u,
aummat_created_b  : al_c:=c_lime;
aummat_advance    : al_c:=c_aqua;
aummat_upgrade    : al_c:=c_yellow;
aummat_info       : al_c:=c_white;
       end;
       ui_AddMarker:=true;
    end;
end;

function LogMes2UIAlarm:boolean;
begin
   // true  - need announcer sound
   // false - no need announcer sound
   LogMes2UIAlarm:=true;
   with g_players[UIPlayer] do
    with log_l[log_i] do
     case mtype of
lmt_unit_advanced    :      ui_AddMarker(xi,yi,aummat_advance   ,true);
lmt_unit_ready       : if(g_uids[argx]._ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_created_b ,true)
                       else ui_AddMarker(xi,yi,aummat_created_u ,true);
lmt_upgrade_complete :      ui_AddMarker(xi,yi,aummat_upgrade   ,true);
lmt_map_mark         :      ui_AddMarker(xi,yi,aummat_info      ,true);
lmt_allies_attacked,
lmt_unit_attacked    : begin
                       if(g_uids[argx]._ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_attacked_b,false)
                       else ui_AddMarker(xi,yi,aummat_attacked_u,false);
                       LogMes2UIAlarm:=not PointInCam(xi,yi);
                       end;
     end;
end;


