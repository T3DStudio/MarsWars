
const
// pannel click type
pct_left   = 1;
pct_right  = 2;
pct_middle = 3;

wip_any        = 0;
wip_enemy_unum = 1;
wip_ally_unum  = 2;
wip_own_uid    = 3;
wip_own_unum   = 4;


function kbState2pct:byte;
begin
   kbState2pct:=pct_left;
   if(ks_ctrl>0)then kbState2pct:=pct_right;
   if(ks_alt >0)then kbState2pct:=pct_middle;
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
chat_allies   : for p:=1 to MaxPlayers do
                 with g_players[p] do
                  if(player_type>pt_none)and(team=g_players[player].team)then
                   SetBBit(@MakeChatTargets,p,true);
1..MaxPlayers : if(g_players[a].player_type=pt_human)then SetBBit(@MakeChatTargets,a,true);
   end;
end;

procedure input_key_return;
var HPlayerAllies: byte;
begin
   if(not menu_state)and(ingame_chat=0)and(net_status>ns_single)then
   begin
      HPlayerAllies:=PlayerGetAlliesByte(PlayerClient,false);
      if(HPlayerAllies>0)
      then ingame_chat:=chat_allies
      else ingame_chat:=chat_all;

      if(ks_ctrl>0)then
      begin
         if(HPlayerAllies>0)
         then ingame_chat:=chat_allies;
      end
      else
         if(ks_shift>0)
         then ingame_chat:=chat_all;
      net_chat_tar:=MakeChatTargets(ingame_chat,PlayerClient);
   end
   else
    if(menu_item=100)or(ingame_chat>0)then //menu chat
    begin
       if(menu_state)then
       begin
          ingame_chat :=chat_all;
          net_chat_tar:=255;
       end;

       if(length(net_chat_str)>0)and(net_chat_tar>0)then
       begin
          if(net_status=ns_client)
          then net_send_chat(        net_chat_tar,net_chat_str)
          else GameLogChat  (PlayerClient,net_chat_tar,net_chat_str,false);
       end;
       net_chat_str:='';
       ingame_chat :=0;
    end;
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
   if(IsUnitRange(otarget,@pu))then
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
        or(unit_canAbility(pu)=0)then exit;
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

   with g_players[PlayerClient] do
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
   uo_psability: if(SelectedAbility<=0)then exit;
   uo_rebuild  : if(SelectedRebuild<=0)then exit;
   else          if(SelectedAll    <=0)then exit;
   end;

   if(UnitSound)then
     with g_uids[LeaderUID] do
       case uo_order of
   uo_psability,
   uo_move,
   uo_hold,
   uo_stay,
   uo_patrol   : _PlayCommand(un_snd_move);
   uo_attack,
   uo_apatrol  : _PlayCommand(un_snd_attack);
       end;

   if(IsUnitRange(otarget,nil))then
   begin
      ui_umark_u:=otarget;
      ui_umark_t:=fr_fpsd2;
      exit;
   end;

   ox0+=vid_mapx;
   oy0+=vid_mapy;

   case uo_order of
   uo_psability: _ClickEffect(c_aqua);
   uo_move,
   uo_patrol   : _ClickEffect(c_lime);
   uo_attack,
   uo_apatrol  : _ClickEffect(c_red );
   end;
end;

procedure PlayerSetOrder(ox0,oy0,ox1,oy1,oa0:integer;oid,pl:byte);
begin
   if(G_Status=gs_running)and(rpls_state<rpls_state_read)then
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

function ui_whoInPoint(tx,ty:integer;rtype:byte):integer;
var i,sc:integer;
  tteam :byte;
  fly   :boolean;
function CheckRType(up:PTPlayer):boolean;
begin
   CheckRType:=true;
   case rtype of
   wip_enemy_unum : CheckRType:=up^.team<>tteam;
   wip_ally_unum  : CheckRType:=up^.team= tteam;
   wip_own_uid,
   wip_own_unum   : CheckRType:=up^.pnum= UIPlayer;
   end;
