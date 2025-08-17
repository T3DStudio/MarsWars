
procedure vid_LoadingScreen(load_str:pshortstring;color:cardinal);
begin
   SDL_FillRect(vid_screen,nil,0);
   stringColor(vid_screen,(vid_vw div 2)-(length(load_str^)*font_w1 div 2), vid_vh div 2,@(load_str^[1]),color);
   SDL_FLIP(vid_screen);
end;

procedure draw_mwtexture(tar:pSDL_Surface;x,y:integer;sur:PTMWTexture);
begin
   with sur^ do
   begin
      vid_RECT^.x:=x;
      vid_RECT^.y:=y;
      vid_RECT^.w:=sur^.w;
      vid_RECT^.h:=sur^.h;
      SDL_BLITSURFACE(surf,nil,tar,vid_RECT);
   end;
end;

procedure draw_sdlsurface(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   vid_RECT^.x:=x;
   vid_RECT^.y:=y;
   vid_RECT^.w:=sur^.w;
   vid_RECT^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,vid_RECT);
end;

procedure draw_rectw(tar:pSDL_Surface;x0,y0,x1,y1,border,borderSkip:integer;color:cardinal);
begin
   while(border<>0)do
   begin
      if(abs(border)>borderSkip)then
        rectangleColor(tar,x0-border,y0-border,
                           x1+border,y1+border,color);
      if(border>0)
      then border-=1
      else border+=1;
   end;
end;

procedure draw_text(sur:pSDL_Surface;x,y:integer;str:shortstring;alignment,MaxLineChars:byte;BaseColor:cardinal;lastLineY:pinteger=nil);
var
strLen,
i,
lines_n,
line   :byte;
textH,
textW,
ix     :integer;
charc  :char;
color  :cardinal;
lines_spos,
lines_epos,
lines_endc,
lines_len :shortstring;

begin
   if(BaseColor=0)then exit;
   strLen:=length(str);
   if(strLen=0)then exit;
   if(MaxLineChars<1)then MaxLineChars:=1;

   // text analize
   lines_spos:='';
   lines_epos:='';
   lines_endc:='';
   lines_len :='';
   if(alignment=ta_chat)then
   begin
      if(strLen>MaxLineChars)then
      begin
         lines_spos:=chr(strLen-MaxLineChars);
         lines_epos:=chr(strLen);
         lines_len :=chr(MaxLineChars);
         textW:=MaxLineChars*font_w1;
      end
      else
      begin
         lines_spos:=#1;
         lines_epos:=chr(strLen);
         lines_len :=chr(strLen);
         textW:=strLen*font_w1;
      end;
      lines_endc:=#0;
      lines_n:=1;
      textH:=font_w1;
      ix:=x;
      y :=y-font_w1;
   end
   else
   begin
      textW:=0;
      textH:=0;
      str_analize(@str,@lines_spos,@lines_epos,@lines_endc,@lines_len,@textH,@lines_n,nil,MaxLineChars);

      case alignment of
      ta_LU,
      ta_MU,
      ta_RU  : ;
      ta_LM,
      ta_MM,
      ta_RM  : y-=(textH div 2);
      ta_LB,
      ta_MB,
      ta_RB  : y-= textH;
      end;
   end;

   color:=BaseColor;
   for line:=1 to lines_n do
   begin
      textW:=ord(lines_len[line])*font_w1;
      case alignment of
      ta_LU,
      ta_LM,
      ta_LB  : ix:=x;
      ta_MU,
      ta_MM,
      ta_MB  : ix:=x-(textW div 2);
      ta_RU,
      ta_RM,
      ta_RB  : ix:=x- textW;
      end;

      for i:=ord(lines_spos[line]) to ord(lines_epos[line]) do
      begin
         charc:=str[i];

         case charc of
         tc_player0..
         tc_player7  : begin color:=PlayerGetColor(ord(charc),false);if(i<strLen)then continue;end;
         tc_nl1..
         tc_nl2      : ;
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
            char_detect  : boxColor(sur,ix,y,ix+font_wi,y+font_wi,c_purple );
            char_advanced: boxColor(sur,ix,y,ix+font_wi,y+font_wi,c_white  );
            ',',';','[',']','{','}'
                         : boxColor(sur,ix,y,ix+font_wi,y+font_wi,BaseColor);
            else           boxColor(sur,ix,y,ix+font_wi,y+font_wi,color    );
            end;

            draw_mwtexture(sur,ix,y,@font_1[charc]);
            ix   += font_w1;
         end;
      end;

      case lines_endc[line] of
      tc_nl1 : y+=txt_line_h1;
      tc_nl3 : y+=txt_line_h3;
      tc_nl2 : y+=txt_line_h2;
      end;
   end;
   if(lastLineY<>nil)then lastLineY^:=y;
