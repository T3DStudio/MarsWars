
procedure D_menu_ScrollBar(tar:pSDL_Surface;mi:byte;scrolli,scrolls,scrollmax:integer);
var posCY,
    barh:integer;
begin
   with menu_items[mi] do
   begin
      barh :=(y1-y0);
      if(scrolls<scrollmax)then
      begin
         barh :=mm3(1,round((y1-y0)*(scrolls/scrollmax)),barh);
         posCY:=y0+round((y1-y0-barh)*(scrolli/(scrollmax-scrolls)));
      end
      else posCY:=y0;

      vlineColor(tar,x0+1,posCY,posCY+barh,c_lime);
      vlineColor(tar,x0+2,posCY,posCY+barh,c_lime);
   end;
end;

function mic(enable,selected:boolean):cardinal;
begin
   mic:=c_white;
   if(not enable)then mic:=c_gray
   else
     if(selected)then mic:=c_yellow;
end;
procedure D_menu_EText(tar:pSDL_Surface;me,halignment,valignment:byte;text:shortstring;listarrow:boolean;selected:byte);
const larrow_w  = 16;
      larrow_hw = larrow_w div 2;
var tx,tx1,ty:integer;
    color:cardinal;
begin
   with menu_items[me] do
   if(x0>0)then
   begin
      tx:=x0;
      ty:=y0;
      if(listarrow)
      then tx1:=max2(x0,x1-larrow_w)
      else tx1:=x1;
      case halignment of
      ta_left    : tx:=x0+font_34;
      ta_middle  : tx:=(x0+tx1) div 2;
      ta_right   : tx:=tx1-font_34;
      ta_rightmid: begin
                   tx:=((x0+x1) div 2)+font_34;
                   halignment:=ta_left;
                   end;
      end;
      case valignment of
      ta_left    : ty:= y0+font_34;
      ta_middle  : ty:=((y0+y1) div 2)-font_hw+1;
      ta_right   : ty:= y1-font_3hw;
      end;

      color:=mic(enabled,((selected>0) or listarrow)and((menu_item=me)or(selected>1)));

      draw_text(tar,tx,ty,text,halignment,255,color);

      if(listarrow)then characterColor(tar,tx1+larrow_hw-font_hw,ty,#31,color);
   end;
end;

procedure D_menu_ValBar(tar:pSDL_Surface;mi:byte;val,max:integer);
var tx0,tx1:integer;
begin
   with menu_items[mi] do
   begin
      tx1:=x1-font_w;
      tx0:=tx1-max;
      vlineColor(tar,tx0,y0+1,y1,c_gray);
      vlineColor(tar,tx1,y0+1,y1,c_gray);
      boxColor  (tar,tx0,y0+font_hw+1,tx0+val,y1-font_hw,c_lime);

      draw_text(tar,tx0-font_34,((y0+y1) div 2)-font_hw+1,i2s(round(val/max*100))+'%',ta_right,255,c_white);
   end;
end;
procedure D_menu_ETextD(tar:pSDL_Surface;mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte);
begin
   D_menu_EText(tar,mi,ta_left  ,ta_middle,l_text,false    ,byte(listarrow)+selected);
   D_menu_EText(tar,mi,ta_right ,ta_middle,r_text,listarrow,selected);
end;
procedure D_menu_ETextN(tar:pSDL_Surface;mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte);
begin
   D_menu_EText(tar,mi,ta_left    ,ta_middle,l_text,false    ,byte(listarrow)+selected);
   D_menu_EText(tar,mi,ta_rightmid,ta_middle,r_text,listarrow,selected);
   with menu_items[mi] do vlineColor(tar,(x0+x1) div 2,y0+1,y1,c_gray);
end;

procedure D_MMap(tar:pSDL_Surface);
var i:integer;
//function _yt(s:integer):integer;begin _yt:=ui_menu_map_y0+s*ui_menu_map_ys+6; end;
begin
   draw_text(tar, ui_menu_map_cx, ui_menu_map_cy, str_MMap, ta_middle,255, c_white);

   {boxColor(tar,
   ui_menu_map_rx0,ui_menu_map_y0,
   ui_menu_map_rx1,ui_menu_map_y1,    194
   c_black);  }

   if(menu_s2=ms2_camp)then
   begin
      //draw_surf(tar, 91 ,129,campain_mmap  [campain_mission_n]);
      //draw_text(tar, 252,132,str_camp_m[campain_mission_n], ta_left,255, c_white);
   end
   else
   begin
      i:=0;
      while (i<=ui_menu_map_ph) do
      begin
         hlineColor(tar,ui_menu_map_px0,ui_menu_map_px1,ui_menu_map_py0+i,c_ltgray);
         i+=ui_menu_map_lh;
      end;
      vlineColor(tar,ui_menu_map_px0,ui_menu_map_py0,ui_menu_map_py1,c_ltgray);
      vlineColor(tar,ui_menu_map_px1,ui_menu_map_py0,ui_menu_map_py1,c_ltgray);

      D_menu_EText (tar,mi_map_params2,ta_middle,ta_middle,c2s(map_seed)      ,false,1);

      D_menu_ETextD(tar,mi_map_params3,str_m_siz,i2s(map_mw)                  ,true ,0);
      D_menu_ETextD(tar,mi_map_params4,str_m_tpe,str_mapt[map_type]           ,true ,0);
      D_menu_ETextD(tar,mi_map_params5,str_m_sym,str_m_symt[map_symmetry]     ,true ,0);

      D_menu_EText (tar,mi_map_params6,ta_middle,ta_middle,str_mrandom        ,false,0);
      D_menu_EText (tar,mi_map_params7,ta_middle,ta_middle,theme_name[theme_i],false,0);
   end;

   {rectangleColor(tar,
   ui_menu_map_rx0,ui_menu_map_y0,
   ui_menu_map_rx1,ui_menu_map_y1,
   c_white);}
end;

procedure D_MPlayers(tar:pSDL_Surface);
var y,p,u:integer;
        c:cardinal;
     tstr:shortstring;
function _yl(s:integer):integer;begin _yl:=s*ui_menu_pls_lh; end;
function _yt(s:integer):integer;begin _yt:=_yl(s)+font_34; end;
begin
   if(menu_s2=ms2_camp)then
   begin
      draw_text(tar,ui_menu_pls_cptx, ui_menu_pls_cpty, str_MObjectives, ta_middle,255, c_white);

      //draw_text(tar, ui_menu_pls_xc , ui_menu_pls_zy0+_yt(0)  ,str_camp_t[campain_mission_n],ta_middle,255,c_white);
      //draw_text(tar, ui_menu_pls_zxn, ui_menu_pls_zy0+_yt(1)+8,str_camp_o[campain_mission_n],ta_left  ,255,c_white);
   end
   else
     if(net_svsearch)then
     begin
        draw_text(tar,ui_menu_pls_cptx, ui_menu_pls_cpty, str_MServers+'('+i2s(net_svsearch_listn)+')', ta_middle,255, c_white);

        with menu_items[mi_mplay_NetSearchList] do
        begin
           hlineColor(tar,x0,x1,y0,c_white);
           hlineColor(tar,x0,x1,y1,c_white);

           if(net_svsearch_listn>0)then
            for u:=0 to vid_srch_m do
            begin
               p:=u+net_svsearch_scroll;
               if(p<net_svsearch_listn)then
                with net_svsearch_list[p] do
                begin
                   y:=y0+(u*ui_menu_nsrch_lh3);
                   if(p=net_svsearch_sel)then boxColor(tar,x0,y+1,x1,y+ui_menu_nsrch_lh3,c_dgray);
                   hlineColor(tar,x0,x1,y+ui_menu_nsrch_lh3,c_white);
                   draw_text(tar,x0+3,y+font_hw,i2s(p+1)+')'+info,ta_left,ui_menu_chat_width,c_white);
                end;
            end;
        end;

        D_menu_ScrollBar(tar,mi_mplay_NetSearchList,net_svsearch_scroll,vid_srch_m+1,net_svsearch_listn);
        D_menu_EText(tar,mi_mplay_NetSearchCon,ta_middle,ta_middle,str_connect[false],false,0);
     end
     else
     begin
        draw_text(tar, ui_menu_pls_cptx, ui_menu_pls_cpty, str_MPlayers, ta_middle,255, c_white);

        // ui_menu_pls_pbx0

        //vlineColor(tar, ui_menu_pls_zxn, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
        //vlineColor(tar, ui_menu_pls_zxs, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
        //vlineColor(tar, ui_menu_pls_zxr, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
        //vlineColor(tar, ui_menu_pls_zxt, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );
        //vlineColor(tar, ui_menu_pls_zxc, ui_menu_pls_zy0, ui_menu_pls_zy0+_yl(MaxPlayers),c_gray );

        vlineColor(tar, ui_menu_pls_cx_race , ui_menu_pls_pby0, ui_menu_pls_pby1,c_gray);
        vlineColor(tar, ui_menu_pls_cx_team , ui_menu_pls_pby0, ui_menu_pls_pby1,c_gray);
        vlineColor(tar, ui_menu_pls_cx_color, ui_menu_pls_pby0, ui_menu_pls_pby1,c_gray);

        for p:=1 to MaxPlayers do
         with g_players[p] do
         begin
            y:=ui_menu_pls_pby0+_yl(p-1);
            u:=ui_menu_pls_pby0+_yt(p-1);

            hlineColor(tar,ui_menu_pls_pbx0,ui_menu_pls_pbx1,y,c_gray);

            // name/status
            c:=c_dgray;
            if(state=ps_play)then
            begin
               tstr:=name;
               c   :=c_white;
            end
            else
              case slot_state of
              ps_opened   : if(g_ai_slots=0)
                            then tstr:=str_PlayerSlots[slot_state]
                            else tstr:=str_PlayerSlots[3+g_ai_slots];
              ps_closed,
              ps_observer,
              ps_AI_1..
              ps_AI_11    : begin
                               tstr:=str_PlayerSlots[slot_state];
                               c   :=c_white;
                            end;
              end;

            D_menu_EText(tar,mi_player_status1+(p-1),ta_left,ta_middle,tstr,true,0);

            if(team=0)
            then tstr:=str_observer
            else tstr:=str_race[slot_race];
            D_menu_EText(tar,mi_player_race1  +(p-1),ta_middle,ta_middle,tstr           ,true,0);
            D_menu_EText(tar,mi_player_team1  +(p-1),ta_middle,ta_middle,str_teams[team],true,0);

            //draw_text(tar,ui_menu_pls_pbx0+font_w,y+ui_menu_pls_ty,tstr,ta_left,255,c);

            boxColor(tar,ui_menu_pls_color_x0,y+ui_menu_pls_border,
                         ui_menu_pls_color_x1,y-ui_menu_pls_border+ui_menu_pls_lh,PlayerGetColor(p));

            {c:=c_white;
            if G_started or (net_status=ns_client)then c:=c_gray;

            if(state<>ps_none)then
            begin
               draw_text(tar,ui_menu_pls_zxst, u,PlayerGetStatus(p), ta_middle, 255, c);
               draw_text(tar,ui_menu_pls_zxnt, u,name              , ta_left  , 255, c_white);
               if(G_Started)
               or(net_status=ns_client)
               or((net_status<ns_client)and(state=ps_play)and(p<>PlayerClient))
               or(team=0)then c:=c_gray;
               if(team=0)
               then draw_text(tar,ui_menu_pls_zxrt, u,str_observer   , ta_middle, 255, c)
               else draw_text(tar,ui_menu_pls_zxrt, u,str_race[slot_race], ta_middle, 255, c);
               if(g_mode in gm_FixedPositionsModes)then c:=c_gray;
               draw_text(tar,ui_menu_pls_zxtt, u,t2c(PlayerGetTeam(g_mode,p)), ta_middle, 255, c);
               if(not GetBBit(@g_player_astatus,p))and(G_Started)then lineColor(tar,ui_menu_pls_zxnt,u+4,ui_menu_pls_zxs-6,u+4,c_red);
            end
            else
              if(g_ai_slots>0)then
              begin
                 draw_text(tar,ui_menu_pls_zxst, u,str_ps_c[ps_comp]              , ta_middle,255, c_gray);
                 draw_text(tar,ui_menu_pls_zxnt, u,str_ps_comp+' '+b2s(g_ai_slots), ta_left  ,255, c_gray);
                 draw_text(tar,ui_menu_pls_zxrt, u,str_race[r_random]             , ta_middle,255, c_gray);
                 draw_text(tar,ui_menu_pls_zxtt, u,b2s(PlayerGetTeam(g_mode,p))   , ta_middle,255, c_gray);
              end
              else draw_text(tar,ui_menu_pls_zxst, u,PlayerGetStatus(p), ta_middle, 255, c); }
            //boxColor(tar,ui_menu_pls_zxc1,u,ui_menu_pls_zxc2,u+6,PlayerGetColor(p));
         end;
        hlineColor(tar,ui_menu_pls_pbx0,ui_menu_pls_pbx1,ui_menu_pls_pby1,c_gray);

        //rectangleColor(tar,ui_menu_pls_zxn,ui_menu_pls_zy0,ui_menu_pls_zxe,ui_menu_pls_zy1,c_white);
     end;
end;

procedure D_M1(tar:pSDL_Surface);
var t,i,y:integer;
function _yl(s:integer):integer;begin _yl:=ui_menu_ssr_zy0+s*ui_menu_ssr_lh+1; end;
begin

   D_menu_EText(tar,mi_tab_settings,ta_middle,ta_middle,str_menu_s1[ms1_sett],false,1+byte(menu_s1=ms1_sett));
   D_menu_EText(tar,mi_tab_saveload,ta_middle,ta_middle,str_menu_s1[ms1_svld],false,1+byte(menu_s1=ms1_svld));
   D_menu_EText(tar,mi_tab_replays ,ta_middle,ta_middle,str_menu_s1[ms1_reps],false,1+byte(menu_s1=ms1_reps));

   hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,ui_menu_ssr_zy0+ui_menu_ssr_lh,c_ltgray);

   i:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
   t:=ui_menu_ssr_zy0;
   while (i<ui_menu_ssr_zx1) do
   begin
      vlineColor(tar,i,t,t+ui_menu_ssr_lh,c_ltgray);
      i+=ui_menu_ssr_cw;
   end;


   case menu_s1 of
   ms1_sett : begin
                 D_menu_EText(tar,mi_settings_game ,ta_middle,ta_middle,str_menu_s3[ms3_game],false,1+byte(menu_s3=ms3_game));
                 D_menu_EText(tar,mi_settings_video,ta_middle,ta_middle,str_menu_s3[ms3_vido],false,1+byte(menu_s3=ms3_vido));
                 D_menu_EText(tar,mi_settings_sound,ta_middle,ta_middle,str_menu_s3[ms3_sond],false,1+byte(menu_s3=ms3_sond));

                 t:=_yl(2);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,t,c_ltgray);

                 i:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
                 while(i<ui_menu_ssr_zx1)do
                 begin
                    vlineColor(tar,i,t,t-ui_menu_ssr_lh,c_ltgray);
                    i+=ui_menu_ssr_cw;
                 end;

                 t:=_yl(3);
                 while(t<ui_menu_ssr_zy1)do
                 begin
                    hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,t,c_gray);
                    t+=ui_menu_ssr_lh;
                 end;


                 case menu_s3 of
       ms3_game: begin
                    D_menu_ETextD(tar,mi_settings_ColoredShadows ,str_ColoredShadow  ,b2cc[vid_ColoredShadow]  ,false,0);
                    D_menu_ETextD(tar,mi_settings_ShowAPM        ,str_APM            ,b2cc[vid_APM]            ,false,0);
                    D_menu_ETextD(tar,mi_settings_HitBars        ,str_uhbar          ,str_uhbars[vid_uhbars]   ,true ,0);
                    D_menu_ETextD(tar,mi_settings_MRBAction      ,str_maction        ,str_maction2[m_action]   ,true ,0);

                    D_menu_ETextD(tar,mi_settings_ScrollSpeed    ,str_scrollspd      ,''                       ,false,0);
                    D_menu_ValBar(tar,mi_settings_ScrollSpeed    ,vid_CamSpeed,max_CamSpeed);

                    D_menu_ETextD(tar,mi_settings_MouseScroll    ,str_mousescrl      ,b2cc[vid_CamMScroll]     ,false,0);

                    D_menu_ETextN(tar,mi_settings_PlayerName     ,str_plname         ,PlayerName               ,false,1);

                    D_menu_ETextD(tar,mi_settings_Langugage      ,str_language       ,str_lng[ui_language]     ,true ,0);
                    D_menu_ETextD(tar,mi_settings_PanelPosition  ,str_panelpos       ,str_panelposp[vid_ppos]  ,true ,0);
                    D_menu_ETextD(tar,mi_settings_PlayerColors   ,str_pcolor         ,str_pcolors[vid_plcolors],true ,0);
                 end;

       ms3_vido: begin
                    D_menu_ETextD(tar,mi_settings_ResWidth       ,str_resol_width    ,i2s(menu_res_w)          ,true ,0);
                    D_menu_ETextD(tar,mi_settings_ResHeight      ,str_resol_height   ,i2s(menu_res_h)          ,true ,0);
                    D_menu_EText (tar,mi_settings_ResApply       ,ta_middle,ta_middle,str_apply                ,false,0);

                    D_menu_ETextD(tar,mi_settings_Fullscreen     ,str_fullscreen     ,b2cc[not vid_fullscreen] ,false,0);
                    D_menu_ETextD(tar,mi_settings_ShowFPS        ,str_fps            ,b2cc[vid_fps]            ,false,0);
                 end;

       ms3_sond: begin
                    D_menu_ETextD(tar,mi_settings_SoundVol       ,str_soundvol       ,''                       ,false,0);
                    D_menu_ValBar(tar,mi_settings_SoundVol       ,round(snd_svolume1*max_svolume),max_svolume);

                    D_menu_ETextD(tar,mi_settings_MusicVol       ,str_musicvol       ,''                       ,false,0);
                    D_menu_ValBar(tar,mi_settings_MusicVol       ,round(snd_mvolume1*max_svolume),max_svolume);

                    D_menu_EText (tar,mi_settings_NextTrack      ,ta_middle,ta_middle,str_NextTrack            ,false,0);
                 end;
                 end;
              end;
   ms1_svld : begin
                 vlineColor(tar,ui_menu_ssr_cx,_yl(1)+1,_yl(12),c_gray);

                 i:=_yl(12);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,i-ui_menu_ssr_lh,c_gray);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,i,c_gray);
                 t:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);
                 t+=ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);

                 D_menu_EText (tar,mi_saveload_fname ,ta_left  ,ta_middle,svld_str_fname,false,1);

                 D_menu_EText (tar,mi_saveload_save  ,ta_middle,ta_middle,str_save      ,false,0);
                 D_menu_EText (tar,mi_saveload_load  ,ta_middle,ta_middle,str_load      ,false,0);
                 D_menu_EText (tar,mi_saveload_delete,ta_middle,ta_middle,str_delete    ,false,0);

                 for t:=0 to vid_svld_m do
                 begin
                    i:=t+svld_list_scroll;
                    if(i<svld_list_size)then
                    begin
                       y:=_yl(t+1);
                       if(i=svld_list_sel)then
                       begin
                          boxColor(tar,ui_menu_ssr_zx0,y+1,ui_menu_ssr_cx-1,y+ui_menu_ssr_lh-1,c_dgray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+1               ,c_gray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+ui_menu_ssr_lh-1,c_gray);
                       end;
                       draw_text(tar,ui_menu_ssr_zx0+font_34,y+font_34,b2s(i+1)+'.'+svld_list[i],ta_left,255,mic(true,i=svld_list_sel));
                    end;
                 end;
                 D_menu_ScrollBar(tar,mi_saveload_list,svld_list_scroll,vid_svld_m+1,svld_list_size);

                 draw_text(tar,ui_menu_ssr_cx+font_34,_yl(1)+font_34,svld_str_info,ta_left,19,c_white);
              end;
   ms1_reps : begin
                 vlineColor(tar,ui_menu_ssr_cx,_yl(1)+1,_yl(12),c_gray);

                 i:=_yl(12);
                 hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_zx1,i,c_gray);
                 t:=ui_menu_ssr_zx0+ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);
                 t+=ui_menu_ssr_cw;
                 vlineColor(tar,t,i,i+ui_menu_ssr_lh,c_gray);

                 D_menu_EText (tar,mi_replays_play  ,ta_middle,ta_middle,str_play      ,false,0);
                 D_menu_EText (tar,mi_replays_delete,ta_middle,ta_middle,str_delete    ,false,0);

                 for t:=0 to vid_rpls_m do
                 begin
                    i:=t+rpls_list_scroll;
                    if(i<rpls_list_size)then
                    begin
                       y:=_yl(t+1);
                       if(i=rpls_list_sel)then
                       begin
                          boxColor(tar,ui_menu_ssr_zx0,y+1,ui_menu_ssr_cx-1,y+ui_menu_ssr_lh-1,c_dgray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+1               ,c_gray);
                          hlineColor(tar,ui_menu_ssr_zx0,ui_menu_ssr_cx,y+ui_menu_ssr_lh-1,c_gray);
                       end;
                       draw_text(tar,ui_menu_ssr_zx0+font_34,y+font_34,TrimString(b2s(i+1)+'.'+rpls_list[i],18),ta_left,255,mic(true,i=rpls_list_sel));
                    end;
                 end;
                 D_menu_ScrollBar(tar,mi_replays_list,rpls_list_scroll,vid_rpls_m+1,rpls_list_size);

                 draw_text(tar,ui_menu_ssr_cx+font_34,_yl(1)+font_34,rpls_str_info,ta_left,19,c_white);
              end;
   end;
