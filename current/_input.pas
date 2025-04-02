


type TkbState = (pct_left,pct_right,pct_middle);


function kbState2pct:TkbState;
begin
   kbState2pct:=pct_left;
   if(kt_ctrl>0)then kbState2pct:=pct_right;
   if(kt_alt >0)then kbState2pct:=pct_middle;
end;

procedure input_key_escape;
begin
   if(ingame_chat>0)then
   begin
      ingame_chat :=0;
      net_chat_str:='';
   end
   else menu_Toggle;
end;

function MakeChatTargets(a,player:byte):byte;
var p:byte;
begin
   MakeChatTargets:=0;
   case a of
chat_all      : MakeChatTargets:=255;
chat_allies   : for p:=0 to LastPlayer do
                 with g_players[p] do
                  if(player_type>pt_none)and(team=g_players[player].team)then
                   SetBBit(@MakeChatTargets,p,true);
0..LastPlayer : if(g_players[a].player_type=pt_human)then SetBBit(@MakeChatTargets,a,true);
   end;
end;

procedure input_key_return;
var PlayerClientAllies: byte;
begin
   if(not menu_state)and(ingame_chat=0)and(net_status>ns_single)then
   begin
      PlayerClientAllies:=PlayerGetAlliesByte(PlayerClient,false);
      // default chat
      if(PlayerClientAllies<>0)
      then ingame_chat:=chat_allies
      else ingame_chat:=chat_all;

      if(kt_ctrl>0)then
      begin
         if(PlayerClientAllies<>0)
         then ingame_chat:=chat_allies;
      end
      else
         if(kt_shift>0)
         then ingame_chat:=chat_all;
      net_chat_tar:=MakeChatTargets(ingame_chat,PlayerClient);
   end
   else ;
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

procedure GameTogglePause;
begin
   if(net_status=ns_client)
   then net_send_byte(nmid_pause)
   else
     if(net_status=ns_server) then
       if(G_Status=gs_running)then
       begin
          G_Status:=PlayerClient;
          GameLogChat(PlayerClient,255,str_msg_PlayerPaused,false);
       end
       else
       begin
          G_Status:=gs_running;
          GameLogChat(PlayerClient,255,str_msg_PlayerResumed,false);
       end;
end;

procedure PlayerUnitOrderEffect(ox0,oy0,otarget,oy1,uo_order:integer;pl:byte;UnitSound:boolean);
var
i,
SelectedAll,
SelectedAbility,
SelectedRebuild,
SelectedBOrders: integer;
LeaderUID      : byte;
function _checkEnemy:boolean;
var pu:PTUnit;
begin
   _checkEnemy:=false;
   if(IsIntUnitRange(otarget,@pu))then
     if(pu^.player^.team<>g_players[PlayerClient].team)then _checkEnemy:=true;
end;
procedure _PlayCommand(ss:PTSoundSet);
begin
   SoundPlayUnitCommand(ss);
   ui_UnitSelectedn:=0;
end;
procedure _ClickEffect(color:cardinal);
begin
   click_eff(ox0,oy0,fr_fpsd4,color);
end;
function CheckBOrders(pu:PTUnit):boolean;
begin
   CheckBOrders:=true;
   with pu^ do
   with uid^ do
   begin
      if(iscomplete)then
        if(speed>0)
        or(unit_canAttack(pu,false))
        //or(unit_canAbility(pu)=0)
        then exit;
      if(UnitHaveRPoint(uidi))then exit;
   end;
   CheckBOrders:=false;
end;

