function StringApplyInput(s:shortstring;charset:TSoc;maxLength:byte;changedVar:pboolean):shortstring;
var i:byte;
    c:char;
begin
   StringApplyInput:=s;
   if(InputActionPressed(iAct_backspace))then
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
   k_KeyboardString:='';
   if(changedVar<>nil)then
     changedVar^:=StringApplyInput<>s;
   StringApplyInput:=s;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MENU ACTIONS

function PlayersSlotEnabled:boolean;
begin
   PlayersSlotEnabled:=(not G_Started)and(g_type<>gt_campaing);
end;
function PlayerNameChangeble:boolean;
begin
   PlayerNameChangeble:=(net_status=ns_none)and(not G_Started);
end;
function GameNetServer(start,check:boolean):boolean;
begin
   GameNetServer:=false;

   if(net_status=ns_client)
   or(rpls_pstate<>rpls_none)
   or(G_Started)then exit;

   case start of
   true : begin   // start
             if(net_status=ns_server)then exit;
             GameNetServer:=true;
             if(check)then exit;

             net_status:=ns_server;
             menu_GetServerPort;
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
             GameNetServer:=true;
             if(check)then exit;

             net_dispose;
             GameDefaultAll;
             g_started:=false;
             net_status:=ns_none;
          end;
   end;
end;
function GameNetClient(connect,check:boolean):boolean;
begin
   GameNetClient:=false;

   if(net_status=ns_server)
   or(rpls_pstate<>rpls_none)
   or(G_Started)then exit;

   case connect of
   true : begin   // start connecting
             if(net_status=ns_client)then exit;
             GameNetClient:=true;
             if(check)then exit;

             net_error_timer:=0;
             net_cl_Hoster:=255;
             net_status:=ns_client;
             menu_GetClientAddress;
             rpls_pnu:=0;
             if(net_UpSocket)
             then GameLogChat(255,255,str_gmsg_Connecting,true)
             else
             begin
                GameLogChat(255,255,str_gmsg_PortBlocked,true);
                net_dispose;
                net_status:=ns_none;
             end;
          end;
   false: begin   // disconnect
             if(net_status<>ns_client)then exit;
             GameNetClient:=true;
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

procedure menu_ListMouseXY2Line(mi:byte;svar:pinteger;scroll,lineh:integer);
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

var
mtx0,mty0,
mtx1    : integer;

/////   BASIC

procedure menu_Item_Set(mi:byte;x0,y0,x1,y1:integer;enabled:boolean);
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
procedure menu_item_setEnabled(mi:byte;enabled:boolean);
begin
   with menu_items[mi] do
     if(mi_state>0)then
       mi_state:=1+byte(enabled);
end;

procedure menu_page_BottomButtons(b1,b2,b3,b4,b5,b6:byte);
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

   mty0:=menu_h-menu_StepFromBottom-menu_BigButtonH;

   gapX:=0;
   if(n>1)then
   begin
      gapX:=(menu_w-(menu_BaseW*2)-(menu_BigButtonW*n)) div (n-1);
      if(gapX>menu_BaseW)then gapX:=menu_BaseW;
      mtx0  :=menu_hw-((menu_BigButtonW*n)+gapX*(n-1)) div 2; //menu_BaseW
   end
   else mtx0:=menu_hw-(menu_BigButtonW div 2);

   if(b1>0)then begin menu_Item_Set(b1,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b2>0)then begin menu_Item_Set(b2,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b3>0)then begin menu_Item_Set(b3,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b4>0)then begin menu_Item_Set(b4,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b5>0)then begin menu_Item_Set(b5,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b6>0)then begin menu_Item_Set(b6,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);                           end;
end;

procedure menu_page_TopCaption(mi:byte);
begin
   menu_Item_Set(mi,menu_hw-menu_CaptionhW,menu_underLogoY,menu_hw+menu_CaptionhW,menu_underLogoY+menu_CaptionH,true);
end;

/////   MAIN

