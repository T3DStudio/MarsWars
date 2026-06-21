
////////////////////////////////////////////////////////////////////////////////
//
//   MENU COMMON

function StringApplyInput(s:shortstring;charset:TSoc;maxLength:byte;changedVar:pboolean):shortstring;
var i:byte;
    c:char;
begin
   StringApplyInput:=s;
   if(InputActionPressed(iAct_backspace))
   or(InputActionStuck  (iAct_backspace))then
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

procedure menu_GetBarValByte(mi:byte;vvar:pbyte;vmin,vmax:byte);
var
bstartX,
bendX  :integer;
begin
   with menu_items[mi] do
     if(mi_state=as_enabled)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1)then
     begin
        bendX  :=mi_x1-menu_BarStepX;
        bstartX:=bendX-(vmax-vmin);

        if(bendX<=mouse_x)and(mouse_x<=mi_x1)then
        begin
           if(vvar^<vmax)then vvar^+=1;
        end
        else
          if(mi_x0<=mouse_x)and(mouse_x<=bstartX)then
          begin
             if(vvar^>vmin)then vvar^-=1;
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
       if(mi_state=as_enabled)then
         if(mi_x0<mouse_x)and(mouse_x<mi_x1)and(mi_y0<mouse_y)and(mouse_y<mi_y1)then
           menu_MouseXY2Item:=i;
end;

function menu_HelpSelectUID(mi:byte;forBalance:boolean=false):byte;
var
tx,ty:integer;
u    :byte;
begin
   menu_HelpSelectUID:=0;
   menu_HelpScroll:=0;
   with menu_items[mi] do
   begin
      tx:=mi_x0;
      ty:=mi_y0;
      for u:=1 to 255 do
        with g_uids[u] do
          if(IsUIDValidForHelpTable(u,forBalance))then
          begin
             if (tx<=mouse_x)and(mouse_x<=(tx+ui_ButtonWh))
             and(ty<=mouse_y)and(mouse_y<=(ty+ui_ButtonWh))then
             begin
                menu_HelpSelectUID:=u;
                exit;
             end;

             tx+=ui_ButtonWh;
             if(tx>=mi_x1)then
             begin
                tx:=mi_x0;
                ty+=ui_ButtonWh;
             end;
          end;
   end;
end;

procedure menu_FixScroll(scrollVar:pinteger;listSel,listSize:integer);
begin
   if(listSel<scrollVar^)
   then scrollVar^:=listSel
   else
     if((scrollVar^+listSize)<=listSel)
     then scrollVar^:=listSel-listSize+1;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   MENU ACTIONS

procedure menu_ControlPanelPosScroll(forward:boolean);
begin
   ScrollByte(@ui_ControlPanelPos,forward,0,ui_MaxControlPanelPos);
   vid_RemakeScreenSurfaces;
   theme_map_pTerrain:=255;
   gfx_MapMakeTerrain;
   ui_InitControlPanelBTNActions;
end;

function menu_ReadyButtonEnabled:boolean;
begin
   menu_ReadyButtonEnabled:=(net_status=ns_client)and(not g_started);
end;

procedure menu_msgBox_Set(str_caption,str_body:shortstring;mtype:TMenuMessageBoxType);
begin
   if(menu_msg_type<>mtype)then
   begin
      menu_update     :=true;
      menu_msg_type   :=mtype;
      menu_msg_Caption:=str_caption;
      menu_msg_Body   :=str_body;
      menu_ItemActs   :=0;
   end;
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
   or(G_Started)
   or(menu_msg_type<>mmbt_none)then exit;

   case start of
   true : begin   // start
             if(net_status<>ns_none)
             or(g_LobbyTimer>0)then exit;
             GameNetServer:=true;
             if(check)then exit;

             menu_GetServerPort;
             if(net_UpSocket(net_ServerPort))then
             begin
                net_status:=ns_server;
                PlayersSetDefault;
             end
             else menu_msgBox_Set(str_Caption_Multiplayer,str_Caption_Server+': '+str_gmsg_PortBlocked,mmbt_netPortBlock);
          end;
   false: begin   // stop
             if(net_status<>ns_server)then exit;
             GameNetServer:=true;
             if(check)then exit;

             GameResetNetGame;
          end;
   end;
end;
function GameNetClient(connect,check:boolean):boolean;
begin
   GameNetClient:=false;

   if(menu_msg_type<>mmbt_none)then exit;

   case connect of
   true : begin   // start connecting
             if(net_status<>ns_none)
             or(rpls_pstate=rpls_read)
             or(g_LobbyTimer>0)
             or(G_Started)then exit;
             GameNetClient:=true;
             if(check)then exit;

             menu_ClientAddress:=menu_GetClientAddress(menu_ClientAddress,@net_cl_svip,@net_cl_svport);
             if(net_UpSocket(0))then
             begin
                net_status   :=ns_client;
                rpls_pnu     :=0;
                net_SvList   :=false;
                net_cl_Hoster:=255;
                net_cl_svttl :=TTLServer;
                net_cl_log_n :=net_cl_log_n.MaxValue;
                PlayerReady  :=false;
                menu_msgBox_Set(str_Caption_Multiplayer,menu_ClientAddress+' - '+str_gstat_WaitForServer,mmbt_netWaitServer);
                PlayersClearLog;
             end
             else menu_msgBox_Set(str_Caption_Multiplayer,str_Caption_Client+': '+str_gmsg_PortBlocked,mmbt_netPortBlock);
          end;
   false: begin   // disconnect
             if(net_status<>ns_client)then exit;
             GameNetClient:=true;
             if(check)then exit;

             net_disconnect;
             GameResetNetGame;
          end;
   end;
end;
function GameNetServerList(start,check:boolean):boolean;
begin
   GameNetServerList:=false;

   if(rpls_pstate<>rpls_none)
   or(G_Started)
   or(menu_msg_type<>mmbt_none)then exit;

   case start of
   true : begin
             if(net_SvList)
             or(g_LobbyTimer>0)
             or(net_status<>ns_none)then exit;
             GameNetServerList:=true;
             if(check)then exit;

             if(net_UpSocket(net_svLanAdv_port))then
             begin
                net_status:=ns_client;
                net_SvList:=true;
                net_TimerBase:=0;
             end
             else menu_msgBox_Set(str_Caption_Multiplayer,str_net_ServerList+': '+str_gmsg_PortBlocked,mmbt_netPortBlock);
          end;
   false: begin
             if(not net_SvList)
             or(net_status<>ns_client)then exit;
             GameNetServerList:=true;
             if(check)then exit;

             net_dispose;
             net_status:=ns_none;
             net_SvList:=false;
          end;
   end;
end;

procedure GameNetServerListSelectedInfo;
begin
   if(net_SvList_sel<0)or(net_SvList_Size<=net_SvList_sel)
   then menu_ClientAddress:=''
   else
     with net_SvList_listi[net_SvList_sel] do
       menu_ClientAddress:=si_line;
end;

procedure GameNetServerListSelect(mi:byte);
begin
   menu_ListMouseXY2Line(mi,@net_SvList_sel,net_SvList_scroll,menu_ServerLineH);
   GameNetServerListSelectedInfo;
end;

function GameNetServerListConnect(check:boolean):boolean;
begin
   GameNetServerListConnect:=false;

   if(rpls_pstate<>rpls_none)
   or(G_Started)
   or(net_status<>ns_client)
   or(not net_SvList)
   or(length(menu_ClientAddress)=0)
   then exit;

   GameNetServerListConnect:=true;

   if(check)then exit;

   net_dispose;
   net_SvList:=false;
   net_status:=ns_none;

   GameNetClient(true,false);
end;

function GameNetServerListAdd(check:boolean):boolean;
begin
   GameNetServerListAdd:=false;

   if(not net_SvList)
   or(length(menu_ClientAddress)=0)
   or(not net_ServerListAdd(menu_ClientAddress,true))
   then exit;

   GameNetServerListAdd:=true;

   if(check)then exit;

   if(net_ServerListAdd(menu_ClientAddress,false))then
   begin
      net_SvList_sel:=net_SvList_Size-1;
      if((net_SvList_scroll+menu_ServerListH)<=net_SvList_sel)then
        net_SvList_scroll:=net_SvList_Size-menu_ServerListH;
   end;
end;