end;

procedure D_M2(tar:pSDL_Surface);
var t,i,y:integer;
function _yl(s:integer):integer;begin _yl:=ui_menu_cgm_zy0+s*ui_menu_cgm_lh+1; end;
procedure default_lines;
begin
   t:=_yl(2);
   while(t<ui_menu_cgm_zy1)do
   begin
      hlineColor(tar,ui_menu_cgm_zx0,ui_menu_cgm_zx1,t,c_gray);
      t+=ui_menu_cgm_lh;
   end;
end;
begin
   D_menu_EText (tar,mi_tab_campaing   ,ta_middle,ta_middle,str_menu_s2[ms2_camp],false,1+byte(menu_s2=ms2_camp));
   D_menu_EText (tar,mi_tab_game       ,ta_middle,ta_middle,str_menu_s2[ms2_game],false,1+byte(menu_s2=ms2_game));
   D_menu_EText (tar,mi_tab_multiplayer,ta_middle,ta_middle,str_menu_s2[ms2_mult],false,1+byte(menu_s2=ms2_mult));

   hlineColor(tar,ui_menu_cgm_zx0,ui_menu_cgm_zx1,ui_menu_cgm_zy0+ui_menu_cgm_lh,c_ltgray);

   i:=ui_menu_cgm_zx0+ui_menu_cgm_cw;
   t:=ui_menu_cgm_zy0;
   while (i<ui_menu_cgm_zx1) do
   begin
      vlineColor(tar,i,t,t+ui_menu_cgm_lh,c_ltgray);
      i+=ui_menu_cgm_cw;
   end;

   case menu_s2 of
   ms2_camp : begin
                 {draw_text(tar,ui_menu_csm_xt0,_yt(1),str_cmpdif+str_cmpd[campain_skill],ta_left,255,mic(not g_started,false));
                 y:=_yl(2);
                 hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_white);
                 for t:=1 to vid_camp_m do
                 begin
                    i:=t+_cmp_sm-1;
                    if(i=campain_mission_n)then
                    begin
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y+ui_menu_csm_ys,c_gray);
                    end;
                    //draw_text(tar,ui_menu_csm_xt0,y+6,str_camp_t[i],ta_left,255,mic(not g_started,i=campain_mission_n));
                    y+=ui_menu_csm_ys;
                 end;}
              end;
   ms2_game : begin
                 default_lines;

                 // game options
                 D_menu_EText (tar,mi_game_GameCaption   ,ta_middle,ta_middle,str_goptions,false,0);
                 D_menu_ETextD(tar,mi_game_mode          ,str_gmodet       ,str_gmode[g_mode]            ,true ,0);
                 D_menu_ETextD(tar,mi_game_builders      ,str_starta       ,b2s(g_start_base+1)          ,true ,0);
                 D_menu_ETextD(tar,mi_game_generators    ,str_generators   ,str_generatorsO[g_generators],true ,0);
                 D_menu_ETextD(tar,mi_game_FixStarts     ,str_fstarts      ,b2cc[g_fixed_positions]      ,false,0);
                 D_menu_ETextD(tar,mi_game_DeadPbserver  ,str_DeadObservers,b2cc[g_deadobservers]        ,false,0);
                 D_menu_ETextD(tar,mi_game_EmptySlots    ,str_aislots      ,ai_name(g_ai_slots)          ,true ,0);
                 D_menu_EText (tar,mi_game_RandomSkrimish,ta_middle,ta_middle,str_randoms,false,0);

                 D_menu_EText (tar,mi_game_RecordCaption ,ta_middle,ta_middle,str_replay,false,0);
                 D_menu_ETextD(tar,mi_game_RecordStatus  ,str_replay_status,str_rstatus[rpls_state]      ,false,0);
                 D_menu_ETextN(tar,mi_game_RecordName    ,str_replay_name  ,rpls_str_name                ,false,1);
            if(rpls_state>rpls_state_none)and(g_cl_units>0)
            then D_menu_ETextD(tar,mi_game_RecordQuality ,str_pnu          ,i2s(min2(_cl_pnua[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_pnua[rpls_pnui]          ,true ,0)
            else D_menu_ETextD(tar,mi_game_RecordQuality ,str_pnu          ,str_pnua[rpls_pnui]          ,true ,0);
              end;
   ms2_mult : begin
                 default_lines;


                 D_menu_EText (tar,mi_mplay_ServerCaption ,ta_middle,ta_middle,str_server                    ,false,0);
                 D_menu_EText (tar,mi_mplay_ServerToggle  ,ta_middle,ta_middle,str_svup[net_status=ns_server],false,0);
                 D_menu_ETextD(tar,mi_mplay_ServerPort    ,str_udpport        ,net_sv_pstr                   ,false,1);

                 D_menu_EText (tar,mi_mplay_ClientCaption ,ta_middle,ta_middle,str_client                    ,false,0);
                 D_menu_ETextD(tar,mi_mplay_NetSearch     ,str_netsearch      ,b2cc[net_svsearch]            ,false,0);
                 D_menu_ETextD(tar,mi_mplay_ClientAddress ,net_cl_svstr       ,''                            ,false,1);
                 D_menu_ETextD(tar,mi_mplay_ClientConnect ,str_connect[net_status=ns_client],net_m_error     ,false,0);

                 {
                 mi_mplay_ServerToggle      = 170;
                 mi_mplay_ServerPort  = 171;
                 mi_mplay_NetSearch
                 mi_mplay_ClientConnect= 172;
                 mi_mplay_ClientAddress  = 173;

                 draw_text(tar,ui_menu_csm_xc, _yt(12), str_menu_chat, ta_middle,255, mic((net_status<>ns_single)and(not net_svsearch),m_chat));

                 if(m_chat)then
                 begin
                    y:=_yl(12);
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y-ui_menu_csm_ys,c_gray);
                    hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);

                    y:=_yt(10);
                    MakeLogListForDraw(PlayerClient,ui_menu_chat_width,ui_menu_chat_height,lmts_menu_chat);
                    if(ui_log_n>0)then
                     for t:=0 to ui_log_n-1 do
                      if(ui_log_c[t]>0)then draw_text(tar,ui_menu_csm_xct,y-t*ui_menu_csm_ycs,ui_log_s[t],ta_left,255,ui_log_c[t]);

                    draw_text(tar,ui_menu_csm_xct, _yt(11), net_chat_str , ta_chat,ui_menu_chat_width, c_white);
                 end
                 else
                 begin
                    t:=ui_menu_csm_y0+ui_menu_csm_ys;

                    while (t<ui_menu_csm_y1) do
                    begin
                       t+=ui_menu_csm_ys;
                       hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,t,c_gray);
                    end;

                    // server
                    y:=_yt(2);
                    draw_text(tar,ui_menu_csm_xt1, y, str_server, ta_left,255, c_white);
                    draw_text(tar,ui_menu_csm_xt2, y,str_svup[net_status=ns_server]       , ta_right ,255, mic((net_status<>ns_client)and(G_Started=false),false));
                    vlineColor(tar,ui_menu_csm_xc , _yl(2),_yl(2)+ui_menu_csm_ys, c_gray);
                    y:=_yt(3);
                    draw_text(tar,ui_menu_csm_xt0, y,str_udpport                          , ta_left  ,255 ,mic((net_status=ns_single),menu_item=87));
                    draw_text(tar,ui_menu_csm_xt2, y,net_sv_pstr                          , ta_right ,255 ,mic((net_status=ns_single),menu_item=87));

                    // client
                    y:=_yt(6);
                    draw_text(tar,ui_menu_csm_xt1, y, str_client                          , ta_left  ,255, c_white);
                    draw_text(tar,ui_menu_csm_xt2, y, net_m_error                         , ta_right ,255, c_red  );

                    y:=_yt(7);
                    draw_text(tar,ui_menu_csm_xt0, y, str_netsearch                       , ta_left  ,255, mic((G_Started=false)and(net_svsearch or (net_status=ns_single)),net_svsearch));

                    y:=_yt(8);
                    vlineColor(tar,ui_menu_csm_x3 , _yl(8),_yl(8)+ui_menu_csm_ys, c_gray);
                    draw_text(tar,ui_menu_csm_xt2, y, str_connect[net_status=ns_client]   , ta_right ,255, mic((net_status<>ns_server)and(not net_svsearch)and((net_status=ns_client)or(G_Started=false)),false));
                    draw_text(tar,ui_menu_csm_xt0, y, net_cl_svstr                        , ta_left  ,255, mic((net_status=ns_single),menu_item=92));

                    y:=_yt(9);
                    draw_text(tar,ui_menu_csm_xt0, y, str_npnu+str_npnua[net_pnui]        , ta_left  ,255, mic((net_status<>ns_server),false));
                    if(g_cl_units>0)then
                    draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                             ta_right ,255, c_white);
                    y:=_yt(10);
                    t:=_yl(10);
                    i:=t+ui_menu_csm_ys;
                    draw_text(tar,ui_menu_csm_xt0 , y, str_team+t2c(PlayerTeam)           , ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false),false));

                    if(PlayerTeam=0)
                    then draw_text(tar,ui_menu_csm_x2+5, y, str_srace+str_observer        , ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false)and(PlayerTeam>0),false))
                    else draw_text(tar,ui_menu_csm_x2+6, y, str_srace+str_race[PlayerRace], ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false)and(PlayerTeam>0),false));
                    draw_text(tar,ui_menu_csm_x3+6, y, str_ready+b2cc[PlayerReady]        , ta_left  ,255, mic((net_status<>ns_server)and(G_Started=false),false));
                    vlineColor(tar,ui_menu_csm_x2  , t,i, c_gray);
                    vlineColor(tar,ui_menu_csm_x3  , t,i, c_gray);
                 end; }
              end;
   end;