begin
   LeaderUID      :=0;
   SelectedAll    :=0;
   SelectedBOrders:=0;
   SelectedAbility:=0;
   SelectedRebuild:=0;

   {with g_players[PlayerClient] do
    for i:=1 to MaxUnits do
     with g_units[i] do
      with uid^ do
       if(hits>0)and(isselected)and(playeri=PlayerClient)then
       begin
          SelectedAll+=1;
          if(CheckBOrders(g_punits[i]))then
          begin
             SelectedBOrders+=1;
             if(iscomplete)then
             begin
                if(LeaderUID<>0)then
                 if(_mhits<=g_uids[LeaderUID]._mhits)then
                  if(_ucl<g_uids[LeaderUID]._ucl)then continue;

                LeaderUID:=uidi;
             end;
          end;
          if(_ability    >0{unit_canAbility(g_punits[i])=0})then SelectedAbility+=1;
          if(_rebuild_uid>0{unit_canRebuild(g_punits[i])=0})then SelectedRebuild+=1;
       end;

   case uo_order of
   uo_move,
   uo_attack,
   uo_hold,
   uo_stay,
   uo_patrol,
   uo_apatrol  : if(SelectedBOrders<=0)then exit;
   //uo_psability: if(SelectedAbility<=0)then exit;
   //uo_rebuild  : if(SelectedRebuild<=0)then exit;
   else          if(SelectedAll    <=0)then exit;
   end;

   if(UnitSound)then
     with g_uids[LeaderUID] do
       case uo_order of
   //uo_psability,
   uo_move,
   uo_hold,
   uo_stay,
   uo_patrol   : _PlayCommand(un_snd_move);
   uo_attack,
   uo_apatrol  : _PlayCommand(un_snd_attack);
       end;

   if(IsIntUnitRange(otarget,nil))then
   begin
      ui_umark_u:=otarget;
      ui_umark_t:=fr_fpsd2;
      exit;
   end;

   //ox0+=vid_mapx;
   //oy0+=vid_mapy;

   case uo_order of
   //uo_psability: _ClickEffect(c_aqua);
   uo_move,
   uo_patrol   : _ClickEffect(c_lime);
   uo_attack,
   uo_apatrol  : _ClickEffect(c_red );
   end; }
end;

procedure PlayerSetOrder(ox0,oy0,ox1,oy1,oa0:integer;oid,pl:byte);
begin
   if(G_Status=gs_running)and(rpls_rstate<rpls_state_read)then
   begin
      if(net_status=ns_client)then
      begin
         net_clearbuffer;
         net_writebyte(nmid_order);
         net_writeint (ox0);
         net_writeint (oy0);
         net_writeint (ox1);
         net_writeint (oy1);
         net_writeint (oa0);
         net_writebyte(oid);
         net_send(net_cl_svip,net_cl_svport);
      end
      else
        with g_players[pl] do
        begin
           o_x0:=ox0;
           o_y0:=oy0;
           o_x1:=ox1;
           o_y1:=oy1;
           o_a0:=oa0;
           o_id:=oid;
        end;

      case oid of
      po_unit_order_set: PlayerUnitOrderEffect(ox0,oy0,ox1,oy1,oa0,pl,oid=po_unit_order_set);
      end;
   end;
end;

function ui_GetCursorUnit(mx,my:integer):PTUnit;
var u:integer;
begin
   ui_GetCursorUnit:=nil;
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(not IsIntUnitRange(transport,nil))then
         if(ui_CheckUnitUIPlayerVision(g_punits[u],true))then
           if(point_dist_rint(vx,vy,mx,my)<uid^._r)then
           begin
              {if(ui_GetCursorUnit=nil)
              then ui_GetCursorUnit:=g_punits[u]
              else
                if(ukfly>ui_GetCursorUnit^.ukfly)
                then ui_GetCursorUnit:=g_punits[u]
                else
                  if(uid^._r<ui_GetCursorUnit^.uid^._r)
                  then ui_GetCursorUnit:=g_punits[u]; }
              if(ui_GetCursorUnit<>nil)then
                if(ukfly<ui_GetCursorUnit^.ukfly)
                then continue
                else
                  if(uid^._r>ui_GetCursorUnit^.uid^._r)
                  then continue;
              ui_GetCursorUnit:=g_punits[u];
           end;
end;

procedure mbrush_Check(log:boolean);
var cndt:cardinal;
     uid:byte;
begin
   mbrush_x:=mouse_map_x;
   mbrush_y:=mouse_map_y;

   if(UIPlayer<>PlayerClient)
   or(g_players[PlayerClient].isobserver)
   or(g_players[PlayerClient].isdefeated)
   then m_brush:=mb_empty
   else
   case m_brush of
1..255       : begin
                  uid :=byte(m_brush);
                  cndt:=uid_CheckRequirements(@g_players[PlayerClient],uid);
                  if(cndt>0)then
                  begin
                     if(log)then GameLogCantProduction(PlayerClient,uid,lmt_argt_unit,cndt,-1,-1,true);
                     m_brush:=mb_empty;
                  end
                  else
                   with g_players[PlayerClient] do
                   begin
                      if not(uid in ui_bprod_possible)or(n_builders<=0)then
                      begin
                         GameLogCantProduction(PlayerClient,uid,lmt_argt_unit,ureq_needbuilders,-1,-1,true);
                         m_brush:=mb_empty;
                         exit;
                      end;

                      if(kt_ctrl<=0)then
                      begin
                         BuildingNewPlace(mouse_map_x,mouse_map_y,uid,PlayerClient,@mbrush_x,@mbrush_y);
                         mbrush_x:=mm3i(vid_cam_x,mbrush_x,vid_cam_x+vid_cam_w);
                         mbrush_y:=mm3i(vid_cam_y,mbrush_y,vid_cam_y+vid_cam_h);
                      end;

                      case CheckBuildPlace(mbrush_x,mbrush_y,0,0,PlayerClient,uid) of
                      cbp_good   :  m_brushc:=c_lime;
                      cbp_noplace:  m_brushc:=c_red;
                      cbp_out    :  m_brushc:=c_blue;
                      else          m_brushc:=c_gray;
                      end;
                   end;
               end;