function GameNetServerListDeleteInit(check:boolean):boolean;
begin
   GameNetServerListDeleteInit:=false;

   if(not net_SvList)
   or(net_SvList_sel<0)
   or(net_SvList_Size<=net_SvList_sel)
   then exit;

   GameNetServerListDeleteInit:=true;

   if(check)then exit;

   with net_SvList_listi[net_SvList_sel] do
     menu_msgBox_Set(str_FileDelete,si_line,mmbt_DeleteServer);
end;

function GameNetServerListDelete(svline:shortstring):boolean;
var delItem:integer;
begin
   GameNetServerListDelete:=false;

   if(not net_SvList)then exit;

   delItem:=-1;

   if(net_SvList_Size>0)then
     for delItem:=0 to net_SvList_Size-1 do
       with net_SvList_listi[delItem] do
         if(si_line=svline)then break;

   if(delItem<0)then exit;

   GameNetServerListDelete:=true;

   net_SvList_sel:=delItem;

   delete(net_SvList_listi,net_SvList_sel,1);
   delete(net_SvList_lists,net_SvList_sel,1);
   net_SvList_Size-=1;
   if(net_SvList_Scroll>0)then
     net_SvList_Scroll-=1;

   //menu_FixScroll(@net_SvList_scroll,net_SvList_sel,menu_ServerListH);
end;


////////////////////////////////////////////////////////////////////////////////
//
//   MENU STRUCTURE
//

var
mtx0,mty0,
mtx1    : integer;

/////   BASIC

procedure menu_Item_Set(mi:byte;x0,y0,x1,y1:integer;enabled:boolean;maxChars:byte=0);
begin
   with menu_items[mi] do
   begin
      mi_x0:=min2i(x0,x1);
      mi_y0:=min2i(y0,y1);
      mi_x1:=max2i(x0,x1);
      mi_y1:=max2i(y0,y1);

      mi_xc:= (mi_x0+mi_x1) div 2;
      mi_yc:=((mi_y0+mi_y1) div 2)+1;

      if(maxChars>0)
      then mi_charw:=maxChars
      else mi_charw:=(mi_x1-mi_x0-font_w1) div font_w1;

      case enabled of
      false: mi_state:=as_disabled;
      true : mi_state:=as_enabled;
      end;
   end;
end;
procedure menu_item_setEnabled(mi:byte;enabled:boolean);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
       case enabled of
       false: mi_state:=as_disabled;
       true : mi_state:=as_enabled;
       end;
end;

procedure menu_page_BottomButtons(b1,b2,b3,b4,b5,b6,b7:byte);
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
   if(b7>0)then n+=1;

   if(n=0)then exit;

   mty0:=menu_LowerBorderY;

   gapX:=0;
   if(n>1)then
   begin
      gapX:=(menu_w-menu_BaseW1-(menu_BigButtonW*n)) div (n-1);
      if(gapX>menu_BaseW1)then gapX:=menu_BaseW1;
      mtx0  :=menu_hw-((menu_BigButtonW*n)+gapX*(n-1)) div 2;
   end
   else mtx0:=menu_hw-(menu_BigButtonW div 2);

   if(b1>0)then begin menu_Item_Set(b1,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b2>0)then begin menu_Item_Set(b2,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b3>0)then begin menu_Item_Set(b3,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b4>0)then begin menu_Item_Set(b4,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b5>0)then begin menu_Item_Set(b5,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b6>0)then begin menu_Item_Set(b6,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mtx0+=menu_BigButtonW+gapX;end;
   if(b7>0)then begin menu_Item_Set(b7,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);                           end;
end;

procedure menu_page_TopCaption(mi:byte);
begin
   menu_Item_Set(mi,menu_hw-menu_CaptionhW,menu_underLogoY,menu_hw+menu_CaptionhW,menu_underLogoY+menu_CaptionH,true);
end;

/////   MAIN

procedure menu_page_SaveLoad;
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_SaveLoad);

   mtx0:=menu_BaseW1;
   mtx1:=mtx0+menu_ListW1;
   mty0:=menu_ListLineH*menu_BaseList1H;

   menu_Item_Set(mi_SaveLoad_list   ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true);

   mtx0:=mtx1+menu_BaseW1;
   mtx1:=menu_w-menu_BaseW1;
   menu_Item_Set(mi_SaveLoad_info   ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true,255);

   with menu_items[mi_SaveLoad_list] do
   menu_Item_Set(mi_SaveLoad_fname  ,mi_x0,mi_y1,mi_x1,mi_y1+menu_ListLineH,true);

   if(g_started)and(rpls_pstate<>rpls_read)
   then menu_page_BottomButtons(mi_back,mi_SaveLoad_save,mi_SaveLoad_load,mi_SaveLoad_delete  ,0,0,0)
   else menu_page_BottomButtons(mi_back,                 mi_SaveLoad_load,mi_SaveLoad_delete,0,0,0,0);

   menu_item_setEnabled(mi_SaveLoad_save  ,saveload_Save  (true));
   menu_item_setEnabled(mi_SaveLoad_load  ,saveload_Load  (true));
   menu_item_setEnabled(mi_SaveLoad_delete,saveload_DeleteInit(true));
end;

procedure menu_page_Replays;
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_Replays);

   mtx0:=menu_BaseW1;
   mtx1:=mtx0+menu_ListW1;
   mty0:=menu_ListLineH*menu_BaseList1H;

   menu_Item_Set(mi_Replays_list    ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true);

   mtx0:=mtx1+menu_BaseW1;
   mtx1:=menu_w-menu_BaseW1;
   menu_Item_Set(mi_Replays_info    ,mtx0,menu_underCaptionY,mtx1,menu_underCaptionY+mty0,true,255);

   menu_page_BottomButtons(mi_back,mi_Replays_play,mi_Replays_delete,0,0,0,0);

   menu_item_setEnabled(mi_Replays_play  ,replay_Play  (true));
   menu_item_setEnabled(mi_Replays_delete,replay_DeleteInit(true));
end;

