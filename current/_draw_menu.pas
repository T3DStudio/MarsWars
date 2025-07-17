

function mic(enbl,sel:boolean):cardinal;
begin
   mic:=c_white;
   if(enbl=false)then mic:=c_gray
   else
     if(sel)then mic:=c_yellow;
end;

procedure D_MMap(tar:pSDL_Surface);
var c:boolean;
    i:integer;
function _yt(s:integer):integer;begin _yt:=ui_menu_map_y0+s*ui_menu_map_ys+6; end;
begin
   draw_text(tar, 229, 96, str_MMap, ta_middle,255, c_white);

   boxColor(tar,
   ui_menu_map_rx0,ui_menu_map_y0,
   ui_menu_map_rx1,ui_menu_map_y1,
   c_black);

   if(menu_s2<>ms2_camp)then
   begin
      i:=ui_menu_map_y0+ui_menu_map_ys;
      while(i<ui_menu_map_y1)do
      begin
         hlineColor(tar,ui_menu_map_rx0,ui_menu_map_rx1,i,c_gray);
         i+=ui_menu_map_ys;
      end;

      c:=menu_GameSettingsEnabled;

      draw_text(tar,ui_menu_map_tx1,_yt(0), c2s(map_seed)+chat_type[menu_item<>50], ta_middle,255, mic(c,menu_item=50));
      draw_text(tar,ui_menu_map_tx0,_yt(1), str_m_siz+i2s(map_mw)                 , ta_left  ,255, mic(c,false));
      draw_text(tar,ui_menu_map_tx0,_yt(2), str_m_obs+_str_mx(map_obs)            , ta_left  ,255, mic(c,false));
      draw_text(tar,ui_menu_map_tx0,_yt(3), str_m_sym+b2cc[map_symmetry]          , ta_left  ,255, mic(c,false));

      draw_text(tar,ui_menu_map_tx1,_yt(6), str_mrandom                           , ta_middle,255, mic(c,false));
      draw_text(tar,ui_menu_map_tx1,_yt(7), theme_name[theme_i]                   , ta_middle,255, c_white     );
   end
   else
   begin
      draw_sdlsurface(tar, ui_menu_map_x0+1,ui_menu_map_y0+1,cmp_mmap[cmp_sel]);
      draw_text(tar,ui_menu_map_tx0,_yt(0),str_camp_map[cmp_sel], ta_left,255, c_white);
   end;

   rectangleColor(tar,
   ui_menu_map_rx0,ui_menu_map_y0,
   ui_menu_map_rx1,ui_menu_map_y1,
   c_white);
end;

