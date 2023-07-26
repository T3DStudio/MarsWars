

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
   _draw_text(tar, 229, 96, str_MMap, ta_middle,255, c_white);

   boxColor(tar,
   ui_menu_map_rx0,ui_menu_map_y0,
   ui_menu_map_rx1,ui_menu_map_y1,
   c_black);

   if(menu_s2<>ms2_camp)then
   begin
      i:=ui_menu_map_y0+ui_menu_map_ys;
      while (i<ui_menu_map_y1) do
      begin
         hlineColor(tar,ui_menu_map_rx0,ui_menu_map_rx1,i,c_gray);
         i+=ui_menu_map_ys;
      end;

      c:=not((net_status=ns_client) or G_Started);

      _draw_text(tar,ui_menu_map_tx1,_yt(0), c2s(map_seed)              , ta_middle,255, mic(c,menu_item=50));
      _draw_text(tar,ui_menu_map_tx0,_yt(1), str_m_siz+i2s(map_mw)      , ta_left  ,255, mic(c,false));
      _draw_text(tar,ui_menu_map_tx0,_yt(2), str_m_liq+_str_mx(map_liq) , ta_left  ,255, mic(c,false));
      _draw_text(tar,ui_menu_map_tx0,_yt(3), str_m_obs+_str_mx(map_obs) , ta_left  ,255, mic(c,false));
      _draw_text(tar,ui_menu_map_tx0,_yt(4), str_m_sym+b2cc[map_symmetry],ta_left  ,255, mic(c,false));

      _draw_text(tar,ui_menu_map_tx1,_yt(6), str_mrandom                , ta_middle,255, mic(c,false));
      _draw_text(tar,ui_menu_map_tx1,_yt(7), theme_name[theme_i]        , ta_middle,255, c_white     );
   end
   else
   begin
      //_draw_surf(tar, 91 ,129,cmp_mmap  [_cmp_sel]);
      //_draw_text(tar, 252,132,str_camp_m[_cmp_sel], ta_left,255, c_white);
   end;

   rectangleColor(tar,
   ui_menu_map_rx0,ui_menu_map_y0,
   ui_menu_map_rx1,ui_menu_map_y1,
   c_white);
end;

procedure D_MPlayers(tar:pSDL_Surface);
var y,p,u:integer;
        c:cardinal;
