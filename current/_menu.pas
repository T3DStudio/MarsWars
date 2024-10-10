

////////////////////////////////////////////////////////////////////////////////
//  MENU COMMON

function menu_List_Clear:boolean;
begin
   menu_List_Clear:=menu_list_n>0;
   menu_item  :=0;
   menu_list_n:=0;
   setlength(menu_list_items,menu_list_n);
   menu_remake:=true;
end;

function menu_NetSearchStop:boolean;
begin
   menu_NetSearchStop:=false;
   if(net_status=ns_client)and(net_svsearch)then
   begin
      menu_NetSearchStop:=true;
      net_svsearch:=false;
      net_dispose;
      net_status :=ns_single;
      net_status_str:='';
   end;
end;
function menu_ServerStop:boolean;
begin
   menu_ServerStop:=false;
   if(net_status=ns_server)then
   begin
      menu_ServerStop:=true;

      net_dispose;
      GameDefaultAll;
      g_started :=false;
      net_status:=ns_single;
   end;
end;

procedure menu_Toggle;
begin
   menu_remake:=true;

   if(menu_state)then
     if(menu_List_Clear)
     then exit
     else
       if(menu_NetSearchStop)
       then exit
       else
         if(menu_page2>0)then
         begin
            menu_item:=0;
            menu_page2:=0;
            exit;
         end
         else
         begin
            if(not g_started)then
            begin
               if(net_status>ns_single)then exit;
               if(menu_page1>mp_main)then
               begin
                  menu_item :=0;
                  menu_page1:=mp_main;
                  exit;
               end;
               if(menu_state)then exit;
            end;
         end;

   menu_state:=not menu_state;

   if(net_status=ns_single)and(g_Status<=MaxPlayers)then
     if(menu_state)
     then g_Status:=PlayerClient
     else g_Status:=gs_running;
end;

function menu_NetSearchConnect(Check:boolean):boolean;
begin
   menu_NetSearchConnect:=false;
   if(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn)then
   begin
      menu_NetSearchConnect:=true;
      if(Check)then exit;
      net_svsearch:=false;
      net_dispose;
      net_status    :=ns_single;
      net_status_str:='';
      if(net_UpSocket(0))then
      begin
         with net_svsearch_list[net_svsearch_sel] do net_cl_svstr:=c2ip(ip)+':'+w2s(swap(port));
         net_cl_saddr;
         net_status_str:=str_menu_connecting;
         net_status    :=ns_client;
         rpls_pnu      :=0;
      end
      else net_dispose;
   end;
end;

procedure menu_ReInit;
const mainBtnW  = (vid_minw div 5)-4;
      mainBtnWh = mainBtnW div 2;
var tx0,tx1,tx2,
    ty0,ty1,ty2:integer;
procedure SetItem(item:byte;ax0,ay0,ax1,ay1:integer;aenabled:boolean);
begin
   with menu_items[item] do
   begin
      mi_x0:=min2i(ax0,ax1);
      mi_y0:=min2i(ay0,ay1);
      mi_x1:=max2i(ax0,ax1);
      mi_y1:=max2i(ay0,ay1);
      mi_enabled:=aenabled;
   end;
end;
function NeedColumnRace(p:byte):boolean;
begin
   NeedColumnRace:=false;
   if(p<=MaxPlayers)then
     case g_slot_state[p] of
pss_opened   : with g_players[p] do NeedColumnRace:=((player_type=pt_none)and(g_ai_slots>0))or((player_type>pt_none)and(team>0));
pss_AI_1..
pss_AI_11    : NeedColumnRace:=true;
     end;
end;
function NeedColumnTeam(p:byte):boolean;
begin
   NeedColumnTeam:=false;
   if(p<=MaxPlayers)then
     case g_slot_state[p] of
pss_opened   : with g_players[p] do NeedColumnTeam:=((player_type=pt_none)and(g_ai_slots>0))or(player_type>pt_none);
pss_observer,
pss_AI_1..
pss_AI_11    : NeedColumnTeam:=true;
     end;
