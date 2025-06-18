

////////////////////////////////////////////////////////////////////////////////
//  MENU COMMON


procedure menu_updatePos;
var cx,cy:single;
begin
   cx:=vid_vw/menu_w;
   cy:=vid_vh/menu_h;
   if(cx>cy)
   then menu_tex_cx:=cy
   else menu_tex_cx:=cx;

   menu_tex_w:=round(menu_w*menu_tex_cx);
   menu_tex_h:=round(menu_h*menu_tex_cx);
   menu_tex_cx:=1/menu_tex_cx;

   menu_tex_x:=(vid_vw-menu_tex_w) div 2;
   menu_tex_y:=(vid_vh-menu_tex_h) div 2;
end;

procedure vid_ApplyResolution;
begin
   SDL_RenderSetLogicalSize(vid_SDLRenderer,vid_vw,vid_vh);
   menu_updatePos;
   vid_UpdateFogGridSize;
   vid_UpdateCommonVars;
   if(not vid_fullscreen)then
   begin
      SDL_SetWindowSize(vid_SDLWindow,vid_vw,vid_vh);
      SDL_SetWindowPosition(vid_SDLWindow,SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED);
   end;
end;

function menu_List_Clear:boolean;
begin
   menu_List_Clear:=menu_list_n>0;
   menu_item  :=0;
   menu_list_n:=0;
   setlength(menu_list_items,0);
   menu_remake:=true;
end;

function menu_NetSearchStop:boolean;
begin
   menu_NetSearchStop:=false;
   if(net_status=ns_client)and(net_svsearch)then
   begin
      net_dispose;
      menu_NetSearchStop:=true;
      net_svsearch  :=false;
      net_status    :=ns_single;
      net_status_str:='';
   end;
end;
procedure menu_NetClientConnect;
begin
   if(net_setup(0))then
   begin
      txt_ValidateServerAddr;
      net_status_str:=str_menu_connecting;
      net_status    :=ns_client;
      rpls_pnu      :=0;
      PlayerLobby   :=255;
   end
   else net_dispose;
end;
function menu_NetSearchConnect(Check:boolean):boolean;
begin
   menu_NetSearchConnect:=false;
   if(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn)then
   begin
      menu_NetSearchConnect:=true;
      if(Check)then exit;
      net_svsearch  :=false;
      net_status    :=ns_single;
      net_status_str:='';
      net_dispose;
      menu_NetClientConnect;
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
      G_Started :=false;
      net_status:=ns_single;
   end;
end;

function menu_ApplyResolution(Check:boolean):boolean;
begin
   menu_ApplyResolution:=false;
   if(menu_vid_vw=vid_vw)and(menu_vid_vh=vid_vh)then exit;
   menu_ApplyResolution:=true;
   if(Check)then exit;
   vid_vw:=menu_vid_vw;
   vid_vh:=menu_vid_vh;
   vid_ApplyResolution;
end;

function menu_Escape(exitMenu:boolean):boolean;
begin
   menu_Escape:=false;
   menu_remake:=true;
   if(exitMenu)then
   begin
      while not menu_Escape(false) do ;
      exit;
   end;

   if(menu_List_Clear)
   then exit
   else
     if(menu_NetSearchStop)
     then exit
     else
       if(menu_page2>0)then
       begin
          menu_item :=0;
          menu_page2:=0;
          exit;
       end
       else
         if(not G_Started)then
         begin
            menu_Escape:=true;
            if(net_status>ns_single)then exit;
            if(menu_page1>mp_main)then
            begin
               menu_item  :=0;
               menu_page1 :=mp_main;
               menu_Escape:=false;
               exit;
            end;
            exit;
         end;

   menu_Escape:=true;
   menu_state :=false;

   if(net_status=ns_single)then
     if(g_Status<=LastPlayer)or(g_Status=gs_running)then
       if(menu_state)
       then g_Status:=PlayerClient
       else g_Status:=gs_running;
end;


procedure menu_ReBuild;
const mainBtnW  = (menu_w div 6)-4;
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
   if(p<=LastPlayer)then
     case g_slot_state[p] of
pss_opened   : with g_players[p] do NeedColumnRace:=((player_type=pt_none)and(g_ai_slots>0))or((player_type>pt_none)and(not isobserver));
pss_AI_1..
pss_AI_11    : NeedColumnRace:=true;
     end;
end;
function NeedColumnTeam(p:byte):boolean;
begin
   NeedColumnTeam:=false;
   if(p<=LastPlayer)then
     case g_slot_state[p] of
pss_opened   : with g_players[p] do NeedColumnTeam:=((player_type=pt_none)and(g_ai_slots>0))or(player_type>pt_none);
pss_observer,
pss_AI_1..
pss_AI_11    : NeedColumnTeam:=true;
     end;
end;
procedure mpage_DefaultCaption(mi:byte);
begin
   SetItem(mi,menu_hw-menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh1,
              menu_hw+menu_main_mp_bwh,menu_logo_h+menu_main_mp_bh2,true );
end;

