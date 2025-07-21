
const
// pannel click type
pct_left   = 1;
pct_right  = 2;
pct_middle = 3;

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
   else ToggleMenu;
end;

function MakeChatTargets(a,player:byte):byte;
var p:byte;
begin
   MakeChatTargets:=0;
   case a of
chat_all      : MakeChatTargets:=255;
chat_allies   : for p:=1 to MaxPlayers do
                 with g_players[p] do
                  if(state>ps_none)and(team=g_players[player].team)then
                   SetBBit(@MakeChatTargets,p,true);
1..MaxPlayers : if(g_players[a].state=ps_human)then SetBBit(@MakeChatTargets,a,true);
   end;
end;

procedure input_key_return;
var HPlayerAllies: byte;
begin
   if(MainMenu=false)and(ingame_chat=0)and(net_status>ns_none)then
   begin
      HPlayerAllies:=PlayerAllies(LocalPlayer,false);
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
      net_chat_tar:=MakeChatTargets(ingame_chat,LocalPlayer);
   end
   else
    if(menu_item=100)or(ingame_chat>0)then
    begin
       if(MainMenu)then
       begin
          ingame_chat :=chat_all;
          net_chat_tar:=255;
       end;

       if(length(net_chat_str)>0)and(net_chat_tar>0)then
       begin
          if(net_status=ns_client)
          then net_send_chat(        net_chat_tar,net_chat_str)
          else GameLogChat  (LocalPlayer,net_chat_tar,net_chat_str,false);
       end;
       net_chat_str:='';
       ingame_chat :=0;
    end;
end;

procedure GameTogglePause;
begin
   if(net_status=ns_client)
   then net_pause
   else
     if(net_status=ns_server) then
       if(G_Status=gs_running)then
       begin
          G_Status:=LocalPlayer;
          GameLogChat(LocalPlayer,255,str_PlayerPaused,false);
       end
       else
       begin
          G_Status:=gs_running;
          GameLogChat(LocalPlayer,255,str_PlayerResumed,false);
       end;
end;

procedure MapMarker(x,y:integer);
begin
   if(net_status=ns_client)
   then net_SendMapMark(x,y)
   else GameLogMapMark(LocalPlayer,x,y);
   m_brush:=co_empty;
end;

procedure ui_ClientCommandEffect(cmd,tar,ox1,oy1:integer);
var
i,
SelectedAll,
SelectedActions,
SelectedRebuild,
SelectedBOrders: integer;
LeaderUID      : byte;
function _checkEnemy:boolean;
begin
   _checkEnemy:=false;
   if(IsUnitRange(tar,nil))then
    if(g_units[tar].player^.team<>g_players[LocalPlayer].team)then _checkEnemy:=true;
end;
procedure _PlayCommand(ss:PTSoundSet);
begin
   SoundPlayUnitCommand(ss);
   ui_UnitSelectedn:=0;
end;
procedure _ClickEffect(color:cardinal);
begin
   ui_click_eff(ox1,oy1,fr_fpsd4,color);
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
       or(unit_sAbility(pu,true)=0)
       or(unit_pAbility(pu,0,0,0,true)=0)then exit;
      if(UnitHaveRPoint(uidi))then exit;
   end;
   CheckBOrders:=false;
end;

begin
   LeaderUID      :=0;
   SelectedAll    :=0;
   SelectedBOrders:=0;
   SelectedActions:=0;
   SelectedRebuild:=0;      // ????????????????????

   with g_players[LocalPlayer] do
   begin
      for i:=1 to MaxUnits do
       with g_units[i] do
        with uid^ do
         if(hits>0)and(sel)and(playeri=LocalPlayer)then
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
            if(_ability    >0)or(transportC>0)then SelectedActions+=1;
            if(_rebuild_uid>0)then SelectedRebuild+=1;
         end;

      case cmd of
      co_supgrade,
      co_cupgrade,
      co_suprod,
      co_cuprod,
      co_pcancle  : ;
      co_rcamove,
      co_rcmove,
      co_stand,
      co_move,
      co_patrol,
      co_astand,
      co_amove,
      co_apatrol  : if(SelectedBOrders<=0)then exit;
      co_pability: if(SelectedActions<=0)then exit;
      //co_sability,
      //co_pability : if(SelectedActions<=0)then begin _PlayCommand(snd_cant_order[race]);exit;end;
      co_rebuild  : if(SelectedRebuild<=0)then exit; //_PlayCommand(snd_cant_order[race]);
      else          if(SelectedAll    <=0)then exit;
      end;
   end;

   with g_uids[LeaderUID] do
   case cmd of
   co_pability,
   co_rcmove,
   co_move,
   co_astand,
   co_stand,
   co_patrol   : _PlayCommand(un_snd_move);
   co_amove,
   co_apatrol  : _PlayCommand(un_snd_attack);
   co_rcamove  : if(_checkEnemy)
                 then _PlayCommand(un_snd_attack)
                 else _PlayCommand(un_snd_move  );
   end;

   ox1+=vid_mapx;
   oy1+=vid_mapy;

   if(IsUnitRange(tar,nil))then
   begin
      ui_umark_u:=tar;
      ui_umark_t:=fr_fpsd2;
      exit;
   end;

   case cmd of
   co_pability : _ClickEffect(c_aqua  );
   co_rcamove  : _ClickEffect(c_yellow);
   co_rcmove,
   co_move,
   co_patrol   : _ClickEffect(c_lime  );
   co_amove,
   co_apatrol  : _ClickEffect(c_red   );
   end;