end;
begin
   {
   rtype:
      wip_any        - any      unum
      wip_enemy_unum - enemy    unum
      wip_ally_unum  - own&ally unum
      wip_own_uid    - own      uid
      wip_own_unum   - own      unum
   }
   fly:=false;
   with g_players[UIPlayer] do
   begin
      sc:=ucl_cs[false]+ucl_cs[true ];
      tteam:=team;
   end;
   ui_whoInPoint:=0;
   if(PointInCam(tx,ty))then
    for i:=1 to MaxUnits do
     with g_punits[i]^ do
      if(hits>0)and(not IsUnitRange(transport,nil))and(CheckRType(player))then
       if(ui_CheckUnitUIPlayerVision(g_punits[i],true))then // (CheckUnitTeamVision(tteam,g_punits[i],false))or
        if(point_dist_rint(vx,vy,tx,ty)<uid^._r)then
        begin
           if(ukfly<fly)then continue;
           fly:=ukfly;

           case rtype of
           wip_enemy_unum,
           wip_ally_unum : begin
                           if(playeri=UIPlayer)and(sc=1)and(isselected=true)then continue;
                           ui_whoInPoint:=i;
                           end;
           wip_own_uid   : ui_whoInPoint:=uidi;
           else ui_whoInPoint:=i;
           end;
           break;
       end;
end;

procedure mb_Check(log:boolean);
var cndt:cardinal;
     uid:byte;
begin
   m_brushx:=mouse_map_x;
   m_brushy:=mouse_map_y;

   if(UIPlayer<>PlayerClient)or(g_players[PlayerClient].isobserver)or(g_players[PlayerClient].isdefeated)
   then m_brush:=mb_empty
   else
   case m_brush of
   0     : m_brush:=mb_empty;
   1..255: begin
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

                  if(ks_ctrl<=0)then
                  begin
                     BuildingNewPlace(mouse_map_x,mouse_map_y,uid,PlayerClient,@m_brushx,@m_brushy);
                     m_brushx:=mm3i(vid_cam_x,m_brushx,vid_cam_x+vid_cam_w);
                     m_brushy:=mm3i(vid_cam_y,m_brushy,vid_cam_y+vid_cam_h);
                  end;

                  case CheckBuildPlace(m_brushx,m_brushy,0,0,PlayerClient,uid) of
                  0 :  m_brushc:=c_lime;
                  1 :  m_brushc:=c_red;
                  2 :  m_brushc:=c_blue;
                  else m_brushc:=c_gray;
                  end;
               end;
           end;
mb_psability         : if(ui_uibtn_sability =0)then m_brush:=mb_empty;
mb_move  ,mb_patrol  ,
mb_attack,mb_apatrol : if(ui_uibtn_move     =0)then m_brush:=mb_empty;
   else    m_brush:=mb_empty;
   end;
end;

procedure mb_MapMarker(x,y:integer);
begin
   if(net_status=ns_client)
   then net_SendMapMark(x,y)
   else GameLogMapMark(PlayerClient,x,y);
   m_brush:=mb_empty;
end;

procedure mb_Command(x,y,target:integer);
begin
   case m_brush of
mb_move     : PlayerSetOrder(x,y,target,0,uo_move     ,po_unit_order_set,PlayerClient);   // move
mb_attack   : PlayerSetOrder(x,y,target,0,uo_attack   ,po_unit_order_set,PlayerClient);   // attack
mb_psability: PlayerSetOrder(x,y,target,0,uo_psability,po_unit_order_set,PlayerClient);
mb_patrol   : PlayerSetOrder(x,y,0     ,0,uo_patrol   ,po_unit_order_set,PlayerClient);
mb_apatrol  : PlayerSetOrder(x,y,0     ,0,uo_apatrol  ,po_unit_order_set,PlayerClient);
mb_empty    : // rclick
         if(m_action)
         then PlayerSetOrder(x,y,target,0,uo_move     ,po_unit_order_set,PlayerClient)    // move
         else PlayerSetOrder(x,y,target,0,uo_attack   ,po_unit_order_set,PlayerClient);   // attack
   end;

   m_brush:=mb_empty;