procedure mpage_BottomButtons(N,mi1,mi2,mi3,mi4,mi5:byte);
begin
   ty0:=menu_h-menu_main_mp_bh2;
   if(N<2)then
   begin
      SetItem(mi1,menu_hw-menu_main_mp_bwq,ty0,
                  menu_hw+menu_main_mp_bwq,ty0+menu_main_mp_bh1,true );
   end
   else
   begin
      tx1:=min2i(mainBtnWh,(menu_w-integer(mainBtnW*N)) div (N+1));
      tx0:=menu_hw-((tx1*N+integer(mainBtnW)*N-tx1) div 2);

      SetItem(mi1,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
      SetItem(mi2,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
      SetItem(mi3,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
      SetItem(mi4,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );tx0+=mainBtnW+tx1;
      SetItem(mi5,tx0,ty0,tx0+mainBtnW,ty0+menu_main_mp_bh1,true );
   end;
end;

procedure mpage_NetSearch;
begin
   tx0:=menu_hw-menu_main_mp_bw1;
   tx1:=menu_hw+menu_main_mp_bw1;
   ty0:=menu_logo_h+menu_main_mp_bh1;

   SetItem(mi_mplay_NetSearchCaption,tx0,ty0,tx1,ty0+menu_main_mp_bh3q,true );

   ty0+=menu_main_mp_bh1;
   ty1:=ty0+menu_netsearch_listh*menu_netsearch_lineh;
   SetItem(mi_mplay_NetSearchList   ,tx0,ty0,tx1,ty1,true);

   ty0+=menu_main_mp_bhh;
   ty1+=menu_main_mp_bhh;
   ty0:=ty1;ty1+=menu_main_mp_bh3q;
   SetItem(mi_mplay_NetSearchCon    ,tx0,ty0,tx1,ty1,menu_NetSearchConnect(true));
   ty0:=ty1;ty1+=menu_main_mp_bh3q;

   mpage_BottomButtons(1,mi_Back,0,0,0,0);
end;

procedure mpage_Scirmish;
var i:integer;
begin
   // CAPTION
   // scirmish / campaing / replay
   tx0:=menu_hw-menu_main_mp_bwh;
   tx1:=menu_hw+menu_main_mp_bwh;
   ty0:=menu_logo_h+menu_main_mp_bh1;
   ty1:=ty0+menu_main_mp_bh1;
   if(rpls_rstate=rpls_state_read)
   then SetItem(mi_title_ReplayPlayback,tx0,ty0,tx1,ty1,true )
   else SetItem(mi_title_Scirmish      ,tx0,ty0,tx1,ty1,true );

   // BASE PANELS
   ty0:=menu_logo_h+menu_main_mp_bh3;

   tx1:=menu_hw-menu_main_mp_bhh;;
   ty1:=menu_main_mp_bhh;

   // players
   tx0:=tx1-(menu_players_namew+menu_players_racew+menu_players_teamw+ty1*2+basefont_w2*2);
   SetItem(mi_title_players    ,tx0,ty0,
                                tx1,ty0+ty1*(MaxPlayer+2)+basefont_w2,true );

   // map
   with menu_items[mi_title_players] do
   SetItem(mi_title_map        ,menu_w-mi_x0,mi_y0,
                                menu_w-mi_x1,mi_y1+basefont_w1,true );

   // game options
   with menu_items[mi_title_map] do
   begin
   tx0:=mi_x0;
   tx1:=mi_x1;
   ty0:=mi_y1+ty1;
   end;
   SetItem(mi_title_GameOptions,tx0,ty0,
                                tx1,ty0+ty1*8+basefont_w2,true );

   // mplayer/replay info
   with menu_items[mi_title_players] do
   begin
   tx0:=mi_x0;
   tx1:=mi_x1;
   ty0:=mi_y1+ty1;
   end;
   if(rpls_rstate=rpls_state_read)then
   SetItem(mi_title_ReplayInfo2,tx0,ty0,
                                tx1,ty0+menu_main_mp_bhh*8+basefont_w3,true )
   else
   SetItem(mi_title_multiplayer,tx0,ty0,
                                tx1,ty0+menu_main_mp_bhh*8+basefont_w3,true );

   // PLAYERS
   with menu_items[mi_title_players] do
   begin
      tx0:=mi_x0+basefont_w2;
      ty0:=mi_y0+ty1*2;
   end;
   for i:=0 to LastPlayer do
   begin
      tx1:=tx0;

      SetItem(mi_player_status0+i,tx1,ty0,tx1+menu_players_namew,ty0+ty1,PlayerSlotChangeState(PlayerClient,i,255,true));tx1+=menu_players_namew;
      if(NeedColumnRace(i))then
      SetItem(mi_player_race0  +i,tx1,ty0,tx1+menu_players_racew,ty0+ty1,PlayerSlotChangeRace (PlayerClient,i,255,true));tx1+=menu_players_racew;
      if(NeedColumnTeam(i))then
      SetItem(mi_player_team0  +i,tx1,ty0,tx1+menu_players_teamw,ty0+ty1,PlayerSlotChangeTeam (PlayerClient,i,255,true));tx1+=menu_players_teamw;

      SetItem(mi_player_color0 +i,tx1,ty0,tx1+ty1*2             ,ty0+ty1,false);tx1+=ty1*2;

      ty0+=ty1;
   end;

   // GAME SETTINGS
   with menu_items[mi_title_GameOptions] do
   begin
      tx0:=mi_x0+basefont_w2;
      tx1:=mi_x1-basefont_w2;
      ty0:=mi_y0+ty1+basefont_w1;
   end;

   SetItem(mi_game_FixStarts     ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_loby_gameFixStarts ,0,true));ty0+=ty1;
   SetItem(mi_game_DeadPbserver  ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_loby_gameDeadPObs  ,0,true));ty0+=ty1;
   SetItem(mi_game_EmptySlots    ,tx0,ty0,tx1,ty0+ty1,GameSetCommonSetting(PlayerClient,nmid_loby_gameEmptySlots,0,true));ty0+=ty1*3;
   SetItem(mi_game_RandomSkrimish,tx0,ty0,tx1,ty0+ty1,not G_Started);

   // MAP
   with menu_items[mi_title_map] do
   begin
      ty0:=mi_y0+ty1+basefont_w1;
      ty2:=mi_y1-ty0-basefont_w2;

      SetItem(mi_map_MiniMap,mi_x1-basefont_w2-ty2,ty0,mi_x1-basefont_w2,ty0+ty2,false);

      tx0:=mi_x0+basefont_w2;
      ty0:=mi_y0+ty1+basefont_w1;
   end;
   with menu_items[mi_map_MiniMap] do
   begin
      tx1:=mi_x0-basefont_w2;
   end;

   SetItem(mi_map_Map       ,tx0,ty0,tx1,ty0+ty1,MapLoad(PlayerClient,0,true)                            );ty0+=ty1;
   SetItem(mi_map_Scenario  ,tx0,ty0,tx1,ty0+ty1,map_SetSetting(PlayerClient,nmid_loby_mapScenario     ,0,true));ty0+=ty1;
   SetItem(mi_map_Generators,tx0,ty0,tx1,ty0+ty1,map_SetSetting(PlayerClient,nmid_loby_mapGenerators   ,0,true));ty0+=ty1;
   SetItem(mi_map_Seed      ,tx0,ty0,tx1,ty0+ty1,map_SetSetting(PlayerClient,nmid_loby_mapSeed         ,0,true));ty0+=ty1;
   SetItem(mi_map_Size      ,tx0,ty0,tx1,ty0+ty1,map_SetSetting(PlayerClient,nmid_loby_mapSize,MinMapSize,true));ty0+=ty1;
   SetItem(mi_map_Type      ,tx0,ty0,tx1,ty0+ty1,map_SetSetting(PlayerClient,nmid_loby_mapType         ,0,true));ty0+=ty1;
   SetItem(mi_map_Sym       ,tx0,ty0,tx1,ty0+ty1,map_SetSetting(PlayerClient,nmid_loby_mapSymmetry     ,0,true));ty0+=ty1;
   SetItem(mi_map_Theme     ,tx0,ty0,tx1,ty0+ty1,false                                                         );ty0+=ty1;
   SetItem(mi_map_Random    ,tx0,ty0,tx1,ty0+ty1,menu_items[mi_map_Sym].mi_enabled);

   // MULTIPLAYER / RECORD INFO
   if(rpls_rstate<>rpls_state_read)then
   begin
      with menu_items[mi_title_multiplayer] do
      begin
         tx0:=mi_x0+basefont_w2;
         tx1:=mi_x1-basefont_w2;
         ty0:=mi_y0+ty1+basefont_wh;
      end;
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
           SetItem(mi_mplay_ServerCaption   ,tx0,ty0,tx1,ty0+ty1, true         );ty0+=ty1;
           SetItem(mi_mplay_ServerStop      ,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
           SetItem(mi_mplay_ChatCaption     ,tx0,ty0,tx1,ty0+ty1, true         );ty0+=ty1;
           ty1*=5;
           SetItem(mi_mplay_Chat            ,tx0,ty0,tx1,ty0+ty1, true);
           end;
ns_client: begin
           SetItem(mi_mplay_ClientCaption   ,tx0,ty0,tx1,ty0+ty1, true         );ty0+=ty1;
           SetItem(mi_mplay_ClientStatus    ,tx0,ty0,tx1,ty0+ty1, true         );ty0+=ty1;
           SetItem(mi_mplay_ClientDisconnect,tx0,ty0,tx1,ty0+ty1, not G_Started);ty0+=ty1;
           SetItem(mi_mplay_ChatCaption     ,tx0,ty0,tx1,ty0+ty1, true         );ty0+=ty1;
           ty1*=4;
           SetItem(mi_mplay_Chat            ,tx0,ty0,tx1,ty0+ty1, true);
           end;
      end;
   end;
   ///

   if(G_Started)then
   begin
      if(rpls_rstate=rpls_state_read)or(net_status>ns_single)
      then mpage_BottomButtons(4,mi_EndGame,mi_Settings,mi_AboutGame,mi_back,0 )
      else mpage_BottomButtons(5,mi_EndGame,mi_SaveLoad,mi_Settings,mi_AboutGame,mi_back );
   end
   else
   begin
      mpage_BottomButtons(4,mi_back,mi_Settings,mi_AboutGame,mi_StartScirmish,0);

      menu_items[mi_StartScirmish].mi_enabled:=GameStartScirmish(PlayerClient,true);
      if(net_status>ns_single)
      then menu_items[mi_back].mi_enabled:=false;
   end;
end;


procedure mpage_StartedGame;
begin
   if(net_svsearch)
   then mpage_NetSearch
   else mpage_Scirmish;
end;

procedure mpage_Settings;
begin
   mpage_DefaultCaption(mi_title_Settings);

   tx0:=menu_hw-350;
   ty0:=menu_logo_h+menu_main_mp_bh3;
   tx1:=tx0+menu_main_mp_bwh;
   ty1:=ty0+menu_main_mp_bh1;
   ty2:=menu_main_mp_bh1+menu_main_mp_bhq3;

   SetItem(mi_settings_game   ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
   SetItem(mi_settings_replay ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
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
                        SetItem(mi_settings_MMapPosition   ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_PlayerColors   ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   mi_settings_replay : begin
                        SetItem(mi_settings_Replaying      ,tx0,ty0,tx1,ty1,rpls_rstate<rpls_state_read );
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ReplayName     ,tx0,ty0,tx1,ty1,rpls_rstate=rpls_state_none );
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ReplayQuality  ,tx0,ty0,tx1,ty1,true );
                        end;
   mi_settings_network: begin
                        SetItem(mi_settings_Client         ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ClientQuality  ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   mi_settings_video  : begin
                        SetItem(mi_settings_Resolution     ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ResApply       ,tx0,ty0,tx1,ty1,menu_ApplyResolution(true));
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_SDLRenderer    ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_Fullscreen     ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_ShowFPS        ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   mi_settings_sound  : begin
                        SetItem(mi_settings_SoundVol       ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_MusicVol       ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_NextTrack      ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_PlayListSize   ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                                                                                   ty0+=ty2;ty1+=ty2;
                        SetItem(mi_settings_MusicReload    ,tx0,ty0,tx1,ty1,true );ty0+=ty2;ty1+=ty2;
                        end;
   end;

   mpage_BottomButtons(1,mi_back,0,0,0,0);
end;

procedure mpage_Replays;
var w:integer;
begin
   mpage_DefaultCaption(mi_title_LoadReplay);

   w:=menu_main_mp_bw1+menu_main_mp_bw1+
      menu_players_namew+menu_players_racew;

   tx0:=menu_hw-(w div 2);
   tx1:=tx0+menu_main_mp_bw1+menu_main_mp_bw1;
   tx2:=tx1+menu_players_namew+menu_players_racew;

   ty0:=menu_logo_h+menu_main_mp_bh3;

   ty1:=ty0+menu_replays_listh*menu_replays_lineh;
   SetItem(mi_replays_list     ,tx0            ,ty0,tx1,ty1,true);
   SetItem(mi_title_ReplayInfo1,tx1+basefont_wh,ty0,tx2,ty1,true);

   mpage_BottomButtons(3,mi_back,mi_replays_play,mi_replays_delete,0,0);
   menu_items[mi_replays_delete].mi_enabled:=replay_Delete(True);
   menu_items[mi_replays_play  ].mi_enabled:=replay_Play  (True);
end;

procedure mpage_SaveLoad;
begin
   mpage_DefaultCaption(mi_title_SaveLoad);

   tx0:=menu_hw-menu_main_mp_bw1-menu_main_mp_bwq;
   tx1:=menu_hw+menu_main_mp_bwq;
   tx2:=tx1+menu_main_mp_bw1;

   ty0:=menu_logo_h+menu_main_mp_bh3;

   ty1:=ty0+menu_saveload_listh*menu_saveload_lineh;
   SetItem(mi_saveload_list ,tx0            ,ty0            ,tx1,ty1,true);
   SetItem(mi_saveload_fname,tx0            ,ty1+basefont_wh,tx1,ty1+basefont_wh+menu_saveload_lineh,true);
   SetItem(mi_title_SaveInfo,tx1+basefont_wh,ty0            ,tx2,ty1+basefont_wh+menu_saveload_lineh,true);

   mpage_BottomButtons(4,mi_back,mi_saveload_save,mi_saveload_load,mi_saveload_delete,0);
   menu_items[mi_saveload_delete].mi_enabled:=saveload_Delete(True);
   menu_items[mi_saveload_load  ].mi_enabled:=saveload_Load  (True);
   menu_items[mi_saveload_save  ].mi_enabled:=saveload_Save  (True);
end;

begin
   //menu_List_Clear;
   FillChar(menu_items,SizeOf(menu_items),0);

   case menu_page2 of
mp_saveload : mpage_SaveLoad;
mp_settings : mpage_Settings;
mp_aboutgame: begin
              mpage_DefaultCaption(mi_title_AboutGame);
              mpage_BottomButtons(1,mi_back,0,0,0,0);
              end;
   else
      case menu_page1 of
mp_main      : mpage_BottomButtons(4,mi_StartGame,mi_Settings,mi_AboutGame,mi_exit,0);
mp_campaings : begin
               mpage_DefaultCaption(mi_title_Campaings);

               if(G_Started)
               then mpage_BottomButtons(5,mi_EndGame,mi_SaveLoad,mi_Settings ,mi_AboutGame    ,mi_back)
               else mpage_BottomButtons(4,mi_back   ,mi_Settings,mi_AboutGame,mi_StartCampaing,0      );
               end;
mp_scirmish  : mpage_StartedGame;
mp_saveload  : mpage_SaveLoad;
mp_loadreplay: mpage_Replays;
      end;
   end;

   if(menu_list_n>0)then
    with menu_items[menu_item] do
     if(not mi_enabled)then menu_List_Clear;
end;

////////////////////////////////////////////////////////////////////////////////

function txt_StringApplyInput(s:shortstring;charset:TSoc;maxLength:byte;ChangedResult:pBoolean):shortstring;
var i:byte;
    c:char;
begin
   txt_StringApplyInput:=s;
   if(InputActionPressed(iAct_backspace))then//or(InputActionPressed(iAct_backspace))
   begin
      if(length(s)>0)then setlength(s,length(s)-1);
   end
   else
     if(length(k_KeyboardString)>0)then
      for i:=1 to length(k_KeyboardString) do
      begin
         c:=k_KeyboardString[i];
         if(length(s)>=maxLength)
         then break
         else
           if(c in charset)then s+=c;
      end;

   {//
   if(length(k_KeyboardString)>0)then
    for i:=1 to length(k_KeyboardString) do
    begin
       c:=k_KeyboardString[i];
       if(c=#8)   // backspace
       then begin if(length(s)>0)then setlength(s,length(s)-1)end //delete(s,length(s),1)
       else
        if(length(s)>=maxLength)
        then break
        else
          if(c in charset)then s+=c;
   end; }
   k_KeyboardString:='';
   if(ChangedResult<>nil)then
     ChangedResult^:=txt_StringApplyInput<>s;
   txt_StringApplyInput:=s;
end;

function menu_ItemIsUnderCursor(mi:byte):boolean;
begin
   menu_ItemIsUnderCursor:=false;
   with menu_items[mi] do
     menu_ItemIsUnderCursor:=(mi_enabled)and(mi_x0<=mouse_x)and(mouse_x<=mi_x1)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1);
end;

procedure menu_ItemSelect;
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
   then menu_list_selected:=-1
   else
     if(not menu_list_items[menu_list_selected].mli_enabled)
     then menu_list_selected:=-1;
   mouse_x+=x;
   mouse_y+=y;
end;

procedure menu_list_SetCommonSettings(mi:byte;MinWidth:pinteger;MaxHeight:integer=-1);
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
      if(MaxHeight>0)
      then menu_list_item_h :=MaxHeight
      else menu_list_item_h :=abs(mi_y1-mi_y0);
      menu_list_item_hh:=menu_list_item_h div 2;
      if(menu_list_item_hh>=basefont_w1h)
      then menu_list_fontS:=basefont_w1h
      else menu_list_fontS:=basefont_w1;
   end;
   menu_list_aleft:=false;
   menu_list_n:=0;
   setlength(menu_list_items,menu_list_n);
end;
procedure menu_list_UpdatePosition;
var ty:integer;
begin
   ty:=menu_list_y+menu_list_n*menu_list_item_h;
   if(ty>menu_h)then menu_list_y-=menu_list_item_h+(menu_list_n*menu_list_item_h);
   if(menu_list_y<0)then menu_list_y:=0;
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
   menu_list_w:=max3i(MinWidth,menu_list_w,menu_list_fontS*slength(acaption)+menu_list_fontS*2);
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
procedure menu_list_MakeFromInts(mi:byte;maxI,minI,StepI,CurrVal,MinWidth,Round_N:integer);
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      if(minI>maxI)then exit;
      while(minI<=maxI)do
      begin
         if(CurrVal=minI)then menu_list_current:=menu_list_n;
         menu_list_AddItem(i2s(RoundN(minI,Round_N)),menu_list_n,menu_list_current<>menu_list_n,MinWidth);
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
      for i:=0 to LastPlayer do
        if(PlayerSlotChangeTeam(PlayerClient,PlayerTarget,i,true))then
        begin
           with g_players[PlayerTarget] do
             if(team=i)then
               menu_list_current:=menu_list_n;
           //str_teams[i]
           menu_list_AddItem(i2s(i+1),i,true,MinWidth);
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
      menu_list_AddItem(str_pt_none,0,true,MinWidth);
      for i:=pss_AI_1 to pss_AI_11 do
        menu_list_AddItem(str_menu_PlayerSlots[i],i-pss_AI_1+1,true,MinWidth);
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeGamePresets(mi:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   menu_list_aleft:=true;
   with menu_items[mi] do
   begin
      menu_list_current:=map_preset_cur;
      if(map_preset_n>0)then
       for i:=0 to map_preset_n-1 do
         menu_list_AddItem(map_presets[i].mapp_name,i,true,MinWidth);
   end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeSDLDisplayModes(mi:byte);
var
MinWidth,
    i: integer;
begin
   MinWidth:=-3;
   menu_list_SetCommonSettings(mi,@MinWidth,basefont_w2);
   menu_list_aleft:=true;
   menu_list_current:=-1;
   with menu_items[mi] do
     if(vid_SDLDisplayModeN>0)then
       for i:=0 to vid_SDLDisplayModeN-1 do
         with vid_SDLDisplayModes[i] do
         begin
            if(menu_vid_vw=w)and(menu_vid_vh=h)then menu_list_current:=i;
            if (w=vid_SDLDisplayModeC.w)
            and(h=vid_SDLDisplayModeC.h)
            then menu_list_AddItem('['+i2s(w)+'x'+i2s(h)+']',i,true,MinWidth)
            else menu_list_AddItem(' '+i2s(w)+'x'+i2s(h)    ,i,true,MinWidth);
         end;
   menu_list_UpdatePosition;
end;
procedure menu_list_MakeSDLRenderers(mi:byte);
var
MinWidth,
    i: integer;
rInfo: TSDL_RendererInfo;
begin
   MinWidth:=-3;
   menu_list_SetCommonSettings(mi,@MinWidth);
   menu_list_aleft:=true;
   menu_list_current:=-1;
   with menu_items[mi] do
     if(vid_SDLRenderersN>0)then
       for i:=0 to vid_SDLRenderersN-1 do
         if(SDL_GetRenderDriverInfo(i,@rInfo)<0)
         then begin WriteSDLError('SDL_GetRenderDriverInfo '+i2s(i));break;end
         else
         begin
            if(rInfo.name=vid_SDLRendererName)then menu_list_current:=i;
            menu_list_AddItem(rInfo.name,i,true,MinWidth);
         end;
   menu_list_UpdatePosition;
end;

////////////////////////////////////////////////////////////////////////////////
//  MENU BASE

{function menu_GetIntVal(mi:byte;cur,min,max:integer):integer;
var tx0,tx1:integer;
begin
   menu_GetBarVal:=cur;
   with menu_items[mi] do
   begin
      tx1:=mi_x1-basefont_w2;
      tx0:=tx1-basefont_w5;

      if(mi_y0<mouse_y)and(mouse_y<mi_y1)then     ???????????????
        if((tx0-basefont_w2)<mouse_x)and(mouse_x<mi_x1)then
          if(mouse_x<tx0)
          then menu_GetBarVal:=max2i(min,cur-1)
          else
            if(tx1<mouse_x)
            then menu_GetBarVal:=min2i(cur+1,max)
            else menu_GetBarVal:=mm3i(min,mouse_x-tx0,max);
   end;
end;}
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
procedure menu_item_ListScrollLine(mi:byte;svar:pinteger;scroll,lineh:integer);
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
menu_list_SIndex,
mouse_px,
mouse_py,
p       :integer;
begin
   mouse_px:=mouse_x;
   mouse_py:=mouse_y;
   mouse_x :=round((mouse_x-menu_tex_x)*menu_tex_cx);
   mouse_y :=round((mouse_y-menu_tex_y)*menu_tex_cx);

   menu_list_pselected:=menu_list_selected;

   menu_list_selected:=-1;
   if(menu_list_n>0)then
   begin
      menu_list_SelectItem;
      if(InputActionPressed(iAct_mlb))and(menu_list_selected=-1)
      then menu_List_Clear
      else
        if(menu_list_pselected<>menu_list_selected)then menu_redraw:=true;
   end
   else
     if(InputActionPressed(iAct_mlb))then
     begin
        case menu_item of
mi_mplay_ClientAddress : txt_ValidateServerAddr;
mi_settings_PlayerName : begin
                         if(length(PlayerName)=0)then PlayerName:=str_defaultPlayerName;
                         g_players[PlayerClient].name:=PlayerName;
                         end;
        end;
        menu_ItemSelect;
        menu_remake:=true;
        SoundPlayUI(snd_click);
     end;

   if(InputActionPressed(iAct_mlb))then        // left button pressed
   begin
      //UpdateItems:=true;

      if(-1<menu_list_selected)and(menu_list_selected<menu_list_n)
      then menu_list_SIndex:=menu_list_items[menu_list_selected].mli_value;

      case menu_item of
mi_exit                   : GameCycle:=false;
mi_back                   : menu_Escape(false);

mi_StartScirmish          : if(net_status=ns_client)
                            then net_send_byte(nmid_start)
                            else GameStartScirmish(PlayerClient,false);

mi_StartGame              : if(menu_list_selected>-1)then
                            begin
                               menu_page1:=menu_list_SIndex;
                               case menu_page1 of
                               mp_loadreplay: replay_MakeFolderList;
                               mp_saveload  : saveload_MakeFolderList;
                               end;

                               menu_List_Clear;
                            end
                            else
                            begin
                               menu_list_SetCommonSettings(menu_item,nil);
                               menu_list_aleft:=true;
                               menu_list_current:=-1;
                               menu_list_AddItem(str_menu_Campaings ,mp_campaings ,true ,0);
                               menu_list_AddItem(str_menu_Scirmish  ,mp_scirmish  ,true ,0);
                               menu_list_AddItem(str_menu_LoadReplay,mp_loadreplay,true ,0);
                               menu_list_AddItem(str_menu_LoadGame  ,mp_saveload  ,true ,0);
                               menu_list_UpdatePosition;
                            end;
mi_EndGame                : if(menu_list_selected>-1)then
                            begin
                               case menu_list_SIndex of
                               mi_EndReplayQuit   : GameBreak(0,           false);
                               mi_EndLeave        : GameBreak(PlayerClient,false);
                               mi_EndSurrender    : begin
                                                    if(net_status=ns_client)
                                                    then net_send_byte(nmid_surrender)
                                                    else PlayerSurrender(PlayerClient,false);
                                                    menu_Escape(true);
                                                    end;
                               end;
                               menu_List_Clear;
                            end
                            else
                            begin
                               menu_list_SetCommonSettings(menu_item,nil);
                               menu_list_aleft:=true;
                               menu_list_current:=-1;
                               if(rpls_rstate=rpls_state_read)
                               then    menu_list_AddItem(str_menu_ReplayQuit,mi_EndReplayQuit,GameBreak      (0           ,true ),0)
                               else
                               begin
                                  if(g_deadobservers)
                                  then menu_list_AddItem(str_menu_LeaveGame ,mi_EndLeave     ,GameBreak      (PlayerClient,true ),0)
                                  else menu_list_AddItem(str_menu_Surrender ,mi_EndLeave     ,GameBreak      (PlayerClient,true ),0);
                                  if(PlayerSurrender(PlayerClient,true))then
                                       menu_list_AddItem(str_menu_Surrender ,mi_EndSurrender ,PlayerSurrender(PlayerClient,true ),0);
                               end;
                               menu_list_UpdatePosition;
                            end;

mi_SaveLoad               : begin
                            menu_page2:=mp_saveload;
                            saveload_MakeFolderList;
                            end;
mi_Settings               : begin
                            menu_page2:=mp_settings;
                            menu_vid_vw:=vid_vw;
                            menu_vid_vh:=vid_vh;
                            end;
mi_AboutGame              : menu_page2:=mp_aboutgame;

mi_settings_video         : begin
                            menu_vid_vw:=vid_vw;
                            menu_vid_vh:=vid_vh;
                            menu_settings_page:=menu_item;
                            end;
mi_settings_game,
mi_settings_replay,
mi_settings_network,
mi_settings_sound         : menu_settings_page:=menu_item;

//////////////////////////////////////////    SETTINGS  GAME
mi_settings_ColoredShadows: vid_ColoredShadow:=not vid_ColoredShadow;
mi_settings_ShowAPM       : vid_APM:=not vid_APM;
mi_settings_HitBars       : if(menu_list_selected>-1)
                            then begin vid_UnitHealthBars:=enum_val2TUIUnitHBarsOption(menu_list_SIndex);menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_menu_unitHBarl[low(TUIUnitHBarsOption)],SizeOf(str_menu_unitHBarl),ord(vid_UnitHealthBars),-2);
mi_settings_MRBAction     : if(menu_list_selected>-1)
                            then begin m_action:=menu_list_SIndex>0;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_menu_mactionl[false],SizeOf(str_menu_mactionl),integer(m_action),-2);
mi_settings_ScrollSpeed   : begin
                            vid_CamSpeedBase  :=menu_GetBarVal(menu_item,vid_CamSpeedBase,1,max_CamSpeed);
                            vid_CamSpeedScaled:=round(vid_CamSpeedBase/vid_cam_sc);
                            end;
mi_settings_MouseScroll   : vid_CamMSEScroll:=not vid_CamMSEScroll;
mi_settings_PlayerName    : ;   // playername
mi_settings_Langugage     : if(menu_list_selected>-1)then
                            begin
                               ui_language:=menu_list_SIndex>0;
                               menu_List_Clear;
                               language_Switch;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_lang[false],SizeOf(str_menu_lang),integer(ui_language),-3);
mi_settings_PanelPosition : if(menu_list_selected>-1)then
                            begin
                               vid_PannelPos:=enum_val2TVidPannelPos(menu_list_SIndex);
                               menu_List_Clear;
                               vid_UpdateCommonVars;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_PanelPosl[low(TVidPannelPos)],SizeOf(str_menu_PanelPosl),integer(vid_PannelPos),-2);
mi_settings_MMapPosition  : if(menu_list_selected>-1)then
                            begin
                               vid_MiniMapPos:=(menu_list_SIndex>0);
                               menu_List_Clear;
                               vid_UpdateCommonVars;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_MiniMapPosl[vid_PannelPos in VPPSet_Vertical][false],SizeOf(str_menu_MiniMapPosl[vid_PannelPos in VPPSet_Vertical]),integer(vid_MiniMapPos),-2);
mi_settings_PlayerColors  : if(menu_list_selected>-1)
                            then begin vid_PlayersColorSchema:=enum_val2TPlayersColorSchema(menu_list_SIndex);menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_menu_PlayersColorl[low(TPlayersColorSchema)],SizeOf(str_menu_PlayersColorl),integer(vid_PlayersColorSchema),-2);