procedure D_MPlayers(tar:pSDL_Surface);
var y,p,u:integer;
function _yl(s:integer):integer;begin _yl:=s*ui_menu_pls_ys; end;
function _yt(s:integer):integer;begin _yt:=_yl(s)+6; end;
begin
   if(menu_s2<>ms2_camp)then
   begin
      draw_text(tar, ui_menu_pls_xc, 96, str_MPlayers, ta_middle,255, c_white);

      vlineColor(tar, ui_menu_pls_zxs, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxr, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxt, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxc, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );

      y:=ui_menu_pls_zy0-10;
      draw_text(tar,ui_menu_pls_zxnt ,y,str_PTPlayer, ta_left  , 255, c_ltgray);
      draw_text(tar,ui_menu_pls_zxr  ,y,str_PTState , ta_right , 255, c_ltgray);
      draw_text(tar,ui_menu_pls_zxrt ,y,str_PTRace  , ta_middle, 255, c_ltgray);
      draw_text(tar,ui_menu_pls_zxtt ,y,str_PTTeam  , ta_middle, 255, c_ltgray);
      draw_text(tar,ui_menu_pls_zxct ,y,str_PTColor , ta_middle, 255, c_ltgray);
      if(net_status<>ns_none)then
      draw_text(tar,ui_menu_pls_zxct ,y-10,str_PTPing,ta_middle, 255, c_ltgray);

      for p:=1 to MaxPlayers do
       with g_players[p] do
       begin
          y:=ui_menu_pls_zy0+_yl(p-1);
          u:=y+6;

          hlineColor(tar,ui_menu_pls_zxn,ui_menu_pls_zxe,y,c_gray);

          if(state<>ps_none)then
          begin
             draw_text(tar,ui_menu_pls_zxnt, u,name                , ta_left  , 255, c_white);
             draw_text(tar,ui_menu_pls_zxst, u,PlayerGetStatus(p)  , ta_middle, 255, mic(PlayerAIToggle(p,true),false));

             if(team=0)
             then draw_text(tar,ui_menu_pls_zxrt, u,str_observer   , ta_middle, 255, c_gray)
             else draw_text(tar,ui_menu_pls_zxrt, u,str_race[mrace], ta_middle, 255, mic(PlayerRaceChange(p,true     ),false));

             draw_text(tar,ui_menu_pls_zxtt, u,t2c(team)           , ta_middle, 255, mic(PlayerTeamChange(p,true,true),false));

             if(not GetBBit(@g_player_astatus,p))and(G_Started)then lineColor(tar,ui_menu_pls_zxnt,u+4,ui_menu_pls_zxs-6,u+4,c_red);
          end
          else
          begin
             if(g_ai_slots>0)then
             begin
                draw_text(tar,ui_menu_pls_zxnt, u,str_ps_comp+' '+b2s(g_ai_slots)   , ta_left  ,255, c_gray);
                draw_text(tar,ui_menu_pls_zxrt, u,str_race[r_random]                , ta_middle,255, c_gray);
                draw_text(tar,ui_menu_pls_zxtt, u,b2s(PlayerGetFixedTeams(g_mode,p)), ta_middle,255, c_gray);
             end;
             if(not g_started) then
               draw_text(tar,ui_menu_pls_zxst, u,'+', ta_middle, 255, c_lime);
          end;

          boxColor(tar,ui_menu_pls_zxc1,u,ui_menu_pls_zxc2,u+6,PlayerGetColor(p));
       end;

      hlineColor(tar,ui_menu_pls_zxn,ui_menu_pls_zxe,ui_menu_pls_zy0,c_white);
      hlineColor(tar,ui_menu_pls_zxn,ui_menu_pls_zxe,ui_menu_pls_zy1,c_white);

      if(menu_ReadyButtonEnabled)then
      begin
         draw_text(tar,ui_menu_pls_zxnt,ui_menu_pls_zy1+6,str_ready+b2cc[PlayerReady], ta_left, 255, c_white);
         vlineColor(tar,ui_menu_pls_zxs,ui_menu_pls_zy1,ui_menu_pls_y1,c_white);
      end;
   end
   else
   begin
      draw_text(tar,ui_menu_pls_xc, 96, str_MObjectives, ta_middle,255, c_white);
      draw_text(tar,ui_menu_pls_xc, ui_menu_pls_zy0+_yt(-1),str_camp_name[cmp_sel],ta_middle,255,c_yellow);

      if(str_camp_infon[cmp_sel]>0)then
        for y:=0 to vid_campi_m do
        begin
           u:=y+(cmp_minfo_page*vid_campi_scrlstep);
           if(u<str_camp_infon[cmp_sel])then
             draw_text(tar,ui_menu_pls_x0+4, ui_menu_pls_zy0+_yt(0)+y*font_3hw ,str_camp_infol[cmp_sel][u],ta_left,255,c_white);
        end;

      vlineColor(tar,659,92 ,109,c_ltgray);
      vlineColor(tar,699,92 ,109,c_ltgray);
      hlineColor(tar,635,723,109,c_ltgray);

      draw_text(tar, 679, 97 ,i2s(cmp_minfo_page+1)+'/'+i2s(cmp_minfo_lpage+1),ta_middle,255,c_white);
      draw_text(tar, 647, 97 ,'<<',ta_middle,255,mic(cmp_minfo_page>0,false));
      draw_text(tar, 711, 97 ,'>>',ta_middle,255,mic(cmp_minfo_page<cmp_minfo_lpage,false));
   end;
end;