procedure menu_page_Settings;
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_Settings);

   mtx0:=menu_border1;
   mty0:=menu_underCaptionY;
   menu_Item_Set(mi_settings_Game   ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BaseW1;
   menu_Item_Set(mi_settings_Record ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BaseW1;
   menu_Item_Set(mi_settings_Video  ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BaseW1;
   menu_Item_Set(mi_settings_Sound  ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);

   mtx0:=menu_border1+menu_BigButtonW+menu_BaseW1;
   mtx1:=menu_w-menu_border1;
   mty0:=menu_underCaptionY;

   case menu_SettingsPage of
   mi_settings_Game  : begin
                          menu_Item_Set(mi_SG_PlayerName       ,mtx0,mty0,mtx1,mty0+menu_SmallW,PlayerNameChangeble);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_Language         ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ColoredShadows   ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_PlayersColor     ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ShowAPM          ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_HealthBars       ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_RightClickAction ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ScrollSpeed      ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_MouseScroll      ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ControlPanelPos  ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ControlPanelAuto ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SG_ShowPlayerScrns  ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
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
                          menu_Item_Set(mi_SS_RenewPlaylist   ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                          menu_Item_Set(mi_SS_ReloadPlaylist  ,mtx0,mty0,mtx1,mty0+menu_SmallW,true);mty0+=menu_SmallW;
                       end;
   end;

   menu_page_BottomButtons(mi_back,0,0,0,0,0,0);
end;

procedure menu_page_Help;
var tx:integer;
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_Help);

   mtx0:=menu_BaseW1;
   mty0:=menu_underCaptionY;
   menu_Item_Set(mi_help_Credits      ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_GameControls ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_GameHotKeys  ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_GameUI       ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_GameMechanics,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_UnitsInfo    ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_UnitsBalance ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;
   menu_Item_Set(mi_help_Other        ,mtx0,mty0,mtx0+menu_BigButtonW,mty0+menu_BigButtonH,true);mty0+=menu_BigButtonH+menu_BigButtonq;

   case menu_HelpPage of
   mi_help_GameControls,
   mi_help_GameMechanics,
   mi_help_GameHotKeys,
   mi_help_GameUI,
   mi_help_Other,
   mi_help_Credits     : begin
                            tx:=mtx0+menu_BigButtonW+menu_BaseW1;
                            menu_Item_Set(mi_help_InfoList,tx,menu_underCaptionY,
                                                           tx+(ui_DocLineLen2*font_w1)+font_w1,menu_LowerBorderY-menu_BigButtonH,true);
                         end;
   mi_help_UnitsBalance,
   mi_help_UnitsInfo   : begin
                            tx:=mtx0+menu_BigButtonW+menu_BaseW1;
                            menu_Item_Set(mi_help_InfoPanel,tx,menu_underCaptionY,
                                                            tx+ui_ButtonWh*menu_HelpUnitsBTNsL,menu_underCaptionY+ui_ButtonWh*15,true);

                            tx:=menu_items[mi_help_InfoPanel].mi_x1+menu_BaseWh;
                            menu_Item_Set(mi_help_InfoList,tx,menu_underCaptionY,
                                                           tx+(ui_DocLineLen1*font_w1)+font_w1,menu_LowerBorderY-menu_BigButtonH,true);
                         end;
   end;

   menu_page_BottomButtons(mi_back,0,0,0,0,0,0);
end;

procedure menu_page_Scirmish_Players(x0,x1,y0:integer);
var p:byte;
begin
   mtx0:=x0;
   mtx1:=x1;
   mty0:=y0;
   menu_Item_Set(mi_Players_Panel,mtx0,mty0,mtx1,mty0+menu_ListLineH*9,true);

   mty0+=menu_ListLineH-2;
   mtx0:=menu_items[mi_Players_Panel].mi_x0;
   menu_Item_Set(mi_Players_CState   ,mtx0,mty0,mtx0+menu_PlayersStateW,mty0+menu_ListLineH,false,9);mtx0+=menu_PlayersStateW;
   menu_Item_Set(mi_Players_CName    ,mtx0,mty0,mtx0+menu_PlayersNameW ,mty0+menu_ListLineH,false,9);mtx0+=menu_PlayersNameW;
   menu_Item_Set(mi_Players_CRace    ,mtx0,mty0,mtx0+menu_PlayersRaceW ,mty0+menu_ListLineH,false,9);mtx0+=menu_PlayersRaceW;
   menu_Item_Set(mi_Players_CTeam    ,mtx0,mty0,mtx0+menu_PlayersTeamW ,mty0+menu_ListLineH,false,9);mtx0+=menu_PlayersTeamW;
   menu_Item_Set(mi_Players_CObs     ,mtx0,mty0,mtx0+menu_PlayersObsW  ,mty0+menu_ListLineH,false,9);mtx0+=menu_PlayersObsW;
   menu_Item_Set(mi_Players_CColor   ,mtx0,mty0,mtx0+menu_PlayersPingW ,mty0+menu_ListLineH,false,9);
   if(net_status<>ns_none)then
   menu_Item_Set(mi_Players_CPing    ,mtx0,mty0-menu_ListLinehH,mtx0+menu_PlayersPingW,mty0,false,9);mtx0+=menu_PlayersPingW;

   mty0+=menu_ListLineH;
   for p:=0 to LastPlayer do
   begin
      mtx0:=menu_items[mi_Players_Panel].mi_x0;
      if(p<map_MaxPlayers)or(g_PlayersMain[p].state=ps_Human)then
      menu_Item_Set(mi_Players_State0   +p,mtx0,mty0,mtx0+menu_PlayersStateW,mty0+menu_PListLineH,PlayerAIToggle      (p,LocalPlayer,true)   ,9);mtx0+=menu_PlayersStateW;

      if(g_PlayersMain[p].state=ps_None)and(not g_started)then
      menu_Item_Set(mi_Players_Slot0    +p,mtx0,mty0,mtx0+menu_PlayersNameW ,mty0+menu_PListLineH,PlayersSwap         (p,LocalPlayer,true))
      else
      menu_Item_Set(mi_Players_AIskil0  +p,mtx0,mty0,mtx0+menu_PlayersNameW ,mty0+menu_PListLineH,PlayerAILevelScroll (p,LocalPlayer,true,true));mtx0+=menu_PlayersNameW;

      if(p<map_MaxPlayers)and(not g_PlayersMain[p].isobserver)then
      menu_Item_Set(mi_Players_Race0    +p,mtx0,mty0,mtx0+menu_PlayersRaceW ,mty0+menu_PListLineH,PlayerRaceScroll    (p,LocalPlayer,true)     );mtx0+=menu_PlayersRaceW;
      if(p<map_MaxPlayers)and(not g_PlayersMain[p].isobserver)then
      menu_Item_Set(mi_Players_Team0    +p,mtx0,mty0,mtx0+menu_PlayersTeamW ,mty0+menu_PListLineH,PlayerTeamScroll    (p,LocalPlayer,true,true));mtx0+=menu_PlayersTeamW;

      menu_Item_Set(mi_Players_Obs0     +p,mtx0,mty0,mtx0+menu_PlayersObsW  ,mty0+menu_PListLineH,PlayerToggleObserver(p,LocalPlayer,true)   ,9);mtx0+=menu_PlayersObsW;
      menu_Item_Set(mi_Players_Ping0    +p,mtx0,mty0,mtx0+menu_PlayersPingW ,mty0+menu_PListLineH,true                                       ,9);mtx0+=menu_PlayersPingW;

      mty0+=menu_PListLineH;
   end;
   mtx0:=menu_items[mi_Players_Panel].mi_x0;
end;

procedure menu_page_Scirmish_Map(x0,x1,y0:integer);
begin
   mtx0:=x0;
   mtx1:=x1;
   mty0:=y0;

   menu_Item_Set(mi_Map_Panel,mtx0,mty0,mtx1,mty0+menu_BaseW1+ui_CtrlPanelW+menu_BasehW,true);

   with menu_items[mi_Map_Panel] do
   menu_Item_Set(mi_Map_Map,mi_x1-menu_BasehW-ui_CtrlPanelW,mi_y0+menu_BaseW1,
                            mi_x1-menu_BasehW              ,mi_y0+menu_BaseW1+ui_CtrlPanelW,true);

   mtx0+=menu_BasehW;
   mtx1:=menu_items[mi_Map_Map].mi_x0-menu_BasehW;
   mty0+=menu_BaseW1;

   menu_Item_Set(mi_Map_Scenario  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Generators,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Seed      ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Size      ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Template  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Symmetry  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Theme     ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Map_Random    ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;

   menu_item_setEnabled(mi_Map_Scenario,GameSetOption(LocalPlayer,0,true,true));
   menu_items[mi_Map_Generators].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Seed      ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Size      ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Template  ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Symmetry  ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Map_Random    ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
end;

procedure menu_page_Scirmish_GOptions(x0,x1,y0:integer);
begin
   mtx0:=x0;
   mtx1:=x1;
   mty0:=y0;

   menu_Item_Set(mi_Game_Panel         ,mtx0,mty0,mtx1,mty0+menu_ListLineH*6+menu_BaseW1,true);
   mtx0+=menu_BasehW;
   mtx1-=menu_BasehW;
   mty0+=menu_ListLineH+menu_BasehW;

   menu_Item_Set(mi_Game_FixedPositions,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Game_AISlots       ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
   menu_Item_Set(mi_Game_NewObservers   ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);mty0+=menu_ListLineH;
                                                                       mty0+=menu_ListLineH;
   menu_Item_Set(mi_Game_Random        ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true);

   menu_items[mi_Game_FixedPositions].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Game_AISlots       ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Game_NewObservers   ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
   menu_items[mi_Game_Random        ].mi_state:=menu_items[mi_Map_Scenario].mi_state;
end;

procedure menu_page_Scirmish_MP(x0,x1,y0:integer);
var cx:integer;
begin
   mtx0:=x0;
   mtx1:=x1;
   cx:=(mtx0+mtx1) div 2;
   mty0:=y0;

   menu_Item_Set(mi_MP_Panel          ,mtx0,mty0,mtx1,menu_items[mi_Game_Panel].mi_y1,true);
   mtx0+=menu_BasehW;
   mtx1-=menu_BasehW;
   mty0+=menu_ListLineH+menu_BasehW;

   case net_status of
   ns_none    : begin
                   menu_Item_Set(mi_MP_ServerToggle    ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetServer      (true ,true));mty0+=menu_ListLineH;
                   menu_Item_Set(mi_MP_ServerPort      ,mtx0,mty0,cx  ,mty0+menu_ListLineH,GameNetServer      (true ,true));
                   menu_Item_Set(mi_MP_ServerLANVis    ,cx  ,mty0,mtx1,mty0+menu_ListLineH,true                           );mty0+=menu_ListLineH;
                                                                                                                            mty0+=menu_ListLineH;
                   menu_Item_Set(mi_MP_Connect         ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetClient      (true ,true));mty0+=menu_ListLineH;
                   menu_Item_Set(mi_MP_ClientAddress   ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetClient      (true ,true));mty0+=menu_ListLineH;
                   menu_Item_Set(mi_MP_ClientServerList,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetServerList(true ,true));mty0+=menu_ListLineH;
                end;
   ns_server  : begin
                   mty0-=menu_ListLineH;
                   menu_Item_Set(mi_MP_ServerPort      ,mtx0,mty0,cx  ,mty0+menu_ListLineH,false                     );
                   menu_Item_Set(mi_MP_ServerLANVis    ,cx  ,mty0,mtx1,mty0+menu_ListLineH,true                      );mty0+=menu_ListLineH;
                   menu_Item_Set(mi_MP_ServerToggle    ,mtx0,mty0,mtx1,mty0+menu_ListLineH,GameNetServer(false,true ));mty0+=menu_ListLineH;
                   with menu_items[mi_MP_Panel] do
                   begin
                   menu_Item_Set(mi_MP_ChatList        ,mi_x0,mty0,mi_x1,mi_y1-txt_line_h1,true);
                   menu_Item_Set(mi_MP_ChatLine        ,mi_x0,mi_y1-txt_line_h1,mi_x1,mi_y1,true);
                   end;
                end;
   ns_client  : begin
                   mty0-=menu_ListLineH;
                   menu_Item_Set(mi_MP_ClientAddress  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,false                     );mty0+=menu_ListLineH;

                   menu_Item_Set(mi_MP_ClientQuality  ,mtx0,mty0,mtx1,mty0+menu_ListLineH,true                      );mty0+=menu_ListLineH;
                   with menu_items[mi_MP_Panel] do
                   begin
                   menu_Item_Set(mi_MP_ChatList       ,mi_x0,mty0,mi_x1,mi_y1-txt_line_h1,true);
                   menu_Item_Set(mi_MP_ChatLine       ,mi_x0,mi_y1-txt_line_h1,mi_x1,mi_y1,true);
                   end;
                end;
   end;

   with menu_items[mi_MP_ChatList] do
   menu_ChatListH:=(mi_y1-mi_y0-font_wh) div txt_line_h1;
end;

procedure menu_page_Scirmish;
var
btns : array[0..6] of byte = (0,0,0,0,0,0,0);
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_Scirmish);
   with menu_items[mi_caption_Scirmish] do
   menu_Item_Set(mi_SubCaptionInfoLine,0,mi_y1,menu_w,mi_y1+menu_BaseWh,true);

   // bottom buttons
   if(g_LobbyTimer>0)and(net_status<>ns_client)
   then btns[0]:=mi_StopTimer
   else
   begin
      if(MenuBack(false,true))then btns[0]:=mi_back;
      if(saveload_Allowed)and(g_started)then btns[1]:=mi_SaveLoad;
      btns[2]:=mi_Settings;
      btns[3]:=mi_Help;

      if(PlayerSurrender(LocalPlayer,true))then btns[4]:=mi_Surrender;

      case net_status of
      ns_none,
      ns_server: case g_started of
                 true : btns[5]:=mi_Break;
                 false: btns[5]:=mi_StartTimer;
                 end;
      ns_client: btns[5]:=mi_MP_Disconnect;
      end;
      if(menu_ReadyButtonEnabled)then btns[6]:=mi_Players_Ready;

   end;

   menu_page_BottomButtons(btns[0],btns[1],btns[2],btns[3],btns[4],btns[5],btns[6]);

   menu_Item_Set(mi_UnderBottomInfoLine,0     ,menu_h-menu_StepFromBottom-menu_BigButtonH*2,
                                        menu_w,menu_h-menu_StepFromBottom-menu_BigButtonH  ,true);

   // PLAYERS BLOCK
   menu_page_Scirmish_Players (menu_BaseW1h,menu_BaseW1h+menu_PlayersW,menu_underCaptionY);

   // MAP BLOCK
   with menu_items[mi_Players_Panel] do
   menu_page_Scirmish_Map     (mi_x1+menu_BaseW1,mi_x1+menu_BaseW1*14,menu_underCaptionY);

   // GAME OPTIONS BLOCK
   with menu_items[mi_Map_Panel] do
   menu_page_Scirmish_GOptions(mi_x0,mi_x1,mi_y1+menu_BaseW1);

   // MULTIPLAYER BLOCK
   if(rpls_pstate<>rpls_read)then
   with menu_items[mi_Players_Panel] do
   menu_page_Scirmish_MP      (mi_x0,mi_x1,mi_y1+menu_BaseW1);
end;

procedure menu_page_Campaing;
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_Campaings);

   mtx0:=menu_BaseW1;
   mty0:=menu_underCaptionY;
   menu_Item_Set(mi_camp_Difficulty ,mtx0,mty0,mtx0+menu_CampListW,mty0+menu_BigButtonH,not g_started);mty0+=menu_BigButtonH+menu_BigButtonH;
   menu_Item_Set(mi_camp_Campaigns  ,mtx0,mty0,mtx0+menu_CampListW,mty0+menu_CampListH ,not g_started);mty0+=menu_BigButtonH+menu_CampListH;
   menu_Item_Set(mi_camp_Missions   ,mtx0,mty0,mtx0+menu_CampListW,mty0+menu_MissListH ,not g_started);//mty0+=menu_BigButtonH+menu_MissListH;
   mtx0:=menu_BaseW2+menu_CampListW;
   menu_Item_Set(mi_camp_MissionInfo,mtx0,menu_underCaptionY,menu_w-menu_BaseW1,menu_LowerBorderY-menu_BigButtonH,not g_started);

   if(g_started)
   then menu_page_BottomButtons(mi_back,mi_SaveLoad,mi_Settings,mi_Help,mi_Break   ,0,0)
   else menu_page_BottomButtons(mi_back,0          ,mi_Settings,mi_Help,mi_StartNow,0,0);
end;

procedure menu_net_ServerList;
begin
   menu_DarkBack:=true;
   menu_page_TopCaption(mi_caption_SVSearch);

   menu_Item_Set(mi_NetServers_List,menu_BaseW1       ,menu_underCaptionY,
                                    menu_w-menu_BaseW1,menu_underCaptionY+menu_ServerLineH*menu_ServerListH,true);

   with menu_items[mi_NetServers_List] do
   menu_Item_Set(mi_MP_ClientAddress,mi_xc-menu_ServerListAddrWh,mi_y1+font_w1,
                                     mi_xc+menu_ServerListAddrWh,mi_y1+font_w1+menu_ListLineH,true);

   menu_page_BottomButtons(mi_back,mi_NetServers_Connect,mi_NetServers_Add,mi_NetServers_Delete,0,0,0);

   menu_item_setEnabled(mi_NetServers_Connect,GameNetServerListConnect   (true));
   menu_item_setEnabled(mi_NetServers_Add    ,GameNetServerListAdd       (true));
   menu_item_setEnabled(mi_NetServers_Delete ,GameNetServerListDeleteInit(true));
end;

////////////////////////////////////////////////////////////////////////////////

procedure menu_Rebuild;
begin
   menu_DarkBack:=false;
   FillChar(menu_items,SizeOf(Menu_items),0);

   if(net_SvList)
   then menu_net_ServerList
   else
     case menu_page of
     mi_SaveLoad: menu_page_SaveLoad;
     mi_Replays : menu_page_Replays;
     mi_Settings: menu_page_Settings;
     mi_Help    : menu_page_Help;
     else
       case g_type of
       gt_scirmish : menu_page_Scirmish;
       gt_campaing : menu_page_Campaing;
       else menu_page_BottomButtons(mi_Campaings,mi_Scirmish,mi_SaveLoad,mi_Replays,mi_Settings,mi_Help,mi_Exit);
       end;
       menu_item_setEnabled(mi_Break        ,GameBreak(true ));
       menu_item_setEnabled(mi_StartNow     ,GameStart(true ));
       menu_item_setEnabled(mi_StartTimer   ,GameStart(true )and(g_LobbyTimer<=0));
       menu_item_setEnabled(mi_StopTimer    ,g_LobbyTimer>0);
       menu_item_setEnabled(mi_Surrender    ,PlayerSurrender(LocalPlayer,true ));
       menu_item_setEnabled(mi_MP_Disconnect,GameNetClient(false,true));
     end;
   menu_item_setEnabled(mi_SaveLoad        ,saveload_Allowed);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MENU MAIN CODE
//

function menu_KeyEnter:boolean;
begin
   menu_KeyEnter:=false;

   if(Menu_items[mi_Replays_list].mi_state=as_enabled)then
   begin
      menu_KeyEnter:=true;
      replay_Play(false);
   end
   else
     if(Menu_items[mi_SaveLoad_list].mi_state=as_enabled)and(not g_started)then
     begin
        menu_KeyEnter:=true;
        saveload_Load(false);
     end
     else
       if(Menu_items[mi_NetServers_List].mi_state=as_enabled)then
       begin
          menu_KeyEnter:=true;
          GameNetServerListConnect(false);
       end;
end;

function menu_EndEdition(EnterKey:boolean):boolean;
begin
   menu_EndEdition:=true;
   case menu_ItemSelected of
mi_SG_PlayerName   : g_PlayersMain[LocalPlayer].name:=PlayerName;
mi_Map_Seed        : if(not GameMapSetSeed(LocalPlayer,0,true))
                     then menu_mseed:=c2s(map_seed)
                     else GameMapSetSeed(LocalPlayer,s2c(menu_mseed),false);
mi_MP_ServerPort   : menu_GetServerPort;
mi_MP_ClientAddress: menu_ClientAddress:=menu_GetClientAddress(menu_ClientAddress,@net_cl_svip,@net_cl_svport);
mi_MP_ChatLine,
mi_MP_ChatList     : if(EnterKey)then
                     begin
                        if(length(net_chat_str)>0)then
                          if(net_status=ns_client)
                          then net_send_chat(            255,net_chat_str)
                          else GameLog_Chat (LocalPlayer,255,net_chat_str);
                        net_chat_str:='';
                     end;
   else
     if(EnterKey)
     then menu_EndEdition:=menu_KeyEnter
     else menu_EndEdition:=false;
   end;
   menu_ItemSelected:=0;
   menu_update:=menu_EndEdition or menu_update;
end;

function menu_KeyUp:boolean;
begin
   menu_KeyUp:=false;

   if(Menu_items[mi_Replays_list].mi_state=as_enabled)then
   begin
      if(rpls_list_sel>0)then
      begin
         rpls_list_sel-=1;
         replay_MenuSelectedInfo;
         menu_FixScroll(@rpls_list_scroll,rpls_list_sel,menu_BaseList1H);
         menu_KeyUp:=true;
      end;
   end
   else
     if(Menu_items[mi_SaveLoad_list].mi_state=as_enabled)then
     begin
        if(svld_list_sel>0)then
        begin
           svld_list_sel-=1;
           saveload_MenuSelectedInfo;
           menu_FixScroll(@svld_list_scroll,svld_list_sel,menu_BaseList1H);
           menu_KeyUp:=true;
        end;
     end
     else
       if(Menu_items[mi_NetServers_List].mi_state=as_enabled)then
       begin
          if(net_SvList_sel>0)then
          begin
             net_SvList_sel-=1;
             GameNetServerListSelectedInfo;
             menu_FixScroll(@net_SvList_scroll,net_SvList_sel,menu_ServerListH);
             menu_KeyUp:=true;
          end;
       end;
   menu_update:=menu_KeyUp or menu_update;
end;

function menu_KeyDown:boolean;
begin
   menu_KeyDown:=false;
   if(Menu_items[mi_Replays_list].mi_state=as_enabled)then
   begin
      if(rpls_list_sel<(rpls_list_Size-1))then
      begin
         rpls_list_sel+=1;
         replay_MenuSelectedInfo;
         menu_FixScroll(@rpls_list_scroll,rpls_list_sel,menu_BaseList1H);
         menu_KeyDown:=true;
      end;
   end
   else
     if(Menu_items[mi_SaveLoad_list].mi_state=as_enabled)then
     begin
        if(svld_list_sel<(svld_list_Size-1))then
        begin
           svld_list_sel+=1;
           saveload_MenuSelectedInfo;
           menu_FixScroll(@svld_list_scroll,svld_list_sel,menu_BaseList1H);
           menu_KeyDown:=true;
        end;
     end
     else
       if(Menu_items[mi_NetServers_List].mi_state=as_enabled)then
       begin
          if(net_SvList_sel<(net_SvList_Size-1))then
          begin
             net_SvList_sel+=1;
             GameNetServerListSelectedInfo;
             menu_FixScroll(@net_SvList_scroll,net_SvList_sel,menu_ServerListH);
             menu_KeyDown:=true;
          end;
       end;
   menu_update:=menu_KeyDown or menu_update;
end;

function menu_KeyDelete:boolean;
begin
   menu_KeyDelete:=false;
   if(Menu_items[mi_Replays_list].mi_state=as_enabled)
   then menu_KeyDelete:=replay_DeleteInit(false)
   else
     if(Menu_items[mi_SaveLoad_list].mi_state=as_enabled)
     then menu_KeyDelete:=saveload_DeleteInit(false)
     else
       if(Menu_items[mi_NetServers_List].mi_state=as_enabled)
       then menu_KeyDelete:=GameNetServerListDeleteInit(false);

   menu_update:=menu_KeyDelete or menu_update;
end;

function menu_Controls_MLB(item:byte;check:boolean):boolean;
begin
   menu_Controls_MLB:=true;
   case item of
mi_back                : if(not check)then MenuBack(false,false);
mi_exit                : if(not check)then GameCycle:=false;
mi_StartTimer          : if(not check)then {$IFDEF TESTMODE}
                                           if(TestMode>0)
                                           then g_LobbyTimer:=2
                                           else {$ENDIF}g_LobbyTimer:=g_GameStartTime;
mi_StopTimer           : if(not check)then begin
                                           g_LobbyTimer:=0;
                                           GameLog_BreakStarting;
                                           end;
mi_StartNow            : if(not check)then GameStart(false);
mi_Break               : if(not check)then GameBreak(false);
mi_Surrender           : if(not check)then
                           if(PlayerSurrender(LocalPlayer,false))then
                             if(MainMenu)then MenuBack(true,false);

mi_Campaings           : if(not check)then g_type:=gt_campaing;
mi_Scirmish            : if(not check)then g_type:=gt_scirmish;

mi_SaveLoad            : if(not check)then begin menu_page:=item;saveload_MakeFolderList;end;
mi_Replays             : if(not check)then begin menu_page:=item;  replay_MakeFolderList;end;
mi_Settings            : if(not check)then begin menu_page:=item; menu_ResolutionWi:=vid_vw;menu_ResolutionHi:=vid_vh;end;
mi_Help                : if(not check)then menu_page:=item;

// SETTINGS LIST
mi_settings_Game,
mi_settings_Record,
mi_settings_Video,
mi_settings_Sound      : if(not check)then menu_SettingsPage:=item;

// SETTINGS GAME
mi_SG_ColoredShadows   : if(not check)then ui_ColoredShadow:=not ui_ColoredShadow;
mi_SG_PlayersColor     : if(not check)then ScrollByte(@ui_PlayersColor,true,0,ui_MaxPlayersColor);
mi_SG_ShowAPM          : if(not check)then ui_ShowAPM      :=not ui_ShowAPM;
mi_SG_HealthBars       : if(not check)then ScrollByte(@ui_HealthBars,true,0,ui_MaxHealthBars);
mi_SG_RightClickAction : if(not check)then m_RightClickAct :=not m_RightClickAct;
mi_SG_ScrollSpeed      : if(not check)then menu_GetBarValByte(item,@ui_CamSpeed,1,ui_MaxCamSpeed);
mi_SG_MouseScroll      : if(not check)then ui_MouseScroll  :=not ui_MouseScroll;
mi_SG_PlayerName       : ;
mi_SG_Language         : if(not check)then begin ui_language:=not ui_language;SwitchLanguage;end;
mi_SG_ControlPanelPos  : if(not check)then menu_ControlPanelPosScroll(true);
mi_SG_ControlPanelAuto : if(not check)then ui_tab_Auto:=not ui_tab_Auto;
mi_SG_ShowPlayerScrns  : if(not check)then ui_PlayersScreens:=not ui_PlayersScreens;

// SETTINGS GAME RECORDING

mi_SR_RecordGames      : if(not check)then rpls_Record:=not rpls_Record;
mi_SR_RecordPrefix     : ;
mi_SR_RecordQuality    : if(not check)then ScrollByte(@rpls_Quality,true,0,rpls_MaxQuality);

// SETTINGS VIDEO

mi_SV_ResolutionW      :;
mi_SV_ResolutionH      :;
mi_SV_ResolutionApply  : if(not check)then
                         begin
                            vid_vw:=max2i(vid_minw,menu_ResolutionWi);menu_ResolutionWi:=vid_vw;
                            vid_vh:=max2i(vid_minh,menu_ResolutionHi);menu_ResolutionHi:=vid_vh;

                            vid_MakeScreen;
                            theme_map_pTerrain:=255;
                            gfx_MapMakeTerrain;
                         end;
mi_SV_Windowed         : if(not check)then begin vid_windowed:=not vid_windowed; vid_MakeScreen;end;
mi_SV_ShowFPS          : if(not check)then vid_ShowFPS:=not vid_ShowFPS;
mi_SV_MenuScaling      : if(not check)then menu_scale:=not menu_scale;
mi_SV_SmoothScaled     : if(not check)then menu_ScaleSmooth:=not menu_ScaleSmooth;

// SETTINGS SOUND

mi_SS_SoundVolume      : if(not check)then
                         begin
                            menu_GetBarValByte(item,@snd_SoundVolume,0,snd_MaxSoundVolume);
                            snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                            snd_SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : if(not check)then
                         begin
                            menu_GetBarValByte(item,@snd_MusicVolume,0,snd_MaxSoundVolume);
                            snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                            snd_SoundSourceUpdateGainAll;
                         end;
mi_SS_PlayerNext       : if(not check)then snd_SoundMusicControll(true);
mi_SS_PlaylistSize     : if(not check)then ScrollByte(@snd_musicListSize,true,1,snd_MaxMusicListSize);
mi_SS_RenewPlaylist    : if(not check)then snd_RenewMusicList:=not snd_RenewMusicList;
mi_SS_ReloadPlaylist   : if(not check)then snd_GameMusicReLoad;

// SAVE LOAD
mi_SaveLoad_list       : if(not check)then
                         begin
                            menu_ListMouseXY2Line(item,@svld_list_sel,svld_list_scroll,menu_ListLineH);
                            saveload_Select;
                         end;
//mi_SaveLoad_info       :;
mi_SaveLoad_fname      :;
mi_SaveLoad_save       : if(not check)then saveload_Save  (false);
mi_SaveLoad_load       : if(not check)then saveload_Load  (false);
mi_SaveLoad_delete     : if(not check)then saveload_DeleteInit(false);

// REPLAYS
mi_Replays_list        : if(not check)then
                         begin
                            menu_ListMouseXY2Line(item,@rpls_list_sel,rpls_list_scroll,menu_ListLineH);
                            replay_Select;
                         end;
//mi_Replays_info        : ;
mi_Replays_play        : if(not check)then replay_Play  (false);
mi_Replays_delete      : if(not check)then replay_DeleteInit(false);

// SCIRMISH PLAYERS
mi_Players_State0..
mi_Players_State7      : if(not check)then PlayerAIToggle     (item-mi_Players_State0 ,LocalPlayer     ,false);
mi_Players_AIskil0..
mi_Players_AIskil7     : if(not check)then PlayerAILevelScroll(item-mi_Players_AIskil0,LocalPlayer,true,false);
mi_Players_Slot0..
mi_Players_Slot7       : if(not check)then PlayersSwap        (item-mi_Players_Slot0  ,LocalPlayer     ,false);
mi_Players_Race0..
mi_Players_Race7       : if(not check)then PlayerRaceScroll   (item-mi_Players_Race0  ,LocalPlayer     ,false);
mi_Players_Team0..
mi_Players_Team7       : if(not check)then PlayerTeamScroll   (item-mi_Players_Team0  ,LocalPlayer,true,false);
mi_Players_Obs0..
mi_Players_Obs7        : if(not check)then PlayerToggleObserver(item-mi_Players_Obs0  ,LocalPlayer     ,false);
mi_Players_Ready       : if(not check)then PlayerReady:=not PlayerReady;

// SCIRMISH MAP
mi_Map_Scenario        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MScenario      ,true,false);
mi_Map_Generators      : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MGenerators    ,true,false);
mi_Map_Seed            : ;
mi_Map_Size            : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MSize          ,true,false);
mi_Map_Template        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MTemplate      ,true,false);
mi_Map_Symmetry        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MSymmetry      ,true,false);
mi_Map_Random          : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MRandom        ,true,false);

