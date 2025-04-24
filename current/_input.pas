

const
mw_up         = 1;
mw_down       = 2;

type TkbState = (pct_left,pct_right,pct_middle);


function kbState2pct:TkbState;
begin
   kbState2pct:=pct_left;
   //if(kt_ctrl>0)then kbState2pct:=pct_right;
   //if(kt_alt >0)then kbState2pct:=pct_middle;
end;

// INPUT ACTIONS     ikt_keyboard,ikt_mouseb,ikt_mousewh

procedure input_InitDefaultActionHotkeys;
procedure input_SetAction(aaction,adepend:byte;aktype:TInputKeyType;aktvalue:cardinal);
begin
   with input_actions[aaction] do
   begin
      ik_type  :=aktype;
      ik_value :=aktvalue;
      ik_depend:=adepend;
   end;
end;
begin
   input_SetAction(iAct_mlb       ,0           ,ikt_mouseb  ,SDL_BUTTON_LEFT  );
   input_SetAction(iAct_mrb       ,0           ,ikt_mouseb  ,SDL_BUTTON_RIGHT );
   input_SetAction(iAct_mmb       ,0           ,ikt_mouseb  ,SDL_BUTTON_MIDDLE);

   input_SetAction(iAct_mwu       ,0           ,ikt_mousew  ,mw_up            );
   input_SetAction(iAct_mwd       ,0           ,ikt_mousew  ,mw_down          );

   input_SetAction(iAct_left      ,0           ,ikt_keyboard,SDLK_LEFT        );
   input_SetAction(iAct_right     ,0           ,ikt_keyboard,SDLK_RIGHT       );
   input_SetAction(iAct_up        ,0           ,ikt_keyboard,SDLK_UP          );
   input_SetAction(iAct_down      ,0           ,ikt_keyboard,SDLK_DOWN        );

   input_SetAction(iAct_esc       ,0           ,ikt_keyboard,SDLK_ESCAPE      );
   input_SetAction(iAct_return    ,0           ,ikt_keyboard,SDLK_RETURN      );
   input_SetAction(iAct_control   ,0           ,ikt_keyboard,SDLK_LCtrl       );
   input_SetAction(iAct_alt       ,0           ,ikt_keyboard,SDLK_LALt        );
   input_SetAction(iAct_shift     ,0           ,ikt_keyboard,SDLK_LShift      );

   input_SetAction(iAct_LastEvent ,0           ,ikt_keyboard,SDLK_SPACE       );

   input_SetAction(iAct_UAbility1 ,0           ,ikt_keyboard,SDLK_Q           );
   input_SetAction(iAct_UAbility2 ,0           ,ikt_keyboard,SDLK_W           );
   input_SetAction(iAct_UAbility3 ,0           ,ikt_keyboard,SDLK_E           );
   input_SetAction(iAct_Destroy   ,0           ,ikt_keyboard,SDLK_DELETE      );

   input_SetAction(iAct_USetGroup0,iAct_control,ikt_keyboard,SDLK_0           );
   input_SetAction(iAct_USetGroup1,iAct_control,ikt_keyboard,SDLK_1           );
   input_SetAction(iAct_USetGroup2,iAct_control,ikt_keyboard,SDLK_2           );
   input_SetAction(iAct_USetGroup3,iAct_control,ikt_keyboard,SDLK_3           );
   input_SetAction(iAct_USetGroup4,iAct_control,ikt_keyboard,SDLK_4           );
   input_SetAction(iAct_USetGroup5,iAct_control,ikt_keyboard,SDLK_5           );
   input_SetAction(iAct_USetGroup6,iAct_control,ikt_keyboard,SDLK_6           );
   input_SetAction(iAct_USetGroup7,iAct_control,ikt_keyboard,SDLK_7           );
   input_SetAction(iAct_USetGroup8,iAct_control,ikt_keyboard,SDLK_8           );
   input_SetAction(iAct_USetGroup9,iAct_control,ikt_keyboard,SDLK_9           );

   input_SetAction(iAct_UAddGroup0,iAct_alt    ,ikt_keyboard,SDLK_0           );
   input_SetAction(iAct_UAddGroup1,iAct_alt    ,ikt_keyboard,SDLK_1           );
   input_SetAction(iAct_UAddGroup2,iAct_alt    ,ikt_keyboard,SDLK_2           );
   input_SetAction(iAct_UAddGroup3,iAct_alt    ,ikt_keyboard,SDLK_3           );
   input_SetAction(iAct_UAddGroup4,iAct_alt    ,ikt_keyboard,SDLK_4           );
   input_SetAction(iAct_UAddGroup5,iAct_alt    ,ikt_keyboard,SDLK_5           );
   input_SetAction(iAct_UAddGroup6,iAct_alt    ,ikt_keyboard,SDLK_6           );
   input_SetAction(iAct_UAddGroup7,iAct_alt    ,ikt_keyboard,SDLK_7           );
   input_SetAction(iAct_UAddGroup8,iAct_alt    ,ikt_keyboard,SDLK_8           );
   input_SetAction(iAct_UAddGroup9,iAct_alt    ,ikt_keyboard,SDLK_9           );

   input_SetAction(iAct_USelGroup0,0           ,ikt_keyboard,SDLK_0           );
   input_SetAction(iAct_USelGroup1,0           ,ikt_keyboard,SDLK_1           );
   input_SetAction(iAct_USelGroup2,0           ,ikt_keyboard,SDLK_2           );
   input_SetAction(iAct_USelGroup3,0           ,ikt_keyboard,SDLK_3           );
   input_SetAction(iAct_USelGroup4,0           ,ikt_keyboard,SDLK_4           );
   input_SetAction(iAct_USelGroup5,0           ,ikt_keyboard,SDLK_5           );
   input_SetAction(iAct_USelGroup6,0           ,ikt_keyboard,SDLK_6           );
   input_SetAction(iAct_USelGroup7,0           ,ikt_keyboard,SDLK_7           );
   input_SetAction(iAct_USelGroup8,0           ,ikt_keyboard,SDLK_8           );
   input_SetAction(iAct_USelGroup9,0           ,ikt_keyboard,SDLK_9           );

   input_SetAction(iAct_UASlGroup0,iAct_shift  ,ikt_keyboard,SDLK_0           );
   input_SetAction(iAct_UASlGroup1,iAct_shift  ,ikt_keyboard,SDLK_1           );
   input_SetAction(iAct_UASlGroup2,iAct_shift  ,ikt_keyboard,SDLK_2           );
   input_SetAction(iAct_UASlGroup3,iAct_shift  ,ikt_keyboard,SDLK_3           );
   input_SetAction(iAct_UASlGroup4,iAct_shift  ,ikt_keyboard,SDLK_4           );
   input_SetAction(iAct_UASlGroup5,iAct_shift  ,ikt_keyboard,SDLK_5           );
   input_SetAction(iAct_UASlGroup6,iAct_shift  ,ikt_keyboard,SDLK_6           );
   input_SetAction(iAct_UASlGroup7,iAct_shift  ,ikt_keyboard,SDLK_7           );
   input_SetAction(iAct_UASlGroup8,iAct_shift  ,ikt_keyboard,SDLK_8           );
   input_SetAction(iAct_UASlGroup9,iAct_shift  ,ikt_keyboard,SDLK_9           );

   input_SetAction(iAct_UF1      ,0           ,ikt_keyboard,SDLK_F1          );
   input_SetAction(iAct_UF2      ,0           ,ikt_keyboard,SDLK_F2          );
   input_SetAction(iAct_UF3      ,0           ,ikt_keyboard,SDLK_F3          );
   input_SetAction(iAct_UF4      ,0           ,ikt_keyboard,SDLK_F4          );
   input_SetAction(iAct_UF5      ,0           ,ikt_keyboard,SDLK_F5          );
   input_SetAction(iAct_UF6      ,0           ,ikt_keyboard,SDLK_F6          );

   input_SetAction(iAct_UAMove   ,0           ,ikt_keyboard,SDLK_A           );
   input_SetAction(iAct_UAStop   ,0           ,ikt_keyboard,SDLK_S           );
   input_SetAction(iAct_UAPatrol ,0           ,ikt_keyboard,SDLK_D           );
   input_SetAction(iAct_UMove    ,0           ,ikt_keyboard,SDLK_Z           );
   input_SetAction(iAct_UStop    ,0           ,ikt_keyboard,SDLK_X           );
   input_SetAction(iAct_UPatrol  ,0           ,ikt_keyboard,SDLK_C           );

   input_SetAction(iAct_Prod1    ,0           ,ikt_keyboard,SDLK_R           );
   input_SetAction(iAct_Prod2    ,0           ,ikt_keyboard,SDLK_T           );
   input_SetAction(iAct_Prod3    ,0           ,ikt_keyboard,SDLK_Y           );
   input_SetAction(iAct_Prod4    ,0           ,ikt_keyboard,SDLK_F           );
   input_SetAction(iAct_Prod5    ,0           ,ikt_keyboard,SDLK_G           );
   input_SetAction(iAct_Prod6    ,0           ,ikt_keyboard,SDLK_H           );
   input_SetAction(iAct_Prod7    ,0           ,ikt_keyboard,SDLK_V           );
   input_SetAction(iAct_Prod8    ,0           ,ikt_keyboard,SDLK_B           );
   input_SetAction(iAct_Prod9    ,0           ,ikt_keyboard,SDLK_N           );
   input_SetAction(iAct_Prod10   ,0           ,ikt_keyboard,SDLK_U           );
   input_SetAction(iAct_Prod11   ,0           ,ikt_keyboard,SDLK_I           );
   input_SetAction(iAct_Prod12   ,0           ,ikt_keyboard,SDLK_O           );
   input_SetAction(iAct_Prod13   ,0           ,ikt_keyboard,SDLK_J           );
   input_SetAction(iAct_Prod14   ,0           ,ikt_keyboard,SDLK_K           );
   input_SetAction(iAct_Prod15   ,0           ,ikt_keyboard,SDLK_L           );
   input_SetAction(iAct_Prod16   ,iAct_control,ikt_keyboard,SDLK_R           );
   input_SetAction(iAct_Prod17   ,iAct_control,ikt_keyboard,SDLK_T           );
   input_SetAction(iAct_Prod18   ,iAct_control,ikt_keyboard,SDLK_Y           );
   input_SetAction(iAct_Prod19   ,iAct_control,ikt_keyboard,SDLK_F           );
   input_SetAction(iAct_Prod20   ,iAct_control,ikt_keyboard,SDLK_G           );
   input_SetAction(iAct_Prod21   ,iAct_control,ikt_keyboard,SDLK_H           );
   input_SetAction(iAct_Prod22   ,iAct_control,ikt_keyboard,SDLK_V           );
   input_SetAction(iAct_Prod23   ,iAct_control,ikt_keyboard,SDLK_B           );
   input_SetAction(iAct_Prod24   ,iAct_control,ikt_keyboard,SDLK_N           );
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

      if(input_Check(iAct_control,tis_Pressed))then
      begin
         if(PlayerClientAllies<>0)
         then ingame_chat:=chat_allies;
      end
      else
         if(input_Check(iAct_shift,tis_Pressed))
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

                      if(not input_Check(iAct_control,tis_Pressed))then
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
      {if(kt_shift>0)then key2:=km_lshift;
      if(kt_ctrl >0)then key2:=km_lctrl;
      if(kt_alt  >0)then key2:=km_lalt;  }

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
                      //ko2_panel_click(tt_controls,pct_left,k_TwiceLast);
                      exit;
                   end;

                   // control groups
                   case key1 of
        km_group0..km_group9 : begin
                                  {i:=key1-km_group0;
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
                                              GameCameraMoveToPoint(ugroup_x,ugroup_y); }
                               end;
                   else
                   end;
                end;
      end;
   end;