procedure D_M1(tar:pSDL_Surface);
const _set_x0 = ui_menu_ssr_x0+font_w;
var
t,i,y:integer;
function _yl(s:integer):integer;begin _yl:=ui_menu_ssr_y0+s*ui_menu_ssr_ys; end;
function _yt(s:integer):integer;begin _yt:=_yl(s)+6; end;
begin
   hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,ui_menu_ssr_y0+ui_menu_ssr_ys,c_white);

   i:=ui_menu_ssr_x0+ui_menu_ssr_xs;
   t:=ui_menu_ssr_y0;
   while (i<ui_menu_ssr_x1) do
   begin
      vlineColor(tar,i,t,t+ui_menu_ssr_ys,c_white);
      i+=ui_menu_ssr_xs;
   end;

   y:=_yt(0);
   t:=ui_menu_ssr_x0+ui_menu_ssr_xhs;
   draw_text(tar,t                 , y, str_menu_s1[ms1_sett], ta_middle, 255,mic(true                ,menu_s1=ms1_sett));
   draw_text(tar,t+ui_menu_ssr_xs  , y, str_menu_s1[ms1_svld], ta_middle, 255,mic(menu_SaveLoadTab,menu_s1=ms1_svld));
   draw_text(tar,t+ui_menu_ssr_xs*2, y, str_menu_s1[ms1_reps], ta_middle, 255,mic(menu_ReplaysTab ,menu_s1=ms1_reps));

   case menu_s1 of
   ms1_sett : begin
                 y:=_yt(1);
                 draw_text(tar,t                 , y, str_menu_s3[ms3_game], ta_middle, 255,mic(true,menu_s3=ms3_game));
                 draw_text(tar,t+ui_menu_ssr_xs  , y, str_menu_s3[ms3_vido], ta_middle, 255,mic(true,menu_s3=ms3_vido));
                 draw_text(tar,t+ui_menu_ssr_xs*2, y, str_menu_s3[ms3_sond], ta_middle, 255,mic(true,menu_s3=ms3_sond));

                 t:=_yl(2);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,t,c_white);

                 i:=ui_menu_ssr_x0+ui_menu_ssr_xs;
                 while (i<ui_menu_ssr_x1) do
                 begin
                    vlineColor(tar,i,t,t-ui_menu_ssr_ys,c_white);
                    i+=ui_menu_ssr_xs;
                 end;

                 while (t<ui_menu_ssr_y1) do
                 begin
                    t+=ui_menu_ssr_ys;
                    hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,t,c_gray);
                 end;

                 i:=_set_x0;
                 t:=ui_menu_ssr_x3;
                 case menu_s3 of
                 ms3_game: begin
                              y:=_yt(2);
                              draw_text(tar,i              ,y  , str_ColoredShadow      , ta_left ,255,c_white);
                              draw_text(tar,ui_menu_ssr_x7t,y  , b2cc[vid_ColoredShadow], ta_right,255,c_white);
                              vlineColor(tar,ui_menu_ssr_x2 ,y-5, y+12,c_gray);

                              draw_text(tar,ui_menu_ssr_x7r,y  , str_APM                , ta_left ,255,c_white);
                              draw_text(tar,t              ,y  , b2cc[vid_APM]          , ta_right,255,c_white);

                              y:=_yt(3);
                              draw_text(tar,i              ,y  , str_uhbar              , ta_left ,255,c_white);
                              draw_text(tar,t              ,y  , str_uhbars[vid_uhbars] , ta_right,255,c_white);

                              y:=_yt(4);
                              draw_text(tar,i              ,y  , str_maction            , ta_left ,255,c_white);
                              draw_text(tar,t              ,y  , str_maction2[m_action] , ta_right,255,c_white);

                              y:=_yt(5);
                              draw_text(tar,i              ,y  , str_scrollspd          , ta_left ,255,c_white);
                              vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);
                              vlineColor(tar,ui_menu_ssr_x3,y-6,y+12,c_gray);
                              boxColor  (tar,ui_menu_ssr_x2,y,ui_menu_ssr_x2+vid_CamSpeed,y+6,c_lime);

                              y:=_yt(6);
                              draw_text(tar,i              ,y  , str_mousescrl          , ta_left ,255, mic(true,false));
                              draw_text(tar,t              ,y  , b2cc[vid_CamMScroll]   , ta_right,255, mic(true,false));

                              y:=_yt(7);
                              draw_text(tar,i,y, str_plname, ta_left,255, mic((net_status=ns_none)and(not G_Started),menu_item=11));
                              draw_text(tar,ui_menu_ssr_x2+6,y, PlayerName+chat_type[menu_item<>11], ta_left  ,255, mic(menu_PlayerNameEnabled,menu_item=11));
                              vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);

                              y:=_yt(8);
                              draw_text(tar,i ,y, str_language             , ta_left ,255, c_white);
                              draw_text(tar,t ,y, str_lng[ui_language]     , ta_right,255, c_white);

                              y:=_yt(9);
                              draw_text(tar,i ,y, str_panelpos             , ta_left ,255, c_white);
                              draw_text(tar,t ,y, str_panelposp[vid_ppos]  , ta_right,255, c_white);

                              y:=_yt(10);
                              draw_text(tar,i ,y, str_pcolor               , ta_left ,255, c_white);
                              draw_text(tar,t ,y, str_pcolors[vid_plcolors], ta_right,255, c_white);
                           end;
                 ms3_vido: begin
                              y:=_yl(3);
                              vlineColor(tar,ui_menu_ssr_x6,y,y+ui_menu_ssr_ys,c_gray);
                              y:=_yt(3);

                              draw_text(tar,i,y, str_resol, ta_left,255,c_white);
                              draw_text(tar,ui_menu_ssr_xt0,y, i2s(m_vrx), ta_middle,255,mic(true,(m_vrx<>vid_vw) ));
                              draw_text(tar,ui_menu_ssr_xt1,y, i2s(m_vry), ta_middle,255,mic(true,(m_vry<>vid_vh) ));
                              draw_text(tar,ui_menu_ssr_x4+ui_menu_ssr_xhs,y, str_apply, ta_middle,255,mic((m_vrx<>vid_vw)or(m_vry<>vid_vh),false));
                              vlineColor(tar,ui_menu_ssr_x4,y-6,y+12,c_gray);
                              vlineColor(tar,ui_menu_ssr_x5,y-6,y+12,c_gray);

                              y:=_yt(5);
                              draw_text(tar,i ,y, str_fullscreen, ta_left ,255, mic(true,false));
                              draw_text(tar,t ,y, b2cc[not vid_fullscreen],ta_right,255, mic(true,false));

                              y:=_yt(7);
                              draw_text(tar,i ,y, str_fps, ta_left ,255, mic(true,false));
                              draw_text(tar,t ,y, b2cc[vid_fps],ta_right,255, mic(true,false));

                              y:=_yt(9);
                              draw_text(tar,i ,y, str_menu_scale, ta_left ,255, mic(true,false));
                              draw_text(tar,t ,y, b2cc[vid_menu_scale],ta_right,255, mic(true,false));

                              y:=_yt(10);
                              draw_text(tar,i ,y, str_menu_scales, ta_left ,255, mic(true,false));
                              draw_text(tar,t ,y, b2cc[vid_menu_scales],ta_right,255, mic(true,false));
                           end;
                 ms3_sond: begin
                              y:=_yt(4);
                              draw_text(tar,i,y, str_soundvol, ta_left,255, mic(snd_svolume1>0,false));
                              vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);
                              vlineColor(tar,ui_menu_ssr_x3,y-6,y+12,c_gray);
                              boxColor  (tar,ui_menu_ssr_x2,y,ui_menu_ssr_x2+trunc(snd_svolume1*ui_menu_ssr_barl),y+6,c_lime);

                              y:=_yt(5);
                              draw_text(tar,i,y, str_musicvol, ta_left,255, mic(snd_mvolume1>0,false));
                              vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);
                              vlineColor(tar,ui_menu_ssr_x3,y-6,y+12,c_gray);
                              boxColor  (tar,ui_menu_ssr_x2,y,ui_menu_ssr_x2+trunc(snd_mvolume1*ui_menu_ssr_barl),y+6,c_lime);

                              y:=_yt(7);
                              draw_text(tar,i,y, str_NextTrack, ta_left,255, c_white);

                              y:=_yt(8);
                              draw_text(tar,i,y, str_MusicListSize, ta_left,255, c_white);
                              draw_text(tar,t,y, b2s(snd_musicListSize),ta_right,255, c_white);

                              y:=_yt(9);
                              draw_text(tar,i,y, str_ReloadMusic, ta_left,255, c_white);

                           end;
                 end;
              end;
   ms1_svld : begin
                 vlineColor(tar,ui_menu_ssl_x0,_yl(1)+1,_yl(10),c_gray);

                 y:=_yl(10);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y-ui_menu_ssr_ys,c_gray);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,y,c_gray);
                 vlineColor(tar,ui_menu_ssr_x4,y,y+ui_menu_ssr_ys,c_gray);
                 vlineColor(tar,ui_menu_ssr_x5,y,y+ui_menu_ssr_ys,c_gray);

                 draw_text(tar,_set_x0,_yt(9),svld_str_fname+chat_type[menu_item<>37],ta_left,255,mic(true,menu_item=37) );

                 y:=_yt(10);
                 draw_text(tar,ui_menu_ssr_x0+ui_menu_ssr_xhs, y, str_save  , ta_middle,255, mic(saveload_Save  (true),false));
                 draw_text(tar,ui_menu_ssr_x4+ui_menu_ssr_xhs, y, str_load  , ta_middle,255, mic(saveload_Load  (true),false));
                 draw_text(tar,ui_menu_ssr_x5+ui_menu_ssr_xhs, y, str_delete, ta_middle,255, mic(saveload_Delete(true),false));

                 for t:=0 to vid_svld_m do
                 begin
                    i:=t+svld_list_scroll;
                    if(i<svld_list_size)then
                    begin
                       y:=_yl(t+1);
                       draw_text(tar,_set_x0,y+6,str_Trim(b2s(i+1)+']'+svld_list[i],17),ta_left,255,mic(true,i=svld_list_sel));
                       if(i=svld_list_sel)then
                       begin
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+1,c_gray);
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+ui_menu_ssr_ys-1,c_gray);
                       end;
                    end;
                 end;

                 draw_text(tar,ui_menu_ssl_x0+6, _yl(1)+6,svld_str_info  ,ta_left,18,c_white);
              end;
   ms1_reps : begin
                 vlineColor(tar,ui_menu_ssl_x0,_yl(1)+1,_yl(10),c_gray);

                 y:=_yl(10);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,y,c_gray);
                 vlineColor(tar,ui_menu_ssr_x4,y,y+ui_menu_ssr_ys,c_gray);
                 vlineColor(tar,ui_menu_ssr_x5,y,y+ui_menu_ssr_ys,c_gray);

                 y:=_yt(10);
                 draw_text(tar,ui_menu_ssr_x0+ui_menu_ssr_xhs, y, str_play  , ta_middle,255, mic(replay_Play  (true),false));
                 draw_text(tar,ui_menu_ssr_x5+ui_menu_ssr_xhs, y, str_delete, ta_middle,255, mic(replay_Delete(true),false));

                 for t:=0 to vid_rpls_m do
                 begin
                    i:=t+rpls_list_scroll;
                    if(i<rpls_list_size)then
                    begin
                       y:=_yl(t+1);
                       draw_text(tar,_set_x0,y+6,str_Trim(b2s(i+1)+']'+rpls_list[i],17),ta_left,255,mic(not g_started,i=rpls_list_sel));
                       if(i=rpls_list_sel)then
                       begin
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+1,c_gray);
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+ui_menu_ssr_ys-1,c_gray);
                       end;
                    end;
                 end;

                 draw_text(tar,ui_menu_ssl_x0+6, _yt(1),rpls_str_info  ,ta_left,19,c_white);
              end;
   end;
