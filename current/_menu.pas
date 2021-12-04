
procedure ToggleMenu;
begin
   if(G_Started)then
   begin
      _menu:=not _menu;
      vid_menu_redraw:=_menu;
      menu_item:=0;
      if(net_status=ns_none)and(G_Paused<200)then
       if(_menu)
       then G_Paused:=1
       else G_Paused:=0;
   end;
end;

function menu_sf(s:shortstring;charset:TSoc;ms:byte):shortstring;
var i:byte;
    c:char;
begin
   if(length(k_keyboard_string)>0)then
   for i:=1 to length(k_keyboard_string) do
   begin
      c:=k_keyboard_string[i];
      if(c=#8)
      then delete(s,length(s),1)
      else
       if(length(s)>=ms)
       then break
       else
         if(c in charset)then s:=s+c;
   end;
   k_keyboard_string:='';
   menu_sf:=s;
end;

procedure c_m_sel;
begin
   menu_item:=0;

   if(544<mouse_y)and(mouse_y<571)then
   begin
      if(32 <mouse_x)and(mouse_x<107)then menu_item:=1;     // exit
      if(net_status<>ns_clnt)then
       if(692<mouse_x)and(mouse_x<767)then menu_item:=2;    // start
   end;

   if(ui_menu_ssr_x0<mouse_x)and(mouse_x<ui_menu_ssr_x1)and(ui_menu_ssr_y0<mouse_y)and(mouse_y<ui_menu_ssr_y1)then
   begin
      // SETTINGS
      // 3 4 5
      // 6 ...14
      // 15...23
      // 24...32
      // 33...35
      menu_item:=(mouse_y-ui_menu_ssr_y0) div ui_menu_ssr_ys;
      if(menu_item=0)then
      begin
         menu_item:=3+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs);

         case menu_item of
         4: if not ((net_status=ns_none)and(_rpls_rst<rpl_rhead))then menu_item:=0;
         5: if (net_status<>ns_none)then menu_item:=0;
         end;
      end
      else
      begin
         if(menu_s1=ms1_sett)then
         begin
            if(menu_item=1)
            then menu_item:=33+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs)
            else
            begin
               if(menu_s3=ms3_game)then menu_item:=4 +menu_item;
               if(menu_s3=ms3_vido)then menu_item:=13+menu_item;
               if(menu_s3=ms3_sond)then menu_item:=22+menu_item;
            end;
         end;
         if(menu_s1=ms1_svld)then  // 36..40
         begin
            if(menu_item in [1..8])and(mouse_x<ui_menu_ssl_x0)then menu_item:=36
            else
              if(menu_item=9)and(mouse_x<ui_menu_ssl_x0)
              then menu_item:=37
              else
                if(menu_item=10)
                then menu_item:=38+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs)
                else menu_item:=0;
         end;
         if(menu_s1=ms1_reps)then  // 41..44
         begin
            if(menu_item in [1..9])and(mouse_x<ui_menu_ssl_x0)then menu_item:=41
            else
              if(menu_item=10)
              then menu_item:=42+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs)
              else menu_item:=0;
         end;
      end;
   end;

   if(G_Started=false)then
   begin
      if(net_status<>ns_clnt)then
      begin
         // MAP
         if(menu_s2<>ms2_camp)then
          if (ui_menu_map_rx0<mouse_x)and(mouse_x<ui_menu_map_rx1)and(ui_menu_map_y0 <mouse_y)and(mouse_y<ui_menu_map_y1)then
           menu_item:=50+((mouse_y-ui_menu_map_y0) div ui_menu_map_ys);
      end;

      // PLAYERS
      if(menu_s2<>ms2_camp)then
      if(ui_menu_pls_zy0<mouse_y)and(mouse_y<ui_menu_pls_zy1)then
      begin
         if(ui_menu_pls_zxn<mouse_x)and(mouse_x<ui_menu_pls_zxs)then menu_item:=60;
         if(ui_menu_pls_zxs<mouse_x)and(mouse_x<ui_menu_pls_zxr)then menu_item:=61;
         if(ui_menu_pls_zxr<mouse_x)and(mouse_x<ui_menu_pls_zxt)then menu_item:=62;
         if(ui_menu_pls_zxt<mouse_x)and(mouse_x<ui_menu_pls_zxc)then menu_item:=63;
      end;
   end;

   if(ui_menu_csm_x0<mouse_x)and(mouse_x<ui_menu_csm_x1)and(ui_menu_csm_y0<mouse_y)and(mouse_y<ui_menu_csm_y1)then
   begin
      menu_item:=(mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys;
      if(menu_item=0)
      then menu_item:=70+((mouse_x-ui_menu_csm_x0) div ui_menu_csm_xs)
      else
      begin
         if(menu_s2=ms2_scir)then
         begin
            menu_item:=72+menu_item;  // 73..84
            if(menu_item=83)and(mouse_x>ui_menu_csm_xc)then menu_item:=0;
         end;
         if(menu_s2=ms2_mult)then
         begin
            menu_item:=84+menu_item;  // 85..96
            if(m_chat)and(menu_item<>96) then
            begin
               menu_item:=100;
            end;
         end;
         if(menu_s2=ms2_camp)then
          if(menu_item=1)
          then menu_item:=97
          else menu_item:=98;
      end;
   end;
end;


procedure g_menu;
var p:byte;
begin
   mouse_x-=mv_x;
   mouse_y-=mv_y;

   if(k_ml=2)or(k_mr=2) then   //right or left click
   begin
      if(menu_item=90)then net_cl_saddr;
      if(menu_item=11 )then _players[HPlayer].name:=PlayerName;
      c_m_sel;
      if not(menu_item in [16,17])then begin m_vrx:=vid_vw;m_vry:=vid_vh; end;
      vid_menu_redraw:=true;
      SoundPlayUI(snd_click);
   end;

   if(k_ml=2)then              // left button pressed
   begin
      case menu_item of
      1  : if(G_Started)
           then ToggleMenu
           else _CYCLE:=false;
      2  : GameMakeDestroy;    // start/break game

      /// SETTINGS SAVE REPLAYS

      3  : menu_s1:=ms1_sett;
      4  : begin menu_s1:=ms1_svld; _svld_make_lst; end;
      5  : begin menu_s1:=ms1_reps; if(G_Started=false)then _rpls_make_lst; end;

      // game settings
      6  : ;
      7  : begin vid_uhbars+=1;vid_uhbars:=vid_uhbars mod 3; end;
      8  : m_a_inv:=not m_a_inv;
      9  : if(ui_menu_ssr_x2>=mouse_x)
           then vid_vmspd:=0
           else
             if(mouse_x<ui_menu_ssr_x3)
             then vid_vmspd:=mouse_x-ui_menu_ssr_x2
             else vid_vmspd:=127;
      10 : vid_vmm:=not vid_vmm;
      11 : if not ((net_status=ns_none)and(G_Started=false))then menu_item:=0;
      12 : begin _lng:=not _lng;swLNG;end;
      13 : begin
              vid_ppos+=1;
              vid_ppos:=vid_ppos mod 4;
              _ScreenSurfaces;
              theme_map_ptrt:=255;
              MakeTerrain;
           end;
      14 : begin
              vid_plcolors+=1;
              vid_plcolors:=vid_plcolors mod 5;
           end;

      // video
      16 : if(mouse_x>ui_menu_ssr_x5)then
           begin
              if(mouse_x<ui_menu_ssr_x6)then
              begin
                 case m_vrx of
                 vid_minw : m_vrx:=960;
                 960      : m_vrx:=1024;
                 1024     : m_vrx:=1280;
                 1280     : m_vrx:=vid_maxw;
                 else       m_vrx:=vid_minw;
                 end;
              end
              else
              begin
                 case m_vry of
                 vid_minh : m_vry:=680;
                 680      : m_vry:=720;
                 720      : m_vry:=vid_maxh;
                 else       m_vry:=vid_minh;
                 end;
              end;
           end
           else
            if(mouse_x>ui_menu_ssr_x4)then
             if(m_vrx<>vid_vw)or(m_vry<>vid_vh)then
             begin
                vid_vw:=m_vrx;
                vid_vh:=m_vry;

                _MakeScreen;
                _ScreenSurfaces;
                theme_map_ptrt:=255;
                MakeTerrain;
             end;
      18 : begin cfg_fullscreen:=not cfg_fullscreen; _MakeScreen;end;

      // sounds
      26 : begin
              if(ui_menu_ssr_x2>=mouse_x)
              then snd_svolume1:=0
              else
                if(mouse_x<ui_menu_ssr_x3)
                then snd_svolume1:=(mouse_x-ui_menu_ssr_x2)/ui_menu_ssr_barl
                else snd_svolume1:=1;
              SoundSourceUpdateGainAll;
           end;
      27 : begin
              if(ui_menu_ssr_x2>=mouse_x)
              then snd_mvolume1:=0
              else
                if(mouse_x<ui_menu_ssr_x3)
                then snd_mvolume1:=(mouse_x-ui_menu_ssr_x2)/ui_menu_ssr_barl
                else snd_mvolume1:=1;
              SoundSourceUpdateGainAll;
           end;

      33 : menu_s3:=ms3_game;
      34 : menu_s3:=ms3_vido;
      35 : menu_s3:=ms3_sond;

      // save load
      36 : if(_svld_ln>0)then
           begin
               _svld_ls:=_svld_sm+((mouse_y-ui_menu_ssr_y0-ui_menu_ssr_ys)div ui_menu_ssr_ys);
              _svld_sel;
           end;
      37 : if(G_Started=false)then menu_item:=0;
      38 : if(G_Started)and(_svld_str<>'')then _svld_save;
      39 : if(0<=_svld_ls)and(_svld_ls<_svld_ln)then _svld_load;
      40 : if(0<=_svld_ls)and(_svld_ls<_svld_ln)then _svld_delete;

      // replays
      41 : if(_rpls_ln>0)and(_rpls_rst<rpl_rhead)then
           begin
              _rpls_ls :=_rpls_sm+((mouse_y-ui_menu_ssr_y0)div ui_menu_ssr_ys)-1;
              _rpls_sel;
           end;
      42 : if(0<=_rpls_ls)and(_rpls_ls<_rpls_ln)and(G_Started=false)then
           begin
              menu_s2:=ms2_scir;
              _rpls_rst:=rpl_rhead;
              g_started:=true;
           end;
      43 : ;
      44 : if(_rpls_ln>0)and(_rpls_ls<_rpls_ln)and(G_Started=false)then _rpls_delete;

      ///  MAP
      50 : ;
      51 : begin ScrollInt(@map_mw,StepSMap,MinSMapW,MaxSMapW); Map_premap;end;
      52 : begin ScrollInt(@map_liq,1,0,7); Map_premap;end;
      53 : begin ScrollInt(@map_obs,1,0,7); Map_premap;end;
      54 : begin map_sym:=not map_sym; Map_premap;end;
      56 : begin Map_randommap; Map_premap;end;


      // players
      60 : if(net_status<>ns_clnt)then PlayerSwitchAILevel( ((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys) +1);
      61 : if(net_status<>ns_clnt)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(p<>HPlayer)then
               with _players[p] do
                if (state<>ps_none)
                then PlayerSetState(p,PS_None)
                else PlayerSetState(p,PS_Comp);
           end;
      62 : if(net_status<>ns_clnt)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with _players[p] do
               if(state=ps_comp)or(p=HPlayer)then
               begin
                  race+=1;
                  race:=race mod 3;
                  mrace:=race;
               end;
           end;
      63 : if(net_status<>ns_clnt)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with _players[p] do
               if(state=ps_comp)or(p=HPlayer)then
                if(team<MaxPlayers)then team+=1;
           end;

      // CAMP SCIRMISH MULTIPLAY
      //70 : if not(G_Started)then menu_s2:=ms2_camp;
      71 : if not(G_Started and(menu_s2=ms2_camp))then begin p:=menu_s2;menu_s2:=ms2_scir;if(p=ms2_camp)then Map_premap;end;
      72 : if not(G_Started and(menu_s2=ms2_camp))then begin menu_s2:=ms2_mult; if(m_chat)then menu_item:=100; end;

      // game options
      75 : if(net_status<>ns_clnt)and(not G_Started)then begin g_addon:=not g_addon; end;
      76 : if(net_status<>ns_clnt)and(not G_Started)then begin ScrollByte(@g_mode,true,@gamemodes);Map_premap;end;
      77 : if(net_status<>ns_clnt)and(not G_Started)then ScrollInt(@g_start_base,1,0,gms_g_startb);
      78 : if(net_status<>ns_clnt)and(not G_Started)then begin g_show_positions:=not g_show_positions; end;
      79 : if(net_status<>ns_clnt)and(not G_Started)then ScrollInt(@g_ai_slots,1,0,gms_g_maxai);
      80 : if(net_status<>ns_clnt)and(not G_Started)then MakeRandomSkirmish(false);

      // replays
      82 : if(mouse_x>ui_menu_csm_x3)then
            if(_rpls_rst=rpl_none)
            then _rpls_rst:=rpl_whead
            else _rpls_rst:=rpl_none;
      83 : if(_rpls_rst<>rpl_none)then menu_item:=0;
      84 : ScrollInt(@rpls_pnui,1,0,9);

      //// multiplayer
      // server
      86 : if(net_status<>ns_clnt)and(not G_Started)and(mouse_x>ui_menu_csm_xc)then
           begin
              if(net_status=ns_srvr)then
              begin
                 net_dispose;
                 GameDefaultAll;
                 g_started:=false;
                 net_status:=ns_none;
              end
              else
              begin
                 net_status:=ns_srvr;
                 net_sv_sport;
                 if(net_UpSocket=false)then
                 begin
                    net_dispose;
                    net_status:=ns_none;
                 end
                 else PlayersSetDefault;
              end;
              menu_s1:=ms1_sett;
           end;
      87 : if(net_status<>ns_none)then menu_item:=0; // port

      // client
      89 : if(net_status<>ns_srvr)and(mouse_x>ui_menu_csm_xc)then
           if(net_status=ns_clnt)or(G_Started=false)then
           begin
              if(net_status=ns_clnt)then
              begin
                 net_disconnect;
                 net_dispose;
                 GameDefaultAll;
                 G_started  :=false;
                 PlayerReady:=false;
                 net_status  :=ns_none;
              end
              else
              begin
                 net_status:=ns_clnt;
                 net_cl_saddr;
                 _rpls_pnu:=0;
                 if(net_UpSocket)
                 then net_m_error:=str_connecting
                 else
                 begin
                    net_dispose;
                    net_status:=ns_none;
                 end;
              end;
              menu_s1:=ms1_sett;
           end;
      90 : if(net_status<>ns_none)then menu_item:=0; // addr
      91 : if(net_status<>ns_srvr)then ScrollInt(@net_pnui,1,0,9);
      92 : if(G_Started=false)and(net_status<>ns_srvr)then
            if(mouse_x<ui_menu_csm_x2)
            then ScrollInt(@PlayerTeam,1,1,MaxPlayers)
            else
              if(mouse_x<ui_menu_csm_x3)
              then begin PlayerRace+=1; PlayerRace:=PlayerRace mod 3;end
              else PlayerReady:=not PlayerReady;
      95 : begin
              p:=((mouse_x-ui_menu_csm_x0) div ui_menu_csm_2ys)+1;
              if(p<>HPlayer)and(p<=MaxPlayers)then
              begin
                 p:=1 shl p;
                 if((net_chat_tar and p)>0)
                 then net_chat_tar:=net_chat_tar xor p
                 else net_chat_tar:=net_chat_tar or  p;
              end;
           end;
      96 : if(net_status<>ns_none)then
           begin
              m_chat:=not m_chat;
              if(m_chat)then menu_item:=100;
           end;

      // camps
      97 : ScrollInt(@cmp_skill,1,0,6);
      98 : begin
              _cmp_sel:=_cmp_sm+((mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(_cmp_sel>=MaxMissions)then _cmp_sel:=MaxMissions-1;
           end;
      else

      end;

   end;

   if(k_mr=2)then    // right button pressed
   begin
      case menu_item of
      // MAP
      50 : begin Map_randomseed;                                  Map_premap;end;
      51 : begin ScrollInt(@map_mw,-StepSMap,MinSMapW,MaxSMapW); Map_premap;end;
      52 : begin ScrollInt(@map_liq,-1,0,7);                     Map_premap;end;
      53 : begin ScrollInt(@map_obs,-1,0,7);                     Map_premap;end;
      56 : begin Map_randommap;                                   Map_premap;end;

      60 : begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(net_status=ns_clnt)
              then net_swapp(p)
              else PlayersSwap(p,HPlayer);
           end;
      63 : if(net_status<>ns_clnt)and(not G_Started)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with _players[p] do
               if(state=ps_comp)or(p=HPlayer)then
                if(team>1)then team-=1;
           end;

      77 : if(net_status<>ns_clnt)and(not G_Started)then ScrollInt(@g_start_base ,-1,0,gms_g_startb);
      79 : if(net_status<>ns_clnt)and(not G_Started)then ScrollInt(@g_ai_slots,-1,0,gms_g_maxai );
      80 : if(net_status<>ns_clnt)and(not G_Started)then MakeRandomSkirmish(true);

      84 : ScrollInt(@rpls_pnui,-1,0,9);

      91 : if(net_status<>ns_srvr)then ScrollInt(@net_pnui,-1,0,9);
      92 : if(G_Started=false)and(net_status<>ns_srvr)then
            if(mouse_x<ui_menu_csm_x2)then ScrollInt(@PlayerTeam,-1,1,MaxPlayers);

      97 : ScrollInt(@cmp_skill,-1,0,CMPMaxSkills);
      end;
   end;

   if(length(k_keyboard_string)>0)then
   begin
      case menu_item of
      11 : PlayerName:=menu_sf(PlayerName,k_kbstr,NameLen);
      37 : _svld_str :=menu_sf(_svld_str ,k_kbstr,SvRpLen);
      50 : begin
              map_seed:=s2c(menu_sf(c2s(map_seed),k_kbdig,10));
              map_premap;
           end;
      83 : _rpls_lrname:=menu_sf(_rpls_lrname,k_kbstr,SvRpLen);
      87 : begin
              net_sv_pstr:=menu_sf(net_sv_pstr,k_kbdig,5);
              net_sv_sport;
           end;
      90 : net_cl_svstr:=menu_sf(net_cl_svstr,k_kbaddr,21);
      100: net_chat_str:=menu_sf(net_chat_str,k_kbstr ,255);
      end;

      vid_menu_redraw:=true;
   end;


   mouse_x+=mv_x;
   mouse_y+=mv_y;
end;

