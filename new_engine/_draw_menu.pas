
procedure D_MMap;
var c:boolean;
begin
   _draw_text(_menu_surf, 229, 96, str_MMap, ta_middle,255, c_white);

   if(menu_s2<>ms2_camp)then
   begin
      c:=not((net_nstat=ns_clnt) or G_Started);

      _draw_text(_menu_surf, 308, 129, c2s(map_seed)                 , ta_Fmiddle,255, mic(c,_m_sel=ms_mapsed));
      _draw_text(_menu_surf, 252, 148, str_m_siz                     , ta_left   ,255, mic(c,false));
      _draw_text(_menu_surf, 365, 148, i2s(map_mw)                   , ta_FRight ,255, mic(c,false));

      _draw_text(_menu_surf, 252, 167, str_m_liq                     , ta_left   ,255, mic(c,false));
      _draw_text(_menu_surf, 365, 167, str_xN[map_liq]               , ta_FRight ,255, mic(c,false));

      _draw_text(_menu_surf, 252, 186, str_m_obs                     , ta_left   ,255, mic(c,false));
      _draw_text(_menu_surf, 365, 186, str_xN[map_obs]               , ta_FRight ,255, mic(c,false));
      _draw_text(_menu_surf, 308, 224, map_themes[map_themec]._name  , ta_Fmiddle,255, mic(c,false));


      _draw_text(_menu_surf, 308, 262, str_mrandom                   , ta_Fmiddle,255, mic(c,false));
   end
   else
   begin
      //_draw_surf(_menu_surf, 91 ,129,cmp_mmap[_cmp_sel]);
      //_draw_text(_menu_surf, 252,132,str_camp_m[_cmp_sel], ta_left,255, c_white);
   end;
end;



procedure D_MPlayers;
var y,p   :integer;
      mcol:cardinal;
begin
   if(menu_s2<>ms2_camp)then
   begin
      _draw_text(_menu_surf, 571, 96, str_MPlayers, ta_Fmiddle,255, c_white);

      if(G_started or (net_nstat=ns_clnt))
      then mcol:=c_gray
      else mcol:=c_white;

      for p:=1 to MaxPlayers do
       with _players[p] do
       begin
          y:=136+(p-1)*22;

          characterColor(_menu_surf,544,y,_plst(p),mcol);

          if(state<>ps_none)then
          begin
             _draw_text(_menu_surf,437, y, name, ta_left, 255,c_white);
             if G_Started or (net_nstat=ns_clnt) or ((net_nstat<ns_clnt)and(state=ps_play)and(p<>HPlayer)) then mcol:=c_gray;
             _draw_text(_menu_surf,606, y,str_race[mrace], ta_middle,255, mcol);
             if(g_mode in [gm_tdm2,gm_tdm3])then mcol:=c_gray;
             _draw_text(_menu_surf,664, y,b2s(_PickPTeam(p)), ta_middle,255, mcol);
          end
          else
            if(G_aislots>0)then
            begin
               _draw_text(_menu_surf,437, y,str_ps_comp+' '+b2s(G_aislots), ta_left, 255,c_gray);
               _draw_text(_menu_surf,606, y,str_race[r_random], ta_middle,255, c_gray);
               _draw_text(_menu_surf,664, y,b2s(_PickPTeam(p)), ta_middle,255, c_gray);
            end;

          boxColor(_menu_surf,696,y-2,707,y+8,color);
       end;
   end
   else
   begin
      _draw_text(_menu_surf,571, 96, str_MObjectives, ta_middle,255, c_white);
      boxColor(_menu_surf,418,110,723,275,c_black);

      //_draw_text(_menu_surf, 571, 119,str_camp_t[_cmp_sel],ta_middle,255,c_white);
      //_draw_text(_menu_surf, 424, 155,str_camp_o[_cmp_sel],ta_left  ,255,c_white);
   end;
end;