mi_Game_FixedPositions : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_GFixedPositions,true,false);
mi_Game_AISlots        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_GAISlots       ,true,false);
mi_Game_NewObservers    : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_GNewObservers   ,true,false);
mi_Game_Random         : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_GRandomScirmish,true,false);

// SCIRMISH MULTIPLAYER
mi_MP_ServerToggle     : if(not check)then GameNetServer(net_status<>ns_server,false);
mi_MP_ServerPort       : ;
mi_MP_ServerLANVis     : if(not check)then net_svLanAdv:=not net_svLanAdv;
mi_MP_Connect          : if(not check)then GameNetClient(true ,false);
mi_MP_Disconnect       : if(not check)then GameNetClient(false,false);
mi_MP_ClientQuality    : if(not check)then ScrollByte(@net_cl_Quality,true,0,net_MaxQuality);
mi_MP_ClientAddress    : ;
mi_MP_ClientServerList : if(not check)then GameNetServerList(true,false);

// Net Server List MULTIPLAYER
mi_NetServers_List      : if(not check)then GameNetServerListSelect    (item);
mi_NetServers_Connect   : if(not check)then GameNetServerListConnect   (false);
mi_NetServers_Add       : if(not check)then GameNetServerListAdd       (false);
mi_NetServers_Delete    : if(not check)then GameNetServerListDeleteInit(false);