end;

procedure map_MinimapBackgroundObj(sd:TSob);
var d:integer;
begin
   for d:=1 to MaxObstacles do
    with map_ObstaclesL[d] do
     if(o_type in sd)then
      if(o_mmr>0)
      then FilledcircleColor(ui_bminimap,o_mmx,o_mmy,o_mmr,o_mmc)
      else pixelColor       (ui_bminimap,o_mmx,o_mmy,    o_mmc);
end;

procedure map_MinimapUpdateBackground;
begin
   sdl_FillRect(ui_bminimap,nil,0);
   map_MinimapBackgroundObj(dids_liquids);
   map_MinimapBackgroundObj([DID_other,DID_srock,DID_brock]);
end;

procedure map_minimap_KeyPoint(tar:pSDL_Surface;x,y,r:integer;sym:char;color:cardinal);
begin
   circleColor   (tar,x  ,y  ,r  ,color);
   characterColor(tar,x-3,y-3,sym,color);
end;

procedure map_MinimapPlayerStarts(tar:pSDL_Surface);
var p    :byte;
    x,y  :integer;
    color:cardinal;
    pc   :char;
begin
   if(map_MaxPlayers>0)then
     for p:=0 to map_MaxPlayers-1 do
     begin
        if(g_FixedPositions)then
        begin
           if(g_gplayers[p].state=ps_none)and(g_AISlots=0)then continue;
           color:=PlayerGetColor(p,false);
           pc:=i2s(p+1)[1];
        end
        else
        begin
           pc:='?';
           color:=c_white;
        end;

        x:=round(map_PlayerStartX[p]*map_mmcx);
        y:=round(map_PlayerStartY[p]*map_mmcx);

        map_minimap_KeyPoint(tar,x,y,trunc(base_1r*map_mmcx),pc,color);
     end;
end;

procedure map_MinimapKeyPoints(tar:pSDL_Surface);
var i  :byte;
begin
   for i:=0 to LastKeyPoint do
    with g_KeyPoints[i] do
     if(kpCaptureR>0)then
      if((i=0)and(map_scenario=mc_KotH))
      then map_minimap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,char_koth,c_white)
      else
        if(kpEnergy<=0)
        then map_minimap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,char_kp ,c_white)
        else map_minimap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,char_gen,c_white);
end;

procedure map_RedrawMenuMinimap;
begin
   sdl_FillRect(ui_minimap,nil,0);
   map_MinimapUpdateBackground;
   draw_sdlsurface(ui_minimap ,0,0,ui_bminimap);
   draw_sdlsurface(ui_mminimap,0,0,ui_minimap);
   map_MinimapPlayerStarts(ui_mminimap);
   map_MinimapKeyPoints   (ui_mminimap);
   menu_update:=menu_update or MainMenu;
end;

procedure d_timer(tar:pSDL_Surface;x,y:integer;time:cardinal;ta:byte;str:shortstring;color:cardinal);
var m,s,h:cardinal;
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

   ax:=mm3i(1,ax,map_Size);
   ay:=mm3i(1,ay,map_Size);

   mx:=trunc(ax*map_mmcx);
   my:=trunc(ay*map_mmcx);

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
   if(UIPlayer<=LastPlayer)then
     with g_gplayers[UIPlayer] do
       with log_l[log_i] do
         case mtype of
lmt_unit_LevelUp    :      ui_AddMarker(xi,yi,aummat_advance   ,true);
lmt_unit_ready       : if(g_uids[argx].uid_ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_created_b ,true)
                       else ui_AddMarker(xi,yi,aummat_created_u ,true);
lmt_upgrade_complete :      ui_AddMarker(xi,yi,aummat_upgrade   ,true);
lmt_map_mark         :      ui_AddMarker(xi,yi,aummat_info      ,true);
lmt_allies_attacked,
lmt_unit_attacked    : begin
                       if(g_uids[argx].uid_ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_attacked_b,false)
                       else ui_AddMarker(xi,yi,aummat_attacked_u,false);

                       LogMes2UIAlarm:=not PointInCam(xi,yi);
                       end;
         end;
end;


