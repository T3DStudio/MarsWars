

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
   //              action          parent act   source type  source key
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
   input_SetAction(iAct_backspace ,0           ,ikt_keyboard,SDLK_BackSpace   );
   input_SetAction(iAct_tab       ,0           ,ikt_keyboard,SDLK_Tab         );

   input_SetAction(iAct_ScreenShot,0           ,ikt_keyboard,SDLK_PrintScreen );

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

   input_SetAction(iAct_UF1      ,0            ,ikt_keyboard,SDLK_F1          );
   input_SetAction(iAct_UF2      ,0            ,ikt_keyboard,SDLK_F2          );
   input_SetAction(iAct_UF3      ,0            ,ikt_keyboard,SDLK_F3          );
   input_SetAction(iAct_UF4      ,0            ,ikt_keyboard,SDLK_F4          );
   input_SetAction(iAct_UF5      ,0            ,ikt_keyboard,SDLK_F5          );
   input_SetAction(iAct_UF6      ,0            ,ikt_keyboard,SDLK_F6          );

   input_SetAction(iAct_UAMove   ,0            ,ikt_keyboard,SDLK_A           );
   input_SetAction(iAct_UAStop   ,0            ,ikt_keyboard,SDLK_S           );
   input_SetAction(iAct_UAPatrol ,0            ,ikt_keyboard,SDLK_D           );
   input_SetAction(iAct_UMove    ,0            ,ikt_keyboard,SDLK_Z           );
   input_SetAction(iAct_UStop    ,0            ,ikt_keyboard,SDLK_X           );
   input_SetAction(iAct_UPatrol  ,0            ,ikt_keyboard,SDLK_C           );

   input_SetAction(iAct_Prod1    ,0            ,ikt_keyboard,SDLK_R           );
   input_SetAction(iAct_Prod2    ,0            ,ikt_keyboard,SDLK_T           );
   input_SetAction(iAct_Prod3    ,0            ,ikt_keyboard,SDLK_Y           );
   input_SetAction(iAct_Prod4    ,0            ,ikt_keyboard,SDLK_F           );
   input_SetAction(iAct_Prod5    ,0            ,ikt_keyboard,SDLK_G           );
   input_SetAction(iAct_Prod6    ,0            ,ikt_keyboard,SDLK_H           );
   input_SetAction(iAct_Prod7    ,0            ,ikt_keyboard,SDLK_V           );
   input_SetAction(iAct_Prod8    ,0            ,ikt_keyboard,SDLK_B           );
   input_SetAction(iAct_Prod9    ,0            ,ikt_keyboard,SDLK_N           );
   input_SetAction(iAct_Prod10   ,0            ,ikt_keyboard,SDLK_U           );
   input_SetAction(iAct_Prod11   ,0            ,ikt_keyboard,SDLK_I           );
   input_SetAction(iAct_Prod12   ,0            ,ikt_keyboard,SDLK_O           );
   input_SetAction(iAct_Prod13   ,0            ,ikt_keyboard,SDLK_J           );
   input_SetAction(iAct_Prod14   ,0            ,ikt_keyboard,SDLK_K           );
   input_SetAction(iAct_Prod15   ,0            ,ikt_keyboard,SDLK_L           );
   input_SetAction(iAct_Prod16   ,iAct_control ,ikt_keyboard,SDLK_R           );
   input_SetAction(iAct_Prod17   ,iAct_control ,ikt_keyboard,SDLK_T           );
   input_SetAction(iAct_Prod18   ,iAct_control ,ikt_keyboard,SDLK_Y           );
   input_SetAction(iAct_Prod19   ,iAct_control ,ikt_keyboard,SDLK_F           );
   input_SetAction(iAct_Prod20   ,iAct_control ,ikt_keyboard,SDLK_G           );
   input_SetAction(iAct_Prod21   ,iAct_control ,ikt_keyboard,SDLK_H           );
   input_SetAction(iAct_Prod22   ,iAct_control ,ikt_keyboard,SDLK_V           );
   input_SetAction(iAct_Prod23   ,iAct_control ,ikt_keyboard,SDLK_B           );
   input_SetAction(iAct_Prod24   ,iAct_control ,ikt_keyboard,SDLK_N           );

   input_SetAction(iAct_Prod24   ,iAct_control ,ikt_keyboard,SDLK_N           );


   input_SetAction(iAct_test_FastTime    ,0    ,ikt_keyboard,sdlk_end         );
   input_SetAction(iAct_test_InstaProd   ,0    ,ikt_keyboard,sdlk_home        );
   input_SetAction(iAct_test_ToggleAI    ,0    ,ikt_keyboard,sdlk_pageup      );
   input_SetAction(iAct_test_iddqd       ,0    ,ikt_keyboard,sdlk_pagedown    );
   input_SetAction(iAct_test_FogToggle   ,0    ,ikt_keyboard,sdlk_backspace   );
   input_SetAction(iAct_test_DrawToggle  ,0    ,ikt_keyboard,sdlk_insert      );
   input_SetAction(iAct_test_NullUpgrades,0    ,ikt_keyboard,SDLK_F3          );
   input_SetAction(iAct_test_BePlayer0   ,0    ,ikt_keyboard,SDLK_F4          );
   input_SetAction(iAct_test_BePlayer1   ,0    ,ikt_keyboard,SDLK_F5          );
   input_SetAction(iAct_test_BePlayer2   ,0    ,ikt_keyboard,SDLK_F6          );
   input_SetAction(iAct_test_BePlayer3   ,0    ,ikt_keyboard,SDLK_F7          );
   input_SetAction(iAct_test_BePlayer4   ,0    ,ikt_keyboard,SDLK_F8          );
   input_SetAction(iAct_test_BePlayer5   ,0    ,ikt_keyboard,SDLK_F9          );
   input_SetAction(iAct_test_BePlayer6   ,0    ,ikt_keyboard,SDLK_F10         );
   input_SetAction(iAct_test_BePlayer7   ,0    ,ikt_keyboard,SDLK_F11         );
   input_SetAction(iAct_test_debug0      ,0    ,ikt_keyboard,SDLK_KP_0        );
   input_SetAction(iAct_test_debug1      ,0    ,ikt_keyboard,SDLK_KP_1        );