// HELP
mi_help_GameControls,
mi_help_GameMechanics,
mi_help_GameHotKeys,
mi_help_GameUI,
mi_help_UnitsInfo,
mi_help_UnitsBalance,
mi_help_Other,
mi_help_Credits
                       : if(not check)then
                         begin
                            menu_HelpPage  :=item;
                            menu_HelpScroll:=0;
                            menu_HelpIList :=nil;
                            case menu_HelpPage of
                            mi_help_GameControls : menu_HelpIList:=@str_doc_BaseControls;
                            mi_help_GameMechanics: menu_HelpIList:=@str_doc_BaseMechanics;
                            mi_help_GameHotKeys  : menu_HelpIList:=@str_doc_HotKeys;
                            mi_help_GameUI       : ;
                            mi_help_UnitsBalance : if(not IsUIDValidForHelpTable(menu_HelpUID,true))then menu_HelpUID:=0;
                            mi_help_UnitsInfo    : menu_HelpIList:=@g_uids[menu_HelpUID].uid_HintDoc;
                            mi_help_Other        : menu_HelpIList:=@str_doc_Other;
                            mi_help_Credits      : menu_HelpIList:=@str_doc_Credits;
                            end;
                         end;
mi_help_InfoPanel      : case menu_HelpPage of
                         mi_help_UnitsBalance,
                         mi_help_UnitsInfo : if(not check)then
                                             begin
                                                menu_HelpUID  :=menu_HelpSelectUID(item,menu_HelpPage=mi_help_UnitsBalance);
                                                menu_HelpIList:=@g_uids[menu_HelpUID].uid_HintDoc;
                                             end;
                         else menu_Controls_MLB:=false;
                         end;