procedure D_M1;
var t,i,y:integer;
begin
   _draw_text(_menu_surf, 128, 330, str_menu_s1[ms1_sett], ta_middle, 255,mic(true,menu_s1=ms1_sett));
   _draw_text(_menu_surf, 230, 330, str_menu_s1[ms1_svld], ta_middle, 255,mic((net_nstat=ns_none)and(onlySVcode),menu_s1=ms1_svld));
   _draw_text(_menu_surf, 332, 330, str_menu_s1[ms1_reps], ta_middle, 255,mic(net_nstat=ns_none,menu_s1=ms1_reps));

   case menu_s1 of
   ms1_sett : begin
                 // SOUND
                 _draw_text(_menu_surf,126, 348, str_game , ta_middle,255, mic(true,menu_s3=ms3_game ));
                 _draw_text(_menu_surf,230, 348, str_video, ta_middle,255, mic(true,menu_s3=ms3_vid  ));
                 _draw_text(_menu_surf,332, 348, str_sound, ta_middle,255, mic(true,menu_s3=ms3_snd  ));

                 if(menu_s3=ms3_snd)then
                 begin
                    _draw_text(_menu_surf,80 , 381, str_soundvol, ta_left,255, mic(snd_svolume>0,false));
                    _draw_text(_menu_surf,369, 381, b2s(round(100*snd_svolume/127)), ta_right,255, c_white);
                    vlineColor(_menu_surf,177, 376, 392,c_gray);
                    vlineColor(_menu_surf,306, 376, 392,c_gray);
                    boxColor(_menu_surf,178,379,178+snd_svolume,389,c_lime);

                    _draw_text(_menu_surf,80 , 399, str_musicvol, ta_left,255, mic(snd_mvolume>0,false));
                    _draw_text(_menu_surf,369, 399, b2s(round(100*snd_mvolume/127)), ta_right,255, c_white);
                    vlineColor(_menu_surf,177, 395, 411,c_gray);
                    vlineColor(_menu_surf,306, 395, 411,c_gray);
                    boxColor(_menu_surf,178,398,178+snd_mvolume,408,c_lime);
                 end;
                 if(menu_s3=ms3_vid)then
                 begin
                    _draw_text(_menu_surf,80 , 381, str_resol     , ta_left,255, c_white);
                    _draw_text(_menu_surf,230, 381, i2s(m_vrx)+'x'+i2s(m_vry), ta_middle,255,mic(true,(m_vrx=vid_mw)and(m_vry=vid_mh)));
                    _draw_text(_menu_surf,332, 381, str_apply, ta_middle,255,mic((m_vrx<>vid_mw)or(m_vry<>vid_mh),(m_vrx<>vid_mw)or(m_vry<>vid_mh)));
                    vlineColor(_menu_surf,177, 376, 392,c_gray);
                    vlineColor(_menu_surf,279, 376, 392,c_gray);

                    _draw_text(_menu_surf, 80 , 399, str_fullscreen, ta_left,255, c_white);
                    _draw_text(_menu_surf, 369, 399, b2pm[not _fscr], ta_right,255, c_white);
                 end;
                 if(menu_s3=ms3_game)then
                 begin
                    _draw_text(_menu_surf, 80 , 381, str_maction  , ta_left,255, c_white);
                    _draw_text(_menu_surf, 369, 381, str_maction2[m_a_inv], ta_right,255,c_white);

                    _draw_text(_menu_surf, 80 , 399, str_scrollspd, ta_left,255, c_white);
                    vlineColor(_menu_surf, 205, 395, 411,c_gray);
                    boxColor(_menu_surf,206,398,206+vid_vmspd,408,c_lime);

                    _draw_text(_menu_surf, 80 , 418, str_mousescrl, ta_left,255, c_white);
                    _draw_text(_menu_surf, 369, 418, b2pm[vid_vmm], ta_left,255, c_white);

                    _draw_text(_menu_surf, 80 , 437, str_plname   , ta_left,255, c_white);
                    _draw_text(_menu_surf, 240, 437, PlayerName+chat_type[_m_sel<>ms_setpln], ta_left  ,255, mic((net_nstat=ns_none)and(G_Started=false),_m_sel=ms_setpln));
                    vlineColor(_menu_surf, 236, 433, 449,c_gray);

                    _draw_text(_menu_surf, 80 , 456, str_language , ta_left,255, c_white);
                    _draw_text(_menu_surf, 369, 456, str_lng[_lng], ta_right,255, c_white);
                 end;
              end;
   ms1_svld : begin
                 _draw_surf(_menu_surf,72,342,spr_msl);

                 _draw_text(_menu_surf,126, 510, str_save  , ta_middle,255, mic(G_Started and (_svld_str<>''),false));
                 _draw_text(_menu_surf,228, 510, str_load  , ta_middle,255, mic(_svld_cor,false));
                 _draw_text(_menu_surf,332, 510, str_delete, ta_middle,255, mic((_svld_ls<_svld_ln) ,false));

                 for t:=0 to menu_svld_m do
                 begin
                    i:=t+_svld_sm;
                    if(i<_svld_ln)then
                    begin
                       y:=350+t*14;
                       _draw_text(_menu_surf,77,y+2,b2s(i+1)+'.'+_svld_l[i],ta_left,255,mic(true,i=_svld_ls),SvRpLen);
                       if(i=_svld_ls)then
                       begin
                          hlineColor(_menu_surf,76,221,y-1,c_gray);
                          hlineColor(_menu_surf,76,221,y+13,c_gray);
                       end;
                    end;
                 end;

                 _draw_text(_menu_surf,224, 350,_svld_stat  ,ta_left,19,c_white);

                 vlineColor(_menu_surf,221,346,502,c_white);

                 hlineColor(_menu_surf,76,221,490,c_white);
                 _draw_text(_menu_surf,79,492,_svld_str+chat_type[_m_sel<>ms_svldsn],ta_left,255,mic(true,_m_sel=ms_svldsn) );
              end;
   ms1_reps : begin
                 _draw_surf(_menu_surf,72,342,spr_msl);

                 _draw_text(_menu_surf,126, 510, str_play  , ta_middle,255, mic((_rpls_cor)and(G_Started=false),false));
                 _draw_text(_menu_surf,332, 510, str_delete, ta_middle,255, mic((_rpls_ls<_rpls_ln)and(G_Started=false),false));

                 for t:=0 to menu_rpls_m do
                 begin
                    i:=t+_rpls_sm;
                    if(i<_rpls_ln)then
                    begin
                       y:=350+t*14;
                       _draw_text(_menu_surf,77,y+2,b2s(i+1)+'.'+_rpls_l[i],ta_left,255,mic((G_Started=false),i=_rpls_ls),SvRpLen);
                       if(i=_rpls_ls)then
                       begin
                          hlineColor(_menu_surf,76,221,y-1,c_gray);
                          hlineColor(_menu_surf,76,221,y+13,c_gray);
                       end;
                    end;
                 end;

                 _draw_text(_menu_surf,224, 350,_rpls_stat  ,ta_left,19,c_white);

                 vlineColor(_menu_surf,221,346,502,c_white);
              end;
   end;