end;


procedure KeyboardStringRussian;
const
  char_num = 65;
  utf  : array[0..char_num] of char = (
#192,  // А
#193,#194,#195,#196,#197,#198,#199,#200,#201,#202,#203,#204,#205,#206,#207,
#208,#209,#210,#211,#212,#213,#214,#215,#216,#217,#218,#219,#220,#221,#222,
#223,  // Я

#224,  // а
#225,#226,#227,#228,#229,#230,#231,#232,#233,#234,#235,#236,#237,#238,#239,
#240,#241,#242,#243,#244,#245,#246,#247,#248,#249,#250,#251,#252,#253,#254,
#255, //я
#229, //ё
#197  //Ё
);
  unic : array[0..char_num] of string[2] = (
#208#144, // А
#208#145,#208#146,#208#147,#208#148,#208#149,#208#150,#208#151,#208#152,
#208#153,#208#154,#208#155,#208#156,#208#157,#208#158,#208#159,#208#160,
#208#161,#208#162,#208#163,#208#164,#208#165,#208#166,#208#167,#208#168,
#208#169,#208#170,#208#171,#208#172,#208#173,#208#174,
#208#175, // Я

#208#176, // а
#208#177,#208#178,#208#179,#208#180,#208#181,#208#182,#208#183,#208#184,
#208#185,#208#186,#208#187,#208#188,#208#189,#208#190,#208#191,#209#128,
#209#129,#209#130,#209#131,#209#132,#209#133,#209#134,#209#135,#209#136,
#209#137,#209#138,#209#139,#209#140,#209#141,#209#142,
#209#143, //я
#209#145, //ё
#208#129  //Ё
  );