end;

procedure input_key_escape;
begin
   if(ui_IngameChat>0)then
   begin
      ui_IngameChat :=0;
      net_chat_str:='';
   end
   else ;//menu_Toggle;
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
   if(not menu_state)and(ui_IngameChat=0)and(net_status>ns_single)then
   begin
      PlayerClientAllies:=PlayerGetAlliesByte(PlayerClient,false);
      // default chat
      if(PlayerClientAllies<>0)
      then ui_IngameChat:=chat_allies
      else ui_IngameChat:=chat_all;

      if(InputAction(iAct_control))then
      begin
         if(PlayerClientAllies<>0)
         then ui_IngameChat:=chat_allies;
      end
      else
         if(InputAction(iAct_shift))
         then ui_IngameChat:=chat_all;
      net_chat_tar:=MakeChatTargets(ui_IngameChat,PlayerClient);
   end
   else ;

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

   if(not ui_ActionsIsAllowed)
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

                      if(not InputAction(iAct_control))then
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

procedure ui_SetMapMarker(x,y:integer);
begin
   if(net_status=ns_client)
   then net_SendMapMark(x,y)
   else GameLogMapMark(PlayerClient,x,y);
   m_brush:=mb_empty;
end;

procedure ui_PanelClickEffect;
begin
   SoundPlayUI(snd_click);
   ui_PanelUpdNow:=true;
end;

