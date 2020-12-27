

procedure d_AddObjSprites(noanim:boolean);
begin
   map_sprites(noanim);
end;

procedure d_Game;
begin
   d_AddObjSprites(G_Paused>0);

   d_terrain   (r_screen,vid_mapx,vid_mapy);
   d_SpriteList(r_screen,vid_mapx,vid_mapy);
   d_fog       (r_screen,vid_mapx,vid_mapy);
   d_ui        (r_screen,vid_mapx,vid_mapy);

   _draw_surf(r_screen,vid_panelx,vid_panely,r_uipanel);

   d_uimouse(r_screen);

   if(_testmode>1)and(net_nstat=0)then _draw_dbg;
end;


procedure DrawGame;
begin
   sdl_FillRect(r_screen,nil,0);

   if(_menu)
   then d_Menu
   else d_Game;

   _drawMWSModel(@spr_LostSoul);

   if(_testmode>0)then _draw_text(r_screen,vid_sw,0,c2s(fps_tt), ta_right,255, c_white);

   sdl_flip(r_screen);
end;