var i,p:byte;
begin
   if(length(k_KeyboardString)>=2)then
     for i:=0 to char_num do
     begin
        while(true)do
        begin
           p:=pos(unic[i],k_KeyboardString);
           if(p=0)
           then break
           else
           begin
              delete(k_KeyboardString,p,length(unic[i]));
              insert(utf[i],k_KeyboardString,p);
           end;
        end;
     end;

   {
   а = #208#176      144
   б        177      145
   в        178      146
   г        179      147
   д        180      148
   е        181      149
   ж        182      150
   з        183      151
   и        184      152
   й        185      153
   к        186      154
   л        187      155
   м        188      156
   н        189      157
   о        190      158
   п        191      159
   р   #209#128      160
   с        129      161
   т        130      162
   у        131      163
   ф        132      164
   х        133      165
   ц        134      166
   ч        135      167
   ш        136      168
   щ        137      169
   ъ        138      170
   ы        139      171
   ь        140      172
   э        141      173
   ю        142      174
   я        143      175
   ё        144 #208#129
   }
end;

procedure inputAction_KeyProc(kvalue:cardinal;ktype:TInputKeyType;down:boolean);
var i:byte;
begin
   case ktype of
ikt_keyboard: case kvalue of
              SDLK_RCtrl : kvalue:=SDLK_LCtrl;
              SDLK_RAlt  : kvalue:=SDLK_LAlt;
              SDLK_RShift: kvalue:=SDLK_LShift;
              1105       : kvalue:=SDLK_BACKQUOTE;
              end;
   end;

   for i:=0 to 255 do
     with input_actions[i] do
       if (ik_type =ktype )
       and(ik_value=kvalue)then
         if(ik_depend>0)and(input_actions[ik_depend].ik_timer_pressed>0)then
         begin
            case down of
            false : ik_timer_pressed:=-1;
            true  : begin
                    ik_timer_pressed:= 1;
                    if(ik_timer_twice<=0)then
                    ik_timer_twice:=kt_TwiceDelay;
                    end;
            end;
            exit;
         end;

   for i:=0 to 255 do
     with input_actions[i] do
       if (ik_type =ktype )
       and(ik_value=kvalue)then
         if(ik_depend=0)then
         begin
            case down of
            false : ik_timer_pressed:=-1;
            true  : begin
                    ik_timer_pressed:= 1;
                    if(ik_timer_twice<=0)then
                    ik_timer_twice:=kt_TwiceDelay;
                    end;
            end;
            exit;
         end;

  { if(kvalue>0)then
    if(down)then
    begin
       if(last_key_m=0)then
       begin
          last_key_t:=ktype;
          last_key  :=kvalue;
          last_key_m:=1;
       end;
    end
    else
     if (last_key_t=ktype )
     and(last_key  =kvalue)then
     begin
        last_key_t:=0;
        last_key  :=0;
        last_key_m:=-1;
     end; }
