function StringApplyInput(s:shortstring;charset:TSoc;ms:byte;changedVar:pboolean):shortstring;
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
        if(changedVar<>nil)then changedVar^:=true;
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

   if(g_DefeatedObs)and(not g_players[LocalPlayer].observer)and(not GameCheckEndStatus)and(rpls_state<rpls_read)then
   begin
      menu_surrender:=true;

      if(check)then exit;

      case net_status  of
      ns_server,
      ns_none   : begin
                     GameLogPlayerSurrender(LocalPlayer);
                     PlayerKill(LocalPlayer,true);
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

   if(g_type=gt_campaing)
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
   menu_ScirmishTab:=not(G_Started and(g_type=gt_campaing));
end;
function menu_MultiplayerTab:boolean;
begin
   menu_MultiplayerTab:=not(G_Started and(g_type=gt_campaing));
end;
function PlayersSlotEnabled:boolean;
begin
   PlayersSlotEnabled:=(not G_Started)and(g_type<>gt_campaing);
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

procedure menu_GetBarValByte(mi:byte;vvar:pbyte;vmin,vmax:byte;ClickOutSetMax:boolean);
var
bstartX,
bendX  :integer;
begin
   with menu_items[mi] do
     if(mi_state>1)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1)then
     begin
        bendX  :=mi_x1-menu_BarStepX;
        bstartX:=bendX-(vmax-vmin);

        if(bendX<=mouse_x)and(mouse_x<=mi_x1)then
          case ClickOutSetMax of
          true : vvar^:=vmax;
          false: if(vvar^<vmax)then vvar^+=1;
          end
        else
          if(mi_x0<=mouse_x)and(mouse_x<=bstartX)then
            case ClickOutSetMax of
            true : vvar^:=vmin;
            false: if(vvar^>vmin)then vvar^-=1;
            end
          else vvar^:=(mouse_x-bstartX)+vmin;
     end;
end;

procedure menu_ListLine(mi:byte;svar:pinteger;scroll,lineh:integer);
begin
   with menu_items[mi] do
     if (mi_x0<mouse_x)and(mouse_x<mi_x1)
     and(mi_y0<mouse_y)and(mouse_y<mi_y1)
     then svar^:=scroll+((mouse_y-mi_y0) div lineh);
end;

function menu_MouseXY2Item:byte;
var i:byte;
begin
   menu_MouseXY2Item:=0;

   for i:=0 to 255 do
     with menu_items[i] do
       if(mi_state>1)then // 0 - no existed, 1 - disabled, 2 - enabled
         if(mi_x0<mouse_x)and(mouse_x<mi_x1)and(mi_y0<mouse_y)and(mouse_y<mi_y1)then
           menu_MouseXY2Item:=i;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   MENU STRUCTURE
//

{
if(menu_s2=ms2_camp)then
  if(92<mouse_y)and(mouse_y<108)then
  begin
     if(635<mouse_x)and(mouse_x<659)then menu_MouseXY2Item:=128; // campaing mission obj page next
     if(699<mouse_x)and(mouse_x<723)then menu_MouseXY2Item:=129; // campaing mission obj page prev
  end;


if(ui_menu_csm_x0<mouse_x)and(mouse_x<ui_menu_csm_x1)and(ui_menu_csm_y0<mouse_y)and(mouse_y<ui_menu_csm_y1)then
begin
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
end; }

procedure g_RebuildMenu;
var
tx0,ty0,
tx1    : integer;
procedure setItem(mi:byte;x0,y0,x1,y1:integer;enabled:boolean);
begin
   with menu_items[mi] do
   begin
      mi_x0:=min2i(x0,x1);
      mi_y0:=min2i(y0,y1);
      mi_x1:=max2i(x0,x1);
      mi_y1:=max2i(y0,y1);

      mi_xc:=(mi_x0+mi_x1) div 2;
      mi_yc:=(mi_y0+mi_y1) div 2;

      mi_state:=1+byte(enabled);
   end;