end;

procedure PlayerSendOrder(ox0,oy0,ox1,oy1,oa0:integer;oid,pl:byte);
var u:integer;
begin
   if(G_Status=gs_running)and(rpls_state<rpls_read)then
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

         with g_players[LocalPlayer] do
           net_writebyte(byte(s_all));
         for u:=1 to MaxUnits do
           with g_punits[u]^ do
             if(hits>0)and(sel)and(LocalPlayer=playeri)and(not IsUnitRange(transport,nil))then
               net_writeint(unum);

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
      uo_corder : ui_ClientCommandEffect(ox0,oy0,ox1,oy1);
      end;
   end;
end;

function _whoInPoint(tx,ty:integer;tt:byte):integer;
var i,sc:integer;
  tteam :byte;
function _ch(up:PTPlayer):boolean;
begin
   _ch:=true;
   case tt of
   1  : _ch:=up^.team<>tteam;
   2  : _ch:=up^.team= tteam;
   3,4: _ch:=up^.pnum= LocalPlayer;
   end;
end;
begin
   {
   tt:
      0 - any
      1 - enemy, unum
      2 - own&ally, unum
      3 - own, uid
      4 - own, unum
      5 - any
   }
   sc:=0;
   with g_players[UIPlayer] do
   begin
      sc+=ucl_cs[false];
      sc+=ucl_cs[true ];
      tteam:=team;
   end;
   _whoInPoint:=0;
   if(PointInCam(tx,ty))then
    for i:=1 to MaxUnits do
     with g_punits[i]^ do
      if(hits>0)and(transport=0)and(_ch(player))then
       if(CheckUnitTeamVision(tteam,g_punits[i],false))or(CheckUnitUIVision(g_punits[i]))then
        if(point_dist_rint(vx,vy,tx,ty)<uid^._r)then
        begin
           case tt of
           1,2: begin
                   if(playeri=UIPlayer)and(sc=1)and(sel=true)then continue;
                   _whoInPoint:=i;
                end;
           3  : _whoInPoint:=uidi;
           else _whoInPoint:=i;
           end;
           break;
       end;
end;

procedure check_mouse_brush(log:boolean);
var cndt:cardinal;
begin
   m_brushx:=mouse_map_x;
   m_brushy:=mouse_map_y;

   if(UIPlayer<>LocalPlayer)
   then m_brush:=co_empty
   else
   case m_brush of
   0     : m_brush:=co_empty;
   1..255: begin
              if not(m_brush in ui_bprod_possible)then
              begin
                 m_brush:=co_empty;
                 exit;
              end;

              cndt:=CheckUnitReqs(@g_players[LocalPlayer],m_brush);
              if(cndt>0)then
              begin
                 if(log)then GameLogCantProduction(LocalPlayer,byte(m_brush),lmt_argt_unit,cndt,-1,-1,true);
                 m_brush:=co_empty;
              end
              else
               with g_players[LocalPlayer] do
               begin
                  if not(m_brush in ui_bprod_possible)or(n_builders<=0)then
                  begin
                     GameLogCantProduction(LocalPlayer,byte(m_brush),lmt_argt_unit,ureq_common,-1,-1,true);
                     m_brush:=co_empty;
                     exit;
                  end;

                  if(ks_ctrl<=0)then
                  begin
                     BuildingFindNewPlace(mouse_map_x,mouse_map_y,m_brush,LocalPlayer,@m_brushx,@m_brushy,g_players[LocalPlayer].team);
                     m_brushx:=mm3i(ui_cam_x,m_brushx,ui_cam_x+vid_cam_w);
                     m_brushy:=mm3i(ui_cam_y,m_brushy,ui_cam_y+vid_cam_h);
                  end;

                  case CheckBuildPlace(m_brushx,m_brushy,0,0,LocalPlayer,m_brush) of
          0 :  m_brushc:=c_lime;
          1 :  m_brushc:=c_red;
          2 :  m_brushc:=c_blue;
          else m_brushc:=c_gray;
                  end;
               end;
           end;