//////////////////////////////////////////    SETTINGS  NETWORK
mi_settings_ClientQuality : if(menu_list_selected>-1)then
                            begin
                               net_Quality:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_NetQuality[0],SizeOf(str_menu_NetQuality),integer(net_Quality),-3);

//////////////////////////////////////////    SETTINGS  RECORD
mi_settings_Replaying     : rpls_Recording:=not rpls_Recording;
mi_settings_ReplayName    : ;
mi_settings_ReplayQuality : if(menu_list_selected>-1)then
                            begin
                               rpls_Quality:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_menu_NetQuality[0],SizeOf(str_menu_NetQuality[0])*(cl_UpT_arrayN_RPLs+1),integer(rpls_Quality),-3);

//////////////////////////////////////////    SETTINGS  VIDEO
mi_settings_Resolution    : if(menu_list_selected>-1)
                            then begin menu_vid_vw:=vid_SDLDisplayModes[menu_list_SIndex].w;
                                       menu_vid_vh:=vid_SDLDisplayModes[menu_list_SIndex].h;
                                       menu_List_Clear;end
                            else menu_list_MakeSDLDisplayModes(menu_item);
mi_settings_ResApply      : menu_ApplyResolution(false);

mi_settings_Fullscreen    : begin vid_fullscreen:=not vid_fullscreen;WindowToggleFullscreen;end;
mi_settings_SDLRenderer   : if(menu_list_selected>-1)
                            then begin vid_SDLRendererName:=menu_list_items[menu_list_SIndex].mli_caption; menu_List_Clear;end
                            else menu_list_MakeSDLRenderers(menu_item);
