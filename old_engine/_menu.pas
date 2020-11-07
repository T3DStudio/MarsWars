
procedure ToggleMenu;
begin
   if(G_Started)then
   begin
      _menu:=not _menu;
      vid_mredraw:=_menu;
      _m_sel:=0;
      if(net_nstat=ns_none)and(G_Paused<200)then
       if(_menu)
       then G_Paused:=1
       else G_Paused:=0;
   end;
end;

function menu_sf(s:string;charset:TSoc;ms:byte):string;
var sl:byte;
     c:char;
begin
   if (k_chrt=2)or(k_chrt>k_chrtt) then
   begin
      sl:=length(s);
      c:=k_chr;
      if not(c in charset) then c:=#0;
      if(k_chr=#8)
      then delete(s,sl,1)
      else
        if(sl<ms)and(c<>#0)then s:=s+c;
   end;
   menu_sf:=s;
end;

procedure c_m_sel;
begin
   _m_sel:=0;

   if(544<m_vy)and(m_vy<571)then
   begin
      if(32 <m_vx)and(m_vx<107)then _m_sel:=1;     // exit
      if(net_nstat<>ns_clnt)then
       if(692<m_vx)and(m_vx<767)then _m_sel:=2;    // start
   end;

   if(ui_menu_ssr_x0<m_vx)and(m_vx<ui_menu_ssr_x1)and(ui_menu_ssr_y0<m_vy)and(m_vy<ui_menu_ssr_y1)then
   begin
      // SETTINGS
      // 3 4 5
      // 6 ...14
      // 15...23
      // 24...32
      // 33...35
      _m_sel:=(m_vy-ui_menu_ssr_y0) div ui_menu_ssr_ys;
      if(_m_sel=0)then
      begin
         _m_sel:=3+((m_vx-ui_menu_ssr_x0) div ui_menu_ssr_xs);

         case _m_sel of
         4: if not ((net_nstat=ns_none)and(_rpls_rst<rpl_rhead))then _m_sel:=0;
         5: if (net_nstat<>ns_none)then _m_sel:=0;
         end;
      end
      else
      begin
         if(menu_s1=ms1_sett)then
         begin
            if(_m_sel=1)
            then _m_sel:=33+((m_vx-ui_menu_ssr_x0) div ui_menu_ssr_xs)
            else
            begin
               if(menu_s3=ms3_game)then _m_sel:=4 +_m_sel;
               if(menu_s3=ms3_vido)then _m_sel:=13+_m_sel;
               if(menu_s3=ms3_sond)then _m_sel:=22+_m_sel;
            end;
         end;
         if(menu_s1=ms1_svld)then  // 36..40
         begin
            if(_m_sel in [1..8])and(m_vx<ui_menu_ssl_x0)then _m_sel:=36
            else
              if(_m_sel=9)and(m_vx<ui_menu_ssl_x0)
              then _m_sel:=37
              else
                if(_m_sel=10)
                then _m_sel:=38+((m_vx-ui_menu_ssr_x0) div ui_menu_ssr_xs)
                else _m_sel:=0;
         end;
         if(menu_s1=ms1_reps)then  // 41..44
         begin
            if(_m_sel in [1..9])and(m_vx<ui_menu_ssl_x0)then _m_sel:=41
            else
              if(_m_sel=10)
              then _m_sel:=42+((m_vx-ui_menu_ssr_x0) div ui_menu_ssr_xs)
              else _m_sel:=0;
         end;
      end;
   end;

   if(G_Started=false)then
   begin
      if(net_nstat<>ns_clnt)then
      begin
         // MAP
         if(menu_s2<>ms2_camp)then
          if (ui_menu_map_rx0<m_vx)and(m_vx<ui_menu_map_rx1)and(ui_menu_map_y0 <m_vy)and(m_vy<ui_menu_map_y1)then
           _m_sel:=50+((m_vy-ui_menu_map_y0) div ui_menu_map_ys);
      end;

      // PLAYERS
      if(menu_s2<>ms2_camp)then
      if(ui_menu_pls_zy0<m_vy)and(m_vy<ui_menu_pls_zy1)then
      begin
         if(ui_menu_pls_zxn<m_vx)and(m_vx<ui_menu_pls_zxs)then _m_sel:=60;
         if(ui_menu_pls_zxs<m_vx)and(m_vx<ui_menu_pls_zxr)then _m_sel:=61;
         if(ui_menu_pls_zxr<m_vx)and(m_vx<ui_menu_pls_zxt)then _m_sel:=62;
         if(ui_menu_pls_zxt<m_vx)and(m_vx<ui_menu_pls_zxc)then _m_sel:=63;
      end;
   end;

   if(ui_menu_csm_x0<m_vx)and(m_vx<ui_menu_csm_x1)and(ui_menu_csm_y0<m_vy)and(m_vy<ui_menu_csm_y1)then
   begin
      _m_sel:=(m_vy-ui_menu_csm_y0) div ui_menu_csm_ys;
      if(_m_sel=0)
      then _m_sel:=70+((m_vx-ui_menu_csm_x0) div ui_menu_csm_xs)
      else
      begin
         if(menu_s2=ms2_scir)then
         begin
            _m_sel:=72+_m_sel;  // 73..84
            if(_m_sel=83)and(m_vx>ui_menu_csm_xc)then _m_sel:=0;
         end;
         if(menu_s2=ms2_mult)then
         begin
            _m_sel:=84+_m_sel;  // 85..96
            if(m_chat)and(_m_sel<>96) then
            begin
               _m_sel:=100;
            end;
         end;
         if(menu_s2=ms2_camp)then
          if(_m_sel=1)
          then _m_sel:=97
          else _m_sel:=98;
      end;
   end;
end;


procedure g_menu;
var p:byte;
begin
   dec(m_vx,mv_x);
   dec(m_vy,mv_y);

   if(k_ml=2)or(k_mr=2) then   //right or left click
   begin
      if(_m_sel=90)then net_cl_saddr;
      if(_m_sel=11 )then _players[HPlayer].name:=PlayerName;
      c_m_sel;
      if not(_m_sel in [16,17])then begin m_vrx:=vid_mw;m_vry:=vid_mh; end;
      vid_mredraw:=true;
      PlaySNDM(snd_click);
   end;

   if(k_ml=2)then              // left button pressed
   begin
      case _m_sel of
      1  : if(G_Started)
           then ToggleMenu
           else _CYCLE:=false;
      2  : _StartGame;    // start/break game

      /// SETTINGS SAVE REPLAYS

      3  : menu_s1:=ms1_sett;
      4  : begin menu_s1:=ms1_svld; _svld_make_lst; end;
      5  : begin menu_s1:=ms1_reps; if(G_Started=false)then _rpls_make_lst; end;

      // game settings
      6  : ;
      7  : ;
      8  : m_a_inv:=not m_a_inv;
      9  : if(ui_menu_ssr_x2>=m_vx)
           then vid_vmspd:=0
           else
             if(m_vx<ui_menu_ssr_x3)
             then vid_vmspd:=m_vx-ui_menu_ssr_x2
             else vid_vmspd:=127;
      10 : vid_vmm:=not vid_vmm;
      11 : if not ((net_nstat=ns_none)and(G_Started=false))then _m_sel:=0;
      12 : begin _lng:=not _lng;swLNG;end;

      // video
      16 : if(m_vx>ui_menu_ssr_x5)then
           begin
              if(m_vx<ui_menu_ssr_x6)then
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
                 vid_minh : m_vry:=720;
                 720      : m_vry:=vid_maxh;
                 else       m_vry:=vid_minh;
                 end;
              end;
           end
           else
            if(m_vx>ui_menu_ssr_x4)then
             if(m_vrx<>vid_mw)or(m_vry<>vid_mh)then
             begin
                vid_mw:=m_vrx;
                vid_mh:=m_vry;

                calcVRV;
                _MakeScreen;
                _makeScrSurf;
                map_ptrt:=255;
                MakeTerrain;
             end;
      18 : begin _fscr:=not _fscr; _MakeScreen;end;

      // sounds
      26 : if(ui_menu_ssr_x2>=m_vx)
           then snd_svolume:=0
           else
             if(m_vx<ui_menu_ssr_x3)
             then snd_svolume:=m_vx-ui_menu_ssr_x2
             else snd_svolume:=127;
      27 : begin
              if(ui_menu_ssr_x2>=m_vx)
              then snd_mvolume:=0
              else
                if(m_vx<ui_menu_ssr_x3)
                then snd_mvolume:=m_vx-ui_menu_ssr_x2
                else snd_mvolume:=127;
              MIX_VOLUMEMUSIC(snd_mvolume);
           end;

      33 : menu_s3:=ms3_game;
      34 : menu_s3:=ms3_vido;
      35 : menu_s3:=ms3_sond;

      // save load
      36 : if(_svld_ln>0)then
           begin
               _svld_ls:=_svld_sm+((m_vy-ui_menu_ssr_y0-ui_menu_ssr_ys)div ui_menu_ssr_ys);
              _svld_sel;
           end;
      37 : if(G_Started=false)then _m_sel:=0;
      38 : if(G_Started)and(_svld_str<>'')then _svld_save;
      39 : if(0<=_svld_ls)and(_svld_ls<_svld_ln)then _svld_load;
      40 : if(0<=_svld_ls)and(_svld_ls<_svld_ln)then _svld_delete;

      // replays
      41 : if(_rpls_ln>0)and(_rpls_rst<rpl_rhead)then
           begin
              _rpls_ls :=_rpls_sm+((m_vy-ui_menu_ssr_y0)div ui_menu_ssr_ys)-1;
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
      51 : begin _scrollV(@map_mw,500,MinSMapW,MaxSMapW); Map_premap;end;
      52 : begin _scrollV(@map_liq,1,0,7); Map_premap;end;
      53 : begin _scrollV(@map_obs,1,0,7); Map_premap;end;
      56 : begin Map_randommap; Map_premap;end;


      // players
      60 : if(net_nstat<>ns_clnt)then _swAI( ((m_vy-ui_menu_pls_zy0) div ui_menu_pls_ys) +1);
      61 : if(net_nstat<>ns_clnt)then
           begin
              p:=((m_vy-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(p<>HPlayer)then
               with _players[p] do
               begin
                  if (state<>ps_none)
                  then state:=PS_None
                  else state:=PS_Comp;

                  _playerSetState(p);
               end;
           end;
      62 : if(net_nstat<>ns_clnt)then
           begin
              p:=((m_vy-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with _players[p] do
               if(state=ps_comp)or(p=HPlayer)then
               begin
                  inc(race,1);
                  race:=race mod 3;
                  mrace:=race;
               end;
           end;
      63 : if(net_nstat<>ns_clnt)then
           begin
              p:=((m_vy-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with _players[p] do
               if(state=ps_comp)or(p=HPlayer)then
                if(team<MaxPlayers)then inc(team,1);
           end;

      // CAMP SCIRMISH MULTIPLAY
      //70 : if not(G_Started)then menu_s2:=ms2_camp;
      71 : if not(G_Started and(menu_s2=ms2_camp))then begin p:=menu_s2;menu_s2:=ms2_scir;if(p=ms2_camp)then Map_premap;end;
      72 : if not(G_Started and(menu_s2=ms2_camp))then begin menu_s2:=ms2_mult; if(m_chat)then _m_sel:=100; end;

      // game options
      75 : if(net_nstat<>ns_clnt)and(not G_Started)then begin g_addon:=not g_addon; end;
      76 : if(net_nstat<>ns_clnt)and(not G_Started)then
           begin
              inc(g_mode,1);
              g_mode:=g_mode mod 6;
              Map_premap;
           end;
      77 : if(net_nstat<>ns_clnt)and(not G_Started)then
           begin
              inc(g_startb,1);
              g_startb:=g_startb mod 6;
           end;
      78 : if(net_nstat<>ns_clnt)and(not G_Started)then begin g_shpos:=not g_shpos; _makeMMB; end;
      79 : if(net_nstat<>ns_clnt)and(not G_Started)then _scrollV(@G_aislots,1,0,8);
      80 : if(net_nstat<>ns_clnt)and(not G_Started)then MakeRandomSkirmish(false);

      // replays
      82 : if(m_vx>ui_menu_csm_x3)then
            if(_rpls_rst=rpl_none)
            then _rpls_rst:=rpl_whead
            else _rpls_rst:=rpl_none;
      83 : if(_rpls_rst<>rpl_none)then _m_sel:=0;
      84 : _scrollV(@_rpls_pnui,1,0,9);

      //// multiplayer
      // server
      86 : if(net_nstat<>ns_clnt)and(not G_Started)and(m_vx>ui_menu_csm_xc)then
           begin
              if(net_nstat=ns_srvr)then
              begin
                 net_dispose;
                 DefGameObjects;
                 g_started:=false;
                 net_nstat:=ns_none;
              end
              else
              begin
                 net_nstat:=ns_srvr;
                 net_sv_sport;
                 if(net_UpSocket=false)then
                 begin
                    net_dispose;
                    net_nstat:=ns_none;
                 end
                 else DefPlayers;
              end;
              menu_s1:=ms1_sett;
           end;
      87 : if(net_nstat<>ns_none)then _m_sel:=0; // port

      // client
      89 : if(net_nstat<>ns_srvr)and(m_vx>ui_menu_csm_xc)then
           if(net_nstat=ns_clnt)or(G_Started=false)then
           begin
              if(net_nstat=ns_clnt)then
              begin
                 net_plout;
                 net_dispose;
                 DefGameObjects;
                 G_started  :=false;
                 PlayerReady:=false;
                 net_nstat  :=ns_none;
              end
              else
              begin
                 net_nstat:=ns_clnt;
                 net_cl_saddr;
                 if(net_UpSocket)
                 then net_m_error:=str_connecting
                 else
                 begin
                    net_dispose;
                    net_nstat:=ns_none;
                 end;
              end;
              menu_s1:=ms1_sett;
           end;
      90 : if(net_nstat<>ns_none)then _m_sel:=0; // addr
      91 : if(net_nstat<>ns_srvr)then _scrollV(@net_pnui,1,0,9);
      92 : if(G_Started=false)and(net_nstat<>ns_srvr)then
            if(m_vx<ui_menu_csm_x2)
            then _scrollV(@PlayerTeam,1,1,MaxPlayers)
            else
              if(m_vx<ui_menu_csm_x3)
              then begin inc(PlayerRace,1); PlayerRace:=PlayerRace mod 3;end
              else PlayerReady:=not PlayerReady;
      95 : begin
              p:=((m_vx-ui_menu_csm_x0) div ui_menu_csm_2ys)+1;
              if(p<>HPlayer)and(p<=MaxPlayers)then
              begin
                 p:=1 shl p;
                 if((net_chat_tar and p)>0)
                 then net_chat_tar:=net_chat_tar xor p
                 else net_chat_tar:=net_chat_tar or  p;
              end;
           end;
      96 : if(net_nstat<>ns_none)then
           begin
              m_chat:=not m_chat;
              if(m_chat)then _m_sel:=100;
           end;

      // camps
      97 : _scrollV(@cmp_skill,1,0,6);
      98 : begin
              _cmp_sel:=_cmp_sm+((m_vy-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(_cmp_sel>=MaxMissions)then _cmp_sel:=MaxMissions-1;
           end;

      else

      end;

   end;

   if(k_mr=2)then    // right button pressed
   begin
      case _m_sel of
      // MAP
      50 : begin Map_randomseed; Map_premap;end;
      51 : begin _scrollV(@map_mw,-500,MinSMapW,MaxSMapW); Map_premap;end;
      52 : begin _scrollV(@map_liq,-1,0,7); Map_premap;end;
      53 : begin _scrollV(@map_obs,-1,0,7); Map_premap;end;
      56 : begin Map_randommap; Map_premap;end;

      60 : begin
              p:=((m_vy-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(net_nstat=ns_clnt)
              then net_swapp(p)
              else _swapPlayers(p,HPlayer);
           end;
      63 : if(net_nstat<>ns_clnt)and(not G_Started)then
           begin
              p:=((m_vy-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with _players[p] do
               if(state=ps_comp)or(p=HPlayer)then
                if(team>1)then dec(team,1);
           end;

      79 : if(net_nstat<>ns_clnt)and(not G_Started)then _scrollV(@G_aislots,-1,0,8);
      80 : if(net_nstat<>ns_clnt)and(not G_Started)then MakeRandomSkirmish(true);

      84 : _scrollV(@_rpls_pnui,-1,0,9);

      91 : if(net_nstat<>ns_srvr)then _scrollV(@net_pnui,-1,0,9);
      92 : if(G_Started=false)and(net_nstat<>ns_srvr)then
            if(m_vx<ui_menu_csm_x2)then _scrollV(@PlayerTeam,-1,1,MaxPlayers);

      97 : _scrollV(@cmp_skill,-1,0,CMPMaxSkills);
      end;
   end;

   if((k_chrt=2)or(k_chrt>k_chrtt)) then
   begin
      if(_m_sel=11 )then PlayerName:=menu_sf(PlayerName,k_kbstr,NameLen);

      if(_m_sel=37 )then _svld_str   :=menu_sf(_svld_str   ,k_kbstr,SvRpLen);

      if(_m_sel=50)then
      begin
         map_seed:=s2c(menu_sf(c2s(map_seed),k_kbdig,10));
         map_premap;
      end;

      if(_m_sel=83 )then _rpls_lrname:=menu_sf(_rpls_lrname,k_kbstr,SvRpLen);
      if(_m_sel=87 )then
      begin
         net_sv_pstr:=menu_sf(net_sv_pstr,k_kbdig,5);
         net_sv_sport;
      end;
      if(_m_sel=90 )then net_cl_svstr:=menu_sf(net_cl_svstr,k_kbaddr,21);
      if(_m_sel=100)then net_chat_str:=menu_sf(net_chat_str,k_kbstr,ChatLen);

      vid_mredraw:=true;
   end;


   inc(m_vx,mv_x);
   inc(m_vy,mv_y);
end;