co_pability          : if(PlayerSetProdError(LocalPlayer,lmt_argt_abil,255,unit_pability(ui_uibtn_pabilityu,0,0,0,true),ui_uibtn_pabilityu))
                       then m_brush:=co_empty
                       else
                         with ui_uibtn_pabilityu^ do
                         with uid^ do
                           case _ability of
                           uab_HKeepBlink,
                           uab_HTowerBlink,
                           uab_CCFly         : math_push_out(mouse_map_x,mouse_map_y,_r                    ,unum,@m_brushx,@m_brushy,false,true,g_players[LocalPlayer].team);
                           uab_RebuildInPoint: math_push_out(mouse_map_x,mouse_map_y,g_uids[_rebuild_uid]._r,unum,@m_brushx,@m_brushy,false,true,g_players[LocalPlayer].team);
                           end;
co_move   ,co_patrol  ,
co_amove  ,co_apatrol : if(ui_uibtn_move  =0)then m_brush:=co_empty;
   else
   end;
end;

procedure ui_command(x,y,target:integer);
begin
   case m_brush of
co_move     : PlayerSendOrder(m_brush   ,target,x,y,0,uo_corder,LocalPlayer);   // move
co_amove    : PlayerSendOrder(m_brush   ,target,x,y,0,uo_corder,LocalPlayer);   // attack
co_pability: if(ui_uibtn_pabilityu<>nil)then
              PlayerSendOrder(m_brush   ,target,x,y,ui_uibtn_pabilityu^.uid^._ability,
                                                  uo_corder,LocalPlayer);
co_patrol,
co_apatrol  : PlayerSendOrder(m_brush   ,0     ,x,y,0,uo_corder,LocalPlayer);
co_empty    :
         if(m_RightClickAct)// rclick
         then PlayerSendOrder(co_rcmove ,target,x,y,0,uo_corder,LocalPlayer)
         else PlayerSendOrder(co_rcamove,target,x,y,0,uo_corder,LocalPlayer);
   end;

   m_brush:=co_empty;
end;

procedure ui_ControlPanel_click(tab,bx,by:integer;click_type:byte;click_dbl:boolean);
var u:integer;
begin
   SoundPlayUI(snd_click);

   case by of
   3 : case ui_ControlPanelPos of   // tabs
       0,1: begin mouse_x-=vid_panelx; if(mouse_y>ui_CtrlPanelW)then ui_tab:=mm3i(0,mouse_x div ui_TabButtonW,3);mouse_x+=vid_panelx;end;
       2,3: begin mouse_y-=vid_panely; if(mouse_x>ui_CtrlPanelW)then ui_tab:=mm3i(0,mouse_y div ui_TabButtonW,3);mouse_y+=vid_panely;end;
       end;
   else
     if(by=ui_menu_btnsy)then
     begin
        case bx of         // buttons
        0 : ToggleMenu;
        1 : ;
        2 : if(net_status>ns_none)then GameTogglePause;
        end;
        exit;
     end;

     if(by<4)
     or(   ui_menu_btnsy<by)
     or(bx<0)
     or(   2<bx)then exit;

     by-=4;// 0,0 under minimap

     u:=(by*3)+(bx mod 3);

     if(u<=ui_ButtonsNum)then
       with g_players[LocalPlayer] do
         case tab of
0:  if(G_Status=gs_running)and(rpls_state<rpls_read)then  // buildings
      case click_type of
pct_left   : begin
             m_brush:=ui_panel_uids[race,tab,u];
             check_mouse_brush(true);
             end;
      end;

1:  if(G_Status=gs_running)and(rpls_state<rpls_read)then  // units
      case click_type of
pct_left   : PlayerSendOrder(co_suprod  ,ui_panel_uids[race,tab,u],vid_cam_cx,vid_cam_cy,0,uo_corder,LocalPlayer);
pct_right  : PlayerSendOrder(co_cuprod  ,ui_panel_uids[race,tab,u],vid_cam_cx,vid_cam_cy,0,uo_corder,LocalPlayer);
      end;