end;
procedure setEnabled(mi:byte;enabled:boolean);
begin
   with menu_items[mi] do
     if(mi_state>0)then
       mi_state:=1+byte(enabled);
end;

procedure menu_BottomButtons(b1,b2,b3,b4,b5,b6:byte);
var n:byte;
gapX :integer;
begin
   n:=0;
   if(b1>0)then n+=1;
   if(b2>0)then n+=1;
   if(b3>0)then n+=1;
   if(b4>0)then n+=1;
   if(b5>0)then n+=1;
   if(b6>0)then n+=1;

   if(n=0)then exit;

   ty0:=menu_h-menu_StepFromBottom-menu_BigButtonH;

   gapX:=0;
   if(n>1)then
   begin
      gapX:=(menu_w-(menu_BaseW*2)-(menu_BigButtonW*n)) div (n-1);
      if(gapX>menu_BaseW)then gapX:=menu_BaseW;
      tx0  :=menu_hw-((menu_BigButtonW*n)+gapX*(n-1)) div 2; //menu_BaseW
   end
   else tx0:=menu_hw-(menu_BigButtonW div 2);

   if(b1>0)then setItem(b1,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);tx0+=menu_BigButtonW+gapX;
   if(b2>0)then setItem(b2,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);tx0+=menu_BigButtonW+gapX;
   if(b3>0)then setItem(b3,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);tx0+=menu_BigButtonW+gapX;
   if(b4>0)then setItem(b4,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);tx0+=menu_BigButtonW+gapX;
   if(b5>0)then setItem(b5,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);tx0+=menu_BigButtonW+gapX;
   if(b6>0)then setItem(b6,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);
end;
procedure menu_TopCaption(mi:byte);
begin
   setItem(mi,menu_hw-menu_BigButtonhW,menu_underLogoY,menu_hw+menu_BigButtonhW,menu_underLogoY+menu_CaptionH,true);
end;
begin
   FillChar(menu_items,SizeOf(Menu_items),0);

   case menu_page of
mi_SaveLoad  : begin
                  menu_TopCaption(mi_caption_SaveLoad);

                  tx0:=menu_border1;
                  tx1:=tx0+menu_ListW;
                  ty0:=menu_ListLineH*menu_BaseListH;

                  setItem(mi_SaveLoad_list   ,tx0,menu_underCaptionY,tx1,menu_underCaptionY+ty0,true);

                  tx0:=tx1+menu_BasehW;
                  tx1:=menu_w-menu_border1;
                  setItem(mi_SaveLoad_info   ,tx0,menu_underCaptionY,tx1,menu_underCaptionY+ty0,true);

                  with menu_items[mi_SaveLoad_list] do
                  setItem(mi_SaveLoad_fname  ,mi_x0,mi_y1,mi_x1,mi_y1+menu_ListLineH,true);

                  if(g_started)and(rpls_state<>rpls_read)
                  then menu_BottomButtons(mi_back,mi_SaveLoad_save,mi_SaveLoad_load,mi_SaveLoad_delete,0,0)
                  else menu_BottomButtons(mi_back,                 mi_SaveLoad_load,mi_SaveLoad_delete,0,0,0);

                  setEnabled(mi_SaveLoad_save  ,saveload_Save  (true));
                  setEnabled(mi_SaveLoad_load  ,saveload_Load  (true));
                  setEnabled(mi_SaveLoad_delete,saveload_Delete(true));
               end;
mi_Replays   : begin
                  menu_TopCaption(mi_caption_Replays);

                  tx0:=menu_border1;
                  tx1:=tx0+menu_ListW;
                  ty0:=menu_ListLineH*menu_BaseListH;

                  setItem(mi_Replays_list    ,tx0,menu_underCaptionY,tx1,menu_underCaptionY+ty0,true);

                  tx0:=tx1+menu_BasehW;
                  tx1:=menu_w-menu_border1;
                  setItem(mi_Replays_info    ,tx0,menu_underCaptionY,tx1,menu_underCaptionY+ty0,true);

                  menu_BottomButtons(mi_back,mi_Replays_play,mi_Replays_delete,0,0,0);

                  setEnabled(mi_Replays_play  ,replay_Play  (true));
                  setEnabled(mi_Replays_delete,replay_Delete(true));
               end;