end;

procedure d_UpdateMenu(tar:pSDL_Surface);
begin
   draw_surf(tar,0,0,spr_mback);
   draw_text(tar,spr_mback^.w,spr_mback^.h-font_w,str_ver,ta_right,255,c_white);

   if(test_mode>0)then draw_text(tar,spr_mback^.w div 2,spr_mback^.h-font_5w,'TEST MODE '+b2s(test_mode),ta_middle,255,c_white);

   draw_text(tar,spr_mback^.w div 2,spr_mback^.h-font_w, str_cprt , ta_middle,255, c_white);

   D_menu_EText(tar,mi_exit ,ta_middle,ta_middle,str_exit [G_Started],false,0);
   D_menu_EText(tar,mi_back ,ta_middle,ta_middle,str_exit [G_Started],false,0);

   D_menu_EText(tar,mi_start,ta_middle,ta_middle,str_reset[G_Started],false,0);
   D_menu_EText(tar,mi_break,ta_middle,ta_middle,str_reset[G_Started],false,0);

   D_MMap    (tar);
   D_MPlayers(tar);
   D_M1      (tar);
   D_M2      (tar);
end;

procedure D_Menu_List;
var i,y:integer;
  color:cardinal;
begin
   menu_list_x+=menu_x;
   menu_list_y+=menu_y;
   y:=menu_list_y+(ui_menu_list_item_H*menu_list_n);
   boxColor      (r_screen,menu_list_x-menu_list_w,menu_list_y,menu_list_x,y,c_black);
   RectangleColor(r_screen,menu_list_x-menu_list_w,menu_list_y,menu_list_x,y,c_white);
   for i:=0 to menu_list_n-1 do
   with menu_list_items[i] do
   begin
      y:=menu_list_y+(ui_menu_list_item_H*i);
      color:=0;
      if(i=menu_list_selected)
      then color:=c_dgray
      else
        if(i=menu_list_current)
        then color:=c_gray;

      if(color<>0)
      then boxColor(r_screen,menu_list_x-menu_list_w+1,y+1,menu_list_x-1,y+ui_menu_list_item_H,color);

      if(mli_enabled)
      then color:=c_white
      else color:=c_gray;

      draw_text (r_screen,menu_list_x-ui_menu_list_item_S,y+ui_menu_list_item_S,mli_caption,ta_right,255,color);
      hlineColor(r_screen,menu_list_x-menu_list_w+1,menu_list_x-1,y+ui_menu_list_item_H,c_white);
   end;
   menu_list_x-=menu_x;
   menu_list_y-=menu_y;