end;

procedure D_M2(tar:pSDL_Surface);
var
t,i,y:integer;
c    :boolean;
function _yl(s:integer):integer;begin _yl:=ui_menu_csm_y0+s*ui_menu_csm_ys; end;
function _yt(s:integer):integer;begin _yt:=_yl(s)+6; end;
begin
   hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,ui_menu_csm_y0+ui_menu_csm_ys,c_white);

   i:=ui_menu_csm_x0+ui_menu_csm_xs;
   t:=ui_menu_csm_y0;
   while (i<ui_menu_csm_x1) do
   begin
      vlineColor(tar,i,t,t+ui_menu_csm_ys,c_white);
      i+=ui_menu_csm_xs;
   end;

   y:=_yt(0);
   t:=ui_menu_csm_x0+ui_menu_csm_xhs;
   draw_text(tar,t                 , y, str_menu_s2[ms2_camp], ta_middle, 255,mic(menu_CampanyTab    ,menu_s2=ms2_camp));
   draw_text(tar,t+ui_menu_csm_xs  , y, str_menu_s2[ms2_scir], ta_middle, 255,mic(menu_ScirmishTab   ,menu_s2=ms2_scir));
   draw_text(tar,t+ui_menu_csm_xs*2, y, str_menu_s2[ms2_mult], ta_middle, 255,mic(menu_MultiplayerTab,menu_s2=ms2_mult));

   case menu_s2 of
   ms2_camp : begin
                 draw_text(tar,ui_menu_csm_xt0,_yt(1),str_cmpdif+str_cmpd[cmp_skill],ta_left,255,mic(not g_started,false));
                 y:=_yl(2);
                 hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_white);
                 for t:=0 to vid_camp_m do
                 begin
                    i:=t+cmp_scroll;
                    if(i<=LastMission)then
                    begin
                       y:=_yl(t+2);
                       draw_text(tar,ui_menu_csm_xt0,_yt(t+2),str_camp_name[i],ta_left,255,mic(not g_started,i=cmp_sel));
                       if(i=cmp_sel)then
                       begin
                          hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);
                          hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y+ui_menu_csm_ys,c_gray);
                       end;
                    end;
                 end;
              end;
   ms2_scir : begin
                 t:=ui_menu_csm_y0+ui_menu_csm_ys;

                 while(t<ui_menu_csm_y1)do
                 begin
                    t+=ui_menu_csm_ys;
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,t,c_gray);
                 end;

                 // game options
                 draw_text(tar,ui_menu_csm_xt1, _yt(1), str_goptions, ta_left,255, c_white);

                 c:=menu_GameSettingsEnabled;

                 y:=_yt(2);
                 draw_text(tar,ui_menu_csm_xt0, y, str_gmodet             , ta_left  ,255, mic(c,false));
                 draw_text(tar,ui_menu_csm_xt2, y, str_gmode[g_mode]      , ta_right ,255, c_white     );

                 y:=_yt(3);
                 draw_text(tar,ui_menu_csm_xt0, y, str_fstarts            , ta_left  ,255, mic(c,false));
                 draw_text(tar,ui_menu_csm_xt2, y, b2cc[g_fixed_positions], ta_right ,255 ,c_white     );

                 y:=_yt(4);
                 draw_text(tar,ui_menu_csm_xt0, y, str_aislots            , ta_left  ,255, mic(c,false));
                 draw_text(tar,ui_menu_csm_xt2, y, ai_name(g_ai_slots)    , ta_right ,255 ,c_white     );

                 y:=_yt(5);
                 draw_text(tar,ui_menu_csm_xt0, y, str_generators         , ta_left  ,255, mic(c,false));
                 draw_text(tar,ui_menu_csm_xt2, y, str_generatorsO[g_generators],
                                                                            ta_right ,255 ,c_white     );

                 y:=_yt(6);
                 draw_text(tar,ui_menu_csm_xt0, y, str_DeadObservers      , ta_left  ,255, mic(c,false));
                 draw_text(tar,ui_menu_csm_xt2, y, b2cc[g_deadobservers]  , ta_right ,255 ,c_white     );

                 y:=_yt(7);
                 draw_text(tar,ui_menu_csm_xc , y, str_randoms            , ta_middle,255, mic(c,false));


                 // replays
                 y:=_yt(10);
                 draw_text(tar,ui_menu_csm_xt1, y, str_replay             , ta_left  ,255, c_white);
                 draw_text(tar,ui_menu_csm_xt2, y, str_rstatus[rpls_state], ta_right ,255, mic( menu_ReplayStatusToggleEnabled ,rpls_state>rpls_none));
                 t:=_yl(10);
                 vlineColor(tar,ui_menu_csm_x3 ,t,t+ui_menu_csm_ys, c_gray);
                 y:=_yt(11);
                 draw_text(tar,ui_menu_csm_xt0, y, str_replay_name        , ta_left,255, mic( rpls_state=rpls_none ,false));
                 draw_text(tar,ui_menu_csm_xt3, y, rpls_str_name+chat_type[menu_item<>83]  , ta_left,255, mic( rpls_state=rpls_none ,menu_item=83));
                 y:=_yl(11);
                 vlineColor(tar,ui_menu_csm_xc ,y,y+ui_menu_csm_ys,c_gray);
                 y:=_yt(12);
                 draw_text(tar,ui_menu_csm_xt0, y, str_pnu+str_pnua[rpls_pnui], ta_left,255, mic( menu_ReplayStatusToggleEnabled ,false));
                 if(rpls_state>rpls_none)and(g_cl_units>0)then
                 draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units), ta_right,255, c_white);
              end;
   ms2_mult : begin
                 case net_status of
                 ns_none  : begin
                               t:=ui_menu_csm_y0+ui_menu_csm_ys;

                               while (t<ui_menu_csm_y1) do
                               begin
                                  t+=ui_menu_csm_ys;
                                  hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,t,c_gray);
                               end;

                               y:=_yt(2);
                               draw_text(tar,ui_menu_csm_xt1, y, str_server, ta_left,255, c_white);
                               draw_text(tar,ui_menu_csm_xt2, y,str_svup[net_status=ns_server]        , ta_right ,255, mic(menu_NetServer(net_status<>ns_server,true),false));
                               vlineColor(tar,ui_menu_csm_xc, _yl(2),_yl(2)+ui_menu_csm_ys, c_gray);
                               y:=_yt(3);
                               draw_text(tar,ui_menu_csm_xt0, y,str_udpport                           , ta_left  ,255 ,mic((net_status=ns_none),menu_item=87));
                               draw_text(tar,ui_menu_csm_xt2, y,net_sv_pstr+chat_type[menu_item<>87]  , ta_right ,255 ,mic((net_status=ns_none),menu_item=87));

                               y:=_yt(5);
                               draw_text(tar,ui_menu_csm_xt1, y, str_client , ta_left,255, c_white);
                               draw_text(tar,ui_menu_csm_xt2, y, str_connect[net_status=ns_client]    , ta_right ,255, mic(menu_NetClient(net_status<>ns_client,true),false));
                               vlineColor(tar,ui_menu_csm_xc, _yl(5),_yl(5)+ui_menu_csm_ys, c_gray);

                               y:=_yt(6);
                               draw_text(tar,ui_menu_csm_xt0, y, net_cl_svstr+chat_type[menu_item<>90], ta_left  ,255, mic((net_status=ns_none),menu_item=90));
                               y:=_yt(7);
                               draw_text(tar,ui_menu_csm_xt0, y, str_npnu+str_npnua[net_pnui]         , ta_left  ,255, mic((net_status<>ns_server),false));
                               if(g_cl_units>0)then
                               draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                                        ta_right ,255, c_white);
                            end;
                 ns_server: begin
                               for t:=2 to 4 do hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(t),c_gray);

                               y:=_yt(1);
                               draw_text(tar,ui_menu_csm_xt0, y,str_svup[net_status=ns_server]        , ta_left  ,255, mic(menu_NetServer(net_status<>ns_server,true),false));
                               draw_text(tar,ui_menu_csm_xt2, y,str_udpport+net_sv_pstr               , ta_right ,255 ,mic(false        ,false));
                            end;
                 ns_client: begin
                               for t:=2 to 4 do hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(t),c_gray);

                               y:=_yt(1);
                               draw_text(tar,ui_menu_csm_xt0, y, str_connect[net_status=ns_client]    , ta_left ,255, mic(menu_NetClient(net_status<>ns_client,true),false));
                               draw_text(tar,ui_menu_csm_xt2, y, net_cl_svstr                         , ta_right,255, mic(false        ,false));

                               y:=_yt(2);
                               draw_text(tar,ui_menu_csm_xt0, y, str_npnu+str_npnua[net_pnui]         , ta_left  ,255, mic((net_status<>ns_server),false));
                               if(g_cl_units>0)then
                               draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                                        ta_right ,255, c_white);
                            end;
                 end;
                 // chat
                 case net_status of
                 ns_server,
                 ns_client: begin
                               draw_text(tar,ui_menu_csm_xc, _yt(3), str_menu_chat, ta_middle,255, mic((net_status<>ns_none),menu_item=100));

                               y:=_yt(11)+1;
                               MakeLogListForDraw(HPlayer,ui_menu_chat_width,ui_menu_chat_height,lmts_menu_chat);
                               if(ui_log_n>0)then
                                 for t:=0 to ui_log_n-1 do
                                   if(ui_log_c[t]>0)then draw_text(tar,ui_menu_csm_xct,y-t*ui_menu_csm_ycs,ui_log_s[t],ta_left,255,ui_log_c[t]);

                               hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(12),c_gray);
                               draw_text(tar,ui_menu_csm_xct, _yt(12), net_chat_str+chat_type[menu_item<>100] , ta_chat,ui_menu_chat_width, c_white);
                            end;
                 end;
              end;
   end;