procedure menu_page_SaveLoad;
begin
   menu_page_TopCaption(mi_caption_SaveLoad);

   mtx0:=menu_border1;
   mtx1:=mtx0+menu_ListW;
   mty0:=menu_ListLineH*menu_BaseListH;

   menu_Item_Set(mi_SaveLoad_list   ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true);

   mtx0:=mtx1+menu_BasehW;
   mtx1:=menu_w-menu_border1;
   menu_Item_Set(mi_SaveLoad_info   ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true);

   with menu_items[mi_SaveLoad_list] do
   menu_Item_Set(mi_SaveLoad_fname  ,mi_x0,mi_y1,mi_x1,mi_y1+menu_ListLineH,true);

   if(g_started)and(rpls_pstate<>rpls_read)
   then menu_page_BottomButtons(mi_back,mi_SaveLoad_save,mi_SaveLoad_load,mi_SaveLoad_delete,0,0)
   else menu_page_BottomButtons(mi_back,                 mi_SaveLoad_load,mi_SaveLoad_delete,0,0,0);

   menu_item_setEnabled(mi_SaveLoad_save  ,saveload_Save  (true));
   menu_item_setEnabled(mi_SaveLoad_load  ,saveload_Load  (true));
   menu_item_setEnabled(mi_SaveLoad_delete,saveload_Delete(true));
end;

procedure menu_page_Replays;
begin
   menu_page_TopCaption(mi_caption_Replays);

   mtx0:=menu_border1;
   mtx1:=mtx0+menu_ListW;
   mty0:=menu_ListLineH*menu_BaseListH;

   menu_Item_Set(mi_Replays_list    ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true);

   mtx0:=mtx1+menu_BasehW;
   mtx1:=menu_w-menu_border1;
   menu_Item_Set(mi_Replays_info    ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true);

   menu_page_BottomButtons(mi_back,mi_Replays_play,mi_Replays_delete,0,0,0);

   menu_item_setEnabled(mi_Replays_play  ,replay_Play  (true));
   menu_item_setEnabled(mi_Replays_delete,replay_Delete(true));
end;

