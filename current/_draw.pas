
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
   if(not g_players[PlayerClient].isobserver)and(rpls_state<rpls_state_read)
   then UIPlayer:=PlayerClient
   else d_UpdateUIPlayer:=TryUpd(@UIPlayer);
end;

procedure d_AddObjSprites(noanim:boolean);
begin
 //doodads_sprites(noanim);
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
   if(sys_fog)then
   D_Fog       (r_screen,vid_mapx,vid_mapy);
   D_UnitsInfo (r_screen,vid_mapx,vid_mapy);
   D_ui        (r_screen,vid_mapx,vid_mapy,UIPlayer);

   draw_surf(r_screen,vid_panelx,vid_panely,r_uipanel);

   d_uimouse(r_screen);

   if(test_mode>1)and(net_status=ns_single)then _draw_dbg;
end;

procedure draw_DebugTileSet(tileSet:pTMWTileSet);
var tileX:word;
x,y,lineN:integer;
begin
   x:=menu_x+20;
   y:=menu_y+20;
   lineN:=8;
   boxColor(r_screen,menu_x,menu_y,menu_x+800,menu_y+600,c_white);
   for tileX:=0 to MaxTileSet do
   begin

      draw_surf(r_screen,x,y,tileSet^[tileX].sdlSurface);

      draw_text(r_screen,x,y,w2s(tileX),ta_left,255,c_white);
      x+=tileSet^[tileX].w+2;

      lineN-=1;
      if(lineN=0)then
      begin
         x:=menu_x+2;
         lineN:=8;
         y+=tileSet^[0].h+2;
      end;
   end;

   //draw_surf(r_screen,x,y,vid_fog_BaseSurf);
end;

procedure DrawGame;
var i,n,y:integer;
begin
   sdl_FillRect(r_screen,nil,0);

   if(menu_state)
   then d_Menu
   else d_Game;

   //_drawMWSModel(@spr_HCommandCenter);

   {i:=10;
   draw_surf(r_screen,i,i,theme_tile_terrain);
   rectangleColor(r_screen,i,i,i+MapCellW,i+MapCellW,c_red);

   i+=MapCellW+10;
   draw_surf(r_screen,i,i,theme_tile_crater);
   rectangleColor(r_screen,i,i,i+MapCellW,i+MapCellW,c_red);

   i+=MapCellW+10;
   draw_surf(r_screen,i,i,theme_tile_liquid);
   rectangleColor(r_screen,i,i,i+MapCellW,i+MapCellW,c_red);   }

   {if(ks_ctrl=0)then
   draw_DebugTileSet(@theme_tileset_liquid[ (SDL_GetTicks div 250) mod theme_anim_step_n ]);
   draw_text(r_screen,menu_x,menu_y,b2s( (SDL_GetTicks div 250) mod theme_anim_step_n ),ta_left,255,c_orange);  }

  { n:=0;
   y:=0;
   if(theme_all_terrain_n>0)then
     for i:=0 to theme_all_terrain_n-1 do
     begin
        draw_surf(r_screen,n,y,theme_all_terrain_l[i].sdlSurface);
        boxColor (r_screen,n,y,n+16,y+16,theme_all_terrain_mmcolor[i]);
        draw_text(r_screen,n,y+16,i2s(i),ta_left,255,c_white);

        n+=theme_all_terrain_l[i].w;
        if((n+theme_all_terrain_l[i].w)>=vid_vw)then
        begin
           n:=0;
           y+=128;
        end;
     end;   }

   if(test_mode>1)then
   begin
   n:=0;
   with g_players[UIPlayer] do
    for i:=0 to MaxPlayers do
    begin
       with ai_alarms[i] do
        if(aia_enemy_limit>0)then n+=1;
       circleColor(r_screen,vid_mapx+map_PlayerStartX[i]-vid_cam_x,
                            vid_mapy+map_PlayerStartY[i]-vid_cam_y,base_1r,c_white);
    end;

   draw_text(r_screen,vid_cam_w+vid_mapx,vid_cam_h-10,
       c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')'+
   ' '+str_b2c[ui_MapPointInRevealedInScreen(mouse_map_x,mouse_map_y)]+
   ' '+i2s(mouse_map_x div fog_CellW)+
   ' '+i2s(mouse_map_y div fog_CellW)+
  // ' '+tc_green+w2s(pf_pathgrid_areas[mm3i(0,mouse_map_x div pf_pathmap_w,pf_pathmap_c),mm3i(0,mouse_map_y div pf_pathmap_w,pf_pathmap_c)])+tc_default+
   ' '+tc_aqua+i2s(g_players[UIPlayer].ai_scout_timer)+
   ' '+tc_orange+i2s(g_players[UIPlayer].upgr[upgr_fog_vision])+
   ' '+tc_green+str_b2c[g_players[UIPlayer].isobserver]+
   ' '+tc_gray+i2s(m_bx)+
   ' '+tc_gray+i2s(m_by)+
   ' '+tc_lime+i2s(dist2mgcell(mouse_map_x,mouse_map_y,1,1)),

   ta_right,255, c_white);

   draw_text(r_screen,vid_cam_w+vid_mapx,vid_cam_h-20,
       i2s(mouse_map_x)+
   ' '+i2s(mouse_map_y),
   ta_right,255, c_white);

   draw_text(r_screen,vid_cam_w+vid_mapx,vid_cam_h-30,
       i2s(rpls_state)+
   ' '+i2s(rpls_fstatus),
   ta_right,255, c_white);

   //draw_DebugTileSet(@vid_fog_tiles);
   end;

   sdl_flip(r_screen);
end;