mi_settings_ShowFPS       : vid_FPS:=not vid_FPS;

//////////////////////////////////////////    SETTINGS  SOUND
mi_settings_SoundVol      : begin
                            snd_svolume1:=menu_GetBarVal(menu_item,round(snd_svolume1*snd_MaxSoundVolume),0,snd_MaxSoundVolume)/snd_MaxSoundVolume;
                            SoundSourceUpdateGainAll;
                            end;
mi_settings_MusicVol      : begin
                            snd_mvolume1:=menu_GetBarVal(menu_item,round(snd_mvolume1*snd_MaxSoundVolume),0,snd_MaxSoundVolume)/snd_MaxSoundVolume;
                            SoundSourceUpdateGainAll;
                            end;
mi_settings_NextTrack     : SoundMusicControll(true);

mi_settings_PlayListSize  : snd_PlayListSize:=menu_GetBarVal(menu_item,snd_PlayListSize,0,snd_PlayListSizeMax);
mi_settings_MusicReload   : SoundMusicReload;



//////////////////////////////////////////    SCIRMISH PLAYERS
mi_player_status0,
mi_player_status1,
mi_player_status2,
mi_player_status3,
mi_player_status4,
mi_player_status5,
mi_player_status6,
mi_player_status7         : begin
                               p:=menu_item-mi_player_status0;
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
mi_player_race0,
mi_player_race1,
mi_player_race2,
mi_player_race3,
mi_player_race4,
mi_player_race5,
mi_player_race6,
mi_player_race7           : begin
                               p:=menu_item-mi_player_race0;
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
mi_player_team0,
mi_player_team1,
mi_player_team2,
mi_player_team3,
mi_player_team4,
mi_player_team5,
mi_player_team6,
mi_player_team7           : begin
                               p:=menu_item-mi_player_team0;
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
mi_map_Map                : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(nmid_loby_mapMap,byte(menu_list_selected))
                               else MapLoad(PlayerClient,byte(menu_list_selected),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeGamePresets(menu_item,-2);
mi_map_Scenario           : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_loby_mapScenario,byte(menu_list_SIndex))
                               else map_SetSetting  (PlayerClient,nmid_loby_mapScenario,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_scenariol[0],SizeOf(str_map_scenariol),integer(map_scenario),-3);