end;

procedure vid_MakeBigMenu;
var
cx,cy:single;
begin
   if(r_menusc<>nil)and(r_menusc<>r_menu)then sdl_FreeSurface(r_menusc);

   if(vid_menu_scale)then
   begin
      cx:=vid_vw/r_menu^.w;
      cy:=vid_vh/r_menu^.h;
      if(cx>cy)
      then r_menusc_s:=cy
      else r_menusc_s:=cx;
      r_menusc  :=zoomSurface(r_menu,r_menusc_s,r_menusc_s,byte(vid_menu_scales));
      r_menusc_s:=1/r_menusc_s;
   end
   else
   begin
      r_menusc_s:=1;
      r_menusc  :=r_menu;
   end;

   r_menusc_x:=(vid_vw-r_menusc^.w) div 2;
   r_menusc_y:=(vid_vh-r_menusc^.h) div 2;
end;

procedure d_updmenu(tar:pSDL_Surface);
begin
   draw_sdlsurface(tar,0,0,spr_mback);
   draw_text(tar,spr_mback^.w,spr_mback^.h-font_w,str_ver,ta_right,255,c_white);

   if(TestMode>0)then draw_text(tar,spr_mback^.w shr 1,0,'TEST MODE '+b2s(TestMode),ta_middle,255,c_white);
   draw_text(tar,spr_mback^.w shr 1,spr_mback^.h-font_3w,str_menu_controls,ta_middle,255,c_white);

   draw_text(tar,spr_mback^.w shr 1,spr_mback^.h-font_w, str_cprt , ta_middle,255, c_white);

   if(menu_ihint>0)then
   begin
      if(menu_ihintpi<=menu_ihintn)then
        draw_text(tar,menu_ihintlx[menu_ihintpi],menu_ihintly[menu_ihintpi],str_menu_hint[menu_ihint],ta_middle,255,c_white);
   end;

   case G_Started of
false: begin
          draw_text(tar, 70,554, str_exit , ta_middle,255, c_white);
          case net_status  of
          ns_server,
          ns_none   : draw_text(tar,730,554, str_start, ta_middle,255, mic(PlayersReadyStatus,false));
          ns_client : ;
          end;
       end;
true : begin
          draw_text(tar, 70,554, str_back , ta_middle,255, c_white);

          if(menu_surrender(true))then
          begin
             draw_sdlsurface(tar,360,542,spr_mbtn);
             draw_text(tar,400,554,str_surrender,ta_middle,255, c_white);
          end;

          draw_text(tar,730,554, str_quit     , ta_middle,255, c_white);
       end;
   end;

   D_MMap    (tar);
   D_MPlayers(tar);
   D_M1      (tar);
   D_M2      (tar);
end;

procedure D_Menu;
begin
   if(vid_menu_redraw)then
   begin
      d_updmenu(r_menu);
      vid_MakeBigMenu;
      vid_menu_redraw:=false;
   end;

   draw_sdlsurface(r_screen,r_menusc_x,r_menusc_y,r_menusc);

   if(vid_FPS)then draw_text(r_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_right,255,c_white);

   draw_sdlsurface(r_screen,mouse_x,mouse_y,spr_cursor);
end;


