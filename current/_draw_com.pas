function ShadowColor(c:cardinal):cardinal;
begin
   ShadowColor:=128 +
   (((c and $FF000000) shr 25) shl 24) +
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 );
end;

procedure _draw_mwtexture(tar:pSDL_Surface;x,y:integer;sur:PTMWTexture);
begin
   with sur^ do
   begin
      r_RECT^.x:=x;
      r_RECT^.y:=y;
      r_RECT^.w:=sur^.w;
      r_RECT^.h:=sur^.h;
      SDL_BLITSURFACE(surf,nil,tar,r_RECT);
   end;
end;

procedure _draw_surf(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   r_RECT^.x:=x;
   r_RECT^.y:=y;
   r_RECT^.w:=sur^.w;
   r_RECT^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,r_RECT);
end;


procedure _draw_text(sur:pSDL_Surface;x,y:integer;s:shortstring;al,chrs:byte;tc:cardinal);
var ss,i,o:byte;
    ix:integer;
     c:char;
    cl:cardinal;
begin
   if(tc=0)then exit;
   ss:=length(s);
   if(ss>0)then
   begin
      if(al in [ta_middle,ta_right])then
      begin
         o:=0;
         for i:=1 to ss do
          if not(s[i] in [tc_player0..tc_player6,tc_purple..tc_default])then o+=1;

         case al of
         ta_middle: ix:=x-((o*font_w)shr 1);
         ta_right : ix:=x- (o*font_w);
         end;
      end
      else ix:=x;

      if(al=ta_chat)and(ss>chrs)
      then i:=ss-chrs
      else i:=1;

      o:=0;
      cl:=tc;
      for i:=i to ss do
      begin
         c:=s[i];

         case c of
         tc_player0..
         tc_player6  : begin cl:=PlayerGetColor(ord(c));if(i<ss)then continue;end;
         tc_nl1..
         tc_nl3      : ;
         tc_purple   : begin cl:=c_purple ;if(i<ss)then continue;end;
         tc_red      : begin cl:=c_red    ;if(i<ss)then continue;end;
         tc_orange   : begin cl:=c_orange ;if(i<ss)then continue;end;
         tc_yellow   : begin cl:=c_yellow ;if(i<ss)then continue;end;
         tc_lime     : begin cl:=c_lime   ;if(i<ss)then continue;end;
         tc_aqua     : begin cl:=c_aqua   ;if(i<ss)then continue;end;
         tc_blue     : begin cl:=c_blue   ;if(i<ss)then continue;end;
         tc_gray     : begin cl:=c_gray   ;if(i<ss)then continue;end;
         tc_white    : begin cl:=c_white  ;if(i<ss)then continue;end;
         tc_green    : begin cl:=c_green  ;if(i<ss)then continue;end;
         tc_default  : begin cl:=tc       ;if(i<ss)then continue;end;
         else
           case c of
            char_detect  : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_purple);
            char_advanced: boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_white );
           else
             boxColor(sur,ix,y,ix+font_iw,y+font_iw,cl);
           end;

           _draw_mwtexture(sur,ix,y,@font_ca[c]);

           o  += 1;
           ix += font_w;
         end;

         if(al=ta_left)then
          if(o>=chrs)or(c in [tc_nl1..tc_nl3])or(i=ss)then
          begin
             if(i<ss)then o:=0;

             ix:=x;
             y +=font_w;
             case c of
             tc_nl1 : y+=2;
             tc_nl2 : y+=txt_line_h2;
             tc_nl3 : y+=txt_line_h;
             else     y+=txt_line_h;
             end;
          end;
      end;
   end;
end;

procedure _LoadingScreen;
begin
   SDL_FillRect(r_screen,nil,0);
   stringColor(r_screen,(vid_vw div 2)-40, vid_vh div 2,@str_loading[1],c_yellow);
   SDL_FLIP(r_screen);
end;



procedure _bmm_draw(sd:TSob);
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t in sd)then
      if(mmr>0)
      then FilledcircleColor(r_bminimap,mmx,mmy,mmr,mmc)
      else pixelColor       (r_bminimap,mmx,mmy,    mmc);
end;