procedure menu_page_Settings;
begin
   menu_page_TopCaption(mi_caption_Settings);

   mtx0:=menu_border1;
   mty0:=menu_underCaptionY;
   menu_Item_Set(mi_settings_Game   ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BaseW;
   menu_Item_Set(mi_settings_Record ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BaseW;
   menu_Item_Set(mi_settings_Video  ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BaseW;
   menu_Item_Set(mi_settings_Sound  ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);

   mtx0:=menu_border1+menu_BigButtonW+menu_BaseW;
   mtx1:=menu_w-menu_border1;
   mty0:=menu_underCaptionY;

   case menu_SettingsPage of
   mi_settings_Game  : begin
                          menu_Item_Set(mi_SG_ColoredShadows  ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ShowAPM         ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_HealthBars      ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_RightClickAction,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ScrollSpeed     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_MouseScroll     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_PlayerName      ,mtx0,mty0,mtx1,mty0+menu_SmallW,PlayerNameChangeble);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_Language        ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ControlPanelPos ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_PlayersColor    ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);
                       end;
   mi_settings_Record: begin
                          menu_Item_Set(mi_SR_RecordGames     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SR_RecordPrefix    ,mtx0,mty0,mtx1,mty0+menu_SmallW,rpls_pstate<>rpls_write);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SR_RecordQuality   ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);
                       end;
   mi_settings_Video : begin
                          menu_Item_Set(mi_SV_ResolutionW     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SV_ResolutionH     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SV_ResolutionApply ,mtx0,mty0,mtx1,mty0+menu_SmallW,((menu_ResolutionWi<>vid_vw)
                                                                                    or(menu_ResolutionHi<>vid_vh))
                                                                                    and(menu_ResolutionWi>=vid_minw)
                                                                                    and(menu_ResolutionHi>=vid_minh));
                                                                                           mty0+=menu_SmallW;
                                                                                           mty0+=menu_SmallW;
                          menu_Item_Set(mi_SV_Windowed        ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                                                                                           mty0+=menu_SmallW;
                          menu_Item_Set(mi_SV_ShowFPS         ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SV_MenuScaling     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SV_SmoothScaled    ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);
                       end;
   mi_settings_Sound : begin
                          menu_Item_Set(mi_SS_SoundVolume     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SS_MusicVolume     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                                                                                           mty0+=menu_SmallW;
                          menu_Item_Set(mi_SS_PlayerNext      ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SS_PlaylistSize    ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SS_ReloadPlaylist  ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                       end;
   end;

   menu_page_BottomButtons(mi_back,0,0,0,0,0);
end;

procedure menu_page_Scirmish;
var p:byte;
btns : array[0..4] of byte = (0,0,mi_Settings,0,0);
begin
   menu_page_TopCaption(mi_caption_Scirmish);

   if(GameBack(false,true))then
     btns[0]:=mi_back;

   if(saveload_Allowed)and(g_started)
   then btns[1]:=mi_SaveLoad;

   if(PlayerSurrender(LocalPlayer,true))
   then btns[3]:=mi_Surrender;

   case net_status of
   ns_none,
   ns_server: case g_started of
              true : btns[4]:=mi_Break;
              false: btns[4]:=mi_Start;
              end;
   ns_client: btns[4]:=mi_MP_Disconnect;
   end;
   menu_page_BottomButtons(btns[0],btns[1],btns[2],btns[3],btns[4],0);

   // PLAYERS BLOCK
   mtx0:=menu_BaseW;
   mtx1:=mtx0+menu_PlayersW;
   mty0:=menu_underCaptionY;
   menu_Item_Set(mi_Players_Panel,mtx0,mty0,mtx1,mty0+menu_ListLineH*9,true);

   mty0+=menu_ListLineH;
   mtx0:=menu_items[mi_Players_Panel].mi_x0;
   menu_Item_Set(mi_Players_NameC ,mtx0,mty0,mtx0+menu_PlayersNameW ,mty0+menu_ListLineH,false);mtx0+=menu_PlayersNameW;
   menu_Item_Set(mi_Players_StateC,mtx0,mty0,mtx0+menu_PlayersStateW,mty0+menu_ListLineH,false);mtx0+=menu_PlayersStateW;
   menu_Item_Set(mi_Players_RaceC ,mtx0,mty0,mtx0+menu_PlayersRaceW ,mty0+menu_ListLineH,false);mtx0+=menu_PlayersRaceW;
   menu_Item_Set(mi_Players_TeamC ,mtx0,mty0,mtx0+menu_PlayersTeamW ,mty0+menu_ListLineH,false);mtx0+=menu_PlayersTeamW;
   menu_Item_Set(mi_Players_ColorC,mtx0,mty0,mtx0+menu_PlayersPingW ,mty0+menu_ListLineH,false);
   mty0-=menu_ListLinehH;
   if(net_status<>ns_none)then
   menu_Item_Set(mi_Players_PingC ,mtx0,mty0,mtx0+menu_PlayersPingW ,mty0+menu_ListLineH,false);

   mty0+=menu_ListLineH+menu_ListLinehH;
   for p:=0 to LastPlayer-1 do
   begin
      mtx0:=menu_items[mi_Players_Panel].mi_x0;
      menu_Item_Set(mi_Players_Name1 +p,mtx0,mty0,mtx0+menu_PlayersNameW ,mty0+menu_ListLineH,PlayersSlotEnabled);mtx0+=menu_PlayersNameW;
      menu_Item_Set(mi_Players_State1+p,mtx0,mty0,mtx0+menu_PlayersStateW,mty0+menu_ListLineH,PlayerAIToggle  (p+1,true     ));mtx0+=menu_PlayersStateW;
      menu_Item_Set(mi_Players_Race1 +p,mtx0,mty0,mtx0+menu_PlayersRaceW ,mty0+menu_ListLineH,PlayerRaceChange(p+1,true     ));mtx0+=menu_PlayersRaceW;
      menu_Item_Set(mi_Players_Team1 +p,mtx0,mty0,mtx0+menu_PlayersTeamW ,mty0+menu_ListLineH,PlayerTeamChange(p+1,true,true));mtx0+=menu_PlayersTeamW;
      menu_Item_Set(mi_Players_Ping1 +p,mtx0,mty0,mtx0+menu_PlayersPingW ,mty0+menu_ListLineH,true);
      mty0+=menu_ListLineH;
   end;
   mtx0:=menu_items[mi_Players_Panel].mi_x0;

   if(menu_ReadyButtonEnabled)then
   menu_Item_Set(mi_Players_Ready,mtx0,mty0,mtx0+menu_PlayersNameW ,mty0+menu_ListLineH,true);

   // MAP BLOCK
   mtx0:=menu_items[mi_Players_Panel].mi_x1+menu_BaseW;
   mtx1:=mtx0+menu_BaseW*14;
   mty0:=menu_underCaptionY;

   menu_Item_Set(mi_Map_Panel,mtx0,mty0,mtx1,mty0+menu_BaseW+ui_CtrlPanelW+menu_BasehW,true);

   with menu_items[mi_Map_Panel] do
   menu_Item_Set(mi_Map_Map,mi_x1-menu_BasehW-ui_CtrlPanelW,mi_y0+menu_BaseW,
                      mi_x1-menu_BasehW           ,mi_y0+menu_BaseW+ui_CtrlPanelW,true);

   mtx0+=menu_BasehW;
   mtx1:=menu_items[mi_Map_Map].mi_x0-menu_BasehW;
   mty0+=menu_BaseW;

   menu_Item_Set(mi_Map_Scenario  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Generators,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Seed      ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Size      ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Obstacles ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Symmetry  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Theme     ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Random    ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;

   menu_item_setEnabled(mi_Map_Scenario,GameSetOption(0,true,true));
   menu_items[mi_Map_Generators].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Seed      ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Size      ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Obstacles ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Symmetry  ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Random    ].mi_state:=menu_items[mi_Map_Scenario].mi_state;

   // GAME OPTIONS BLOCK
   with menu_items[mi_Map_Panel] do
   begin
      mtx0:=mi_x0;
      mtx1:=mi_x1;
      mty0:=mi_y1+menu_BaseW;
   end;
   menu_Item_Set(mi_Game_Panel         ,mtx0,mty0,mtx1,mty0+menu_ListLineH*6+menu_BaseW,true);
   mtx0+=menu_BasehW;
   mtx1-=menu_BasehW;
   mty0+=menu_ListLineH+menu_BasehW;

   menu_Item_Set(mi_Game_FixedPositions,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Game_AISlots       ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Game_DefeatedObs   ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
                                                                       mty0+=menu_ListLineH;
   menu_Item_Set(mi_Game_Random        ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);

   menu_items[mi_Game_FixedPositions].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Game_AISlots       ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Game_DefeatedObs   ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Game_Random        ].mi_state:=menu_items[mi_Map_Scenario].mi_state;

   // MULTIPLAYER BLOCK
   with menu_items[mi_Players_Panel] do
   begin
      mtx0:=mi_x0;
      mtx1:=mi_x1;
      mty0:=mi_y1+menu_BaseW;
   end;
   if(rpls_pstate=rpls_read)
   then menu_Item_Set(mi_ReplayInfo_Panel,mtx0,mty0,mtx1,menu_items[mi_Game_Panel].mi_y1,true)
   else
   begin
      menu_Item_Set(mi_MP_Panel          ,mtx0,mty0,mtx1,menu_items[mi_Game_Panel].mi_y1,true);
      mtx0+=menu_BasehW;
      mtx1-=menu_BasehW;
      mty0+=menu_ListLineH+menu_BasehW;

      case net_status of
      ns_none    : begin
                      menu_Item_Set(mi_MP_ServerToggle   ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetServer(true ,true));mty0+=menu_ListLineH;
                      menu_Item_Set(mi_MP_ServerPort     ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetServer(true ,true));mty0+=menu_ListLineH;
                                                                                                              mty0+=menu_ListLineH;
                      menu_Item_Set(mi_MP_Connect        ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetClient(true ,true));mty0+=menu_ListLineH;
                      menu_Item_Set(mi_MP_ClientAddress  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetClient(true ,true));mty0+=menu_ListLineH;
                      menu_Item_Set(mi_MP_ClientLANSearch,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetClient(true ,true));mty0+=menu_ListLineH;
                   end;
      ns_server  : begin
                      mty0-=menu_ListLineH;
                      menu_Item_Set(mi_MP_Status         ,mtx0,mty0,mtx1,mty0+menu_ListLineH,false                     );mty0+=menu_ListLineH;
                      menu_Item_Set(mi_MP_ServerToggle   ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetServer(false,true ));mty0+=menu_ListLineH;
                      with menu_items[mi_MP_Panel] do
                      menu_Item_Set(mi_MP_Chat           ,mi_x0,mty0,mi_x1,mi_y1,true);
                   end;
      ns_client  : begin
                      mty0-=menu_ListLineH;
                      menu_Item_Set(mi_MP_Status         ,mtx0,mty0,mtx1,mty0+menu_ListLineH,false                     );mty0+=menu_ListLineH;
                      menu_Item_Set(mi_MP_ClientQuality  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true                      );mty0+=menu_ListLineH;
                      with menu_items[mi_MP_Panel] do
                      menu_Item_Set(mi_MP_Chat           ,mi_x0,mty0,mi_x1,mi_y1,true);
                   end;
      end;


      {
      mi_MP_Chat             = 189;
      }
   end;
end;

procedure menu_page_Campaing;
begin
   menu_page_TopCaption(mi_caption_Campaings);

   if(g_started)
   then menu_page_BottomButtons(mi_back,mi_SaveLoad,mi_Settings,mi_Break,0,0)
   else menu_page_BottomButtons(mi_back,mi_Settings,mi_Start   ,0       ,0,0);
end;


procedure menu_Rebuild;
begin
   FillChar(menu_items,SizeOf(Menu_items),0);

   case menu_page of
mi_SaveLoad  : menu_page_SaveLoad;
mi_Replays   : menu_page_Replays;
mi_Settings  : menu_page_Settings;
   else
      case g_type of
 gt_scirmish : menu_page_Scirmish;
 gt_campaing : menu_page_Campaing;
      else     menu_page_BottomButtons(mi_Campaings,mi_Scirmish,mi_SaveLoad,mi_Replays,mi_Settings,mi_Exit);
      end;
      menu_item_setEnabled(mi_Break        ,GameBreak(true ));
      menu_item_setEnabled(mi_Start        ,GameStart(true ));
      menu_item_setEnabled(mi_Surrender    ,PlayerSurrender(LocalPlayer,true ));
      menu_item_setEnabled(mi_MP_Disconnect,GameNetClient(false,true));
   end;
   menu_item_setEnabled(mi_SaveLoad        ,saveload_Allowed);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MENU MAIN CODE
//

procedure menu_EndEdition(EnterKey:boolean);
var changed:boolean;
begin
   changed:=true;
   case menu_ItemSelected of
mi_SG_PlayerName   : g_players[LocalPlayer].name:=PlayerName;
mi_Map_Seed        : if(not GameMapSetSeed(0,true))
                     then menu_mseed:=c2s(map_seed)
                     else GameMapSetSeed(s2c(menu_mseed),false);
mi_MP_ServerPort   : menu_GetServerPort;
mi_MP_ClientAddress: menu_GetClientAddress;
mi_MP_Chat         : if(EnterKey)then
                     begin
                        if(length(net_chat_str)>0)then
                        begin
                           if(net_status=ns_client)
                           then net_send_chat(            255,net_chat_str)
                           else GameLogChat  (LocalPlayer,255,net_chat_str,false);
                        end;
                        net_chat_str:='';
                     end;
   else changed:=false;
   end;
   menu_ItemSelected:=0;
   menu_update:=changed or menu_update;
end;

procedure menu_Controls;
var
mnx,
mny    :integer;
clickSound,
changed:boolean;
function SetSelectedItem(newItem:byte):boolean;
begin
   SetSelectedItem:=true;
   if(menu_items[newItem].mi_state>0)
   then menu_ItemSelected:=newItem
   else SetSelectedItem:=false;
end;

begin
   mnx:=mouse_x;
   mny:=mouse_y;
   mouse_x:=round((mouse_x-menu_sc_x)*menu_sc_cx);
   mouse_y:=round((mouse_y-menu_sc_y)*menu_sc_cx);

   clickSound:=false;

   {p:=menu_MouseXY2Item; // menu hint
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
      menu_update:=true;
   end; }

   menu_ItemTarget:=menu_MouseXY2Item;

   if(InputActionPressed(iact_MLB))or(InputActionPressed(iact_MRB)) then   //right or left click
   begin
      if(menu_ItemTarget<>menu_ItemSelected)then
         menu_EndEdition(false);

      menu_ItemSelected:=menu_ItemTarget;
   end;

///////////////////////////////////
///////////////////////////////////   left button pressed
///////////////////////////////////

   if(InputActionPressed(iact_MLB))then
   begin
      changed:=true;
      case menu_ItemSelected of
mi_back                : GameBack(false,false);
mi_exit                : GameCycle:=false;

mi_Start               : GameStart(false);      // start game
mi_Break               : GameBreak(false);      // break game
mi_Surrender           : if(PlayerSurrender(LocalPlayer,false))then
                           if(MainMenu)then GameBack(true,false);
// Surrender


mi_Campaings           : g_type:=gt_campaing;
mi_Scirmish            : g_type:=gt_scirmish;

mi_SaveLoad            : begin menu_page:=menu_ItemSelected;saveload_MakeFolderList; end;
mi_Replays             : begin menu_page:=menu_ItemSelected;  replay_MakeFolderList; end;
mi_Settings            : begin menu_page:=menu_ItemSelected; menu_ResolutionWi:=vid_vw;menu_ResolutionHi:=vid_vh;end;

// SETTINGS LIST
mi_settings_Game,
mi_settings_Record,
mi_settings_Video,
mi_settings_Sound      : menu_SettingsPage:=menu_ItemSelected;

// SETTINGS GAME
mi_SG_ColoredShadows   : ui_ColoredShadow:=not ui_ColoredShadow;
mi_SG_ShowAPM          : ui_ShowAPM      :=not ui_ShowAPM;
mi_SG_HealthBars       : ScrollByte(@ui_HealthBars,true,0,vid_MaxHealthBars);
mi_SG_RightClickAction : m_RightClickAct :=not m_RightClickAct;
mi_SG_ScrollSpeed      : menu_GetBarValByte(menu_ItemSelected,@ui_CamSpeed,1,vid_MaxCamSpeed,true);
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
                         menu_GetBarValByte(menu_ItemSelected,@snd_SoundVolume,0,snd_MaxSoundVolume,true);
                         snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : begin
                         menu_GetBarValByte(menu_ItemSelected,@snd_MusicVolume,0,snd_MaxSoundVolume,true);
                         snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_SS_PlayerNext       : SoundMusicControll(true);
mi_SS_PlaylistSize     : ScrollByte(@snd_musicListSize,true,1,snd_musicListSizeMax);
mi_SS_ReloadPlaylist   : GameMusicReLoad;

// SAVE LOAD
mi_SaveLoad_list       : begin
                            menu_ListMouseXY2Line(menu_ItemSelected,@svld_list_sel,svld_list_scroll,menu_ListLineH);
                            saveload_Select;
                         end;
mi_SaveLoad_info       :;
mi_SaveLoad_fname      :;
mi_SaveLoad_save       : saveload_Save  (false);
mi_SaveLoad_load       : saveload_Load  (false);
mi_SaveLoad_delete     : saveload_Delete(false);

// REPLAYS
mi_Replays_list        : begin
                            menu_ListMouseXY2Line(menu_ItemSelected,@rpls_list_sel,rpls_list_scroll,menu_ListLineH);
                            replay_Select;
                         end;
mi_Replays_info        : ;
mi_Replays_play        : replay_Play  (false);
mi_Replays_delete      : replay_Delete(false);

// SCIRMISH PLAYERS
mi_Players_Name1..
mi_Players_Name6       : PlayerAILevelLoop(menu_ItemSelected-mi_Players_Name1 +1);
mi_Players_State1..
mi_Players_State6      : PlayerAIToggle   (menu_ItemSelected-mi_Players_State1+1,false);
mi_Players_Race1..
mi_Players_Race6       : PlayerRaceChange (menu_ItemSelected-mi_Players_Race1 +1,false);
mi_Players_Team1..
mi_Players_Team6       : PlayerTeamChange (menu_ItemSelected-mi_Players_Team1 +1,true ,false);
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

// SCIRMISH MULTIPLAYER
mi_MP_ServerToggle     : GameNetServer(net_status<>ns_server,false);
mi_MP_Connect          : GameNetClient(true ,false);
mi_MP_Disconnect       : GameNetClient(false,false);
mi_MP_ClientQuality    : ScrollByte(@net_cl_Quality,true,0,net_MaxQuality);
mi_MP_ServerPort       : ;
mi_MP_ClientAddress    : ;
mi_MP_ClientLANSearch  : ;
      else changed:=false;
      end;
      menu_update:=menu_update or changed;
      clickSound :=clickSound  or changed;
   end;

///////////////////////////////////
///////////////////////////////////   right button pressed
///////////////////////////////////

   if(InputActionPressed(iact_MRB))then
   begin
      changed:=true;
      case menu_ItemSelected of
mi_SG_PlayersColor     : ScrollByte(@ui_PlayersColor  ,false,0,vid_MaxPlayersColor);
mi_SG_HealthBars       : ScrollByte(@ui_HealthBars    ,false,0,vid_MaxHealthBars  );
mi_SR_RecordQuality    : ScrollByte(@rpls_Quality     ,false,0,rpls_MaxQuality    );
mi_SS_PlaylistSize     : ScrollByte(@snd_musicListSize,false,1,snd_musicListSizeMax);

mi_SG_ScrollSpeed      : menu_GetBarValByte(menu_ItemSelected,@ui_CamSpeed,1,vid_MaxCamSpeed,false);
mi_SS_SoundVolume      : begin
                         menu_GetBarValByte(menu_ItemSelected,@snd_SoundVolume,0,snd_MaxSoundVolume,false);
                         snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : begin
                         menu_GetBarValByte(menu_ItemSelected,@snd_MusicVolume,0,snd_MaxSoundVolume,false);
                         snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                         SoundSourceUpdateGainAll;
                         end;
mi_Players_Name1..
mi_Players_Name6       : PlayersSwap(menu_ItemSelected-mi_Players_Name1 +1,LocalPlayer);
mi_Players_Team1..
mi_Players_Team6       : PlayerTeamChange(menu_ItemSelected-mi_Players_Team1+1,false,false);

mi_Map_Scenario        : GameSetOption(nmid_lobby_MScenario  ,false,false);
mi_Map_Generators      : GameSetOption(nmid_lobby_MGenerators,false,false);
mi_Map_Seed            : GameSetOption(nmid_lobby_MSeed      ,false,false);
mi_Map_Size            : GameSetOption(nmid_lobby_MSize      ,false,false);
mi_Map_Obstacles       : GameSetOption(nmid_lobby_MObs       ,false,false);

mi_Game_AISlots        : GameSetOption(nmid_lobby_GAISlots   ,false,false);

mi_MP_ClientQuality    : ScrollByte(@net_cl_Quality,false,0,net_MaxQuality);
      else changed:=false;
      end;
      menu_update:=menu_update or changed;
      clickSound :=clickSound  or changed;
   end;

///////////////////////////////////
///////////////////////////////////   mouse wheel
///////////////////////////////////

   if(InputActionPressed(iact_MWD))then
   begin
      SetSelectedItem(mi_SaveLoad_list);
      SetSelectedItem(mi_Replays_list );

      changed:=true;
      case menu_ItemSelected of
//98: if not(G_Started)then
//    ScrollInt(@camp_list_scroll, 1,0,LastMission     -menu_BaseListH);
mi_SaveLoad_list       : ScrollInt(@svld_list_scroll, 10,0,svld_list_size-menu_BaseListH,false);
mi_Replays_list        : ScrollInt(@rpls_list_scroll, 10,0,rpls_list_size-menu_BaseListH,false);
      else changed:=false;
      end;
      menu_update:=menu_update or changed;
   end;

   if(InputActionPressed(iact_MWU))then
   begin
      SetSelectedItem(mi_SaveLoad_list);
      SetSelectedItem(mi_Replays_list );

      changed:=true;
      case menu_ItemSelected of
//98: if not(G_Started)then
//    ScrollInt(@camp_list_scroll, 1,0,LastMission     -menu_BaseListH);
mi_SaveLoad_list       : ScrollInt(@svld_list_scroll,-10,0,svld_list_size-menu_BaseListH,false);
mi_Replays_list        : ScrollInt(@rpls_list_scroll,-10,0,rpls_list_size-menu_BaseListH,false);
      else changed:=false;
      end;
      menu_update:=menu_update or changed;
   end;

///////////////////////////////////
///////////////////////////////////   text input
///////////////////////////////////
   if(length(k_KeyboardString)>0)then
   begin
      SetSelectedItem(mi_SaveLoad_fname);
      SetSelectedItem(mi_MP_Chat);

      changed:=false;
      case menu_ItemSelected of
mi_SG_PlayerName   : PlayerName        :=    StringApplyInput(PlayerName            ,CharSetCommon,MaxPlayerNameLen   ,@changed);
mi_SR_RecordPrefix : rpls_NamePrefix   :=    StringApplyInput(rpls_NamePrefix       ,CharSetCommon,SvRpLen            ,@changed);

mi_SV_ResolutionW  : menu_ResolutionWi :=s2i(StringApplyInput(i2s(menu_ResolutionWi),CharSetDigits,4                  ,@changed));
mi_SV_ResolutionH  : menu_ResolutionHi :=s2i(StringApplyInput(i2s(menu_ResolutionHi),CharSetDigits,4                  ,@changed));

mi_SaveLoad_fname  : svld_str_fname    :=    StringApplyInput(svld_str_fname        ,CharSetCommon,menu_ListLineWChars,@changed);

mi_Map_Seed        : menu_mseed        :=    StringApplyInput(menu_mseed            ,CharSetDigits,10                 ,@changed);

mi_MP_ServerPort   : menu_ServerPort   :=    StringApplyInput(menu_ServerPort       ,CharSetDigits,5                  ,@changed);
mi_MP_ClientAddress: menu_ClientAddress:=    StringApplyInput(menu_ClientAddress    ,CharSetCommon,30                 ,@changed);
mi_MP_Chat         : net_chat_str      :=    StringApplyInput(net_chat_str          ,CharSetCommon,255                ,@changed);
      end;

      menu_update:=menu_update or changed;
   end;

///////////////////////////////////
///////////////////////////////////   other keys
///////////////////////////////////

   if(InputActionPressed(iact_Esc   ))then GameBack(false,false);
   if(InputActionPressed(iact_Return))then menu_EndEdition(true);

  // if(InputActionPressed(iAct_test_debug0      ))then writeln(GameBack(false,true));
  // if(InputActionPressed(iAct_test_debug1      ))then ;

   if(clickSound)then SoundPlayUI(snd_click);

   mouse_x:=mnx;
   mouse_y:=mny;
end;