// CAMPAIGNS
mi_camp_Difficulty     : if(not check)then ScrollByte(@camp_diff,true,0,camp_Maxdiff);
mi_camp_Campaigns      : if(not check)then menu_ListMouseXY2Line(item,@camp_sel    ,camp_scroll    ,menu_CampLineH);
mi_camp_Missions       : if(not check)then menu_ListMouseXY2Line(item,@camp_mis_sel,camp_mis_scroll,menu_MissLineH);
   else
      menu_Controls_MLB:=false;
   end;
end;

function menu_Controls_DMLB(item:byte;check:boolean):boolean;
begin
   menu_Controls_DMLB:=true;
   case item of
mi_SaveLoad_list  : case g_started of
                    true : menu_Controls_DMLB:=false;
                    false: if(not check)then saveload_Load(false);
                    end;
mi_Replays_list   : if(not check)then replay_Play(false);
mi_NetServers_List: if(not check)then GameNetServerListConnect(false);
   else
      menu_Controls_DMLB:=false;
   end;
end;

function menu_Controls_MRB(item:byte;check:boolean):boolean;
begin
   menu_Controls_MRB:=true;
   case item of
mi_SG_PlayersColor     : if(not check)then ScrollByte(@ui_PlayersColor  ,false,0,ui_MaxPlayersColor);
mi_SG_HealthBars       : if(not check)then ScrollByte(@ui_HealthBars    ,false,0,ui_MaxHealthBars  );
mi_SG_ControlPanelPos  : if(not check)then menu_ControlPanelPosScroll(false);
mi_SR_RecordQuality    : if(not check)then ScrollByte(@rpls_Quality     ,false,0,rpls_MaxQuality    );
mi_SS_PlaylistSize     : if(not check)then ScrollByte(@snd_musicListSize,false,1,snd_MaxMusicListSize);