2:  if(G_Status=gs_running)and(rpls_state<rpls_read)then  // upgrades
      case click_type of
pct_left   : PlayerSendOrder(co_supgrade,ui_panel_uids[race,tab,u],vid_cam_cx,vid_cam_cy,0,uo_corder,LocalPlayer);
pct_right  : PlayerSendOrder(co_cupgrade,ui_panel_uids[race,tab,u],vid_cam_cx,vid_cam_cy,0,uo_corder,LocalPlayer);
      end;

3:  case ControlTabType of
    1 : begin //////////////////////////////////////////////////////////////////
           if(rpls_fstatus=rpls_read)then
             case u of
           1 : case click_type of
      pct_left   : replay_SetPlayPosition(g_step-(fr_fps1*2      )+1);
      pct_right  : replay_SetPlayPosition(g_step-(fr_fps1*10     )+1);
      pct_middle : replay_SetPlayPosition(g_step-(fr_fps1*fr_fps1)+1);
               end;
           2 : case click_type of
      pct_left   : rpls_step:=fr_fpsd2*2 ;
      pct_right  : rpls_step:=fr_fpsd2*10;
      pct_middle : rpls_step:=fr_fpsd2*fr_fps1;
               end;
             else
                 if(click_type=pct_left)then
                   case u of
             0 : uncappedFPS:=not uncappedFPS;
             3 : if (G_Status<>gs_replayend)
                 and(G_Status<>gs_replayerror)then
                 begin
                    if  (G_Status =gs_running    )
                    then G_Status:=gs_replaypause
                    else G_Status:=gs_running;
                    rpls_step:=0;
                 end;
             4 : rpls_plcam  :=not rpls_plcam;
             5 : rpls_showlog:=not rpls_showlog;
             6 : rpls_fog    :=not rpls_fog;
         8..14 : UIPlayer    :=u-8;
                   end;
             end;
        end;
    2 : //////////////////////////////////////////////////////////////////
        if(click_type=pct_left)then
          case u of
          0    :  rpls_fog:=not rpls_fog;
          2..8 :  UIPlayer:=u-2;
          end;
    3 : //////////////////////////////////////////////////////////////////
        if(G_Status=gs_running)then
         if(click_type=pct_left)then
         begin
            case u of
            10: if(ui_orders_x[MaxUnitGroups]>0)then
                  if(click_dbl)
                  then MoveCamToPoint(ui_orders_x[MaxUnitGroups],ui_orders_y[MaxUnitGroups])
                  else units_SelectGroup(false,LocalPlayer,255); //PlayerSendOrder(0,0,0,0,0,uo_specsel,LocalPlayer);
            12: m_brush :=co_mmark;
            13: m_RightClickAct:=not m_RightClickAct;
            else
                if(g_players[LocalPlayer].s_all>0)then
                case u of
                0 : if(ui_uibtn_sabilityu<>nil)then
                      if(not PlayerSetProdError(LocalPlayer,lmt_argt_abil,254,unit_sability(ui_uibtn_sabilityu,true),ui_uibtn_sabilityu))then
                        PlayerSendOrder(co_sability,0,vid_cam_cx,vid_cam_cy,ui_uibtn_sabilityu^.uid^._ability  , uo_corder  ,LocalPlayer);
                1 : if(ui_uibtn_pabilityu<>nil)then
                    begin
                       m_brush :=co_pability;
                       check_mouse_brush(true);
                    end;
                2 : if(ui_uibtn_rebuildu<>nil)then
                      if(not PlayerSetProdError(LocalPlayer,lmt_argt_unit,0,unit_rebuild (ui_uibtn_rebuildu,true),ui_uibtn_rebuildu))then
                        PlayerSendOrder(co_rebuild ,0,vid_cam_cx,vid_cam_cy,ui_uibtn_rebuildu^.uid^._rebuild_uid, uo_corder  ,LocalPlayer);

                3 : m_brush :=co_amove;
                4 : PlayerSendOrder(co_astand  ,0,0,0,0, uo_corder  ,LocalPlayer);
                5 : m_brush :=co_apatrol;

                6 : m_brush :=co_move;
                7 : PlayerSendOrder(co_stand   ,0,0,0,0, uo_corder  ,LocalPlayer);
                8 : m_brush :=co_patrol;

                9 : if(s_barracks>0)
                    or(s_smiths  >0)
                    then PlayerSendOrder(co_pcancle ,0,0,0,0, uo_corder  ,LocalPlayer)
                    else
                      case ui_tab of
                      1 : PlayerSendOrder(co_cuprod  ,255,0,0,0,uo_corder,LocalPlayer);
                      2 : PlayerSendOrder(co_cupgrade,255,0,0,0,uo_corder,LocalPlayer);
                      end;
                11: PlayerSendOrder(co_destroy,0,0,0,0 ,uo_corder  ,LocalPlayer);
                end;
            end;

            check_mouse_brush(false);
         end;
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
                 then begin if(map_scenario=mc_invasion)then g_inv_wave_n+=1; end
                 else uncappedFPS:=not uncappedFPS;
{$IFDEF DEBUG0}
sdlk_home      : _warpten:=not _warpten;
{$ENDIF}
sdlk_pageup    : with g_players[LocalPlayer] do if(state=ps_human      )then state:=ps_ai       else state:=ps_human;
sdlk_pagedown  : with g_players[LocalPlayer] do if(upgr[upgr_invuln]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
sdlk_backspace : rpls_fog:=not rpls_fog;
SDLK_F3        : nullupgr(LocalPlayer);
{SDLK_F4        : with g_players[LocalPlayer] do
                  if(IsUnitRange(ai_scout_u_cur,nil))then
                   with g_units[ai_scout_u_cur] do MoveCamToPoint(x,y); }
SDLK_F4        : if(map_scenario=mc_invasion)then
                   if(ks_ctrl>0)
                   then PlayerKill(0,true)
                   else GameModeInvasionSpawnMonsters(g_inv_limit,(ul1*g_inv_wave_n));
SDLK_F5        : LocalPlayer:=0;
SDLK_F6        : LocalPlayer:=1;
SDLK_F7        : LocalPlayer:=2;
SDLK_F8        : LocalPlayer:=3;
SDLK_F9        : LocalPlayer:=4;
SDLK_F10       : LocalPlayer:=5;
SDLK_F11       : LocalPlayer:=6;
{SDLK_P         : begin
                 writeln(g_players[LocalPlayer].a_units[UID_Sergant ]);
                 writeln(g_players[LocalPlayer].a_units[UID_SSergant]);
                 writeln(ui_panel_uids[r_uac,1,0]);
                 writeln(ui_panel_uids[r_uac,1,1]);
                 end;    }
sdlk_insert    : r_draw:= not r_draw;
   else test_hotkeys:=false;
   end;
end;

procedure _hotkeys(k:cardinal);
var ko,k2:cardinal;
begin
   k_dbl:=(k_dblt>0)and(k=k_dblk);
   k_dblt:=fr_fpsd4;
   k_dblk:=k;

   PlayerAPMInc(LocalPlayer);

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
      if(TestMode>0)and(net_status=0)then
        if(test_hotkeys(k))then exit;

      k2:=0;
      if(ks_ctrl >0)then k2:=SDLK_LCtrl;
      if(ks_alt  >0)then k2:=SDLK_LAlt;
      if(ks_shift>0)then k2:=SDLK_LShift;

      if(k=sdlk_space)and(k2=0)then
      begin
         MoveCamToLastEvent;
         exit;
      end;

      case ControlTabType of
      1 : for ko:=0 to max_HotKeys do  // replays
          begin
             if(HotKeysReplay[ko]= 0 )
             or(HotKeysReplay[ko]<>k )then continue;
             ui_ControlPanel_click(3,ko mod 3,4+(ko div 3),kbState2pct,k_dbl);
             exit;
          end;
      2 : for ko:=0 to max_HotKeys do  // observer
          begin
             if(HotKeysObserv[ko]= 0 )
             or(HotKeysObserv[ko]<>k )then continue;
             ui_ControlPanel_click(3,ko mod 3,4+(ko div 3),kbState2pct,k_dbl);
             exit;
          end;
      3 : begin
             case ui_tab of                // normal panels
          0,1,2:for ko:=0 to max_HotKeys do
                begin
                   if(HotKeysBase2[ko]<>k2)
                   or(HotKeysBase1[ko]= 0 )
                   or(HotKeysBase1[ko]<>k )then continue;
                   ui_ControlPanel_click(ui_tab,ko mod 3,4+(ko div 3),pct_left,false);
                   exit;
                end;
             end;

             if(G_Status=gs_running)then
             begin
                for ko:=0 to max_HotKeys do  // actions   HotKeysAction2
                begin
                   if(HotKeysAction2[ko]<>k2)
                   or(HotKeysAction1 [ko]= 0 )
                   or(HotKeysAction1 [ko]<>k )then continue;
                   ui_ControlPanel_click(3,ko mod 3,4+(ko div 3),pct_left,k_dbl);
                   exit;
                end;

                case k of
             sdlk_0..sdlk_9 :  begin
                                  ko:=sys_EVENT^.key.keysym.sym-sdlk_0;
                                  if(ko<MaxUnitGroups)then
                                   if(ks_ctrl>0)
                                   then units_Grouping(false,LocalPlayer,ko)//PlayerSendOrder(ko,0,0,0,0,uo_setorder,LocalPlayer)
                                   else
                                     if(ks_alt>0)
                                     then units_Grouping(true ,LocalPlayer,ko) //PlayerSendOrder(ko,0,0,0,0,uo_addorder,LocalPlayer)
                                     else
                                       if(k_dbl)and(ui_orders_x[ko]>0)and(ko>0)
                                       then MoveCamToPoint(ui_orders_x[ko] , ui_orders_y[ko])
                                       else units_SelectGroup(ks_shift>0,LocalPlayer,ko);//PlayerSendOrder(ko,ks_shift,0,0,0,uo_selorder,LocalPlayer);
                               end;
                else
                end;
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
     if(0<i^)and(i^<32000)then i^+=1;
end;

procedure WindowEvents;
begin
   _keyp(@ks_up       ); // arrows
   _keyp(@ks_down     );
   _keyp(@ks_right    );
   _keyp(@ks_left     );
   _keyp(@ks_shift    );
   _keyp(@ks_ctrl     );
   _keyp(@ks_alt      );
   _keyp(@ks_mleft    ); // mouse btns
   _keyp(@ks_mright   );
   _keyp(@ks_mmiddle  );
   _keyp(@k_chart     ); // last key

   if(k_dblt>0)then k_dblt-=1;

   k_keyboard_string:='';

   if(k_chart>k_chrtt)then
    if(length(k_keyboard_string)<255)then k_keyboard_string+=k_char;

   while (SDL_PollEvent(sys_EVENT)>0) do
    case (sys_EVENT^.type_) of
      SDL_MOUSEMOTION    : begin
                              if(m_DragCamMove)and(MainMenu=false)and(G_Started)then
                              begin
                                 ui_cam_x-=sys_EVENT^.motion.x-mouse_x;
                                 ui_cam_y-=sys_EVENT^.motion.y-mouse_y;
                                 CameraBounds;
                              end;
                              mouse_x:=sys_EVENT^.motion.x;
                              mouse_y:=sys_EVENT^.motion.y;
                           end;
      SDL_MOUSEBUTTONUP  : case (sys_EVENT^.button.button) of
                            SDL_BUTTON_LEFT   : ks_mleft  :=-1;
                            SDL_BUTTON_RIGHT  : ks_mright :=-1;
                            SDL_BUTTON_MIDDLE : begin
                                                m_DragCamMove   :=false;
                                                ks_mmiddle:=-1;
                                                end
                           else
                           end;
      SDL_MOUSEBUTTONDOWN: case (sys_EVENT^.button.button) of
                            SDL_BUTTON_LEFT      : if(ks_mleft =0)then ks_mleft   :=1;
                            SDL_BUTTON_RIGHT     : if(ks_mright=0)then ks_mright  :=1;
                            SDL_BUTTON_MIDDLE    : begin
                                                   if(MainMenu=false)and(G_Started)and(rpls_plcam=false)then m_DragCamMove:=true;
                                                   if(ks_mmiddle=0)then ks_mmiddle:=1;
                                                   end;
                            SDL_BUTTON_WHEELDOWN : if(MainMenu)then
                                                   begin
                                                      menu_redraw:=true;
                                                      case menu_item of
                                                      98: if not(G_Started)then
                                                          ScrollInt(@camp_list_scroll, 1,0,LastMission     -menu_BaseListH);
                                                      mi_SaveLoad_list: ScrollInt(@svld_list_scroll, 1,0,svld_list_size-1-menu_BaseListH);
                                                      mi_Replays_list : ScrollInt(@rpls_list_scroll, 1,0,rpls_list_size-1-menu_BaseListH);
                                                      end;
                                                   end
                                                   else tmpmid-=1;
                            SDL_BUTTON_WHEELUP   : if(MainMenu)then
                                                   begin
                                                      menu_redraw:=true;
                                                      case menu_item of
                                                      98: if not(G_Started)then
                                                          ScrollInt(@camp_list_scroll,-1,0,LastMission     -menu_BaseListH);
                                                      mi_SaveLoad_list: ScrollInt(@svld_list_scroll,-1,0,svld_list_size-1-menu_BaseListH);
                                                      mi_Replays_list : ScrollInt(@rpls_list_scroll,-1,0,rpls_list_size-1-menu_BaseListH);
                                                      end;
                                                   end
                                                   else tmpmid+=1;
                           else
                           end;
      SDL_QUITEV         : GameCycle:=false;
      SDL_VIDEORESIZE    : begin
                           vid_vw:=max2i(vid_minw,sys_EVENT^.resize.w);menu_ResolutionWi:=vid_vw;
                           vid_vh:=max2i(vid_minh,sys_EVENT^.resize.h);menu_ResolutionWi:=vid_vh;

                           vid_MakeScreen;
                           theme_map_pTerrain:=255;
                           gfx_MapMakeTerrain;
                           menu_rebuild:=true;
                           end;
      SDL_KEYUP          : begin
                              k_chart:=-1;
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
                              k_chart  :=2;
                              k_char   :=Widechar(sys_EVENT^.key.keysym.unicode);
                              k_keyboard_string+=k_char;

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
                                sdlk_print  : gfx_MakeScreenshot;
                                sdlk_escape : input_key_escape;
                                SDLK_KP_ENTER,
                                sdlk_return : input_key_return;
                              else
                                if(not MainMenu)and(G_Started)and(ingame_chat=0)then _hotkeys(sys_EVENT^.key.keysym.sym);
                              end;
                           end;
    else
    end;
end;

procedure ui_SicpleClick;
var u:integer;
begin
   u:=_whoInPoint(mouse_map_x,mouse_map_y,4);
   if(u>0)then UpdateLastSelectedUnit(u);
end;

procedure g_mouse;
var u:integer;
begin
   mouse_map_x :=mouse_x+ui_cam_x-vid_mapx;
   mouse_map_y :=mouse_y+ui_cam_y-vid_mapy;
   if(ui_ControlPanelPos<2)then
   begin
      u:=mouse_x-vid_panelx;m_bx:=u div ui_ButtonW1;if(u<0)then m_bx-=1;
      u:=mouse_y-vid_panely;m_by:=u div ui_ButtonW1;if(u<0)then m_by-=1;
   end
   else
   begin
      u:=mouse_y-vid_panely;m_bx:=u div ui_ButtonW1;if(u<0)then m_bx-=1;
      u:=mouse_x-vid_panelx;m_by:=u div ui_ButtonW1;if(u<0)then m_by-=1;
   end;

   if(m_ldblclk>0)then m_ldblclk-=1;

   check_mouse_brush(false);

   ui_uhint:=0;
   if(mouse_select_x0=-1)or(CheckSimpleClick(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y))then
     case m_brush of
co_empty   : ui_uhint:=_whoInPoint(mouse_map_x,mouse_map_y,0);
co_move    : ui_uhint:=_whoInPoint(mouse_map_x,mouse_map_y,2);
co_amove   : ui_uhint:=_whoInPoint(mouse_map_x,mouse_map_y,1);
co_pability: ui_uhint:=_whoInPoint(mouse_map_x,mouse_map_y,5);
     else
     end;

   if(ks_mleft=1)then                // LMB down
    if(m_bx<0)or(3<=m_bx)then        // map
     case m_brush of
co_empty  : if(ks_ctrl>0)
            then units_SelectRect(ks_shift>0,LocalPlayer,ui_cam_x,ui_cam_y, ui_cam_x+vid_cam_w,ui_cam_y+vid_cam_h,_whoInPoint(mouse_map_x,mouse_map_y,3))
            else
            begin
               if(ui_uhint>0)and(ks_mleft=1)then
                 if(d_UpdateUIPlayer(ui_uhint))then exit;
               mouse_select_x0:=mouse_map_x;
               mouse_select_y0:=mouse_map_y;
            end;
1..255    : if(m_brushc=c_lime)
            then PlayerSendOrder(m_brushx,m_brushy,m_brush,0,0, uo_build  ,LocalPlayer)
            else GameLogCantProduction(LocalPlayer,byte(m_brush),lmt_argt_unit,ureq_place,mouse_map_x,mouse_map_y,true);
co_pability,
co_move,
co_amove,
co_patrol,
co_apatrol: ui_command (m_brushx,m_brushy,ui_uhint);
co_mmark  : MapMarker(mouse_map_x,mouse_map_y);
     end
    else
      if(m_by<3)then      // minimap
      case m_brush of
      co_pability,
      co_move,
      co_amove,
      co_patrol,
      co_apatrol : ui_command (trunc((mouse_x-vid_panelx)/map_mmcx),trunc((mouse_y-vid_panely)/map_mmcx),ui_uhint);
      co_mmark   : MapMarker(trunc((mouse_x-vid_panelx)/map_mmcx),trunc((mouse_y-vid_panely)/map_mmcx));
      else         if(rpls_plcam=false)then m_mmap_move:=true;
      end
      else ui_ControlPanel_click(ui_tab,m_bx,m_by,pct_left,k_dbl);     // panel

   if(ks_mleft=-1)then  // LMB up
   begin
      m_mmap_move:=false;

      if(mouse_select_x0>-1)then //select
      begin
         if(m_ldblclk>0)
         then units_SelectRect(ks_shift>0,LocalPlayer,ui_cam_x,ui_cam_y, ui_cam_x+vid_cam_w,ui_cam_y+vid_cam_h,_whoInPoint(mouse_map_x,mouse_map_y,3))
         else
         begin
            units_SelectRect(ks_shift>0,LocalPlayer,mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,255);

            if(G_Status=gs_running)and(rpls_state<rpls_read)then
             if(CheckSimpleClick(mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y))then ui_SicpleClick;
         end;

         mouse_select_x0:=-1;
         m_ldblclk:=fr_fpsd4;
      end;
   end;

   if(m_mmap_move)and(mouse_select_x0=-1)then
   begin
      MoveCamToPoint(trunc((mouse_x-vid_panelx)/map_mmcx), trunc((mouse_y-vid_panely)/map_mmcx));
      CameraBounds;
   end;

 //  if(k_mr=2)then effect_add(mouse_map_x,mouse_map_y-50,10000,UID_Pain);
   {if(ks_mright=1)and(ks_ctrl>2)then
   begin
      u:=_whoInPoint(mouse_map_x,mouse_map_y,0);
      if(u>0)then
       with g_units[u] do hits:=hits div 2;
   end; }

   if(ks_mright=1)then            // RMB down
    if(m_brush<>co_empty)
    then m_brush:=co_empty
    else
     if(m_bx<0)or(3<=m_bx)        // map
     then ui_command(mouse_map_x,mouse_map_y,ui_uhint)
     else
       if(m_by<3)                 // minimap
       then ui_command(trunc((mouse_x-vid_panelx)/map_mmcx), trunc((mouse_y-vid_panely)/map_mmcx),ui_uhint)
       else ui_ControlPanel_click(ui_tab,m_bx,m_by,pct_right,false);     // panel

   if(ks_mmiddle=1)then          // MMB down
    if(m_bx<0)or(3<=m_bx)        // map
    then
    else
      if(m_by<3)                 // minimap
      then
      else ui_ControlPanel_click(ui_tab,m_bx,m_by,pct_middle,false);     // panel
end;

procedure CameraMove;
var vx,vy:integer;
begin
   vx:=ui_cam_x;
   vy:=ui_cam_y;

   if(ui_MouseScroll)then
   begin
      if(mouse_x<vid_vmb_x0)then ui_cam_x-=ui_CamSpeed;
      if(mouse_y<vid_vmb_y0)then ui_cam_y-=ui_CamSpeed;
      if(mouse_x>vid_vmb_x1)then ui_cam_x+=ui_CamSpeed;
      if(mouse_y>vid_vmb_y1)then ui_cam_y+=ui_CamSpeed;
   end;

   if(ks_up   >0)then ui_cam_y-=ui_CamSpeed;
   if(ks_left >0)then ui_cam_x-=ui_CamSpeed;
   if(ks_down >0)then ui_cam_y+=ui_CamSpeed;
   if(ks_right>0)then ui_cam_x+=ui_CamSpeed;

   if(vx<>ui_cam_x)or(vy<>ui_cam_y)then CameraBounds;
end;

procedure g_keyboard;
begin
   if(not m_DragCamMove)and(not rpls_plcam)then CameraMove;
   if(ingame_chat>0)then net_chat_str:=StringApplyInput(net_chat_str,CharSetCommon,ChatLen2,nil);
end;

procedure InputGame;
begin
   WindowEvents;

   if(MainMenu)
   then g_menu
   else
   begin
      {if(ks_mleft =1)
      or(ks_mright=1)
      or(ks_up    =1)
      or(ks_down  =1)
      or(ks_left  =1)
      or(ks_right =1)
      then PlayerAPMInc(LocalPlayer); }

      g_keyboard;
      g_mouse;
   end;
end;