-255..-1     : with g_uability[-m_brush] do
                 if(ua_type<>uat_point)or(ua_type<>uat_unit)
                 then m_brush:=mb_empty
                 else ;
   else m_brush:=mb_empty;
   end;
end;

procedure mb_MapMarker(x,y:integer);
begin
   if(net_status=ns_client)
   then net_SendMapMark(x,y)
   else GameLogMapMark(PlayerClient,x,y);
   m_brush:=mb_empty;
end;

procedure ui_PanelClick;
begin
   SoundPlayUI(snd_click);
   vid_PanelUpdNow:=true;
end;

procedure ui_PanelButton(tab:TTabType;bx,by:integer;click_type:TkbState;twice:boolean);
var u:integer;
begin
   if(by=vid_panel_bh)then
   begin
      case bx of // last line,  common buttons
      0 : menu_Toggle;
      2 : if(net_status>ns_single)then GameTogglePause;
      end;
      exit;
   end;
   by-=1;

   if(not ui_ActionsIsAllowed(PlayerClient))then exit;

   if(by<0)
   or(   vid_panel_bh<=by)
   or(bx<0)
   or(   vid_panel_bw<=bx)then exit;

   if(vid_PannelPos in VPPSet_Horizontal)then
   begin  // turn vid_panel_bw*vid_panel_bw block if horizontal panel
      u :=bx;
      bx:=by;
      by:=u;
      by+=vid_panel_bw*(bx div vid_panel_bw);
      bx-=vid_panel_bw*(bx div vid_panel_bw);
   end;

   u:=(by*vid_panel_bw)+(bx mod vid_panel_bw);

   if(0<=u)and(u<=ui_ubtns)then
     with g_players[PlayerClient] do
     begin
        if(G_Status=gs_running)and(rpls_rstate<rpls_state_read)then
          case tab of
          tt_buildings : case click_type of
                         pct_left  : begin
                                     m_brush:=ui_panel_uids[race,ord(tab),u];
                                     mbrush_Check(true);
                                     end;
                         end;
          tt_units     : case click_type of
                         pct_left  : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,ord(tab),u],po_prod_unit_start,PlayerClient);
                         pct_right : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,ord(tab),u],po_prod_unit_stop ,PlayerClient);
                         end;
          tt_upgrades  : case click_type of
                         pct_left  : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,ord(tab),u],po_prod_upgr_start,PlayerClient);
                         pct_right : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,ord(tab),u],po_prod_upgr_stop ,PlayerClient);
                         end;
          end;

        if(tab=tt_controls)then
          case tab3PageType of
             // replay