end;

procedure D_M2;
var t{,i,y}:integer;
begin                                                                                                                 //)or (net_nstat>ns_none)
   _draw_text(_menu_surf, 470, 316, str_menu_s2[ms2_camp], ta_middle,255, mic((net_nstat=ns_none)and(G_Started=false)and false,menu_s2=ms2_camp));
   _draw_text(_menu_surf, 572, 316, str_menu_s2[ms2_scir], ta_middle,255, mic(not(G_Started and(menu_s2=ms2_camp)),menu_s2=ms2_scir));
   _draw_text(_menu_surf, 673, 316, str_menu_s2[ms2_mult], ta_middle,255, mic(not(G_Started and(menu_s2=ms2_camp)),menu_s2=ms2_mult));

   case menu_s2 of
   ms2_camp : begin
                 boxColor(_menu_surf,418,330,723,523,c_black);

                 {_draw_text(_menu_surf,424,290,str_cmpdif+str_cmpd[cmp_skill],ta_left,255,mic(not g_started,31=_cmp_sel));

                 for t:=1 to vid_camp_m do
                 begin
                    i:=t+_cmp_sm-1;
                    y:=287+t*14;
                    if(i=_cmp_sel)then
                    begin
                       hlineColor(_menu_surf,418,723,y-1,c_gray);
                       hlineColor(_menu_surf,418,723,y+13,c_gray);
                    end;
                    _draw_text(_menu_surf,424,y+3,str_camp_t[i],ta_left,255,mic(not g_started,i=_cmp_sel));
                 end;}

                 hlineColor(_menu_surf,418,723,344,c_white);
              end;
   ms2_scir : begin
                 _draw_text(_menu_surf,430, 341, str_goptions, ta_left,255, c_white);

                 _draw_text(_menu_surf,425, 365, str_gmodet        , ta_left  ,255, mic((G_Started=false)and(net_nstat<>ns_clnt),false));
                 _draw_text(_menu_surf,716, 365, str_gmode[g_mode] , ta_right ,255, c_white);

                 _draw_text(_menu_surf,425, 384, str_aislots, ta_left,255, mic((G_Started=false)and(net_nstat<>ns_clnt),false));
                 if(G_aislots>0)
                 then _draw_text(_menu_surf,716, 384, _ai_name(G_aislots), ta_right ,255, c_white)
                 else _draw_text(_menu_surf,716, 384, '-', ta_right ,255, c_white);

                 _draw_text(_menu_surf,425, 403, str_sstarts    , ta_left ,255, mic((G_Started=false)and(net_nstat<>ns_clnt)and not(g_mode in [gm_tdm2,gm_tdm3]),false));
                 _draw_text(_menu_surf,716, 403, b2pm[g_sslots or (g_mode in [gm_tdm2,gm_tdm3])] , ta_right,255, c_white);

                 _draw_text(_menu_surf,570, 440, str_randoms , ta_middle,255, mic((G_Started=false)and(net_nstat=0),false));

                 _draw_text(_menu_surf,430, 469, str_replay        , ta_left   ,255, c_white);
                 _draw_text(_menu_surf,531, 473, str_rpl[_rpls_rst], ta_Fmiddle,255, mic( _rpls_rst<rpl_rhead ,_rpls_rst>0));
                 _draw_text(_menu_surf,582, 473, _rpls_lrname+chat_type[_m_sel<>ms_rplsfn], ta_left   ,255, mic( _rpls_rst=rpl_none ,_m_sel=ms_rplsfn));
                 _draw_text(_menu_surf,436, 497, str_pnu+str_pnua[_rpls_pnui],ta_left,255, mic( _rpls_rst<rpl_rhead ,false));
              end;
   ms2_mult : begin
                 _draw_surf(_menu_surf,418, 330,spr_MBackmlt);

                 _draw_text(_menu_surf,570, 512, str_chat, ta_middle,255, mic((net_nstat<>ns_none),m_chat));

                 if(m_chat)then
                 begin
                    boxColor (_menu_surf,418,330,723,504,c_black);
                    lineColor(_menu_surf,418,491,723,491,c_white);

                    for t:=0 to MaxNetChat do _draw_text(_menu_surf,419,482-txt_line_h3*t,net_clchatm[t],ta_left,255,c_white);

                    _draw_text(_menu_surf, 419, 494, ui_chat_str , ta_left,255, c_white);
                 end
                 else
                 begin
                    _draw_text(_menu_surf,430, 341, str_server, ta_left,255, c_white);
                    _draw_text(_menu_surf,575, 365, str_udpport+net_sv_pstr+chat_type[_m_sel<>ms_mltsvp] , ta_left  ,255 ,mic((net_nstat=ns_none),_m_sel=ms_mltsvp));
                    _draw_text(_menu_surf,494, 365, str_svup[net_nstat=ns_srvr]                          , ta_middle,255, mic((net_nstat<>ns_clnt)and(G_Started=false),false));

                    _draw_text(_menu_surf,430, 389, str_client, ta_left,255, c_white);
                    _draw_text(_menu_surf,709, 389, net_m_error, ta_right,255,c_red);

                    _draw_text(_menu_surf,480, 414, str_connect[net_nstat=ns_clnt]  , ta_middle,255, mic((net_nstat<>ns_srvr)and((net_nstat=ns_clnt)or(G_Started=false)),false));
                    _draw_text(_menu_surf,534, 414, net_cl_svstr+chat_type[_m_sel<>ms_mltcla], ta_left  ,255, mic((net_nstat=ns_none),_m_sel=ms_mltcla));
                    _draw_text(_menu_surf,436, 438, str_npnu+str_npnua[net_pnui], ta_left  ,255, mic((net_nstat<>ns_srvr),false));

                    _draw_text(_menu_surf,438, 462, str_team+b2s(PlayerTeam)        , ta_left  ,255, mic((net_nstat<>ns_srvr)and(G_Started=false),false));
                    _draw_text(_menu_surf,514, 462, str_srace+str_race[PlayerRace]  , ta_left  ,255, mic((net_nstat<>ns_srvr)and(G_Started=false),false));
                    _draw_text(_menu_surf,627, 462, str_ready+b2pm[PlayerReady]     , ta_left  ,255, mic((net_nstat<>ns_srvr)and(G_Started=false),false));

                    //_draw_text(_menu_surf,434, 486, str_aspectator                  , ta_left  ,255, mic(_spectator=false,false));
                    //_draw_text(_menu_surf,542, 486, b2pm[_allowspect]               , ta_left  ,255, c_white);
                    //
                    //_draw_text(_menu_surf,565, 486, str_spectator                   , ta_left  ,255, mic((G_Started=false)and(net_nstat<>ns_srvr),false));
                    //_draw_text(_menu_surf,689, 486, b2pm[_spectator]                , ta_left  ,255, c_white);
                 end;
              end;
   end;
end;


procedure D_Menu;
begin
   if(vid_mredraw)then
   begin
      _draw_surf(_menu_surf,0,0,spr_mback);
      _draw_text(_menu_surf,vid_minw      ,vid_minh-font_w, str_ver  ,ta_right ,255, c_white);
      _draw_text(_menu_surf,vid_menu_cprtx,vid_minh-font_w, str_cprt ,ta_middle,255, c_white);

      _draw_text(_menu_surf, 70,554, str_exit [G_Started], ta_middle,255, c_white);
      _draw_text(_menu_surf,730,554, str_reset[G_Started], ta_middle,255, mic((net_nstat<>ns_clnt)and (G_Started or _plsReady),false));

      D_MMap;
      D_MPlayers;
      D_M1;
      D_M2;

      vid_mredraw:=false;
   end;

   SDL_FillRect(_screen,nil,0);
   _draw_surf(_screen,mv_x,mv_y,_menu_surf);
   _draw_surf(_screen,m_vx,m_vy,spr_cursor);
end;