procedure ui_PanelButton(tab:TTabType;bx,by:integer;click_type:TkbState;click_twice:boolean);
var u:integer;
begin
   if(by=ui_panel_bh)then // last line, common buttons
   begin
      case bx of
      0 : begin
          ui_IngameChat:=0;
          menu_state :=true;
          end;
      2 : if(net_status>ns_single)then GameTogglePause;
      end;
      exit;
   end;
   by-=1;

   if(not ui_ActionsIsAllowed)then exit;

   if(by<0)
   or(   ui_panel_bh<=by)
   or(bx<0)
   or(   ui_panel_bw<=bx)then exit;

   if(ui_CBarPos in VPPSet_Horizontal)then
   begin  // turn ui_panel_bw*ui_panel_bw block if horizontal panel
      u :=bx;
      bx:=by;
      by:=u;
      by+=ui_panel_bw*(bx div ui_panel_bw);
      bx-=ui_panel_bw*(bx div ui_panel_bw);
   end;

   u:=(by*ui_panel_bw)+(bx mod ui_panel_bw);
   writeln(ui_pButtonsCount,' ',u);

   if(0<=u)and(u<=ui_pButtonsCount)then
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
          case tabControlContent of
               // replay
tcp_replay   : case u of
               1: case click_type of
                  pct_left   : replay_SetPlayPosition(g_step-(fr_fps1*2 )+1,-1);
                  pct_right  : replay_SetPlayPosition(g_step-(fr_fps1*10)+1,-1);
                  pct_middle : replay_SetPlayPosition(g_step-(fr_fps1*60)+1,-1);
                  end;
               2: case click_type of
                  pct_left   : if(not replay_SetPlayPosition(g_step+(fr_fps1*2 )+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*2 ;
                  pct_right  : if(not replay_SetPlayPosition(g_step+(fr_fps1*10)+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*10;
                  pct_middle : if(not replay_SetPlayPosition(g_step+(fr_fps1*60)+1,fr_fps1))then rpls_ForwardStep:=fr_fpsd2*60;
                  end;
               else
                  if(click_type=pct_left)then
                    case u of
                    0 : sys_uncappedFPS:=not sys_uncappedFPS;
                    3 : begin
                           if  (G_Status =gs_running    )
                           then G_Status:=gs_replaypause
                           else
                             if(G_Status =gs_replaypause)
                             then G_Status:=gs_running;
                           rpls_ForwardStep:=0;
                        end;
                    4 : rpls_POVCam :=not rpls_POVCam;
                    5 : rpls_showlog:=not rpls_showlog;
                    6 : ui_fog      :=not ui_fog;
                8..17 : ui_player   :=u-8;
                    end;
               end;
               // observer
tcp_observer : if(click_type=pct_left)then
               case u of
               0    :  ui_fog:=not ui_fog;
               2..11:  ui_player:=u-2;
               end;
               // actions
tcp_controls : if(G_Status=gs_running)then
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
                          if(click_twice)
                          then with ui_groups_f1 do GameCameraMoveToPoint(ugroup_x,ugroup_y);
                    11: if(ui_groups_f2.ugroup_n>0)then
                          if(click_twice)
                          then with ui_groups_f2 do GameCameraMoveToPoint(ugroup_x,ugroup_y)
                          else units_SelectGroup(false,255);
                    12: PlayerSetOrder(0,0,0,0,ua_destroy,po_unit_order_set,PlayerClient);  // destroy
                    13: m_brush :=mb_mark;
                    14: m_action:=not m_action;
                    end;

                    mbrush_Check(false);
                 end;
          end;
     end;
end;

{procedure GameHotkeys(key1:cardinal);
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
              else ui_tab:=Succ(ui_tab);         //ui_PanelClickEffect
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
t3pt_controls : if(G_Status=gs_running)then
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
end;  }


procedure KeyboardStringRussian;
const
  char_num = 65;
  utf  : array[0..char_num] of char = (
#192,     // А
#193,#194,#195,#196,#197,#198,#199,#200,#201,#202,#203,#204,#205,#206,#207,
#208,#209,#210,#211,#212,#213,#214,#215,#216,#217,#218,#219,#220,#221,#222,
#223,     // Я

#224,     // а
#225,#226,#227,#228,#229,#230,#231,#232,#233,#234,#235,#236,#237,#238,#239,
#240,#241,#242,#243,#244,#245,#246,#247,#248,#249,#250,#251,#252,#253,#254,
#255,     // я
#229,     // ё
#197      // Ё
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
#209#143, // я
#209#145, // ё
#208#129  // Ё
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
            false : begin
                    ik_timer_pressed:=-1;
                    if(ik_timer_twice<=0)then
                    ik_timer_twice:=kt_TwiceDelay;
                    end;
            true  : if(ik_timer_pressed=0)then
                    ik_timer_pressed:= 1;
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
            false : begin
                    ik_timer_pressed:=-1;
                    if(ik_timer_twice<=0)then
                    ik_timer_twice:=kt_TwiceDelay;
                    end;
            true  : if(ik_timer_pressed=0)then
                    ik_timer_pressed:= 1;
            end;
            //exit;
         end;
end;


procedure inputAction_TimerProc(keyi:byte);
begin
   with input_actions[keyi] do
   begin
      if(ik_timer_pressed<0)
      then ik_timer_pressed:=0
      else
        if(0<ik_timer_pressed)and(ik_timer_pressed<ik_timer_pressed.MaxValue)then
          if(ik_type=ikt_mousew)
          then ik_timer_pressed-=1
          else ik_timer_pressed+=1;
      if(ik_timer_twice>0)then ik_timer_twice-=1;
   end;
end;

procedure WindowEvents;
var i:byte;
begin
   for i:=0 to 255 do inputAction_TimerProc(i);

   k_KeyboardString:='';

   while (SDL_PollEvent(sys_EVENT)>0) do
     case (sys_EVENT^.type_) of
      SDL_TEXTINPUT           : k_KeyboardString+=sys_event^.text.text;
      SDL_MOUSEMOTION         : begin
                                   if(m_vmove)and(not menu_state)and(g_Started)then
                                   begin
                                      vid_cam_x-=round((sys_EVENT^.motion.x-mouse_x)/vid_cam_sc);
                                      vid_cam_y-=round((sys_EVENT^.motion.y-mouse_y)/vid_cam_sc);
                                      GameCameraBounds;
                                   end;
                                   mouse_x:=sys_EVENT^.motion.x;
                                   mouse_y:=sys_EVENT^.motion.y;
                                end;
      SDL_QUITEV              : g_GameCycle:=false;
      SDL_MOUSEBUTTONUP       : inputAction_KeyProc(sys_event^.button.button ,ikt_mouseb  ,false);
      SDL_MOUSEBUTTONDOWN     : inputAction_KeyProc(sys_event^.button.button ,ikt_mouseb  ,true );
      SDL_KEYUP               : inputAction_KeyProc(sys_event^.key.keysym.sym,ikt_keyboard,false);
      SDL_KEYDOWN             : inputAction_KeyProc(sys_event^.key.keysym.sym,ikt_keyboard,true );
      SDL_MOUSEWHEEL          : if(sys_event^.wheel.y<0)
                           then inputAction_KeyProc(mw_down                  ,ikt_mousew  ,true )
                           else inputAction_KeyProc(mw_up                    ,ikt_mousew  ,true );
      SDL_WINDOWEVENT         : case(sys_event^.window.event)of
                                SDL_WINDOWEVENT_SHOWN,
                                SDL_WINDOWEVENT_HIDDEN,
                                SDL_WINDOWEVENT_EXPOSED,
                                SDL_WINDOWEVENT_MINIMIZED,
                                SDL_WINDOWEVENT_MAXIMIZED,
                                SDL_WINDOWEVENT_RESTORED,
                                SDL_WINDOWEVENT_TAKE_FOCUS,
                                SDL_WINDOWEVENT_FOCUS_GAINED,
                                SDL_WINDOWEVENT_FOCUS_LOST    : ;//clear_keys:=true;
                                SDL_WINDOWEVENT_RESIZED       : if(menu_state)then menu_redraw:=true;
                                end;
      SDL_RENDER_TARGETS_RESET: begin
                                map_MinimapBackground;
                                map_RedrawMenuMinimap;
                                gfx_MakeUnitIcons;
                                ui_PanelUpdNow:=true;
                                end;
     else
     end;

   KeyboardStringRussian;
end;

procedure GameCameraZoom(zstep:single);
var cw,ch:integer;
begin
   //cx:=vid_cam_x+vid_cam_hw;
   //cy:=vid_cam_y+vid_cam_hh;
   cw:=vid_cam_w;
   ch:=vid_cam_h;

   vid_cam_sc+=zstep;
   if(vid_cam_sc>vid_cam_Maxsc)then vid_cam_sc:=vid_cam_Maxsc;
   if(vid_cam_sc<vid_cam_Minsc)then vid_cam_sc:=vid_cam_Minsc;
   vid_UpdateCamVars;
   ui_CamSpeedScaled:=round(ui_CamSpeedBase/vid_cam_sc);

   vid_cam_x-=round((vid_cam_w-cw)*((mouse_x/vid_cam_sc)/vid_cam_w));
   vid_cam_y-=round((vid_cam_h-ch)*((mouse_y/vid_cam_sc)/vid_cam_h));

   GameCameraBounds;
   //GameCameraMoveToPoint(cx,cy);
end;

procedure g_mouse;
type mf_type = (mf_none,mf_map,mf_mmap,mf_panel);
var
mouse_rx,
mouse_ry   : integer;
mouse_f    : mf_type;
function PointInRect(mx,my,rx,ry,rw,rh:integer;scale:single):boolean;
begin
   mx-=rx;
   my-=ry;
   PointInRect:=(0<mx)and(mx<rw)
             and(0<my)and(my<rh);
   if(PointInRect)then
   begin
      mouse_rx:=round(mx/scale);
      mouse_ry:=round(my/scale);
   end;
end;
begin
   mouse_rx:=-1;
   mouse_ry:=-1;
   mouse_f :=mf_none;
   if(PointInRect(mouse_x,mouse_y,0              ,0              ,vid_vw         ,vid_vh         ,vid_cam_sc      ))then mouse_f:=mf_map;
   if(PointInRect(mouse_x,mouse_y,ui_MiniMap_x   ,ui_MiniMap_y   ,ui_MiniMap_w   ,ui_MiniMap_w   ,ui_MiniMap_sc   ))then mouse_f:=mf_mmap;
   if(PointInRect(mouse_x,mouse_y,ui_ControlBar_x,ui_ControlBar_y,ui_ControlBar_w,ui_ControlBar_h,ui_ControlBar_sc))then mouse_f:=mf_panel;

   if(mouse_f<>mf_mmap)or(mouse_select_x0>-1)then
   begin
      mouse_map_x:=vid_cam_x+trunc(mouse_x/vid_cam_sc);
      mouse_map_y:=vid_cam_y+trunc(mouse_y/vid_cam_sc);
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
      if(InputActionPressed(iAct_mlb))
      or(InputActionPressed(iAct_mrb))
      or(InputActionPressed(iAct_mmb))then ui_PanelClickEffect;
      case ui_CBarPos of
uicbp_left,
uicbp_right  : begin
                m_panelBtn_x:=mouse_rx div ui_pButtonW1;if(mouse_rx<0)then m_panelBtn_x-=1;
                m_panelBtn_y:=mouse_ry div ui_pButtonW1;if(mouse_ry<0)then m_panelBtn_y-=1;
             end;
uicbp_top,
uicbp_bottom : begin
                m_panelBtn_x:=mouse_ry div ui_pButtonW1;if(mouse_ry<0)then m_panelBtn_x-=1;
                m_panelBtn_y:=mouse_rx div ui_pButtonW1;if(mouse_rx<0)then m_panelBtn_y-=1;
             end;
      end;
   end;

   mbrush_Check(false);

   if(InputActionPressed(iAct_mlb))then // LMB down
     case mouse_f of
     mf_map,
     mf_mmap  : case m_brush of
                mb_empty  : case mouse_f of
                            mf_map   : if(ui_CursorUnit<>nil)and((InputAction(iAct_control))or(InputActionDPressed(iAct_mlb)))
                                       then units_SelectRect(InputAction(iAct_shift),vid_cam_x,vid_cam_y,vid_cam_x+vid_cam_w,vid_cam_y+vid_cam_h,ui_CursorUnit^.uidi)
                                       else
                                       begin
                                          mouse_select_x0:=mouse_x;
                                          mouse_select_y0:=mouse_y;
                                       end;
                            mf_mmap  : if(mouse_select_x0=-1)then m_mmap_move:=true;
                            end;
                mb_mark   : ui_SetMapMarker(mouse_map_x,mouse_map_y);
                1..255    : if(m_brushc=c_lime)
                            then PlayerSetOrder(mbrush_x,mbrush_y,0,0,m_brush,po_build,PlayerClient)
                            else GameLogCantProduction(PlayerClient,byte(m_brush),lmt_argt_unit,ureq_place,mouse_map_x,mouse_map_y,true);
                -255..-1  : begin
                            PlayerSetOrder(mouse_map_x,mouse_map_y,ui_uhint,0,-m_brush,po_unit_order_set,PlayerClient);
                            m_brush:=0;
                            end;
                end;
     mf_panel : if(m_panelBtn_y>0)
                then ui_PanelButton(ui_tab,m_panelBtn_x,m_panelBtn_y,pct_left,InputActionDPressed(iAct_mlb))
                else
                  if(ui_player<=LastPlayer)then
                    case ui_CBarPos of   // first line, tabs
                    uicbp_left,
                    uicbp_right  : ui_tab:=i2tab[mm3i(ord(low(TTabType)),mouse_rx div ui_tButtonW1,ord(high(TTabType)))];
                    uicbp_top,
                    uicbp_bottom : ui_tab:=i2tab[mm3i(ord(low(TTabType)),mouse_ry div ui_tButtonW1,ord(high(TTabType)))];
                    end;
     end;


   if(InputActionReleased(iAct_mlb))then  // LMB up
   begin
      m_mmap_move:=false;
      if(mouse_select_x0>-1)then // rect select
      begin
         units_SelectRect(InputAction(iAct_shift),vid_cam_x+trunc(mouse_select_x0/vid_cam_sc),
                                                  vid_cam_y+trunc(mouse_select_y0/vid_cam_sc),
                                                  mouse_map_x,
                                                  mouse_map_y,255);
         mouse_select_x0:=-1;
      end;
   end;

   if(m_mmap_move)and(mouse_select_x0=-1)then
   begin
      GameCameraMoveToPoint(trunc((mouse_x-ui_MiniMap_x)/ui_MiniMap_sc/map_mm_cx),trunc((mouse_y-ui_MiniMap_y)/ui_MiniMap_sc/map_mm_cx));
      GameCameraBounds;
   end;

   if(InputActionPressed(iAct_mrb))then  // mouse right down
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
   if(InputActionPressed(iAct_mmb))then  // mouse middle down
     case mouse_f of
     mf_map   : if(not rpls_POVCam)and(mouse_select_x0=-1)then m_vmove:=true;
     mf_panel : ui_PanelButton(ui_tab,m_panelBtn_x,m_panelBtn_y,pct_middle,false);
     end;

   if(InputActionReleased(iAct_mmb))then // mouse middle up
     m_vmove:=false;

   if(mouse_f=mf_map )
   or(mouse_f=mf_mmap)then
   begin
      if(InputActionPressed(iAct_mwd))then GameCameraZoom( vid_cam_stepsc);  // mouse wheel down
      if(InputActionPressed(iAct_mwu))then GameCameraZoom(-vid_cam_stepsc);  // mouse wheel up
   end;
end;

procedure GameCameraMove;
var vx,vy:integer;
begin
   vx:=vid_cam_x;
   vy:=vid_cam_y;

   if(ui_CamMSEScroll)then
   begin
      if(mouse_x<vid_vmb_x0)then vid_cam_x-=ui_CamSpeedScaled;
      if(mouse_y<vid_vmb_y0)then vid_cam_y-=ui_CamSpeedScaled;
      if(mouse_x>vid_vmb_x1)then vid_cam_x+=ui_CamSpeedScaled;
      if(mouse_y>vid_vmb_y1)then vid_cam_y+=ui_CamSpeedScaled;
   end;

   if(InputAction(iAct_up   ))then vid_cam_y-=ui_CamSpeedScaled;
   if(InputAction(iAct_left ))then vid_cam_x-=ui_CamSpeedScaled;
   if(InputAction(iAct_down ))then vid_cam_y+=ui_CamSpeedScaled;
   if(InputAction(iAct_right))then vid_cam_x+=ui_CamSpeedScaled;

   if(vx<>vid_cam_x)or(vy<>vid_cam_y)then GameCameraBounds;
end;

procedure testmode_CancelUpgrades(playeri:byte);
var i:byte;
begin
   with g_players[playeri] do
    for i:=1 to 255 do
     upgr[i]:=0;
end;

procedure g_keyboard;
begin
   if(InputActionPressed(iAct_esc))then
     if(ui_IngameChat>0)
     then ui_IngameChat:=0
     else menu_state:=true;

   if(test_mode>0)and(net_status=ns_single)then
   begin
      if(InputActionPressed(iAct_test_FastTime    ))then sys_uncappedFPS:=not sys_uncappedFPS;
      if(InputActionPressed(iAct_test_InstaProd   ))then test_fastprod:=not test_fastprod;
      if(InputActionPressed(iAct_test_ToggleAI    ))then with g_players[PlayerClient] do if(player_type=pt_human)then player_type:=pt_ai else player_type:=pt_human;
      if(InputActionPressed(iAct_test_iddqd       ))then with g_players[PlayerClient] do if(upgr[upgr_invuln ]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
      if(InputActionPressed(iAct_test_FogToggle   ))then ui_fog:=not ui_fog;
      if(InputActionPressed(iAct_test_DrawToggle  ))then vid_draw:=not vid_draw;
      if(InputActionPressed(iAct_test_NullUpgrades))then testmode_CancelUpgrades(PlayerClient);
      if(InputActionPressed(iAct_test_BePlayer0   ))then PlayerClient:=0;
      if(InputActionPressed(iAct_test_BePlayer1   ))then PlayerClient:=1;
      if(InputActionPressed(iAct_test_BePlayer2   ))then PlayerClient:=2;
      if(InputActionPressed(iAct_test_BePlayer3   ))then PlayerClient:=3;
      if(InputActionPressed(iAct_test_BePlayer4   ))then PlayerClient:=4;
      if(InputActionPressed(iAct_test_BePlayer5   ))then PlayerClient:=5;
      if(InputActionPressed(iAct_test_BePlayer6   ))then PlayerClient:=6;
      if(InputActionPressed(iAct_test_BePlayer7   ))then PlayerClient:=7;
      if(InputActionPressed(iAct_test_debug0      ))then debug_SetDomainColors;
      if(InputActionPressed(iAct_test_debug1      ))then begin
                                                         map_ZonesMake;
                                                         map_pf_MarkSolidCells;
                                                         map_pf_MakeDomains;
                                                         end;
   end;

   if(InputActionPressed(iAct_LastEvent))then GameCameraMoveToLastEvent;

   if(ui_player<=LastPlayer)then
     if(InputActionPressed(iAct_tab))then
       if(ui_tab=high(ui_tab))
       then ui_tab:=low (ui_tab)
       else ui_tab:=succ(ui_tab);

   if(ui_IngameChat>0)then
   begin
      net_chat_str:=txt_StringApplyInput(net_chat_str,k_kbstr,ChatLen2,nil);
   end
   else
     if(not m_vmove)and(not rpls_POVCam)and(mouse_select_x0=-1)then GameCameraMove;
end;

procedure MainInput;
begin
   WindowEvents;

   // common input
   if(InputActionReleased(iAct_ScreenShot))then
   begin
      MakeScreenShot;
      exit;
   end;

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