mi_Settings  : begin
                  menu_TopCaption(mi_caption_Settings);

                  tx0:=menu_border1;
                  ty0:=menu_underCaptionY;
                  setItem(mi_settings_Game   ,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);ty0+=menu_BigButtonH+menu_BaseW;
                  setItem(mi_settings_Record ,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);ty0+=menu_BigButtonH+menu_BaseW;
                  setItem(mi_settings_Video  ,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);ty0+=menu_BigButtonH+menu_BaseW;
                  setItem(mi_settings_Sound  ,tx0,ty0,tx0+menu_BigButtonW,ty0+menu_BigButtonH,true);

                  tx0:=menu_border1+menu_BigButtonW+menu_BaseW;
                  tx1:=menu_w-menu_border1;
                  ty0:=menu_underCaptionY;

                  case menu_settings of
                  mi_settings_Game  : begin
                                         setItem(mi_SG_ColoredShadows  ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_ShowAPM         ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_HealthBars      ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_RightClickAction,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_ScrollSpeed     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_MouseScroll     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_PlayerName      ,tx0,ty0,tx1,ty0+menu_SmallW,menu_PlayerNameEnabled);ty0+=menu_SmallW;
                                         setItem(mi_SG_Language        ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_ControlPanelPos ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SG_PlayersColor    ,tx0,ty0,tx1,ty0+menu_SmallW,true);
                                      end;
                  mi_settings_Record: begin
                                         setItem(mi_SR_RecordGames     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SR_RecordPrefix    ,tx0,ty0,tx1,ty0+menu_SmallW,rpls_state<>rpls_write);ty0+=menu_SmallW;
                                         setItem(mi_SR_RecordQuality   ,tx0,ty0,tx1,ty0+menu_SmallW,true);
                                      end;
                  mi_settings_Video : begin
                                         setItem(mi_SV_ResolutionW     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SV_ResolutionH     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SV_ResolutionApply ,tx0,ty0,tx1,ty0+menu_SmallW,((menu_ResolutionWi<>vid_vw)
                                                                                                   or(menu_ResolutionHi<>vid_vh))
                                                                                                   and(menu_ResolutionWi>=vid_minw)
                                                                                                   and(menu_ResolutionHi>=vid_minh));
                                                                                                          ty0+=menu_SmallW;
                                                                                                          ty0+=menu_SmallW;
                                         setItem(mi_SV_Windowed        ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                                                                                          ty0+=menu_SmallW;
                                         setItem(mi_SV_ShowFPS         ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SV_MenuScaling     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SV_SmoothScaled    ,tx0,ty0,tx1,ty0+menu_SmallW,true);
                                      end;
                  mi_settings_Sound : begin
                                         setItem(mi_SS_SoundVolume     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SS_MusicVolume     ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                                                                                          ty0+=menu_SmallW;
                                         setItem(mi_SS_PlayerNext      ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SS_PlaylistSize    ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                         setItem(mi_SS_ReloadPlaylist  ,tx0,ty0,tx1,ty0+menu_SmallW,true);ty0+=menu_SmallW;
                                      end;
                  end;

                  menu_BottomButtons(mi_back,0,0,0,0,0);
               end;
   else
      case g_type of
gt_scirmish: begin
                menu_TopCaption(mi_caption_Scirmish);

                if(g_started)
                then menu_BottomButtons(mi_back,mi_SaveLoad,mi_Settings,mi_Break,0,0)
                else menu_BottomButtons(mi_back,mi_Settings,mi_Start   ,0       ,0,0);

                // PLAYERS BLOCK
                tx0:=menu_BaseW;
                tx1:=tx0+menu_PlayersW;
                ty0:=menu_underCaptionY;
                setItem(mi_Players_Panel,tx0,ty0,tx1,ty0+menu_ListLineH*9,true);

                ty0+=menu_ListLineH;
                tx0:=menu_items[mi_Players_Panel].mi_x0;
                setItem(mi_Players_NameC ,tx0,ty0,tx0+menu_PlayersNameW ,ty0+menu_ListLineH,false);tx0+=menu_PlayersNameW;
                setItem(mi_Players_StateC,tx0,ty0,tx0+menu_PlayersStateW,ty0+menu_ListLineH,false);tx0+=menu_PlayersStateW;
                setItem(mi_Players_RaceC ,tx0,ty0,tx0+menu_PlayersRaceW ,ty0+menu_ListLineH,false);tx0+=menu_PlayersRaceW;
                setItem(mi_Players_TeamC ,tx0,ty0,tx0+menu_PlayersTeamW ,ty0+menu_ListLineH,false);tx0+=menu_PlayersTeamW;
                setItem(mi_Players_ColorC,tx0,ty0,tx0+menu_PlayersPingW ,ty0+menu_ListLineH,false);
                ty0-=menu_ListLinehH;
                if(net_status<>ns_none)then
                setItem(mi_Players_PingC ,tx0,ty0,tx0+menu_PlayersPingW ,ty0+menu_ListLineH,false);

                ty0+=menu_ListLineH+menu_ListLinehH;
                for tx1:=0 to MaxPlayers-1 do
                begin
                   tx0:=menu_items[mi_Players_Panel].mi_x0;
                   setItem(mi_Players_Name1 +tx1,tx0,ty0,tx0+menu_PlayersNameW ,ty0+menu_ListLineH,PlayersSlotEnabled);tx0+=menu_PlayersNameW;
                   setItem(mi_Players_State1+tx1,tx0,ty0,tx0+menu_PlayersStateW,ty0+menu_ListLineH,PlayerAIToggle  (tx1+1,true     ));tx0+=menu_PlayersStateW;
                   setItem(mi_Players_Race1 +tx1,tx0,ty0,tx0+menu_PlayersRaceW ,ty0+menu_ListLineH,PlayerRaceChange(tx1+1,true     ));tx0+=menu_PlayersRaceW;
                   setItem(mi_Players_Team1 +tx1,tx0,ty0,tx0+menu_PlayersTeamW ,ty0+menu_ListLineH,PlayerTeamChange(tx1+1,true,true));tx0+=menu_PlayersTeamW;
                   setItem(mi_Players_Ping1 +tx1,tx0,ty0,tx0+menu_PlayersPingW ,ty0+menu_ListLineH,true);
                   ty0+=menu_ListLineH;
                end;
                tx0:=menu_items[mi_Players_Panel].mi_x0;

                if(menu_ReadyButtonEnabled)then
                setItem(mi_Players_Ready,tx0,ty0,tx0+menu_PlayersNameW ,ty0+menu_ListLineH,true);

                // MAP BLOCK
                tx0:=menu_items[mi_Players_Panel].mi_x1+menu_BaseW;
                tx1:=tx0+menu_BaseW*14;
                ty0:=menu_underCaptionY;

                setItem(mi_Map_Panel,tx0,ty0,tx1,ty0+menu_BaseW+ui_CtrlPanelW+menu_BasehW,true);

                with menu_items[mi_Map_Panel] do
                setItem(mi_Map_Map,mi_x1-menu_BasehW-ui_CtrlPanelW,mi_y0+menu_BaseW,
                                   mi_x1-menu_BasehW           ,mi_y0+menu_BaseW+ui_CtrlPanelW,true);

                tx0+=menu_BasehW;
                tx1:=menu_items[mi_Map_Map].mi_x0-menu_BasehW;
                ty0+=menu_BaseW;

                setItem(mi_Map_Scenario  ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Generators,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Seed      ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Size      ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Obstacles ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Symmetry  ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Theme     ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Map_Random    ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;

                setEnabled(mi_Map_Scenario,GameSetOption(0,true,true));
                menu_items[mi_Map_Generators].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Map_Seed      ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Map_Size      ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Map_Obstacles ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Map_Symmetry  ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Map_Random    ].mi_state:=menu_items[mi_Map_Scenario].mi_state;

                // GAME OPTIONS BLOCK
                with menu_items[mi_Map_Panel] do
                begin
                   tx0:=mi_x0;
                   tx1:=mi_x1;
                   ty0:=mi_y1+menu_BaseW;
                end;
                setItem(mi_Game_Panel         ,tx0,ty0,tx1,ty0+menu_ListLineH*6+menu_BaseW,true);
                tx0+=menu_BasehW;
                tx1-=menu_BasehW;
                ty0+=menu_ListLineH+menu_BasehW;

                setItem(mi_Game_FixedPositions,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Game_AISlots       ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                setItem(mi_Game_DefeatedObs   ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                                                                                    ty0+=menu_ListLineH;
                setItem(mi_Game_Random        ,tx0,ty0,tx1,ty0+menu_ListLineH,true);

                menu_items[mi_Game_FixedPositions].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Game_AISlots       ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Game_DefeatedObs   ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
                menu_items[mi_Game_Random        ].mi_state:=menu_items[mi_Map_Scenario].mi_state;

                // MULTIPLAYER BLOCK
                if(rpls_state=rpls_read)then
                begin

                end
                else
                begin
                   with menu_items[mi_Players_Panel] do
                   begin
                      tx0:=mi_x0;
                      tx1:=mi_x1;
                      ty0:=mi_y1+menu_BaseW;
                   end;
                   setItem(mi_MP_Panel           ,tx0,ty0,tx1,menu_items[mi_Game_Panel].mi_y1,true);
                   tx0+=menu_BasehW;
                   tx1-=menu_BasehW;
                   ty0+=menu_ListLineH+menu_BasehW;


                   case net_status of
                   ns_none    : begin
                                   setItem(mi_MP_ServerPort     ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                                   setItem(mi_MP_ServerStart    ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                                                                                                      ty0+=menu_ListLineH;
                                   setItem(mi_MP_ClientAddress  ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                                   setItem(mi_MP_ClientLANSearch,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                                   setItem(mi_MP_ClientConnect  ,tx0,ty0,tx1,ty0+menu_ListLineH,true);ty0+=menu_ListLineH;
                                end;
                   ns_client  :;
                   ns_server  :;
                   end;


                   {
                   mi_MP_Panel            = 180;
                   mi_MP_ServerStop       = 182;

                   mi_MP_ClientConnect    = 184;
                   mi_MP_ClientDisconnect = 185;
                   mi_MP_ClientAddress    = 186;
                   mi_MP_ClientQuality    = 187;
                   mi_MP_ClientLANSearch  = 188
                   mi_MP_Chat             = 189;
                   }
                end;
             end;
gt_campaing: begin
                menu_TopCaption(mi_caption_Campaings);

                if(g_started)
                then menu_BottomButtons(mi_back,mi_SaveLoad,mi_Settings,mi_Break,0,0)
                else menu_BottomButtons(mi_back,mi_Settings,mi_Start   ,0       ,0,0);
             end;
      else
      menu_BottomButtons(mi_Campaings,mi_Scirmish,mi_SaveLoad,mi_Replays,mi_Settings,mi_Exit);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MANU MAIN CODE
//

procedure g_menu;
var
p      :byte;
mnx,
mny    :integer;
changed:boolean;
procedure EndEdition(mi:byte);
begin
   if(menu_items[mi].mi_state<2)then  exit;
   case mi of
mi_SG_PlayerName : g_players[LocalPlayer].name:=PlayerName;
mi_Map_Seed      : if(not GameMapSetSeed(0,true))
                   then menu_mseed:=c2s(map_seed)
                   else GameMapSetSeed(s2c(menu_mseed),false);
   {90: net_cl_saddr;
   50}
   end;
end;

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
      if(menu_item>0)then EndEdition(menu_item);

      menu_item:=menu_MouseXY2Item;

      vid_menu_redraw:=true;
      menu_rebuild   :=true;

      if(menu_item>0)then SoundPlayUI(snd_click);
   end;

///////////////////////////////////
///////////////////////////////////   left button pressed
///////////////////////////////////

   if(ks_mleft=1)then
   begin
      case menu_item of
mi_back                : ToggleMenu;
mi_exit                : GameCycle:=false;

mi_Start               : GameStart;             // start game
mi_Break               : GameBreak;             // break game
mi_Surrender           : menu_surrender(false); // Surrender


mi_Campaings           : g_type:=gt_campaing;
mi_Scirmish            : g_type:=gt_scirmish;

mi_SaveLoad            : begin menu_page:=menu_item;saveload_MakeFolderList; end;
mi_Replays             : begin menu_page:=menu_item;  replay_MakeFolderList; end;
mi_Settings            : begin menu_page:=menu_item; menu_ResolutionWi:=vid_vw;menu_ResolutionHi:=vid_vh;end;

// SETTINGS LIST
mi_settings_Game,
mi_settings_Record,
mi_settings_Video,
mi_settings_Sound      : menu_settings:=menu_item;

// SETTINGS GAME
mi_SG_ColoredShadows   : ui_ColoredShadow:=not ui_ColoredShadow;
mi_SG_ShowAPM          : ui_ShowAPM      :=not ui_ShowAPM;
mi_SG_HealthBars       : ScrollByte(@ui_HealthBars,true,0,vid_MaxHealthBars);
mi_SG_RightClickAction : m_RightClickAct :=not m_RightClickAct;
mi_SG_ScrollSpeed      : menu_GetBarValByte(menu_item,@ui_CamSpeed,1,vid_MaxCamSpeed,true);
mi_SG_MouseScroll      : ui_MouseScroll  :=not ui_MouseScroll;
mi_SG_PlayerName       : ;
mi_SG_Language         : begin ui_language:=not ui_language;SwitchLanguage;end;
mi_SG_ControlPanelPos  : begin
                            ScrollByte(@ui_ControlPanelPos,true,0,vid_MaxControlPanelPos);
                            vid_RemakeScreenSurfaces;
                            theme_map_pTerrain:=255;
                            gfx_MapMakeTerrain;
                         end;
mi_SG_PlayersColor     : ScrollByte(@ui_PlayersColor,true,0,vid_MaxPlayersColor);

// SETTINGS GAME RECORDING

mi_SR_RecordGames      : rpls_Record:=not rpls_Record;
mi_SR_RecordPrefix     : ;
mi_SR_RecordQuality    : ScrollByte(@rpls_Quality,true,0,rpls_MaxQuality);

// SETTINGS VIDEO

mi_SV_ResolutionW      :;
mi_SV_ResolutionH      :;
mi_SV_ResolutionApply  :begin
                            vid_vw:=max2i(vid_minw,menu_ResolutionWi);menu_ResolutionWi:=vid_vw;
                            vid_vh:=max2i(vid_minh,menu_ResolutionHi);menu_ResolutionHi:=vid_vh;

                            vid_MakeScreen;
                            theme_map_pTerrain:=255;
                            gfx_MapMakeTerrain;
                         end;
mi_SV_Windowed         : begin vid_windowed:=not vid_windowed; vid_MakeScreen;end;
mi_SV_ShowFPS          : vid_ShowFPS:=not vid_ShowFPS;
mi_SV_MenuScaling      : menu_scale:=not menu_scale;
mi_SV_SmoothScaled     : menu_ScaleSmooth:=not menu_ScaleSmooth;

// SETTINGS SOUND

mi_SS_SoundVolume      : begin
                         menu_GetBarValByte(menu_item,@snd_SoundVolume,0,snd_MaxSoundVolume,true);
                         snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : begin
                         menu_GetBarValByte(menu_item,@snd_MusicVolume,0,snd_MaxSoundVolume,true);
                         snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_SS_PlayerNext       : SoundMusicControll(true);
mi_SS_PlaylistSize     : ScrollByte(@snd_musicListSize,true,1,snd_musicListSizeMax);
mi_SS_ReloadPlaylist   : GameMusicReLoad;

// SAVE LOAD
mi_SaveLoad_list       : begin
                            menu_ListLine(menu_item,@svld_list_sel,svld_list_scroll,menu_ListLineH);
                            saveload_Select;
                         end;
mi_SaveLoad_info       :;
mi_SaveLoad_fname      :;
mi_SaveLoad_save       : saveload_Save  (false);
mi_SaveLoad_load       : saveload_Load  (false);
mi_SaveLoad_delete     : saveload_Delete(false);

// REPLAYS
mi_Replays_list        : begin
                            menu_ListLine(menu_item,@rpls_list_sel,rpls_list_scroll,menu_ListLineH);
                            replay_Select;
                         end;
mi_Replays_info        : ;
mi_Replays_play        : replay_Play  (false);
mi_Replays_delete      : replay_Delete(false);

// SCIRMISH PLAYERS
mi_Players_Name1..
mi_Players_Name6       : PlayerAILevelLoop(menu_item-mi_Players_Name1 +1);
mi_Players_State1..
mi_Players_State6      : PlayerAIToggle   (menu_item-mi_Players_State1+1,false);
mi_Players_Race1..
mi_Players_Race6       : PlayerRaceChange (menu_item-mi_Players_Race1 +1,false);
mi_Players_Team1..
mi_Players_Team6       : PlayerTeamChange (menu_item-mi_Players_Team1 +1,true ,false);
mi_Players_Ready       : PlayerReady:=not PlayerReady;

// SCIRMISH MAP
mi_Map_Scenario        : GameSetOption(nmid_lobby_MScenario      ,true,false);
mi_Map_Generators      : GameSetOption(nmid_lobby_MGenerators    ,true,false);
mi_Map_Seed            : ;
mi_Map_Size            : GameSetOption(nmid_lobby_MSize          ,true,false);
mi_Map_Obstacles       : GameSetOption(nmid_lobby_MObs           ,true,false);
mi_Map_Symmetry        : GameSetOption(nmid_lobby_MSym           ,true,false);
mi_Map_Random          : GameSetOption(nmid_lobby_MRandom        ,true,false);

mi_Game_FixedPositions : GameSetOption(nmid_lobby_GFixedPositions,true,false);
mi_Game_AISlots        : GameSetOption(nmid_lobby_GAISlots       ,true,false);
mi_Game_DefeatedObs    : GameSetOption(nmid_lobby_GDefeatedObs   ,true,false);
mi_Game_Random         : GameSetOption(nmid_lobby_GRandomScirmish,true,false);

{
      // CAMP SCIRMISH MULTIPLAY
      70 : begin
              menu_s2:=ms2_camp;
              cmp_minfo_lpage:=str_camp_infon[cmp_sel] div vid_campi_scrlstep;
           end;
      71 : begin p:=menu_s2;menu_s2:=ms2_scir;if(p=ms2_camp)then Map_premap;end;
      72 : menu_s2:=ms2_mult;

      //// multiplayer
      // server
      86 : menu_NetServer(net_status<>ns_server,false);
      87 : ; // port

      // client
      89 : menu_NetClient(net_status<>ns_client,false);
      90 : ;
      91 : ScrollByte(@net_cl_Quality,true,0,net_MaxQuality);

      // camps
      97 : ScrollByte(@cmp_skill,true,0,CMPMaxSkills);
      98 : begin
              t:=cmp_sel;
              cmp_sel:=camp_list_scroll+((mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(cmp_sel>=LastMission)then cmp_sel:=LastMission;
              if(t<>cmp_sel)then
              begin
                 cmp_minfo_page :=0;
                 cmp_minfo_lpage:=str_camp_infon[cmp_sel] div vid_campi_scrlstep;
              end;
           end;
      128: if(cmp_minfo_page>0)then cmp_minfo_page-=1;
      129: if(cmp_minfo_page<cmp_minfo_lpage)then cmp_minfo_page+=1;  }
      end;

   end;

///////////////////////////////////
///////////////////////////////////   right button pressed
///////////////////////////////////

   if(ks_mright=1)then
   begin
      case menu_item of
mi_SG_PlayersColor     : ScrollByte(@ui_PlayersColor  ,false,0,vid_MaxPlayersColor);
mi_SG_HealthBars       : ScrollByte(@ui_HealthBars    ,false,0,vid_MaxHealthBars  );
mi_SR_RecordQuality    : ScrollByte(@rpls_Quality     ,false,0,rpls_MaxQuality    );
mi_SS_PlaylistSize     : ScrollByte(@snd_musicListSize,false,1,snd_musicListSizeMax);

mi_SG_ScrollSpeed      : menu_GetBarValByte(menu_item,@ui_CamSpeed,1,vid_MaxCamSpeed,false);
mi_SS_SoundVolume      : begin
                         menu_GetBarValByte(menu_item,@snd_SoundVolume,0,snd_MaxSoundVolume,false);
                         snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : begin
                         menu_GetBarValByte(menu_item,@snd_MusicVolume,0,snd_MaxSoundVolume,false);
                         snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_Players_Name1..
mi_Players_Name6       : PlayersSwap(menu_item-mi_Players_Name1 +1,LocalPlayer);
mi_Players_Team1..
mi_Players_Team6       : PlayerTeamChange(menu_item-mi_Players_Team1+1,false,false);

mi_Map_Scenario        : GameSetOption(nmid_lobby_MScenario  ,false,false);
mi_Map_Generators      : GameSetOption(nmid_lobby_MGenerators,false,false);
mi_Map_Seed            : GameSetOption(nmid_lobby_MSeed      ,false,false);
mi_Map_Size            : GameSetOption(nmid_lobby_MSize      ,false,false);
mi_Map_Obstacles       : GameSetOption(nmid_lobby_MObs       ,false,false);

mi_Game_AISlots        : GameSetOption(nmid_lobby_GAISlots     ,false,false);
      {
      91 : ScrollByte(@net_cl_Quality,false,0,9);

      97 : ScrollByte(@cmp_skill,false,0,CMPMaxSkills);  }
      end;
   end;

   //if(menu_s2=ms2_mult)and(net_status<>ns_none)and(menu_item<>50)then menu_item:=100;

///////////////////////////////////
///////////////////////////////////   text vars
///////////////////////////////////
   if(length(k_keyboard_string)>0)then
   begin
      changed:=false;
      case menu_item of
mi_SG_PlayerName  : PlayerName       :=StringApplyInput(PlayerName      ,CharSetCommon,MaxPlayerNameLen,@changed);
mi_SR_RecordPrefix: rpls_NamePrefix  :=StringApplyInput(rpls_NamePrefix ,CharSetCommon,SvRpLen,@changed);

mi_SV_ResolutionW : menu_ResolutionWi:=s2i(StringApplyInput(i2s(menu_ResolutionWi),CharSetDigits,4,@changed));
mi_SV_ResolutionH : menu_ResolutionHi:=s2i(StringApplyInput(i2s(menu_ResolutionHi),CharSetDigits,4,@changed));

mi_SaveLoad_fname : svld_str_fname   :=StringApplyInput(svld_str_fname  ,CharSetCommon,menu_ListLineWChars,@changed);

mi_Map_Seed       : menu_mseed       :=StringApplyInput(menu_mseed      ,CharSetDigits,10     ,@changed);
      {
      87 : begin
              net_sv_StrPort:=StringApplyInput(net_sv_StrPort   ,CharSetDigits,5     ,@changed );
              net_sv_sport;
           end;
      90 : net_cl_StrAddr  :=StringApplyInput(net_cl_StrAddr  ,CharSetCommon,21     ,@changed);
      100: net_chat_str  :=StringApplyInput(net_chat_str  ,CharSetCommon,255    ,@changed);    }
      end;

      vid_menu_redraw:=changed;
   end;

   // rebuild menu
   if(menu_rebuild)then
   begin
      g_RebuildMenu;
      menu_rebuild   :=false;
      vid_menu_redraw:=true;

      if(menu_items[menu_item].mi_state<2)then menu_item:=0;
   end;

   mouse_x:=mnx;
   mouse_y:=mny;
end;

