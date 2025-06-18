
function d_CheckUIPlayer(u:integer):boolean;
var tu:PTUnit;
begin
   d_CheckUIPlayer:=false;
   if(not g_players[PlayerClient].isobserver)and(rpls_rstate<rpls_state_read)
   then UIPlayer:=PlayerClient
   else
     if(IsIntUnitRange(u,@tu))then
     begin
        UIPlayer:=tu^.playeri;
        d_CheckUIPlayer:=true;
     end;
end;

procedure d_UI_ClearCounters;
var u:byte;
begin
   for u:=0 to 255 do
   begin
      ui_uid_reload [u]:=-1;
      ui_bucl_reload[u]:=-1;
   end;
   FillChar(ui_bprod_uid_count  ,SizeOf(ui_bprod_uid_count  ),0);
   FillChar(ui_bprod_ucl_count  ,SizeOf(ui_bprod_ucl_count  ),0);
   FillChar(ui_bprod_ucl_time   ,SizeOf(ui_bprod_ucl_time   ),0);
   FillChar(ui_uprod_uid_time   ,SizeOf(ui_uprod_uid_time   ),0);
   FillChar(ui_uprod_uid_max    ,SizeOf(ui_uprod_uid_max    ),0);
   FillChar(ui_pprod_max        ,SizeOf(ui_pprod_max        ),0);
   FillChar(ui_pprod_time       ,SizeOf(ui_pprod_time       ),0);
   FillChar(ui_units_InTransport,SizeOf(ui_units_InTransport),0);
   FillChar(ui_groups_d         ,SizeOf(ui_groups_d         ),0);
   FillChar(ui_groups_f1        ,SizeOf(ui_groups_f1        ),0);
   FillChar(ui_groups_f2        ,SizeOf(ui_groups_f2        ),0);

   ui_uprod_max      :=0;
   ui_uprod_cur      :=0;
   ui_uprod_first    :=0;
   ui_pprod_first    :=0;
   ui_uibtn_abilityu :=nil;
   ui_uibtn_move     :=0;
   ui_bprod_possible :=[];
   ui_bprod_first    :=0;
   ui_bprod_all      :=0;

   if(ui_umark_t>0)then
   begin
      ui_umark_t-=1;
      if(ui_umark_t=0)then ui_umark_u:=0;
   end;
end;

procedure d_AddObjSprites(noanim:boolean);
begin
   d_SpriteListAddUnits  (noanim);
   d_SpriteListAddEffects(noanim,r_draw);

   if(not r_draw)then exit;

   d_SpriteListAddMissiles;
   d_SpriteListAddCPoints;
end;

procedure d_Game;
var lsx,lsy:single;
begin
   vid_blink_timer1+=1;vid_blink_timer1:=vid_blink_timer1 mod vid_blink_period1;
   vid_blink_timer2+=1;vid_blink_timer2:=vid_blink_timer2 mod vid_blink_period2;

   if(vid_blink_timer1=0)then
   begin
      vid_blink3+=1;
      vid_blink3:=vid_blink3 mod 4;
   end;

   vid_PanelUpdTimer+=1;vid_PanelUpdTimer:=vid_PanelUpdTimer mod ui_panel_UpdateTime;

   vid_blink1_colorb  :=vid_blink_timer1>vid_blink_periodh;
   vid_blink2_colorb  :=vid_blink_timer2>vid_blink_period1;

   vid_blink1_color_BG:=ui_color_blink1[vid_blink1_colorb];
   vid_blink1_color_BY:=ui_color_blink2[vid_blink1_colorb];
   vid_blink2_color_BG:=ui_color_blink1[vid_blink2_colorb];
   vid_blink2_color_BY:=ui_color_blink2[vid_blink2_colorb];

   d_CheckUIPlayer(0);

   d_UI_ClearCounters;

   d_AddObjSprites(G_Status<>gs_running);

   sdl_RenderGetScale(vid_SDLRenderer,@lsx,@lsy);
   sdl_RenderSetScale(vid_SDLRenderer,lsx*vid_cam_sc,lsy*vid_cam_sc);
   draw_set_font(font_base,basefont_w1);
   // MAP View
   d_MapTerrain;
   d_SpriteList;

   if(ui_fog)then
   D_Fog;

   d_UIInfoItems;

   { if(rpls_rstate<rpls_state_read)then
   begin
   d_UIMouseMapBrush(r_screen,ui_MapView_x,ui_MapView_y);
   d_UIMouseMapClick(r_screen,ui_MapView_x,ui_MapView_y);
   end;    }

   sdl_RenderSetScale(vid_SDLRenderer,lsx,lsy);

   d_UIText;

   // Control bar view
   if(vid_PanelUpdTimer=0)
   or(vid_PanelUpdNow    )then d_UpdatePanel;
   if(vid_PanelUpdTimer=1)then d_UpdateMinimap;

   draw_set_color(c_white);
   draw_mwtexture2(ui_ControlBar_x,ui_ControlBar_y,tex_ui_ControlBar,ui_ControlBar_w,ui_ControlBar_h);
   draw_mwtexture2(ui_MiniMap_x   ,ui_MiniMap_y   ,tex_ui_MiniMap1  ,ui_MiniMap_w   ,ui_MiniMap_w   );

   if(mouse_select_x0>-1)then
   begin
      if(UIPlayer<=LastPlayer)
      then draw_set_color(PlayerColorNormal[UIPlayer])
      else draw_set_color(c_white);
      draw_rect(mouse_select_x0, mouse_select_y0, mouse_x, mouse_y);
   end;
 //  d_UIMouseCursor(r_screen);

   if(test_mode>1)and(net_status=ns_single)then _draw_dbg;
