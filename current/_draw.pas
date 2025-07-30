
function d_UpdateUIPlayer(u:integer):boolean;
var tu:PTUnit;
function TryUpd(pplayer:pbyte):boolean;
begin
   TryUpd:=false;
   if(IsUnitRange(u,@tu))then
   begin
      pplayer^:=tu^.playeri;
      TryUpd  :=true;
   end;
end;
begin
   d_UpdateUIPlayer:=false;
   if(not g_players[LocalPlayer].observer)and(not Game_IsEnded)and(rpls_pstate<rpls_read)
   then UIPlayer:=LocalPlayer
   else d_UpdateUIPlayer:=TryUpd(@UIPlayer);
end;

procedure d_AddObjSprites(noanim:boolean);
begin
 doodads_sprites(noanim);
    unit_sprites(noanim);
 effects_sprites(noanim,vid_draw);
 if(not vid_draw)then exit;
missiles_sprites;
 cpoints_sprites;
end;

procedure d_Game;
begin
   d_UpdateUIPlayer(0);

   D_AddObjSprites(G_Status>gs_running);

   D_terrain   (vid_screen,ui_mapx,ui_mapy);
   D_SpriteList(vid_screen,ui_mapx,ui_mapy);
   D_Fog       (vid_screen,ui_mapx,ui_mapy);
   D_UnitsInfo (vid_screen,ui_mapx,ui_mapy);
   D_ui        (vid_screen,ui_mapx,ui_mapy);

   draw_sdlsurface(vid_screen,ui_panelx,ui_panely,ui_uipanel);

   d_UIMouseBaseBrush(vid_screen);

   if(TestMode>1)and(net_status=0)then _draw_dbg;
end;


procedure GameDraw;
var i,n:integer;
begin
   ui_blink_timer1+=1;ui_blink_timer1:=ui_blink_timer1 mod ui_blink_period1;
   ui_blink_timer2+=1;ui_blink_timer2:=ui_blink_timer2 mod ui_blink_period2;

   if(ui_blink_timer1=0)then
   begin
      ui_blink3+=1;
      ui_blink3:=ui_blink3 mod 4;
   end;

   ui_blink1_colorb  :=ui_blink_timer1>ui_blink_periodh;
   ui_blink2_colorb  :=ui_blink_timer2>ui_blink_period1;

   ui_blink1_color_BG:=ui_blink_color1[ui_blink1_colorb];
   ui_blink1_color_BY:=ui_blink_color2[ui_blink1_colorb];
   ui_blink2_color_BG:=ui_blink_color1[ui_blink2_colorb];
   ui_blink2_color_BY:=ui_blink_color2[ui_blink2_colorb];

   sdl_FillRect(vid_screen,nil,0);

   if(MainMenu)
   then d_Menu
   else d_Game;

   //_drawMWSModel(@spr_HCommandCenter);

   if(TestMode>1)then
   begin
   n:=0;
   with g_players[UIPlayer] do
    for i:=0 to LastPlayer do
     with ai_alarms[i] do
      if(aia_enemy_limit>0)then n+=1;

   draw_text(vid_screen,ui_cam_w+ui_mapx,ui_cam_h-10,
       c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')'+
   ' '+b2c[ui_uibtn_sabilityu=nil]+
   ' '+b2c[ui_uibtn_pabilityu=nil]+
   //' '+b2c[ui_fog_CheckXY(mouse_map_x-ui_cam_x,mouse_map_y-ui_cam_y,@i,@n)]+   MapPointInScreenP(mouse_map_x,mouse_map_y,true)
   ' '+i2s(i)+' '+i2s(n)
   {' '+i2s(mouse_map_x div pf_pathmap_w)+
   ' '+i2s(mouse_map_y div pf_pathmap_w)+
   ' '+tc_green+w2s(pf_pathgrid_areas[mm3i(0,mouse_map_x div pf_pathmap_w,pf_pathmap_c),mm3i(0,mouse_map_y div pf_pathmap_w,pf_pathmap_c)])+tc_default+
   ' '+tc_aqua+i2s(g_players[UIPlayer].ai_scout_timer)+
   ' '+tc_orange+i2s(g_players[UIPlayer].ai_attack_timer)+
   ' '+tc_green+b2c[g_players[UIPlayer].ai_ReadyForAttack]}
   ,
   ta_right,255, c_white);

   draw_text(vid_screen,ui_cam_w+ui_mapx,ui_cam_h-20,
       i2s(mouse_map_x)+
   ' '+i2s(mouse_map_y),
   ta_right,255, c_white);

   draw_text(vid_screen,ui_cam_w+ui_mapx,ui_cam_h-30,
       i2s(rpls_pstate)+
   ' '+i2s(rpls_fstate),
   ta_right,255, c_white);
   end;

   sdl_flip(vid_screen);
end;