end;


procedure inputAction_TimerProc(keyi:byte);
begin
   with input_actions[keyi] do
     if(ik_timer_pressed<0)
     then ik_timer_pressed:=0
     else
       if(0<ik_timer_pressed)and(ik_timer_pressed<ik_timer_pressed.MaxValue)then
         if(ik_type=ikt_mousew)
         then ik_timer_pressed-=1
         else ik_timer_pressed+=1;
end;

procedure WindowEvents;
var i:byte;
begin
   for i:=0 to 255 do inputAction_TimerProc(i);

   {KeyTimerProc(@kt_up      ); // arrows
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

   // mouse wheel action type


   wy2mwkey               : array[false..true] of cardinal = (mw_up,mw_down);
   }

   k_KeyboardString:='';

   //if(kt_Last>k_LastCharStuckDealy)then
   //  if(length(k_KeyboardString)<255)then k_KeyboardString+=k_LastChar;

   while (SDL_PollEvent(sys_EVENT)>0) do
     case (sys_EVENT^.type_) of
      SDL_TEXTINPUT      : k_KeyboardString+=sys_event^.text.text;
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
      SDL_QUITEV         : GameCycle:=false;
      SDL_MOUSEBUTTONUP  : inputAction_KeyProc(sys_event^.button.button ,ikt_mouseb  ,false);
      SDL_MOUSEBUTTONDOWN: inputAction_KeyProc(sys_event^.button.button ,ikt_mouseb  ,true );
      SDL_KEYUP          : inputAction_KeyProc(sys_event^.key.keysym.sym,ikt_keyboard,false);
      SDL_KEYDOWN        : inputAction_KeyProc(sys_event^.key.keysym.sym,ikt_keyboard,true );
      SDL_MOUSEWHEEL     : if(sys_event^.wheel.y<0)
                      then inputAction_KeyProc(mw_down                  ,ikt_mousew  ,true )
                      else inputAction_KeyProc(mw_up                    ,ikt_mousew  ,true );
      SDL_WINDOWEVENT    : case(sys_event^.window.event)of
                           SDL_WINDOWEVENT_SHOWN,
                           SDL_WINDOWEVENT_HIDDEN,
                           SDL_WINDOWEVENT_EXPOSED,
                           SDL_WINDOWEVENT_MINIMIZED,
                           SDL_WINDOWEVENT_MAXIMIZED,
                           SDL_WINDOWEVENT_RESTORED,
                           SDL_WINDOWEVENT_TAKE_FOCUS,
                           SDL_WINDOWEVENT_FOCUS_GAINED,
                           SDL_WINDOWEVENT_FOCUS_LOST    : ;//clear_keys:=true;
                           SDL_WINDOWEVENT_RESIZED       : begin
                                                           //vid_window_w:=sys_event^.window.data1;
                                                           //vid_window_h:=sys_event^.window.data2;
                                                           //MakeScreenShot_CalcSize(vid_window_w:=sys_event^.window.data1,vid_window_h);
                                                           //clear_keys:=true;
                                                           end;
                           end;


      {
      SDL_MOUSEBUTTONUP  : {case (sys_EVENT^.button.button) of
                            km_mouse_l  : kt_mleft  :=-1;
                            km_mouse_r  : kt_mright :=-1;
                            km_mouse_m  : begin
                                             m_vmove   :=false;
                                             kt_mmiddle:=-1;
                                          end
                           else
                           end};
      SDL_MOUSEBUTTONDOWN: begin
                             { m_TwiceLast :=(m_Last=sys_EVENT^.button.button)and(mt_TwiceLast>0);
                              m_Last      :=sys_EVENT^.button.button;
                              mt_TwiceLast:=kt_TwiceDelay;

                              m_TwiceLeft :=(m_TwiceLast)and(m_Last=km_mouse_l);

                              case (sys_EVENT^.button.button) of
                              km_mouse_l  : if(kt_mleft  =0)then kt_mleft  :=1;
                              km_mouse_r  : if(kt_mright =0)then kt_mright :=1;
                              km_mouse_m  : if(kt_mmiddle=0)then kt_mmiddle:=1;
                              {km_mouse_wd : if(menu_state)then
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
                                            end;  }
                              else
                              end;  }
                           end;

      SDL_KEYUP          : begin
                              {kt_Last:=-1;
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
                              end; }
                           end;
      SDL_KEYDOWN        : begin
                              {kt_Last     :=1;
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
                              end;}
                           end; }
     else
     end;

   KeyboardStringRussian;
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
      if(input_Check(iAct_mlb,tis_NPressed))
      or(input_Check(iAct_mrb,tis_NPressed))
      or(input_Check(iAct_mmb,tis_NPressed))then ui_PanelClick;
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

   if(input_Check(iAct_mlb,tis_NPressed))then // LMB down
     case m_brush of
     mb_empty  : case mouse_f of
                 mf_map   : if(input_Check(iAct_control,tis_Pressed))or(input_Check(iAct_mlb,tis_DPressed))then
                            begin
                               if(ui_CursorUnit<>nil)then
                                 units_SelectRect(input_Check(iAct_shift,tis_Pressed),PlayerClient,vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,ui_CursorUnit^.uidi);
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


   if(input_Check(iAct_mlb,tis_NReleased))then  // LMB up
   begin
      m_mmap_move:=false;
      if(mouse_select_x0>-1)then // rect select
      begin
         units_SelectRect(input_Check(iAct_shift,tis_Pressed),PlayerClient,mouse_select_x0,mouse_select_y0,mouse_map_x,mouse_map_y,255);
         mouse_select_x0:=-1;
      end;
   end;

   if(m_mmap_move)and(mouse_select_x0=-1)then
   begin
      GameCameraMoveToPoint(trunc((mouse_x-ui_MiniMap_x)/map_mm_cx),trunc((mouse_y-ui_MiniMap_y)/map_mm_cx));
      GameCameraBounds;
   end;

   if(input_Check(iAct_mrb,tis_NPressed))then // mouse right down
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
   if(input_Check(iAct_mmb,tis_NPressed))then // mouse middle down
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

   if(input_Check(iAct_up   ,tis_Pressed))then vid_cam_y-=vid_CamSpeed;
   if(input_Check(iAct_left ,tis_Pressed))then vid_cam_x-=vid_CamSpeed;
   if(input_Check(iAct_down ,tis_Pressed))then vid_cam_y+=vid_CamSpeed;
   if(input_Check(iAct_right,tis_Pressed))then vid_cam_x+=vid_CamSpeed;

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

   //if(input_Check(iAct_up,tis_NPressed))then dtest;

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