mi_Players_AIskil0..
mi_Players_AIskil7     : if(not check)then PlayerAILevelScroll(item-mi_Players_AIskil0,LocalPlayer,false,false);
mi_Players_Team0..
mi_Players_Team7       : if(not check)then PlayerTeamScroll   (item-mi_Players_Team0  ,LocalPlayer,false,false);

mi_Map_Seed            : if(not check)then GameMapSetSeed(LocalPlayer,random(map_seed.MaxValue)  ,false);
mi_Map_Scenario        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MScenario  ,false,false);
mi_Map_Generators      : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MGenerators,false,false);
mi_Map_Size            : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MSize      ,false,false);
mi_Map_Template        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MTemplate  ,false,false);
mi_Map_Symmetry        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_MSymmetry  ,false,false);

mi_Game_AISlots        : if(not check)then GameSetOption(LocalPlayer,nmid_lobby_GAISlots   ,false,false);

mi_MP_ClientQuality    : if(not check)then ScrollByte(@net_cl_Quality,false,0,net_MaxQuality);

mi_camp_Difficulty     : if(not check)then ScrollByte(@camp_diff,false,0,camp_Maxdiff);
   else
      menu_Controls_MRB:=false;
   end;
end;

function menu_ChatSize:integer;
begin
   with g_PlayersMain[LocalPlayer] do
     if(log_n<MaxPlayerLog)
     then menu_ChatSize:=integer(log_n)
     else menu_ChatSize:=MaxPlayerLog;
end;

function menu_Controls_MWD(item:byte;check:boolean):boolean;
begin
   menu_Controls_MWD:=true;
   case item of
mi_NetServers_List     : if(not check)then ScrollInt(@net_SvList_scroll, 10,0,net_SvList_Size-menu_ServerListH,false);
mi_SaveLoad_list       : if(not check)then ScrollInt(@svld_list_scroll , 10,0,svld_list_size -menu_BaseList1H ,false);
mi_Replays_list        : if(not check)then ScrollInt(@rpls_list_scroll , 10,0,rpls_list_size -menu_BaseList1H ,false);
mi_MP_ChatList         : if(not check)then ScrollInt(@menu_ChatScroll  ,-2 ,0,menu_ChatSize  -menu_ChatListH  ,false);
mi_help_InfoList       : if(not check)then if(menu_HelpIList<>nil)then
                                           with menu_HelpIList^ do
                                           ScrollInt(@menu_HelpScroll  , 2 ,0,slist_n        -ui_DocListH     ,false);

mi_SG_ScrollSpeed      : if(not check)then ScrollByte(@ui_CamSpeed,false,1,ui_MaxCamSpeed,false);
mi_SS_SoundVolume      : if(not check)then
                         begin
                            ScrollByte(@snd_SoundVolume,false,0,snd_MaxSoundVolume,false);
                            snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                            snd_SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : if(not check)then
                         begin
                            ScrollByte(@snd_MusicVolume,false,0,snd_MaxSoundVolume,false);
                            snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                            snd_SoundSourceUpdateGainAll;
                         end;
mi_camp_Campaigns      : if(not check)then ScrollInt(@camp_scroll    , 1,0,camp_size              -menu_CampListSize,false);
mi_camp_Missions       : if(not check)then
                           if(0<=camp_sel)and(camp_sel<camp_size)then
                                           ScrollInt(@camp_mis_scroll, 1,0,camp_mis_size[camp_sel]-menu_MissListSize,false);

   else
      menu_Controls_MWD:=false;
   end;
end;

function menu_Controls_MWU(item:byte;check:boolean):boolean;
begin
   menu_Controls_MWU:=true;
   case item of
mi_NetServers_List     : if(not check)then ScrollInt(@net_SvList_scroll,-10,0,net_SvList_Size-menu_ServerListH,false);
mi_SaveLoad_list       : if(not check)then ScrollInt(@svld_list_scroll ,-10,0,svld_list_size -menu_BaseList1H ,false);
mi_Replays_list        : if(not check)then ScrollInt(@rpls_list_scroll ,-10,0,rpls_list_size -menu_BaseList1H ,false);
mi_MP_ChatList         : if(not check)then ScrollInt(@menu_ChatScroll  , 2 ,0,menu_ChatSize  -menu_ChatListH  ,false);
mi_help_InfoList       : if(not check)then if(menu_HelpIList<>nil)then
                                           with menu_HelpIList^ do
                                           ScrollInt(@menu_HelpScroll  ,-2 ,0,slist_n        -ui_DocListH     ,false);

mi_SG_ScrollSpeed      : if(not check)then ScrollByte(@ui_CamSpeed,true,1,ui_MaxCamSpeed,false);
mi_SS_SoundVolume      : if(not check)then
                         begin
                            ScrollByte(@snd_SoundVolume,true,0,snd_MaxSoundVolume,false);
                            snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
                            snd_SoundSourceUpdateGainAll;
                         end;
mi_SS_MusicVolume      : if(not check)then
                         begin
                            ScrollByte(@snd_MusicVolume,true,0,snd_MaxSoundVolume,false);
                            snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;
                            snd_SoundSourceUpdateGainAll;
                         end;
mi_camp_Campaigns      : if(not check)then ScrollInt(@camp_scroll    ,-1,0,camp_size              -menu_CampListSize,false);
mi_camp_Missions       : if(not check)then
                           if(0<=camp_sel)and(camp_sel<camp_size)then
                                           ScrollInt(@camp_mis_scroll,-1,0,camp_mis_size[camp_sel]-menu_MissListSize,false);
   else
      menu_Controls_MWU:=false;
   end;
end;

function menu_Controls_Text(item:byte;check:boolean;changed:pboolean):boolean;
begin
   menu_Controls_Text:=true;
   case item of
mi_SG_PlayerName       : if(not check)then PlayerName        :=    StringApplyInput(PlayerName            ,CharSetCommon,MaxPlayerNameLen    ,changed);
mi_SR_RecordPrefix     : if(not check)then rpls_NamePrefix   :=    StringApplyInput(rpls_NamePrefix       ,CharSetCommon,MaxReplayPrefixLen  ,changed);

mi_SV_ResolutionW      : if(not check)then menu_ResolutionWi :=s2i(StringApplyInput(i2s(menu_ResolutionWi),CharSetDigits,4                   ,changed));
mi_SV_ResolutionH      : if(not check)then menu_ResolutionHi :=s2i(StringApplyInput(i2s(menu_ResolutionHi),CharSetDigits,4                   ,changed));

mi_SaveLoad_fname      : if(not check)then svld_str_fname    :=    StringApplyInput(svld_str_fname        ,CharSetCommon,menu_ListLineWChars1,changed);

mi_Map_Seed            : if(not check)then menu_mseed        :=    StringApplyInput(menu_mseed            ,CharSetDigits,10                  ,changed);

mi_MP_ServerPort       : if(not check)then menu_ServerPort   :=    StringApplyInput(menu_ServerPort       ,CharSetDigits,5                   ,changed);
mi_MP_ClientAddress    : if(not check)then menu_ClientAddress:=    StringApplyInput(menu_ClientAddress    ,CharSetCommon,menu_AddressLen     ,changed);
mi_MP_ChatLine,
mi_MP_ChatList         : if(not check)then net_chat_str      :=    StringApplyInput(net_chat_str          ,CharSetCommon,254                 ,changed);
   else
      menu_Controls_Text:=false;
   end;
end;

function menu_msgBox_Code:boolean;
procedure msgBoxOff;
begin
   menu_msg_type    :=mmbt_none;
   menu_ItemTarget  :=0;
   menu_ItemSelected:=0;
   menu_update      :=true;
   snd_SoundPlayUI(snd_click);
