
function d_UpdateUIPlayer(u:integer):boolean;
var tu:PTUnit;
function TryUpd(pplayer:pbyte):boolean;
begin
   TryUpd:=false;
   if(_IsUnitRange(u,@tu))then
   begin
      pplayer^:=tu^.playeri;
      TryUpd  :=true;
   end;
end;
begin
   d_UpdateUIPlayer:=false;
   if(rpls_state>=rpl_rhead)then
   begin
      //d_UpdateUIPlayer:=TryUpd(@HPlayer);
      //UIPlayer:=HPlayer;
      d_UpdateUIPlayer:=TryUpd(@UIPlayer);
   end
   else
     if(not _players[HPlayer].observer)
     then UIPlayer:=HPlayer
     else d_UpdateUIPlayer:=TryUpd(@UIPlayer);
end;

procedure d_AddObjSprites(noanim:boolean);
begin
 doodads_sprites(noanim);
    unit_sprites(noanim);
 effects_sprites(noanim,r_draw);
missiles_sprites(r_draw);
 cpoints_sprites(r_draw);
end;

procedure d_Game;
begin
   d_UpdateUIPlayer(0);

   D_AddObjSprites(G_Status>gs_running);

   D_terrain   (r_screen,vid_mapx,vid_mapy);
   D_SpriteList(r_screen,vid_mapx,vid_mapy);
   D_Fog       (r_screen,vid_mapx,vid_mapy);
   D_UnitsInfo (r_screen,vid_mapx,vid_mapy);
   D_ui        (r_screen,vid_mapx,vid_mapy,UIPlayer);

   _draw_surf(r_screen,vid_panelx,vid_panely,r_uipanel);

   d_uimouse(r_screen);

   if(_testmode>1){and(net_status=0)}then _draw_dbg;
end;


procedure DrawGame;
var i,n:integer;
begin
   sdl_FillRect(r_screen,nil,0);

   if(_menu)
   then d_Menu
   else d_Game;

   //_drawMWSModel(@spr_HCommandCenter);

   if(_testmode>0)then
   begin
   n:=0;
   with _players[HPlayer] do
    for i:=0 to MaxPlayers do
     with ai_alarms[i] do
      if(aia_enemy_limit>0)then n+=1;

   _draw_text(r_screen,vid_cam_w+vid_mapx,vid_cam_h-10,
       c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')'+
   ' '+b2c[PointInScreenP(mouse_map_x,mouse_map_y)]+
   ' '+i2s(mouse_map_x div pf_pathmap_w)+
   ' '+i2s(mouse_map_y div pf_pathmap_w)+
   ' '+tc_green+w2s(pf_pathgrid_areas[mm3(0,mouse_map_x div pf_pathmap_w,pf_pathmap_c),mm3(0,mouse_map_y div pf_pathmap_w,pf_pathmap_c)])+tc_default+
   ' '+i2s(n),
   ta_right,255, c_white);

   _draw_text(r_screen,vid_cam_w+vid_mapx,vid_cam_h-20,
       i2s(mouse_map_x)+
   ' '+i2s(mouse_map_y),
   ta_right,255, c_white);
   end;

   sdl_flip(r_screen);
end;