function _yl(s:integer):integer;begin _yl:=s*ui_menu_pls_ys; end;
function _yt(s:integer):integer;begin _yt:=_yl(s)+6; end;
begin
   if(menu_s2<>ms2_camp)then
   begin
      _draw_text(tar, 571, 96, str_MPlayers, ta_middle,255, c_white);

      vlineColor(tar, ui_menu_pls_zxn, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxs, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxr, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxt, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxc, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
      vlineColor(tar, ui_menu_pls_zxe, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );

      for p:=1 to MaxPlayers do
       with _players[p] do
       begin
          y:=ui_menu_pls_zy0+_yl(p-1);
          u:=y+6;

          hlineColor(tar,ui_menu_pls_zxn,ui_menu_pls_zxe,y,c_gray);

          c:=c_white;
          if G_started or (net_status=ns_client)then c:=c_gray;

          if(state<>ps_none)then
          begin
             _draw_text(tar,ui_menu_pls_zxst, u,PlayerGetStatus(p), ta_middle, 255, c);
             _draw_text(tar,ui_menu_pls_zxnt, u,name              , ta_left  , 255, c_white);
             if(G_Started)
             or(net_status=ns_client)
             or((net_status<ns_client)and(state=ps_play)and(p<>HPlayer))
             or(team=0)then c:=c_gray;
             if(team=0)
             then _draw_text(tar,ui_menu_pls_zxrt, u,str_observer   , ta_middle, 255, c)
             else _draw_text(tar,ui_menu_pls_zxrt, u,str_race[mrace], ta_middle, 255, c);
             if(g_mode in gm_fixed_positions)then c:=c_gray;
             _draw_text(tar,ui_menu_pls_zxtt, u,t2c(PlayerGetTeam(g_mode,p)), ta_middle, 255, c);
             if(not GetBBit(@g_player_astatus,p))and(G_Started)then lineColor(tar,ui_menu_pls_zxnt,u+4,ui_menu_pls_zxs-6,u+4,c_red);
          end
          else
            if(g_ai_slots)>0then
            begin
               _draw_text(tar,ui_menu_pls_zxst, u,str_ps_c[ps_comp]              , ta_middle,255, c_gray);
               _draw_text(tar,ui_menu_pls_zxnt, u,str_ps_comp+' '+b2s(g_ai_slots), ta_left  ,255, c_gray);
               _draw_text(tar,ui_menu_pls_zxrt, u,str_race[r_random]             , ta_middle,255, c_gray);
               _draw_text(tar,ui_menu_pls_zxtt, u,b2s(PlayerGetTeam(g_mode,p))   , ta_middle,255, c_gray);
            end
            else _draw_text(tar,ui_menu_pls_zxst, u,PlayerGetStatus(p), ta_middle, 255, c);
          boxColor(tar,ui_menu_pls_zxc1,u,ui_menu_pls_zxc2,u+6,PlayerGetColor(p));
       end;

      rectangleColor(tar,ui_menu_pls_zxn,ui_menu_pls_zy0,ui_menu_pls_zxe,ui_menu_pls_zy1,c_white);
   end
   else
   begin
      _draw_text(tar,ui_menu_pls_xc, 96, str_MObjectives, ta_middle,255, c_white);

      //_draw_text(tar, ui_menu_pls_xc , ui_menu_pls_zy0+_yt(0)  ,str_camp_t[_cmp_sel],ta_middle,255,c_white);
      //_draw_text(tar, ui_menu_pls_zxn, ui_menu_pls_zy0+_yt(1)+8,str_camp_o[_cmp_sel],ta_left  ,255,c_white);
   end;
end;

procedure D_M1(tar:pSDL_Surface);
const _set_x0 = ui_menu_ssr_x0+font_w;
var t,i,y:integer;
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
   _draw_text(tar,t                 , y, str_menu_s1[ms1_sett], ta_middle, 255,mic(true,menu_s1=ms1_sett));
   _draw_text(tar,t+ui_menu_ssr_xs  , y, str_menu_s1[ms1_svld], ta_middle, 255,mic((net_status=ns_none)and(ServerSide),menu_s1=ms1_svld));
   _draw_text(tar,t+ui_menu_ssr_xs*2, y, str_menu_s1[ms1_reps], ta_middle, 255,mic(net_status=ns_none,menu_s1=ms1_reps));

   case menu_s1 of
   ms1_sett : begin
                 y:=_yt(1);
                 _draw_text(tar,t                 , y, str_menu_s3[ms3_game], ta_middle, 255,mic(true,menu_s3=ms3_game));
                 _draw_text(tar,t+ui_menu_ssr_xs  , y, str_menu_s3[ms3_vido], ta_middle, 255,mic(true,menu_s3=ms3_vido));
                 _draw_text(tar,t+ui_menu_ssr_xs*2, y, str_menu_s3[ms3_sond], ta_middle, 255,mic(true,menu_s3=ms3_sond));

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
                 if(menu_s3=ms3_game)then
                 begin
                    y:=_yt(2);
                    _draw_text(tar,i              ,y  , str_ColoredShadow      , ta_left ,255,c_white);
                    _draw_text(tar,ui_menu_ssr_x7t,y  , b2cc[vid_ColoredShadow], ta_right,255,c_white);
                    vlineColor(tar,ui_menu_ssr_x2 ,y-5, y+12,c_gray);

                    _draw_text(tar,ui_menu_ssr_x7r,y  , str_APM                , ta_left ,255,c_white);
                    _draw_text(tar,t              ,y  , b2cc[vid_APM]          , ta_right,255,c_white);

                    y:=_yt(3);
                    _draw_text(tar,i              ,y  , str_uhbar              , ta_left ,255,c_white);
                    _draw_text(tar,t              ,y  , str_uhbars[vid_uhbars] , ta_right,255,c_white);

                    y:=_yt(4);
                    _draw_text(tar,i              ,y  , str_maction            , ta_left ,255,c_white);
                    _draw_text(tar,t              ,y  , str_maction2[m_action] , ta_right,255,c_white);

                    y:=_yt(5);
                    _draw_text(tar,i              ,y  , str_scrollspd          , ta_left ,255,c_white);
                    vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);
                    vlineColor(tar,ui_menu_ssr_x3,y-6,y+12,c_gray);
                    boxColor  (tar,ui_menu_ssr_x2,y,ui_menu_ssr_x2+vid_CamSpeed,y+6,c_lime);

                    y:=_yt(6);
                    _draw_text(tar,i              ,y  , str_mousescrl          , ta_left ,255, mic(true,false));
                    _draw_text(tar,t              ,y  , b2cc[vid_CamMScroll]   , ta_right,255, mic(true,false));

                    y:=_yt(7);
                    _draw_text(tar,i,y, str_plname, ta_left,255, mic((net_status=ns_none)and(G_Started=false),menu_item=11));
                    _draw_text(tar,ui_menu_ssr_x2+6,y, PlayerName, ta_left  ,255, mic((net_status=ns_none)and(G_Started=false),menu_item=11));
                    vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);

                    y:=_yt(8);
                    _draw_text(tar,i ,y, str_language             , ta_left ,255, c_white);
                    _draw_text(tar,t ,y, str_lng[ui_language]     , ta_right,255, c_white);

                    y:=_yt(9);
                    _draw_text(tar,i ,y, str_panelpos             , ta_left ,255, c_white);
                    _draw_text(tar,t ,y, str_panelposp[vid_ppos]  , ta_right,255, c_white);

                    y:=_yt(10);
                    _draw_text(tar,i ,y, str_pcolor               , ta_left ,255, c_white);
                    _draw_text(tar,t ,y, str_pcolors[vid_plcolors], ta_right,255, c_white);
                 end;

                 if(menu_s3=ms3_vido)then
                 begin
                    y:=_yl(3);
                    vlineColor(tar,ui_menu_ssr_x6,y,y+ui_menu_ssr_ys,c_gray);
                    y:=_yt(3);

                    _draw_text(tar,i,y, str_resol, ta_left,255,c_white);
                    _draw_text(tar,ui_menu_ssr_xt0,y, i2s(m_vrx), ta_middle,255,mic(true,(m_vrx<>vid_vw) ));
                    _draw_text(tar,ui_menu_ssr_xt1,y, i2s(m_vry), ta_middle,255,mic(true,(m_vry<>vid_vh) ));
                    _draw_text(tar,ui_menu_ssr_x4+ui_menu_ssr_xhs,y, str_apply, ta_middle,255,mic((m_vrx<>vid_vw)or(m_vry<>vid_vh),false));
                    vlineColor(tar,ui_menu_ssr_x4,y-6,y+12,c_gray);
                    vlineColor(tar,ui_menu_ssr_x5,y-6,y+12,c_gray);

                    y:=_yt(5);
                    _draw_text(tar,i ,y, str_fullscreen, ta_left ,255, mic(true,false));
                    _draw_text(tar,t ,y, b2cc[not vid_fullscreen],ta_right,255, mic(true,false));

                    y:=_yt(7);
                    _draw_text(tar,i ,y, str_fps, ta_left ,255, mic(true,false));
                    _draw_text(tar,t ,y, b2cc[vid_fps],ta_right,255, mic(true,false));
                 end;

                 if(menu_s3=ms3_sond)then
                 begin
                    y:=_yt(4);
                    _draw_text(tar,i,y, str_soundvol, ta_left,255, mic(snd_svolume1>0,false));
                    vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);
                    vlineColor(tar,ui_menu_ssr_x3,y-6,y+12,c_gray);
                    boxColor  (tar,ui_menu_ssr_x2,y,ui_menu_ssr_x2+trunc(snd_svolume1*ui_menu_ssr_barl),y+6,c_lime);

                    y:=_yt(5);
                    _draw_text(tar,i,y, str_musicvol, ta_left,255, mic(snd_mvolume1>0,false));
                    vlineColor(tar,ui_menu_ssr_x2,y-6,y+12,c_gray);
                    vlineColor(tar,ui_menu_ssr_x3,y-6,y+12,c_gray);
                    boxColor  (tar,ui_menu_ssr_x2,y,ui_menu_ssr_x2+trunc(snd_mvolume1*ui_menu_ssr_barl),y+6,c_lime);

                    y:=_yt(7);
                    _draw_text(tar,i,y, str_NextTrack, ta_left,255, c_white);

                 end;
              end;
   ms1_svld : begin
                 vlineColor(tar,ui_menu_ssl_x0,_yl(1)+1,_yl(10),c_gray);

                 y:=_yl(10);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y-ui_menu_ssr_ys,c_gray);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,y,c_gray);
                 vlineColor(tar,ui_menu_ssr_x4,y,y+ui_menu_ssr_ys,c_gray);
                 vlineColor(tar,ui_menu_ssr_x5,y,y+ui_menu_ssr_ys,c_gray);

                 _draw_text(tar,_set_x0,_yt(9),svld_str_fname,ta_left,255,mic(true,menu_item=37) );

                 y:=_yt(10);
                 _draw_text(tar,ui_menu_ssr_x0+ui_menu_ssr_xhs, y, str_save  , ta_middle,255, mic(G_Started and (svld_str_fname<>''),false));
                 _draw_text(tar,ui_menu_ssr_x4+ui_menu_ssr_xhs, y, str_load  , ta_middle,255, mic((svld_list_sel<svld_list_size) ,false));
                 _draw_text(tar,ui_menu_ssr_x5+ui_menu_ssr_xhs, y, str_delete, ta_middle,255, mic((svld_list_sel<svld_list_size) ,false));

                 for t:=0 to vid_svld_m do
                 begin
                    i:=t+svld_list_scroll;
                    if(i<svld_list_size)then
                    begin
                       y:=_yl(t+1);
                       _draw_text(tar,_set_x0,y+6,b2s(i+1)+'.'+svld_list[i],ta_left,255,mic(true,i=svld_list_sel));
                       if(i=svld_list_sel)then
                       begin
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+1,c_gray);
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+ui_menu_ssr_ys-1,c_gray);
                       end;
                    end;
                 end;

                 _draw_text(tar,ui_menu_ssl_x0+6, _yl(1)+6,svld_str_info  ,ta_left,19,c_white);
              end;
   ms1_reps : begin
                 vlineColor(tar,ui_menu_ssl_x0,_yl(1)+1,_yl(10),c_gray);

                 y:=_yl(10);
                 hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssr_x1,y,c_gray);
                 vlineColor(tar,ui_menu_ssr_x4,y,y+ui_menu_ssr_ys,c_gray);
                 vlineColor(tar,ui_menu_ssr_x5,y,y+ui_menu_ssr_ys,c_gray);

                 y:=_yt(10);
                 _draw_text(tar,ui_menu_ssr_x0+ui_menu_ssr_xhs, y, str_play  , ta_middle,255, mic((rpls_list_sel<rpls_list_size)and(G_Started=false),false));
                 _draw_text(tar,ui_menu_ssr_x5+ui_menu_ssr_xhs, y, str_delete, ta_middle,255, mic((rpls_list_sel<rpls_list_size)and(G_Started=false),false));

                 for t:=0 to vid_rpls_m do
                 begin
                    i:=t+rpls_list_scroll;
                    if(i<rpls_list_size)then
                    begin
                       y:=_yl(t+1);
                       _draw_text(tar,_set_x0,y+6,b2s(i+1)+'.'+rpls_list[i],ta_left,255,mic(true,i=rpls_list_sel));
                       if(i=rpls_list_sel)then
                       begin
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+1,c_gray);
                          hlineColor(tar,ui_menu_ssr_x0,ui_menu_ssl_x0,y+ui_menu_ssr_ys-1,c_gray);
                       end;
                    end;
                 end;

                 _draw_text(tar,ui_menu_ssl_x0+6, _yl(1)+6,rpls_str_info  ,ta_left,19,c_white);
              end;
   end;