end;

procedure D_Menu;
var i:integer;
begin
   if(menu_update)then
   begin
      map_RedrawMenuMinimap(vid_map_RedrawBack);
      d_UpdateMenu(r_menu);
      menu_update:=false;
      vid_map_RedrawBack:=false;

      if(menu_list_n>0)then
       with menu_items[menu_item] do
       begin
          boxColor(r_menu,0   ,0 ,x0       ,r_menu^.h,c_ablack);
          boxColor(r_menu,x1  ,0 ,r_menu^.w,r_menu^.h,c_ablack);
          boxColor(r_menu,x0+1,0 ,x1-1     ,y0       ,c_ablack);
          boxColor(r_menu,x0+1,y1,x1-1     ,r_menu^.h,c_ablack);
       end;
      //if false then
      for i:=0 to 255 do
       with menu_items[i] do
        if(x0>0)then
         rectangleColor(r_menu,x0,y0,x1,y1,rgba2c(128+random(128),128+random(128),128+random(128),255));
   end;

   draw_surf(r_screen,menu_x,menu_y,r_menu);

   if(menu_list_n>0)then D_Menu_List;

   if(vid_FPS)then draw_text(r_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_right,255,c_white);

   draw_surf(r_screen,mouse_x,mouse_y,spr_cursor);
end;