end;
begin
   menu_msgBox_Code:=(menu_msg_type<>mmbt_none);

   case menu_msg_type of
   mmbt_nothing,
   mmbt_netPortBlock : if(InputActionPressed(iAct_any))then msgBoxOff;
   mmbt_netWaitServer: if(InputActionPressed(iAct_any))then
                       begin
                          GameResetNetGame;
                          msgBoxOff;
                       end;
   mmbt_SaveRewrite,
   mmbt_DeleteSave,
   mmbt_DeleteReplay,
   mmbt_DeleteServer : begin
                            if((InputActionPressed(iact_MLB))
                            and(menu_msg_btn1x0<=mouse_x)and(mouse_x<=menu_msg_btn1x1)
                            and(menu_msg_btn1y0<=mouse_y)and(mouse_y<=menu_msg_btn1y1))
                            or(InputActionPressed(iact_Return))then
                            begin
                               case menu_msg_type of
                               mmbt_SaveRewrite :      saveload_SaveWrite(menu_msg_Body);
                               mmbt_DeleteSave  :     saveload_DeleteFile(menu_msg_Body);
                               mmbt_DeleteReplay:       replay_DeleteFile(menu_msg_Body);
                               mmbt_DeleteServer: GameNetServerListDelete(menu_msg_Body);
                               end;
                               snd_SoundPlayUI(snd_click);
                            end;
                          if(InputActionPressed(iAct_any))then msgBoxOff;
                       end;
   end;
end;

procedure menu_Controls;
var
mnx,
mny       :integer;
changed,
clickSound:boolean;
procedure SetSelectedItem(newItem:byte;fromTarget:boolean=false);
begin
   if(menu_items[newItem].mi_state>as_off)then
     case fromTarget of
     false: menu_ItemSelected:=newItem;
     true : if(newItem=menu_ItemTarget)then
              menu_ItemSelected:=newItem;
     end;
end;

begin
   mnx:=mouse_x;
   mny:=mouse_y;
   mouse_x:=round((mouse_x-menu_sc_x)*menu_sc_cx);
   mouse_y:=round((mouse_y-menu_sc_y)*menu_sc_cx);

   clickSound:=false;
   changed:=false;

   // force menu msg box error awaiting for server
   if(net_status=ns_client)and(not net_SvList)then
     if(net_cl_svttl>=TTLServer)and(not g_started)
     then menu_msgBox_Set(str_Caption_Multiplayer,menu_ClientAddress+' - '+str_gstat_WaitForServer,mmbt_netWaitServer)
     else
       if(menu_msg_type=mmbt_netWaitServer)then menu_msg_type:=mmbt_none;

   if(menu_msgBox_Code)then
   begin
      mouse_x:=mnx;
      mouse_y:=mny;
      exit;
   end;

   menu_ItemTarget:=menu_MouseXY2Item;

   if(InputActionPressed(iact_MLB)or(InputActionPressed(iact_MRB)))then  //select item
   begin
      if(menu_ItemTarget<>menu_ItemSelected)then
         menu_EndEdition(false);

      menu_ItemSelected:=menu_ItemTarget;
   end;

   menu_ItemActs:=0;

///////////////////////////////////   text input
  case(length(k_KeyboardString)>0)or(InputActionPressed(iAct_backspace))or(InputActionStuck(iAct_backspace))of
  true : begin
            SetSelectedItem(mi_SaveLoad_fname);
            if(menu_ItemSelected<>mi_Map_Seed)then
              SetSelectedItem(mi_MP_ChatList);

            if(menu_Controls_Text(menu_ItemSelected,false,@changed))then
            begin
               if(menu_ItemTarget=menu_ItemSelected)then SetBBit(@menu_ItemActs,miat_TextEdit,true);
               menu_update:=menu_update or changed;
            end;
         end;
  false: if(menu_Controls_Text(menu_ItemTarget  ,true ,nil))then SetBBit(@menu_ItemActs,miat_TextEdit,true);
  end;

///////////////////////////////////   left button pressed
   case InputActionPressed(iact_MLB) of
   true : if(menu_Controls_MLB(menu_ItemSelected,false))then
          begin
             if(menu_ItemTarget=menu_ItemSelected)then SetBBit(@menu_ItemActs,miat_BtnLeft,true);
             menu_update:=true;
             clickSound :=true;
             if(not GetBBit(@menu_ItemActs,miat_TextEdit))
             and(not InputActionDPressed(iact_MLB))then menu_ItemSelected:=0;
          end;
   false: if(menu_Controls_MLB(menu_ItemTarget  ,true ))then SetBBit(@menu_ItemActs,miat_BtnLeft,true);
   end;
///////////////////////////////////  double  left button pressed
   case InputActionDPressed(iact_MLB) of
   true : if(menu_Controls_DMLB(menu_ItemSelected,false))then
          begin
             if(menu_ItemTarget=menu_ItemSelected)then SetBBit(@menu_ItemActs,miat_BtnDLeft,true);
             menu_update:=true;
             clickSound :=true;
          end;
   false: if(menu_Controls_DMLB(menu_ItemTarget  ,true ))then SetBBit(@menu_ItemActs,miat_BtnDLeft,true);
   end;

///////////////////////////////////   right button pressed
   case InputActionPressed(iact_MRB) of
   true : if(menu_Controls_MRB(menu_ItemSelected,false))then
          begin
             if(menu_ItemTarget=menu_ItemSelected)then SetBBit(@menu_ItemActs,miat_BtnRight,true);
             menu_update:=true;
             clickSound :=true;
             menu_ItemSelected:=0;
          end;
   false: if(menu_Controls_MRB(menu_ItemTarget  ,true ))then SetBBit(@menu_ItemActs,miat_BtnRight,true);
   end;

///////////////////////////////////   mouse wheel down
   case InputActionPressed(iact_MWD) of
   true : begin
             SetSelectedItem(mi_NetServers_List);
             SetSelectedItem(mi_SaveLoad_list  );
             SetSelectedItem(mi_Replays_list   );
             SetSelectedItem(mi_MP_ChatList    );
             SetSelectedItem(mi_help_InfoList  );
             SetSelectedItem(mi_SS_SoundVolume,true);
             SetSelectedItem(mi_SS_MusicVolume,true);
             SetSelectedItem(mi_SG_ScrollSpeed,true);
             SetSelectedItem(mi_camp_Campaigns,true);
             SetSelectedItem(mi_camp_Missions ,true);

             if(menu_Controls_MWD(menu_ItemSelected,false))then
             begin
                if(menu_ItemTarget=menu_ItemSelected)then SetBBit(@menu_ItemActs,miat_MWhell,true);
                menu_update:=true;
                menu_ItemSelected:=0;
             end;
          end;
   false: if(menu_Controls_MWD(menu_ItemTarget  ,true ))then SetBBit(@menu_ItemActs,miat_MWhell,true);
   end;

///////////////////////////////////   mouse wheel up
   case InputActionPressed(iact_MWU) of
   true : begin
             SetSelectedItem(mi_NetServers_List);
             SetSelectedItem(mi_SaveLoad_list  );
             SetSelectedItem(mi_Replays_list   );
             SetSelectedItem(mi_MP_ChatList    );
             SetSelectedItem(mi_help_InfoList  );
             SetSelectedItem(mi_SS_SoundVolume,true);
             SetSelectedItem(mi_SS_MusicVolume,true);
             SetSelectedItem(mi_SG_ScrollSpeed,true);
             SetSelectedItem(mi_camp_Campaigns,true);
             SetSelectedItem(mi_camp_Missions ,true);

             if(menu_Controls_MWU(menu_ItemSelected,false))then
             begin
                if(menu_ItemTarget=menu_ItemSelected)then SetBBit(@menu_ItemActs,miat_MWhell,true);
                menu_update:=true;
                menu_ItemSelected:=0;
             end;
          end;
   false: if(menu_Controls_MWU(menu_ItemTarget  ,true ))then SetBBit(@menu_ItemActs,miat_MWhell,true);
   end;

///////////////////////////////////   other keyboards keys

   if(InputActionPressed(iact_Esc   ))then MenuBack(false,false);
   if(InputActionPressed(iact_Return))then menu_EndEdition(true);
   if(InputActionPressed(iact_Up    ))
   or(InputActionStuck  (iact_Up    ))then menu_KeyUp;
   if(InputActionPressed(iact_Down  ))
   or(InputActionStuck  (iact_Down  ))then menu_KeyDown;
   if(InputActionPressed(iAct_Delete))then menu_KeyDelete;

   // if(InputActionPressed(iAct_test_debug0      ))then writeln(MenuBack(false,true));
   // if(InputActionPressed(iAct_test_debug1      ))then ;

   if(menu_ItemTargetP<>menu_ItemTarget)then
     if(menu_hint_pos[menu_ItemTarget ]>0)
     or(menu_hint_pos[menu_ItemTargetP]>0)then menu_update:=true;
   menu_ItemTargetP:=menu_ItemTarget;

   if(clickSound)then snd_SoundPlayUI(snd_click);

   mouse_x:=mnx;
   mouse_y:=mny;
end;

