procedure ToggleMenu;
begin
   if(G_Started)then
   begin
      _menu:=not _menu;
      vid_mredraw:=_menu;
      ui_panelmmm:=false;
      _m_sel:=0;
      if(net_nstat=ns_none)then
       if(_menu)
       then G_Status:=255
       else G_Status:=0;
   end;
end;

function menu_sf(s:string;charset:TSoc;ms:byte):string;
var sl:byte;
begin
   if (k_chrt=2)or(k_chrt>vid_h3fps) then
   begin
      sl:=length(s);
      case k_chr of
      #8 : if(sl>0)then
           begin
              delete(s,sl,1);
              if(_menu)then vid_mredraw:=true;
           end;
      else
        if(k_chr in charset)and(sl<ms)then
        begin
           s:=s+k_chr;
           if(_menu)then vid_mredraw:=true;
        end;
      end;
   end;
   menu_sf:=s;
end;

procedure c_m_sel;
begin
   _m_sel:=0;

   if(544<m_vy)and(m_vy<571)then
   begin
      if(32 <m_vx)and(m_vx<107)then _m_sel:=ms_extbck;       // exit
      if(net_nstat<>ns_clnt)then
       if(692<m_vx)and(m_vx<767)then _m_sel:=ms_strrst;      // start
   end;

   if(312<m_vy)and(m_vy<327)then
   begin
      if(net_nstat=ns_none)then
       if(not G_Started)then
        if(418<m_vx)and(m_vx<519)then _m_sel:=ms_ms2cmp;     // camps

      if not(G_Started and(menu_s2=ms2_camp))then
      begin
         if(518<m_vx)and(m_vx<621)then _m_sel:=ms_ms2scr;    // scir
         if(620<m_vx)and(m_vx<724)then _m_sel:=ms_ms2mlt;    // multiplayer
      end;
   end;

   if(325<m_vy)and(m_vy<341)then
   begin
      if(78< m_vx)and(m_vx<177)then _m_sel:=ms_ms1set;         // settings

      if(net_nstat=ns_none)and(_rpls_rst<rpl_rhead)then
       if(180<=m_vx)and(m_vx<280)then _m_sel:=ms_ms1svl;       // save load

      if(net_nstat=ns_none)then
       if(280<m_vx)and(m_vx<380)then _m_sel:=ms_ms1rpl;        // replays
   end;

   if(G_Started=false)then
   begin
      {if(menu_s2=ms2_camp)then
       if(424<m_vx)and(m_vx<720)then
       begin
          if(286<m_vy)and(m_vy<=300)then _m_sel:=ms_cmpdif;   // defficulty
          if(300<m_vy)and(m_vy< 518)then _m_sel:=ms_cmpmis;   // missions
       end;}

      if(432<m_vx)and(m_vx<535)then
       if(129<m_vy)and(m_vy<260)then _m_sel:=ms_plname;       //name

      if(net_nstat<>ns_clnt)and(menu_s2<>ms2_camp)then
      begin
         if(129<m_vy)and(m_vy<260)then
         begin
            if(538<m_vx)and(m_vx<557)then _m_sel:=ms_plstat;  // < C P - ?
            if(576<m_vx)and(m_vx<635)then _m_sel:=ms_plrace;  // race
            if(g_mode in [gm_scir])then
             if(654<m_vx)and(m_vx<673)then _m_sel:=ms_plteam; // team
         end;

         if(248<m_vx)and(m_vx<368)then
         begin
            if(123<m_vy)and(m_vy<142)then _m_sel:=ms_mapsed; // map seed
            if(141<m_vy)and(m_vy<274)then _m_sel:=ms_mapset; // map settings
         end;
      end;
   end;

   if(menu_s1=ms1_sett)then
   begin
      if(343<m_vy)and(m_vy<358)then
      begin
         if(78<  m_vx)and(m_vx<177)then _m_sel:=ms_ms3gam;        // sound options
         if(177<=m_vx)and(m_vx<280)then _m_sel:=ms_ms3vid;        // video options
         if(280< m_vx)and(m_vx<380)then _m_sel:=ms_ms3snd;        // game options
      end;
      if(76<m_vx)and(m_vx<381)and(375<m_vy)and(m_vy<506)then _m_sel:=ms_setting;
   end;

   if(menu_s1=ms1_svld)then                                                        // save load
   begin
      if(_svld_ln>0)then
       if(76<m_vx)and(m_vx<221)and(349<m_vy)and(m_vy<487)then _m_sel:=ms_svldfl;   // file list

      if(76<m_vx)and(m_vx<381)then
      begin
         if(G_Started)then
          if(490<m_vy)and(m_vy<502)then _m_sel:=ms_svldsn;                         // fname string
         if(502<m_vy)and(m_vy<524)then
         begin
            if(m_vx<177)then
            begin
               if(G_Started)and(_svld_str<>'')then _m_sel:=ms_svldsv;
            end
            else
              if((_svld_ls>=0)and(_svld_ls<_svld_ln))then
               if(m_vx>278)
               then _m_sel:=ms_svlddl
               else
                 if(_svld_cor)
                 then _m_sel:=ms_svldld
         end;
      end;
   end;

   if(menu_s1=ms1_reps)and(G_Started=false)then
   begin                                                                         // replays
      if(_rpls_ln>0)then
       if(76<m_vx)and(m_vx<231)and(349<m_vy)and(m_vy<502)then _m_sel:=ms_rplsfl; // file list

      if(76<m_vx)and(m_vx<381)then
       if(502<m_vy)and(m_vy<524)then
       begin
          if((_rpls_ls>=0)and(_rpls_ls<_rpls_ln))then
           if(m_vx<177)then
           begin
              if(_rpls_cor)then _m_sel:=ms_rplspl
           end
           else
             if(m_vx>278)then _m_sel:=ms_rplsdl
       end;
   end;

   if(menu_s2=ms2_scir)then
   begin
      if(468<m_vy)and(m_vy<484)then                                                // replays
      begin
         if(_rpls_rst<rpl_rhead)and(503<m_vx)and(m_vx<562)then _m_sel:=ms_rplson;  // replay off/on
         if(_rpls_rst=rpl_none )and(578<m_vx)and(m_vx<713)then _m_sel:=ms_rplsfn;  // last replay name
      end;
      if(_rpls_rst<rpl_rhead)then
       if(492<m_vy)and(m_vy<508)and(432<m_vx)and(m_vx<713)then _m_sel:=ms_rplspn;  // replay pnu

      // game options
      if(418<m_vx)and(m_vx<723)and(not G_Started)then
      begin
         if(net_nstat<>ns_clnt)then
          if(359<m_vy)and(m_vy<434)then _m_sel:=ms_gameop;                       // game options
         if(net_nstat=ns_none)then
          if(434<m_vy)and(m_vy<453)then _m_sel:=ms_gamers;                       // random scir
      end;
   end;

   if(menu_s2=ms2_mult)then
   begin
      if(net_nstat<>ns_none)then
       if(418<m_vx)and(m_vx<723)and(507<m_vy)and(m_vy<523)then _m_sel:=ms_mltcht;      // open chat

      if(m_chat=false)then
      begin
         if(net_nstat<>ns_clnt)and(not G_Started)then
         begin
            if(432<m_vx)and(m_vx<557)and(360<m_vy)and(m_vy<376)then _m_sel:=ms_mltsvu; // sv up
         end;

         {if(not G_Started)and(net_nstat<>ns_srvr)then
          if(560<m_vx)and(m_vx<713)and(481<m_vy)and(m_vy<497)then _m_sel:=ms_mltisp;   // be spectator

         if(_spectator=false)then
          if(432<m_vx)and(m_vx<557)and(481<m_vy)and(m_vy<497)then _m_sel:=ms_mltasp;   // allow spectators   }

         if(net_nstat=ns_none)then
         begin
            if(572<m_vx)and(m_vx<692)and(360<m_vy)and(m_vy<376)then _m_sel:=ms_mltsvp; // udp port
            if(531<m_vx)and(m_vx<713)and(409<m_vy)and(m_vy<425)then _m_sel:=ms_mltcla; // sv addr
         end;

         if(net_nstat<>ns_srvr)then
         begin
            if(432<m_vx)and(m_vx<713)and(433<m_vy)and(m_vy<449)then _m_sel:=ms_mltpnu; // PNU

            if(net_nstat=ns_clnt)or(G_Started=false)then
             if(432<m_vx)and(m_vx<529)and(409<m_vy)and(m_vy<425)then _m_sel:=ms_mltcon;// connect

            if(not G_Started)then
             if(457<m_vy)and(m_vy<473)then
             begin
                if(432<m_vx)and(m_vx<491)then _m_sel:=ms_mlttem; // team
                if(509<m_vx)and(m_vx<606)then _m_sel:=ms_mltrac; // race
                if(620<m_vx)and(m_vx<711)then _m_sel:=ms_mltred; // ready
             end;
         end;
      end;
   end;
end;

procedure G_Menu;
var p:byte;
begin
   dec(m_vx,mv_x);
   dec(m_vy,mv_y);

   if(k_ml=2)or(k_mr=2) then   //right or left click
   begin
      if(_m_sel=ms_mltcla)then net_cl_saddr;
      if(_m_sel=ms_setpln)then _players[HPlayer].name:=PlayerName;
      c_m_sel;
      if(_m_sel<>ms_setting)then
      begin
         m_vrx:=vid_mw;
         m_vry:=vid_mh;
      end;
      vid_mredraw:=true;
      PlayGSND(snd_click);
   end;

   if(k_ml=2)then              // left button pressed
   begin
      if(_m_sel=ms_extbck) then
       if(G_Started)
       then ToggleMenu
       else _CYCLE:=false;

      if(_m_sel=ms_strrst) then _StartMatch;    // start/break game

      if(_m_sel=ms_ms2cmp)then menu_s2:=ms2_camp;
      if(_m_sel=ms_ms2scr)then menu_s2:=ms2_scir;
      if(_m_sel=ms_ms2mlt)then menu_s2:=ms2_mult;

      if(_m_sel=ms_ms1set)then menu_s1:=ms1_sett;
      if(_m_sel=ms_ms1svl)then begin menu_s1:=ms1_svld;_svld_make_lst;end;
      if(_m_sel=ms_ms1rpl)then begin menu_s1:=ms1_reps;if(G_Started=false)then _rpls_make_lst;end;

      if(_m_sel=ms_ms3snd)then menu_s3:=ms3_snd;
      if(_m_sel=ms_ms3vid)then menu_s3:=ms3_vid;
      if(_m_sel=ms_ms3gam)then menu_s3:=ms3_game;

      if(_m_sel=ms_setting)then
      begin
         p:=(m_vy-375) div 19;
         if(menu_s3=ms3_snd)then
          case p of
          0: if(m_vx<=177)
             then snd_svolume:=0
             else
               if(m_vx>=304)
               then snd_svolume:=127
               else snd_svolume:=m_vx-177;
          1: if(m_vx<=177)
             then snd_mvolume:=0
             else
               if(m_vx>=304)
               then snd_mvolume:=127
               else snd_mvolume:=m_vx-177;
          end;
         if(menu_s3=ms3_vid)then
          case p of
          0: if(m_vx>177)then
              if(m_vx<279)then
              begin
                 if(m_vrx=800)and(m_vry=600)then
                 begin
                    m_vrx:=960;
                    m_vry:=720;
                 end
                 else
                   if(m_vrx=960)and(m_vry=720)then
                   begin
                      m_vrx:=1024;
                      m_vry:=768;
                   end
                   else
                   begin
                      m_vrx:=800;
                      m_vry:=600;
                   end;
              end
              else
              begin
                 vid_mw:=m_vrx;
                 vid_mh:=m_vry;

                 _MakeScreen;
                 calcVRV;
                 map_ptrt:=255;
                 MakeTerrain;
              end;
          1: begin _fscr:=not _fscr; _MakeScreen;end;
          end;
         if(menu_s3=ms3_game)then
          case p of
          0: begin m_a_inv:=not m_a_inv; _players[HPlayer].rghtatt:=m_a_inv; end;
          1: if(m_vx>=205)then vid_vmspd:=m_vx-205;
          2: vid_vmm:=not vid_vmm;
          3: _m_sel:=ms_setpln;
          4: begin _lng:=not _lng;swLNG;end;
          end;
      end;

      if(_m_sel=ms_mapset)then
       case ((m_vy-141)div 19) of
       0 : begin _scrollV(@map_mw,500,MinSMapW,MaxSMapW); Map_premap;end;
       1 : begin _scrollV(@map_liq,1,0,4); Map_premap;end;
       2 : begin _scrollV(@map_obs,1,0,4); Map_premap;end;
       6 : begin Map_randommap; Map_premap;end;
       end;

      if(_m_sel=ms_mltsvu)then //server start/stop
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
            if(net_UpSocket=false)then
            begin
               net_dispose;
               net_nstat:=ns_none;
            end
            else DefPlayers;
         end;
         menu_s1:=ms1_sett;
      end;

      if(_m_sel=ms_mlttem)then _scrollV(@PlayerTeam,1,1,MaxPlayers);
      if(_m_sel=ms_mltrac)then begin inc(PlayerRace,1); PlayerRace:=PlayerRace mod 3;end;
      if(_m_sel=ms_mltred)then PlayerReady:=not PlayerReady;

      if(_m_sel=ms_mltcon)then
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

      if(_m_sel=ms_mltpnu)then _scrollV(@net_pnui,1,0,9);

      if(_m_sel=ms_mltcht)then m_chat:=not m_chat;

      if(_m_sel=ms_gameop)then
      begin
         p:=(m_vy-359) div 19;
         case p of
         0 : begin
                inc(g_mode,1);
                g_mode:=g_mode mod 3;
                Map_premap;
             end;
         1 : begin
                inc(G_aislots,1);
                G_aislots:=G_aislots mod 7;
             end;
         2 : if not(g_mode in [gm_tdm2,gm_tdm3])then
             begin
                g_sslots:=not g_sslots;
                Map_minimapUPD;
             end;
         end;
      end;
      if(_m_sel=ms_gamers)then MakeRandomSkirmish(false);

      if(_m_sel=ms_plname)then
      if(net_nstat<>ns_clnt)then
      begin
         p:=((m_vy-129) div 22)+1;
         if(p in [1..MaxPlayers])then _swAI(p);
      end;

      if(_m_sel=ms_plstat)then
      begin
         p:=((m_vy-129) div 22)+1;
         if(p in [1..MaxPlayers])then
          if(p<>HPlayer)then
           with _players[p] do
           begin
              if (State<>ps_none)
              then state:=PS_None
              else state:=PS_Comp;

              _playerSetState(p);
           end;
      end;
      if(_m_sel=ms_plrace)then
      begin
         p:=((m_vy-129) div 22)+1;
         if(p in [1..MaxPlayers])then
          with _players[p] do
           if(state=ps_comp)or(p=HPlayer)then
            with _players[p] do
            begin
               inc(race,1);
               race:=race mod 3;
               mrace:=race;
            end;
      end;
      if(_m_sel=ms_plteam)then
      begin
         p:=((m_vy-129) div 22)+1;
         if(p in [1..MaxPlayers])then
          with _players[p] do
           if(state=ps_comp)or(p=HPlayer)then
            if(team<MaxPlayers)then
            begin
               inc(team,1);
            end;
      end;

      if(_m_sel=ms_svldfl)then
      begin
         _svld_ls :=_svld_sm+((m_vy-351) div 14);
         _svld_sel;
      end;
      if(_m_sel=ms_svldsv)then _svld_save;
      if(_m_sel=ms_svldld)then _svld_load;
      if(_m_sel=ms_svlddl)then _svld_delete;

      if(_m_sel=ms_rplsfl)then
      begin
         _rpls_ls :=_rpls_sm+((m_vy-351)div 14);
         _rpls_sel;
      end;
      if(_m_sel=ms_rplspl)then
      begin
         menu_s2:=ms2_scir;
         _rpls_rst:=rpl_rhead;
         g_started:=true;
      end;
      if(_m_sel=ms_rplsdl)then _rpls_delete;

      if(_m_sel=ms_rplson)then
       if(_rpls_rst=rpl_none)
       then _rpls_rst:=rpl_whead
       else _rpls_rst:=rpl_none;

      if(_m_sel=ms_rplspn)then _scrollV(@_rpls_pnui,1,0,9);

      {if(_m_sel=30)then
      begin
         _cmp_sel:=_cmp_sm+((m_vy-300)div 14);
         if(_cmp_sel>=MaxMissions)then _cmp_sel:=MaxMissions-1;
      end;
      if(_m_sel=31)then
       if(cmp_skill<4)then inc(cmp_skill,1);
     }
      k_ml:=1;
   end;

   if(k_mr=2)then    // right button pressed
   begin
      if(_m_sel=ms_mapsed)then begin Map_randomseed; Map_premap;end;
      if(_m_sel=ms_mapset)then
       case ((m_vy-141)div 19) of
       0 : begin _scrollV(@map_mw,-500,MinSMapW,MaxSMapW); Map_premap;end;
       1 : begin _scrollV(@map_liq,-1,0,4); Map_premap;end;
       2 : begin _scrollV(@map_obs,-1,0,4); Map_premap;end;
       end;

      if(_m_sel=ms_gamers)then MakeRandomSkirmish(true);

      if(_m_sel=ms_mlttem)then _scrollV(@PlayerTeam,-1,1,MaxPlayers);
      if(_m_sel=ms_mltpnu)then _scrollV(@net_pnui,-1,0,9);

      if(_m_sel=ms_plteam)then
      begin
         p:=((m_vy-129) div 22)+1;
         if(p in [1..MaxPlayers])then
          with _players[p] do
           if(state=ps_comp)or(p=HPlayer)then
            if(team>1)then
            begin
               dec(team,1);
            end;
      end;

      if(_m_sel=ms_plname)then
      begin
         p:=((m_vy-129) div 22)+1;
         if(p in [1..MaxPlayers])then
          if(net_nstat=ns_clnt)
          then net_swapp(p)
          else _swapPlayers(p,HPlayer);
      end;

      if(_m_sel=ms_rplspn)then _scrollV(@_rpls_pnui,-1,0,9);

      {
      if(_m_sel=31)then _scrollV(@cmp_skill,-1,0,4);
}
      k_mr:=1;
   end;

   if((k_chrt=2)or(k_chrt>vid_h3fps))then
    case _m_sel of
     ms_setpln : PlayerName:=menu_sf(PlayerName,k_kbstr,NameLen);
     ms_mapsed : begin
                    map_seed:=s2c(menu_sf(c2s(map_seed),k_kbdig,15));
                    map_premap;
                 end;
     ms_mltsvp : begin
                    net_sv_pstr:=menu_sf(net_sv_pstr,k_kbdig,5);
                    net_sv_sport;
                 end;
     ms_mltcla : net_cl_svstr:=menu_sf(net_cl_svstr,k_kbaddr,21);
     ms_svldsn : _svld_str   :=menu_sf(_svld_str   ,k_kbstr,SvRpLen);
     ms_rplsfn : _rpls_lrname:=menu_sf(_rpls_lrname,k_kbstr,SvRpLen);
   else
     if(m_chat)then ui_chat_str:=menu_sf(ui_chat_str,k_kbstr,ChatLen);
   end;

   inc(m_vx,mv_x);
   inc(m_vy,mv_y);
end;