end;

procedure ui_PanelButton(tab,bx,by:integer;click_type:byte;click_dbl:boolean);
var u:integer;
begin
   SoundPlayUI(snd_click);
   case by of
   3 : case vid_PannelPos of   // tabs
       0,1: begin mouse_x-=vid_panelx; if(mouse_y>vid_panelw)then ui_tab:=mm3i(0,mouse_x div vid_tBW,3);mouse_x+=vid_panelx;end;
       2,3: begin mouse_y-=vid_panely; if(mouse_x>vid_panelw)then ui_tab:=mm3i(0,mouse_y div vid_tBW,3);mouse_y+=vid_panely;end;
       end;
   else
     if(by=ui_menu_btnsy)then
     begin
        case bx of         // common buttons
        0 : menu_Toggle;
        1 : ;
        2 : if(net_status>ns_single)then GameTogglePause;
        end;
        exit;
     end;

     if(by<4)
     or(   ui_menu_btnsy<by)
     or(bx<0)
     or(   2<bx)then exit;

     by-=4;// 0,0 under minimap

     if(vid_PannelPos>=2)then
     begin
        u:=bx;
        bx:=by;
        by:=u;
        by+=3*(bx div 3);
        bx-=3*(bx div 3);
     end;

     u:=(by*3)+(bx mod 3);

     if(0<=u)and(u<=ui_ubtns)then
       with g_players[PlayerClient] do
         case tab of
0:  if(G_Status=gs_running)and(rpls_state<rpls_state_read)then  // buildings
      case click_type of
      pct_left   : begin
                   m_brush:=ui_panel_uids[race,tab,u];
                   mb_Check(true);
                   end;
      end;

1:  if(G_Status=gs_running)and(rpls_state<rpls_state_read)then  // units
      case click_type of
      pct_left   : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,tab,u],po_prod_unit_start,PlayerClient);
      pct_right  : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,tab,u],po_prod_unit_stop ,PlayerClient);
      end;

2:  if(G_Status=gs_running)and(rpls_state<rpls_state_read)then  // upgrades
      case click_type of
      pct_left   : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,tab,u],po_prod_upgr_start,PlayerClient);
      pct_right  : PlayerSetOrder(0,0,0,0,ui_panel_uids[race,tab,u],po_prod_upgr_stop ,PlayerClient);
      end;