end;
procedure ms_DefaultCaption(mi:byte);
begin
   SetItem(mi,vid_vhw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
              vid_vhw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
end;

procedure ms_BottomButtons1(mi:byte);
begin
   ty0:=vid_vh-menu_main_mp_bh1h-((vid_vh-vid_minh) div 8);
   SetItem(mi,vid_vhw-menu_main_mp_bwh,ty0,
              vid_vhw+menu_main_mp_bwh,ty0+menu_main_mp_bh1,true );
end;
procedure ms_BottomButtonsXY(N:integer);
begin
   tx1:=min2i(mainBtnWh,(vid_vw-(mainBtnW*N)) div (N+1));
   tx0:=vid_vhw-((tx1*N+mainBtnW*N-tx1) div 2);
   ty0:=vid_vh-menu_main_mp_bh1h-((vid_vh-vid_minh) div 8);
end;

procedure ms_BottomButtons2(mi1,mi2:byte);
begin
   ms_BottomButtonsXY(2);
   SetItem(mi1,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi2,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );
end;
procedure ms_BottomButtons4(mi1,mi2,mi3,mi4:byte);
begin
   ms_BottomButtonsXY(4);
   SetItem(mi1,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi2,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi3,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi4,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );
end;
procedure ms_BottomButtons5(mi1,mi2,mi3,mi4,mi5:byte);
begin
   ms_BottomButtonsXY(5);
   SetItem(mi1,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi2,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi3,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi4,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
   SetItem(mi5,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );
end;

procedure ms_Scirmish;
var i:integer;
begin
   if(vid_vh<700)
   then ty2:=0
   else ty2:=menu_main_mp_bh1;
   SetItem(mi_title_Scirmish,
              vid_vhw-menu_main_mp_bwh,menu_logo_h+ty2,
              vid_vhw+menu_main_mp_bwh,menu_logo_h+ty2+menu_main_mp_bh1,true );

   ty2:=(vid_vh-vid_minh+10) div 2;

   if(not net_svsearch)then
   begin
      // PLAYERS

      ty0:=menu_logo_h+ty2+menu_main_mp_bh2+1;

      tx0:=vid_vhw-396-((vid_vw-vid_minw) div 8);
      ty1:=menu_main_mp_bhh;

      tx1:=tx0+menu_players_namew+menu_players_racew+menu_players_teamw+ty1*2;
      SetItem(mi_title_players,tx0-basefont_w2,ty0-menu_main_mp_bh1,
                               tx1+basefont_w2,ty0+ty1*6+basefont_w2,true );

      for i:=1 to MaxPlayers do
      begin
         tx1:=tx0;

         SetItem(mi_player_status1+i-1,tx1,ty0,tx1+menu_players_namew,ty0+ty1,PlayerSlotChangeState(PlayerClient,i,255,true));tx1+=menu_players_namew;
         if(NeedColumnRace(i))then
         SetItem(mi_player_race1  +i-1,tx1,ty0,tx1+menu_players_racew,ty0+ty1,PlayerSlotChangeRace (PlayerClient,i,255,true));tx1+=menu_players_racew;
         if(NeedColumnTeam(i))then
         SetItem(mi_player_team1  +i-1,tx1,ty0,tx1+menu_players_teamw,ty0+ty1,PlayerSlotChangeTeam (PlayerClient,i,255,true));tx1+=menu_players_teamw;

         SetItem(mi_player_color1 +i-1,tx1,ty0,tx1+ty1*2             ,ty0+ty1,false);tx1+=ty1*2;

         ty0+=ty1;
      end;

      // GAME SETTINGS

      ty0+=ty1*4;

      SetItem(mi_title_GOptions  ,tx0-basefont_w2,ty0-menu_main_mp_bh1,
                                  tx1+basefont_w2,ty0+ty1*8+basefont_w2,true );

      SetItem(mi_game_mode          ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_lobbby_gamemode  ,0,true));ty0+=ty1;
      SetItem(mi_game_builders      ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_lobbby_builders  ,0,true));ty0+=ty1;
      SetItem(mi_game_generators    ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_lobbby_generators,0,true));ty0+=ty1;
      SetItem(mi_game_FixStarts     ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_lobbby_FixStarts ,0,true));ty0+=ty1;
      SetItem(mi_game_DeadPbserver  ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_lobbby_DeadPObs  ,0,true));ty0+=ty1;
      SetItem(mi_game_EmptySlots    ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_lobbby_EmptySlots,0,true));ty0+=ty1;
                                                                                                                           ty0+=ty1;
      SetItem(mi_game_RandomSkrimish,tx0,ty0,tx1,ty0+ty1,not g_started);


      // MAP
      tx0:=vid_vhw+396-menu_map_settingsw-r_minimap^.w-basefont_w2+((vid_vw-vid_minw) div 8);
      tx1:=tx0+menu_map_settingsw;
      ty0:=menu_logo_h+ty2+menu_main_mp_bh1h+menu_main_mp_bhq;

      SetItem(mi_title_map      ,tx0-basefont_w2             ,ty0-menu_main_mp_bhq3,
                              tx1+basefont_w3+r_minimap^.w,ty0+r_minimap^.w+basefont_w1,true );

      SetItem(mi_map_Preset ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,GameLoadPreset(PlayerClient,0,true)                              );ty0+=menu_main_mp_bhh;
      SetItem(mi_map_Seed   ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,map_SetSetting(PlayerClient,nmid_lobbby_mapseed          ,0,true));ty0+=menu_main_mp_bhh;
      SetItem(mi_map_Size   ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,map_SetSetting(PlayerClient,nmid_lobbby_mapsize ,MinMapSize,true));ty0+=menu_main_mp_bhh;
      SetItem(mi_map_Type   ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,map_SetSetting(PlayerClient,nmid_lobbby_type             ,0,true));ty0+=menu_main_mp_bhh;
      SetItem(mi_map_Sym    ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,map_SetSetting(PlayerClient,nmid_lobbby_symmetry         ,0,true));ty0+=menu_main_mp_bhh;
      SetItem(mi_map_Random ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,menu_items[mi_map_Sym].mi_enabled);ty0+=menu_main_mp_bhh;
      SetItem(mi_map_Theme  ,tx0,ty0,tx1,ty0+menu_main_mp_bhh,true);

      ty0:=((menu_items[mi_map_Preset].mi_y0+menu_items[mi_map_Theme].mi_y1) div 2)-(r_minimap^.h div 2);
      SetItem(mi_map_MiniMap,tx1+basefont_w1,ty0,tx1+basefont_w1+r_minimap^.w,ty0+r_minimap^.h,false);

      // MULTIPLAYER
      ty0:=menu_logo_h+ty2+menu_main_mp_bh3+r_minimap^.w+basefont_w2-menu_main_mp_bhq;


      SetItem(mi_title_multiplayer,tx0-basefont_w2             ,ty0-menu_main_mp_bhq3,
                                   tx1+basefont_w3+r_minimap^.w,ty0+menu_main_mp_bhh*8+basefont_w2+basefont_wq,true );

      ty1:=menu_main_mp_bhh;
      tx1+=basefont_w1+r_minimap^.w;
      case net_status of
   ns_single: begin
              SetItem(mi_mplay_ServerCaption   ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              SetItem(mi_mplay_ServerPort      ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              SetItem(mi_mplay_ServerStart     ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              SetItem(mi_mplay_ClientCaption   ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              SetItem(mi_mplay_ClientAddress   ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              SetItem(mi_mplay_ClientConnect   ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              SetItem(mi_mplay_NetSearchStart  ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
              end;
   ns_server: begin
              SetItem(mi_mplay_ServerCaption   ,tx0,ty0,tx1,ty0+ty1, true);ty0+=ty1;
              SetItem(mi_mplay_ServerStop      ,tx0,ty0,tx1,ty0+ty1, true);ty0+=ty1;
              SetItem(mi_mplay_ChatCaption     ,tx0,ty0,tx1,ty0+ty1, true);ty0+=ty1;
              ty1*=6;
              SetItem(mi_mplay_Chat            ,tx0,ty0,tx1,ty0+ty1, true);
              end;
   ns_client: begin
              SetItem(mi_mplay_ClientCaption   ,tx0,ty0,tx1,ty0+ty1, true);ty0+=ty1;
              SetItem(mi_mplay_ClientDisconnect,tx0,ty0,tx1,ty0+ty1, true);ty0+=ty1;
              SetItem(mi_mplay_ChatCaption     ,tx0,ty0,tx1,ty0+ty1, true);ty0+=ty1;
              ty1*=5;
              SetItem(mi_mplay_Chat            ,tx0,ty0,tx1,ty0+ty1, true);
              end;
      end;

      if(g_started)
      then ms_BottomButtons5(mi_EndGame,mi_SaveLoad,mi_Settings,mi_AboutGame,mi_back )
      else
      begin
         ms_BottomButtons4(mi_back,mi_Settings,mi_AboutGame,mi_start);

        if(net_status>ns_single)
        then menu_items[mi_back].mi_enabled:=false;
      end;
   end
   else
   begin
      tx0:=vid_vhw-menu_main_mp_bw1;
      tx1:=vid_vhw+menu_main_mp_bw1;
      ty0:=menu_logo_h+ty2+menu_main_mp_bh1h;

      SetItem(mi_mplay_NetSearchCaption,tx0,ty0,tx1,ty0+menu_main_mp_bh3q,true );

      ty0+=menu_main_mp_bh1;
      ty1:=ty0+menu_netsearch_listh*menu_netsearch_lineh;
      SetItem(mi_mplay_NetSearchList   ,tx0,ty0,tx1,ty1,true);

      ty0+=menu_main_mp_bhh;
      ty1+=menu_main_mp_bhh;
      ty0:=ty1;ty1+=menu_main_mp_bh3q;
      SetItem(mi_mplay_NetSearchCon    ,tx0,ty0,tx1,ty1,menu_NetSearchConnect(true));
      ty0:=ty1;ty1+=menu_main_mp_bh3q;
      SetItem(mi_mplay_NetSearchStop   ,tx0,ty0,tx1,ty1,true);
   end;
end;

procedure ms_Settings;
begin
   ms_DefaultCaption(mi_title_settings);

   tx0:=vid_vhw-350;
   ty0:=menu_logo_h+menu_main_mp_bh3;
   tx1:=tx0+menu_main_mp_bwh;
   ty1:=ty0+menu_main_mp_bh1;
   ty2:=menu_main_mp_bh1+menu_main_mp_bhq3;

   SetItem(mi_settings_game   ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
   SetItem(mi_settings_record ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
   SetItem(mi_settings_network,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
   SetItem(mi_settings_video  ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
   SetItem(mi_settings_sound  ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;

   tx0+=menu_main_mp_bwh+(menu_main_mp_bwq div 2);
   ty0:=menu_logo_h+menu_main_mp_bh3;
   tx1:=tx0+menu_main_mp_bwh*3+menu_main_mp_bwq;
   ty1:=ty0+menu_main_mp_bh3q;
   ty2:=menu_main_mp_bh3q;

   case menu_settings_page of
   mi_settings_game   : begin
                        SetItem(mi_settings_ColoredShadows ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ShowAPM        ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_HitBars        ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_MRBAction      ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ScrollSpeed    ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_MouseScroll    ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_PlayerName     ,tx0,ty0,tx1,ty1,(net_status=ns_single)and(not G_Started));
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_Langugage      ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_PanelPosition  ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_PlayerColors   ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   mi_settings_record : begin
                        SetItem(mi_settings_RecordStatus   ,tx0,ty0,tx1,ty1,rpls_state<rpls_state_read );
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_RecordName     ,tx0,ty0,tx1,ty1,rpls_state=rpls_state_none );
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_RecordQuality  ,tx0,ty0,tx1,ty1,true );
                        end;
   mi_settings_network: begin
                        SetItem(mi_settings_ClientQuality  ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   mi_settings_video  : begin
                        SetItem(mi_settings_ResWidth       ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ResHeight      ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ResApply       ,tx0,ty0,tx1,ty1,(menu_res_w<>vid_vw)or(menu_res_h<>vid_vh) );
                                                                                   ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_Fullscreen     ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ShowFPS        ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   mi_settings_sound  : begin
                        SetItem(mi_settings_SoundVol       ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_MusicVol       ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_NextTrack      ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   end;

   ms_BottomButtons1(mi_back);
end;

begin
   //menu_List_Clear;
   FillChar(menu_items,SizeOf(menu_items),0);

   case menu_page2 of
mp_SaveGame : begin
              ms_DefaultCaption(mi_title_SaveGame);
              ms_BottomButtons4(mi_back     ,mi_Settings,mi_AboutGame,0);
              end;
mp_LoadGame : begin
              ms_DefaultCaption(mi_title_LoadGame);
              ms_BottomButtons4(mi_back     ,mi_Settings,mi_AboutGame,0);
              end;
mp_settings : ms_Settings;
mp_aboutgame: begin
              ms_DefaultCaption(mi_title_aboutgame);
              ms_BottomButtons1(mi_back);
              end;
   else
      case menu_page1 of
mp_main      : ms_BottomButtons4(mi_StartGame,mi_Settings,mi_AboutGame,mi_exit );
mp_campaings : begin
               ms_DefaultCaption(mi_title_campaings);

               if(g_started)
               then ms_BottomButtons5(mi_EndGame,mi_Settings,mi_AboutGame,mi_SaveLoad,mi_back)
               else ms_BottomButtons4(mi_back   ,mi_Settings,mi_AboutGame,mi_start   );
               end;
mp_scirmish  : ms_Scirmish;
mp_loadgame  : begin
               ms_DefaultCaption(mi_title_loadgame);
               ms_BottomButtons4(mi_back     ,mi_Settings,mi_AboutGame,0);

               end;
mp_loadreplay: begin
               ms_DefaultCaption(mi_title_loadreplay);
               ms_BottomButtons4(mi_back     ,mi_Settings,mi_AboutGame,0);
               end;
      end;
   end;


   // MAIN BUTTONS
   {tx0:=vid_vhw-menu_main_mp_bwh;
   tx1:=vid_vhw+menu_main_mp_bwh;
   ty0:=menu_logo_h+menu_main_mp_bh1;
   ty1:=ty0+menu_main_mp_bh1;
   i  :=(vid_vh-ty0) div 8;   }

   {tx2:=(800 div 4)-4;
   tx1:=(vid_vw-(tx2*4)) div 5;
   tx0:=tx1;

   ty2:=(vid_vh-600) div 2;
   ty0:=vid_vh-menu_main_mp_bh1h-(ty2 div 4);
   ty1:=ty0+menu_main_mp_bh1; }
   //

   //ms_BottomButtons4(mi_back     ,mi_Settings,mi_AboutGame,mi_exit);


   {if(menu_page=mp_campaings)
   or(menu_page=mp_scirmish )
   then SetItem(mi_start      ,tx0,ty0,tx0+tx2,ty1,true )
   else SetItem(mi_StartGame  ,tx0,ty0,tx0+tx2,ty1,true ); tx0+=tx1+tx2;

   SetItem(mi_Settings        ,tx0,ty0,tx0+tx2,ty1,true ); tx0+=tx1+tx2;
   SetItem(mi_AboutGame       ,tx0,ty0,tx0+tx2,ty1,true ); tx0+=tx1+tx2;

   if(menu_page=mp_campaings)
   or(menu_page=mp_scirmish )
   then SetItem(mi_back       ,tx0,ty0,tx0+tx2,ty1,true )
   else SetItem(mi_exit       ,tx0,ty0,tx0+tx2,ty1,true ); }


   {case menu_page of
mp_main        : begin




                    ty0+=i;ty1+=i;
                    SetItem(mi_back      ,tx0,ty0,tx1,ty1,true );
                    end
                    else SetItem(mi_exit ,tx0,ty0,tx1,ty1,true );
                 end;
mp_campaings   : begin
                    SetItem(mi_title_campaings ,vid_vhw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
                                                vid_vhw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
                 end;
mp_scirmish    : begin
                    ty2:=(vid_vh-600) div 2;
                    ty0:=ty2 div 2;
                    SetItem(mi_title_scirmish  ,vid_vhw-menu_main_mp_bwh,menu_logo_h+ty0,
                                                vid_vhw+menu_main_mp_bwh,menu_logo_h+ty0+menu_main_mp_bh1,true );


                 end;
mp_loadgame    : begin
                    SetItem(mi_title_loadgame  ,vid_vhw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
                                                vid_vhw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
                 end;
mp_SaveGame    : begin
                    SetItem(mi_title_savegame  ,vid_vhw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
                                                vid_vhw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
                 end;
mp_loadreplay  : begin
                    SetItem(mi_title_loadreplay,vid_vhw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
                                                vid_vhw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
                 end;
mp_settings    : begin

                 end;
mp_aboutgame   : begin
                    SetItem(mi_title_aboutgame ,vid_vhw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
                                                vid_vhw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
                 end;


   end; }

   // main buttons
   {

   if(G_Started)
   then SetItem(mi_back,ui_menu_mbutton_lx0,ui_menu_mbutton_y0,ui_menu_mbutton_lx1,ui_menu_mbutton_y1,true)
   else SetItem(mi_exit,ui_menu_mbutton_lx0,ui_menu_mbutton_y0,ui_menu_mbutton_lx1,ui_menu_mbutton_y1,true);

   //enable:=(net_status<>ns_client)and(G_Started or PlayersReadyStatus);
   if(not G_Started)then
   begin
      if(PlayerClient=PlayerLobby)or(PlayerLobby=0)
      then SetItem(mi_start    ,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,GameStart(PlayerClient,true));
      //else SetItem(mi_EndSurrender,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,false             );
   end
   else
     if(PlayerSpecialDefeat(PlayerClient,true,true))
     then SetItem(mi_EndSurrender,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,true)
     else SetItem(mi_EndLeave    ,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,GameBreak(PlayerClient,true));

   {  if(net_status=ns_single)
     then SetItem(mi_EndLeave    ,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,net_status<>ns_client)
     else SetItem(mi_EndSurrender,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,true);}



   // settings block

   tx0:=ui_menu_ssr_zx0;
   ty0:=ui_menu_ssr_zy0;

   SetItem(mi_tab_settings,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);
   tx0+=ui_menu_ssr_cw;
   SetItem(mi_tab_saveload,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(net_status=ns_single)and(rpls_state<rpls_state_read));
   tx0+=ui_menu_ssr_cw;
   SetItem(mi_tab_replays ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(net_status=ns_single));

   tx0:=ui_menu_ssr_zx0;
   ty0+=ui_menu_ssr_lh;
   case menu_s1 of
ms1_sett: begin
             SetItem(mi_settings_game ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_settings_video,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_settings_sound,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);

             ty0+=ui_menu_ssr_lh;
             ty1:=0;
             while(ty0<ui_menu_ssr_zy1)do
             begin
                case menu_s3 of
                ms3_game : SetItem(mi_settings_ColoredShadows+ty1,ui_menu_ssr_zx0,ty0,ui_menu_ssr_zx1,ty0+ui_menu_ssr_lh,true);
                ms3_vido : SetItem(mi_settings_video1        +ty1,ui_menu_ssr_zx0,ty0,ui_menu_ssr_zx1,ty0+ui_menu_ssr_lh,true);
                ms3_sond : SetItem(mi_settings_sound1        +ty1,ui_menu_ssr_zx0,ty0,ui_menu_ssr_zx1,ty0+ui_menu_ssr_lh,true);
                end;

                ty0+=ui_menu_ssr_lh;
                ty1+=1;
             end;

             menu_items[mi_settings_PlayerName].mi_enabled:=(net_status=ns_single)and(not G_Started);
             menu_items[mi_settings_ResApply  ].mi_enabled:=(menu_res_w<>vid_vw)or(menu_res_h<>vid_vh);
          end;
ms1_svld: begin
             tx0:=ui_menu_ssr_zx0;
             ty0:=ui_menu_ssr_zy0+ui_menu_ssr_lh*12;

             SetItem(mi_saveload_save  ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(G_Started)and(length(svld_str_fname)>0));
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_saveload_load  ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(svld_list_size>0)and(0<=svld_list_sel)and(svld_list_sel<svld_list_size));
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_saveload_delete,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(svld_list_size>0)and(0<=svld_list_sel)and(svld_list_sel<svld_list_size));

             ty0:=ui_menu_ssr_zy0+ui_menu_ssr_lh*11;
             SetItem(mi_saveload_fname ,ui_menu_ssr_zx0,ty0,ui_menu_ssr_cx,ty0+ui_menu_ssr_lh,G_Started);

             SetItem(mi_saveload_list  ,ui_menu_ssr_zx0,ui_menu_ssr_zy0+ui_menu_ssr_lh*1,ui_menu_ssr_cx,ui_menu_ssr_zy0+ui_menu_ssr_lh*11,svld_list_size>0);
          end;
ms1_reps: begin
             tx0:=ui_menu_ssr_zx0;
             ty0:=ui_menu_ssr_zy0+ui_menu_ssr_lh*12;

             enable:=(not G_Started)and(rpls_list_size>0)and(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size);

             SetItem(mi_replays_play  ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,enable);
             tx0+=ui_menu_ssr_cw*2;
             SetItem(mi_replays_delete,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,enable);

             SetItem(mi_replays_list  ,ui_menu_ssr_zx0,ui_menu_ssr_zy0+ui_menu_ssr_lh*1,ui_menu_ssr_cx,ui_menu_ssr_zy0+ui_menu_ssr_lh*12,(rpls_list_size>0)and(rpls_state<rpls_state_read));
          end;
   end;




   // campaing scirmish game multiplayer
   tx0:=ui_menu_cgm_zx0;
   ty0:=ui_menu_cgm_zy0;

   SetItem(mi_tab_campaing   ,tx0,ty0,tx0+ui_menu_cgm_cw,ty0+ui_menu_cgm_lh,false and(not g_started)and(net_status=ns_single));
   tx0+=ui_menu_cgm_cw;
   SetItem(mi_tab_game       ,tx0,ty0,tx0+ui_menu_cgm_cw,ty0+ui_menu_cgm_lh,(menu_s2<>ms2_camp)or(not g_started));
   tx0+=ui_menu_cgm_cw;
   SetItem(mi_tab_multiplayer,tx0,ty0,tx0+ui_menu_cgm_cw,ty0+ui_menu_cgm_lh,(menu_s2<>ms2_camp)or(not g_started));

   case menu_s2 of
ms2_camp: begin
          end;
ms2_game: begin
             ty0+=ui_menu_cgm_lh;
             ty1:=0;
             while(ty0<ui_menu_cgm_zy1)do
             begin
                SetItem(mi_game_GameCaption+ty1,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,true);

                ty0+=ui_menu_cgm_lh;
                ty1+=1;
             end;

             menu_items[mi_game_mode         ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_gamemode    ,0,true);
             menu_items[mi_game_builders     ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_builders    ,0,true);
             menu_items[mi_game_generators   ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_generators  ,0,true);
             menu_items[mi_game_FixStarts    ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_FixStarts   ,0,true);
             menu_items[mi_game_DeadPbserver ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_DeadPObs,0,true);
             menu_items[mi_game_EmptySlots   ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_EmptySlots  ,0,true);

             menu_items[mi_settings_RecordStatus ].mi_enabled:=rpls_state<rpls_state_read;
             menu_items[mi_settings_RecordName   ].mi_enabled:=rpls_state=rpls_state_none;
             menu_items[mi_settings_RecordQuality].mi_enabled:=true;
          end;
ms2_mult: begin
             ty0+=ui_menu_cgm_lh;
{
mi_mplay_Chat           : ;
}
          end;
   end;

   {
   if(ui_menu_ssr_zx0<mouse_x)and(mouse_x<ui_menu_ssr_zx1)and(ui_menu_ssr_zy0<mouse_y)and(mouse_y<ui_menu_ssr_zy1)then
   begin
      // SETTINGS
      // 3 4 5
      // 6 ...14
      // 15...23
      // 24...32
      // 33...35
      menu_item:=(mouse_y-ui_menu_ssr_zy0) div ui_menu_ssr_ys;
      if(menu_item=0)then
      begin
         menu_item:=3+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs);

         case menu_item of
         4: if not ((net_status=ns_single)and(rpls_state<rpls_state_read))then menu_item:=0;
         5: if (net_status<>ns_single)then menu_item:=0;
         end;
      end
      else
      begin
         if(menu_s1=ms1_sett)then
         begin
            if(menu_item=1)
            then menu_item:=33+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs)
            else
              case menu_s3 of
              ms3_game: menu_item:=4 +menu_item;
              ms3_vido: menu_item:=13+menu_item;
              ms3_sond: menu_item:=22+menu_item;
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
                then menu_item:=38+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs)
                else menu_item:=0;
         end;
         if(menu_s1=ms1_reps)then  // 41..44
         begin
            if(menu_item in [1..9])and(mouse_x<ui_menu_ssl_x0)then menu_item:=41
            else
              if(menu_item=10)
              then menu_item:=42+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs)
              else menu_item:=0;
         end;
      end;
   end;

   if(G_Started=false)then
   begin
      if(net_status<ns_client)then
      begin
         // MAP
         if(menu_s2<>ms2_camp)then
          if(ui_menu_map_rx0<mouse_x)and(mouse_x<ui_menu_map_rx1)and(ui_menu_map_y0 <mouse_y)and(mouse_y<ui_menu_map_y1)then
           menu_item:=50+((mouse_y-ui_menu_map_y0) div ui_menu_map_ys);
      end;

      // PLAYERS
      if(menu_s2<>ms2_camp)and(not net_svsearch)then
      if(ui_menu_pls_zy0<mouse_y)and(mouse_y<ui_menu_pls_zy1)then
      begin
         if(ui_menu_pls_zxn<mouse_x)and(mouse_x<ui_menu_pls_zxs)then menu_item:=60;
         if(ui_menu_pls_zxs<mouse_x)and(mouse_x<ui_menu_pls_zxr)then menu_item:=61;
         if(ui_menu_pls_zxr<mouse_x)and(mouse_x<ui_menu_pls_zxt)then menu_item:=62;
         if(ui_menu_pls_zxt<mouse_x)and(mouse_x<ui_menu_pls_zxc)then menu_item:=63;
      end;

      //Net Search
      if(net_status=ns_client)and(net_svsearch)then
      if (ui_menu_pls_zx0<mouse_x)and(mouse_x<ui_menu_pls_zx1)then
      begin
         if(ui_menu_pls_zy0<mouse_y)and(mouse_y<ui_menu_pls_ye)then menu_item:=102;
         if(ui_menu_pls_ye<mouse_y)and(mouse_y<ui_menu_pls_zy1)then menu_item:=103;
      end;
   end;

   if(ui_menu_csm_x0<mouse_x)and(mouse_x<ui_menu_csm_x1)and(ui_menu_csm_y0<mouse_y)and(mouse_y<ui_menu_csm_y1)then
   begin
      menu_item:=(mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys;
      if(menu_item=0)
      then menu_item:=70+((mouse_x-ui_menu_csm_x0) div ui_menu_csm_xs)
      else
      begin
         if(menu_s2=ms2_game)then
         begin
            menu_item:=72+menu_item;  // 73..84
            if(menu_item=83)and(mouse_x<ui_menu_csm_xc)then menu_item:=0;
         end;
         if(menu_s2=ms2_mult)then
         begin
            menu_item:=84+menu_item;  // 85..96
            if(m_chat)and(menu_item<>96)then menu_item:=100;
            if(menu_item=92)then
              if(mouse_x>ui_menu_csm_x3)then menu_item:=101;
         end;
         if(menu_s2=ms2_camp)then
          if(menu_item=1)
          then menu_item:=97
          else menu_item:=98;
      end;
   end;    }
              }

              {
              menu_items[mi_settings_RecordStatus ].mi_enabled:=rpls_state<rpls_state_read;
              menu_items[mi_settings_RecordName   ].mi_enabled:=rpls_state=rpls_state_none;
              menu_items[mi_settings_RecordQuality].mi_enabled:=true;

              mi_settings_RecordCaption     = 168;
              mi_settings_RecordStatus      = 169;
              mi_settings_RecordName        = 170;
              mi_settings_RecordQuality     = 171;
              }

   if(menu_list_n>0)then
    with menu_items[menu_item] do
     if(not mi_enabled)then menu_List_Clear;
end;

function StringApplyInput(s:shortstring;charset:TSoc;ms:byte;ChangedResult:pBoolean):shortstring;
var i:byte;
    c:char;
begin
   StringApplyInput:=s;
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
          if(c in charset)then s+=c;
   end;
   k_keyboard_string:='';
   if(ChangedResult<>nil)then
     ChangedResult^:=StringApplyInput<>s;
   StringApplyInput:=s;
end;

function menu_UnderCursor(mi:byte):boolean;
begin
   menu_UnderCursor:=false;
   with menu_items[mi] do
     menu_UnderCursor:=(mi_enabled)and(mi_x0<=mouse_x)and(mouse_x<=mi_x1)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1);
end;

procedure menu_SelectItem;
var i:byte;
begin
   menu_item:=0;
   for i:=255 downto 1 do
     with menu_items[i] do
       if(mi_enabled)and(mi_x0<=mouse_x)and(mouse_x<=mi_x1)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1)then
       begin
          menu_item:=i;
          break;
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//  MENU LIST

procedure menu_list_SelectItem;
var x,y:integer;
begin
   x:=menu_list_x-menu_list_w;
   y:=menu_list_y;
   mouse_x-=x;
   mouse_y-=y;
   if(0<=mouse_x)and(mouse_x<=menu_list_w)and(0<=mouse_y)then menu_list_selected:=mouse_y div menu_list_item_H;
   if(menu_list_selected>=menu_list_n)
   or(menu_list_selected< 0)
   then menu_list_selected:=-1;
   if(not menu_list_items[menu_list_selected].mli_enabled)
   then menu_list_selected:=-1;
   mouse_x+=x;
   mouse_y+=y;
end;

procedure menu_list_SetCommonSettings(mi:byte;MinWidth:pinteger);
begin
   with menu_items[mi] do
   begin
      if(MinWidth=nil)
      then menu_list_w:=abs(mi_x1-mi_x0)
      else
      begin
         if(MinWidth^<0)then MinWidth^:=(mi_x1-mi_x0) div abs(MinWidth^);
         menu_list_w:=0;
      end;
      menu_list_x      :=mi_x1;
      menu_list_y      :=mi_y1;
      menu_list_item_h :=abs(mi_y1-mi_y0);
      menu_list_item_hh:=menu_list_item_h div 2;
      if(menu_list_item_hh>=basefont_w1h)
      then menu_list_font:=15
      else menu_list_font:=10;
   end;
   menu_list_n:=0;
   setlength(menu_list_items,menu_list_n);
end;
procedure menu_list_UpdatePosition;
var ty:integer;
begin
   ty:=menu_list_y+menu_list_n*menu_list_item_h;
   if(ty>vid_vh)then menu_list_y-=menu_list_item_h+(menu_list_n*menu_list_item_h);
end;

procedure menu_list_AddItem(acaption:shortstring;avalue:integer;aenabled:boolean;MinWidth:integer);
begin
   menu_list_n+=1;
   setlength(menu_list_items,menu_list_n);
   with menu_list_items[menu_list_n-1] do
   begin
      mli_caption:=acaption;
      mli_value  :=avalue;
      mli_enabled:=aenabled;
   end;
   menu_list_w:=max3i(MinWidth,menu_list_w,basefont_w1*length(acaption)+basefont_w1);
end;

//-----------------------------------------------------

procedure menu_list_MakeFromStr(mi:byte;pfstring:pshortstring;size,CurrVal,MinWidth:integer);
var n:integer;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=CurrVal;
      n:=size div SizeOf(shortstring);
      writeln(n);
      while(n>0)do
      begin
         menu_list_AddItem(pfstring^,menu_list_n,true,MinWidth);
         pfstring+=1;
         n-=1;
      end;
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeFromInts(mi:byte;maxI,minI,StepI,CurrVal,MinWidth:integer);
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      if(minI>maxI)then exit;
      while(minI<=maxI)do
      begin
         if(CurrVal=minI)then menu_list_current:=menu_list_n;
         menu_list_AddItem(i2s(minI),menu_list_n,menu_list_current<>menu_list_n,MinWidth);
         minI+=StepI;
      end;
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeFromIntAr(mi:byte;pfint:pinteger;size,CurrVal,MinWidth:integer);
var n:integer;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      n:=size div SizeOf(integer);
      while(n>0)do
      begin
         if(pfint^=CurrVal)then menu_list_current:=menu_list_n;
         menu_list_AddItem(i2s(pfint^),menu_list_n,menu_list_current<>menu_list_n,MinWidth);
         pfint+=1;
         n-=1;
      end;
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakePlayerSlot(mi:byte;PlayerTarget:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      for i:=0 to ps_states_n-1 do
        if(PlayerSlotChangeState(PlayerClient,PlayerTarget,i,true))then
        begin
           if(g_slot_state[PlayerTarget]=i)then
             menu_list_current:=menu_list_n;
           menu_list_AddItem(str_menu_PlayerSlots[i],i,true,MinWidth);
        end;
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakePlayerTeam(mi:byte;PlayerTarget:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      for i:=0 to MaxPlayers do
        if(PlayerSlotChangeTeam(PlayerClient,PlayerTarget,i,true))then
        begin
           with g_players[PlayerTarget] do
             if(team=i)then
               menu_list_current:=menu_list_n;
           menu_list_AddItem(str_teams[i],i,true,MinWidth);
        end;
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeAISlots(mi:byte;CurVal,MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=CurVal;
      menu_list_AddItem(str_ps_none,0,true,MinWidth);
      for i:=pss_AI_1 to pss_AI_11 do
        menu_list_AddItem(str_menu_PlayerSlots[i],i-pss_AI_1+1,true,MinWidth);
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeGamePresets(mi:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=g_preset_cur;
      if(g_preset_n>0)then
       for i:=0 to g_preset_n-1 do
         menu_list_AddItem(g_presets[i].gp_name,i,true,MinWidth);
   end;
   menu_list_UpdatePosition;
end;

////////////////////////////////////////////////////////////////////////////////
//  MENU BASE

function menu_GetBarVal(mi:byte;cur,min,max:integer):integer;
var tx0,tx1:integer;
begin
   menu_GetBarVal:=cur;
   with menu_items[mi] do
   begin
      tx1:=mi_x1-basefont_w2;
      tx0:=tx1-max;

      if(mi_y0<mouse_y)and(mouse_y<mi_y1)then
        if((tx0-basefont_w2)<mouse_x)and(mouse_x<mi_x1)then
          if(mouse_x<tx0)
          then menu_GetBarVal:=max2i(min,cur-1)
          else
            if(tx1<mouse_x)
            then menu_GetBarVal:=min2i(cur+1,max)
            else menu_GetBarVal:=mm3i(min,mouse_x-tx0,max);
   end;
end;
procedure menu_item_ListLine(mi:byte;svar:pinteger;scroll,lineh:integer);
begin
   with menu_items[mi] do
   begin
      if (mi_x0<mouse_x)and(mouse_x<mi_x1)
      and(mi_y0<mouse_y)and(mouse_y<mi_y1)
      then svar^:=scroll+((mouse_y-mi_y0) div lineh);
   end;
end;


procedure menu_mouse;
var
UpdateItems:boolean;
menu_list_SIndex,
p          :integer;
begin
   menu_list_selected:=-1;
   if(menu_list_n>0)then
   begin
      menu_list_SelectItem;
      if(ks_mleft=1)and(menu_list_selected=-1)
      then menu_List_Clear
   end
   else
     if(ks_mleft=1)then
     begin
        case menu_item of
mi_mplay_ClientAddress : net_cl_saddr;
mi_settings_PlayerName : begin
                         if(length(PlayerName)=0)then PlayerName:=str_defaultPlayerName;
                         g_players[PlayerClient].name:=PlayerName;
                         end;
        end;
        menu_SelectItem;
        menu_remake:=true;
        SoundPlayUI(snd_click);
     end;

   if(ks_mleft=1)then        // left button pressed
   begin
      UpdateItems:=true;

      if(-1<menu_list_selected)and(menu_list_selected<menu_list_n)
      then menu_list_SIndex:=menu_list_items[menu_list_selected].mli_value;

      case menu_item of
mi_exit                   : GameCycle:=false;
mi_back                   : menu_Toggle;

mi_start                  : if(net_status=ns_client)
                            then net_send_byte(nmid_start)
                            else GameStart(PlayerClient,false);

mi_StartGame              : if(menu_list_selected>-1)then
                            begin
                               menu_page1:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else
                            begin
                               menu_list_SetCommonSettings(menu_item,nil);
                               menu_list_current:=-1;
                               menu_list_AddItem(str_menu_campaings ,mp_campaings ,false,0);
                               menu_list_AddItem(str_menu_scirmish  ,mp_scirmish  ,true ,0);
                               menu_list_AddItem(str_menu_loadreplay,mp_loadreplay,true ,0);
                               menu_list_AddItem(str_menu_loadgame  ,mp_loadgame  ,true ,0);
                               menu_list_UpdatePosition;
                            end;
mi_SaveLoad               : if(menu_list_selected>-1)then
                            begin
                               menu_page2:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else
                            begin
                               menu_list_SetCommonSettings(menu_item,nil);
                               menu_list_current:=-1;
                               menu_list_AddItem(str_menu_savegame,mp_SaveGame,g_started,0);
                               menu_list_AddItem(str_menu_loadgame,mp_LoadGame,true     ,0);
                               menu_list_UpdatePosition;
                            end;
mi_EndGame                : if(menu_list_selected>-1)then
                            begin
                               case menu_list_SIndex of
                               mi_EndLeave     : GameBreak(PlayerClient,false);
                               mi_EndSurrender : if(net_status=ns_client)
                                                 then net_send_byte(nmid_surrender)
                                                 else PlayerSurrender(PlayerClient,false);
                               end;
                               menu_List_Clear;
                            end
                            else
                            begin
                               menu_list_SetCommonSettings(menu_item,nil);
                               menu_list_current:=-1;
                               menu_list_AddItem(str_menu_LeaveGame,mi_EndLeave    ,GameBreak      (PlayerClient,true ),0);
                               menu_list_AddItem(str_menu_Surrender,mi_EndSurrender,PlayerSurrender(PlayerClient,true ),0);
                               menu_list_UpdatePosition;
                            end;

mi_Settings               : begin
                            menu_page2:=mp_settings;
                            menu_res_w:=vid_vw;
                            menu_res_h:=vid_vh;
                            end;
mi_AboutGame              : menu_page2:=mp_aboutgame;

mi_settings_video         : begin
                            menu_res_w:=vid_vw;
                            menu_res_h:=vid_vh;
                            menu_settings_page:=menu_item;
                            end;
mi_settings_game,
mi_settings_record,
mi_settings_network,
mi_settings_sound         : menu_settings_page:=menu_item;

//////////////////////////////////////////    SETTINGS  GAME
mi_settings_ColoredShadows: vid_ColoredShadow:=not vid_ColoredShadow;
mi_settings_ShowAPM       : vid_APM:=not vid_APM;
mi_settings_HitBars       : if(menu_list_selected>-1)
                            then begin vid_uhbars:=menu_list_SIndex;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_menu_unitHBarl[0],SizeOf(str_menu_unitHBarl),vid_uhbars,-2);
mi_settings_MRBAction     : if(menu_list_selected>-1)
                            then begin m_action:=menu_list_SIndex>0;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_menu_mactionl[false],SizeOf(str_menu_mactionl),integer(m_action),-2);
mi_settings_ScrollSpeed   : vid_CamSpeed  :=menu_GetBarVal(menu_item,vid_CamSpeed,1,max_CamSpeed);
mi_settings_MouseScroll   : vid_CamMScroll:=not vid_CamMScroll;
mi_settings_PlayerName    : ;   // playername
mi_settings_Langugage     : if(menu_list_selected>-1)then
                            begin
                               ui_language:=menu_list_SIndex>0;
                               menu_List_Clear;
                               SwitchLanguage;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_lang[false],SizeOf(str_menu_lang),integer(ui_language),-3);
mi_settings_PanelPosition : if(menu_list_selected>-1)then
                            begin
                               vid_PannelPos:=menu_list_SIndex;
                               menu_List_Clear;
                               vid_ScreenSurfaces;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_PanelPosl[0],SizeOf(str_menu_PanelPosl),integer(vid_PannelPos),-2);
mi_settings_PlayerColors  : if(menu_list_selected>-1)
                            then begin vid_plcolors:=menu_list_SIndex;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_menu_PlayersColorl[0],SizeOf(str_menu_PlayersColorl),integer(vid_plcolors),-2);

//////////////////////////////////////////    SETTINGS  RECORD
mi_settings_RecordStatus  : if(rpls_state=rpls_state_none)
                            then rpls_state:=rpls_state_write
                            else rpls_state:=rpls_state_none;
mi_settings_RecordName    : ;
mi_settings_RecordQuality : if(menu_list_selected>-1)then
                            begin
                               rpls_pnui:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_NetQuality[0],SizeOf(str_menu_NetQuality[0])*(cl_UpT_arrayN_RPLs+1),integer(rpls_pnui),-3);

//////////////////////////////////////////    SETTINGS  VIDEO
mi_settings_ResWidth      : if(menu_list_selected>-1)
                            then begin menu_res_w:=vid_rw_list[menu_list_SIndex];menu_List_Clear;end
                            else menu_list_MakeFromIntAr(menu_item,@vid_rw_list[0],SizeOf(vid_rw_list),menu_res_w,-3);
mi_settings_ResHeight     : if(menu_list_selected>-1)
                            then begin menu_res_h:=vid_rh_list[menu_list_SIndex];menu_List_Clear;end
                            else menu_list_MakeFromIntAr(menu_item,@vid_rh_list[0],SizeOf(vid_rh_list),menu_res_h,-3);
mi_settings_ResApply      : begin
                            vid_vw:=menu_res_w;
                            vid_vh:=menu_res_h;
                            vid_MakeScreen;
                            end;

mi_settings_Fullscreen    : begin vid_fullscreen:=not vid_fullscreen; vid_MakeScreen;end;
mi_settings_ShowFPS       : vid_FPS:=not vid_FPS;

//////////////////////////////////////////    SETTINGS  SOUND
mi_settings_SoundVol      : begin
                            snd_svolume1:=menu_GetBarVal(menu_item,round(snd_svolume1*max_SoundVolume),0,max_SoundVolume)/max_SoundVolume;
                            SoundSourceUpdateGainAll;
                            end;
mi_settings_MusicVol      : begin
                            snd_mvolume1:=menu_GetBarVal(menu_item,round(snd_mvolume1*max_SoundVolume),0,max_SoundVolume)/max_SoundVolume;
                            SoundSourceUpdateGainAll;
                            end;
mi_settings_NextTrack     : SoundMusicControll(true);


//////////////////////////////////////////    SCIRMISH PLAYERS
mi_player_status1,
mi_player_status2,
mi_player_status3,
mi_player_status4,
mi_player_status5,
mi_player_status6         : begin
                               p:=menu_item-mi_player_status1+1;
                               if(menu_list_selected>-1)then
                               begin
                                  if(PlayerSlotChangeState(PlayerClient,p,menu_list_SIndex,true))then
                                    if(net_status=ns_client)
                                    then net_send_PlayerSlot(p,menu_list_SIndex)
                                    else PlayerSlotChangeState(PlayerClient,p,menu_list_SIndex,false);
                                  menu_List_Clear;
                               end
                               else menu_list_MakePlayerSlot(menu_item,p,-1);
                            end;
mi_player_race1,
mi_player_race2,
mi_player_race3,
mi_player_race4,
mi_player_race5,
mi_player_race6           : begin
                               p:=menu_item-mi_player_race1+1;
                               if(menu_list_selected>-1)then
                               begin
                                  if(PlayerSlotChangeRace(PlayerClient,p,menu_list_SIndex,true))then
                                    if(net_status=ns_client)
                                    then net_send_PlayerRace(p,menu_list_SIndex)
                                    else PlayerSlotChangeRace(PlayerClient,p,menu_list_SIndex,false);
                                  menu_List_Clear;
                               end
                               else menu_list_MakeFromStr(menu_item,@str_racel[0],SizeOf(str_racel),g_players[p].slot_race,-1);
                            end;
mi_player_team1,
mi_player_team2,
mi_player_team3,
mi_player_team4,
mi_player_team5,
mi_player_team6           : begin
                               p:=menu_item-mi_player_team1+1;
                               if(menu_list_selected>-1)then
                               begin
                                  if(PlayerSlotChangeTeam(PlayerClient,p,menu_list_SIndex,true))then
                                    if(net_status=ns_client)
                                    then net_send_PlayerTeam(p,menu_list_SIndex)
                                    else PlayerSlotChangeTeam(PlayerClient,p,menu_list_SIndex,false);
                                  menu_List_Clear;
                               end
                               else menu_list_MakePlayerTeam(menu_item,p,-1);
                            end;
//////////////////////////////////////////    SCIRMISH MAP
mi_map_Preset             : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(nmid_lobbby_preset,byte(menu_list_selected))
                               else GameLoadPreset(PlayerClient,byte(menu_list_selected),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeGamePresets(menu_item,-2);
mi_map_Seed               : ;// seed;
mi_map_Size               : if(menu_list_selected>-1)then
                            begin
                               p:=MinMapSize+(StepMapSize*menu_list_SIndex);
                               if(net_status=ns_client)
                               then net_send_MIDInt(             nmid_lobbby_mapsize,p)
                               else map_SetSetting (PlayerClient,nmid_lobbby_mapsize,p,false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromInts(menu_item,MaxMapSize,MinMapSize,StepMapSize,map_size,-2);
mi_map_Type               : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_lobbby_type,byte(menu_list_selected))
                               else map_SetSetting  (PlayerClient,nmid_lobbby_type,byte(menu_list_selected),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_typel[0],SizeOf(str_map_typel),map_type,-2);
mi_map_Sym                : if(menu_list_selected>-1)then
                            begin
                               menu_List_Clear;
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_lobbby_symmetry,byte(menu_list_selected))
                               else map_SetSetting  (PlayerClient,nmid_lobbby_symmetry,byte(menu_list_selected),false);
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_syml[0],SizeOf(str_map_syml),map_symmetry,-2);
mi_map_Random             : begin
                               Map_randommap;
                               Map_premap;
                            end;
//////////////////////////////////////////    GAME SETTINGS
mi_game_mode              : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_gamemode,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_gamemode,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_emnu_GameModel[0],SizeOf(str_emnu_GameModel),integer(g_mode),-2);
mi_game_builders          : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_builders,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_builders,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromInts(menu_item,gms_g_startb+1,1,1,integer(g_start_base)+1,-4);

mi_game_generators        : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_generators,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_generators,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_Generatorsl[0],SizeOf(str_menu_Generatorsl),integer(g_generators),-2);
mi_game_FixStarts         : if(net_status=ns_client)
                            then net_send_MIDByte    (             nmid_lobbby_FixStarts   ,byte(not g_fixed_positions))
                            else GameSetCommonSetting(PlayerClient,nmid_lobbby_FixStarts   ,byte(not g_fixed_positions),false);
mi_game_DeadPbserver      : if(net_status=ns_client)
                            then net_send_MIDByte    (             nmid_lobbby_DeadPObs,byte(not g_deadobservers))
                            else GameSetCommonSetting(PlayerClient,nmid_lobbby_DeadPObs,byte(not g_deadobservers),false);
mi_game_EmptySlots        : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_EmptySlots,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_EmptySlots,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeAISlots(menu_item,integer(g_ai_slots),-2);
mi_game_RandomSkrimish    : MakeRandomSkirmish(false);


//////////////////////////////////////////    MULTIPLAYER

mi_mplay_ServerPort       : ;
mi_mplay_ServerStart      : if(net_status=ns_single)then
                            begin
                               net_sv_sport;
                               if(net_UpSocket(net_port))then
                               begin
                                  PlayersSetDefault;
                                  net_status:=ns_server;
                               end
                               else net_dispose;
                            end;
mi_mplay_ServerStop       : menu_ServerStop;

mi_mplay_ClientConnect    : if(net_status=ns_single)then
                              if(net_UpSocket(0))then
                              begin
                                 net_status_str:=str_menu_connecting;
                                 net_status    :=ns_client;
                                 net_cl_saddr;
                                 rpls_pnu:=0;
                                 PlayerLobby:=254;
                              end
                              else net_dispose;
mi_mplay_ClientDisconnect : if(net_status=ns_client)
                            then GameBreakClientGame;
mi_settings_ClientQuality : if(menu_list_selected>-1)then
                            begin
                               net_pnui:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_NetQuality[0],SizeOf(str_menu_NetQuality),integer(net_pnui),-3);

mi_mplay_ClientAddress    : ;
mi_mplay_Chat             : ;

mi_mplay_NetSearchStart   : if(net_UpSocket(net_svlsearch_port))then
                            begin
                               net_status_str:='';
                               net_status  :=ns_client;
                               net_svsearch:=true;
                               SetLength(net_svsearch_list,0);
                               net_svsearch_listn :=0;
                               net_svsearch_scroll:=0;
                               net_svsearch_sel   :=0;
                            end
                            else net_dispose;
mi_mplay_NetSearchStop    : menu_NetSearchStop;
mi_mplay_NetSearchList    : if(mleft_dbl_click>0)
                            then menu_NetSearchConnect(false)
                            else menu_item_ListLine(menu_item,@net_svsearch_sel,net_svsearch_scroll,menu_netsearch_lineh);
mi_mplay_NetSearchCon     : menu_NetSearchConnect(false);

      end;



      {
                 = 1;
                  = 2;

      mi_EndSurrender           = 8;
      mi_back                = 9;
      mi_exit                = 10;

      case menu_item of

mi_start                  : if(net_status=ns_client)
                            then net_send_byte(nmid_start)
                            else GameStart(PlayerClient,false);




//////////////////////////////////////////    TABS
mi_tab_settings           :       menu_s1:=ms1_sett;
mi_tab_saveload           : begin menu_s1:=ms1_svld; saveload_MakeFolderList; end;
mi_tab_replays            : begin menu_s1:=ms1_reps; if(not G_Started)then replay_MakeFolderList; end;

//////////////////////////////////////////    SETTINGS TABS
mi_settings_game          : menu_s3:=ms3_game;
mi_settings_video         : begin
                            menu_s3:=ms3_vido;
                            menu_res_w:=vid_vw;
                            menu_res_h:=vid_vh;
                            end;
mi_settings_sound         : menu_s3:=ms3_sond;







//////////////////////////////////////////    SAVE LOAD

mi_saveload_save          : saveload_Save;
mi_saveload_load          : saveload_Load;
mi_saveload_delete        : saveload_Delete;
mi_saveload_list          : begin
                            menu_item_ListLine(menu_item,@svld_list_sel,svld_list_scroll,ui_menu_ssr_lh);
                            saveload_Select;
                            end;

//////////////////////////////////////////    REPLAYS PLAYER
mi_replays_list           : begin
                            menu_item_ListLine(menu_item,@rpls_list_sel,rpls_list_scroll,ui_menu_ssr_lh);
                            replay_Select;
                            end;
mi_replays_play           : begin
                               menu_s2:=ms2_game;
                               rpls_state:=rpls_state_read;
                               g_started:=true;
                            end;
mi_replays_delete         : replay_Delete;



//////////////////////////////////////////    campaings game multiplayer  tabs
mi_tab_campaing           : menu_s2:=ms2_camp;
mi_tab_game               : menu_s2:=ms2_game;
mi_tab_multiplayer        : menu_s2:=ms2_mult;




{

     /// SETTINGS SAVE REPLAYS
      11 : if not ((net_status=ns_single)and(G_Started=false))then menu_item:=0;


      // save load
      36 : if(svld_list_size>0)then
           begin
               svld_list_sel:=svld_list_scroll+((mouse_y-ui_menu_ssr_zy0-ui_menu_ssr_ys)div ui_menu_ssr_ys);
              saveload_Select;
           end;
      37 : if(G_Started=false)then menu_item:=0;
      38 : if(G_Started)and(svld_str_fname<>'')then
      39 : if(0<=svld_list_sel)and(svld_list_sel<svld_list_size)then ;
      40 : if(0<=svld_list_sel)and(svld_list_sel<svld_list_size)then ;

      // replays
      41 : if(rpls_list_size>0)and(rpls_state<rpls_state_read)then
           begin
              rpls_list_sel :=rpls_list_scroll+((mouse_y-ui_menu_ssr_zy0)div ui_menu_ssr_ys)-1;
              replay_Select;
           end;
      42 : if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)and(G_Started=false)then
           begin
              menu_s2:=ms2_game;
              rpls_state:=rpls_state_read;
              g_started:=true;
           end;
      43 : ;
      44 : if(rpls_list_size>0)and(rpls_list_sel<rpls_list_size)and(G_Started=false)then replay_Delete;


      // PLAYERS table
      60 : if(net_status<ns_client)then PlayerSwitchAILevel( ((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys) +1);
      61 : if(net_status<ns_client)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(p<>PlayerClient)then
               with g_players[p] do
                if (state<>pt_none)
                then PlayerSetState(p,pt_none)
                else
                begin
                   PlayerSetState(p,pt_ai);
                   if(team=0)then team:=p;
                end;
           end;
      62 : if(net_status<ns_client)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with g_players[p] do
               if(team>0)then
                if(state=pt_ai)or(p=PlayerClient)then
                begin
                   race+=1;
                   race:=race mod 3;
                   mrace:=race;
                end;
           end;
      63 : if(net_status<ns_client)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with g_players[p] do
               if(state=pt_ai)or(p=PlayerClient)then
                if(team<MaxPlayers)then team+=1;
           end;

      // CAMP SCIRMISH MULTIPLAY
      //70 : if not(G_Started)then menu_s2:=ms2_camp;
      71 : if not(G_Started and(menu_s2=ms2_camp))then begin p:=menu_s2;menu_s2:=ms2_game;if(p=ms2_camp)then Map_premap;end;
      72 : if not(G_Started and(menu_s2=ms2_camp))then begin menu_s2:=ms2_mult; if(m_chat)then menu_item:=100; end;



      //// multiplayer
      // server
      86 :
      87 : if(net_status<>ns_single)then menu_item:=0; // port

      // client
      91 :

      101:
      102: if(net_status=ns_client)and(not G_Started)and(net_svsearch)and(net_svsearch_listn>0)then
             net_svsearch_sel:=net_svsearch_scroll+((mouse_y-ui_menu_pls_zy0)div ui_menu_pls_ys3);
      103: if(net_status=ns_client)and(not G_Started)and(net_svsearch)and(net_svsearch_listn>0)then
           if(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn)then
           begin
              net_svsearch:=false;
              net_dispose;
              net_status :=ns_single;
              net_status_str:='';
              if(net_UpSocket(0))then
              begin
                 with net_svsearch_list[net_svsearch_sel] do net_cl_svstr:=c2ip(ip)+':'+w2s(swap(port));
                 net_cl_saddr;
                 net_status_str:=str_menu_connecting;
                 net_status :=ns_client;
                 net_cl_saddr;
                 rpls_pnu:=0;
                 menu_s1 :=ms1_sett;
              end
              else net_dispose;
           end;
      92 : if(net_status<>ns_single)then menu_item:=0; // addr
      93 : if(net_status<>ns_server)then ScrollByte(@net_pnui,true,0,cl_UpT_arrayN);
      94 : if(G_Started=false)and(net_status<>ns_server)then
            if(mouse_x<ui_menu_csm_x2)
            then ScrollByte(@PlayerTeam,true,0,MaxPlayers)
            else
              if(mouse_x<ui_menu_csm_x3)
              then begin if(PlayerTeam>0)then PlayerRace+=1; PlayerRace:=PlayerRace mod 3;end
              else PlayerReady:=not PlayerReady;
      96 : if(net_status<>ns_single)and(not net_svsearch)then
           begin
              m_chat:=not m_chat;
              if(m_chat)then menu_item:=100;
           end;

      // camps
      97 : ScrollByte(@campain_skill,true,0,6);
      98 : begin
              campain_mission_n:=_cmp_sm+((mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(campain_mission_n>=MaxMissions)then campain_mission_n:=MaxMissions-1;
           end; }
      else UpdateItems:=false;
      end;

      if(UpdateItems)then menu_remake:=true;
   end; }

   {if(ks_mright=1)then    // right button pressed
   begin
      case menu_item of
      // MAP
      51 : begin Map_randomseed;                                  Map_premap;end;
      52 : begin ScrollInt (@map_size      ,-StepMapSize,MinMapSize,MaxMapSize   );Map_premap;end;
      53 : begin ScrollByte(@map_type    ,false    ,0       ,gms_m_types);Map_premap;end;
      54 : begin ScrollByte(@map_symmetry,false    ,0       ,2          );Map_premap;end;

      60 : if(not net_svsearch)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(net_status=ns_client)
              then net_send_SwapSlot(p)
              else PlayersSwap(p,PlayerClient);
           end;
      63 : if(net_status<ns_client)and(not G_Started)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with g_players[p] do
               if(state=pt_ai)or(p=PlayerClient)then
                if(team>byte(state=pt_ai))then team-=1;
           end;

      74 : if(net_status<ns_client)and(not G_Started)then begin ScrollByteSet(@g_mode,false,@allgamemodes        );Map_premap;end;
      75 : if(net_status<ns_client)and(not G_Started)then       ScrollByte   (@g_start_base,false,0,gms_g_startb );
      77 : if(net_status<ns_client)and(not G_Started)then       ScrollByte   (@g_ai_slots  ,false,0,gms_g_maxai  );
      78 : if(net_status<ns_client)and(not G_Started)then begin ScrollByte   (@g_generators,false,0,gms_g_maxgens);Map_premap;end;

      80 : if(net_status<ns_client)and(not G_Started)then MakeRandomSkirmish(true);

      84 : ScrollByte(@rpls_pnui,false,0,9);

      93 : if(net_status<>ns_server)then ScrollByte(@net_pnui,false,0,9);
      94 : if(G_Started=false)and(net_status<>ns_server)then
            if(mouse_x<ui_menu_csm_x2)then ScrollByte(@PlayerTeam,false,0,MaxPlayers);

      97 : ScrollByte(@campain_skill,false,0,CMPMaxSkills);
      end; }
   end;
end;

procedure menu_keyborad;
var UpdateItems:boolean;
begin
   UpdateItems:=false;
   if(length(k_keyboard_string)>0)then
   begin
      case menu_item of
mi_map_Seed           : begin
                           map_seed  :=s2c(StringApplyInput(c2s(map_seed) ,k_kbdig ,10     ,@UpdateItems));
                           if(UpdateItems)then
                            if(net_status=ns_client)
                            then net_send_MIDCard(             nmid_lobbby_mapseed,map_seed)
                            else map_SetSetting  (PlayerClient,nmid_lobbby_mapseed,map_seed,false);
                        end;
mi_settings_PlayerName: PlayerName    :=StringApplyInput(PlayerName    ,k_pname ,PlayerNameLen,@UpdateItems);
//mi_saveload_fname     : svld_str_fname:=StringApplyInput(svld_str_fname,k_kbstr ,ReplayNameLen,@UpdateItems);
mi_settings_RecordName: rpls_str_name :=StringApplyInput(rpls_str_name ,k_kbstr ,ReplayNameLen,@UpdateItems);
mi_mplay_ServerPort   : begin
                        net_sv_pstr   :=StringApplyInput(net_sv_pstr   ,k_kbdig ,5      ,@UpdateItems);
                        net_sv_sport;
                        end;
mi_mplay_ClientAddress: net_cl_svstr  :=StringApplyInput(net_cl_svstr  ,k_kbaddr,21     ,@UpdateItems);
//mi_mplay_Chat         : net_chat_str  :=StringApplyInput(net_chat_str  ,k_kbstr ,255    ,@UpdateItems);
      else
      end;

      if(UpdateItems)then menu_remake:=true;
   end;
end;