mi_map_Generators         : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_loby_mapGenerators,byte(menu_list_SIndex))
                               else map_SetSetting  (PlayerClient,nmid_loby_mapGenerators,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_Generatorsl[0],SizeOf(str_map_Generatorsl),integer(map_generators),-2);
mi_map_Seed               : ;// seed;
mi_map_Size               : if(menu_list_selected>-1)then
                            begin
                               p:=MinMapSize+(StepMapSize*menu_list_SIndex);
                               if(net_status=ns_client)
                               then net_send_MIDInt(             nmid_loby_mapSize,p)
                               else map_SetSetting (PlayerClient,nmid_loby_mapSize,p,false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromInts(menu_item,MaxMapSize,MinMapSize,StepMapSize,map_psize,-2,100);
mi_map_Type               : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_loby_mapType,byte(menu_list_selected))
                               else map_SetSetting  (PlayerClient,nmid_loby_mapType,byte(menu_list_selected),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_typel[0],SizeOf(str_map_typel),map_type,-2);
mi_map_Sym                : if(menu_list_selected>-1)then
                            begin
                               menu_List_Clear;
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_loby_mapSymmetry,byte(menu_list_selected))
                               else map_SetSetting  (PlayerClient,nmid_loby_mapSymmetry,byte(menu_list_selected),false);
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_syml[0],SizeOf(str_map_syml),map_symmetry,-2);
mi_map_Random             : begin
                               Map_randommap;
                               map_Make1Scirmish;
                            end;