3:  if(rpls_state>=rpls_state_read)then
    begin
       if(rpls_fstatus=rpls_file_read)then  // replay player controls
       case u of
       1 : case click_type of
           pct_left   : replay_SetPlayPosition(g_step-(fr_fps1*2      )+1,-1);
           pct_right  : replay_SetPlayPosition(g_step-(fr_fps1*10     )+1,-1);
           pct_middle : replay_SetPlayPosition(g_step-(fr_fps1*fr_fps1)+1,-1);
           end;
       2 : case click_type of
           pct_left   : if(not replay_SetPlayPosition(g_step-(fr_fps1*2      )+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*2 ;
           pct_right  : if(not replay_SetPlayPosition(g_step-(fr_fps1*10     )+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*10;
           pct_middle : if(not replay_SetPlayPosition(g_step-(fr_fps1*fr_fps1)+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*fr_fps1;
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
           4 : rpls_plcam  :=not rpls_plcam;
           5 : rpls_showlog:=not rpls_showlog;
           6 : sys_fog    :=not sys_fog;
       8..14 : UIPlayer    :=u-8;
           end;
       end;
   end
   else
     if(g_players[PlayerClient].isobserver)then // isobserver controls
     begin
        if(click_type=pct_left)then
          case u of
          0    :  sys_fog:=not sys_fog;
          2..8 :  UIPlayer:=u-2;
          end;
     end
     else
       if(not g_players[PlayerClient].isdefeated)and(G_Status=gs_running)then
         if(click_type=pct_left)then
         begin
            case u of
            0 : PlayerSetOrder(0,0,0,0,uo_sability,po_unit_order_set,PlayerClient);
            1 : m_brush :=mb_psability;
            2 : PlayerSetOrder(0,0,0,0,uo_rebuild ,po_unit_order_set,PlayerClient);

            3 : m_brush :=mb_attack;
            4 : PlayerSetOrder(0,0,0,0,uo_stay    ,po_unit_order_set,PlayerClient);
            5 : m_brush :=mb_apatrol;

            6 : m_brush :=mb_move;
            7 : PlayerSetOrder(0,0,0,0,uo_hold    ,po_unit_order_set,PlayerClient);
            8 : m_brush :=mb_patrol;

            9 : if(s_barracks>0)
                or(s_smiths  >0)
                then PlayerSetOrder(0,0,0,0,0,po_prod_stop,PlayerClient) // comon production stop
                else
                  case ui_tab of
                  1 : PlayerSetOrder(0,0,0,0,255,po_prod_unit_stop,PlayerClient);
                  2 : PlayerSetOrder(0,0,0,0,255,po_prod_upgr_stop,PlayerClient);
                  end;
            10: if(ui_groups_x[MaxUnitGroups]>0)then
                  if(click_dbl)
                  then GameCameraMoveToPoint(ui_groups_x[MaxUnitGroups],ui_groups_y[MaxUnitGroups])
                  else PlayerSetOrder(0,0,0,0,0,po_select_all_set,PlayerClient);
            11: PlayerSetOrder(0,0,0,0,uo_destroy,po_unit_order_set,PlayerClient);  // destroy
            12: m_brush :=mb_mark;
            13: m_action:=not m_action;
            end;

            mb_Check(false);
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
sdlk_end       : if(ks_ctrl>0)
                 then begin if(g_mode=gm_invasion)then g_inv_wave_n+=1; end
                 else sys_uncappedFPS:=not sys_uncappedFPS;
sdlk_home      : test_fastprod:=not test_fastprod;
sdlk_pageup    : with g_players[PlayerClient] do if(player_type=pt_human)then player_type:=pt_ai else player_type:=pt_human;
sdlk_pagedown  : with g_players[PlayerClient] do if(upgr[upgr_invuln]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
sdlk_backspace : sys_fog:=not sys_fog;
SDLK_F3        : nullupgr(PlayerClient);
{SDLK_F4        : with g_players[PlayerClient] do
                  if(IsUnitRange(ai_scout_u_cur,nil))then
                   with g_units[ai_scout_u_cur] do GameCameraMoveToPoint(x,y); }
SDLK_F4        : if(g_mode=gm_invasion)then
                   if(ks_ctrl>0)
                   then PlayerKill(0)
                   else GameModeInvasionSpawnMonsters(g_inv_limit,(ul1*g_inv_wave_n));
SDLK_F5        : PlayerClient:=0;
SDLK_F6        : PlayerClient:=1;
SDLK_F7        : PlayerClient:=2;
SDLK_F8        : PlayerClient:=3;
SDLK_F9        : PlayerClient:=4;
SDLK_F10       : PlayerClient:=5;
SDLK_F11       : PlayerClient:=6;
sdlk_insert    : r_draw:= not r_draw;
   else test_hotkeys:=false;
   end;
end;

procedure InGameHotkeys(k:cardinal);
var ko,k2:cardinal;
procedure ko2_panel_click(tabN,ClickType:byte;kdbl:boolean);
begin
   if(vid_PannelPos<2)
   then ui_PanelButton(tabN, ko mod 3      ,4+(ko div 3)             ,ClickType,kdbl)
   else ui_PanelButton(tabN,(ko div 3)mod 3,4+(ko div 9)*3+(ko mod 3),ClickType,kdbl);
end;
begin
   k_dbl:=(ks_dbl>0)and(k=k_dblk);
   ks_dbl:=fr_fpsd4;
   k_dblk:=k;

   PlayerAPMInc(PlayerClient);

   if(k=sdlk_pause)then
   begin
      GameTogglePause;
      exit;
   end;

   case k of
sdlk_tab: begin
             ui_tab+=1;
             ui_tab:=ui_tab mod 4;
          end;
1       : ; // ?????
   else
      if(test_mode>0)and(net_status=ns_single)then
        if(test_hotkeys(k))then exit;

      k2:=0;
      if(ks_ctrl >0)then k2:=SDLK_LCtrl;
      if(ks_alt  >0)then k2:=SDLK_LAlt;
      if(ks_shift>0)then k2:=SDLK_LShift;

      if(k=sdlk_space)and(k2=0)then
      begin
         GameCameraMoveToLastEvent;
         exit;
      end;

      if(rpls_state>=rpls_state_read)then
      begin
         for ko:=0 to _mhkeys do  // replays
         begin
            if(_hotkeyR[ko]= 0 )
            or(_hotkeyR[ko]<>k )then continue;
            ko2_panel_click(3,kbState2pct,false);
            exit;
         end;
      end
      else
        if(g_players[PlayerClient].isobserver)then
        begin
           for ko:=0 to _mhkeys do  // observer
           begin
              if(_hotkeyO[ko]= 0 )
              or(_hotkeyO[ko]<>k )then continue;
              ko2_panel_click(3,kbState2pct,false);
              exit;
           end;
        end
        else
        begin
           case ui_tab of                // normal panels
          0,1,2:for ko:=0 to _mhkeys do
                begin
                   if(_hotkey2 [ko]<>k2)
                   or(_hotkey1 [ko]= 0 )
                   or(_hotkey1 [ko]<>k )then continue;
                   ko2_panel_click(ui_tab,pct_left,false);
                   exit;
                end;
           end;

           if(G_Status=gs_running)then
           begin
              for ko:=0 to _mhkeys do  // actions   _hotkeyA2
              begin
                 if(_hotkeyA2[ko]<>k2)
                 or(_hotkeyA [ko]= 0 )
                 or(_hotkeyA [ko]<>k )then continue;
                 ko2_panel_click(3,pct_left,k_dbl);
                 exit;
              end;
              case k of
          sdlk_0..sdlk_9 : begin
                              ko:=sys_EVENT^.key.keysym.sym-sdlk_0;
                              if(ko<MaxUnitGroups)then
                                if(ks_ctrl>0)
                                then PlayerSetOrder(0,0,0,0,ko,po_unit_group_set,PlayerClient)
                                else
                                  if(ks_alt>0)
                                  then PlayerSetOrder(0,0,0,0,ko,po_unit_group_add,PlayerClient)
                                  else
                                    if(k_dbl)and(ui_groups_x[ko]>0)and(ko>0)
                                    then GameCameraMoveToPoint(ui_groups_x[ko],ui_groups_y[ko])
                                    else
                                      if(ks_shift>0)
                                      then PlayerSetOrder(0,0,0,0,ko,po_select_group_add,PlayerClient)
                                      else PlayerSetOrder(0,0,0,0,ko,po_select_group_set,PlayerClient);
                           end;
              else
              end;
           end;
        end;
   end;
end;

procedure _keyp(i:pinteger);
begin
   if(i^<0)
   then i^:=0
   else
     if(0<i^)and(i^<i^.MaxValue)then i^+=1;
end;

procedure WindowEvents;
begin
   _keyp(@ks_up      ); // arrows
   _keyp(@ks_down    );
   _keyp(@ks_right   );
   _keyp(@ks_left    );
   _keyp(@ks_shift   );
   _keyp(@ks_ctrl    );
   _keyp(@ks_alt     );
   _keyp(@ks_mleft   ); // mouse btns
   _keyp(@ks_mright  );
   _keyp(@ks_mmiddle );
   _keyp(@ks_LastChar); // last key

   if(ks_dbl>0)then ks_dbl-=1;

   k_keyboard_string:='';

   if(ks_LastChar>k_chrtt)then
     if(length(k_keyboard_string)<255)then k_keyboard_string+=k_LastChar;

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
                            SDL_BUTTON_LEFT   : ks_mleft  :=-1;
                            SDL_BUTTON_RIGHT  : ks_mright :=-1;
                            SDL_BUTTON_MIDDLE : begin
                                                m_vmove   :=false;
                                                ks_mmiddle:=-1;
                                                end
                           else
                           end;
      SDL_MOUSEBUTTONDOWN: case (sys_EVENT^.button.button) of
                            SDL_BUTTON_LEFT      : if(ks_mleft =0)then ks_mleft   :=1;
                            SDL_BUTTON_RIGHT     : if(ks_mright=0)then ks_mright  :=1;
                            SDL_BUTTON_MIDDLE    : begin
                                                   if(not menu_state)and(G_Started)and(not rpls_plcam)then m_vmove:=true;
                                                   if(ks_mmiddle=0)then ks_mmiddle:=1;
                                                   end;
                            SDL_BUTTON_WHEELDOWN : if(menu_state)then
                                                   begin
                                                   if(menu_UnderCursor(mi_saveload_list      ))then menu_redraw:=menu_redraw or ScrollInt(@svld_list_scroll   , 1,0,svld_list_size    -menu_saveload_listh ,false);
                                                   if(menu_UnderCursor(mi_replays_list       ))then menu_redraw:=menu_redraw or ScrollInt(@rpls_list_scroll   , 1,0,rpls_list_size    -menu_replays_listh  ,false);
                                                   if(menu_UnderCursor(mi_mplay_NetSearchList))then menu_redraw:=menu_redraw or ScrollInt(@net_svsearch_scroll, 1,0,net_svsearch_listn-menu_netsearch_listh,false);
                                                   end;
                            SDL_BUTTON_WHEELUP   : if(menu_state)then
                                                   begin
                                                   if(menu_UnderCursor(mi_saveload_list      ))then menu_redraw:=menu_redraw or ScrollInt(@svld_list_scroll   ,-1,0,svld_list_size    -menu_saveload_listh ,false);
                                                   if(menu_UnderCursor(mi_replays_list       ))then menu_redraw:=menu_redraw or ScrollInt(@rpls_list_scroll   ,-1,0,rpls_list_size    -menu_replays_listh  ,false);
                                                   if(menu_UnderCursor(mi_mplay_NetSearchList))then menu_redraw:=menu_redraw or ScrollInt(@net_svsearch_scroll,-1,0,net_svsearch_listn-menu_netsearch_listh,false);
                                                   end;
                           else
                           end;
      SDL_QUITEV         : GameCycle:=false;
      SDL_KEYUP          : begin
                              ks_LastChar:=-1;
                              case (sys_EVENT^.key.keysym.sym) of
                                sdlk_up     : ks_up   :=-1;
                                sdlk_down   : ks_down :=-1;
                                sdlk_left   : ks_left :=-1;
                                sdlk_right  : ks_right:=-1;
                                sdlk_rshift : ks_shift:=-1;
                                sdlk_lshift : ks_shift:=-1;
                                sdlk_lctrl  : ks_ctrl :=-1;
                                sdlk_rctrl  : ks_ctrl :=-1;
                                sdlk_lalt   : ks_alt  :=-1;
                                sdlk_ralt   : ks_alt  :=-1;
                              else
                              end;
                           end;
      SDL_KEYDOWN        : begin
                              ks_LastChar  :=1;
                              k_LastChar   :=Widechar(sys_EVENT^.key.keysym.unicode);
                              k_keyboard_string+=k_LastChar;

                              case (sys_EVENT^.key.keysym.sym) of
                                sdlk_up     : if(ks_up   =0)then ks_up   :=1;
                                sdlk_down   : if(ks_down =0)then ks_down :=1;
                                sdlk_left   : if(ks_left =0)then ks_left :=1;
                                sdlk_right  : if(ks_right=0)then ks_right:=1;
                                sdlk_rshift : if(ks_shift=0)then ks_shift:=1;
                                sdlk_lshift : if(ks_shift=0)then ks_shift:=1;
                                sdlk_rctrl  : if(ks_ctrl =0)then ks_ctrl :=1;
                                sdlk_lctrl  : if(ks_ctrl =0)then ks_ctrl :=1;
                                sdlk_ralt   : if(ks_alt  =0)then ks_alt  :=1;
                                sdlk_lalt   : if(ks_alt  =0)then ks_alt  :=1;
                                sdlk_print  : MakeScreenshot;
                                sdlk_escape : input_key_escape;
                                sdlk_return : input_key_return;
                              else
                                if(not menu_state)and(G_Started)and(ingame_chat=0)then InGameHotkeys(sys_EVENT^.key.keysym.sym);
                              end;
                           end;
     else
     end;
end;

procedure ui_PointClick;
var u:integer;
begin
   u:=ui_whoInPoint(mouse_map_x,mouse_map_y,4);
   if(u>0)then UpdateLastSelectedUnit(u);
end;

procedure g_mouse;
var u:integer;
begin
   mouse_map_x:=mouse_x+vid_cam_x-vid_mapx;
   mouse_map_y:=mouse_y+vid_cam_y-vid_mapy;

   // pannel bx by
   if(vid_PannelPos<2)then  //vertical
   begin
      u:=mouse_x-vid_panelx;m_bx:=u div vid_BW;if(u<0)then m_bx-=1;
      u:=mouse_y-vid_panely;m_by:=u div vid_BW;if(u<0)then m_by-=1;
   end
   else
   begin
      u:=mouse_y-vid_panely;m_bx:=u div vid_BW;if(u<0)then m_bx-=1;
      u:=mouse_x-vid_panelx;m_by:=u div vid_BW;if(u<0)then m_by-=1;
   end;

   mb_Check(false);

   ui_uhint:=0;
   if(mouse_select_x0=-1)or(CheckSimpleClick(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y))then
     case m_brush of
mb_psability,
mb_empty    : ui_uhint:=ui_whoInPoint(mouse_map_x,mouse_map_y,wip_any       );
mb_move     : ui_uhint:=ui_whoInPoint(mouse_map_x,mouse_map_y,wip_ally_unum );
mb_attack   : ui_uhint:=ui_whoInPoint(mouse_map_x,mouse_map_y,wip_enemy_unum);
     end;

   if(ks_mleft=1)then                // LMB down
     if(0<=m_bx)and(m_bx<3)and(0<=m_by)and(m_by<=ui_menu_btnsy)then // panel
     begin
        if(m_by>=3)
        then ui_PanelButton(ui_tab,m_bx,m_by,pct_left,k_dbl)
        else
          case m_brush of
       mb_psability,
       mb_move,
       mb_attack,
       mb_patrol,
       mb_apatrol : mb_Command  (trunc((mouse_x-vid_panelx)/map_mm_cx),trunc((mouse_y-vid_panely)/map_mm_cx),ui_uhint);
       mb_mark    : mb_MapMarker(trunc((mouse_x-vid_panelx)/map_mm_cx),trunc((mouse_y-vid_panely)/map_mm_cx));
          else      if(rpls_plcam=false)then m_mmap_move:=true;
          end;
     end
     else
       case m_brush of
mb_empty    : if(ks_ctrl>0)then
              begin
                 u:=ui_whoInPoint(mouse_map_x,mouse_map_y,wip_own_uid);
                 if(0<u)and(u<255)then
                   if(ks_shift>0)
                   then PlayerSetOrder(vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,u,po_select_uid_add,PlayerClient)
                   else PlayerSetOrder(vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,u,po_select_uid_set,PlayerClient);
                 exit;
              end
              else
              begin
                 if(d_UpdateUIPlayer(ui_uhint))then exit;

                 //debug_zone:=map_GetZone(mouse_map_x,mouse_map_y,true);

                 mouse_select_x0:=mouse_map_x;
                 mouse_select_y0:=mouse_map_y;
              end;
1..255      : if(m_brushc=c_lime)
              then PlayerSetOrder(m_brushx,m_brushy,0,0,m_brush,po_build,PlayerClient)
              else GameLogCantProduction(PlayerClient,byte(m_brush),lmt_argt_unit,ureq_place,mouse_map_x,mouse_map_y,true);
mb_psability,
mb_move,
mb_attack,
mb_patrol,
mb_apatrol  : mb_Command  (mouse_map_x,mouse_map_y,ui_uhint);
mb_mark     : mb_MapMarker(mouse_map_x,mouse_map_y);
       end;

   if(ks_mleft=-1)then  // LMB up
   begin
      m_mmap_move:=false;

      if(mouse_select_x0>-1)then //select
      begin
         if(mleft_dbl_click>0)then
         begin
            u:=ui_whoInPoint(mouse_map_x,mouse_map_y,wip_own_uid);
            if(0<u)and(u<255)then
              if(ks_shift>0)
              then PlayerSetOrder(vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,u,po_select_uid_add,PlayerClient)
              else PlayerSetOrder(vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,u,po_select_uid_set,PlayerClient);
         end
         else
         begin
            if(ks_shift>0)
            then PlayerSetOrder(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,0,po_select_rect_add,PlayerClient)
            else PlayerSetOrder(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,0,po_select_rect_set,PlayerClient);

            if(G_Status=gs_running)and(rpls_state<rpls_state_read)then
              if(CheckSimpleClick(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y))then ui_PointClick;
         end;

         mouse_select_x0:=-1;
      end;
   end;

   if(m_mmap_move)and(mouse_select_x0=-1)then
   begin
      GameCameraMoveToPoint(trunc((mouse_x-vid_panelx)/map_mm_cx),trunc((mouse_y-vid_panely)/map_mm_cx));
      GameCameraBounds;
   end;

 //  if(k_mr=2)then effect_add(mouse_map_x,mouse_map_y-50,10000,UID_Pain);

   if(ks_mright =1)then
     if(m_brush<>mb_empty)
     then m_brush:=mb_empty
     else
       if(0<=m_bx)and(m_bx<3)and(0<=m_by)and(m_by<=ui_menu_btnsy)then // panel
       begin
          if(m_by<3)               // minimap
          then mb_Command(trunc((mouse_x-vid_panelx)/map_mm_cx),trunc((mouse_y-vid_panely)/map_mm_cx),ui_uhint)
          else ui_PanelButton(ui_tab,m_bx,m_by,pct_right,false);      // panel
       end
       else mb_Command(mouse_map_x,mouse_map_y,ui_uhint);

   if(ks_mmiddle=1)then            // middle down
     if(0<=m_bx)and(m_bx<3)and(0<=m_by)and(m_by<=ui_menu_btnsy)then   // panel
     begin
        if(m_by<3)                 // minimap
        then
        else ui_PanelButton(ui_tab,m_bx,m_by,pct_middle,false);
     end
     else ;
end;

procedure GameCameraMoveMScroll;
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

   if(vid_CamMScroll)then GameCameraMoveMScroll;

   if(ks_up   >0)then vid_cam_y-=vid_CamSpeed;
   if(ks_left >0)then vid_cam_x-=vid_CamSpeed;
   if(ks_down >0)then vid_cam_y+=vid_CamSpeed;
   if(ks_right>0)then vid_cam_x+=vid_CamSpeed;

   if(vx<>vid_cam_x)or(vy<>vid_cam_y)then GameCameraBounds;
end;

procedure g_keyboard;
begin
   if(not m_vmove)and(not rpls_plcam)then GameCameraMove;
   if(ingame_chat>0)then net_chat_str:=StringApplyInput(net_chat_str,k_kbstr,ChatLen2,nil);
end;

procedure InputGame;
begin
   WindowEvents;

   if(mleft_dbl_click>0)then mleft_dbl_click-=1;

   if(menu_state)then
   begin
      menu_keyborad;
      menu_mouse;
      if(menu_remake)then
      begin
         menu_ReInit;
         menu_redraw:=true;
         menu_remake:=false;
      end;
   end
   else
   begin
      {if(ks_mleft =1)
      or(ks_mright=1)
      or(ks_up    =1)
      or(ks_down  =1)
      or(ks_left  =1)
      or(ks_right =1)
      then PlayerAPMInc(PlayerClient); }

      g_keyboard;
      g_mouse;
   end;

   if(ks_mleft=-1)then mleft_dbl_click:=fr_fpsd5;
end;



