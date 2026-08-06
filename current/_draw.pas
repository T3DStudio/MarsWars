
procedure draw_AddAllSprites(noanim:boolean);
begin
  obstacles_AddSprites(noanim);
     unit_AddSpritesAndMarks(noanim);
  effects_AddSprites(noanim);
 missiles_AddSprites;
keyPoints_AddSprites;
end;

procedure draw_Game;
begin
   ui_UpdateUIPlayer(0);
   PlayersUpdateColorSchema(UIPlayer);

   ui_DrawEdges:=ui_MouseBrushNeedDrawEdges;

   draw_AddAllSprites(g_status<>gs_running);

   draw_LayerTerrain   (vid_screen);
   {$IFDEF TESTMODE}
   test_w :=vid_ScreenSpritesS;
   {$ENDIF}
   draw_LayerSpriteList(vid_screen);

   if (ui_fog)
   and(ui_fog_gridw>0)
   and(ui_fog_gridh>0)then
   draw_LayerFog      (vid_screen);

   draw_LayerUnitsInfo(vid_screen);
   draw_LayerUI       (vid_screen);
   {$IFDEF TESTMODE}
   if(TestMode>1)and(net_status=0)then draw_debug;
   {$ENDIF}
end;

procedure game_Draw;
var n:integer;
begin
   ui_blink_timer1+=1;ui_blink_timer1:=ui_blink_timer1 mod ui_blink_period1;
   ui_blink_timer2+=1;ui_blink_timer2:=ui_blink_timer2 mod ui_blink_period2;

   //ui_update_timer+=1;ui_update_timer:=ui_update_timer mod ui_update_period1;

   if(ui_blink_timer1=0)then
   begin
      ui_blink3+=1;
      ui_blink3:=ui_blink3 mod 4;
   end;

   ui_blink1_colorb  :=ui_blink_timer1>ui_blink_periodh;
   ui_blink2_colorb  :=ui_blink_timer2>ui_blink_period1;

 //ui_blink1_color_BG:=ui_blink_color1[ui_blink1_colorb];
 //ui_blink1_color_BY:=ui_blink_color2[ui_blink1_colorb];
   ui_blink2_color_BG:=ui_blink_color1[ui_blink2_colorb];
   ui_blink2_color_BY:=ui_blink_color2[ui_blink2_colorb];

   sdl_FillRect(vid_screen,nil,0);


   if(MainMenu)
   then draw_Menu
   else draw_Game;

   //_drawMWSModel(@spr_HCommandCenter);
   {$IFDEF TESTMODE}
   if(TestMode>1)then
   begin

     { if(InputAction(iact_Alt))then
      begin
         writeln(LocalPlayer);
        for i:=0 to LastPlayer do
          with g_PlayersGame[i] do
            writeln(i,' ',isobserver,' ',isdefeated);
      end;   }

      //
     // for i:=0 to fog_TileSetSize do
      //  draw_sdlsurface(vid_screen,20+i*fog_cr*2,20,ui_fog_Tiles[i] );

   {n:=0;
   if(UIPlayer<=LastPlayer)then
    with g_PlayersGame[UIPlayer] do
     for i:=0 to LastPlayer do
      with ai_alarms[i] do
       if(aia_enemy_limit>0)then n+=1;  }





     draw_text(vid_screen,ui_cam_w,ui_cam_h,
     i2s(m_brush),
     ta_RB,255, c_white);

     n:=50;

   draw_text(vid_screen,ui_cam_w,ui_cam_h-30,
    w2s(test_w)+' '+tc_nl1+
  //     c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')'+
  // ' '+b2c[ui_uibtn_sabilityu=nil]+
   //' '+b2c[ui_uibtn_pabilityu=nil]+
   //' '+b2c[ui_fog_CheckXY(mouse_map_x-ui_cam_x,mouse_map_y-ui_cam_y,@i,@n)]+   ui_CheckMapPointFogVision(mouse_map_x,mouse_map_y,true)
   ' '+tc_green+w2s(map_GetZone(mouse_map_x,mouse_map_y))+
   ' '+tc_aqua+b2s(menu_ItemSelected)+' '+b2c[map_BusyCenter]
   {' '+i2s(mouse_map_x div pf_pathmap_w)+
   ' '+i2s(mouse_map_y div pf_pathmap_w)+
   ' '+tc_green+w2s(pf_pathgrid_areas[mm3i(0,mouse_map_x div pf_pathmap_w,pf_pathmap_c),mm3i(0,mouse_map_y div pf_pathmap_w,pf_pathmap_c)])+tc_default+
   ' '+tc_aqua+i2s(g_PlayersGame[UIPlayer].ai_scout_timer)+
   ' '+tc_orange+i2s(g_PlayersGame[UIPlayer].ai_attack_timer)+
   ' '+tc_green+b2c[g_PlayersGame[UIPlayer].ai_ReadyForAttack]}
   ,
   ta_RB,255, c_white);

   {draw_text(vid_screen,ui_cam_w,ui_cam_h-20,
       i2s(mouse_map_x)+
   ' '+i2s(mouse_map_y),
   ta_RU,255, c_white);   }

  { draw_text(vid_screen,ui_cam_w,ui_cam_h-30,
       i2s(rpls_pstate)+
   ' '+i2s(rpls_fstate),
   ta_RU,255, c_white);   }

  { circleColor(vid_screen,ui_UIPortX0,ui_UIPortY0,10,c_lime);
   circleColor(vid_screen,ui_UIPortX1,ui_UIPortY1,10,c_aqua); }
   end;
   {$ENDIF}

   sdl_flip(vid_screen);
end;