//////////////////////////////////////////    GAME SETTINGS
mi_game_FixStarts         : if(net_status=ns_client)
                            then net_send_MIDByte    (             nmid_loby_gameFixStarts   ,byte(not g_fixed_positions))
                            else GameSetCommonSetting(PlayerClient,nmid_loby_gameFixStarts   ,byte(not g_fixed_positions),false);
mi_game_DeadPbserver      : if(net_status=ns_client)
                            then net_send_MIDByte    (             nmid_loby_gameDeadPObs,byte(not g_deadobservers))
                            else GameSetCommonSetting(PlayerClient,nmid_loby_gameDeadPObs,byte(not g_deadobservers),false);
mi_game_EmptySlots        : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_loby_gameEmptySlots,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_loby_gameEmptySlots,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeAISlots(menu_item,integer(g_ai_slots),-2);
mi_game_RandomSkrimish    : MakeRandomSkirmish(false);


//////////////////////////////////////////    MULTIPLAYER

mi_mplay_ServerPort       : ;
mi_mplay_ServerStart      : if(net_status=ns_single)then
                            begin
                               txt_ValidateServerPort;
                               if(net_setup(net_port))then
                               begin
                                  PlayersSetDefault;
                                  net_status:=ns_server;
                               end
                               else net_dispose;
                            end;
