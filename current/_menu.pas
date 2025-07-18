function StringApplyInput(s:shortstring;charset:TSoc;ms:byte):shortstring;
var i:byte;
    c:char;
begin
   if(length(k_keyboard_string)>0)then
   for i:=1 to length(k_keyboard_string) do
   begin
      c:=k_keyboard_string[i];
      if(c=#8)   // backspace
      then delete(s,length(s),1)
      else
       if(length(s)>=ms)
       then break
       else
         if(c in charset)then s:=s+c;
   end;
   k_keyboard_string:='';
   StringApplyInput:=s;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MENU ACTIONS

function menu_surrender(check:boolean):boolean;
begin
   menu_surrender:=false;

   if(g_deadobservers)and(not g_players[HPlayer].observer)and(not GameCheckEndStatus)and(rpls_state<rpls_read)then
   begin
      menu_surrender:=true;

      if(check)then exit;

      case net_status  of
      ns_server,
      ns_none   : begin
                     GameLogPlayerSurrender(HPlayer);
                     PlayerKill(HPlayer,true);
                  end;
      ns_client : net_surrender;// send surrender command, toggle menu
      end;
      ToggleMenu;
   end;
end;

function menu_SaveLoadTab:boolean;
begin
   menu_SaveLoadTab:=(net_status=ns_none)and(ServerSide);
end;
function menu_ReplaysTab:boolean;
begin
   menu_ReplaysTab:=(net_status=ns_none);
end;
function menu_GameSettingsEnabled:boolean;
begin
   menu_GameSettingsEnabled:=false;

   if(menu_s2=ms2_camp)
   or(g_started)then exit;

   case net_status of
   ns_none,
   ns_server: menu_GameSettingsEnabled:=true;
   ns_client: menu_GameSettingsEnabled:=net_cl_Hoster=0;
   end;
end;
function menu_CampanyTab:boolean;
begin
   menu_CampanyTab:=(net_status=ns_none)and(not G_Started);
end;
function menu_ScirmishTab:boolean;
begin
   menu_ScirmishTab:=not(G_Started and(menu_s2=ms2_camp));
end;
function menu_MultiplayerTab:boolean;
begin
   menu_MultiplayerTab:=not(G_Started and(menu_s2=ms2_camp));
end;
function PlayersSlotEnabled:boolean;
begin
   PlayersSlotEnabled:=(not G_Started)and(menu_s2<>ms2_camp);
end;
function menu_PlayerNameEnabled:boolean;
begin
   menu_PlayerNameEnabled:=(net_status=ns_none)and(not G_Started);
end;
function menu_ReplayStatusToggleEnabled:boolean;
begin
   menu_ReplayStatusToggleEnabled:=rpls_state<>rpls_read;
end;
function menu_NetServer(start,check:boolean):boolean;
begin
   menu_NetServer:=false;

   if(net_status=ns_client)
   or(G_Started)then exit;

   case start of
   true : begin   // start
             if(net_status=ns_server)then exit;
             menu_NetServer:=true;
             if(check)then exit;

             net_status:=ns_server;
             net_sv_sport;
             if(not net_UpSocket)then
             begin
                net_dispose;
                net_status:=ns_none;
             end
             else
             begin
                PlayersSetDefault;
                menu_s1:=ms1_sett;
             end;
          end;
   false: begin   // stop
             if(net_status<>ns_server)then exit;
             menu_NetServer:=true;
             if(check)then exit;

             net_dispose;
             GameDefaultAll;
             g_started:=false;
             net_status:=ns_none;
          end;
   end;
end;
function menu_NetClient(connect,check:boolean):boolean;
begin
   menu_NetClient:=false;

   if(net_status=ns_server)
   or(G_Started)then exit;

   case connect of
   true : begin   // start connecting
             if(net_status=ns_client)then exit;
             menu_NetClient:=true;
             if(check)then exit;

             net_error_timer:=0;
             net_cl_Hoster:=255;
             net_status:=ns_client;
             net_cl_saddr;
             rpls_pnu:=0;
             if(net_UpSocket)
             then GameLogChat(255,255,str_connecting,true)
             else
             begin
                GameLogChat(255,255,str_portblocked,true);
                net_dispose;
                net_status:=ns_none;
             end;

             menu_s1:=ms1_sett;
          end;
   false: begin   // disconnect
             if(net_status<>ns_client)then exit;
             menu_NetClient:=true;
             if(check)then exit;

             net_disconnect;
             net_dispose;
             GameDefaultAll;
             G_started  :=false;
             PlayerReady:=false;
             net_status :=ns_none;
          end;
   end;
end;
function menu_ReadyButtonEnabled:boolean;
begin
   menu_ReadyButtonEnabled:=(net_status=ns_client)and(not g_started);
end;

////////////////////////////////////////////////////////////////////////////////

function menu_MouseXY2Item:byte;
var p:byte;
begin
   menu_MouseXY2Item:=0;

   if(544<mouse_y)and(mouse_y<571)then
   begin
      if(32 <mouse_x)and(mouse_x<107)then
        if(G_Started)
        then menu_MouseXY2Item:=111  // menu toggle
        else menu_MouseXY2Item:=110; // game quit

      if(360<mouse_x)and(mouse_x<440)then
        if(menu_surrender(true))
        then menu_MouseXY2Item:=115; // surrender

      if(692<mouse_x)and(mouse_x<767)then
        if(G_Started)then
        begin
           case net_status  of
           ns_server,
           ns_none   : menu_MouseXY2Item:=114; // break game
           ns_client : menu_MouseXY2Item:=110; // game quit
           end
         end
         else
           case net_status  of
           ns_server,
           ns_none   : menu_MouseXY2Item:=112; // start game
           ns_client : ;
           end;
   end;

   if(menu_s2=ms2_camp)then
     if(92<mouse_y)and(mouse_y<108)then
     begin
        if(635<mouse_x)and(mouse_x<659)then menu_MouseXY2Item:=128; // campaing mission obj page next
        if(699<mouse_x)and(mouse_x<723)then menu_MouseXY2Item:=129; // campaing mission obj page prev
     end;

   if(ui_menu_ssr_x0<mouse_x)and(mouse_x<ui_menu_ssr_x1)and(ui_menu_ssr_y0<mouse_y)and(mouse_y<ui_menu_ssr_y1)then
   begin
      // SETTINGS
      // 3 4 5
      // 6 ...14
      // 15...23
      // 24...32
      // 33...35
      menu_MouseXY2Item:=(mouse_y-ui_menu_ssr_y0) div ui_menu_ssr_ys;
      if(menu_MouseXY2Item=0)then
      begin
         menu_MouseXY2Item:=3+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs);

         case menu_MouseXY2Item of
         3 : ;                                                  // settings
         4 : if(not menu_SaveLoadTab)then menu_MouseXY2Item:=0; // save load
         5 : if(not menu_ReplaysTab )then menu_MouseXY2Item:=0; // replays
         else menu_MouseXY2Item:=0;
         end;
      end
      else
      begin
         case menu_s1 of
         ms1_sett: if(menu_MouseXY2Item=1)
                   then menu_MouseXY2Item:=33+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs) // settings
                   else
                   begin
                      case menu_s3 of
                      ms3_game: begin
                                   menu_MouseXY2Item+=4;
                                   if(menu_MouseXY2Item=6)and(mouse_x<ui_menu_ssr_x7)then menu_MouseXY2Item:=106;
                                   if(menu_MouseXY2Item=11)then
                                     if(not menu_PlayerNameEnabled)then menu_MouseXY2Item:=0;
                                end;
                      ms3_vido: menu_MouseXY2Item+=13;
                      ms3_sond: menu_MouseXY2Item+=22;
                      end;

                      if(menu_MouseXY2Item=16)then
                        if(mouse_x>ui_menu_ssr_x5)then
                        begin
                           if(mouse_x<ui_menu_ssr_x6)
                           then menu_MouseXY2Item:=116
                           else menu_MouseXY2Item:=117;
                        end
                        else
                          if(mouse_x>ui_menu_ssr_x4)then menu_MouseXY2Item:=16;
                   end;
         ms1_svld: begin  // 36..40
                      if(menu_MouseXY2Item in [1..8])and(mouse_x<ui_menu_ssl_x0)then menu_MouseXY2Item:=36
                      else
                        if(menu_MouseXY2Item=9)and(mouse_x<ui_menu_ssl_x0)
                        then menu_MouseXY2Item:=37
                        else
                          if(menu_MouseXY2Item=10)
                          then menu_MouseXY2Item:=38+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs)
                          else menu_MouseXY2Item:=0;

                      case menu_MouseXY2Item of
                      36,
                      37: if(not G_Started)then menu_MouseXY2Item:=0;
                      38: if(not saveload_Save  (true))then menu_MouseXY2Item:=0;
                      39: if(not saveload_Load  (true))then menu_MouseXY2Item:=0;
                      40: if(not saveload_Delete(true))then menu_MouseXY2Item:=0;
                      else menu_MouseXY2Item:=0;
                      end;
                   end;
         ms1_reps: begin  // 41..44
                      if(menu_MouseXY2Item in [1..9])and(mouse_x<ui_menu_ssl_x0)then menu_MouseXY2Item:=41
                      else
                        if(menu_MouseXY2Item=10)
                        then menu_MouseXY2Item:=42+((mouse_x-ui_menu_ssr_x0) div ui_menu_ssr_xs)
                        else menu_MouseXY2Item:=0;

                      case menu_MouseXY2Item of
                      41: if(g_started)then menu_MouseXY2Item:=0;
                      42: if(not replay_Play  (true))then menu_MouseXY2Item:=0;
                      44: if(not replay_Delete(true))then menu_MouseXY2Item:=0;
                      else menu_MouseXY2Item:=0;
                      end;
                   end;
         end;
      end;
   end;

   if(menu_GameSettingsEnabled)then  // MAP
     if(ui_menu_map_rx0<mouse_x)and(mouse_x<ui_menu_map_rx1)and(ui_menu_map_y0<mouse_y)and(mouse_y<ui_menu_map_y1)then
       menu_MouseXY2Item:=50+((mouse_y-ui_menu_map_y0) div ui_menu_map_ys);

   if (ui_menu_pls_zxn<mouse_x)and(mouse_x<ui_menu_pls_zxe)
   and(ui_menu_pls_zy0<mouse_y)and(mouse_y<ui_menu_pls_zy2)then    // players
   begin
      p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys);
      if(ui_menu_pls_zxn<mouse_x)and(mouse_x<ui_menu_pls_zxs)then menu_MouseXY2Item:=161+p;
      if(ui_menu_pls_zxs<mouse_x)and(mouse_x<ui_menu_pls_zxr)then menu_MouseXY2Item:=171+p;
      if(ui_menu_pls_zxr<mouse_x)and(mouse_x<ui_menu_pls_zxt)then menu_MouseXY2Item:=181+p;
      if(ui_menu_pls_zxt<mouse_x)and(mouse_x<ui_menu_pls_zxc)then menu_MouseXY2Item:=191+p;

      case menu_MouseXY2Item of
      161..166: if(not PlayersSlotEnabled)then menu_MouseXY2Item:=0;
      171..176: if(not PlayerAIToggle  (menu_MouseXY2Item-170,true     ))then menu_MouseXY2Item:=0;
      181..186: if(not PlayerRaceChange(menu_MouseXY2Item-180,true     ))then menu_MouseXY2Item:=0;
      191..196: if(not PlayerTeamChange(menu_MouseXY2Item-190,true,true))then menu_MouseXY2Item:=0;
      167     : if(not menu_ReadyButtonEnabled)then menu_MouseXY2Item:=0;
      else menu_MouseXY2Item:=0;
      end;
   end;

   if(ui_menu_csm_x0<mouse_x)and(mouse_x<ui_menu_csm_x1)and(ui_menu_csm_y0<mouse_y)and(mouse_y<ui_menu_csm_y1)then
   begin
      menu_MouseXY2Item:=(mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys;
      if(menu_MouseXY2Item=0)then
      begin
         menu_MouseXY2Item:=70+((mouse_x-ui_menu_csm_x0) div ui_menu_csm_xs);
         case menu_MouseXY2Item of
         70: if(not menu_CampanyTab    )then menu_MouseXY2Item:=0;
         71: if(not menu_ScirmishTab   )then menu_MouseXY2Item:=0;
         72: if(not menu_MultiplayerTab)then menu_MouseXY2Item:=0;
         else menu_MouseXY2Item:=0;
         end;
      end
      else
      begin
         case menu_s2 of
         ms2_scir: begin
                      menu_MouseXY2Item+=72;  // 73..84

                      case menu_MouseXY2Item of
                      74..80: if(not menu_GameSettingsEnabled)then menu_MouseXY2Item:=0;       // game settings

                      82    : if(mouse_x<ui_menu_csm_x3)
                              or(not menu_ReplayStatusToggleEnabled)then menu_MouseXY2Item:=0; // replay record
                      83    : if(rpls_state<>rpls_none)then menu_MouseXY2Item:=0;              // replay prefix
                      84    : if(not menu_ReplayStatusToggleEnabled)then menu_MouseXY2Item:=0; // replay qual
                      else menu_MouseXY2Item:=0;
                      end;
                   end;
         ms2_mult: begin
                      menu_MouseXY2Item:=84+menu_MouseXY2Item;  // 85..96

                      case net_status of
                      ns_none  : ;
                      ns_server: case menu_MouseXY2Item of
                                 85 : menu_MouseXY2Item:=86;
                             88..96 : menu_MouseXY2Item:=100;
                                 else menu_MouseXY2Item:=0;
                                 end;
                      ns_client: case menu_MouseXY2Item of
                                 85 : menu_MouseXY2Item:=89;
                                 86 : menu_MouseXY2Item:=91;
                             88..96 : menu_MouseXY2Item:=100;
                                 else menu_MouseXY2Item:=0;
                                 end;
                      end;

                      case menu_MouseXY2Item of
                      86 : if(not menu_NetServer(net_status<>ns_server,true))then menu_MouseXY2Item:=0; // start/stop server
                      87 : if(net_status<>ns_none)then menu_MouseXY2Item:=0;

                      89 : if(not menu_NetClient(net_status<>ns_client,true))then menu_MouseXY2Item:=0; // connect/disconnect
                      90 : if(net_status<>ns_none  )then menu_MouseXY2Item:=0;
                      91 : if(net_status= ns_server)then menu_MouseXY2Item:=0;
                      100: ;
                      else menu_MouseXY2Item:=0;
                      end;

                   end;
         ms2_camp: begin
                      if(menu_MouseXY2Item=1)
                      then menu_MouseXY2Item:=97
                      else menu_MouseXY2Item:=98;

                      case menu_MouseXY2Item of
                      97,                                        // skill and missions list
                      98: if(G_Started)then menu_MouseXY2Item:=0;
                      else menu_MouseXY2Item:=0;
                      end;
                   end;
         else menu_MouseXY2Item:=0;
         end;
      end;
   end;
end;

function GetIndex(cval:integer;firsti:pinteger;size:integer):integer;
begin
   GetIndex:=0;
   if(size>0)then
     while(GetIndex<size)do
     begin
        if(firsti^=cval)then break;
        firsti+=1;
        GetIndex+=1;
     end;
end;

procedure g_menu;
var p:byte;
mnx,t,
mny :integer;
begin
   mnx:=mouse_x;
   mny:=mouse_y;
   mouse_x:=round((mouse_x-r_menusc_x)*r_menusc_s);
   mouse_y:=round((mouse_y-r_menusc_y)*r_menusc_s);

   p:=menu_MouseXY2Item; // menu hint
   if(p<>menu_ihint)then
   begin
      menu_ihint:=p;

      menu_ihintpi:=255;
      for p:=0 to menu_ihintn do
        if(menu_ihintly[p]<mouse_y)and(abs(menu_ihintlx[p]-mouse_x)<166)then
         if(menu_ihintpi=255)
         then menu_ihintpi:=p
         else
           if(abs(menu_ihintly[p]-mouse_y)<abs(menu_ihintly[menu_ihintpi]-mouse_y))
           then menu_ihintpi:=p;
      vid_menu_redraw:=true;
   end;

   if(ks_mleft=1)or(ks_mright=1) then   //right or left click
   begin
      case menu_item of
      90: net_cl_saddr;
      11: g_players[HPlayer].name:=PlayerName;
      50: if(not menu_GameSettingsEnabled)
          then menu_mseed:=c2s(map_seed)
          else
            if(net_status=ns_client)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_lobby_MSeed);
               net_writecard(s2c(menu_mseed));
               net_send(net_cl_svip,net_cl_svport);
            end
            else
            begin
               map_seed:=s2c(menu_mseed);
               menu_mseed:=c2s(map_seed);
               map_premap;
            end;
      end;

      menu_item:=menu_MouseXY2Item;
      if not(menu_item in [116,117])then begin m_vrx:=vid_vw;m_vry:=vid_vh; end;
      vid_menu_redraw:=true;
      SoundPlayUI(snd_click);
   end;
   if(ks_mleft=1)then              // left button pressed
   begin
      case menu_item of
      111: ToggleMenu;
      110: GameCycle:=false;

      112: GameMakeStartBreak;          // start game
      114: GameMakeStartBreak;          // break game
      115: menu_surrender(false);       // Surrender

      /// SETTINGS SAVE REPLAYS

      3  : menu_s1:=ms1_sett;
      4  : begin menu_s1:=ms1_svld; saveload_MakeFolderList; end;
      5  : begin menu_s1:=ms1_reps; replay_MakeFolderList; end;

      // game settings
      106: vid_ColoredShadow:=not vid_ColoredShadow;
      6  : vid_APM:=not vid_APM;
      7  : begin vid_uhbars+=1;vid_uhbars:=vid_uhbars mod 3; end;
      8  : m_action:=not m_action;
      9  : if(ui_menu_ssr_x2>=mouse_x)
           then vid_CamSpeed:=0
           else
             if(mouse_x<ui_menu_ssr_x3)
             then vid_CamSpeed:=mouse_x-ui_menu_ssr_x2
             else vid_CamSpeed:=127;
      10 : vid_CamMScroll:=not vid_CamMScroll;
      12 : begin ui_language:=not ui_language;SwitchLanguage;end;
      13 : begin
              vid_ppos+=1;
              vid_ppos:=vid_ppos mod 4;
              vid_RemakeScreenSurfaces;
              theme_map_ptrt:=255;
              gfx_MapMakeTerrain;
           end;
      14 : ScrollByte(@vid_plcolors,true,0,vid_maxplcolors);

      // video
      116: m_vrx:=vid_wl[(GetIndex(m_vrx,@vid_wl[0],vid_wl_n)+1) mod vid_wl_n]; // width
      117: m_vry:=vid_hl[(GetIndex(m_vry,@vid_hl[0],vid_hl_n)+1) mod vid_hl_n]; // height
      16 : if(m_vrx<>vid_vw)or(m_vry<>vid_vh)then // apply
           begin
              vid_vw:=m_vrx;
              vid_vh:=m_vry;

              vid_MakeScreen;
              theme_map_ptrt:=255;
              gfx_MapMakeTerrain;
           end;

      18 : begin vid_fullscreen:=not vid_fullscreen; vid_MakeScreen;end;
      20 : vid_FPS:=not vid_FPS;
      22 : vid_menu_scale:=not vid_menu_scale;
      23 : vid_menu_scales:=not vid_menu_scales;

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
      29 : SoundMusicControll(true);
      30 : ScrollByte(@snd_musicListSize,true,1,snd_musicListSizeMax);
      31 : GameMusicReLoad;

      33 : menu_s3:=ms3_game;
      34 : menu_s3:=ms3_vido;
      35 : menu_s3:=ms3_sond;

      // save load
      36 : begin
              svld_list_sel:=svld_list_scroll+((mouse_y-ui_menu_ssr_y0-ui_menu_ssr_ys)div ui_menu_ssr_ys);
              saveload_Select;
           end;
      37 : ;
      38 : saveload_Save  (false);
      39 : saveload_Load  (false);
      40 : saveload_Delete(false);

      // replays
      41 : begin
              rpls_list_sel :=rpls_list_scroll+((mouse_y-ui_menu_ssr_y0)div ui_menu_ssr_ys)-1;
              replay_Select;
           end;
      42 : replay_Play  (false);
      43 : ;
      44 : replay_Delete(false);

      ///  MAP
      50 : ;
      51 : menu_GameMapSetting(nmid_lobby_MSize  ,true);
      52 : menu_GameMapSetting(nmid_lobby_MObs   ,true);
      53 : menu_GameMapSetting(nmid_lobby_MSym   ,true);
      56 : menu_GameMapSetting(nmid_lobby_MRandom,true);

      // PLAYERS table
      161..166: PlayerAILevelLoop(menu_item-160);
      171..176: PlayerAIToggle   (menu_item-170,false);
      181..186: PlayerRaceChange (menu_item-180,false);
      191..196: PlayerTeamChange (menu_item-190,true,false);
      167: PlayerReady:=not PlayerReady;

      // CAMP SCIRMISH MULTIPLAY
      70 : begin
              menu_s2:=ms2_camp;
              cmp_minfo_lpage:=str_camp_infon[cmp_sel] div vid_campi_scrlstep;
           end;
      71 : begin p:=menu_s2;menu_s2:=ms2_scir;if(p=ms2_camp)then Map_premap;end;
      72 : menu_s2:=ms2_mult;

      // game options
      74 : menu_GameMapSetting(nmid_lobby_GMode      ,true);
      75 : menu_GameMapSetting(nmid_lobby_GFixPos    ,true);
      76 : menu_GameMapSetting(nmid_lobby_GAISlots   ,true);
      77 : menu_GameMapSetting(nmid_lobby_GGen       ,true);
      78 : menu_GameMapSetting(nmid_lobby_GDeadObs   ,true);
      79 : menu_GameMapSetting(nmid_lobby_GRandomScir,true);

      // replays
      82 : if(rpls_state=rpls_none)
           then rpls_state:=rpls_write
           else rpls_state:=rpls_none;
      83 : ;
      84 : ScrollByte(@rpls_pnui,true,0,_cl_pnun_rpls);

      //// multiplayer
      // server
      86 : menu_NetServer(net_status<>ns_server,false);
      87 : ; // port

      // client
      89 : menu_NetClient(net_status<>ns_client,false);
      90 : ;
      91 : ScrollByte(@net_pnui,true,0,_cl_pnun);

      // camps
      97 : ScrollByte(@cmp_skill,true,0,CMPMaxSkills);
      98 : begin
              t:=cmp_sel;
              cmp_sel:=cmp_scroll+((mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(cmp_sel>=LastMission)then cmp_sel:=LastMission;
              if(t<>cmp_sel)then
              begin
                 cmp_minfo_page :=0;
                 cmp_minfo_lpage:=str_camp_infon[cmp_sel] div vid_campi_scrlstep;
              end;
           end;
      128: if(cmp_minfo_page>0)then cmp_minfo_page-=1;
      129: if(cmp_minfo_page<cmp_minfo_lpage)then cmp_minfo_page+=1;
      end;

   end;

   if(ks_mright=1)then    // right button pressed
   begin
      case menu_item of
      14 : ScrollByte(@vid_plcolors,false,0,vid_maxplcolors);

      116: m_vrx:=vid_wl[(GetIndex(m_vrx,@vid_wl[0],vid_wl_n)+vid_wl_n-1) mod vid_wl_n];
      117: m_vry:=vid_hl[(GetIndex(m_vry,@vid_hl[0],vid_hl_n)+vid_hl_n-1) mod vid_hl_n];

      30 : ScrollByte(@snd_musicListSize,false,1,snd_musicListSizeMax);

      // MAP
      50 : menu_GameMapSetting(nmid_lobby_MSeed,false);
      51 : menu_GameMapSetting(nmid_lobby_MSize,false);
      52 : menu_GameMapSetting(nmid_lobby_MObs ,false);

      // players
      161..166: PlayersSwap     (menu_item-160,HPlayer);
      181..186: ;
      191..196: PlayerTeamChange(menu_item-190,false,false);

      // game settings
      74 : menu_GameMapSetting(nmid_lobby_GMode      ,false);
      76 : menu_GameMapSetting(nmid_lobby_GAISlots   ,false);
      77 : menu_GameMapSetting(nmid_lobby_GGen       ,false);
      79 : menu_GameMapSetting(nmid_lobby_GRandomScir,false);

      84 : ScrollByte(@rpls_pnui,false,0,9);

      90 : ;
      91 : ScrollByte(@net_pnui,false,0,9);

      97 : ScrollByte(@cmp_skill,false,0,CMPMaxSkills);
      end;
   end;

   if(menu_s2=ms2_mult)and(net_status<>ns_none)and(menu_item<>50)then menu_item:=100;

   if(length(k_keyboard_string)>0)then
   begin
      case menu_item of
      11 : PlayerName:=StringApplyInput(PlayerName,k_kbstr,NameLen);
      37 : svld_str_fname:=StringApplyInput(svld_str_fname ,k_kbstr,SvRpLen);
      50 : begin
              //map_seed:=s2c(StringApplyInput(c2s(map_seed),k_kbdig,10));
              menu_mseed:=StringApplyInput(menu_mseed,k_kbdig,10);
           end;
      83 : rpls_str_name:=StringApplyInput(rpls_str_name,k_kbstr,SvRpLen);
      87 : begin
              net_sv_pstr:=StringApplyInput(net_sv_pstr,k_kbdig,5);
              net_sv_sport;
           end;
      90 : if(net_status=ns_none)then net_cl_svstr:=StringApplyInput(net_cl_svstr,k_kbstr,21);
      100: net_chat_str:=StringApplyInput(net_chat_str,k_kbstr,255);
      end;

      vid_menu_redraw:=true;
   end;

   mouse_x:=mnx;
   mouse_y:=mny;
end;