procedure map_bminimap;
begin
   sdl_FillRect(r_bminimap,nil,0);
   _bmm_draw(dids_liquids);
   _bmm_draw([DID_other,DID_srock,DID_brock]);
end;

procedure map_minimap_cpoint(tar:pSDL_Surface;x,y,r:integer;sym:char;color:cardinal);
begin
   circleColor   (tar,x  ,y  ,r  ,color);
   characterColor(tar,x-3,y-3,sym,color);
end;

procedure map_dstarts;
var i  :byte;
    x,y:integer;
    c  :cardinal;
begin
   for i:=0 to MaxPlayers do
   begin
      if(g_mode in [gm_invasion,gm_koth])and(i=0)then continue;

      x:=round(map_psx[i]*map_mmcx);
      y:=round(map_psy[i]*map_mmcx);

      c:=PlayerGetColor(i);

      map_minimap_cpoint(r_minimap,x,y,trunc(base_r*map_mmcx),char_start ,c);
   end;

   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCapturer>0)then
      if((i=0)and(g_mode=gm_koth))or(cpenergy<=0)
      then map_minimap_cpoint(r_minimap,cpmx,cpmy,cpmr,char_cp ,c_purple)
      else map_minimap_cpoint(r_minimap,cpmx,cpmy,cpmr,char_gen,c_white );
end;

procedure map_RedrawMenuMinimap;
begin
   sdl_FillRect(r_minimap,nil,0);
   map_bminimap;
   _draw_surf(r_minimap,0,0,r_bminimap);
   if(g_fixed_positions)then map_dstarts;
   _draw_surf(spr_mback,ui_menu_map_x0,ui_menu_map_y0,r_minimap);
   rectangleColor(spr_mback,ui_menu_map_x0,ui_menu_map_y0,ui_menu_map_x0+r_minimap^.w,ui_menu_map_y0+r_minimap^.h,c_white);
   vid_menu_redraw:=vid_menu_redraw or _menu;
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
   _draw_text(tar,x,y,str,ta,255,color);
end;

function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;
var i,ni,mx,my:integer;
begin
   {
   new  0 - not required new alarm point
        1 -
   return - true if alarm created
   }
   ui_AddMarker:=false;

   ax:=mm3(1,ax,map_mw);
   ay:=mm3(1,ay,map_mw);

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
          //ui_AddMarker:=(mx<(vid_mmvx-vid_uialrm_ti))or((vid_mmvx+map_mmvw+vid_uialrm_ti)<mx)
          //          or(my<(vid_mmvy-vid_uialrm_ti))or((vid_mmvy+map_mmvh+vid_uialrm_ti)<my);
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
aummat_advance,
aummat_upgrade    : al_c:=c_yellow;
aummat_info       : al_c:=c_white;
       end;
       ui_AddMarker:=true;
    end;
end;

{

lmt_chat0              = 0;  = player humber
lmt_chat1              = 1;
lmt_chat2              = 2;
lmt_chat3              = 3;
lmt_chat4              = 4;
lmt_chat5              = 5;
lmt_chat6              = 6;
lmt_game_message       = 10;
lmt_game_end           = 11;
lmt_player_defeated    = 12;
lmt_player_leave       = 13;
lmt_cant_build         = 14;
lmt_unit_ready         = 15;
lmt_unit_advanced      = 16;
lmt_upgrade_complete   = 17;
lmt_req_energy         = 18;
lmt_req_common         = 19;
lmt_req_ruids          = 20;
lmt_player_chat        = 255;
}

function LogMes2UIAlarm:boolean;
begin
   // true  - need announcer sound
   // false - no need announcer sound
   LogMes2UIAlarm:=true;
   with _players[HPlayer] do
    with log_l[log_i] do
     case mtype of
lmt_unit_advanced    :      ui_AddMarker(xi,yi,aummat_advance,true);
lmt_unit_ready       : if(_uids[uid]._ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_created_b,true)
                       else ui_AddMarker(xi,yi,aummat_created_u,true);
lmt_upgrade_complete :      ui_AddMarker(xi,yi,aummat_upgrade,true);
lmt_map_mark         :      ui_AddMarker(xi,yi,aummat_info   ,true);
lmt_unit_attacked    : LogMes2UIAlarm:=not PointInCam(xi,yi);
     end;
end;