mi_mplay_ServerStop       : menu_ServerStop;

mi_mplay_ClientConnect    : if(net_status=ns_single)then menu_NetClientConnect;
mi_mplay_ClientDisconnect : if(net_status=ns_client)then GameBreakClientGame;

mi_mplay_ClientAddress    : ;
mi_mplay_Chat             : ;

mi_mplay_NetSearchStart   : if(net_setup(net_svlsearch_port))then
                            begin
                               net_status_str:='';
                               net_status  :=ns_client;
                               net_svsearch:=true;
                               SetLength(net_svsearch_lists,0);
                               SetLength(net_svsearch_listi,0);
                               net_svsearch_listn :=0;
                               net_svsearch_scroll:=0;
                               net_svsearch_sel   :=0;
                            end
                            else net_dispose;
mi_mplay_NetSearchStop    : menu_NetSearchStop;
mi_mplay_NetSearchList    : if(InputActionDPressed(iAct_mlb))
                            then menu_NetSearchConnect(false)
                            else menu_item_ListScrollLine(menu_item,@net_svsearch_sel,net_svsearch_scroll,menu_netsearch_lineh);
mi_mplay_NetSearchCon     : menu_NetSearchConnect(false);


//////////////////////////////////////////    REPLAYS PLAYER
mi_replays_list           : if(InputActionDPressed(iAct_mlb))
                            then replay_Play(false)
                            else
                            begin
                               menu_item_ListScrollLine(menu_item,@rpls_list_sel,rpls_list_scroll,menu_replays_lineh);
                               replay_Select;
                            end;