t3pt_replay  : case u of
               1: case click_type of
                  pct_left   : replay_SetPlayPosition(g_step-(fr_fps1*2 )+1,-1);
                  pct_right  : replay_SetPlayPosition(g_step-(fr_fps1*10)+1,-1);
                  pct_middle : replay_SetPlayPosition(g_step-(fr_fps1*60)+1,-1);
                  end;
               2: case click_type of
                  pct_left   : if(not replay_SetPlayPosition(g_step-(fr_fps1*2 )+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*2 ;
                  pct_right  : if(not replay_SetPlayPosition(g_step-(fr_fps1*10)+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*10;
                  pct_middle : if(not replay_SetPlayPosition(g_step-(fr_fps1*60)+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*60;
                  end;
               else
                  if(click_type=pct_left)then
                    case u of
                    0 : sys_uncappedFPS:=not sys_uncappedFPS;
                    3 : begin
                           if  (G_Status =gs_running    )
                           then G_Status:=gs_replaypause
                           else G_Status:=gs_running;
                           rpls_ForwardStep:=0;
                        end;
                    4 : rpls_POVCam :=not rpls_POVCam;
                    5 : rpls_showlog:=not rpls_showlog;
                    6 : sys_fog     :=not sys_fog;
                8..17 : UIPlayer    :=u-8;
                    end;
               end;
             // observer
t3pt_observer: if(click_type=pct_left)then
               case u of
               0    :  sys_fog:=not sys_fog;
               2..11:  UIPlayer:=u-2;
               end;
             // actions
t3pt_actions : if(G_Status=gs_running)then
                 if(click_type=pct_left)then
                 begin
                    case u of
                    {0 : PlayerSetOrder(0,0,0,0,uo_sability,po_unit_order_set,PlayerClient);
                    1 : m_brush :=mb_psability;
                    2 : PlayerSetOrder(0,0,0,0,uo_rebuild ,po_unit_order_set,PlayerClient);}

                    3 : m_brush :=-ua_amove;
                    4 : PlayerSetOrder(0,0,0,0,ua_astay   ,po_unit_order_set,PlayerClient);
                    5 : m_brush :=-ua_apatrol;

                    6 : m_brush :=-ua_move;
                    7 : PlayerSetOrder(0,0,0,0,ua_stay    ,po_unit_order_set,PlayerClient);
                    8 : m_brush :=-ua_patrol;

                    9 : if(s_barracks>0)
                        or(s_smiths  >0)
                        then PlayerSetOrder(0,0,0,0,0,po_prod_stop,PlayerClient) // common production stop ???????????????
                        else ;
                          {case ui_tab of
                          1 : PlayerSetOrder(0,0,0,0,255,po_prod_unit_stop,PlayerClient);
                          2 : PlayerSetOrder(0,0,0,0,255,po_prod_upgr_stop,PlayerClient);
                          end;  }
                    10: if(ui_groups_f1.ugroup_n>0)then
                          if(twice)
                          then with ui_groups_f1 do GameCameraMoveToPoint(ugroup_x,ugroup_y);
                    11: if(ui_groups_f2.ugroup_n>0)then
                          if(twice)
                          then with ui_groups_f2 do GameCameraMoveToPoint(ugroup_x,ugroup_y)
                          else units_SelectGroup(false,PlayerClient,255);
                    12: PlayerSetOrder(0,0,0,0,ua_destroy,po_unit_order_set,PlayerClient);  // destroy
                    13: m_brush :=mb_mark;
                    14: m_action:=not m_action;
                    end;

                    mbrush_Check(false);
                 end;
           end;
     end;
end;

function test_hotkeys(k:cardinal):boolean;
procedure nullupgr(playeri:byte);
var i:byte;
begin
   with g_players[playeri] do
    for i:=1 to 255 do
     upgr[i]:=0;
end;
begin
   test_hotkeys:=true;
   case k of
km_test_FastTime    : sys_uncappedFPS:=not sys_uncappedFPS;
km_test_InstaProd   : test_fastprod:=not test_fastprod;
km_test_ToggleAI    : with g_players[PlayerClient] do if(player_type=pt_human)then player_type:=pt_ai else player_type:=pt_human;
km_test_iddqd       : with g_players[PlayerClient] do if(upgr[upgr_invuln ]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
km_test_FogToggle   : sys_fog:=not sys_fog;
km_test_DrawToggle  : r_draw :=not r_draw;
km_test_NullUpgrades: nullupgr(PlayerClient);
km_test_BePlayer0   : PlayerClient:=0;
km_test_BePlayer1   : PlayerClient:=1;
km_test_BePlayer2   : PlayerClient:=2;
km_test_BePlayer3   : PlayerClient:=3;
km_test_BePlayer4   : PlayerClient:=4;
km_test_BePlayer5   : PlayerClient:=5;
km_test_BePlayer6   : PlayerClient:=6;
km_test_BePlayer7   : PlayerClient:=7;
km_test_debug0      : debug_SetDomainColors;
km_test_debug1      : begin
                       map_ZonesMake;
                       map_pf_MarkSolidCells;
                       map_pf_MakeDomains;
                      end;
   else test_hotkeys:=false;
   end;
end;

procedure GameHotkeys(key1:cardinal);
var i,key2:cardinal;
procedure ko2_panel_click(tab:TTabType;ClickType:TkbState;kdbl:boolean);
begin
   SoundPlayUI(snd_click);
   vid_PanelUpdNow:=true;
   case vid_PannelPos  of
   vpp_left,
   vpp_right  : ui_PanelButton(tab, i mod vid_panel_bw                 ,1+(i div vid_panel_bw),ClickType,kdbl);
   vpp_top,
   vpp_bottom : ui_PanelButton(tab,(i div vid_panel_bw)mod vid_panel_bw,
                                 1+(i div vid_panel_bblock)*vid_panel_bw+(i mod vid_panel_bw),ClickType,kdbl);
   end;
end;
begin
   case key1 of
km_Esc      : input_key_escape;
km_GamePause: ui_PanelButton(tt_controls,2,vid_panel_bh,pct_left,false);
km_Tab      : if(ui_tab=high(ui_tab))
              then ui_tab:=low (ui_tab)
              else ui_tab:=Succ(ui_tab);         //ui_PanelClick
   else
      if(test_mode>0)and(net_status=ns_single)then
        if(test_hotkeys(key1))then exit;

      if(not ui_ActionsIsAllowed(PlayerClient))then exit;

      key2:=0;
      if(kt_shift>0)then key2:=km_lshift;
      if(kt_ctrl >0)then key2:=km_lctrl;
      if(kt_alt  >0)then key2:=km_lalt;

      if(key1=km_Space)and(key2=0)then
      begin
         GameCameraMoveToLastEvent;
         exit;
      end;

      case tab3PageType of
               // replays
t3pt_replay  : for i:=0 to HotKeysArraySize do
               begin
                  if(hotkeyR2[i]<>key2)
                  or(hotkeyR1[i]= 0   )
                  or(hotkeyR1[i]<>key1 )then continue;
                  ko2_panel_click(tt_controls,kbState2pct,false);
               end;
               // observer
t3pt_observer: for i:=0 to HotKeysArraySize do
               begin
                  if(hotkeyO2[i]<>key2)
                  or(hotkeyO1[i]= 0   )
                  or(hotkeyO1[i]<>key1 )then continue;
                  ko2_panel_click(tt_controls,kbState2pct,false);
               end;
               // production panels
t3pt_actions : if(G_Status=gs_running)then
               begin
                  case ui_tab of
                  tt_buildings,
                  tt_units,
                  tt_upgrades : for i:=0 to HotKeysArraySize do
                                begin
                                    if(hotkeyP2[i]<>key2 )
                                    or(hotkeyP1[i]= 0    )
                                    or(hotkeyP1[i]<>key1)then continue;
                                    ko2_panel_click(ui_tab,pct_left,false);
                                    exit;
                                 end;
                   end;

                   for i:=0 to HotKeysArraySize do  // actions
                   begin
                      if(hotkeyA2[i]<>key2)
                      or(hotkeyA1[i]= 0 )
                      or(hotkeyA1[i]<>key1 )then continue;
                      ko2_panel_click(tt_controls,pct_left,k_TwiceLast);
                      exit;
                   end;

                   // control groups
                   case key1 of
        km_group0..km_group9 : begin
                                  i:=key1-km_group0;
                                  if(i<MaxUnitGroups)then
                                    if(kt_ctrl>0)
                                    then units_Grouping(false,PlayerClient,i)
                                    else
                                      if(kt_alt>0)
                                      then units_Grouping(true ,PlayerClient,i)
                                      else
                                        if(not k_TwiceLast)
                                        then units_SelectGroup(kt_shift>0,PlayerClient,i)
                                        else
                                          with ui_groups_d[i] do
                                            if(ugroup_n>0)then
                                              GameCameraMoveToPoint(ugroup_x,ugroup_y);
                               end;
                   else
                   end;
                end;
      end;
   end;
end;

procedure KeyTimerProc(i:pinteger);
begin
   if(i^<0)
   then i^:=0
   else
     if(0<i^)and(i^<i^.MaxValue)then i^+=1;
end;

procedure WindowEvents;
begin
   KeyTimerProc(@kt_up      ); // arrows
   KeyTimerProc(@kt_down    );
   KeyTimerProc(@kt_right   );
   KeyTimerProc(@kt_left    );
   KeyTimerProc(@kt_shift   ); // special
   KeyTimerProc(@kt_ctrl    );
   KeyTimerProc(@kt_alt     );
   KeyTimerProc(@kt_mleft   ); // mouse btns
   KeyTimerProc(@kt_mright  );
   KeyTimerProc(@kt_mmiddle );
   KeyTimerProc(@kt_Last    ); // last key

   if(kt_TwiceLast>0)then kt_TwiceLast-=1;
   if(mt_TwiceLast>0)then mt_TwiceLast-=1;
   k_TwiceLast:=false;
   m_TwiceLast:=false;
   m_TwiceLeft:=false;

   k_KeyboardString:='';

   if(kt_Last>k_LastCharStuckDealy)then
     if(length(k_KeyboardString)<255)then k_KeyboardString+=k_LastChar;

   while (SDL_PollEvent(sys_EVENT)>0) do
     case (sys_EVENT^.type_) of
      SDL_MOUSEMOTION    : begin
                              if(m_vmove)and(not menu_state)and(G_Started)then
                              begin
                                 vid_cam_x-=sys_EVENT^.motion.x-mouse_x;
                                 vid_cam_y-=sys_EVENT^.motion.y-mouse_y;
                                 GameCameraBounds;
                              end;
                              mouse_x:=sys_EVENT^.motion.x;
                              mouse_y:=sys_EVENT^.motion.y;
                           end;
      SDL_MOUSEBUTTONUP  : case (sys_EVENT^.button.button) of
                            km_mouse_l  : kt_mleft  :=-1;
                            km_mouse_r  : kt_mright :=-1;
                            km_mouse_m  : begin
                                             m_vmove   :=false;
                                             kt_mmiddle:=-1;
                                          end
                           else
                           end;
      SDL_MOUSEBUTTONDOWN: begin
                              m_TwiceLast :=(m_Last=sys_EVENT^.button.button)and(mt_TwiceLast>0);
                              m_Last      :=sys_EVENT^.button.button;
                              mt_TwiceLast:=kt_TwiceDelay;

                              m_TwiceLeft :=(m_TwiceLast)and(m_Last=km_mouse_l);

                              case (sys_EVENT^.button.button) of
                              km_mouse_l  : if(kt_mleft  =0)then kt_mleft  :=1;
                              km_mouse_r  : if(kt_mright =0)then kt_mright :=1;
                              km_mouse_m  : if(kt_mmiddle=0)then kt_mmiddle:=1;
                              km_mouse_wd : if(menu_state)then
                                            begin
                                               if(menu_ItemIsUnderCursor(mi_saveload_list      ))then menu_redraw:=menu_redraw or ScrollInt(@svld_list_scroll   , 1,0,svld_list_size    -menu_saveload_listh ,false);
                                               if(menu_ItemIsUnderCursor(mi_replays_list       ))then menu_redraw:=menu_redraw or ScrollInt(@rpls_list_scroll   , 1,0,rpls_list_size    -menu_replays_listh  ,false);
                                               if(menu_ItemIsUnderCursor(mi_mplay_NetSearchList))then menu_redraw:=menu_redraw or ScrollInt(@net_svsearch_scroll, 1,0,net_svsearch_listn-menu_netsearch_listh,false);
                                            end;
                              km_mouse_wu : if(menu_state)then
                                            begin
                                               if(menu_ItemIsUnderCursor(mi_saveload_list      ))then menu_redraw:=menu_redraw or ScrollInt(@svld_list_scroll   ,-1,0,svld_list_size    -menu_saveload_listh ,false);
                                               if(menu_ItemIsUnderCursor(mi_replays_list       ))then menu_redraw:=menu_redraw or ScrollInt(@rpls_list_scroll   ,-1,0,rpls_list_size    -menu_replays_listh  ,false);
                                               if(menu_ItemIsUnderCursor(mi_mplay_NetSearchList))then menu_redraw:=menu_redraw or ScrollInt(@net_svsearch_scroll,-1,0,net_svsearch_listn-menu_netsearch_listh,false);
                                            end;
                              else
                              end;
                           end;
      SDL_QUITEV         : GameCycle:=false;
      SDL_KEYUP          : begin
                              kt_Last:=-1;
                              case (sys_EVENT^.key.keysym.sym) of
                              km_arrow_up   : kt_up   :=-1;
                              km_arrow_down : kt_down :=-1;
                              km_arrow_left : kt_left :=-1;
                              km_arrow_right: kt_right:=-1;
                              km_lshift,
                              km_rshift     : kt_shift:=-1;
                              km_lctrl,
                              km_rctrl      : kt_ctrl :=-1;
                              km_lalt,
                              km_ralt       : kt_alt  :=-1;
                              else
                              end;
                           end;
      SDL_KEYDOWN        : begin
                              kt_Last     :=1;
                              k_LastChar  :=Widechar(sys_EVENT^.key.keysym.unicode);
                              k_KeyboardString+=k_LastChar;

                              k_TwiceLast :=(k_Last=sys_EVENT^.key.keysym.sym)and(kt_TwiceLast>0);
                              k_Last      :=sys_EVENT^.key.keysym.sym;
                              kt_TwiceLast:=kt_TwiceDelay;

                              case (sys_EVENT^.key.keysym.sym) of
                              km_arrow_up   : if(kt_up   =0)then kt_up   :=1;
                              km_arrow_down : if(kt_down =0)then kt_down :=1;
                              km_arrow_left : if(kt_left =0)then kt_left :=1;
                              km_arrow_right: if(kt_right=0)then kt_right:=1;
                              km_lshift,
                              km_rshift     : if(kt_shift=0)then kt_shift:=1;
                              km_lctrl,
                              km_rctrl      : if(kt_ctrl =0)then kt_ctrl :=1;
                              km_lalt,
                              km_ralt       : if(kt_alt  =0)then kt_alt  :=1;
                              km_Screenshot : MakeScreenshot;
                              //km_Esc        : input_key_escape;
                              km_Enter      : input_key_return;
                              else
                                 case menu_state of
                                 false: if(G_Started)and(ingame_chat=0)then GameHotkeys(k_Last);
                                 true : Menu_Hotkeys(k_Last);
                                 end;
                              end;
                           end;
     else
     end;
end;



procedure g_mouse;
type mf_type = (mf_none,mf_map,mf_mmap,mf_panel);
var
mouse_rx,
mouse_ry   : integer;
mouse_f    : mf_type;
function PointInRect(mx,my,rx,ry,rw,rh:integer):boolean;
begin
   mx-=rx;
   my-=ry;
   PointInRect:=(0<mx)and(mx<rw)
             and(0<my)and(my<rh);
   if(PointInRect)then
   begin
      mouse_rx:=mx;
      mouse_ry:=my;
   end;
end;
begin
   mouse_f:=mf_none;
   if(PointInRect(mouse_x,mouse_y,ui_MapView_x   ,ui_MapView_y   ,vid_cam_w      ,vid_cam_h      ))then mouse_f:=mf_map;
   if(PointInRect(mouse_x,mouse_y,ui_MiniMap_x   ,ui_MiniMap_y   ,vid_panel_pw   ,vid_panel_pw   ))then mouse_f:=mf_mmap;
   if(PointInRect(mouse_x,mouse_y,ui_ControlBar_x,ui_ControlBar_y,ui_ControlBar_w,ui_ControlBar_h))then mouse_f:=mf_panel;

   if(mouse_f<>mf_mmap)or(mouse_select_x0>-1)then
   begin
      mouse_map_x:=mouse_x+vid_cam_x-ui_MapView_x;
      mouse_map_y:=mouse_y+vid_cam_y-ui_MapView_y;
   end
   else
     if(mouse_f=mf_mmap)then
     begin
        mouse_map_x:=trunc(mouse_rx/map_mm_cx);
        mouse_map_y:=trunc(mouse_ry/map_mm_cx);
     end;

   ui_uhint:=0;
   ui_CursorUnit:=nil;
   if(mouse_f=mf_map)then ui_CursorUnit:=ui_GetCursorUnit(mouse_map_x,mouse_map_y);
   if(ui_CursorUnit<>nil)then ui_uhint:=ui_CursorUnit^.unum;

   // pannel bx by
   m_panelBtn_x:=-1;
   m_panelBtn_y:=-1;
   if(mouse_f=mf_panel)then
   begin
      if(kt_mleft  =1)
      or(kt_mright =1)
      or(kt_mmiddle=1)then ui_PanelClick;
      case vid_PannelPos of
vpp_left,
vpp_right  : begin
                m_panelBtn_x:=mouse_rx div vid_BW;if(mouse_rx<0)then m_panelBtn_x-=1;
                m_panelBtn_y:=mouse_ry div vid_BW;if(mouse_ry<0)then m_panelBtn_y-=1;
             end;
vpp_top,
vpp_bottom : begin
                m_panelBtn_x:=mouse_ry div vid_BW;if(mouse_ry<0)then m_panelBtn_x-=1;
                m_panelBtn_y:=mouse_rx div vid_BW;if(mouse_rx<0)then m_panelBtn_y-=1;
             end;
      end;
   end;

   mbrush_Check(false);

   if(kt_mleft=1)then // LMB down
     case m_brush of
     mb_empty  : case mouse_f of
                 mf_map   : if(kt_ctrl>0)or(m_TwiceLeft)then
                            begin
                               if(ui_CursorUnit<>nil)then
                                 units_SelectRect(kt_shift>0,PlayerClient,vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,ui_CursorUnit^.uidi);
                            end
                            else
                            begin
                               mouse_select_x0:=mouse_map_x;
                               mouse_select_y0:=mouse_map_y;
                            end;
                 mf_mmap  : m_mmap_move:=true;
                 mf_panel : if(m_panelBtn_y>0)
                            then ui_PanelButton(ui_tab,m_panelBtn_x,m_panelBtn_y,pct_left,m_TwiceLeft)
                            else
                              case vid_PannelPos of   // first line, tabs
                              vpp_left,
                              vpp_right  : ui_tab:=i2tab[mm3i(ord(low(TTabType)),mouse_rx div vid_tBW,ord(high(TTabType)))];
                              vpp_top,
                              vpp_bottom : ui_tab:=i2tab[mm3i(ord(low(TTabType)),mouse_ry div vid_tBW,ord(high(TTabType)))];
                              end;
                 end;
     mb_mark   : ;
     1..255    : case mouse_f of
                 mf_map,
                 mf_mmap  : if(m_brushc=c_lime)
                            then PlayerSetOrder(mbrush_x,mbrush_y,0,0,m_brush,po_build,PlayerClient)
                            else GameLogCantProduction(PlayerClient,byte(m_brush),lmt_argt_unit,ureq_place,mouse_map_x,mouse_map_y,true);
                 end;
     -255..-1  : case mouse_f of
                 mf_map,
                 mf_mmap  : begin
                            PlayerSetOrder(mouse_map_x,mouse_map_y,ui_uhint,0,-m_brush,po_unit_order_set,PlayerClient);
                            m_brush:=0;
                            end;
                 end;
     end;


   if(kt_mleft=-1)then  // LMB up
   begin
      m_mmap_move:=false;
      if(mouse_select_x0>-1)then // rect select
      begin
         units_SelectRect(kt_shift>0,PlayerClient,mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,255);
         mouse_select_x0:=-1;
      end;
   end;

   if(m_mmap_move)and(mouse_select_x0=-1)then
   begin
      GameCameraMoveToPoint(trunc((mouse_x-ui_MiniMap_x)/map_mm_cx),trunc((mouse_y-ui_MiniMap_y)/map_mm_cx));
      GameCameraBounds;
   end;

   if(kt_mright =1)then // mouse right down
     if(m_brush<>mb_empty)
     then m_brush:=mb_empty
     else
       case mouse_f of
       mf_map,
       mf_mmap  : if(m_action)
                  then PlayerSetOrder(mouse_map_x,mouse_map_y,ui_uhint,0,ua_move ,po_unit_order_set,PlayerClient) // move
                  else PlayerSetOrder(mouse_map_x,mouse_map_y,ui_uhint,0,ua_amove,po_unit_order_set,PlayerClient);// attack
       mf_panel : ui_PanelButton(ui_tab,m_panelBtn_x,m_panelBtn_y,pct_right,false);
       end;
   if(kt_mmiddle=1)then // mouse middle down
     if(m_brush=mb_empty)then
       case mouse_f of
       mf_map   : if(not rpls_POVCam)then m_vmove:=true;
       mf_panel : ui_PanelButton(ui_tab,m_panelBtn_x,m_panelBtn_y,pct_middle,false);
       end;
end;

procedure GameCameraScreenEdgeScroll;
begin
   if(mouse_x<vid_vmb_x0)then vid_cam_x-=vid_CamSpeed;
   if(mouse_y<vid_vmb_y0)then vid_cam_y-=vid_CamSpeed;
   if(mouse_x>vid_vmb_x1)then vid_cam_x+=vid_CamSpeed;
   if(mouse_y>vid_vmb_y1)then vid_cam_y+=vid_CamSpeed;
end;

procedure GameCameraMove;
var vx,vy:integer;
begin
   vx:=vid_cam_x;
   vy:=vid_cam_y;

   if(vid_CamMSEScroll)then GameCameraScreenEdgeScroll;

   if(kt_up   >0)then vid_cam_y-=vid_CamSpeed;
   if(kt_left >0)then vid_cam_x-=vid_CamSpeed;
   if(kt_down >0)then vid_cam_y+=vid_CamSpeed;
   if(kt_right>0)then vid_cam_x+=vid_CamSpeed;

   if(vx<>vid_cam_x)or(vy<>vid_cam_y)then GameCameraBounds;
end;

procedure g_keyboard;
begin
   if(not m_vmove)and(not rpls_POVCam)then GameCameraMove;
   if(ingame_chat>0)then net_chat_str:=txt_StringApplyInput(net_chat_str,k_kbstr,ChatLen2,nil);
end;

procedure InputGame;
begin
   WindowEvents;

   if(menu_state)then
   begin
      menu_keyborad;
      menu_mouse;
      if(menu_remake)then
      begin
         menu_ReBuild;
         menu_redraw:=true;
         menu_remake:=false;
      end;
   end
   else
   begin
      g_keyboard;
      g_mouse;
   end;
end;