end;

procedure D_M2(tar:pSDL_Surface);
var t,i,y:integer;
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
   _draw_text(tar,t                 , y, str_menu_s2[ms2_camp], ta_middle, 255,mic(false and (net_status=ns_none)and(G_Started=false),menu_s2=ms2_camp));
   _draw_text(tar,t+ui_menu_csm_xs  , y, str_menu_s2[ms2_scir], ta_middle, 255,mic(not(G_Started and(menu_s2=ms2_camp)),menu_s2=ms2_scir));
   _draw_text(tar,t+ui_menu_csm_xs*2, y, str_menu_s2[ms2_mult], ta_middle, 255,mic(not(G_Started and(menu_s2=ms2_camp)),menu_s2=ms2_mult));

   case menu_s2 of
   ms2_camp : begin
                 _draw_text(tar,ui_menu_csm_xt0,_yt(1),str_cmpdif+str_cmpd[cmp_skill],ta_left,255,mic(not g_started,false));
                 y:=_yl(2);
                 hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_white);
                 for t:=1 to vid_camp_m do
                 begin
                    i:=t+_cmp_sm-1;
                    if(i=_cmp_sel)then
                    begin
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y+ui_menu_csm_ys,c_gray);
                    end;
                    //_draw_text(tar,ui_menu_csm_xt0,y+6,str_camp_t[i],ta_left,255,mic(not g_started,i=_cmp_sel));
                    y+=ui_menu_csm_ys;
                 end;
              end;
   ms2_scir : begin
                 t:=ui_menu_csm_y0+ui_menu_csm_ys;

                 while (t<ui_menu_csm_y1) do
                 begin
                    t+=ui_menu_csm_ys;
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,t,c_gray);
                 end;

                 // game options
                 _draw_text(tar,ui_menu_csm_xt1, _yt(1), str_goptions, ta_left,255, c_white);

                 y:=_yt(2);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_gmodet             , ta_left  ,255, mic((G_Started=false)and(net_status<>ns_client),false));
                 _draw_text(tar,ui_menu_csm_xt2, y, str_gmode[g_mode]      , ta_right ,255, c_white);

                 y:=_yt(3);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_starta             , ta_left  ,255, mic((G_Started=false)and(net_status<>ns_client),false));
                 _draw_text(tar,ui_menu_csm_xt2, y, b2s(g_start_base+1)    , ta_right ,255,c_white);

                 y:=_yt(4);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_fstarts            , ta_left  ,255, mic((G_Started=false)and(net_status<>ns_client),false));
                 _draw_text(tar,ui_menu_csm_xt2, y, b2cc[g_fixed_positions], ta_right ,255 ,c_white);

                 y:=_yt(5);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_aislots            , ta_left  ,255, mic((G_Started=false)and(net_status<>ns_client),false));
                 _draw_text(tar,ui_menu_csm_xt2, y, ai_name(g_ai_slots)    , ta_right ,255 ,c_white);

                 y:=_yt(6);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_generators        , ta_left  ,255, mic((G_Started=false)and(net_status<>ns_client),false));
                 _draw_text(tar,ui_menu_csm_xt2, y, str_generatorsO[g_generators],
                                                                             ta_right ,255 ,c_white);

                 y:=_yt(7);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_DeadObservers      , ta_left  ,255, mic((G_Started=false)and(net_status<>ns_client),false));
                 _draw_text(tar,ui_menu_csm_xt2, y, b2cc[g_deadobservers]  , ta_right ,255 ,c_white);

                 y:=_yt(8);
                 _draw_text(tar,ui_menu_csm_xc , y, str_randoms            , ta_middle,255, mic((G_Started=false)and(net_status=0       ),false));

                 // replays
                 y:=_yt(10);
                 _draw_text(tar,ui_menu_csm_xt1, y, str_replay             , ta_left  ,255, c_white);
                 _draw_text(tar,ui_menu_csm_xt2, y, str_rstatus[rpls_state], ta_right ,255, mic( rpls_state<rpls_state_read ,rpls_state>rpls_state_none));
                 t:=_yl(10);
                 vlineColor(tar,ui_menu_csm_x3 ,t,t+ui_menu_csm_ys, c_gray);
                 y:=_yt(11);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_replay_name, ta_left,255, mic( rpls_state=rpls_state_none ,false));
                 _draw_text(tar,ui_menu_csm_xt3, y, rpls_str_name  , ta_left,255, mic( rpls_state=rpls_state_none ,menu_item=83));
                 y:=_yl(11);
                 vlineColor(tar,ui_menu_csm_xc ,y,y+ui_menu_csm_ys,c_gray);
                 y:=_yt(12);
                 _draw_text(tar,ui_menu_csm_xt0, y, str_pnu+str_pnua[rpls_pnui], ta_left,255, mic( rpls_state<rpls_state_read ,false));
                 if(rpls_state>rpls_state_none)and(g_cl_units>0)then
                 _draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units), ta_right,255, c_white);
              end;
   ms2_mult : begin
                 _draw_text(tar,ui_menu_csm_xc, _yt(12), str_menu_chat, ta_middle,255, mic((net_status<>ns_none),m_chat));

                 if(m_chat)then
                 begin
                    y:=_yl(12);
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y-ui_menu_csm_ys,c_gray);
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);

                    y:=_yt(10);
                    MakeLogListForDraw(HPlayer,ui_menu_chat_width,ui_menu_chat_height,lmts_menu_chat);
                    if(ui_log_n>0)then
                     for t:=0 to ui_log_n-1 do
                      if(ui_log_c[t]>0)then _draw_text(tar,ui_menu_csm_xct,y-t*ui_menu_csm_ycs,ui_log_s[t],ta_left,255,ui_log_c[t]);

                    _draw_text(tar,ui_menu_csm_xct, _yt(11), net_chat_str , ta_chat,ui_menu_chat_width, c_white);
                 end
                 else
                 begin
                    t:=ui_menu_csm_y0+ui_menu_csm_ys;

                    while (t<ui_menu_csm_y1) do
                    begin
                       t+=ui_menu_csm_ys;
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,t,c_gray);
                    end;

                    y:=_yt(2);
                    _draw_text(tar,ui_menu_csm_xt1, y, str_server, ta_left,255, c_white);
                    _draw_text(tar,ui_menu_csm_xt2, y,str_svup[net_status=ns_server]         , ta_right ,255, mic((net_status<>ns_client)and(G_Started=false),false));
                    vlineColor(tar,ui_menu_csm_xc , _yl(2),_yl(2)+ui_menu_csm_ys, c_gray);
                    y:=_yt(3);
                    _draw_text(tar,ui_menu_csm_xt0, y,str_udpport                          , ta_left  ,255 ,mic((net_status=ns_none),menu_item=87));
                    _draw_text(tar,ui_menu_csm_xt2, y,net_sv_pstr                          , ta_right ,255 ,mic((net_status=ns_none),menu_item=87));


                    y:=_yt(5);
                    _draw_text(tar,ui_menu_csm_xt1, y, str_client , ta_left,255, c_white);
                    _draw_text(tar,ui_menu_csm_xt2, y, str_connect[net_status=ns_client]     , ta_right ,255, mic((net_status<>ns_server)and((net_status=ns_client)or(G_Started=false)),false));
                    vlineColor(tar,ui_menu_csm_xc , _yl(5),_yl(5)+ui_menu_csm_ys, c_gray);

                    y:=_yt(6);
                    _draw_text(tar,ui_menu_csm_xt0, y, net_cl_svstr                        , ta_left  ,255, mic((net_status=ns_none),menu_item=90));
                    _draw_text(tar,ui_menu_csm_xt2, y, net_m_error                         , ta_right ,255, c_red);
                    y:=_yt(7);
                    _draw_text(tar,ui_menu_csm_xt0, y, str_npnu+str_npnua[net_pnui]        , ta_left  ,255, mic((net_status<>ns_server),false));
                    y:=_yt(8);
                    t:=_yl(8);
                    i:=t+ui_menu_csm_ys;
                    _draw_text(tar,ui_menu_csm_xt0 , y, str_team+t2c(PlayerTeam)           , ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false),false));

                    if(PlayerTeam=0)
                    then _draw_text(tar,ui_menu_csm_x2+5, y, str_srace+str_observer        , ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false)and(PlayerTeam>0),false))
                    else _draw_text(tar,ui_menu_csm_x2+6, y, str_srace+str_race[PlayerRace], ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false)and(PlayerTeam>0),false));
                    _draw_text(tar,ui_menu_csm_x3+6, y, str_ready+b2cc[PlayerReady]        , ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false),false));
                    vlineColor(tar,ui_menu_csm_x2  , t,i, c_gray);
                    vlineColor(tar,ui_menu_csm_x3  , t,i, c_gray);
                 end;
              end;
   end;
end;

procedure d_updmenu(tar:pSDL_Surface);
begin
   _draw_surf(tar,0,0,spr_mback);
   _draw_text(tar,spr_mback^.w,spr_mback^.h-font_w,str_ver,ta_right,255,c_white);

   _draw_text(tar,spr_mback^.w shr 1,spr_mback^.h-font_w, str_cprt , ta_middle,255, c_white);

   _draw_text(tar, 70,554, str_exit [G_Started], ta_middle,255, c_white);
   _draw_text(tar,730,554, str_reset[G_Started], ta_middle,255, mic((net_status<>ns_client)and (G_Started or PlayersReadyStatus),false));

   D_MMap    (tar);
   D_MPlayers(tar);
   D_M1      (tar);
   D_M2      (tar);
end;

procedure D_Menu;
begin
   if(vid_menu_redraw)then
   begin
      //map_RedrawMenuMinimap;
      d_updmenu(r_menu);
      vid_menu_redraw:=false;
   end;

   _draw_surf(r_screen,mv_x,mv_y,r_menu    );
   _draw_surf(r_screen,mouse_x,mouse_y,spr_cursor);
end;