mi_replays_play           : replay_Play  (false);
mi_replays_delete         : replay_Delete(false);

//////////////////////////////////////////    SAVE LOAD
//
mi_saveload_save          : saveload_Save  (false);
mi_saveload_load          : saveload_Load  (false);
mi_saveload_delete        : saveload_Delete(false);
mi_saveload_list          : if(InputActionDPressed(iAct_mlb))
                            then saveload_Load(false)
                            else
                            begin
                            menu_item_ListScrollLine(menu_item,@svld_list_sel,svld_list_scroll,menu_saveload_lineh);
                            saveload_Select;
                            end;
      end;
   end;

   if(InputActionPressed(iAct_mwd))then
   begin
      if(menu_ItemIsUnderCursor(mi_saveload_list      ))then menu_redraw:=menu_redraw or ScrollInt(@svld_list_scroll   , mwscroll_speed,0,svld_list_size    -menu_saveload_listh ,false);
      if(menu_ItemIsUnderCursor(mi_replays_list       ))then menu_redraw:=menu_redraw or ScrollInt(@rpls_list_scroll   , mwscroll_speed,0,rpls_list_size    -menu_replays_listh  ,false);
      if(menu_ItemIsUnderCursor(mi_mplay_NetSearchList))then menu_redraw:=menu_redraw or ScrollInt(@net_svsearch_scroll, mwscroll_speed,0,net_svsearch_listn-menu_netsearch_listh,false);
   end;

   if(InputActionPressed(iAct_mwu))then
   begin
      if(menu_ItemIsUnderCursor(mi_saveload_list      ))then menu_redraw:=menu_redraw or ScrollInt(@svld_list_scroll   ,-mwscroll_speed,0,svld_list_size    -menu_saveload_listh ,false);
      if(menu_ItemIsUnderCursor(mi_replays_list       ))then menu_redraw:=menu_redraw or ScrollInt(@rpls_list_scroll   ,-mwscroll_speed,0,rpls_list_size    -menu_replays_listh  ,false);
      if(menu_ItemIsUnderCursor(mi_mplay_NetSearchList))then menu_redraw:=menu_redraw or ScrollInt(@net_svsearch_scroll,-mwscroll_speed,0,net_svsearch_listn-menu_netsearch_listh,false);
   end;

   mouse_x:=mouse_px;
   mouse_y:=mouse_py;
end;

{procedure Menu_Hotkeys(key1:cardinal);
begin
   case key1 of
km_Esc      : menu_Toggle;
   end;
end;   }

procedure menu_keyborad;
var Changed:boolean;
begin
   Changed:=false;
   case menu_item of
mi_map_Seed           : begin
                        map_seed  :=s2c(txt_StringApplyInput(c2s(map_seed) ,k_kbdig ,10           ,@Changed));
                        if(Changed)then
                          if(net_status=ns_client)
                          then net_send_MIDCard(             nmid_loby_mapSeed,map_seed      )
                          else map_SetSetting  (PlayerClient,nmid_loby_mapSeed,map_seed,false);
                        end;
mi_settings_PlayerName: PlayerName     :=txt_StringApplyInput(PlayerName     ,k_pname ,PlayerNameLen,@Changed);
mi_settings_ReplayName: rpls_str_prefix:=txt_StringApplyInput(rpls_str_prefix,k_kbstr ,ReplayNameLen,@Changed);
mi_mplay_ServerPort   : begin
                        net_sv_pstr    :=txt_StringApplyInput(net_sv_pstr    ,k_kbdig ,5            ,@Changed);
                        if(Changed)then txt_ValidateServerPort;
                        end;
mi_mplay_ClientAddress: net_cl_svaddr  :=txt_StringApplyInput(net_cl_svaddr  ,k_kbstr ,30           ,@Changed);
   else
     if(net_status>ns_single)and(menu_items[mi_mplay_Chat].mi_enabled)
     then net_chat_str  :=txt_StringApplyInput(net_chat_str  ,k_kbstr ,255    ,@Changed)
     else
       if(menu_items[mi_saveload_fname].mi_enabled)then
       begin
          svld_str_fname:=txt_StringApplyInput(svld_str_fname,k_kbstr ,ReplayNameLen,@Changed);
          if(Changed)then saveload_SelectByName(svld_str_fname);
       end;
   end;

   if(Changed)then menu_remake:=true;

   if(InputActionPressed(iAct_esc))then
   begin
      menu_Escape(false);
      exit;
   end;

   if(InputActionPressed(iAct_return))then ;
   {if(menu_item=100)or(ingame_chat>0)then //menu chat   ?????????????
   begin
      if(menu_state)then
      begin
         ingame_chat :=chat_all;
         net_chat_tar:=255;
      end;

      if(length(net_chat_str)>0)and(net_chat_tar>0)then
      begin
         if(net_status=ns_client)
         then net_send_chat(             net_chat_tar,net_chat_str )
         else GameLogChat  (PlayerClient,net_chat_tar,net_chat_str,false);
      end;
      net_chat_str:='';
      ingame_chat :=0;
   end;}
end;