end;

procedure draw_DebugTileSet(tileSet:pTMWTileSet);
const lineLen = 24;
var tileX,
x,y,lineN:integer;
begin
   x:=20;
   y:=20;
   lineN:=lineLen;
   //boxColor(r_screen,0,0,vid_vw,vid_vh,c_green);
   for tileX:=0 to MaxTileSet do
   begin

      draw_mwtexture1(x,y,tileSet^[tileX],1,1);
      //draw_surf(r_screen,x,y,tileSet^[tileX].apidata);

      draw_set_font(font_Base,basefont_w1);
      draw_text_line(x,y,w2s(tileX),ta_LU,255,0);
      x+=tileSet^[tileX]^.w+2;

      lineN-=1;
      if(lineN=0)then
      begin
         x:=20;
         lineN:=lineLen;
         y+=tileSet^[0]^.h+2;
      end;
   end;

   //draw_surf(r_screen,x,y,vid_fog_BaseSurf);
end;



procedure MainDraw;
var i,n,y:integer;
begin
   draw_set_color(c_black);
   draw_set_alpha(255);
   draw_clear;

   {draw_set_color(c_ltgray);
   draw_frect(vid_vw,vid_vh,0,0);

   draw_set_color(c_white);
   draw_mwtexture1(0,0,spr_mback,1,1);

   {draw_set_color(c_red);
   draw_line(0,0,500,500);      }

   draw_set_color(c_yellow);
   draw_text_line(50,50,'ABCDabcd 123456789 $#^$ .   !',ta_LU,255,c_green);
   draw_mwtexture1(500,300,@tex_ui_MiniMap,1,1);
   draw_mwtexture1(0,0,@spr_mlogo,1,1);
   spr_mlogo

   draw_set_color(c_white);
   draw_set_alpha(255);
   draw_DebugTileSet(ui_fog_tileset);    }

   //draw_set_alpha(127);
   //_drawMWSModel(spr_lostsoul);

  // draw_set_color(c_red);

   //draw_fcircle(300,300,100);
   {draw_ellipse(300,300,0  ,100);
   draw_ellipse(300,600,100,50);
   draw_frect(300,600,305,605);

   draw_set_color(c_aqua);
   draw_ellipse (600,300,100,0);
   draw_fellipse(600,600,50,100);

   draw_set_color(c_red);
   draw_ellipse(900,300,0,0); }

   UpdatePlayerColors;

   if(menu_state)
   then d_Menu
   else
     if(G_Started)
     then d_Game;

   //draw_DebugTileSet(theme_tileset_liquid[(SDL_GetTicks div 1000) mod theme_anim_step_n]);

   draw_set_color(c_white);
   draw_mwtexture1(mouse_x,mouse_y,spr_cursor,1,1);

   //_drawMWSModel(@spr_HCommandCenter1);

   {i:=10;
   draw_surf(r_screen,i,i,theme_tile_terrain);
   rectangleColor(r_screen,i,i,i+MapCellW,i+MapCellW,c_red);

   i+=MapCellW+10;
   draw_surf(r_screen,i,i,theme_tile_crater);
   rectangleColor(r_screen,i,i,i+MapCellW,i+MapCellW,c_red);

   i+=MapCellW+10;
   draw_surf(r_screen,i,i,theme_tile_liquid);
   rectangleColor(r_screen,i,i,i+MapCellW,i+MapCellW,c_red);   }

   //draw_surf(r_screen,0,0,theme_tile_liquid.sdlsurface);
   //if(kt_ctrl=0)then
   //draw_DebugTileSet(@vid_fog_tiles);
  { y:=0;
   n:=0;
   if(theme_cur_decor_n>0)then
    for i:=0 to theme_cur_decor_n-1 do
    begin
       n:=i*48;
       draw_surf(r_screen,n,y,theme_all_decor_l[theme_cur_decor_l[i]].apidata);
    end;
   draw_line(r_screen,0,0,i2s(theme_cur_decor_n),ta_LU,255,c_white); }

  { n:=0;
   y:=0;
   if(theme_all_terrain_n>0)then
     for i:=0 to theme_all_terrain_n-1 do
     begin
        draw_surf(r_screen,n,y,theme_all_terrain_l[i].apidata);
        boxColor (r_screen,n,y,n+16,y+16,theme_all_terrain_mmcolor[i]);
        draw_line(r_screen,n,y+16,i2s(i),ta_LU,255,c_white);

        n+=theme_all_terrain_l[i].w;
        if((n+theme_all_terrain_l[i].w)>=vid_vw)then
        begin
           n:=0;
           y+=128;
        end;
     end;   }

   if(test_mode>1)then
   begin
      //Vector1Calc(128,128,mouse_map_x,mouse_map_y,@debug_x0,@debug_y0);
      //circleColor(r_screen,(128-vid_cam_x),(128-vid_cam_y),10,c_white);
      //lineColor(r_screen,(128-vid_cam_x),(128-vid_cam_y),(128-vid_cam_x)+debug_x0*128,(128-vid_cam_y)+debug_y0*128,c_lime);

      {if(kt_ctrl>0)then
        pushOut_GridUAction(@debug_x0,@debug_y0,10,debug_zone);
      circleColor(r_screen,(debug_x0-vid_cam_x),(debug_y0-vid_cam_y),5,c_white); }

   {mgcell2NearestXY(mouse_map_x,mouse_map_y,debug_x0,debug_y0,debug_x0+MapCellW,debug_y0+MapCellW,MapCellhW,@n,@y);
   circleColor(r_screen,mouse_x,mouse_y,MapCellhW,c_lime);
   circleColor(r_screen,(n-vid_cam_x),(y-vid_cam_y),5,c_white);  }

   if(G_Started)then
   begin

   draw_set_color(c_white);
   draw_set_font(font_base,basefont_w2);
   draw_text_line(vid_vw,vid_vh-basefont_w1h,
       c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')'+
   //' '+str_b2c[ui_MapPointInRevealedInScreen(mouse_map_x,mouse_map_y)]+
   ' '+Float2Str(vid_cam_sc)+
   ' '+i2s(mouse_map_x)+
   ':'+i2s(mouse_map_y)+
   //' '+i2s(mouse_map_x div MapCellW)+
   //' '+i2s(mouse_map_y div MapCellW)+
   //' L'+i2s(map_csize)+
   //' C'+i2s(map_chsize)+
   //' r0: '+tc_green+i2s(debug_r0)+
   //' r1: '+tc_blue+i2s(debug_r1)+

   //' '+tc_green+w2s(map_GetZone(mouse_map_x,mouse_map_y,true))+tc_default+
   //' '+tc_aqua+i2s(g_players[UIPlayer].ai_scout_timer)+
   //' '+tc_orange+i2s(g_players[UIPlayer].upgr[upgr_fog_vision])+
   //' '+tc_green+str_b2c[g_players[UIPlayer].isobserver]+
   //' '+tc_gray+i2s(m_panelBtn_x)+
   //' '+tc_gray+i2s(m_panelBtn_y)+
   //' '+tc_lime+i2s(dist2mgcellC(mouse_map_x,mouse_map_y,1,1))
   ' '+b2s(G_Status)+
   ' '+str_b2c[G_Started]+
   ' '+str_b2c[ServerSide]+
   ' '+c2s(G_Step),ta_RD,255, c_none);

   {draw_line(r_screen,ui_MapView_x+vid_cam_w,ui_MapView_y+vid_cam_h-20,
       i2s(m_panelBtn_x)+
   ' '+i2s(m_panelBtn_y),
   ta_RU,255, c_white);    }

  { draw_line(r_screen,vid_cam_w+vid_mapx,vid_cam_h-30,
       i2s(rpls_rstate)+
   ' '+i2s(rpls_fstate),
   ta_RU,255, c_white)   }

   end;
   end;
   //draw_DebugTileSet(@vid_fog_tiles);

   SDL_RenderPresent(vid_SDLRenderer);
end;



